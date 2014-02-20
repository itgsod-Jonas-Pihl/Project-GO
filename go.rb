require "openid/store/filesystem"
require "omniauth/strategies/steam"
require 'net/http'


class GamersOnline < Sinatra::Base
  api_key = "8DA685124F4E525EC2A97F2C932F3763"

  use OmniAuth::Builder do
    provider :steam, api_key, :storage => OpenID::Store::Filesystem.new("/tmp")
  end

  Faye::WebSocket.load_adapter('thin')

  use Faye::RackAdapter, :mount => '/faye', :timeout => 45

  enable :sessions

  get '/' do

    if session['steamid'] != nil
      @games = JSON.parse(Net::HTTP.get(URI("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{api_key}&steamid=#{session['steamid']}&include_appinfo=1&include_played_free_games=1")))['response']['games']

      @games.each do |game|
        if Game.get(game['appid']) == nil
          Game.create(appid: game['appid'], title: game['name'], logo: game['img_logo_url'])
        end

        if OwnedGames.first(:game_appid => game['appid'], :user_steamid => session['steamid']) == nil
          OwnedGames.create(game_appid: game['appid'], user_steamid: session['steamid'])
        end
      end
    end

    slim :frontpage
  end

  post '/auth/steam/callback' do
    @openid = request.env["omniauth.auth"].extra.raw_info.to_hash
    session[:steamid] = @openid['steamid'].to_i


    if User.get(@openid['steamid']) == nil
      redirect '/register'
    else
      redirect '/'
    end
  end

  get '/register' do
    slim :'register/register'
  end

  post '/register' do
    User.create(steamid: params[:steamid], name: params[:username])
    redirect '/'
  end

  get '/lobby/:id' do |lobby_id|
    unless session[:steamid] == nil
      @user = User.first(steamid: session[:steamid])
      @lobby = Lobby.first(id: lobby_id)
      @lobby.update(:players => @lobby['players'] + 1)
      @game = Game.first(appid: @lobby[:game_appid])

      unless @lobby['players'] >= @lobby['slots']
        slim :'./lobby/lobby'
      else
        "Lobby full"
      end
    else
      redirect '/'
    end
  end

  get '/profile' do
    unless session[:steamid] == nil

      @games = OwnedGames.all(user_steamid: session[:steamid])
      @game_list = []
      @games.each do |game|
        @result = Game.first(appid: game['game_appid'])
        @game_info = { "appid" => @result['appid'], "title" => @result['title'], "logo" => @result['logo']}
        @game_list << @game_info
      end

      slim :'/profile/profile'
    else
      redirect '/'
    end
  end

  get '/browse/:id' do |id|
    unless session[:steamid] == nil
      @lobby_list = []
      @game = Game.first(appid: id)
      @lobbys = Lobby.all(game_appid: id)

      @lobbys.each do |lobby|
        unless lobby['players'].to_i >= lobby['slots'].to_i
          @lobby_list << @lobby_info = {"id" => lobby[:id], "name" => lobby[:name], "slots" => lobby[:slots], "players" => lobby[:players], "game_appid" => lobby[:game_appid]}
        end
      end

      slim :'/browse/lobby/lobbybrowser'
    else
      redirect '/'
    end
  end

  post '/createlobby' do
    test = Lobby.create(name: params[:name], game_appid: params[:appid].to_i, slots: params[:slots].to_i, players: 0)
    redirect "/lobby/#{test['id']}"
  end
end
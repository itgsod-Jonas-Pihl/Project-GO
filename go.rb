require "openid/store/filesystem"
require "omniauth/strategies/steam"
require 'net/http'


class GamersOnline < Sinatra::Base
  #Steam api Key
  api_key = "8DA685124F4E525EC2A97F2C932F3763"


  #The engine for open id(the steam login)
  use OmniAuth::Builder do
    provider :steam, api_key, :storage => OpenID::Store::Filesystem.new("/tmp")
  end

  #Starting the faye server (the chat)
  Faye::WebSocket.load_adapter('thin')
  use Faye::RackAdapter, :mount => '/faye', :timeout => 10




  set :raise_errors, false
  set :show_exceptions, false

  enable :sessions

  get '/' do

    unless session['steamid'] == nil

      #gets all the owned games from the use (If the profile is set to public)
      @games = JSON.parse(Net::HTTP.get(URI("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{api_key}&steamid=#{session['steamid']}&include_appinfo=1&include_played_free_games=1")))['response']['games']


      @games.each do |game|
        #looks at the database (in the game tabel). If the game isnt there it adds it with appid, name and logo_url
        if Game.get(game['appid']) == nil
          Game.create(appid: game['appid'], title: game['name'], logo: game['img_logo_url'])
        end

        #looks at the database again (in the OwnedGames tabel). If there isnt there it adds it
        if OwnedGames.first(:game_appid => game['appid'], :user_steamid => session['steamid']) == nil && game['img_logo_url'].length >= 5
          OwnedGames.create(game_appid: game['appid'], user_steamid: session['steamid'])
        end
      end
    end

    slim :frontpage
  end

  #when the steam login gets back
  post '/auth/steam/callback' do
    @openid = request.env["omniauth.auth"].extra.raw_info.to_hash
    session[:steamid] = @openid['steamid'].to_i

    #checks if the user is in the database
    user = User.get(@openid['steamid'].to_i)
    if user == nil
      redirect '/register'
    elsif user['banned'] == true
      redirect '/banned'
    else
      redirect '/'
    end
  end

  #the register page where you choose your username
  get '/register' do
    slim :'register/register'
  end

  post '/register' do
    User.create(steamid: params[:steamid], name: params[:username])
    redirect '/'
  end


  get '/lobby/:id' do |lobby_id|
    unless session[:steamid] == nil
      #user information gets fetched from the database
      @user = User.first(steamid: session[:steamid])
      #lobby information gets fetched from the database
      @lobby = Lobby.first(id: lobby_id)
      #updates the lobby to display +1 player
      #game information gets fetched from the database
      @game = Game.first(appid: @lobby[:game_appid])

      unless @lobby['players'] >= @lobby['slots']
        @lobby.update(:players => @lobby['players'] + 1)
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
      #fetches all owned games of the user from the database
      @games = OwnedGames.all(user_steamid: session[:steamid])
      @game_list = []
      @friend_list
      #puts the game information in a hash in an array
      @games.each do |game|
        result = Game.first(appid: game['game_appid'])
        game_info = { "appid" => result['appid'], "title" => result['title'], "logo" => result['logo']}
        @game_list << game_info
      end

      friends = Friend.all(user_steamid: session[:steamid])

      unless friends == nil
        friends.each do |friend|
          result = User.first(steamid: friend['friend_user_steamid'])
          user_info = {"steamid" => result['steamid'], "name" => result['name']}
          @friend_list << user_info
        end
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
        if lobby['players'] == 0
          lobby.destroy
        end

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

  get '/admin' do
    unless session[:steamid] == nil
      if User.get(session[:steamid])['admin'] == true
        @users = User.all
        slim :'admin/admin'
      else
        "403 Forbidden"
      end
    else
      redirect '/'
    end
  end

  post '/admin/ban' do
    @user = User.first(steamid: params['id'])
    @user.update(:banned => 1)
  end

  get '/banned' do
    session.destroy
    "You are banned :("
  end

  not_found do
    slim :'404', :layout => false
  end
end


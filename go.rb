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
    session['steamid'] = 76561198021297355
    unless session['steamid'] == nil
        #lets the game model handel importing new games to the database
        Game.import_games(session[:steamid])
    end

    slim :frontpage
  end

  #the data that gets back from steams openid login
  post '/auth/steam/callback' do
    openid = request.env["omniauth.auth"].extra.raw_info.to_hash
    session[:steamid] = openid['steamid']

    #checks if the user is in the database
    user = User.get(openid['steamid'].to_i)
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
    User.new_user(params[:steamid],  params[:username])
    redirect '/'
  end


  get '/lobby/:id' do |lobby_id|
    unless session[:steamid] == nil
      #user information gets fetched from the database
      @user = User.first(steamid: session[:steamid])
      #lobby information gets fetched from the database
      @lobby = Lobby.first(id: lobby_id)
      #game information gets fetched from the database
      @game = @lobby.game

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
      user = User.first(steamid: session[:steamid])
      @games = user.games
      slim :'/profile/profile'
    else
      redirect '/'
    end
  end

  get '/browse/:id' do |id|
    @lobby_list = []
    unless session[:steamid] == nil
      @game = Game.first(appid: id)
      @lobbys = Lobby.all(game_appid: id)

      unless @lobbys[0] == nil
        @lobbys.each do |lobby|
          if lobby['players'] == 0
            lobby.destroy
          end

          unless lobby['players'].to_i >= lobby['slots'].to_i
            @lobby_list << @lobby_info = {"id" => lobby[:id], "name" => lobby[:name], "slots" => lobby[:slots], "players" => lobby[:players], "game_appid" => lobby[:game_appid]}
          end
        end
      end
      slim :'/browse/lobby/lobbybrowser'
    else
      redirect '/'
    end
  end

  post '/createlobby' do
    lobby = Lobby.create(name: params[:name], game_appid: params[:appid].to_i, slots: params[:slots].to_i, players: 0)
    redirect "/lobby/#{lobby['id']}"
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

  get '/search' do
    @games = Game.all(title: params['title'])

      slim :'search/search'
  end

  get '/browse' do
    @games = Game.all
    unless session['steamid'] == nil
      user = User.first(steamid: session[:steamid])
      ownedgames = user.games
    end
    slim :'browse/browse'
  end
end


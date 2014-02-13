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
    slim :frontpage
  end

  post '/auth/steam/callback' do
    content_type "text/plain"
    @openid = request.env["omniauth.auth"].extra.raw_info.to_hash
    session[:steamid] = @openid['steamid'].to_i
    redirect '/'
  end

  get '/browse' do
    slim :'browse/browse'
  end

  get '/lobbies' do
    slim :'lobby_browse/lobbies'
  end

  get '/lobby' do
    unless session[:steamid] == nil
      uri = URI("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=#{api_key}&steamids=#{session[:steamid]}")
      @user = JSON.parse(Net::HTTP.get(uri))['response']['players'][0]['personaname']

      slim :'./lobby/lobby'
    else
      redirect '/'
    end
  end

  get '/profile' do
    unless session[:steamid] == nil
      uri = URI("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{api_key}&steamid=#{session[:steamid]}&include_appinfo=1")
      @games = JSON.parse(Net::HTTP.get(uri))['response']['games']

      slim :'/profile/profile'
    else
      redirect '/'
    end
  end

end
require "openid/store/filesystem"
require "omniauth/strategies/steam"
require 'net/http'


class GamersOnline < Sinatra::Base

 api_key = "8DA685124F4E525EC2A97F2C932F3763"

  use OmniAuth::Builder do
    provider :steam, api_key, :storage => OpenID::Store::Filesystem.new("/tmp")
  end

  enable :sessions

  Faye::WebSocket.load_adapter('thin')
  use Faye::RackAdapter, :mount => '/faye', :timeout => 45

  get '/' do
    slim :frontpage
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
      @user = JSON.parse(Net::HTTP.get(uri))
      @username = @user['response']
      @username = @username['players'][0]['personaname']
      "#{@user.class} #{@username.inspect} #{@username.class}"

      slim :'./lobby/lobby'
    else
      redirect '/'
    end
  end

  post '/auth/steam/callback' do
    content_type "text/plain"
    @openid = request.env["omniauth.auth"].extra.raw_info.to_hash
    session[:steamid] = @openid['steamid']

  end
  get '/test' do
    if session[:steamid].to_i == 76561198021297355
      "wohooo"
    else
      "buuuuh"
    end
  end
end
require "openid/store/filesystem"
require "omniauth/strategies/steam"

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
    slim :'./lobby/lobby'
  end

  post '/auth/steam/callback' do
    content_type "text/plain"
    request.env["omniauth.auth"].info.to_hash.inspect
  end

end
class GamersOnline < Sinatra::Base
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

end
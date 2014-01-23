class GamersOnline < Sinatra::Base
  Faye::WebSocket.load_adapter('thin')
  use Faye::RackAdapter, :mount => '/faye', :timeout => 45

  get '/' do
<<<<<<< HEAD
    slim :index
  end
=======
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

>>>>>>> d88c4d319b2d2a33372d417a6230890737630846
end
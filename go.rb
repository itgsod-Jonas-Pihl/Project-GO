class GamersOnline < Sinatra::Base
  Faye::WebSocket.load_adapter('thin')
  use Faye::RackAdapter, :mount => '/faye', :timeout => 45

  get '/' do
    slim :index
  end
end
class GamersOnline < Sinatra::Base

  get '/' do
    slim :index
  end

end
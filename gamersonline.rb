class Gamersonline < Sinatra::Base
  get '/' do

    slim :index
  end
end
class Lobby
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :slots, Integer
  property :players, Integer

  belongs_to :game

end
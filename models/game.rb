class Game
  include DataMapper::Resource

  property :appid, Integer, :key => true
  property :title, String


  has n, :taggings
  has n, :genres, :through => :taggings
end
class Genre
  include DataMapper::Resource

  property :id, Serial
  property :genre, String

  has n, :taggings
  has n, :games, :through => :taggings
end

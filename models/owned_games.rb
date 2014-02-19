class OwnedGames
  include DataMapper::Resource

  belongs_to :user, :key=> true
  belongs_to :game, :key=> true
end
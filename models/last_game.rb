class LastGame
  include DataMapper::Resource

  belongs_to :user, :key=> true
  belongs_to :lobby, :key=> true
end
class User
  include DataMapper::Resource

  property :steamid, String, :key => true
  property :name, String
  property :banned, Boolean, :default => false
  property :admin, Boolean, :default => true

  has n, :ownerships
  has n, :games, through: :ownerships


  def self.new_user(id,username)
    User.create(steamid: id, name: username)
  end
end
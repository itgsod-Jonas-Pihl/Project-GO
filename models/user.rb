class User
  include DataMapper::Resource

  property :steamid, Integer, :key => true
  property :name, String
  property :banned, Boolean, :default => false
  property :admin, Boolean, :default => true
end
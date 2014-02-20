class User
  include DataMapper::Resource

  property :steamid, String, :key => true
  property :name, String
  property :banned, Boolean, :default => false
  property :admin, Boolean, :default => false
end
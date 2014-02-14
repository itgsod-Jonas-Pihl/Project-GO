class User
  include DataMapper::Resource

  property :steamid, Integer, :key => true
  property :name, String
  property :banned, Boolean
  property :admin, Boolean
end
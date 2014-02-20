class User
  include DataMapper::Resource

  property :steamid, String, :key => true
  property :name, String
  property :banned, Boolean
  property :admin, Boolean
end
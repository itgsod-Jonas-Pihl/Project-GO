class Friend
  include DataMapper::Resource

  belongs_to :user, Integer, :key=> true
  belongs_to :friend, Integer, :key=> true , :trough => :user
end
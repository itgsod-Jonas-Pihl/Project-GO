puts "##################"
puts "# PRODUCTION ENV #"
puts "##################"

DataMapper::setup(:default, ENV['DATABASE_URL'])
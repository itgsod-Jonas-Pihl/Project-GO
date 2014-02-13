require 'bundler'

Bundler.require

Dir["./models/*.rb"].each {|model| require model}

configure :development do
  require_relative './development.rb'
end

configure :production do
  require_relative './production.rb'
end

require './go'
DataMapper.finalize
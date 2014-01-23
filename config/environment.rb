require 'bundler'

Bundler.require

Dir["./models/*.rb"].each {|model| require model}

configure :development do
  require_relative './development.rb'
end

require './gamersonline'
DataMapper.finalize
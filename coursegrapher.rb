require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/cg.db")

class Course
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :rating, Float
end

DataMapper.auto_upgrade!

get '/' do
  haml :index
end

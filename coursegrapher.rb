require 'sinatra'
require 'data_mapper'
require_relative 'models'

get '/' do
  @depts = Department.all.select{|dept| dept.num_reviews != 0}
  haml :index
end

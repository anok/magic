require 'rubygems'
require 'sinatra'
require 'dm-core'

require 'dm-migrations'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://my.db')

class Shop
  include DataMapper::Resource
  belongs_to :list
  property :id, Serial
  property :name, String, :key => true
  has n, :StockCards
end

class StockCard
  include DataMapper::Resource
  belongs_to :shop
  property :id, Serial
  property :name, String, :key => true
  property :quantity, Integer
  property :price, Float
end

class List
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :key => true
  has n, :ToBuyCards
  has n, :Shops
end

class ToBuyCard
  include DataMapper::Resource
  belongs_to :list
  property :id, Serial
  property :name, String, :key => true
end

DataMapper.finalize

DataMapper.auto_migrate!
get '/' do
  "MAGIC!"
end

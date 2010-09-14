require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'hpricot'
require 'rest-open-uri'


DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://my.db')

class Shop
  include DataMapper::Resource
  belongs_to :list
  property :id, Serial
  property :name, String, :key => true
  has n, :StockCards
end

class Stockcard
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
  has n, :tobuycards
  has n, :shops
end

class Tobuycard
  include DataMapper::Resource
  belongs_to :list
  property :id, Serial
  property :quantity, Integer
  property :name, String, :key => true
end

DataMapper.finalize

DataMapper.auto_upgrade!

get '/' do
  "MAGIC!"
end

get '/add/:list/:id' do
  list = List.first_or_create(:name => params[:list])
  id = params[:id]
  hdrs = {"User-Agent"=>"Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; 
en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1", 
"Accept-Charset"=>"utf-8", "Accept"=>"text/html"}
  table = Hpricot(open("http://store.tcgplayer.com/product.aspx?id=" + 
params[:id], hdrs)).search("table[@class=price_list]")
end

get '/see/:list' do

end

get '/all' do

end

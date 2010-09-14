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
  has n, :stockcards
end

class Stockcard
  include DataMapper::Resource
  belongs_to :shop
  property :id, Serial
  property :condition, String
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
  "MAGIC"
end

hdrs = {"User-Agent"=>"Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O;en-US; rv:1.8.1.1) Gecko/20061204 Firefox/2.0.0.1", "Accept-Charset"=>"utf-8", "Accept"=>"text/html"}

get '/add/:list/:quant/:id' do
  list = List.first_or_create(:name => params[:list])
  id = params[:id]
  quant = params[:quant]
  doc = Hpricot(open("http://store.tcgplayer.com/product.aspx?id=" + id.to_s, hdrs))
  nome = doc.at("span[@id=ctl00_cphMain_lblName").inner_html #nome do card
  table = doc.search("table[@class=price_list]").search("tr")
  table[1..-1].each do |x| x = x.search('td')
    shop = list.shops.first_or_create(:name => x[1].inner_html)
    card = shop.stockcards.first_or_create(:name => nome)
    card.quantity = x[3].inner_html.to_i #quantidade
    card.price = x[4].inner_html[1..-1].to_f #preço
    card.save
    shop.save
  end
  tobuycard = list.tobuycards.first_or_create(:name => nome)
  tobuycard.quantity = quant
  tobuycard.save
  list.save
  "Card #{nome} adicionado a lista #{list.name}, #{quant} unidades. para ver a lista: <a href='/see/#{list.name}'>clique aqui</a>, ou continue adicionado coisasss ;3"
end

get '/see/:list' do

  r = ''
  list = List.first_or_create(:name => params[:list])
  list.shops.each do |shop|
    soma = 0
    r += "<b>" + shop.name + "</b><br>"
    list.tobuycards.each do |card|
      tem = shop.stockcards.first(:name => card.name, :quantity.gte => card.quantity)
      if tem then
        cardtotal = card.quantity * tem.price
        r += "#{card.name.to_s} $#{tem.price.to_s} * #{card.quantity.to_s} = #{cardtotal.to_s}<br>"
        soma += cardtotal
      end
    end
    r += "total: #{soma.to_s}<br><br>"
  end
  r

end

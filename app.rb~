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
  r = '<head><title>MAGIC</title><meta content=\'text/html; charset=utf-8\' http-equiv=\'Content-Type\' /></head><body>BEM VINDO AO MARAVILHOSO MUNDO DE MAGIC! AQUI VOCE TERÁ AMIGOS!<br>'
  r += '<br>Para criar uma lista basta apontar seu navegador para -> http://magic.heroku.com/add/<b>NOME</b>/<b>N</b>/<b>ID</b><br>'
  r += 'onde NOME é o nome da lista(como ela vai aparecer aqui na primeira página, e o que você terá que digitar pra buscar ela<br>'
  r += 'N é o numero de cards que você quer<br>'
  r += 'ID é o id dela no site <a href=\'http://store.tcgplayer.com/\' target=\'_blank\'>http://store.tcgplayer.com</a><br>'
  r += 'O ID é o numero que aparece no final do link dela, depois que você procurou a carta.<br>'
  r += 'Por exemplo, a carta caos planar(<a href=\'http://store.tcgplayer.com/product.aspx?id=10257\'>http://store.tcgplayer.com/product.aspx?id=10257</a>) tem o id <b>10257</b>. Para criar uma lista d compra, onde eu quero 4 caos planares, é só ir em para http://magic.heroku.com/add/caos/4/10257<br>'
  r += 'As outras cartas que eu quero comprar junto com essa, é só ir no mesmo esquema, adicionando na mesma lista.<br>'
  r += 'Para ver a lista é só ir em /see/Nomedalista. Ainda não tem comando de remoção de cartas/listas. Sim, bem provavel que eu nunca faça nada além disso.<br>'
  r += 'Mas, o código fonte dessa jossa é opensource, você pode pegar no github. faça o que quiser com elee ;3~<br>'
  r += 'Also, não tem nenhuma proteção em nenhum lugar para as listas que você cria aqui, afinal, o que você estava esperando do LOST?<br>'
  r += 'No mais, respeitem para serem respeitados e aquela coisa chata de sempre'
  lists = List.all
  lists.each do |list|
    r += "<a href=\"/see/#{list.name}\">#{list.name}<br/>"
  end
  r
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
    card = shop.stockcards.first_or_create(:name => nome, :condition => x[2].inner_html)
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
  tobuy = list.tobuycards
  r = "<b>Cards Buscados na lista <a href='/remove/#{params[:list]}/'>[x]</a>:</b><br>"
  somacards = 0
  tobuy.each do |card|
    somacards += card.quantity
    r += card.name.to_s + ' * ' + card.quantity.to_s + "<a href=\'/updatecard/#{params[:list]}/#{card.id}/#{card.quantity+1}\'>+</a>/<a href=\'/updatecard/#{params[:list]}/#{card.id}/#{card.quantity-1}\'>-</a> | <a href=\'/removecard/#{params[:list]}/#{card.id}\'>[x]</a><br>"
  end
  r += "total: #{somacards.to_s} cartas<br><br>"
  list.shops.each do |shop|
    cartas = 0
    soma = 0
    r += "<b>" + shop.name + "</b><br>"
    list.tobuycards.each do |card|
      tem = shop.stockcards.first(:name => card.name, :quantity.gte => card.quantity)
      if tem then
        cardtotal = card.quantity * tem.price
        r += "#{card.name.to_s} $#{tem.price.to_s} * #{card.quantity.to_s} = #{cardtotal.to_s} (#{tem.condition}) <a href=\'/updatecard/#{params[:list]}/#{card.id}/#{card.quantity+1}\'>+</a>/<a href=\'/updatecard/#{params[:list]}/#{card.id}/#{card.quantity-1}\'>-</a> | <a href=\'/removecard/#{params[:list]}/#{card.id}\'>[x]</a><br>"
        soma += cardtotal
        cartas += card.quantity
      end
    end
    r += "total: #{soma.to_s} (#{cartas.to_s} cards)<br><br>"
  end
  r

end

get '/removecard/:list/:id' do
  list = List.first_or_create(:name => params[:list])
  tobuy = list.tobuycards.first(:id => params[:id])
  tobuy.destroy!
  redirect "/see/#{params[:list]}"
end

get '/updatecard/:list/:id/:n' do
  list = List.first_or_create(:name => params[:list])
  tobuy = list.tobuycards.first(:id => params[:id])
  tobuy.quantity = params[:n]
  tobuy.save
  redirect "/see/#{params[:list]}"
end

get '/remove/:list/' do
  list = List.first_or_create(:name => params[:list])
  list.destroy!
  redirect '/'
end

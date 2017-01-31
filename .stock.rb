require 'uri'
require 'net/http'
require 'json'

puts '💰'
puts '---'

{
  'CADEUR=X' => 'CAD/EUR',
  'SHOP' => 'Shopify',
  'XAUUSD=X' => 'Gold',
}.each do |symbol, name|
  params = {
    q: "select * from yahoo.finance.quotes where symbol in (\"#{symbol}\")",
    format: 'json',
    env: 'store://datatables.org/alltableswithkeys',
  }

  query = params.map { |key, value| "#{key}=#{URI.encode(value)}" }.join('&')
  path = "v1/public/yql?#{query}"
  url = "https://query.yahooapis.com/#{path}"
  response = Net::HTTP.get(URI(url))
  json = JSON.parse(response)

  quote = json['query']['results']['quote']

  currency = " (#{quote['Currency']})" if quote['Currency']
  line = "#{name}: #{quote['PreviousClose']}#{currency} #{quote['ChangeinPercent']}"
  puts "#{line} | color=purple href=#{url}"
end

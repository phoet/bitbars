require 'uri'
require 'net/http'
require 'json'
require_relative '.retry'

class Stock
  include Retry

  def symbols
    {
      'CADEUR=X' => 'CAD/EUR',
      'SHOP' => 'Shopify',
      'XAUUSD=X' => 'Gold',
    }
  end

  def fetch(symbol)
    params = {
      q: "select * from yahoo.finance.quotes where symbol in (\"#{symbol}\")",
      format: 'json',
      env: 'store://datatables.org/alltableswithkeys',
    }

    query = params.map { |key, value| "#{key}=#{URI.encode(value)}" }.join('&')
    path = "v1/public/yql?#{query}"
    url = "https://query.yahooapis.com/#{path}"
    response = Net::HTTP.get(URI(url))
    JSON.parse(response)
  end

  def results
    symbols.map do |symbol, name|
      json = with_retry { fetch(symbol) }
      [name, json['query']['results']['quote']]
    end
  end

  def print
    puts '💰'
    puts '---'

    results.each do |(name, quote)|
      currency = " (#{quote['Currency']})" if quote['Currency']
      line = "#{name}: #{quote['PreviousClose']}#{currency} #{quote['ChangeinPercent']}"
      puts "#{line} | color=purple"
    end
  end
end

stock = Stock.new
stock.print

require 'byebug'
require 'json'
require 'mechanize'
require_relative '.retry'

class Flat
  include Retry

  HOST = 'https://zvhh.de'
  RESULT_URL = "#{HOST}/?person=&typ=0&geo1=DEU&geo2=02&geo3=2000000&geo4=&path=%2FZwangsversteigerungen&_submit=1"
  LAST_ID_PATH = "#{ENV['HOME']}/Dropbox/bitbar/.last_id_versteigerungen"

  def page
    with_retry { Mechanize.new.get(RESULT_URL) }
  end

  def fetch_results
    page.search('li.contentBox').map do |item|
      title = item.search('h2').first.text.strip
      next if title =~ /gewerbe/i
      id = item.search('a[name]').first.attribute('name').value
      link = item.search('.linkBar a.button').first
      next unless link
      url = link.attributes['href'].value
      attributes = Hash[item.search('dl').first.children.map { |el| el.text.strip }.reject(&:empty?).each_slice(2).to_a]
      {
        id: id,
        title: title,
        url: "#{HOST}#{url}",
        attributes: attributes,
      }
    end
  end

  def print
    results = fetch_results.compact
    if results.empty?
      puts "⛺️"
      return
    end

    last_id = results.map { |entry| entry[:id].to_i }.max
    if File.exist? LAST_ID_PATH
      current_id = File.read(LAST_ID_PATH).to_i
      color = ' | color=purple' if last_id > current_id
    end
    File.write(LAST_ID_PATH, last_id)

    puts "#{results.size}👋#{color}"
    puts '---'

    results.each do |entry|
      puts entry[:title]
      attributes = entry[:attributes].map { |key, value| "#{key}: #{value}" }.join(', ')
      puts "#{attributes} | color=purple href=#{entry[:url]}"
    end
  end
end

flat = Flat.new
flat.print

require 'json'
require 'mechanize'
require_relative '.retry'

class Flat
  include Retry

  RESULT_URL = 'https://www.immobilienscout24.de/Suche/S-T/Wohnung-Kauf/Umkreissuche/Hamburg/20357/-2192/2621329/-/-/4/-/80,00-/EURO--600000,00/-/-/-/-/-/true/true/-/-/-/-/-2015/true?enteredFrom=result_list'
  ENTRY_URL = 'https://www.immobilienscout24.de/expose/'
  LAST_ID_PATH = "#{ENV['HOME']}/Dropbox/bitbar/.last_id"

  def page
    with_retry { Mechanize.new.get(RESULT_URL) }
  end

  def fetch_results
    match = page.search('script').find { |it| it.text.match('IS24.resultList') }
    JSON.parse(match.text.match(/model: ({.*})/)[1])['results']
  end

  def print
    results = fetch_results
    last_id = results.map { |entry| entry['id'].to_i }.max
    if File.exist? LAST_ID_PATH
      current_id = File.read(LAST_ID_PATH).to_i
      color = ' | color=purple' if last_id > current_id
    end
    File.write(LAST_ID_PATH, last_id)

    puts "#{results.size}🏡#{color}"
    puts '---'

    results.each do |entry|
      puts "#{'PRIVAT: ' if entry['privateOffer']}#{entry['title']} (#{entry['address']})"
      url = "#{ENTRY_URL}#{entry['id']}"
      attributes = entry['attributes'].map { |it| it.values.flatten.join(': ') }.join(', ')
      puts "#{attributes} | color=purple href=#{url}"
    end
  end
end

flat = Flat.new
flat.print

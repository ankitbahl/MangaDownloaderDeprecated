#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'rmagick'
require './pdf_compiler.rb'
require 'async'
require 'async/http/internet'

def get_url_fragment(search_term)
  search_term = search_term.gsub(' ', '_')
  search_url = "https://manganelo.com/search/#{search_term}"
  uri = URI.parse(search_url)
  req = Net::HTTP.new(uri.host, uri.port)
  req.use_ssl = true
  res = req.get(uri.request_uri)
  document = Nokogiri::HTML(res.body)
  options = document.css('.story_item').map do |search_item|
    {
        title: search_item.css('.story_name a')[0].content,
        url: search_item.css('a')[0].attr('href').split('/').last
    }
  end

  (0..[6, options.length - 1].min).each do |i|
    puts "#{i + 1}: #{options[i][:title]}"
  end

  puts 'Enter number for which you want to download: '
  option = STDIN.gets.gsub(/[ \n]/, '').to_i
  `echo #{options[option - 1][:title]} >> build/title.t`
  options[option - 1][:url]
end

def async_image(url, i, page)
  Async.run do
    internet = Async::HTTP::Internet.new
    # Make a new internet:

    # Issues a GET request to Google:
    response = internet.get(url)
    response.save("build/Chapter_#{i}/page_#{page}.jpg")

    # The internet is closed for business:
    internet.close
    img = Magick::Image::read("build/Chapter_#{i}/page_#{page}.jpg").first
    if img.columns > img.rows
      img.rotate! 90
      img.write("build/Chapter_#{i}/page_#{page}.jpg")
    end
  end
end

if ARGV.length < 3
  puts 'usage is "./downloader.rb search_term vol1_start,vol2_start... vol1_end, vol2_end..."'
  raise RuntimeError
end

start_chapters = ARGV[1].split(',').map(&:to_i)
end_chapters = ARGV[2].split(',').map(&:to_i)
`rm -rf build` if File.exist?('build')
Dir.mkdir('build')
Dir.mkdir('out') unless File.exist?('out')
fragment = get_url_fragment(ARGV[0])
url_base = "https://manganelo.com/chapter/#{fragment}/chapter_"
for vol in 0..start_chapters.length - 1
  start_chapter = start_chapters[vol]
  end_chapter = end_chapters[vol]
  for i in start_chapter..end_chapter
    puts "Chapter #{i}"
    uri = URI.parse("#{url_base}#{i}")
    req = Net::HTTP.new(uri.host, uri.port)
    req.use_ssl = true
    res = req.get(uri.request_uri)
    document = Nokogiri::HTML(res.body)
    Dir.mkdir "build/Chapter_#{i}"
    page = 0
    Async do
      document.css('.vung-doc').css('img').each do |img|
        url = img.attr('src')
        async_image(url, i, page)
        page += 1
      end
    end
  end
end
`echo #{ARGV[1]} >> build/start.t`
`echo #{ARGV[2]} >> build/end.t`
compile_pdfs
#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'rmagick'
require './pdf_compiler.rb'

def get_url_fragment(search_term)
  search_url = "https://manganelo.com/search/#{search_term}"
  uri = URI.parse(search_url)
  req = Net::HTTP.new(uri.host, uri.port)
  req.use_ssl = true
  res = req.get(uri.request_uri)
  document = Nokogiri::HTML(res.body)
  document.css('.story_item').each do |search_item|
    title = search_item.css('.story_name a')[0].content
    puts "Is #{title} the manga you want to download? (y/n)"
    while true
      option = STDIN.gets.gsub(/[ \n]/, '')
      case option
        when 'y'
          return search_item.css('a')[0].attr('href').split('/').last
        when 'n'
          break
        when 'q'
          raise RuntimeError
        else
          puts 'please put y or n'
      end
    end
  end
  puts 'no more search results, quitting'
  raise RuntimeError
end

if ARGV.length < 3
  puts 'usage is "./downloader.rb search_term vol1_start,vol2_start... vol1_end, vol2_end..."'
  raise RuntimeError
end

fragment = get_url_fragment(ARGV[0])
url_base = "https://manganelo.com/chapter/#{fragment}/chapter_"
start_chapters = ARGV[1].split(',').map(&:to_i)
end_chapters = ARGV[2].split(',').map(&:to_i)
`rm -rf build` if File.exist?('build')
Dir.mkdir('build')
Dir.mkdir('out') unless File.exist?('out')
for vol in 0..start_chapters.length - 1
  start_chapter = start_chapters[vol]
  end_chapter = end_chapters[vol]
  for i in start_chapter..end_chapter
    uri = URI.parse("#{url_base}#{i}")
    req = Net::HTTP.new(uri.host, uri.port)
    req.use_ssl = true
    res = req.get(uri.request_uri)
    document = Nokogiri::HTML(res.body)
    Dir.mkdir "build/Chapter_#{i}"
    page = 0
    document.css('.vung-doc').css('img').each do |img|
      url = URI.parse(img.attr('src'))
      img_res = nil
      loop do
        img_req = Net::HTTP::Get.new(url.to_s)
        img_res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
          http.request(img_req)
        end
        break if img_res.is_a?(Net::HTTPSuccess)
      end
      open("build/Chapter_#{i}/page_#{page}.jpg", "wb") do |file|
        file.write(img_res.body)
      end
      img = Magick::Image::read("build/Chapter_#{i}/page_#{page}.jpg").first
      if img.columns > img.rows
        img.rotate! 90
        img.write("build/Chapter_#{i}/page_#{page}.jpg")
      end
      puts "Done chapter #{i}, page #{page}"
      page += 1
    end
  end
end

`echo #{ARGV[1]} >> build/start.t`
`echo #{ARGV[2]} >> build/end.t`
compile_pdfs
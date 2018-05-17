#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'rmagick'
require 'fileutils'

url_base = 'http://manganelo.com/chapter/read_one_piece_manga_online_free4/chapter_'
start_chapters = [807, 817, 828, 839, 849, 859, 870, 880]
end_chapters = [816, 827, 838, 848, 858, 869, 879, 889]
Dir.mkdir('build')
Dir.mkdir('out') unless File.exist?('out')
for vol in 0..start_chapters.length - 1
  start_chapter = start_chapters[vol]
  end_chapter = end_chapters[vol]
  pagenums = {}
  for i in start_chapter..end_chapter
    uri = URI.parse("#{url_base}#{i}")
    req = Net::HTTP::Get.new(uri.to_s)
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end
    document = Nokogiri::HTML(res.body)
    Dir.mkdir "build/Chapter_#{i}"
    page = 0
    document.css('.vung-doc').css('img').each do |img|
      url = URI.parse(img.attr('src'))
      img_req = Net::HTTP::Get.new(url.to_s)
      img_res = Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|
        http.request(img_req)
      end
      open("build/Chapter_#{i}/page_#{page}.jpg", "wb") do |file|
        file.write(img_res.body)
      end
      img = Magick::Image::read("build/Chapter_#{i}/page_#{page}.jpg").first
      if img.columns > 850
        img.rotate! 90
        img.write("build/Chapter_#{i}/page_#{page}.jpg")
      end
      puts "Done chapter #{i}, page #{page}"
      page += 1
    end
    pagenums[i] = page - 1
  end
  imagelist = []
  for chap in start_chapter..end_chapter
    for num in 0..pagenums[chap]
      imagelist.push("build/Chapter_#{chap}/page_#{num}.jpg")
    end
  end
  img = Magick::ImageList.new(*imagelist)
  img.write("out/vol#{vol + 81}.pdf")
  puts "done vol #{vol + 81}"
end
FileUtils.rm_rf('build')
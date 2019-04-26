#!/usr/bin/env ruby

require 'rmagick'

def compile_pdfs
  puts 'Writing'
  title = `cat build/title.t`
  start_chapters = `cat build/start.t`.split(',').map(&:to_i)
  end_chapters = `cat build/end.t`.split(',').map(&:to_i)
  start_chapters.each_with_index do |start_chap, i|
    image_list = []
    (start_chap..end_chapters[i]).each do |chap|
      dir = "./build/Chapter_#{chap}"
      num_pages = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file)}
      for num in 0..num_pages - 1
        image_list.push("build/Chapter_#{chap}/page_#{num}.jpg")
      end
    end
    img = Magick::ImageList.new(*image_list)
    img.write("out/#{title}_chap_#{start_chap}-#{end_chapters[i]}.pdf")
    puts "Done writing chapters #{start_chap}-#{end_chapters[i]}"
  end
  `rm -rf build`
end

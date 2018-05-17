MangaDownloader is a ruby script that downloads manga (sourced from manganelo.com). It downloads all the images and creates pdfs of the compiled volumes. All that needs to be changed in order to customize which manga to download is to change the following lines:
```ruby
url_base = 'http://manganelo.com/chapter/read_one_piece_manga_online_free4/chapter_'
start_chapters = [807, 817, 828, 839, 849, 859, 870, 880]
end_chapters = [816, 827, 838, 848, 858, 869, 879, 889]
```
The url_base line must be changed to the correct url for the manga, and the start and end chapters are the chapter numbers for the start and end of each volume. You can also only specify one volume of start and end chapter and the script will compile all chapters into one large volume. To run, simply call:
```
./downloader.rb
```
This will work if you have ruby installed.

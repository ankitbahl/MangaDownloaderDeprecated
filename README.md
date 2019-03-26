MangaDownloader is a ruby script that downloads manga (sourced from manganelo.com). It downloads all the images and creates pdfs of the compiled volumes. All that needs to be changed in order to customize which manga to download 

#Dependencies
1. Have ruby >= 2.3
1. Have ImageMagick >= 6.8.9

#Running
'usage is "./downloader.rb search_term vol1_start,vol2_start... vol1_end, vol2_end..." 

where:
search term is the manga search term (e.g. "one piece")

vol_n_start/vol_n_end is the chapter number of the nth volume start/end'


e.g.

```
./downloader.rb "one piece" 1,4,6 3,5,9
```

This will search for one piece and compile it into vol_1.pdf = chap 1-3, vol_2.pdf = chap 4-5, etc.

PDF output will be found in out/ dir

Large volumes will not work on computers with low memory
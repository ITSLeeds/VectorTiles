# Making Vector Tiles: For Pleasure and Profit

## Summary
Vector Tiles are a great new way to serve geographic data via web maps.  They provide significant improvements over traditional methods of creating web maps but are a little more complicated to set up. 

This tutorial explains how to use Vector Tiles for both base maps but more importantly how to create your own vector tile layers.  It also explains how to do this using comply free software and avoiding licencing or subscription fees. 

In this tutorial we will cover going from a source geographic file format to viewing tiles on Mapbox which provides critical tools to achieve this. The documentation, we feel requires some improvement for someone to achieve this, hence this blog post.

## Introduction
Web maps (Haklay et al 2008) are a great way to present your data, they allow for interactivity, and for users to zoom into their area of interest. But they have a problem with large datasets, they become slow and unresponsive. This is because you have to download all your data before it is put onto the map. The solution was to tile the data.

### Tiling – What it is and why it matters
Tiling breaks your data into many small square datasets (tiles) than can then be downloaded individually. This means that you only have to download the tiles in the area you interested in rather than the whole dataset. This both reduces the amount of data that the web server has to send to the user and reduces the amount of data the user’s computer must hold in memory.
Tiling was first implemented for raster data with each tile being a 256 x 256 pixel PNG image. It works great for basemaps and is still used by many websites today such as https://www.openstreetmap.org/. Tiles exist in a pyramid structure, at the top of the pyramid (zoom level 0) the whole world is a single tile. Each step down the pyramid (zoom levels 1,2,3 etc) increases the number of tiles by a factor of 4.  Tile sets typically go down to about zoom level 19 at which point one tile covers an area about the size of a single building.

<img src='images/tiles.png'/>

Raster tiles have two major limitations:
1. They are static – you can’t click on an image to get extra information or dynamically change the styling of the map.
2. They are large – while each tile is small, hosting all the tiles uses up a lot of space on your server. For example, a tile set for the UK is around 15 GB.

Due to these limitations’ raster tiles are mostly used for base maps and are served by third party services. 

### Introducing Vector Tiles
Vector Tiles are a newer take on the idea of tiling, instead of many images the tiles are lots of tiny vector datasets. These vector tiles are usually smaller as not all pixeles need to be coded.

### Get started
Converting a shape file into tile:

An example file in question would be the UK MSOA boundaries which is roughly ~600M in size when converted to plani `.geojson` file.

This could be achieved in R for instance:

```R
# get LAs
folder = "/tmp/Counties_and_UA"
if(!dir.exists(folder)) {
  dir.create(folder)
}
url = "https://opendata.arcgis.com/datasets/f341dcfd94284d58aba0a84daf2199e9_0.zip"
msoa_shape = list.files(folder, pattern = "shp")[1]
if(!file.exists(file.path(folder, msoa_shape))) {
  download.file(url, destfile = file.path(folder, "data.zip"))
  unzip(file.path(folder, "data.zip"), exdir = folder)
  msoa_shape = list.files(folder, pattern = "shp")[1]
}
library(sf)
msoa = st_read(file.path(folder, msoa_shape))
st_write(msoa, "~/Downloads/msoa.geojson")
```
//TODO add an alternative way, Python? CPP?

Let us convert this to a format called `.mbtiles` which is essentially a SQLite zipped formatted the way Mapbox (hence the mb part) can read it.

We will use `tippecanoe` repo/package to achieve this.

```sh
tippecanoe -zg -o out.mbtiles --drop-densest-as-needed msoa.geojson
```

### References:
Haklay, Muki, Alex Singleton, and Chris Parker. "Web mapping 2.0: The neogeography of the GeoWeb." Geography Compass 2.6 (2008): 2011-2039.

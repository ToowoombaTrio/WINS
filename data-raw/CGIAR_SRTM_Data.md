CGIAR SRTM 250m Digital Elevation Model
================

Hole-filled Shuttle Radar Topography Mission (SRTM) data
--------------------------------------------------------

Hole-filled seamless SRTM data V4 aggregated to 250m (SRTM\_SE\_250m) available from <http://srtm.csi.cgiar.org> were downloaded from <https://drive.google.com/drive/u/0/folders/0B_J08t5spvd8VWJPbTB3anNHamc> and uncompressed externally.

After extracting the GeoTIFF file, it was imported into R.

``` r
Oz_dem <- raster::raster("~/Downloads/SRTM_SE_250m_TIF/SRTM_SE_250m.tif")
raster::plot(Oz_dem)
```

![](CGIAR_SRTM_Data_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-1.png)

The SRTM data were cropped and masked for Australia only to remove unnecessary data, using GADM data available through the [*raster*](https://CRAN.R-project.org/package=raster) package.

Due to islands, etc. the GADM data, `Oz_shape`, is cropped, then the `Oz_dem` is cropped and masked using the `Oz_shape`.

``` r
Oz_shape <- rnaturalearth::ne_countries(scale = 50,
                                        country = "Australia")

# Crop Oz_shape down to mainland only
Oz_shape <- raster::crop(Oz_shape, c(108,
                                     155,
                                     -45,
                                     -9))
```

    ## Loading required namespace: rgeos

``` r
Oz_dem <- raster::crop(Oz_dem, Oz_shape)
Oz_dem <- raster::mask(Oz_dem, Oz_shape)
raster::plot(Oz_dem)
```

![](CGIAR_SRTM_Data_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-2-1.png)

SRTM data for Australia were saved as a package file for use in interpolating temperature values.

``` r
devtools::use_data(Oz_dem, internal = TRUE)
```

    ## Saving Oz_dem as sysdata.rda to /Users/asparks/Development/WINS/R

References
----------

Jarvis A., H.I. Reuter, A. Nelson, E. Guevara, 2008, Hole-filled seamless SRTM data V4, International Centre for Tropical Agriculture (CIAT), available from <http://srtm.csi.cgiar.org>.
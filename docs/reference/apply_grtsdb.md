# apply grtsdb

Applies
[`grtsdb::extract_sample`](https://inbo.github.io/grtsdb/reference/extract_sample.html)
from inbo/GRTSdb to a custom perimeter. This function installs GRTSdb if
it is missing from your machine.

## Usage

``` r
apply_grtsdb(perimeter, cellsize = 100, n = 20, export_path = ".", seed)
```

## Arguments

- perimeter:

  a simple features (sf) object

- cellsize:

  an optional integer. The size of each cell. Either a single value or
  one value for each dimension. Passed onto extract_sample from GRTSdb.
  Default is 100.

- n:

  an optional integer. the sample size. Passed onto extract_sample from
  GRTSdb. Default is 20

- export_path:

  an optional character string pointing to the path where the
  GRTSdb.sqlite is created. Default is "."

- seed:

  a optional character. Allowing to rerun a previous use.

## Details

A function to apply grtsdb to a custom perimeter

GRTSdb is automatically installed when missing from your system.

## See also

Other spatial: [`CRS_extracter()`](CRS_extracter.md),
[`add_habitats()`](add_habitats.md),
[`calculate_polygon_centroid()`](calculate_polygon_centroid.md),
[`collect_osm_features()`](collect_osm_features.md),
[`dms_column_to_decimal()`](dms_column_to_decimal.md),
[`dms_to_decimal()`](dms_to_decimal.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# Preparation
perimeter <- sf::st_as_sf(boswachterijen$boswachterijen_2024) %>%
  dplyr::filter(Regio == "Taxandria",
                Naam == "vacant 4")

# A new sample
sample <- apply_grtsdb(perimeter,
                       cellsize = 1000,
                       n = 20,
                       export_path = ".")

leaflet::leaflet() %>%
 leaflet::addTiles() %>%
 leaflet::addCircles(data = sample$samples,
                     color = "red") %>%
 leaflet::addPolylines(data = sample$grid,
                       color = "blue") %>%
 leaflet::addPolylines(data = perimeter,
                       color = "black")
# Reuse a old sample
seed <- sample$seed

sample <- apply_grtsdb(perimeter,
                       cellsize = 1000,
                       n = 20,
                       export_path = ".",
                       seed = seed)

 leaflet::leaflet() %>%
 leaflet::addTiles() %>%
 leaflet::addCircles(data = sample$samples,
                     color = "red") %>%
 leaflet::addPolylines(data = sample$grid,
                       color = "blue") %>%
 leaflet::addPolylines(data = perimeter,
                       color = "black")
} # }
```

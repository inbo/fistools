# CRS_extracter

Extracts a coordinate reference system (CRS) from a library of commonly
used CRS codes This also fixes issues with the belge lambert 72 we use.
The EPSG code is 31370, but the proj4string is not the same as the one
in the EPSG database.

## Usage

``` r
CRS_extracter(CRS, EPSG = TRUE)
```

## Arguments

- CRS:

  A character string with the name of the CRS

- EPSG:

  A logical indicating whether the output should be in EPSG format

## Value

A CRS object

## See also

Other spatial: [`aggregate_lineparts_sf()`](aggregate_lineparts_sf.md),
[`apply_grtsdb()`](apply_grtsdb.md),
[`calculate_polygon_centroid()`](calculate_polygon_centroid.md),
[`collect_osm_features()`](collect_osm_features.md),
[`dms_column_to_decimal()`](dms_column_to_decimal.md),
[`dms_to_decimal()`](dms_to_decimal.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# Example of how to use the CRS_extracter function
crs_wgs <- CRS_extracter("WGS", EPSG = FALSE)
crs_bel <- CRS_extracter("BEL72", EPSG = FALSE)

epsg_wgs <- CRS_extracter("WGS", EPSG = TRUE)

# Example of how to use the CRS_extracter function in combination with the sf & leaflet packages
library(sf)
library(tidyverse)
library(leaflet)
boswachterijen_df <- boswachterijen$boswachterijen_2024 %>%
  st_transform(crs_bel) %>%
  mutate(centroid = st_centroid(geometry)) %>%
  st_drop_geometry() %>%
  st_as_sf(sf_column_name = "centroid",
           crs = crs_bel) %>%
  st_transform(crs_wgs)

leaflet() %>%
  addTiles() %>%
  addPolylines(data = boswachterijen$boswachterijen_2024) %>%
  addCircles(data = boswachterijen_df, color = "red", radius = 1000)
} # }
```

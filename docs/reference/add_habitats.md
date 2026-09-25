# Add habitat information to spatial features

This function calculates habitat areas and related statistics for given
spatial features

## Usage

``` r
add_habitats(sf_data, id_column)
```

## Arguments

- sf_data:

  An sf object containing the spatial features (polygons or
  multipolygons)

- id_column:

  A character string specifying the column name in sf_data that contains
  unique identifiers for each feature

## Value

A data frame with habitat areas and statistics for each feature

## Details

The function performs the following steps:

1.  Validates the input sf object and checks for the presence of the
    specified id column.

2.  Loads the CORINE Land Cover 2018 data for Belgium (CLC18_BE) from
    the fistools package.

3.  Calculates the area of each feature in square meters, hectares, and
    square kilometers.

4.  Computes the intersection between the input features and the
    CLC18_BE habitat data.

5.  Calculates the area of each habitat type within each feature.

6.  Computes additional statistics for forest habitats (bos), including
    density, average area, and perimeter.

7.  Merges the habitat information back to the original sf_data and
    calculates habitat percentages.

8.  Ensures that the total habitat area does not differ from the total
    area by more than 1%.

9.  Returns a data frame with habitat areas and statistics for each
    feature.

## See also

Other spatial: [`CRS_extracter()`](CRS_extracter.md),
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
library(sf)

# Load example spatial data (replace with actual data)
example_sf <- st_read("path_to_your_spatial_data.shp")

# Add habitat information
habitat_info <- add_habitats(example_sf, id_column = "unique_id")
} # }
```

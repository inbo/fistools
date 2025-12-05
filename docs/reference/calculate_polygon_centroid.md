# Calculate the centroid of a polygon

This function calculates the centroid of a polygon and returns the
latitude, longitude and uncertainty of the centroid.

## Usage

``` r
calculate_polygon_centroid(sf_df, id)
```

## Arguments

- sf_df:

  A sf object with polygons

- id:

  A character string with the name of the column containing the unique
  identifier

## Value

A data frame with the unique identifier, latitude, longitude and
uncertainty of the centroid

## Details

The function always returns the latitude & longitude of the polygon
centroid and the uncertainty of this centroid.

The uncertainty is calculated as the maximum distance between the
centroid and vertrexes of the polygon.

When the crs of the input is not wgs84 centroidX & centroidY are also
returned. The crs of these columns is equal to the crs of the input sf
data frame.

## See also

Other spatial: [`CRS_extracter()`](CRS_extracter.md),
[`apply_grtsdb()`](apply_grtsdb.md),
[`collect_osm_features()`](collect_osm_features.md),
[`dms_column_to_decimal()`](dms_column_to_decimal.md),
[`dms_to_decimal()`](dms_to_decimal.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# Example of how to use the calculate_polygon_centroid function
# Load the necessary data
boswachterijen <- boswachterijen$boswachterijen_2024

# add a unique identifier to the sf object
boswachterijen <- boswachterijen %>%
dplyr::mutate(UUID = as.character(row_number()))

# Calculate the centroid of the polygons
centroids_data_final <- calculate_polygon_centroid(sf_df = boswachterijen, id = "UUID")

# Plot the polygons and the centroids
library(leaflet)

# Sample 1 polygon and 1 centroid to plot using id
sample_id <- sample(centroids_data_final$UUID, 1)

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(data = boswachterijen %>% dplyr::filter(UUID == sample_id),
              weight = 1, color = "black", fillOpacity = 0.5) %>%
  addCircles(data = centroids_data_final %>% dplyr::filter(UUID == sample_id),
             lat = ~centroidLatitude, lng = ~centroidLongitude, radius = 5,
             color = "black") %>%
  addCircles(data = centroids_data_final %>% dplyr::filter(UUID == sample_id),
             lat = ~centroidLatitude, lng = ~centroidLongitude, radius = ~centroidUncertainty,
             color = "red", weight = 1)
} # }
```

# Connect separate line parts into 1 line

This function takes a sf object with separate line parts and connects
them into 1 line. The function is based on the st_union function from
the sf package. The function is designed to work with sf objects that
have a column with unique identifiers for the separate line parts. The
function will connect the line parts based on the unique identifier.

## Usage

``` r
aggregate_lineparts_sf(sf_data, sf_id)
```

## Arguments

- sf_data:

  A sf object with separate line parts

- sf_id:

  A character string with the name of the column with unique identifiers

## Value

A sf object with connected line parts

## See also

Other spatial: [`CRS_extracter()`](CRS_extracter.md),
[`apply_grtsdb()`](apply_grtsdb.md),
[`calculate_polygon_centroid()`](calculate_polygon_centroid.md),
[`collect_osm_features()`](collect_osm_features.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# create a sf object containing 2 seperate linstrings with wgs84 coordinates that lay within belgium
# add a column with the same id for both linestrings & a unique label for each line
sf_data <- sf::st_sfc(sf::st_linestring(matrix(c(5.5, 5.0, 50.0, 50.6), ncol = 2)),
                     sf::st_linestring(matrix(c(4.7, 4.8, 50.8, 50.8), ncol = 2))) %>%
 sf::st_sf(id = c("a", "a")) %>%
 dplyr::mutate(label = as.factor(dplyr::row_number()))

# plot sf_data using leaflet
# create a palette for label
pal <- leaflet::colorFactor(palette = "RdBu", levels = sf_data$label)

plot <- leaflet::leaflet() %>%
  leaflet::addTiles() %>%
  leaflet::addPolylines(data = sf_data, color = ~pal(label), weight = 5, opacity = 1)

# connect the line parts
sf_data_connected <- aggregate_lineparts_sf(sf_data, "id")

# add sf_data_connected to plot
plot <- plot %>%
  leaflet::addPolylines(data = sf_data_connected, color = "black", weight = 2, opacity = 0.5)

plot
} # }
```

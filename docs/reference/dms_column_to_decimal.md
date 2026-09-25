# dms column_to_decimal

Convert a data frame column with degrees, minutes as well as seconds to
decimal degrees.

## Usage

``` r
dms_column_to_decimal(df, coord_col)
```

## Arguments

- df:

  Data frame containing the DMS columns.

- coord_col:

  Name of the column with coordinates in degrees.

## Value

Data frame with a new column containing decimal degrees.

## See also

Other spatial: [`CRS_extracter()`](CRS_extracter.md),
[`add_habitats()`](add_habitats.md),
[`apply_grtsdb()`](apply_grtsdb.md),
[`calculate_polygon_centroid()`](calculate_polygon_centroid.md),
[`collect_osm_features()`](collect_osm_features.md),
[`dms_to_decimal()`](dms_to_decimal.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# Example data frame
df <- data.frame(
 lat_Y = c("50\u00B045'38.7\"N", "50\u00B046'04.9\"N", "50\u00B045'19.7\"N",
 "50\u00B045'18.0\"N", "50\u00B046'24.4\"N", "50\u00B045'29.2\"N"),
 long_X = c("3\u00B010'26.0\"E", "3\u00B010'28.0\"E", "3\u00B010'25.0\"E",
 "3\u00B010'24.0\"E", "3\u00B010'30.0\"E", "3\u00B010'27.0\"E"))

# Convert the lat_Y and long_X columns to decimal degrees
df <- dms_column_to_decimal(df, c("lat_Y", "long_X"))
# View the updated data frame
print(df)
} # }
```

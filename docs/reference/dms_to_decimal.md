# dms_to_decimal

Convert degrees, minutes, and seconds to decimal degrees.

## Usage

``` r
dms_to_decimal(deg, min, sec, direction = NULL)
```

## Arguments

- deg:

  Degrees (numeric or character).

- min:

  Minutes (numeric or character).

- sec:

  Seconds (numeric or character).

- direction:

  Direction (character, optional, e.g., 'N', 'S', 'E', 'W').

## Value

Decimal degrees (numeric).

## See also

Other spatial: [`CRS_extracter()`](CRS_extracter.md),
[`add_habitats()`](add_habitats.md),
[`apply_grtsdb()`](apply_grtsdb.md),
[`calculate_polygon_centroid()`](calculate_polygon_centroid.md),
[`collect_osm_features()`](collect_osm_features.md),
[`dms_column_to_decimal()`](dms_column_to_decimal.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# Convert 30\u00B0 15'50"N or 30 degrees, 15 minutes, and 50 seconds north to decimal degrees
dms_to_decimal(30, 15, 50, 'N')
# Returns 30.26389
} # }
```

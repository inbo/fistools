# Columnname comparison

A simple function to list the difference in column names in 2 datasets.

## Usage

``` r
colcompare(x, y)
```

## Arguments

- x:

  dataframe 1

- y:

  dataframe 2

## Value

a list of columns present in x but not in y and a list of columns
present in y and not in x.

## See also

Other dataframe_comparison:
[`col_content_compare()`](col_content_compare.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# create example dataframes
super_sleepers <- data.frame(rating=1:4,
animal=c('koala', 'hedgehog', 'sloth', 'panda'),
country=c('Australia', 'Italy', 'Peru', 'China'),
avg_sleep_hours=c(21, 18, 17, 10))

super_actives <- data.frame(rating=1:4,
animal=c('kangeroo', 'wolf', 'jaguar', 'tiger'),
country=c('Australia', 'Italy', 'Peru', 'China'),
avg_active_hours=c(16, 15, 8, 10))

colcompare(super_sleepers, super_actives)
} # }
```

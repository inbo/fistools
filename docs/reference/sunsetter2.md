# sunsetter2

Calculate the sunrise and sunset times for a given set of date and
location combinations

## Usage

``` r
sunsetter2(df, dates, lat, lng)
```

## Arguments

- df:

  A dataframe containing the dates, latitudes and longitudes

- dates:

  A vector of dates contained in the dataframe

- lat:

  A vector of latitudes contained in the dataframe

- lng:

  A vector of longitudes contained in the dataframe

## Value

dataframe containing the dates, latitudes, longitudes, sunrise time and
sunset time.

## Details

This function uses the sunrise-sunset API to calculate the sunrise and
sunset times for a given set of date and location combinations.

## See also

Other temporal: [`sunsetter()`](sunsetter.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# create a dataframe with dates, latitudes and longitudes
df <- data.frame(dates = c("2021-01-01", "2021-01-01", "2020-12-25"),
                 location = c("Brussels", "Amsterdam", "Brussels"),
                 lat = c(50.866572, 52.367573, 50.866572),
                 lng = c(4.350309, 4.904138, 4.350309),
                 remarks = c("New Year's Day", "New Year's Day", "Christmas Day"))

# calculate the sunrise and sunset times for the dataframe
sunsets <- sunsetter2(df)

# add the sunrise and sunset times to the dataframe
df <- dplyr::bind_cols(df, sunsets %>% dplyr::select(-dates))
df
} # }
```

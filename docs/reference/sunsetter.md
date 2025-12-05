# sunsetter Calculate the sunrise and sunset times for a given range of dates and location

sunsetter Calculate the sunrise and sunset times for a given range of
dates and location

## Usage

``` r
sunsetter(
  StartDate = Sys.Date(),
  EndDate = Sys.Date(),
  lat = 50.866572,
  lng = 4.350309
)
```

## Arguments

- StartDate:

  Date in %y-%m-%d format indicating startdate of dataframe. Defaults to
  today

- EndDate:

  Date in %y-%m-%d format indicating enddate of dataframe. Defaults to
  today

- lat:

  Numeric indicating the latitude. Defaults to Herman Teirlinck building
  in Brussels

- lng:

  Numeric indicating the longitude. Defaults to Herman Teirlinck
  building in Brussels

## Value

dataframe containing the dates between the startdate and enddate, the
corresponding sunrise time and sunset time.

## Details

This function uses the sunrise-sunset API to calculate the sunrise and
sunset times for a given range of dates and fixed location. The default
location is the Herman Teirlinck building in Brussels.

if StartDate and EndDate are not specified, the function will return the
sunrise and sunset times for today.

## See also

Other temporal: [`sunsetter2()`](sunsetter2.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# sunrise and sunset times for the first 10 days of 2021 in Brussels
sunsetter(StartDate = "2021-01-01", EndDate = "2021-01-10", lat = 50.866572, lng = 4.350309)

# sunrise and sunset times for today in Brussels
sunsetter()
} # }
```

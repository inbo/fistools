# get_age_sex_ratio

Calculate Demographic Ratios Across Flexible Aggregation Levels Wrapper
around `camtraptor` functions to calculate age/sex demographic counts,
group-level RAIs, and ratios grouped by deployment, location, metadata
variables, or across the entire dataset.

## Usage

``` r
get_age_sex_ratio(
  package,
  species = "all",
  num_life_stage = "juvenile",
  num_sex = NULL,
  den_life_stage = "adult",
  den_sex = "female",
  by = "deploymentID",
  ...
)
```

## Arguments

- package:

  Camera trap data package object (as returned by `read_camtrap_dp()`).

- species:

  Scientific or vernacular species name(s) to filter on. Defaults to
  `"all"`.

- num_life_stage:

  Vector of life stage(s) for the numerator group. `NULL` applies no
  filter.

- num_sex:

  Vector of sex class(es) for the numerator group. `NULL` applies no
  filter.

- den_life_stage:

  Vector of life stage(s) for the denominator group. `NULL` applies no
  filter.

- den_sex:

  Vector of sex class(es) for the denominator group. `NULL` applies no
  filter.

- by:

  Character vector of column name(s) in `package$data$deployments` to
  group by (e.g., `"deploymentID"`, `"locationName"`). Use `"all"` or
  `NULL` for whole dataset totals. Defaults to `"deploymentID"`.

- ...:

  Additional arguments passed to `camtraptor` functions.

## Value

A tibble with numerator/denominator counts (`n_*`), group effort (days),
group relative abundance indices (`rai_*`), and demographic ratios
(`ratio_obs`, `ratio_ind`)

## Author

Martijn Bollen

## Examples

``` r
if (FALSE) { # \dontrun{
# Data paths
zipfile <- "../fis-grofwild/Projecten/Drongengoed/Input/Agouti/drongengoed.zip"
exdir <- "../fis-grofwild/Projecten/Drongengoed/Input/Agouti/filesDRG"

# Download and unzip files
download_gdrive_if_missing("1F7mCj-Wm0Ggq1evz1HusxZBgX-1ttx-S", destfile = zipfile)
unzip(zipfile, exdir = exdir)

# Import as Camtrap DP
drg <- camtraptor::read_camtrap_dp(file.path(exdir, "datapackage.json"))

drg$data$deployments <- drg$data$deployments %>%
mutate(year = year(start), month = month(start),
       year_month = floor_date(start, unit = "month")) %>%
filter(month %in% 4:8, year %in% 2023:2025)

# Fawn to Doe ratio per location
location_fawn_doe_ratios <- get_age_sex_ratio(
 package = drg,
 species = "Capreolus capreolus",
 num_life_stage = "juvenile",
 den_life_stage = c("adult", "subadult"), den_sex = "female",
 by = "locationName"
)

# Fawn to Doe ratio per year
yearly_fawn_doe_ratios <- get_age_sex_ratio(
 package = drg,
 species = c("Capreolus capreolus", "Dama dama"),
 num_life_stage = "juvenile",
 den_life_stage = "adult", den_sex = "female",
 by = "year" # or by = NULL
)

# Fawn to doe ratio - overall
overall_fawn_doe_ratio <- get_age_sex_ratio(
 package = drg,
 species = c("Capreolus capreolus", "Dama dama"),
 num_life_stage = "juvenile",
 den_life_stage = "adult", den_sex = "female",
 by = "all"
)
} # }
```

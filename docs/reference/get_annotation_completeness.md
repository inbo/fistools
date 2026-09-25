# get_annotation_completeness

Screen Data Package for Demographic Annotation Coverage. Identifies time
periods and deployment windows where demographic attributes
(`lifeStage`, `sex`, or custom fields) are actively annotated (non-NA).

## Usage

``` r
get_annotation_completeness(
  package,
  fields = c("lifeStage", "sex"),
  mode = c("any", "all"),
  species = "all",
  by = "deploymentID"
)
```

## Arguments

- package:

  Camera trap data package object (as returned by `read_camtrap_dp()`).

- fields:

  Character vector of column names in `package$data$observations` to
  evaluate. Defaults to `c("lifeStage", "sex")`.

- mode:

  Character string (`"any"` or `"all"`). `"any"` flags observations
  where at least one field is annotated; `"all"` requires all specified
  fields to be non-NA. Defaults to `"any"`.

- species:

  Scientific or vernacular species name(s) to filter on. Defaults to
  `"all"`.

- by:

  Character vector of column name(s) in `package$data$deployments` to
  group by (e.g., `"deploymentID"`, `"locationName"`). Use `"all"` or
  `NULL` to screen the entire dataset. Defaults to `"deploymentID"`.

## Value

A tibble detailing observation counts, percentage annotated, first and
last annotated timestamps, and total annotated duration (in days) per
group.

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

# Check deployments where EITHER lifeStage OR sex is annotated
drg$data$deployments <- drg$data$deployments %>%
mutate(year = year(start), month = month(start),
       year_month = floor_date(start, unit = "month"))

coverage_dep <- get_annotation_completeness(
package = drg,
fields = c("lifeStage", "sex"),
mode = "any",
species = "Capreolus capreolus",
by = "year_month"
)
} # }
```

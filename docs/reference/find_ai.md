# Find used AI models in a datapackage

Find used AI models in a datapackage

## Usage

``` r
find_ai(datapack, species = species)
```

## Arguments

- datapack:

  a camtrapdb datapackage containing the column classificationMethod

- species:

  a vector of species passed down from `agouti_validate_ai`.

## Value

a vector of ai models used

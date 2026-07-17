# Read "dieren met onderkaakgegevens georef"

This function reads the most up to date version of the dieren met
onderkaakgegevens georef (DMOGG) file from the backoffice wild analyse.

## Usage

``` r
read_dmogg(type = "short", email = Sys.getenv("email"))
```

## Arguments

- type:

  "short" or "long" indicating which version you want to import. The
  default is "short". See details for more info.

- email:

  email used to authenticate the google drive

## Value

a dataframe containing the most recent DMOGG data.

## Details

This function can import two versions of the DMOGG dataset:

- The *"Short"* version: Contains data collected via the e-loket and,
  later, the ANB's WIZ-app, enriched with data from the autopsiedb. Its
  temporal range spans from 2014 to the present. This dataset is more
  comprehensive and includes spatial data for WBEs and FBZs. It also
  contains data on causes of death other than culling (mainly "valwild")
  and exotic species (such as raccoon, muntjac, and sika deer).

- The *"Long"* version: Combines older data collected by INBO via
  e-loket predecessors (e.g., zwijntje) with the subset of the "Short"
  version that specifically concerns culling
  (`doodsoorzaak == "afschot"`) and a select group of species (e.g., roe
  deer, wild boar, red deer, and fallow deer). This dataset is less
  comprehensive because the early data (pre-2014) lacks almost all
  spatial information.

This function uses
[`fistools::download_gdrive_if_missing()`](download_gdrive_if_missing.md)
under the hood to download the file from the google drive.

## See also

Other download: [`download_dep_media()`](download_dep_media.md),
[`download_gdrive_if_missing()`](download_gdrive_if_missing.md),
[`download_seq_media()`](download_seq_media.md),
[`get_last_modified_zip()`](get_last_modified_zip.md),
[`unzip_last_modified_zip()`](unzip_last_modified_zip.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# read the most recent short DMOGG data
dmogg <- read_dmogg()
} # }
```

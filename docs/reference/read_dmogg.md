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

Two versions of the DMOGG dataset can be imported by this function,
namely:

- The "Short" version containing only data collected via the e-loket and
  later WIZ-app from ANB enriched with data from the autopsiedb. The
  temporal range of this dataset is 2014 - today. This dataset is more
  complete and contains spatial data concerning wbe's & fbz's.

- The "Long" version containing the data from the "Short" dataset plus
  data collected via the predecessors of the e-loket (ao zwijntje) by
  INBO. This dataset is less complete because early data (\<2014) misses
  almost all spatial info.

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

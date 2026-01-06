# Unzip last modified zip

A function to download and unzip the last modified zip file from a
specified Google Drive folder.

## Usage

``` r
unzip_last_modified_zip(folder_id, exdir = tempdir())
```

## Arguments

- folder_id:

  The ID of the googledrive folder to check for the last modified zip
  file.

- exdir:

  The directory where the zip file should be extracted. Defaults to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

## Value

The path to the datapackage.json of the last modified zip file in the
specified folder.

## See also

Other download: [`download_dep_media()`](download_dep_media.md),
[`download_gdrive_if_missing()`](download_gdrive_if_missing.md),
[`download_seq_media()`](download_seq_media.md),
[`get_last_modified_zip()`](get_last_modified_zip.md)

## Examples

``` r
if (FALSE) { # \dontrun{
datapackage <- unzip_last_modified_zip(folder_id = "17p2MZt9LIuhIU72u_JjDBbO7D1IPTv7-") |>
camtraptor::read_camtrap_dp()
} # }
```

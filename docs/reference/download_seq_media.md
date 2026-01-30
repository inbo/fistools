# Download sequence media

This function allows the user to download all media related to a
Agouti - sequence which matches the given parameters.

## Usage

``` r
download_seq_media(dataset, seqID, favorite = FALSE, outputfolder = NULL)
```

## Arguments

- dataset:

  character string, path to the folder where a camptraptor datapackage
  has been unzipped.

- seqID:

  character string, ID of the sequence to download media from

- favorite:

  boolean, do you only want the pretty pictures?

- outputfolder:

  character string, path where the function should download the media
  into

## Value

Downloads the specified media files into the outputfolder

## Details

If you are getting an Authorization Error (#403), this probably means
your Agouti project has Restrict Images on. This needs to be turned off.

## See also

Other download: [`download_dep_media()`](download_dep_media.md),
[`download_gdrive_if_missing()`](download_gdrive_if_missing.md),
[`get_last_modified_zip()`](get_last_modified_zip.md),
[`unzip_last_modified_zip()`](unzip_last_modified_zip.md)

## Author

Lynn Pallemaerts

Emma Cartuyvels

Sander Devisscher

Soria Delva

## Examples

``` r
if (FALSE) { # \dontrun{
drg <- fistools::drg_example

# Situation 1: download whole sequence
download_seq_media(dataset = drg,
                    seqID = "f4c049d2-d42f-4cd3-a951-fd485ed0279a")

# Situation 2: download only favorited species media within sequence
download_seq_media(dataset = drg,
                    seqID = "f4c049d2-d42f-4cd3-a951-fd485ed0279a",
                    favorite = TRUE)
} # }
```

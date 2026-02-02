# Download deployment media

This function allows the user to download all media related to a
Agouti - dataset which matches the given parameters.

## Usage

``` r
download_dep_media(
  dataset,
  depID,
  species = NULL,
  favorite = FALSE,
  outputfolder = NULL
)
```

## Arguments

- dataset:

  character string, path to the folder where a camptraptor datapackage
  has been unzipped.

- depID:

  character string, ID of the deployment to download media from.

- species:

  character string, latin name of the species to download

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
If depID = "all" and favorite = TRUE, the function will download all
favorited pictures in the whole dataset.

## See also

Other download:
[`download_gdrive_if_missing()`](download_gdrive_if_missing.md),
[`download_seq_media()`](download_seq_media.md),
[`get_last_modified_zip()`](get_last_modified_zip.md),
[`unzip_last_modified_zip()`](unzip_last_modified_zip.md)

Other agouti: [`agouti_imager()`](agouti_imager.md),
[`download_seq_media()`](download_seq_media.md),
[`drg_example`](drg_example.md),
[`rename_ct_files()`](rename_ct_files.md)

## Author

Lynn Pallemaerts

Emma Cartuyvels

Sander Devisscher

Soria Delva

## Examples

``` r
if (FALSE) { # \dontrun{
drg <- fistools::drg_example

# Situation 1: download whole deployment
download_dep_media(dataset = drg,
                    depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f")

# Situation 2: download only wanted species
download_dep_media(dataset = drg,
                    depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f",
                    species = "Dama dama")

# Situation 3: download only favorited species media
download_dep_media(dataset = drg,
                    depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f",
                    species = "Dama dama",
                    favorite = TRUE)

# Situation 4: download only favorited species media
download_dep_media(dataset = drg,
                    depID = "all",
                    favorite = TRUE)
} # }
```

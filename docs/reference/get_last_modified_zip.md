# get last modified zip

A helper function to retrieve the id of last modified zip file from a
specified Google Drive folder.

## Usage

``` r
get_last_modified_zip(folder_id)
```

## Arguments

- folder_id:

  The ID of the googledrive folder to check for the last modified zip
  file.

## Value

The name of the last modified zip file in the specified folder.

## See also

Other download: [`download_dep_media()`](download_dep_media.md),
[`download_gdrive_if_missing()`](download_gdrive_if_missing.md),
[`download_seq_media()`](download_seq_media.md),
[`unzip_last_modified_zip()`](unzip_last_modified_zip.md)

## Author

Sander Devisscher, Martijn Bollen

## Examples

``` r
 if (FALSE) { # \dontrun{
 get_last_modified_zip(folder_id = "17p2MZt9LIuhIU72u_JjDBbO7D1IPTv7-")
} # }
```

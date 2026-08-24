# Download files from a Google Drive folder to a local directory

This function allows the user to download all files from a specified
Google Drive folder to a local directory. The user can filter the files
by type and specify the output folder.

## Usage

``` r
drive_to_folder(
  drive_folder = NULL,
  output_folder = NULL,
  filetypes = "all",
  email = Sys.getenv("email")
)
```

## Arguments

- drive_folder:

  character string, URL or ID of the Google Drive folder to download
  from.

- output_folder:

  character string, path to the local directory where the files will be
  downloaded. If NULL, the current working directory will be used.

- filetypes:

  character vector, types of files to download. Default is "all", which
  means all files will be downloaded. You can specify file types by
  using regular expressions, for example c("csv", "txt") to download
  only csv and txt files.

- email:

  character string, the email address to use for authentication with
  Google Drive. Default is the value of the "email" environment
  variable.

## Value

The specified files are downloaded from the Google Drive folder to the
local directory.

## Details

You can find the ID of a Google Drive folder by right-clicking on the
folder, selecting "Get link", and copying the part of the URL that comes
after "folders/". For example, if the URL is
"https://drive.google.com/drive/folders/1a2b3c4d5e6f7g8h9i0j", then the
ID of the folder is "1a2b3c4d5e6f7g8h9i0j".

If you specify file types using regular expressions, make sure to
include the appropriate syntax. For example, to download only csv files,
you can use "csv" or "\\csv\$". To download multiple file types, you can
use c("csv", "txt") or c("\\csv\$", "\\txt\$").

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
#' # download all files from a Google Drive folder to the current working directory

drive_to_folder(drive_folder = "1a2b3c4d5e6f7g8h9i0j")

# download only wav files from a Google Drive folder to a specified output folder
drive_to_folder(drive_folder = "1a2b3c4d5e6f7g8h9i0j",
                output_folder = "path/to/output/folder",
                filetypes = "wav")
} # }
```

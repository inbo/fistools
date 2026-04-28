# Upload a folder to Google Drive

This function allows you to upload a folder to Google Drive. You can
choose to zip the folder before uploading, and to clean up the local
files after uploading.

## Usage

``` r
folder_to_drive(
  input_folder = NULL,
  drive_folder = NULL,
  zipfiles = FALSE,
  cleanup = FALSE,
  filetype = "all",
  recursive = FALSE,
  email = Sys.getenv("email")
)
```

## Arguments

- input_folder:

  character string, path to the folder you want to upload

- drive_folder:

  character string, id to the folder in Google Drive where you want to
  upload the files.

- zipfiles:

  boolean, whether to zip the files before uploading. Default is FALSE.

- cleanup:

  boolean, whether to delete the local files after uploading. Default is
  FALSE.

- filetype:

  character string, the type of files to upload. Default is "all". You
  can specify a filetype by using a regular expression, for example
  "csv" to upload only csv files.

- recursive:

  boolean, whether to include files in subfolders of the input folder.
  Default is FALSE.

- email:

  character string, the email address to use for authentication with
  Google Drive. Default is the value of the "email" environment
  variable.

## Value

The specified files are uploaded to Google Drive, and optionally the
local files are deleted.

## Details

You can find the id of a folder in Google Drive by right-clicking on the
folder, selecting "Get link", and copying the part of the URL that comes
after "folders/". For example, if the URL is
"https://drive.google.com/drive/folders/1a2b3c4d5e6f7g8h9i0j", then the
id of the folder is "1a2b3c4d5e6f7g8h9i0j". If you choose to zip the
folder, only the zip file will be uploaded to Google Drive. If you
choose to clean up the local files, all files in the input folder will
be deleted after uploading.

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
# upload a folder to Google Drive without zipping and without cleaning up local files
folder_to_drive(input_folder = "path/to/your/folder",
                drive_folder = "1a2b3c4d5e6f7g8h9i0j",
                zipfiles = FALSE,
                cleanup = FALSE,
                filetype = "all",
                recursive = FALSE,
                email = Sys.getenv("email"))

# upload a folder to Google Drive with zipping and cleaning up local files, only for csv files
folder_to_drive(input_folder = "path/to/your/folder",
               drive_folder = "1a2b3c4d5e6f7g8h9i0j",
               zipfiles = TRUE,
               cleanup = TRUE,
               filetype = "csv",
               recursive = TRUE,
               email = Sys.getenv("email"))
} # }
```

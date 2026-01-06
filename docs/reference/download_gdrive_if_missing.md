# Download gdrive if missing

This function downloads the specified file from google drive if the
destination file does not exist. If it does exist the user will be
prompted to download it again.

## Usage

``` r
download_gdrive_if_missing(gfileID, destfile, update_always = FALSE, email)
```

## Arguments

- gfileID:

  character google file token

- destfile:

  character destination filename with extention

- update_always:

  optional boolean to trigger a download everytime the function is run.
  default is FALSE.

- email:

  optional character specifying the users email used to access the
  googledrive file.

## Value

If the destination file was missing it is downloaded from the
googledrive.

## Details

Its best practice to provide the email in encrypted form. This can be
easily achieved by adding email as an item in a .renviron file or even
beter by using more robust encryption methods.

When a *PERMISSION_DENIED* error occurs, it is likely that the file is
not shared with the email address provided. This can be fixed by sharing
the file with the email address. If the file was shared correctly this
might indicate that email address does not have the correct permissions
to access the file. This can be fixed by running
[`googledrive::drive_deauth()`](https://googledrive.tidyverse.org/reference/drive_deauth.html)
followed by
[`googledrive::drive_auth()`](https://googledrive.tidyverse.org/reference/drive_auth.html)
and making sure the 'show, modify and delete all drive files' option is
selected. Additionally running
`options(gargle_oauth_cache = ".secrets")` prior to running the function
can fix this issue. If the error yet persists please create a [new
issue](https://github.com/inbo/fistools/issues/new/choose) on the github
page.

## See also

Other download: [`download_dep_media()`](download_dep_media.md),
[`download_seq_media()`](download_seq_media.md),
[`get_last_modified_zip()`](get_last_modified_zip.md),
[`unzip_last_modified_zip()`](unzip_last_modified_zip.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# download newest version of the team charter
download_gdrive_if_missing(gfileID = "1gtqcZojPnbLhEgpul3r9sy2zK3UyyCVG",
                           destfile = "../../Teamcharters/Teamcharter_FIS.pdf",
                           email = Sys.getenv("email"),
                           update_always = TRUE)
} # }
if (FALSE) { # \dontrun{
# download newest DRG Agouti export
download_gdrive_if_missing(gfileID = "1FX8DDyREKMH1M3iW9ijWjVjO_tBH8PXi",
                           destfile = "../fis-projecten/Grofwild/Drongengoed/Input/Agouti/drongengoed_240502.zip",
                           email = Sys.getenv("email"),
                           update_always = TRUE)
} # }
```

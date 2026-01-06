# Rename camera trap files for upload in Agouti

Function that rename camera trap files (i.e. photos) by appending folder
name (e.g. 1000RECX) to file name (e.g. IMG0001) to create all unique
file names across a deployment. Needed for deployments with more than
9999 pictures, so they can be uploaded in Agouti. This is a copy of the
old `rename_file_names()` in the old `fis-projecten` (archived).

## Usage

``` r
rename_ct_files(
  foldername,
  extensions = c("jpg", "png", "jpeg", "bmp"),
  compile = FALSE
)
```

## Arguments

- foldername:

  DCIM folder to be treated

- extensions:

  file extensions to be rename. Default is jpg, jpeg, bmp and png

- compile:

  logical. If TRUE, all files will be compiled in a single folder

## Value

renamed picture files in the original folder

## Details

This function will rename all files in the subfolders of the folder
specified by foldername. If no foldername is provided, the user will be
prompted to select a folder. The function will rename all files with the
extensions specified in the extensions argument. The function will also
compile all files in a single folder if compile is set to TRUE.

## Author

: Lynn Pallemaerts and Someone Before Her

## Examples

``` r
if (FALSE) { # \dontrun{
tempzip <- tempfile(fileext = ".zip")
fistools::download_gdrive_if_missing(gfileID = "1-84hbKouLKGwnLgBSRaQO1BnfogoFZWz",
                                     destfile = tempzip,
                                     email = Sys.getenv("email"),
                                     update_always = TRUE)

foldername <- paste0(tempdir(), "/test_case_renaming")
unzip(tempzip,
      exdir = tempdir())
rename_ct_files(foldername)
browseURL(foldername)
unlink(foldername,
       recursive = TRUE)

# The function also works when no foldername is provided
rename_ct_files()

# The function can also compile all files in a single folder
rename_ct_files(foldername, compile = TRUE)
browseURL(foldername)
unlink(foldername,
       recursive = TRUE)
} # }
```

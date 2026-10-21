# Validate AI classifications in Agouti

This function allows you to validate AI classifications in Agouti by
downloading a datapackage from Google Drive, filtering observations
based on the specified AI model and species, and opening the relevant
sequence IDs in Agouti for manual validation.

## Usage

``` r
validate_agouti_ai(
  gfileID,
  ai_model = "Europe",
  agouti_prj_id,
  species = NULL,
  email
)
```

## Arguments

- gfileID:

  The Google Drive file ID of the datapackage to be downloaded.

- ai_model:

  The name of the AI model used for classification (e.g., "Europe").
  Default is "Europe".

- agouti_prj_id:

  The Agouti project ID where the sequences will be opened for
  validation.

- species:

  Optional. A vector of species (scientific names) to filter the
  observations for validation. If NULL, the user will be prompted to
  select species from the available options.

- email:

  Optional. The email address used for authentication when downloading
  the datapackage from Google Drive. If not provided, the function will
  attempt to retrieve it from system environment variables or prompt the
  user for input.

## Value

None. The function opens URLs in the default web browser for validation.

## Details

The function performs the following steps:

1.  Checks for the required parameters and prompts the user if
    necessary.

2.  Downloads the specified datapackage from Google Drive using the
    provided file ID.

3.  Unzips the downloaded datapackage and reads it using the
    `camtraptor` package.

4.  Filters the observations based on the specified AI model and
    species.

5.  Extracts the unique sequence IDs from the filtered observations and
    opens them in Agouti for manual validation using the `agouti_imager`
    function.

6.  The user can validate the classifications in Agouti *NOTE:* This
    function doesn't track which sequences have been validated!

## See also

Other agouti: [`agouti_imager()`](agouti_imager.md),
[`download_dep_media()`](download_dep_media.md),
[`download_seq_media()`](download_seq_media.md),
[`drg_example`](drg_example.md),
[`rename_ct_files()`](rename_ct_files.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
validate_agouti_ai(gfileID = "your_google_drive_file_id",
                   ai_model = "Europe",
                   agouti_prj_id = "your_agouti_project_id",
                   species = c("Lynx lynx", "Canis lupus"))
} # }

```

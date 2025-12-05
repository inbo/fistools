# Normalize line endings according to `.gitattributes`

This function adjusts the line endings (LF or CRLF) and enforces file
attribute handling of all files in the current directory and
subdirectories, according to the settings specified in the
`.gitattributes` file. This creates consistency between the files on the
online repository and those in the local environment.

## Usage

``` r
normalize_line_endings()
```

## Value

Files in the directory will be altered where relevant. Users get the
option to commit these changes.

## Details

The function

- Checks whether a `.gitattributes` file is available.

- Normalizes all files using Git.

- Checks if files were altered and asks users if these changes can be
  committed.

- Provides status updates, so users can follow the progress of the
  function.

## Author

Soria Delva

## Examples

``` r
if (FALSE) { # \dontrun{
# Run normalization and (optionally) commit changes
normalize_line_endings()
} # }
```

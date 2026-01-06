# Export sessionInfo as data.frames for easy sharing & comparison

A function to export sessionInfo as data.frames to allow easy sharing
and comparison between users.

## Usage

``` r
session_info_df(x = utils::sessionInfo())
```

## Arguments

- x:

  A [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html)-like
  list. Default is the current session info.

## Value

A list with three data.frames: `r_info`, `rstudio`, and `packages`.

## See also

[`sessionInfo`](https://rdrr.io/r/utils/sessionInfo.html)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# Get user 1 session info as data.frames & export to CSV files
user1_sessioninfo_df <- session_info_df()

write.csv(user1_sessioninfo_df$packages, "user1_packages.csv", row.names = FALSE)
write.csv(user1_sessioninfo_df$r_info,    "r_info.csv",        row.names = FALSE)

# rstudio element may be NULL if not running in RStudio
if (!is.null(user1_sessioninfo_df$rstudio)) {
  write.csv(user1_sessioninfo_df$rstudio, "rstudio_info.csv", row.names = FALSE)
}

# Get user 2 session info and compare with user 1
user2_sessioninfo_df <- session_info_df()
user1_packages <- read.csv("user1_packages.csv", stringsAsFactors = FALSE)

# Compare packages by package name
merged_pkgs <- merge(
  user1_packages,
  user2_sessioninfo_df$packages,
  by = "package",
  suffixes = c("_user1", "_user2"),
  all = TRUE
)

# Find packages that differ in version or are missing in one of the users
differing_pkgs <- merged_pkgs[
  merged_pkgs$version_user1 != merged_pkgs$version_user2 |
    is.na(merged_pkgs$version_user1) |
    is.na(merged_pkgs$version_user2),
]

differing_pkgs
} # }
```

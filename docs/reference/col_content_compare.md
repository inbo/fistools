# Compare column contents of two dataframes

Compares the content of 2 similar columns of two data frames. The
function prints a list of values missing from the first column, missing
from the second column, and the values that are in both columns.

## Usage

``` r
col_content_compare(df1, col1, df2, col2)
```

## Arguments

- df1:

  A data frame

- col1:

  A column name of df1

- df2:

  A data frame

- col2:

  A column name of df2

## Value

A list of values missing from the first column, missing from the second
column, and the values that are in both columns.

## See also

Other dataframe_comparison: [`colcompare()`](colcompare.md)

## Author

Sander Devisscher

## Examples

``` r
 if (FALSE) { # \dontrun{
dataset1 <- data.frame(a = c(1, 2, 3, 4, 5), b = c("a", "b", "c", "d", "e"))
dataset2 <- data.frame(c = c(1, 2, 3, 4, 5), d = c("a", "b", "f", "d", "e"))
col_content_compare(df1 = dataset1, "b", df2 = dataset2, "d")
} # }
```

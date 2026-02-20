# Retry a function multiple times

This function evaluates an expression multiple times until it succeeds
or the maximum number of attempts is reached.

## Usage

``` r
retry_function(expr, max_attempts = 3, sleep_time = 0)
```

## Arguments

- expr:

  An expression to evaluate.

- max_attempts:

  The maximum number of attempts to make.

- sleep_time:

  The time to sleep between attempts, in seconds.

## Value

The result of the expression if successful.

## See also

Other other: [`label_selecter()`](label_selecter.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
# This example will fail or succeed randomly.

some_function <- function() {
 if (runif(1) < 0.5) {  # Randomly fail
   stop("\U02620 Something went wrong!")
   }
 return("Success")
}

retry_function({some_function()}, max_attempts = 5, sleep_time = 1)
} # }
```

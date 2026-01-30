# Potential conflict index (first variant)

questionnaire data analysis: potential conflict index

## Usage

``` r
qd_pci1(x, scale_values = c(-2:2), x_is_table = FALSE)
```

## Arguments

- x:

  vector with scores of the respondents

- scale_values:

  vector with levels; default: -2:2

- x_is_table:

  if TRUE, x is table with the distribution of the scores

## Value

PCI-score (potential for conflict index)

## See also

Other plotting: [`qd_pci2()`](qd_pci2.md), [`qd_pci2_D()`](qd_pci2_D.md)

## Examples

``` r
if (FALSE) { # \dontrun{
 set.seed(201)
 Xv <- sample(-2:2, size = 100, replace = TRUE) #random responses
 Yv <- rep(c(-2,2),50) #most extreme difference
 Zv <- rep(2,100) #minimal difference
 #qd_pci1
 qd_pci1(Xv, scale_values = -2:2, x_is_table = FALSE) # 0.4
 qd_pci1(Yv, scale_values = -2:2, x_is_table = FALSE) # 1
 qd_pci1(Zv, scale_values = -2:2, x_is_table = FALSE) # 0
} # }
```

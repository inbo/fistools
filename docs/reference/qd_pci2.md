# Potential conflict index (second variant)

Calculates the potential conflict index based on the distance matrix
between responses.

## Usage

``` r
qd_pci2(
  x,
  scale_values = c(-2:2),
  x_is_table = FALSE,
  m = 1,
  p = 1,
  print = FALSE
)
```

## Arguments

- x:

  vector with scores of the respondents

- scale_values:

  vector with levels; default: -2:2

- x_is_table:

  if TRUE, x is table with the distribution of the scores

- m:

  correction; default: m = 1

- p:

  power; default: p = 1

- print:

  flag; if TRUE print results

## Value

PCI-score (potential for conflict index)

## See also

Other plotting: [`qd_pci1()`](qd_pci1.md), [`qd_pci2_D()`](qd_pci2_D.md)

## Examples

``` r
if (FALSE) { # \dontrun{
set.seed(201)
Xv <- sample(-2:2, size = 100, replace = TRUE) #random responses
Yv <- rep(c(-2,2),50) #most extreme difference
Zv <- rep(2,100) #minimal difference
#qd_pci2 - using D2 (m=1)
qd_pci2(Xv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 0.37
qd_pci2(Yv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 1
qd_pci2(Zv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 0
qd_pci2(Xv, scale_values = -2:2, x_is_table = FALSE, m = 2, p = 1) # 0.31
qd_pci2(Yv, scale_values = -2:2, x_is_table = FALSE, m = 2, p = 1) # 1
qd_pci2(Zv, scale_values = -2:2, x_is_table = FALSE, m = 2, p = 1) # 0
} # }
```

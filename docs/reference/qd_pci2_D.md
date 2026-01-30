# Distance matrix for qd_pci2

Calculates distance matrix for the function qd_pci2

## Usage

``` r
qd_pci2_D(x, m = 1, p = 1)
```

## Arguments

- x:

  vector with the scores of the respondents

- m:

  m value in the formula (see details)

- p:

  power value in the formula (see details)

## Value

single value containing pci index

## Details

\$\$Dp\_{x,y} = (\|r\_{x} - r\_{y}\|) - (m-1))^{p}\$\$ \$\$if
sign(r\_{x} \neq r\_{y}) \\ else d\_{x,y} = 0\$\$ Dp_x,y = (\|r_x -
r_y\| - (m-1))^p

## See also

Other plotting: [`qd_pci1()`](qd_pci1.md), [`qd_pci2()`](qd_pci2.md)

## Examples

``` r
if (FALSE) { # \dontrun{
#'set.seed(201)
Xv <- sample(-2:2, size = 100, replace = TRUE) #random responses
qd_pci2(Xv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 0.37
} # }
```

# Potential for Conflict Index (PCI) Visualization Layer

This function constructs a composite ggplot2 layer that automatically
calculates and draws Potential for Conflict Index (PCI) circles directly
from raw ordinal data, optionally supported by structured background
micro-histograms.

## Usage

``` r
geom_pci(
  mapping = NULL,
  data = NULL,
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  bars = TRUE,
  bar_width = 0.4,
  max_height = 0.4,
  bar_fill = "gray88",
  pci_fun = qd_pci2,
  n_points = 60,
  ...
)
```

## Arguments

- mapping:

  Set of aesthetic mappings created by
  [`aes`](https://ggplot2.tidyverse.org/reference/aes.html).

- data:

  The dataset to be displayed..

- position:

  Position adjustment (e.g., "identity").

- na.rm:

  Logical. If `TRUE`, missing values are silently removed.

- show.legend:

  Logical. Should this layer be included in the legends?

- inherit.aes:

  If `FALSE`, the default aesthetics are overridden.

- bars:

  Logical. If `TRUE` (default), the distribution bars are drawn in the
  background.

- bar_width:

  Numeric. The width of the background bars. Default is 0.4.

- max_height:

  Numeric. The maximum height proportion of the bars within their own
  row track. Default is 0.4.

- bar_fill:

  Character. The fill color of the background bars. Default is "gray88".

- pci_fun:

  Function. The algorithm used to compute the PCI index. Default is
  `qd_pci2`.

- n_points:

  Integer. The number of points used to smoothly generate the circle's
  polygon path. Default is 60.

- ...:

  Other arguments passed directly to the underlying
  [`layer`](https://ggplot2.tidyverse.org/reference/layer.html).

## Value

A `ggplot2` layer object (if `bars = FALSE`) or a list containing two
layers (background bars and foreground circles) if `bars = TRUE`.

## Author

Martijn Bollen

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
library(dplyr)
library(forcats)

# Load sample data
load("data/surveyMonkey_q6.rda")

x_lbls <- c("Not at all a priority (-2)", "Not a priority (-1)",
             "Neutral (0)", "A priority (1)", "A big priority (2)")

# -------------------------------------------------------------------------
# Example 1: Colored by Agreement / Mean Position (Default Layout)
# -------------------------------------------------------------------------
surveyMonkey_q6 %>%
  filter(!is.na(score)) %>%
  ggplot(aes(x = score, y = fct_reorder(topic, score, mean))) +

  # Explicitly mapping fill and color to the computed X-axis center (x0)
  geom_pci(aes(fill = after_stat(x0), color = after_stat(x0)), alpha = 0.8) +

  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  scale_x_continuous(limits = c(-2.5, 2.5), breaks = -2:2, labels = x_lbls) +

  # Continuous scale mapping to the after_stat(x0) values:
  scale_fill_gradient2(low = "#b2182b", mid = "#f7f7f7", high = "#2166ac", midpoint = 0) +
  scale_color_gradient2(low = "#67001f", mid = "gray70", high = "#053061", midpoint = 0) +

  guides(fill = "none", color = "none") +
  labs(x = "", y = "") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

# -------------------------------------------------------------------------
# Example 2: Minimalist Layout without Background Histogram Bars
# -------------------------------------------------------------------------
surveyMonkey_q6 %>%
  filter(!is.na(score)) %>%
  ggplot(aes(x = score, y = fct_reorder(topic, score, mean))) +

  # Setting bars = FALSE hides the background micro-histograms
  geom_pci(aes(fill = after_stat(x0), color = after_stat(x0)), bars = FALSE, alpha = 0.8) +

  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  scale_x_continuous(limits = c(-2.5, 2.5), breaks = -2:2, labels = x_lbls) +

  scale_fill_gradient2(low = "#b2182b", mid = "#f7f7f7", high = "#2166ac", midpoint = 0) +
  scale_color_gradient2(low = "#67001f", mid = "gray70", high = "#053061", midpoint = 0) +

  guides(fill = "none", color = "none") +
  labs(x = "", y = "") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))

# -------------------------------------------------------------------------
# Example 3: Colored by Conflict Score (Radius 'r') instead of Mean
# -------------------------------------------------------------------------
surveyMonkey_q6 %>%
  filter(!is.na(score)) %>%
  ggplot(aes(x = score, y = fct_reorder(topic, score, mean))) +

  # Mapping fill and color to after_stat(r) highlights high-conflict topics
  geom_pci(aes(fill = after_stat(r), color = after_stat(r)), alpha = 0.8) +

  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  scale_x_continuous(limits = c(-2.5, 2.5), breaks = -2:2, labels = x_lbls) +

  # Using viridis to visually isolate high polarization values cleanly
  scale_fill_viridis_c() +
  scale_color_viridis_c() +

  guides(fill = "none", color = "none") +
  labs(x = "", y = "") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
} # }
```

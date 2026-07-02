#' Potential for Conflict Index (PCI) Visualization Layer
#'
#' @author Martijn Bollen
#'
#' @description This function constructs a composite ggplot2 layer that
#' automatically calculates and draws Potential for Conflict Index (PCI) circles
#' directly from raw ordinal data, optionally supported by structured background
#' micro-histograms.
#'
#' @importFrom ggplot2 ggproto Stat GeomPolygon GeomRect layer
#' @importFrom dplyr filter group_by mutate select rename reframe n
#' @importFrom tidyr unnest
#'
#' @param mapping Set of aesthetic mappings created by \code{\link[ggplot2]{aes}}.
#' @param data The dataset to be displayed..
#' @param position Position adjustment (e.g., "identity").
#' @param na.rm Logical. If \code{TRUE}, missing values are silently removed.
#' @param show.legend Logical. Should this layer be included in the legends?
#' @param inherit.aes If \code{FALSE}, the default aesthetics are overridden.
#' @param bars Logical. If \code{TRUE} (default), the distribution bars are drawn in the background.
#' @param bar_width Numeric. The width of the background bars. Default is 0.4.
#' @param max_height Numeric. The maximum height proportion of the bars within their own row track. Default is 0.4.
#' @param bar_fill Character. The fill color of the background bars. Default is "gray88".
#' @param pci_fun Function. The algorithm used to compute the PCI index. Default is \code{qd_pci2}.
#' @param n_points Integer. The number of points used to smoothly generate the circle's polygon path. Default is 60.
#' @param ... Other arguments passed directly to the underlying \code{\link[ggplot2]{layer}}.
#'
#' @return A \code{ggplot2} layer object (if \code{bars = FALSE}) or a list containing
#' two layers (background bars and foreground circles) if \code{bars = TRUE}.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(dplyr)
#' library(forcats)
#'
#' # Load sample data
#' load("data/surveyMonkey_q6.rda")
#'
#' x_lbls <- c("Not at all a priority (-2)", "Not a priority (-1)",
#'              "Neutral (0)", "A priority (1)", "A big priority (2)")
#'
#' # -------------------------------------------------------------------------
#' # Example 1: Colored by Agreement / Mean Position (Default Layout)
#' # -------------------------------------------------------------------------
#' surveyMonkey_q6 %>%
#'   filter(!is.na(score)) %>%
#'   ggplot(aes(x = score, y = fct_reorder(topic, score, mean))) +
#'
#'   # Explicitly mapping fill and color to the computed X-axis center (x0)
#'   geom_pci(aes(fill = after_stat(x0), color = after_stat(x0)), alpha = 0.8) +
#'
#'   geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
#'   scale_x_continuous(limits = c(-2.5, 2.5), breaks = -2:2, labels = x_lbls) +
#'
#'   # Continuous scale mapping to the after_stat(x0) values:
#'   scale_fill_gradient2(low = "#b2182b", mid = "#f7f7f7", high = "#2166ac", midpoint = 0) +
#'   scale_color_gradient2(low = "#67001f", mid = "gray70", high = "#053061", midpoint = 0) +
#'
#'   guides(fill = "none", color = "none") +
#'   labs(x = "", y = "") +
#'   theme_minimal() +
#'   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
#'
#' # -------------------------------------------------------------------------
#' # Example 2: Minimalist Layout without Background Histogram Bars
#' # -------------------------------------------------------------------------
#' surveyMonkey_q6 %>%
#'   filter(!is.na(score)) %>%
#'   ggplot(aes(x = score, y = fct_reorder(topic, score, mean))) +
#'
#'   # Setting bars = FALSE hides the background micro-histograms
#'   geom_pci(aes(fill = after_stat(x0), color = after_stat(x0)), bars = FALSE, alpha = 0.8) +
#'
#'   geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
#'   scale_x_continuous(limits = c(-2.5, 2.5), breaks = -2:2, labels = x_lbls) +
#'
#'   scale_fill_gradient2(low = "#b2182b", mid = "#f7f7f7", high = "#2166ac", midpoint = 0) +
#'   scale_color_gradient2(low = "#67001f", mid = "gray70", high = "#053061", midpoint = 0) +
#'
#'   guides(fill = "none", color = "none") +
#'   labs(x = "", y = "") +
#'   theme_minimal() +
#'   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
#'
#' # -------------------------------------------------------------------------
#' # Example 3: Colored by Conflict Score (Radius 'r') instead of Mean
#' # -------------------------------------------------------------------------
#' surveyMonkey_q6 %>%
#'   filter(!is.na(score)) %>%
#'   ggplot(aes(x = score, y = fct_reorder(topic, score, mean))) +
#'
#'   # Mapping fill and color to after_stat(r) highlights high-conflict topics
#'   geom_pci(aes(fill = after_stat(r), color = after_stat(r)), alpha = 0.8) +
#'
#'   geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
#'   scale_x_continuous(limits = c(-2.5, 2.5), breaks = -2:2, labels = x_lbls) +
#'
#'   # Using viridis to visually isolate high polarization values cleanly
#'   scale_fill_viridis_c() +
#'   scale_color_viridis_c() +
#'
#'   guides(fill = "none", color = "none") +
#'   labs(x = "", y = "") +
#'   theme_minimal() +
#'   theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
#' }

geom_pci <- function(mapping = NULL, data = NULL, position = "identity",
                     na.rm = FALSE, show.legend = NA, inherit.aes = TRUE,
                     bars = TRUE,            # Toggle background bars
                     bar_width = 0.4,        # Parameter for bars
                     max_height = 0.4,       # Parameter for bars
                     bar_fill = "gray88",    # Parameter for bars
                     pci_fun = qd_pci2,      # Parameter for circles
                     n_points = 60,          # Parameter for circles
                     ...) {

  # Build primary circle polygon layer
  circle_layer <- layer(
    stat = StatPciCircle, data = data, mapping = mapping, geom = ggplot2::GeomPolygon,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, pci_fun = pci_fun, n_points = n_points, ...)
  )

  if (bars) {
    # Build secondary background bar layer
    bars_layer <- layer(
      stat = StatPciBars, data = data, mapping = mapping, geom = ggplot2::GeomRect,
      position = position, show.legend = show.legend, inherit.aes = inherit.aes,
      params = list(na.rm = na.rm, bar_width = bar_width, max_height = max_height,
                    fill = bar_fill, color = NA) # We separate circle '...' from bar parameters
    )

    # Return a list containing BOTH layers.
    # Because ggplot evaluations happen sequentially, bars_layer executes first (goes to the background)
    return(list(bars_layer, circle_layer, ggplot2::coord_fixed()))
  } else {
    # If bars = FALSE, return only the circle layer
    return(list(circle_layer, ggplot2::coord_fixed()))
  }
}

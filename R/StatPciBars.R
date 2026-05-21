StatPciBars <- ggplot2::ggproto("StatPciBars", ggplot2::Stat,
                                required_aes = c("x", "y"),
                                compute_panel = function(data, scales, bar_width = 0.4, max_height = 0.4) {
                                  data %>%
                                    dplyr::filter(!is.na(x), !is.na(y)) %>%
                                    dplyr::group_by(y, x, group, PANEL) %>%
                                    dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
                                    dplyr::group_by(y, group, PANEL) %>%
                                    dplyr::mutate(
                                      xmin = x - (bar_width / 2),
                                      xmax = x + (bar_width / 2),
                                      ymin = y,
                                      ymax = y + (n / max(n)) * max_height,
                                      x0 = 0,
                                      r = 0
                                    ) %>%
                                    dplyr::ungroup()
                                }
)

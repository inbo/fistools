StatPciCircle <- ggplot2::ggproto("StatPciCircle", ggplot2::Stat,
                                  required_aes = c("x", "y"),
                                  default_aes = ggplot2::aes(
                                    fill  = ggplot2::after_stat(x0),
                                    color = ggplot2::after_stat(x0)
                                  ),
                                  compute_panel = function(data, scales, pci_fun = qd_pci2, n_points = 60) {
                                    pci_base <- data %>%
                                      dplyr::filter(!is.na(x), !is.na(y)) %>%
                                      dplyr::group_by(y, group, PANEL) %>%
                                      dplyr::summarise(
                                        x0 = mean(x),
                                        r = pci_fun(x),
                                        dplyr::across(dplyr::any_of(c("fill", "color")), ~ .x[1]),
                                        .groups = "drop"
                                      )
                                    pci_base %>%
                                      dplyr::reframe(
                                        theta = list(seq(0, 2 * pi, length.out = n_points)),
                                        .by = dplyr::any_of(c("y", "PANEL", "group", "x0", "r", "fill", "color"))
                                      ) %>%
                                      tidyr::unnest(theta) %>%
                                      dplyr::mutate(
                                        x = x0 + r * cos(theta),
                                        y_poly = y + r * sin(theta),
                                        group = as.integer(factor(interaction(y, PANEL, group)))
                                      ) %>%
                                      dplyr::select(-y, -theta) %>%
                                      dplyr::rename(y = y_poly)
                                  }
)

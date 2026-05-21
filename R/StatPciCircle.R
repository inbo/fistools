StatPciCircle <- ggproto("StatPciCircle", Stat,
                         required_aes = c("x", "y"),
                         compute_panel = function(data, scales, pci_fun = qd_pci2, n_points = 60) {
                           data %>%
                             filter(!is.na(x), !is.na(y)) %>%
                             group_by(y, PANEL) %>%
                             summarise(
                               x0 = mean(x),
                               r = pci_fun(x),
                               .groups = "drop"
                             ) %>%
                             reframe(
                               theta = list(seq(0, 2 * pi, length.out = n_points)),
                               .by = c(y, PANEL, x0, r)
                             ) %>%
                             unnest(theta) %>%
                             mutate(
                               x = x0 + r * cos(theta),
                               y_poly = y + r * sin(theta),
                               group = as.integer(factor(interaction(y, PANEL))),
                               fill = x0,
                               color = x0
                             ) %>%
                             select(-y, -theta) %>%
                             rename(y = y_poly)
                         }
)

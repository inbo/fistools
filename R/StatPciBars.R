StatPciBars <- ggproto("StatPciBars", Stat,
                       required_aes = c("x", "y"),
                       compute_panel = function(data, scales, bar_width = 0.4, max_height = 0.4) {
                         data %>%
                           filter(!is.na(x), !is.na(y)) %>%
                           group_by(y, x, group, PANEL) %>%
                           summarise(n = n(), .groups = "drop") %>%
                           group_by(y, group, PANEL) %>%
                           mutate(
                             xmin = x - (bar_width / 2),
                             xmax = x + (bar_width / 2),
                             ymin = y,
                             ymax = y + (n / max(n)) * max_height
                           ) %>%
                           ungroup()
                       }
)

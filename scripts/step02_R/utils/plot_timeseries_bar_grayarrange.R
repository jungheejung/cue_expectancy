plot_timeseries_bar_grayarrange <- function(df, iv1, iv2, mean, error, xlab, ylab, ggtitle, color) {
  
  # Reorder levels of iv2 factor: Non-gray before gray
  non_gray_levels <- levels(df[[iv2]])[!grepl("gray", levels(df[[iv2]]))]
  gray_levels <- levels(df[[iv2]])[grepl("gray", levels(df[[iv2]]))]
  ordered_levels <- c(gray_levels, non_gray_levels)  # Gray conditions first
  df[[iv2]] <- factor(df[[iv2]], levels = ordered_levels)
  
  g <- ggplot(
    data = df,
    aes(
      x = .data[[iv1]],
      y = .data[[mean]],
      group = factor(.data[[iv2]]),
      color = factor(.data[[iv2]])
    )
  ) +
  
  geom_errorbar(
    aes(
      ymin = (.data[[mean]] - .data[[error]]),
      ymax = (.data[[mean]] + .data[[error]]),
      fill = factor(.data[[iv2]]), color = factor(.data[[iv2]])
    ),
    width = .1,
    alpha =  0.8)  +
  
  geom_line() +
  geom_point(
    aes(fill = factor(.data[[iv2]]), color = factor(.data[[iv2]])),
    alpha = 0.8,  # Set alpha for both gray and colored conditions
    position = position_jitterdodge(jitter.width = 0.2)
  ) +
  
  ggtitle(ggtitle) +
  xlab(xlab) +
  ylab(ylab) +
  
  theme_classic() +
  expand_limits(x = 3.25) +
  
  scale_color_manual("", values = color) +
  scale_fill_manual("", values = color) +
  
  theme(
    aspect.ratio = .6,
    axis.title.x = element_text(size = 30),
    axis.title.y = element_text(size = 24),
    legend.position = c(.99, .99),
    legend.justification = c("right", "top"),
    legend.box.just = "right",
    legend.margin = margin(6, 6, 6, 6),
    text = element_text(size = 20),
    legend.key = element_rect(fill = "white", colour = "white"),
    legend.background = element_rect(fill = "white", colour = NA)
  ) +
  
  theme_bw()
  
  return(g)
}

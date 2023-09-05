plot_timeseries_bar <-  function(df, iv1, iv2, mean, error, xlab, ylab, ggtitle, color) {
    
n_points <- 100  # Number of points for interpolation
# interpolated_data <- data.frame(
#   
#   x = rep(seq(min(df[[iv1]]), max(df[[iv1]]), length.out = n_points), each = n_points),
#   y = rep(df[[mean]], each = n_points),
#   ymin = rep(df[[mean]] - df[[error]], each = n_points),
#   ymax = rep(df[[mean]] + df[[error]], each = n_points)
# )
    g <- ggplot(
      data = df,
      aes(
        x = .data[[iv1]],
        y = .data[[mean]],
        group = factor(.data[[iv2]]),
        color = factor(.data[[iv2]])
      ),
      cex.lab = 1.5,
      cex.axis = 2,
      cex.main = 1.5,
      cex.sub = 1.5
    ) +

      geom_errorbar(aes(
        ymin = (.data[[mean]] - .data[[error]]),
        ymax = (.data[[mean]] + .data[[error]]),
        fill =  factor(.data[[iv2]])
      ), width = .1, alpha=0.8) +

      geom_line() +
      geom_point() +
      ggtitle(ggtitle) +
      xlab(xlab) +
      ylab(ylab) +

      theme_classic() +
      expand_limits(x = 3.25) +

      scale_color_manual("",
                         values =  color) +
            scale_fill_manual("",
                         values =  color) +
      theme(
        aspect.ratio = .6,
        text = element_text(size = 20),
        axis.title.x = element_text(size = 24),
        axis.title.y = element_text(size = 24),
        legend.position = c(.99, .99),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6)
      ) +
      theme(legend.key = element_rect(fill = "white", colour = "white")) +
      theme_bw()
    
    return(g)
  }

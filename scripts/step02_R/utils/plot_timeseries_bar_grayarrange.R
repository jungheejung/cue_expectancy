#' Plot Time Series Bar with Gray Arrange
#'
#' This function creates a time series bar plot with a specific arrangement for gray and non-gray levels of a factor. It uses ggplot2 for plotting and allows for custom color settings. The levels of the second independent variable are reordered so that gray levels appear first.
#'
#' @param df A data frame containing the data to be plotted.
#' @param iv1 The name of the first independent variable for the x-axis.
#' @param iv2 The name of the second independent variable used for grouping and coloring, with special handling for 'gray' levels.
#' @param mean The name of the column containing mean values to be plotted on the y-axis.
#' @param error The name of the column containing error values for error bars.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis.
#' @param ggtitle Title of the plot.
#' @param color A named vector of colors to be used for the different groups represented by `iv2`.
#'
#' @return A ggplot object representing the time series bar plot.
#'
#' @import ggplot2
#' @export
#'
#' @examples
#' df <- data.frame(
#'     time = c(1, 2, 3, 1, 2, 3),
#'     condition = c("gray1", "gray2", "non-gray1", "gray1", "gray2", "non-gray1"),
#'     mean = rnorm(6),
#'     error = runif(6, 0.1, 0.5)
#' )
#' plot_timeseries_bar_grayarrange(df, "time", "condition", "mean", "error",
#'     "Time", "Response", "My Plot", c("gray1" = "gray", "gray2" = "darkgray", "non-gray1" = "blue"))

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

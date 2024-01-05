plot_timeseries_bar <- function(df, iv1, iv2, mean, error, xlab, ylab, ggtitle, color_mapping, y_limits = NULL, show_legend = TRUE, alpha_value = 1, geompoint_size = 3) {
  #' Create a Time Series Bar Plot
  #'
  #' This function generates a time series plot using the ggplot2 package in R.
  #' It's designed for visualizing time series data with error bars, grouping by a categorical variable,
  #' and coloring specific groups differently.
  #'
  #' @param df A data frame containing the time series data.
  #' @param iv1 The name of the independent variable for the x-axis.
  #' @param iv2 The name of the categorical variable for grouping the data.
  #' @param mean The name of the variable representing the mean values for each group.
  #' @param error The name of the variable representing the error values for each group.
  #' @param xlab The label for the x-axis.
  #' @param ylab The label for the y-axis.
  #' @param ggtitle The title for the plot.
  #' @param color_mapping A named vector specifying the color mapping for categorical groups.
  #' @param y_limits A numeric vector specifying the lower and upper limits for the y-axis.
  #' @param show_legend Logical, indicating whether to display the legend (default is TRUE).
  #' @param alpha_value The alpha value (transparency) for data points (default is 1).
  #'
  #' @return A ggplot2 object representing the time series bar plot.
  #'
  #' @details This function creates a time series bar plot with error bars using ggplot2.
  #' It allows for customization of colors, labels, and legend display.
  #'
  #' @examples
  #' # Create sample data
  #' data <- data.frame(
  #'   Time = rep(1:5, each = 3),
  #'   Group = rep(c("A", "B", "C"), times = 5),
  #'   Mean = rnorm(15, mean = 0, sd = 1),
  #'   Error = runif(15, min = 0, max = 0.5)
  #' )
  #'
  #' # Define color mapping
  #' colors <- c("red", "blue", "gray")
  #'
  #' # Create the time series bar plot
  #' plot_timeseries_bar(
  #'   df = data,
  #'   iv1 = "Time",
  #'   iv2 = "Group",
  #'   mean = "Mean",
  #'   error = "Error",
  #'   xlab = "Time",
  #'   ylab = "Value",
  #'   ggtitle = "Time Series Bar Plot",
  #'   color_mapping = setNames(colors, unique(data$Group))
  #' )
  #'
  #' @seealso \code{\link{ggplot2}}
  #'
  #' @import ggplot2
  #'
  #' @export

  library(ggplot2)
  # Determine y-axis limits if not provided
  if (is.null(y_limits)) {
    y_min <- min(df[[mean]] - df[[error]], na.rm = TRUE)
    y_max <- max(df[[mean]] + df[[error]], na.rm = TRUE)
    y_limits <- c(y_min, y_max)
  }
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
  )

  g <- g + geom_errorbar(
    aes(
      ymin = (.data[[mean]] - .data[[error]]),
      ymax = (.data[[mean]] + .data[[error]])
    ),
    width = .1
   # alpha = ifelse(.data[[iv2]] %in% names(color_mapping)[color_mapping == "gray"], .4, 1)
  ) +
    geom_line()
  g <- g + geom_point(
    data = df %>% filter(.data[[iv2]] %in% names(color_mapping)[color_mapping == "gray"]), # nolint
    aes(color = factor(.data[[iv2]])),
    size = geompoint_size * .5, alpha = 0.4
  )

  # Add points for non-'gray' conditions with no transparency
  g <- g + geom_point(
    data = df %>% filter(!(.data[[iv2]] %in% names(color_mapping)[color_mapping == "gray"])), # nolint
    aes(color = factor(.data[[iv2]])),
    size = geompoint_size, alpha = 1
  )

  g <- g +
    ggtitle(ggtitle) +
    xlab(xlab) +
    ylab(ylab) +

    theme_classic() +
    expand_limits(x = 3.25) +

    scale_color_manual("", values = color_mapping) +

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
    theme_bw() +
    guides(alpha = "none") # Disable the alpha legend

  # Conditionally remove the legend
  if (!show_legend) {
    g <- g + theme(legend.position = "none")
  }


  return(g)
}

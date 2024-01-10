#' Prettify a Legend and Combine with a Plot
#'
#' This function takes a ggplot object, customizes a legend, and combines it with the plot.
#'
#' @param ggplot_obj A ggplot object that you want to combine with the legend.
#' @param factor_level A character vector specifying the factor levels for the legend.
#' @param factor_color A character vector specifying the colors for each factor level.
#' @param geom_point_size Size of the points in the legend. Default is 3.
#' @param legend_position A numeric vector specifying the legend's x and y positions. Default is c(-0.1, 0.9).
#' @param legend_widths A numeric vector specifying the relative widths of the plot and legend. Default is c(4, 1).
#'
#' @return A combined plot with a customized legend.
#'
#' @examples
#' \dontrun{
#' my_ggplot <- prettify_legend(my_ggplot, factor_level = c("High cue", "Low cue"), factor_color = c("#D73027", "#4575B4"))
#' }
#'
#' @import ggplot2
#' @import gridExtra
#'
#' @export
ggplot_prettifylegend <- function(ggplot_obj, factor_level, factor_color, geom_point_size = 3, legend_position = c(-0.1, 0.9), legend_widths = c(4, 1)) {
  legend_data <- data.frame(
    factorlevel = factor(factor_level),
    color = factor_color,
    stringsAsFactors = FALSE
  )
  
  # Create the legend as a separate plot
  legend_plot <-
    ggplot(legend_data, aes(x = 1, y = factorlevel, color = factorlevel)) +
    geom_point(size = geom_point_size) +
    scale_color_manual(values = factor_color) +
    theme_void() +
    theme(
      legend.position = legend_position,
      legend.text = element_text(size = 12, vjust = 0.5),
      # Adjust text size and vertical alignment
      legend.margin = margin(0, 0, 0, 0),
      legend.box.background = element_blank()
    ) +
    guides(color = guide_legend(
      title = "",
      title.position = "top"
    ))
  
  legend_grob <- ggplotGrob(legend_plot)$grobs[[which(sapply(ggplotGrob(legend_plot)$grobs, function(x) x$name) == "guide-box")]]
  
  # Use grid.arrange to put them together
  combined_plot <- grid.arrange(ggplot_obj, legend_grob,
                                ncol = 2,
                                widths = legend_widths)  # Adjust widths as needed
  
  return(combined_plot)
}

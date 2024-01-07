#' Create a Cue Expectancy Plot with Two Factors
#'
#' This function generates a cue expectancy plot with two factors, including customization options for various plot elements.
#'
#' @param subjectwise Data for outcome by subject.
#' @param groupwise Data for outcome by group.
#' @param model_iv1 First independent variable for modeling.
#' @param model_iv2 Second independent variable for modeling.
#' @param sub_mean Mean outcome by subject.
#' @param group_mean Mean outcome by group.
#' @param se Standard error.
#' @param subject Subject information.
#' @param ggtitle Title for the plot.
#' @param title Title for the plot.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis.
#' @param taskname Task name.
#' @param ylim Limits for the y-axis.
#' @param w Width of the plot.
#' @param h Height of the plot.
#' @param dv_keyword Keyword for dependent variable.
#' @param color Color for plot elements.
#' @param plot_savefname Filename for saving the plot.
#' @param expand_x Expand limits for the x-axis. Default is TRUE.
#' @param xlim Limits for the x-axis. Default is c(NA, 3).
#' @param x_scale_expansion Expansion for x-axis scale. Default is c(0, 0.5).
#' @param x_hline_position Position for horizontal line on the x-axis. Default is 3.5.
#' @param x_hline_linetype Linetype for the horizontal line. Default is "dashed".
#' @param x_hline_nudge_x Nudge value for horizontal line on the x-axis. Default is 0.1.
#' @param x_hline_textsize Text size for the horizontal line annotation. Default is 3.
#' @param legend_factor_levels Levels for the legend factors. Default is c("High cue", "Low cue").
#' @param legend_factor_colors Colors for the legend factors. Default is c("#D73027", "#4575B4").
#' @param legend_geom_point_size Size of the points in the legend. Default is 3.
#' @param legend_position Position of the legend. Default is c(-0.1, 0.9).
#' @param legend_widths Relative widths of the plot and legend. Default is c(4, 1).
#'
#' @return A customized cue expectancy plot with two factors.
#'
#' @import ggplot2
#' @import gridExtra
#'
#' @export
#' 
#' 

plot_cueexpectancy_twofactor <- function(
  subjectwise, groupwise, model_iv1, model_iv2,
  sub_mean, group_mean, se, subject,
  ggtitle, title, xlab, ylab, taskname, ylim,
  w, h, dv_keyword, color, plot_savefname,
  expand_x = TRUE,
  xlim = c(NA, 3),
  x_scale_expansion = c(0, 0.5),
  x_hline_position = 3.5,
  x_hline_linetype = "dashed",
  x_hline_nudge_x = 0.1,
  x_hline_textsize = 3,
  legend_factor_levels = c("High cue", "Low cue"),
  legend_factor_colors = c("#D73027", "#4575B4"),
  legend_geom_point_size = 3,
  legend_position = c(-0.1, 0.9),
  legend_widths = c(4, 1)
) {
  # Generate the main plot
  g <- plot_halfrainclouds_twofactor(
    subjectwise, groupwise, model_iv1, model_iv2,
    sub_mean, group_mean, se, subject,
    ggtitle, title, xlab, ylab, taskname, ylim,
    w, h, dv_keyword, color, plot_savefname
  )
  
  # Apply customizations to the plot
  if (expand_x) {
    g <- g + coord_cartesian(xlim = xlim, ylim = c(NA, NA), clip = "off") +
      scale_x_discrete(expand = expansion(mult = x_scale_expansion))
  }
  
  g <- ggplot_hline_bartoshuk(g, xposition = x_hline_position, linetype = x_hline_linetype, nudge_x = x_hline_nudge_x, textsize = x_hline_textsize) +
    theme_classic() +
    guides(shape = guide_legend(override.aes = list(shape = c(16, 17)))) +
    theme(legend.position = "none")
  
  g <- plot_largetext(g)
  
  # Create the legend data frame

  
  # Use grid.arrange to put them together
  combined_plot <- plot_prettifylegend(
      g,
      factor_level = legend_factor_levels,
      factor_color = legend_factor_colors,
      geom_point_size = legend_geom_point_size,
      legend_position = legend_position,
      legend_widths = legend_widths
    )
  
  return(combined_plot)
}

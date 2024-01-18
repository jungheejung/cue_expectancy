#' Plot Cue Expectancy with One Factor
#'
#' This function creates a customized plot for cue expectancy data with one factor. It builds upon the `plot_halfrainclouds_onefactor` function and adds additional customizations like horizontal lines, legend modifications, and axis adjustments.
#'
#' @param subjectwise A data frame containing subject-wise data.
#' @param groupwise A data frame containing group-wise summary data.
#' @param iv Independent variable name (as a string) in the data frame.
#' @param sub_mean Name of the subject-wise mean variable in the data frame.
#' @param group_mean Name of the group mean variable in the data frame.
#' @param se Standard error for the group mean.
#' @param subject Name of the subject identifier variable in the data frame.
#' @param ggtitle Title for the ggplot.
#' @param title Title for the legend.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis.
#' @param taskname Name of the task (unused in function).
#' @param ylim y-axis limits for the plot.
#' @param w Width of the saved plot.
#' @param h Height of the saved plot.
#' @param dv_keyword Keyword associated with the dependent variable (unused in function).
#' @param color Color scheme for the plot, specified as a vector of colors.
#' @param plot_savefname Filename for saving the plot.
#' @param expand_x Logical, whether to expand x-axis.
#' @param xlim Limits for the x-axis (vector of two values).
#' @param x_scale_expansion Expansion factor for x-axis scaling.
#' @param x_hline_position Position for horizontal line.
#' @param x_hline_linetype Linetype for the horizontal line.
#' @param x_hline_nudge_x Nudge x value for the horizontal line.
#' @param x_hline_textsize Text size for labels near the horizontal line.
#' @param legend_factor_levels Factor levels for the legend.
#' @param legend_factor_colors Colors for the legend factors.
#' @param legend_geom_point_size Size of the points in the legend.
#' @param legend_position Position of the legend (vector of two values).
#' @param legend_widths Widths of the legend components (vector of two values).
#'
#' @return A ggplot object representing the customized cue expectancy plot.
#'
#' @examples
#' # Example usage (assuming appropriate data frames 'subjectwise' and 'groupwise'):
#' plot_cueexpectancy_onefactor(subjectwise, groupwise, "IVName",
#'                             "SubMean", "GroupMean", "SE", "SubjectID",
#'                             "Plot Title", "Legend Title", "X-axis Label", "Y-axis Label",
#'                             "TaskName", c(-2, 2), 8, 6, "DVKeyword",
#'                             c("blue", "red"), "output_plot.png",
#'                             TRUE, c(NA, 3), c(0, 0.5), 3.5, "dashed", 0.1, 3,
#'                             c("High cue", "Low cue"), c("#D73027", "#4575B4"), 3,
#'                             c(-0.1, 0.9), c(4, 1))
#'
#' ![Example Plot](https://github.com/jungheejung/cueR/blob/main/man/figures/example_plot_cueexpectancy_twofactor.png)
#' @export
plot_cueexpectancy_onefactor <- function(
    subjectwise, groupwise, iv,
    sub_mean, group_mean, se, subject,
    ggtitle, title, xlab, ylab, taskname,
    w, h, dv_keyword, color, plot_savefname,
    expand_x = TRUE,
    xlim = c(NA, 3),
    ylim = c(NA, NA),
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

  # 1. create backbone of one factor raincloud plot ____________________________
  g <- plot_halfrainclouds_onefactor(
    subjectwise, groupwise,
    iv, sub_mean, group_mean, se, subject,
    ggtitle, title, xlab, ylab, taskname, ylim,
    w, h, dv_keyword, color, plot_savefname
  )
  # 2. apply customizations to the plot ________________________________________
  if (expand_x) {
    g <- g + coord_cartesian(xlim = xlim, ylim = ylim, clip = "off") +
      scale_x_discrete(expand = expansion(mult = x_scale_expansion))
  }

  # 2. apply customizations to the plot ________________________________________
  g <- ggplot_hline_bartoshuk(g,
                              xposition = x_hline_position,
                              linetype = x_hline_linetype,
                              nudge_x = x_hline_nudge_x,
                              textsize = x_hline_textsize) +
    theme_classic() +
    guides(shape = guide_legend(override.aes = list(shape = c(16, 17)))) +
    theme(legend.position = "none")


  # 3. make axes, label text larger _______________________________________________
  g <- ggplot_largetext(g)


  # dreate a brand new legend and paste to plot ________________________________
  combined_plot <- ggplot_prettifylegend(
    g,
    factor_level = legend_factor_levels,
    factor_color = legend_factor_colors,
    geom_point_size = legend_geom_point_size,
    legend_position = legend_position,
    legend_widths = legend_widths
  )
  # return(g)
  return(combined_plot)
}

#' Plot Half Rainclouds for One Factor
#'
#' This function creates a half raincloud plot for a given one-factor dataset. It combines violin plots,
#' box plots, and individual data points to provide a comprehensive view of the data distribution.
#'
#' @param subjectwise A data frame containing subject-wise data.
#' @param groupwise A data frame containing group-wise summary data.
#' @param iv Independent variable name (as a string) in the data frame.
#' @param sub_mean The name of the subject-wise mean variable in the data frame.
#' @param group_mean The name of the group mean variable in the data frame.
#' @param se Standard error for the group mean.
#' @param subject The name of the subject identifier variable in the data frame.
#' @param ggtitle Title for the ggplot.
#' @param title Title for the legend.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis.
#' @param taskname Name of the task (unused in function).
#' @param ylim y-axis limits for the plot.
#' @param w Width of the
#' @param h Height of the saved plot.
#' @param dv_keyword Keyword associated with the dependent variable (unused in function).
#' @param color Color scheme for the plot, specified as a vector of colors.
#' @param plot_savefname Filename for saving the plot.
#' 
plot_halfrainclouds_onefactor <- function(subjectwise, groupwise, iv,
                                      sub_mean, group_mean, se, subject,
                                      ggtitle, title, xlab, ylab, taskname, ylim,
                                      w, h, dv_keyword, color, plot_savefname) {
  g <- ggplot(
    data = subjectwise,
    aes(
      y = .data[[sub_mean]],
      x = factor(.data[[iv]]),
      fill = factor(.data[[iv]])
    )
  ) +
    coord_cartesian(ylim = ylim, expand = TRUE) +


    geom_half_violin(
      # aes(fill = factor(.data[[iv]])),
      side = 'r',
      position = 'dodge',
      adjust = 1.5,
      trim = FALSE,
      alpha = .3,
      colour = NA
    ) +

  geom_line(data = subjectwise,
    aes(
      group = .data[[subject]],
      x = as.numeric(as.factor(.data[[iv]])) - .15,
      y = .data[[sub_mean]],
      # fill = factor(.data[[iv]])
      ),
    linetype = "solid",
    color = "grey",
    alpha = .3) +

  geom_point(
    aes(
      # group = .data[[subject]],
      x = as.numeric(as.factor(.data[[iv]])) - .15,
      y = .data[[sub_mean]],
      color = factor(.data[[iv]])
    ),
    position = position_jitter(width = .05),
    size = 2,
    alpha = 0.7,
  ) + 


    geom_half_boxplot(
      data = subjectwise,
      aes(x = .data[[iv]],
          y = .data[[sub_mean]]
          #,
          # fill = .data[[iv]]
          ),
      side = "r",
      outlier.shape = NA,
      alpha = 0.8,
      width = .1,
      notch = FALSE,
      notchwidth = 0,
      varwidth = FALSE,
      colour = "black",
      errorbar.draw = FALSE
    ) +

    geom_errorbar(
      data = groupwise,
      aes(
        x = as.numeric(.data[[iv]]) + .1,
        y = as.numeric(.data[[group_mean]]),
        colour = factor(.data[[iv]]),
        ymin = .data[[group_mean]] - .data[[se]],
        ymax = .data[[group_mean]] + .data[[se]]
      ), width = .05
    ) +


    # legend stuff ________________________________________________________ # nolint
    expand_limits(x = 2.8) +
    #guides(fill = "none") +
    guides(color = "none") +
    # guides(fill = guide_legend(title = title)) +
    scale_fill_manual(values = color) +
    scale_color_manual(values = color) +
    ggtitle(ggtitle) +
    xlab(xlab) +
    ylab(ylab) +
    theme_bw()
  # ggsave(plot_savefname, width = w, height = h)
  return(g)
}

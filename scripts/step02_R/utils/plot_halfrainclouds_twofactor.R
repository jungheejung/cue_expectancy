#' Plot Half Rainclouds for Two Factors
#'
#' This function creates a half raincloud plot for a given two-factor dataset. It combines
#' violin plots, box plots, and individual data points to provide a comprehensive view of
#' the data distribution across two independent variables.
#'
#' @param subjectwise A dataframe containing subject-wise data.
#' @param groupwise A dataframe containing group-wise summary statistics.
#' @param iv1 The name of the first independent variable in the dataframe.
#' @param iv2 The name of the second independent variable in the dataframe.
#' @param sub_mean The name of the subject-wise mean variable in the dataframe.
#' @param group_mean The name of the group mean variable in the dataframe.
#' @param se The name of the standard error variable in the dataframe.
#' @param subject The name of the subject identifier variable in the dataframe.
#' @param ggtitle Title for the ggplot.
#' @param legend_title Title for the legend.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis.
#' @param task_name Name of the task (unused in function).
#' @param ylim y-axis limits for the plot.
#' @param w Width of the saved plot.
#' @param h Height of the saved plot.
#' @param dv_keyword Keyword associated with the dependent variable (unused in function).
#' @param color Color scheme for the plot, specified as a named vector of colors.
#' @param save_fname Filename for saving the plot.
#'
#' @return A ggplot object representing the customized half raincloud plot.
#'
#' @examples
#' # Example usage (assuming appropriate data frames 'subjectwise' and 'groupwise'):
#' plot_halfrainclouds_twofactor(subjectwise, groupwise, "IV1", "IV2",
#'                               "SubMean", "GroupMean",


plot_halfrainclouds_twofactor <- function(subjectwise, groupwise,
                                      iv1, iv2, sub_mean, group_mean, se, subject,
                                      ggtitle, legend_title, xlab, ylab, task_name, ylim,
                                      w, h, dv_keyword, color, save_fname) {
    library(ggplot2)
    g <- ggplot(
        data = subjectwise,
        aes(
            y = .data[[sub_mean]],
            x = .data[[iv1]],
            fill = .data[[iv2]]
        )
    ) +

        geom_half_violin(
            data = subjectwise,
        aes(color = .data[[iv2]]),
        side = 'r',
        position = position_nudge(x = .1, y = 0),
        adjust = 1.5,
        trim = FALSE,
        alpha = .3,
        colour = NA
        ) +

        geom_line(
            data = subjectwise,
            aes(
                group = .data[[subject]],
                y = .data[[sub_mean]],
                x = as.numeric(as.factor(.data[[iv1]])) - .15,
                color = .data[[iv2]]
            ),
            linetype = 3, color = "grey", alpha = .3
        ) +
        geom_point(
            data = subjectwise,
            aes(
                x = as.numeric(as.factor(.data[[iv1]])) - .15,
                y = .data[[sub_mean]],
                color = .data[[iv2]]
            ),
            position = position_jitter(width = .05),
            size = 1, alpha = 0.8, shape = 20
        ) +

        geom_boxplot(
        data = subjectwise,
        aes(x = .data[[iv1]],
            y = .data[[sub_mean]],
            fill = .data[[iv2]]),
        outlier.shape = NA,
        alpha = 0.8,
        width = .1,
        notch = FALSE,
        notchwidth = 0,
        varwidth = FALSE,
        colour = "black",
        ) +

        # use summary stats ____________________________________________________

        geom_errorbar(
            data = groupwise,
            aes(
                x = as.numeric(as.factor(.data[[iv1]])) + .1,
                y = .data[[group_mean]],
                group = .data[[iv2]],
                colour = .data[[iv2]],
                ymin = .data[[group_mean]] - .data[[se]],
                ymax = .data[[group_mean]] + .data[[se]]
            ), width = .05
        ) +


        # legend stuff _________________________________________________________
        expand_limits(x = 3.5) +
        guides(fill = "none") +
        guides(color = "none") +
        guides(fill = guide_legend(title = legend_title)) +
        # geom_text()


        scale_fill_manual(values = color) +
        scale_color_manual(values = color) +
        ggtitle(ggtitle) +
        # coord_flip() + #vertical vs horizontal
        xlab(xlab) +
        ylab(ylab) +
        theme_classic()
        #theme(text = element_text(size = 30))   +
        theme(text = element_text(size = 15)) +theme(aspect.ratio=1) +
        theme(axis.line = element_line(colour = "black"),
            panel.background = element_blank(),
            plot.subtitle = ggtext::element_textbox_simple(size= 11))

    if (!is.null(ylim)) {
        g + ylim(ylim)
    } else {
        g
    }
    #ggsave(save_fname, width = w, height = h)
    return(g)
}

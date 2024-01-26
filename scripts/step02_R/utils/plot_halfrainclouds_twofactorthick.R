#' Plot Half Rainclouds with Two Factor Thickness
#'
#' This function creates a complex plot using ggplot2, combining half violin plots,
#' line graphs, point plots, and boxplots. It's designed to handle two independent
#' variables and a dependent variable, and includes features like error bars, 
#' manual color specification, and optional y-axis limits.
#'
#' @param subjectwise A dataframe containing subject-wise data.
#' @param groupwise A dataframe containing group-wise summary data.
#' @param iv1 The name of the first independent variable.
#' @param iv2 The name of the second independent variable.
#' @param sub_mean The name of the column representing the subject mean.
#' @param group_mean The name of the column representing the group mean.
#' @param se The name of the column representing the standard error.
#' @param subject The name of the column for subject identifiers.
#' @param ggtitle The title of the ggplot.
#' @param legend_title The title of the legend.
#' @param xlab The label for the x-axis.
#' @param ylab The label for the y-axis.
#' @param task_name Name of the task (not used in current function version).
#' @param ylim The limits for the y-axis (optional).
#' @param w The width for saving the plot (optional, requires uncommenting ggsave).
#' @param h The height for saving the plot (optional, requires uncommenting ggsave).
#' @param dv_keyword Keyword for the dependent variable (not used in current function version).
#' @param color A vector of colors for the plot elements.
#' @param save_fname The filename for saving the plot (optional, requires uncommenting ggsave).
#' @return A ggplot object.
#' @import ggplot2
#' @examples
#' # Example usage (assuming appropriate data structure):
#' plot_halfrainclouds_twofactorthick(subjectwise_data, groupwise_data, 
#'                                    "IV1", "IV2", "SubMean", "GroupMean", "SE", 
#'                                    "Subject", "Plot Title", "Legend Title", 
#'                                    "X-axis Label", "Y-axis Label", "Task", 
#'                                    c(0, 10), 10, 8, "Keyword", c("red", "blue"),
#'                                    "output_plot.png")
#' @export
plot_halfrainclouds_twofactorthick <- function(subjectwise, groupwise,
                                      iv1, iv2, sub_mean, group_mean, se, subject,
                                      ggtitle, legend_title, xlab, ylab, task_name, ylim,
                                      w, h, dv_keyword, color, save_fname) {
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
        aes(color = .data[[iv2]]), #factor(.data[[iv2]])),
        side = 'r',
        position = position_nudge(x = .2, y = 0),
        # position = 'dodge',
        adjust = 1.5,
        trim = FALSE,
        alpha = .2,
        colour = NA
        ) +

        geom_line(
            data = subjectwise,
            aes(
                group = .data[[subject]],
                y = .data[[sub_mean]],
                x = as.numeric(as.factor(.data[[iv1]])) - .25,
                color = .data[[iv2]]
            ),
            linetype = 3, color = "grey", alpha = .3
        ) +
        geom_point(
            data = subjectwise,
            aes(
                x = as.numeric(as.factor(.data[[iv1]])) - .25,
                y = .data[[sub_mean]],
                color = .data[[iv2]]
            ),
            position = position_jitter(width = .05),
            size = 1, alpha = 0.7, shape = 20
        ) +


        geom_boxplot(
        data = subjectwise,
        aes(x = .data[[iv1]],
            y = .data[[sub_mean]],
            fill = .data[[iv2]]),
        outlier.shape = NA,
        alpha = 0.8,
        width = .3,
        notch = FALSE,
        notchwidth = 0,
        varwidth = FALSE,
        colour = "black",
        ) +

        # use summary stats __________________________________________________________________________________ # nolint

        geom_errorbar(
            data = groupwise,
            aes(
                x = as.numeric(as.factor(.data[[iv1]])) + .2,
                y = .data[[group_mean]],
                group = .data[[iv2]],
                colour = .data[[iv2]],
                ymin = .data[[group_mean]] - .data[[se]],
                ymax = .data[[group_mean]] + .data[[se]]
            ), width = .05
        ) +


        # legend stuff __________________________________________________________________________________ # nolint
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

    if (!is.null(ylim)) {
        g + ylim(ylim)
    } else {
        g
    }
    ggsave(save_fname, width = w, height = h)
    return(g)
}
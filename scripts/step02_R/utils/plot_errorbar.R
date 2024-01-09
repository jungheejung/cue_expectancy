#' Plot Error Bars
#'
#' Creates a plot with error bars and points, based on subject-wise and group-wise data.
#' The plot is customized with various aesthetic parameters and saved to a file.
#'
#' @param subjectwise Data frame containing subject-wise data.
#' @param groupwise Data frame containing group-wise summary data.
#' @param iv Name of the independent variable in the data frames.
#' @param sub_iv Sub independent variable in the data frames (unused in current implementation).
#' @param group_by Grouping variable name used in the data frames.
#' @param subjectwise_mean Name of the subject-wise mean variable in `subjectwise`.
#' @param group_mean Name of the group mean variable in `groupwise`.
#' @param se Name of the standard error variable in `groupwise`.
#' @param subject Subject identifier variable in the data frames (unused in current implementation).
#' @param ggtitle Title for the ggplot.
#' @param title Title for the legend.
#' @param xlab Label for the x-axis.
#' @param ylab Label for the y-axis.
#' @param taskname Task name (unused in current implementation).
#' @param ylim Vector of two numbers for y-axis limits.
#' @param w Width of the saved plot.
#' @param h Height of the saved plot.
#' @param dv_keyword Dependent variable keyword (unused in current implementation).
#' @param color Vector of colors for the plot.
#' @param level_num Number of levels for the independent variable.
#' @param save_fname File name to save the plot.
#'
#' @return A ggplot object representing the error bars plot.
#'
#' @examples
#' # Assuming subjectwise and groupwise are appropriately structured data frames:
#' plot_errorbar(subjectwise, groupwise, "iv", "sub_iv", "group_by",
#'               "mean_var", "group_mean_var", "se", "subject",
#'               "Title", "Legend Title", "X-axis Label", "Y-axis Label",
#'               "taskname", c(-10, 10), 8, 6, "keyword", c("blue", "red"), 5, "output.png")
#'  
#' [Example](https://github.com/jungheejung/cueR/blob/main/man/figures/example_plot_binned_rating.png)
#' @import ggplot2
#' @export
plot_errorbar <- function(subjectwise, groupwise, iv, sub_iv, group_by,
                          subjectwise_mean, group_mean, se, subject,
                          ggtitle, title, xlab, ylab, taskname, ylim,
                          w, h, dv_keyword, color, level_num, save_fname) {
    library(ggplot2)
    g <- ggplot(
        data = subjectwise,
        aes(
            y = .data[[subjectwise_mean]],
            x = factor(.data[[iv]]),
            fill = factor(.data[[group_by]])
        )
    ) +
        coord_cartesian(ylim = ylim, expand = TRUE) +
        geom_point(
            aes(
                x = as.numeric(as.factor(.data[[iv]])) - (level_num / 2) - 0.1,
                y = .data[[subjectwise_mean]],
                color = factor(.data[[group_by]])
            ),
            position = position_jitter(width = .1),
            size = 1,
            alpha = 0.3,
        ) +
        geom_errorbar(
            data = groupwise,
            aes(
                x = as.numeric(.data[[iv]]) + .1,
                y = as.numeric(.data[[group_mean]]),
                group = .data[[group_by]],
                color = factor(.data[[group_by]]),
                ymin = .data[[group_mean]] - .data[[se]],
                ymax = .data[[group_mean]] + .data[[se]]
            ),
            position = position_dodge(width = 0.3), width = 0.3, # position = 'dodge',#nolint
            alpha = 1, lwd = .7
        ) +
        geom_line(
            data = groupwise,
            aes(
                group = .data[[group_by]],
                y = as.numeric(.data[[group_mean]]),
                x = as.numeric(.data[[iv]]) + .1,
                color = factor(.data[[group_by]]),
            ),
            position = position_dodge(width = 0.2),
            linetype = "solid", alpha = 1
        ) +
        # legend stuff ________________________________________________________ # nolint
        guides(fill = guide_legend(title = title)) +
        scale_fill_manual(values = color) +
        scale_color_manual(values = color) +
        ggtitle(ggtitle) +
        xlab(xlab) +
        ylab(ylab) +
        #theme_bw() +
        theme(
            axis.line = element_line(colour = "grey50"),
            panel.background = element_blank(),
            #plot.subtitle = ggtext::element_textbox_simple(size = 11)
        )
    ggsave(save_fname, width = w, height = h)
    return(g)
}

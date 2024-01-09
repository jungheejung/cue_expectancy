#' Plot a correlation using ggplot
#'
#' This function creates a scatter plot using ggplot2 and adds a correlation coefficient.
#' It is customized to control various aspects like point size, axis labels, and the
#' aspect ratio of the plot. It also allows setting limits for the axes and the position
#' of the correlation coefficient label.
#'
#' @param data A data frame containing the variables to be plotted.
#' @param x The name of the column in `data` to be used as the x variable.
#' @param y The name of the column in `data` to be used as the y variable.
#' @param p_acc A string indicating the accuracy of the p-value to be displayed.
#' @param r_acc A string indicating the accuracy of the r-value to be displayed.
#' @param limit_min The minimum limit for both x and y axes.
#' @param limit_max The maximum limit for both x and y axes.
#' @param label_position The position of the correlation coefficient label on the y-axis.
#' @return A ggplot object representing the scatter plot with correlation coefficient.
#' @examples
#' data <- data.frame(x = rnorm(100), y = rnorm(100))
#' plot_ggplot_correlation(data, "x", "y", "0.01", "0.01", -3, 3, 2)
#' @export
plot_ggplot_correlation <- function(data, x, y, p_acc, r_acc,
                                    limit_min, limit_max, label_position) {
    g <- ggplot(
        data = data,
        aes(x = .data[[x]], y = .data[[y]]),
        cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5
    ) +
        geom_point() +
        theme_classic() +
        theme(aspect.ratio = 1) +
        stat_cor(
            p.accuracy = p_acc,
            r.accuracy = r_acc,
            method = "pearson",
            label.y = label_position
        ) +
        xlim(limit_min, limit_max) +
        ylim(limit_min, limit_max)
    return(g)
}
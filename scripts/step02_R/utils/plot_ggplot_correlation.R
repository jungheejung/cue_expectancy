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
#' 
#' @examples
#' data <- data.frame(x = rnorm(100), y = rnorm(100))
#' plot_ggplot_correlation(data, "x", "y", "0.01", "0.01", -3, 3, 2)
#' pv <- cueR::plot_ggplot_correlation(data = pvc_rand_cue, x = 'vicarious', y = 'pain', 
#'                                     p_acc = 0.001, r_acc = 0.01, 
#'                                     limit_min = -.75, limit_max = .75, label_position = .6)
#' pvc_rand_cue dataframe structure:
#' * we have a subj column
#' * The other columns are tasks where we have the random effects store in long format. 
#'         subj     cognitive          pain    vicarious
#' 1   sub-0131 -0.0689888509  4.036147e-02  0.377622250
#' 2   sub-0063            NA  7.072555e-02           NA
#' 3   sub-0104 -0.1153836400  1.836190e-01 -0.095720170
#' @import ggplot2
#' @importFrom ggpubr stat_cor
#' @export
plot_ggplot_correlation <- function(data, x, y, p_acc, r_acc,
                                    limit_min, limit_max, label_position) {

    # Drop NA values in the specified columns
    data_clean <- na.omit(data, cols = c(x, y))

    # Create the plot                                
    g <- ggplot(
        data = data,
        aes(x = .data[[x]], y = .data[[y]]),
        cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5
    ) +
        geom_point() +
        theme_classic() +
        theme(aspect.ratio = 1) +
        ggpubr::stat_cor(
            p.accuracy = p_acc,
            r.accuracy = r_acc,
            method = "pearson",
            label.y = label_position
        ) +
        xlim(limit_min, limit_max) +
        ylim(limit_min, limit_max)
    return(g)
}
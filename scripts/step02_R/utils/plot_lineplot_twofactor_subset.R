#' Plot a Two-Factor Line Plot with Optional Subsetting
#'
#' This function creates a line plot for data with two factors. It allows for optional subsetting of the data based on a specified task name. If the 'taskname' column does not exist or 'taskname' is NULL, the function uses the entire dataset. It utilizes ggplot2 for plotting.
#'
#' @param data A data frame containing the dataset to be plotted.
#' @param taskname A string specifying the task name for subsetting the data, or NULL to use the entire dataset.
#' @param iv1 The name of the first independent variable (factor) for the x-axis.
#' @param iv2 The name of the second independent variable (factor) used for grouping and coloring.
#' @param mean The name of the column containing mean values to be plotted on the y-axis.
#' @param error The name of the column containing error values for error bars.
#' @param color A vector of colors to be used for the different groups represented by `iv2`.
#' @param ggtitle The title of the plot.
#' @param xlab Label for the x-axis. Default is "Stimulus Intensity".
#' @param ylab Label for the y-axis. Default is "Outcome Rating".
#'
#' @return A ggplot object representing the line plot.
#'
#' @import ggplot2
#' @export
#'
#' @examples
#' # Example usage with taskname specified:
#' p1 = plot_lineplot_twofactor_subset(data = mydata, taskname = "task1",
#'               iv1 = "intensity", iv2 = "cue", mean = "mean_score", error = "ci",
#'               color = c("red", "blue"), ggtitle = "My Plot")
#'
#' # Example usage without taskname (using entire dataset):
#' p2 = plot_lineplot_twofactor_subset(data = mydata, taskname = NULL,
#'               iv1 = "intensity", iv2 = "cue", mean = "mean_score", error = "ci",
#'               color = c("red", "blue"), ggtitle = "My Plot")
#' [Example plot](TODO)
plot_lineplot_twofactor_subset <- function(data, taskname, iv1, iv2, mean, error,
                      color, ggtitle, xlab= "Stimulus intensity", ylab = "Outcome rating",
                      xlim = NULL, ylim = NULL) {

    # Check if 'taskname' column exists in 'data'
    if ("task" %in% names(data) && !is.null(taskname)) {
        subset <- data[which(data$task == taskname), ]
    } else {
        # If 'taskname' column does not exist or 'taskname' is NULL, use the entire dataframe
        subset <- data
    }

    g <- ggplot(data = subset, aes(
        x = .data[[iv1]],
        y = .data[[mean]],
        group = as.factor(.data[[iv2]]),
        color = as.factor(.data[[iv2]])
    ), cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5) +
        geom_errorbar(aes(
            ymin = (.data[[mean]] - .data[[error]]),
            ymax = (.data[[mean]] + .data[[error]])
        ), width = .1) +
        geom_line(linewidth=.5, aes(linetype = as.factor(.data[[iv2]]) )) + # change back to geom_line() +
        geom_point() +
        ggtitle(ggtitle) +
        xlab(xlab) +
        ylab(ylab) +
        scale_color_manual(values = color) +
        scale_linetype_manual(values = c("solid", "solid")) +
        theme_classic() +
        theme(legend.position = "none") +
        theme(aspect.ratio = .6)

        # Conditionally apply xlim and ylim if provided
        if (!is.null(xlim)) {
            g <- g + xlim(xlim)
        }
        if (!is.null(ylim)) {
            g <- g + ylim(ylim)
        }
        
    return(g)
}
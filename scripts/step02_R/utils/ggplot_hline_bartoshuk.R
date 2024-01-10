#' Add horizontal lines and labels to a plot.
#'
#' This function adds horizontal lines and labels to a plot at predefined
#' y-intercepts with corresponding labels.
#'
#' @param xposition The x-position where the lines and labels will be added.
#'
#' @return NULL. This function is used for side effects (adding lines and labels to a plot).
#'
#' @examples
#' p <- ggplot(data, aes(x = x, y = y)) + geom_point()
#' p + ggplot_hline_bartoshuk(3.5)
#'
#' @import ggplot2
#'
#' @export
#' 
ggplot_hline_bartoshuk <- function(g, xposition, linesize = 0.1, linetype = "dashed", linecolor = "#adb5bd", nudge_x = 0.1, textsize = 9) {
    library(ggplot2)
    # Add horizontal lines and labels to the ggplot2 object
    g <- g +
        geom_segment(aes(x = 0, xend = xposition, y = 3, yend = 3), size = linesize, linetype = linetype, color = linecolor) +
        annotate("text", x = xposition + nudge_x, y = 3, label = "Barely detectable", hjust = 0, vjust = 0, size = textsize) +
        geom_segment(aes(x = 0, xend = xposition, y = 10, yend = 10), size = linesize, linetype = linetype, color = linecolor) +
        annotate("text", x = xposition+ nudge_x, y = 10, label = "Weak", hjust = 0, vjust = 0, size = textsize) +
        geom_segment(aes(x = 0, xend = xposition, y = 29, yend = 29), size = linesize, linetype = linetype, color = linecolor) +
        annotate("text", x = xposition+ nudge_x, y = 29, label = "Moderate", hjust = 0, vjust = 0, size = textsize) +
        geom_segment(aes(x = 0, xend = xposition, y = 64, yend = 64), size = linesize, linetype = linetype, color = linecolor) +
        annotate("text", x = xposition+ nudge_x, y = 64, label = "Strong", hjust = 0, vjust = 0, size = textsize) +
        geom_segment(aes(x = 0, xend = xposition, y = 96, yend = 96), size = linesize, linetype = linetype, color = linecolor) +
        annotate("text", x = xposition+ nudge_x, y = 96, label = "Very Strong", hjust = 0, vjust = 0, size = textsize) +
        geom_segment(aes(x = 0, xend = xposition, y = 180, yend = 180), size = linesize, linetype = linetype, color = linecolor) +
        annotate("text", x = xposition+ nudge_x, y = 180, label = "Strongest imaginable", hjust = 0, vjust = 0, size = textsize) 
    return(g)
}


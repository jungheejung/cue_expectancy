plot_lineplot_twofactorthick <- function(data, iv1, iv2, mean, error,
                      color, ggtitle, xlab= "Stimulus intensity", ylab = "Rating (degrees)",
                      line_thickness=2, xlim = NULL, ylim = NULL) {


    g <- ggplot(data = subset, aes(
        x = .data[[iv1]],
        y = .data[[mean]],
        group = as.factor(.data[[iv2]]),
        color = as.factor(.data[[iv2]])
    ), cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5) +
        geom_errorbar(aes(
            ymin = (.data[[mean]] - .data[[error]]),
            ymax = (.data[[mean]] + .data[[error]])
        ), width = .1, size=line_thickness) +
        geom_line(linewidth=line_thickness, aes(linetype = as.factor(.data[[iv2]]) )) + # change back to geom_line() +
        geom_point(size=line_thickness*2) +
        # scale_x_continuous(breaks = seq(-3, +3, by = 1)) +
        # scale_y_continuous(breaks = seq(0, 90, by=30), limits=c(0,90)) +
        ggtitle(ggtitle) +
        xlab(xlab) +
        ylab(ylab) +
        # guides(fill=guide_legend(title="Social Endorsement Position")) +
        scale_color_manual(values = color) +
        scale_linetype_manual(values = c("solid", "solid")) +
        theme_classic() +
        theme(legend.position = "none") +
        theme(text = element_text(size = 30))   +
        theme(aspect.ratio = .6)

    if (!is.null(xlim)) {
        g <- g + xlim(xlim)
    }
    if (!is.null(ylim)) {
        g <- g + ylim(ylim)
    }
return(g)
}


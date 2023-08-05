plot_lineplot_onefactorthick <- function(data, taskname, iv,  mean, error,
                      color, xlab, ylab, ggtitle) {
    # iv = "levels_ordered"
    # mean = mean_per_sub_norm_mean
    # error = ci
    subset <- data[which(data$task == taskname), ]
    line_thickness=1.5
    g <- ggplot(data = subset, aes(
        x = factor(.data[[iv]]),
        y = .data[[mean]]),
        #group = .data[[iv]],
        #color = .data[[iv]]),
        cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5) +
        geom_errorbar(aes(
            ymin = (.data[[mean]] - .data[[error]]),
            ymax = (.data[[mean]] + .data[[error]])
        ), width = .1, size=line_thickness-.5) +
        geom_line(aes(group = 1), data = subset, size=line_thickness) +
        
        geom_point(size=line_thickness*2) +
        # scale_x_continuous(breaks = seq(-3, +3, by = 1)) +
        # scale_y_continuous(breaks = seq(0, 90, by=30), limits=c(0,90)) +
        ggtitle(ggtitle) +
        xlab(xlab) +
        ylab(ylab) +
        # guides(fill=guide_legend(title="Social Endorsement Position")) +
        #scale_color_manual(values = color) +
        theme_classic() +
        theme(legend.position = "none") +
        theme(text = element_text(size = 20))   +
        theme(aspect.ratio = .6)
    return(g)
}
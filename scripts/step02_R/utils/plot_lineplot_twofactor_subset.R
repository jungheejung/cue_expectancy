plot_lineplot_twofactor_subset <- function(data, taskname, iv1, iv2, mean, error,
                      color, ggtitle, xlab= "Stimulus Intensity", ylab = "Outcome Rating") {
    # iv1 = "levels_ordered"
    # iv2 = "social_ordered"
    # mean = mean_per_sub_norm_mean
    # error = ci
    subset <- data[which(data$task == taskname), ]

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
        theme(aspect.ratio = .6)
    return(g)
}
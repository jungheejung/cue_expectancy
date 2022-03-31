plot_lineplot_twofactor <- function(data, taskname, iv1, iv2, mean, error,
                      color, ggtitle) {
    # iv1 = "levels_ordered"
    # iv2 = "social_ordered"
    # mean = mean_per_sub_norm_mean
    # error = ci
    subset <- data[which(data$task == taskname), ]

    g <- ggplot(data = subset, aes(
        x = .data[[iv1]],
        y = .data[[mean]],
        group = factor(.data[[iv2]]),
        color = factor(.data[[iv2]])
    ), cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5) +
        geom_errorbar(aes(
            ymin = (.data[[mean]] - .data[[error]]),
            ymax = (.data[[mean]] + .data[[error]])
        ), width = .1) +
        geom_line() +
        geom_point() +
        # scale_x_continuous(breaks = seq(-3, +3, by = 1)) +
        # scale_y_continuous(breaks = seq(0, 90, by=30), limits=c(0,90)) +
        ggtitle(ggtitle) +
        xlab("Stimulus intensity") +
        ylab("Rating (degrees)") +
        # guides(fill=guide_legend(title="Social Endorsement Position")) +
        scale_color_manual(values = color) +
        theme_classic() +
        theme(legend.position = "none") +
        theme(aspect.ratio = .6)
    return(g)
}
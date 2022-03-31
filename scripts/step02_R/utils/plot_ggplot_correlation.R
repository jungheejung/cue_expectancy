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
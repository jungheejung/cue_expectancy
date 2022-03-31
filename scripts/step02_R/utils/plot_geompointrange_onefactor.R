plot_geompointrange_onefactor <- function(subjectwise, groupwise,
                                 iv, subjectwise_mean, group_mean, se,
                                 xlab, ylab, color, ggtitle, w, h, save_fname) {
    j <- ggplot(
        data = subjectwise,
        mapping = aes(
            x = .data[[iv]],
            y = .data[[subjectwise_mean]]
        )
    ) +
        geom_jitter(
            position = position_jitter(0.3),
            size = 1, colour = "#808080"
        ) +
        # scale_color_manual(values = c("#D3C2FF", "#7E79FF", "#0237C9")) +
        geom_pointrange(
            data = groupwise,
            mapping = aes(
                x = .data[[iv]],
                y = .data[[group_mean]],
                ymin = as.numeric(.data[[group_mean]] - .data[[se]]),
                ymax = as.numeric(.data[[group_mean]] + .data[[se]]),
                color = .data[[iv]]
            ),
            position = position_dodge(0.3),
            size = 1, shape = 19
        ) +
        theme_classic() +
        expand_limits(x = 3.25) +
        guides(fill = FALSE) +
        guides(color = FALSE) +
        guides(fill = guide_legend(title = "social cues")) +
        scale_fill_manual(values = color) +
        scale_color_manual(values = color) +
        xlab(xlab) +
        ylab(ylab) +
        ggtitle(ggtitle)
    # ggsave(save_fname, width = w, height = h)
    return(j)
}
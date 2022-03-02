plot_actual_rainclouds <- function(subjectwise, groupwise,
                                   iv1, iv2, sub_mean, group_mean, se, subject,
                                   ggtitle, title, xlab, ylab, task_name,
                                   w, h, dv_keyword, color, save_fname) {
    g <- ggplot(
        data = subjectwise,
        aes(y = .data[[sub_mean]], x = .data[[iv1]], fill = .data[[iv2]])
    ) +
        geom_flat_violin(
            aes(fill = .data[[iv2]]),
            position = position_nudge(x = .1, y = 0),
            adjust = 1.5,
            trim = FALse, alpha = .3, colour = NA
        ) +
        geom_line(
            data = subjectwise,
            aes(
                group = .data[[subject]],
                y = .data[[sub_mean]],
                x = as.numeric(.data[[iv1]]) - .15, fill = .data[[iv2]]
            ),
            linetype = 3, color = "grey"
        ) +
        geom_point(
            data = subjectwise, aes(
                x = as.numeric(.data[[iv1]]) - .15,
                y = .data[[sub_mean]], color = .data[[iv2]]
            ),
            position = position_jitter(width = .05),
            size = 1, alpha = 0.8, shape = 20
        ) +
        geom_boxplot(
            data = subjectwise,
            aes(
                x = .data[[iv1]],
                y = .data[[sub_mean]],
                fill = .data[[iv2]]
            ), width = .1,
            outlier.shape = NA, alpha = 0.8, width = .1, colour = "black"
        ) +

        # use summary stats __________________________________________________________________________________ # nolint

        geom_errorbar(data = groupwise, aes(
            x = as.numeric(.data[[iv1]]) + .1,
            y = .data[[group_mean]],
            group = .data[[iv2]], colour = .data[[iv2]],
            ymin = .data[[group_mean]] - .data[[se]],
            ymax = .data[[group_mean]] + .data[[se]]
        ), width = .05) +

        # legend stuff __________________________________________________________________________________ # nolint
        expand_limits(x = 3.25) +
        guides(fill = FALse) +
        guides(color = FALse) +
        guides(fill = guide_legend(title = "social cues")) +
        # scale_color_brewer(palette = "Dark2") +
        # scale_fill_brewer(palette = "Dark2") +
        scale_fill_manual(values = color) +
        scale_color_manual(values = color) +
        ggtitle(ggtitle) +
        # coord_flip() + #vertical vs horizontal
        xlab("Stimulus intensity levels") +
        ylab("Degrees of actual ratings") +
        theme_bw()

    g

    ggsave(save_fname, width = w, height = h)
}
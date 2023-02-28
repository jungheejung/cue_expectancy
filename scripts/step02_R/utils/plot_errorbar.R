plot_errorbar <- function(subjectwise, groupwise, iv, sub_iv, group_by,
                          subjectwise_mean, group_mean, se, subject,
                          ggtitle, title, xlab, ylab, taskname, ylim,
                          w, h, dv_keyword, color, level_num, save_fname) {
    library(ggplot2)
    file.sources = list.files(c("/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils"),
                          pattern="*.R", 
                          full.names=TRUE, 
                          ignore.case=TRUE)
    sapply(file.sources,source,.GlobalEnv)
    g <- ggplot(
        data = subjectwise,
        aes(
            y = .data[[subjectwise_mean]],
            x = factor(.data[[iv]]),
            fill = factor(.data[[group_by]])
        )
    ) +
        coord_cartesian(ylim = ylim, expand = TRUE) +
        geom_point(
            aes(
                x = as.numeric(factor(.data[[iv]])) - (level_num / 2) - 0.1,
                y = .data[[subjectwise_mean]],
                color = factor(.data[[group_by]])
            ),
            position = position_jitter(width = .1),
            size = 1,
            alpha = 0.3,
        ) +
        geom_errorbar(
            data = groupwise,
            aes(
                x = as.numeric(.data[[iv]]) + .1,
                y = as.numeric(.data[[group_mean]]),
                group = .data[[group_by]],
                color = factor(.data[[group_by]]),
                ymin = .data[[group_mean]] - .data[[se]],
                ymax = .data[[group_mean]] + .data[[se]]
            ),
            position = position_dodge(width = 0.3), width = 0.3, # position = 'dodge',#nolint
            alpha = 1, lwd = .7
        ) +
        geom_line(
            data = groupwise,
            aes(
                group = .data[[group_by]],
                y = as.numeric(.data[[group_mean]]),
                x = as.numeric(.data[[iv]]) + .1,
                color = factor(.data[[group_by]]),
            ),
            position = position_dodge(width = 0.2),
            linetype = "solid", alpha = 1
        ) +
        # legend stuff ________________________________________________________ # nolint
        guides(fill = guide_legend(title = title)) +
        scale_fill_manual(values = color) +
        scale_color_manual(values = color) +
        ggtitle(ggtitle) +
        xlab(xlab) +
        ylab(ylab) +
        #theme_bw() +
        theme(
            axis.line = element_line(colour = "grey50"),
            panel.background = element_blank(),
            #plot.subtitle = ggtext::element_textbox_simple(size = 11)
        )
    ggsave(save_fname, width = w, height = h)
    return(g)
}

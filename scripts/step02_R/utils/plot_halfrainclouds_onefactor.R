plot_halfrainclouds_onefactor <- function(subjectwise, groupwise, iv,
                                      subjectwise_mean, group_mean, se, subject,
                                      ggtitle, title, xlab, ylab, taskname, ylim,
                                      w, h, dv_keyword, color, save_fname) {
  g <- ggplot(
    data = subjectwise,
    aes(
      y = .data[[subjectwise_mean]],
      x = factor(.data[[iv]]),
      fill = factor(.data[[iv]])
    )
  ) +
    coord_cartesian(ylim = ylim, expand = TRUE) +
    # geom_flat_violin(
    #   aes(fill = factor(.data[[iv]])),
    #   position = position_nudge(x = .1, y = 0),
    #   adjust = 1.5, trim = FALSE, alpha = .3, colour = NA
    # ) +

    geom_half_violin(
      aes(fill = factor(.data[[iv]])),
      side = 'r',
      position = 'dodge',
      adjust = 1.5,
      trim = FALSE,
      alpha = .3,
      colour = NA
    ) +

    # geom_line(
    #   data = subjectwise,
    #   aes(
    #     group = .data[[subject]],
    #     y = .data[[subjectwise_mean]],
    #     x = as.numeric(.data[[iv]]) - .15,
    #     fill = factor(.data[[iv]])
    #   ),
    #   linetype = "solid", color = "grey", alpha = .3
    # ) +
    # geom_point(
    #   aes(
    #     x = as.numeric(.data[[iv]]) - .15,
    #     y = .data[[subjectwise_mean]],
    #     color = factor(.data[[iv]])
    #   ),
    #   position = position_jitter(width = .05),
    #   size = 1, alpha = 0.8, shape = 20
    # ) +

  geom_line(data = subjectwise,
    aes(
      group = .data[[subject]],
      x = as.numeric(as.factor(.data[[iv]])) - .15 ,
      y = .data[[subjectwise_mean]],
      fill = factor(.data[[iv]])
      ),
    linetype = "solid",
    color = "grey",
    alpha = .3) +

  geom_point(
    aes(
      # group = .data[[subject]],
      x = as.numeric(as.factor(.data[[iv]])) - .15 ,
      y = .data[[subjectwise_mean]],
      color = factor(.data[[iv]])
    ),
    position = position_jitter(width = .05),
    size = 2,
    alpha = 0.7,
  ) + 
    # geom_boxplot(
    #   aes(
    #     x = .data[[iv]],
    #     y = .data[[subjectwise_mean]],
    #     fill = .data[[iv]]
    #   ),
    #   outlier.shape = NA, alpha = 0.8, width = .1, colour = "black"
    # ) +

    geom_half_boxplot(
      data = subjectwise,
      aes(x = .data[[iv]],
          y = .data[[subjectwise_mean]],
          fill = .data[[iv]]),
      side = "r",
      outlier.shape = NA,
      alpha = 0.8,
      width = .1,
      notch = FALSE,
      notchwidth = 0,
      varwidth = FALSE,
      colour = "black",
      errorbar.draw = FALSE
    ) +

    geom_errorbar(
      data = groupwise,
      aes(
        x = as.numeric(.data[[iv]]) + .1,
        y = as.numeric(.data[[group_mean]]),
        colour = factor(.data[[iv]]),
        ymin = .data[[group_mean]] - .data[[se]],
        ymax = .data[[group_mean]] + .data[[se]]
      ), width = .05
    ) +


    # legend stuff ________________________________________________________ # nolint
    expand_limits(x = 2.8) +
    #guides(fill = "none") +
    guides(color = "none") +
    guides(fill = guide_legend(title = title)) +
    scale_fill_manual(values = color) +
    scale_color_manual(values = color) +
    ggtitle(ggtitle) +
    xlab(xlab) +
    ylab(ylab) +
    theme_bw()
  ggsave(save_fname, width = w, height = h)
  return(g)
}

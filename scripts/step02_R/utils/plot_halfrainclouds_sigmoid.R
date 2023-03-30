plot_halfrainclouds_sigmoid <- function(subjectwise, groupwise, iv,sub_iv,
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

    geom_half_violin(
      aes(fill = factor(.data[[iv]])),
      side = 'r',
      #position = 'dodge',
      adjust = 0.5,
      trim = FALSE,
      alpha = .5,
      colour = NA
    ) +

  geom_point(
    aes(
      # group = .data[[subject]],
      x = as.numeric(as.factor(.data[[iv]])) - .1 ,
      y = .data[[subjectwise_mean]],
      color = factor(.data[[iv]])
    ),
    position = position_jitter(width = .05),
    size = 2,
    alpha = 0.7,
  ) + 

    geom_errorbar(
      data = groupwise,
      aes(
        x = as.numeric(.data[[sub_iv]]) + .1 ,
        y = as.numeric(.data[[group_mean]]),
        color = factor(.data[[iv]]),
        ymin = .data[[group_mean]] - .data[[se]],
        ymax = .data[[group_mean]] + .data[[se]]
      ),
      position = position_dodge(width=0.1), width=0.1 ,   # position = 'dodge',
      alpha = 1
    ) +
geom_line(
  data = groupwise,
  aes(
    #group = .data[[subject]],
    group = 1,
    y = as.numeric(.data[[group_mean]]),
    x = as.numeric(.data[[sub_iv]]) + .1 ,
    # fill = factor(.data[[iv]])
  ),
  linetype = "solid", color = "#C97482", alpha = 1
) +

    # legend stuff ________________________________________________________ # nolint
    #expand_limits(x = 2.8) +
    #guides(fill = "none") +
    guides(color = "none") +
    guides(fill = guide_legend(title = title)) +
    scale_fill_manual(values = color) +
    scale_color_manual(values = color) +
    ggtitle(ggtitle) +
    xlab(xlab) +
    ylab(ylab) +
    theme(
            axis.line = element_line(colour = "grey50"),
            panel.background = element_blank(),
            #plot.subtitle = ggtext::element_textbox_simple(size = 11)
        )
  ggsave(save_fname, width = w, height = h)
  return(g)
}
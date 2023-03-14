# summarize dataframe __________________________________________________________
plot_twovariable <- function(df, iv1, iv2, group, subject, min, max, xlab, ylab, ggtitle, color_scheme, alpha, fit_lm) {
    # x: iv1 e.g. expect rating
    # y: iv2 e.g. outcome rating
    # group: param_cue_type
    # subject: src_subject_id
    # xlab("expect rating") +
    # ylab("outcome rating") +
    # color_scheme = c("high_cue" = "#000000",low_cue" = "#BBBBBB"        )
    library(ggplot2)

    df_dropna <- df[!is.na(df[, iv1]) & !is.na(df[, iv2]), ]
    subjectwise_2dv <- meanSummary_2dv(
        df_dropna,
        c(subject, group),
        iv1, iv2
    )
    subjectwise_naomit_2dv <- na.omit(subjectwise_2dv)
    subjectwise_naomit_2dv[ , group] <- as.factor(subjectwise_naomit_2dv[, group])
    # plot _________________________________________________________________________ #nolint

    g <- ggplot(
        data = subjectwise_naomit_2dv,
        aes(
            x = .data[["DV1_mean_per_sub"]],
            y = .data[["DV2_mean_per_sub"]],
            color = .data[[group]]
        )
    ) +
        geom_point(
            aes(shape = .data[[group]],
            color = .data[[group]]),
            size = 2,
            alpha = alpha) +
        geom_abline(
            intercept = 0, slope = 1, color = "green",
            linetype = "dashed", linewidth = 0.5
        ) +
        theme(aspect.ratio = 1) +
        scale_color_manual(values = color_scheme) +
        scale_shape_manual(values = c(16, 17)) +
        xlab(xlab) +
        ylab(ylab) +
        ylim(min,max) +
        xlim(min,max) +
        ggtitle(ggtitle) +
        theme(
            axis.line = element_line(colour = "grey50"),
            panel.background = element_blank(),
            plot.subtitle = ggtext::element_textbox_simple(size = 11)
        )


    if (isTRUE(fit_lm)) {
        g <- g +
        geom_ribbon(stat = "smooth", method = "lm", se = TRUE, alpha = 0.1,
              aes(color = NULL, group = factor(group))) +
        geom_line(stat = "smooth", method = "lm", alpha = 0.8, size = 1.5)
    } else {
        g
    }
    return(g)
}

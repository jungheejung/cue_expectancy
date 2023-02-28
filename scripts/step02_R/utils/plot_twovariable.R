# summarize dataframe __________________________________________________________
iv1 <- "event02_expect_angle"
iv2 <- "event04_actual_angle"

plot_twovariable <- function(df, iv1, iv2) {
    df_dropna <- df[!is.na(df[, iv1]) & !is.na(df[, iv2]), ]
    subjectwise_2dv <- meanSummary_2dv(
        df_dropna,
        c("src_subject_id", "param_cue_type"),
        iv1, iv2
    )
    subjectwise_naomit_2dv <- na.omit(subjectwise_2dv)
    subjectwise_naomit_2dv$param_cue_type <- as.factor(subjectwise_naomit_2dv$param_cue_type)
    # plot _________________________________________________________________________ #nolint
    g <- ggplot(
        data = subjectwise_naomit_2dv,
        aes(
            x = DV1_mean_per_sub,
            y = DV2_mean_per_sub,
            color = param_cue_type
        )
    ) +
        geom_point(aes(shape = param_cue_type, color = param_cue_type), size = 2, alpha = .8) +
        geom_abline(
            intercept = 0, slope = 1, color = "green",
            linetype = "dashed", size = 0.5
        ) +
        theme(aspect.ratio = 1) +
        scale_color_manual(values = c(
            "high_cue" = "#000000",
            "low_cue" = "#BBBBBB"
        )) +
        scale_shape_manual(values = c(16, 17)) +
        xlab("expect rating") +
        ylab("outcome rating") +
        ylim(0, 180) +
        xlim(0, 180) +
        theme(
            axis.line = element_line(colour = "grey50"),
            panel.background = element_blank(),
            plot.subtitle = ggtext::element_textbox_simple(size = 11)
        )

    return(g)
}

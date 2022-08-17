subject_varkey <- "src_subject_id"
iv <- "param_cue_type"
dv <- "event04_actual_angle"
dv_keyword <- "actual"
subject <- "subject"
exclude <- ""
w <- 10
h <- 6

analysis_dir <- file.path(main_dir, "analysis", "mixedeffect", "model01_cue_expectrating_02-2022")

# [ CONTRASTS ]  ----------------------------------------------------------------------------
# DATA = cue_stim_contrast(DATA)
# STIMC1 = "stim_con_linear"
# STIMC2 = "stim_con_quad"

for (taskname in c("pain", "vicarious", "cognitive")) {
    # [ MODEL ] ----------------------------------------------------------------------------
    model_fname <- file.path(
        analysis_dir,
        paste("lmer_task-", taskname,
            "_cue_on_rating-", dv_keyword,
            "_", as.character(Sys.Date()), ".txt",
            sep = ""
        )
    )
    data <- load_task_social_df(taskname, subject_varkey, iv, dv, exclude)
    data$subject <- factor(data$src_subject_id)
    cooksd <- lmer_onefactor_cooksd(
        data, taskname, iv, dv, subject, dv_keyword, model_savefname
    )
    influential <- as.numeric(names(cooksd)[
        (cooksd > (4 / as.numeric(length(unique(data$subject)))))
    ])
    data_screen <- data[-influential, ]
    subjectwise <- meanSummary(data_screen, c(subject, iv), dv)
    groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = "mean_per_sub", # variable created from above
        withinvars = c(iv), # iv
        idvar = "subject"
    )

    if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color <- c("#1B9E77", "#D95F02")
    } else {
        color <- c("#4575B4", "#D73027")
    }
    xlab <- ""
    ylab <- "judgment (degree)"
    ggtitle <- paste(taskname, " - actual judgment (degree)")
    title <- paste(taskname, " - actual")
    subject_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    se <- "se"
    subject <- "subject"
    save_fname <- file.path(
        analysis_dir,
        paste("raincloudplots_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), ".png",
            sep = ""
        )
    )
    plot_expect_rainclouds(subjectwise, groupwise, iv, subject_mean, group_mean, se, subject, ggtitle, title, xlab, ylab, taskname, w, h, dv_keyword, color, save_fname)
}
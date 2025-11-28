# parameters
subject_varkey <- "src_subject_id"
iv <- "param_cue_type"
dv <- "event02_expect_angle"
dv_keyword <- "expect"
xlab <- ""
ylab <- "ratings (degree)"
subject <- "subject"
exclude <- ""

analysis_dir <- file.path(main_dir, "analysis", "mixedeffect", "model01_cue_expectrating_02-2022")

for (taskname in c("pain", "vicarious", "cognitive")) {
    save_fname <- file.path(
        analysis_dir,
        paste("lmer_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), ".txt",
            sep = ""
        )
    )
    data <- expect_df(taskname, subject_varkey, iv, dv, exclude)
    cooksd <- lmer_onefactor_cooksd(
        data, taskname, iv, dv, subject, dv_keyword, save_fname
    )
    influential <- as.numeric(names(cooksd)[ß
    (cooksd > (4 / as.numeric(length(unique(data$src_subject_id)))))])
    data_screen <- data[-influential, ]

    subjectwise <- meanSummary(data, c(subject, iv), dv)
    groupwise <- summarysewithin(
        data = subjectwise,
        measurevar = "mean_per_sub", # variable created from above
        withinvars = c(iv), # iv
        idvar = "subject"
    )

    subjectwise_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    se <- "se"
    subject <- "subject"
    ggtitle <- paste(taskname, " - Expectation Rating (degree)")
    title <- paste(taskname, " - Expect")
    xlab <- ""
    ylab <- "ratings (degree)"
    dv_keyword <- "expect"
    if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color <- c("#1B9E77", "#D95F02")
    } else {
        color <- c("#4274AD", "#C5263A")
    }
    save_fname <- file.path(
        analysis_dir,
        paste("raincloudpoint_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), ".png",
            sep = ""
        )
    )
    plot_expect_rainclouds(
        subjectwise, groupwise,
        iv, subjectwise_mean, group_mean, se, subject,
        ggtitle, title, xlab, ylab, task_name,
        w, h, dv_keyword, color, save_fname
    )
}
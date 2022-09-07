# common dir for saving plots and model outputs
analysis_dir <- file.path(
    main_dir, "analysis",
    "mixedeffect", "model05_cue_actualrating_contrast"
)
dir.create(analysis_dir, showWarnings = FALSE)

for (taskname in c("pain", "vicarious", "cognitive")) {
    subject_varkey <- "src_subject_id"
    iv <- "param_stimulus_type"
    dv <- "event04_actual_angle"
    dv_keyword <- "actual"
    subject <- "subject"
    exclude <- ""
    w <- 10
    h <- 6
    model_fname <- file.path(
        analysis_dir,
        paste("lmer_task-", taskname, "_cue_on_rating-", dv_keyword, "_",
            as.character(Sys.Date()), ".txt",
            sep = ""
        )
    )
    # ___ 1) load data _______________________________________________________________ # nolint
    data <- expect_df(taskname, subject_varkey, iv, dv, exclude)
    unique(data$src_subject_id)
    data$subject <- factor(data$src_subject_id)
    modeliv1 <- "stim_ordered"
    modeliv2 <- "cue_ordered"

    # ___ 2) mixed effects model _____________________________________________________ # nolint
    cooksd <- lmer_onefactor_cooksd(
        data, taskname, iv, dv, subject, dv_keyword, model_savefname
    )
    influential <- as.numeric(names(cooksd)[
        (cooksd > (4 / as.numeric(length(unique(data$subject)))))
    ])
    data_screen <- data[-influential, ]

    # ___ 3) calculate difference scores and summarize _______________________________ # nolint
    # TODO: within param_run_num
    data$run_order[data$param_run_num > 3] <- "a"
    data$run_order[data$param_run_num <= 3] <- "b"
    sub_diff <- subset(data, select = c(
        "subject", "session_id", "run_order",
        "param_task_name", "param_cue_type",
        "param_stimulus_type", dv
    ))
    subjectwise <- meanSummary(sub_diff, c(
        "subject", "session_id", "run_order",
        "param_task_name", "param_cue_type",
        "param_stimulus_type"
    ), dv)
    mean_actual <- subjectwise[1:(length(subjectwise) - 1)]
    wide <- mean_actual %>%
        spread(param_cue_type, mean_per_sub)
    wide$diff <- wide$high_cue - wide$low_cue
    wide$stim_name[wide$param_stimulus_type == "high_stim"] <- "high"
    wide$stim_name[wide$param_stimulus_type == "med_stim"] <- "med"
    wide$stim_name[wide$param_stimulus_type == "low_stim"] <- "low"
    wide$stim_ordered <- factor(wide$stim_name,
        levels = c("low", "med", "high")
    )

    subjectwise_diff <- meanSummary(wide, c("subject", "stim_ordered"), "diff")
    subjectwise_diff$stim_ordered <- factor(subjectwise_diff$stim_ordered,
        levels = c("low", "med", "high")
    )
    groupwise_diff <- summarySEwithin(
        data = subjectwise_diff,
        measurevar = "mean_per_sub", # variable created from above
        withinvars = c("stim_ordered"), # iv
        idvar = "subject"
    )


    # ___ 4) plot ____________________________________________________________________  # nolint
    # 4-1. parameters ______________________________________________________________ # nolint
    subjectwise <- subjectwise_diff
    groupwise <- groupwise_diff
    iv <- "stim_ordered"
    subject_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    p1.se <- "se"
    subject <- "subject"
    if (any(startsWith(taskname, c("pain", "Pain")))) { # red
        color <- c("#B7021E", "#B7021E", "#B7021E")
    } else if (any(startsWith(taskname, c("vicarious", "Vicarious")))) { # green
        color <- c("#22834A", "#22834A", "#22834A")
    } else if (any(startsWith(taskname, c("cognitive", "Cognitive")))) { # blue
        color <- c("#0237C9", "#0237C9", "#0237C9")
    }

    # 4-2. plot rain cloud plots ____________________________________________________ # nolint
    p1.xlab <- ""
    p1.ylab <- "Cue effect \n(actual ratings of high > low cue)"
    p1.ggtitle <- paste(taskname, " - actual judgment (degree)")
    p1.title <- paste(taskname, " - actual")
    p1.save_fname <- file.path(
        analysis_dir,
        paste("socialinfluence_task-", taskname, "_rating-",
            dv_keyword, "-diff_", as.character(Sys.Date()), ".png",
            sep = ""
        )
    )
    g <- plot_rainclouds_onefactor(
        subjectwise, groupwise, iv, subject_mean, group_mean, p1.se,
        subject, p1.ggtitle, p1.title, p1.xlab, p1.ylab, taskname,
        w, h, dv_keyword, color, p1.save_fname
    )
    g <- g + geom_hline(yintercept = 0, size = 0.5, linetype = "dashed")
    ggsave(p1.save_fname, plot = g)

    # 4-3.  plot geom range _________________________________________________________ # nolint
    p2.se <- "sd" # se, sd, ci
    p2.xlab <- "stimulus intensity"
    p2.ylab <- "Cue effect \n(actual ratings of high > low cue)"
    p2.ggtitle <- paste(taskname, " - cue effect per stimulus intensity", sep = "")
    w <- 5
    h <- 5
    p2.save_fname <- file.path(
        analysis_dir,
        paste("cueeffect_task-", taskname, "_rating-", dv_keyword, "_",
            as.character(Sys.Date()), ".png",
            sep = ""
        )
    )
    r <- plot_geom_pointrange(
        subjectwise, groupwise, iv,
        subject_mean, group_mean, p2.se,
        p2.xlab, p2.ylab, color, p2.ggtitle, W, H, p2.save_fname
    )
    r <- r + geom_hline(yintercept = 0, size = 1, linetype = "dashed")
    ggsave(p2.save_fname, plot = r)
}


combined_se_calc_cooksd <- data.frame()
# 1. [ PARAMETERS ]  __________________________________________________ # nolint
dv_keyword <- "actual"
xlab <- ""
ylab <- "judgment (degree)"
for (taskname in c("pain", "vicarious", "cognitive")) {
    ggtitle <- paste(taskname, " - actual judgment (degree)")
    title <- paste(taskname, " - actual")
    subject <- "subject"

    data <- load_task_social_df(
        taskname = taskname,
        subject_varkey = "src_subject_id",
        iv = "param_cue_type",
        dv = "event04_actual_angle",
        exclude = "sub-0001|sub-0003|sub-0004|sub-0005|sub-0025|sub-0999"
    )
    analysis_dir <- file.path(
        main_dir,
        "analysis", "mixedeffect", "model04_iv-cue-stim_dv-actual"
    )

    w <- 10
    h <- 6

    # [ CONTRASTS ]  ________________________________________________________________________________ # nolint
    # contrast code ________________________________________
    data$stim[data$event03_stimulus_type == "low_stim"] <- -0.5 # social influence task
    data$stim[data$event03_stimulus_type == "med_stim"] <- 0 # no influence task
    data$stim[data$event03_stimulus_type == "high_stim"] <- 0.5 # no influence task

    data$stim_factor <- factor(data$event03_stimulus_type)

    # contrast code 1 linear
    data$stim_con_linear[data$event03_stimulus_type == "low_stim"] <- -0.5
    data$stim_con_linear[data$event03_stimulus_type == "med_stim"] <- 0
    data$stim_con_linear[data$event03_stimulus_type == "high_stim"] <- 0.5

    # contrast code 2 quadratic
    data$stim_con_quad[data$event03_stimulus_type == "low_stim"] <- -0.33
    data$stim_con_quad[data$event03_stimulus_type == "med_stim"] <- 0.66
    data$stim_con_quad[data$event03_stimulus_type == "high_stim"] <- -0.33

    # social cude contrast
    data$social_cue[data$param_cue_type == "low_cue"] <- -0.5 # social influence task
    data$social_cue[data$param_cue_type == "high_cue"] <- 0.5 # no influence task


    stim_con1 <- "stim_con_linear"
    stim_con2 <- "stim_con_quad"
    iv1 <- "social_cue"
    dv <- "event04_actual_angle"

    # [ MODEL ] _________________________________________________ # nolint
    model_savefname <- file.path(
        analysis_dir,
        paste("lmer_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), "_cooksd.txt",
            sep = ""
        )
    )
    cooksd <- run_cue_stim_lmer(
        data, taskname, iv1, stim_con1, stim_con2, dv,
        subject, dv_keyword, model_savefname
    )
    influential <- as.numeric(names(cooksd)[
        (cooksd > (4 / as.numeric(length(unique(data$src_subject_id)))))
    ])
    data_screen <- data[-influential, ]
    # [ PLOT ] reordering for plots _________________________ # nolint
    data_screen$cue_name[data_screen$param_cue_type == "high_cue"] <- "high cue"
    data_screen$cue_name[data_screen$param_cue_type == "low_cue"] <- "low cue"

    data_screen$stim_name[data_screen$param_stimulus_type == "high_stim"] <- "high"
    data_screen$stim_name[data_screen$param_stimulus_type == "med_stim"] <- "med"
    data_screen$stim_name[data_screen$param_stimulus_type == "low_stim"] <- "low"

    # DATA$levels_ordered <- factor(DATA$param_stimulus_type, levels=c("low", "med", "high"))

    data_screen$stim_ordered <- factor(
        data_screen$stim_name,
        levels = c("low", "med", "high")
    )
    data_screen$cue_ordered <- factor(
        data_screen$cue_name,
        levels = c("low cue", "high cue")
    )
    model_iv1 <- "stim_ordered"
    model_iv2 <- "cue_ordered"

    #  [ PLOT ] calculate mean and se  _________________________
    actual_subjectwise <- meanSummary(
        data_screen,
        c(subject, model_iv1, model_iv2), dv
    )
    actual_groupwise <- summarySEwithin(
        data = actual_subjectwise,
        measurevar = "mean_per_sub",
        withinvars = c(model_iv1, model_iv2), idvar = subject
    )
    actual_groupwise$task <- taskname
    # https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402
    combined_se_calc_cooksd <- rbind(combined_se_calc_cooksd, actual_groupwise)
    # if(any(startsWith(dv_keyword, c("expect", "Expect")))){color = c( "#1B9E77", "#D95F02")}else{color=c( "#4575B4", "#D73027")} # if keyword starts with
    # print("groupwisemean")
    #  [ PLOT ] calculate mean and se  ----------------------------------------------------------------------------
    sub_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    se <- "se"
    subject <- "subject"
    ggtitle <- paste(taskname, " - Actual Rating (degree) Cooksd removed")
    title <- paste(taskname, " - Actual")
    xlab <- ""
    ylab <- "ratings (degree)"
    dv_keyword <- "actual"
    if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color <- c("#1B9E77", "#D95F02")
    } else {
        color <- c("#4575B4", "#D73027")
    } # if keyword starts with
    plot_savefname <- file.path(
        analysis_dir,
        paste("socialinfluence_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), "_cooksd.png",
            sep = ""
        )
    )
    plot_actual_rainclouds(
        actual_subjectwise, actual_groupwise, model_iv1, model_iv2,
        sub_mean, group_mean, se, subject,
        ggtitle, title, xlab, ylab, taskname,
        w, h, dv_keyword, color, plot_savefname
    )


    # save fixed random effects _______________________________
    randEffect$newcoef <- mapvalues(randEffect$term,
        from = c("(Intercept)", "data[, iv]low_cue", "DATA[, stim_con1]", "DATA[, stim_con2]", "DATA[, IV]low_cue:DATA[, stim_con1]", "DATA[, IV]low_cue:DATA[, stim_con2]"),
        to = c("rand_intercept", "rand_cue", "rand_stimulus_linear", "rand_stimulus_quad", "rand_int_cue_stimlin", "rand_int_cue_stimquad")
    )

    #
    # # The arguments to spread():
    # # - data: Data object
    # # - key: Name of column containing the new column names
    # # - value: Name of column containing values
    #
    # # TODO: add fixed effects
    #
    rand_subset <- subset(randEffect, select = -c(grpvar, term, condsd))
    wide_rand <- spread(rand_subset, key = newcoef, value = condval)
    wide_fix <- do.call(
        "rbind",
        replicate(nrow(wide_rand), as.data.frame(t(as.matrix(fixEffect))),
            simplify = FALSE
        )
    )
    rownames(wide_fix) <- NULL
    new_wide_fix <- dplyr::rename(wide_fix,
        fix_intercept = `(Intercept)`, fix_cue = `DATA[, IV]low_cue`,
        fix_stimulus_linear = `DATA[, stim_con1]`,
        fix_stimulus_quad = `DATA[, stim_con2]`, fix_int_cue_stimlin = `DATA[, IV]low_cue:DATA[, stim_con1]`,
        fix_int_cue_stimquad = `DATA[, IV]low_cue:DATA[, stim_con2]`
    )

    total <- cbind(wide_rand, new_wide_fix)
    total$task <- taskname
    new_total <- total %>% dplyr::select(task, everything())
    new_total <- dplyr::rename(total, subj = grp)

    plot_savefname <- file.path(analysis_dir, paste("task-", taskname, "_", as.character(Sys.Date()), "_cooksd.csv", sep = ""))
    write.csv(new_total, plot_savefname, row.names = FALSE)
}
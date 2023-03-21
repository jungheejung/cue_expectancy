# outcome_rating ~ cue * stim {#ch05_outcome-cueXstim}

## What is the purpose of this notebook? 
Here, I plot the outcome ratings as a function of cue and stimulus intensity. 
* Main model: `lmer(outcome_rating ~ cue * stim)` 
* Main question: do outcome ratings differ as a function of cue type and stimulus intensity? 
* If there is a main effect of cue on outcome ratings, does this cue effect differ depending on task type?
* Is there an interaction between the two factors?
* IV: 
  - cue (high / low)
  - stim (high / med / low)
* DV: outcome rating





## model 03 iv-cuecontrast dv-actual

```r
## common dir for saving plots and model outputs
analysis_dir <- file.path(
    main_dir, "analysis",
    "mixedeffect", "model04_iv-cuecontrast_dv-outcome", as.character(Sys.Date()))
dir.create(analysis_dir, recursive = TRUE, showWarnings = FALSE)

for (taskname in c("pain", "vicarious", "cognitive")) {
    subject_varkey <- "src_subject_id"
    iv <- "param_cue_type"; iv_keyword <- "cue"
    dv <- "event04_actual_angle"
    dv_keyword <- "actual"
    subject <- "subject"
    xlab <- ""
    ylab <- "ratings (degree)"
    exclude <- "sub-0001|sub-0003|sub-0004|sub-0005|sub-0025|sub-0999"
    w <- 10
    h <- 6
    model_savefname <- file.path(
        analysis_dir,
        paste("lmer_task-", taskname, "_cue_on_rating-", dv_keyword, "_",
            as.character(Sys.Date()), ".txt",
            sep = ""
        )
    )
    # ___ 1) load data _______________________________________________________________ # nolint
    data <- load_task_social_df(datadir, taskname, subject_varkey, iv, dv, exclude)
    unique(data$src_subject_id)
    data$subject <- factor(data$src_subject_id)

    # ___ 2) mixed effects model _____________________________________________________ # nolint
    cooksd <- lmer_onefactor_cooksd(
        df = data, taskname, iv, dv, subject_keyword = subject, dv_keyword, model_savefname, print_lmer_output=FALSE
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
    ylim <- c()
    p1.ggtitle <- paste(taskname, " - actual judgment (degree)")
    p1.title <- paste(taskname, " - actual")
    p1.save_fname <- file.path(
        analysis_dir,
        paste("raincloud_task-", taskname, "_rating-",
            dv_keyword, "-cuecontrast_", as.character(Sys.Date()), ".png",
            sep = ""
        )
    )
    dv_keyword = "cuecontrast"
    ylim = c(-75,75)
    g <- plot_rainclouds_onefactor(
        subjectwise, groupwise, iv, subject_mean, group_mean, p1.se,
        subject, p1.ggtitle, p1.title, p1.xlab, p1.ylab, taskname, ylim,
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
    r <- plot_geompointrange_onefactor(
        subjectwise, groupwise, iv,
        subject_mean, group_mean, p2.se,
        p2.xlab, p2.ylab, color, p2.ggtitle, w, h, p2.save_fname
    )
    r <- r + geom_hline(yintercept = 0, size = 1, linetype = "dashed")
    ggsave(p2.save_fname, plot = r)
}
```

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], y
## = .data[[subjectwise_mean]], : Ignoring unknown aesthetics: fill
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_ydensity()`).
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_boxplot()`).
```

```
## Warning: Using the `size` aesthietic with geom_polygon was deprecated in ggplot2 3.4.0.
## ℹ Please use the `linewidth` aesthetic instead.
```

```
## Warning: Removed 1 row containing missing values (`geom_line()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## ℹ Please use `linewidth` instead.
```

```
## Saving 7 x 5 in image
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_ydensity()`).
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_boxplot()`).
```

```
## Warning: Removed 1 row containing missing values (`geom_line()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: The `<scale>` argument of `guides()` cannot be `FALSE`. Use "none" instead as
## of ggplot2 3.3.4.
```

```
## Saving 7 x 5 in image
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 3 rows containing missing values (`geom_pointrange()`).
```

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], y
## = .data[[subjectwise_mean]], : Ignoring unknown aesthetics: fill
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_ydensity()`).
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_boxplot()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Saving 7 x 5 in image
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_ydensity()`).
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_boxplot()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Saving 7 x 5 in image
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 3 rows containing missing values (`geom_pointrange()`).
```

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], y
## = .data[[subjectwise_mean]], : Ignoring unknown aesthetics: fill
```

```
## Saving 7 x 5 in image
## Saving 7 x 5 in image
```

### model 03 3-2. individual difference



### model 04 iv-cue-stim dv-actual









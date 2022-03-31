randEffect$newcoef <- mapvalues(randEffect$term,
    from = c("(Intercept)", "data[, iv]low_cue", "data[, stimc1]", "data[, stimc2]", "data[, iv]low_cue:data[, stimc1]", "data[, iv]low_cue:data[, stimc2]"),
    to = c("rand_intercept", "rand_cue", "rand_stimulus_linear", "rand_stimulus_quad", "rand_int_cue_stimlin", "rand_int_cue_stimquad")
)

# # The arguments to spread():
# # - data: data object
# # - key: Name of column containing the new column names
# # - value: Name of column containing values
#
# # TODO: add fixed effects
#
rand_subset <- subset(randEffect, select = -c(grpvar, term, condsd))
wide_rand <- spread(rand_subset, key = newcoef, value = condval)

wide_fix <- do.call(
    "rbind",
    replicate(nrow(wide_rand),
        as.data.frame(t(as.matrix(fixEffect))),
        simplify = FALSE
    )
)
rownames(wide_fix) <- NULL
new_wide_fix <- dplyr::rename(wide_fix,
    fix_intercept = `(Intercept)`,
    fix_cue = `data[, iv]low_cue`,
    fix_stimulus_linear = `data[, stimc1]`,
    fix_stimulus_quad = `data[, stimc2]`,
    fix_int_cue_stimlin = `data[, iv]low_cue:data[, stimc1]`,
    fix_int_cue_stimquad = `data[, iv]low_cue:data[, stimc2]`
)

total <- cbind(wide_rand, new_wide_fix)
total$task <- TASKNAME
new_total <- total %>% dplyr::select(task, everything())
new_total <- dplyr::rename(total, subj = grp)

save_fname <- file.path(
    analysis_dir,
    paste("task-", TASKNAME, "_",
        as.character(Sys.Date()), "_cooksd.csv",
        sep = ""
    )
)
write.csv(new_total, save_fname, row.names = FALSE)




# load concatenated mixed effect coefficients
# stack task- .csv
dfP <- read.csv(file.path(
    analysis_dir,
    paste("task-pain", "_", as.character(Sys.Date()), ".csv", sep = "")
))
dfV <- read.csv(file.path(
    analysis_dir,
    paste("task-vicarious", "_", as.character(Sys.Date()), ".csv", sep = "")
))
dfC <- read.csv(file.path(
    analysis_dir,
    paste("task-cognitive", "_", as.character(Sys.Date()), ".csv", sep = "")
))

pvc <- merge_recurse(list(dfP, dfV, dfC))

save_fname <- file.path(
    analysis_dir,
    paste("pvc_mixedeffect_coef", "_",
        as.character(Sys.Date()), ".csv",
        sep = ""
    )
)
write.csv(pvc, save_fname, row.names = FALSE)

# plot separately
pvc_rand_cue_subset <- subset(pvc, select = c(task, subj, rand_cue))
pvc_rand_cue <- spread(pvc_rand_cue_subset, key = task, value = rand_cue)
pv <- ggplot(
    data = pvc_rand_cue,
    aes(x = vicarious, y = pain),
    cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5
) +
    geom_point() +
    theme_classic() +
    theme(aspect.ratio = 1) +
    stat_cor(
        p.accuracy = 0.001,
        r.accuracy = 0.01,
        method = "pearson",
        label.y = 14
    ) +
    xlim(-15, 15) +
    ylim(-15, 15)
vc <- ggplot(
    data = pvc_rand_cue,
    aes(x = cognitive, y = vicarious),
    cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5
) +
    geom_point() +
    theme_classic() +
    theme(aspect.ratio = 1) +
    stat_cor(
        p.accuracy = 0.001,
        r.accuracy = 0.01,
        method = "pearson",
        label.y = 14
    ) +
    xlim(-15, 15) +
    ylim(-15, 15)
cp <- ggplot(
    data = pvc_rand_cue,
    aes(x = pain, y = cognitive),
    cex.lab = 1.5, cex.axis = 2, cex.main = 1.5, cex.sub = 1.5
) +
    geom_point() +
    theme_classic() +
    theme(aspect.ratio = 1) +
    stat_cor(
        p.accuracy = 0.001,
        r.accuracy = 0.01,
        method = "pearson",
        label.y = 14
    ) +
    xlim(-15, 15) +
    ylim(-15, 15)
ggpubr::ggarrange(pv, vc, cp, ncol = 3, nrow = 1, common.legend = FALSE, legend = "bottom")
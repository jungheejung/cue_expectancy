plot_signature_twofactor <- function(signature_key, plot_keys, df) {
    # feed in signature keyword # signature_key = "NPSpos"

file.sources = list.files(c("/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils"),
                          pattern="*.R", 
                          full.names=TRUE, 
                          ignore.case=TRUE)
sapply(file.sources,source,.GlobalEnv)
    
    groupwise <- data.frame()
    subjectwise <- data.frame()
    summary <- summary_for_plots_PVC(
        df = df,
        # taskname = taskname,
        groupwise_measurevar = plot_keys$sub_mean, # "mean_per_sub",
        subject_keyword = plot_keys$subject, # "sub",
        model_iv1 = plot_keys$iv1, # "task",
        model_iv2 = plot_keys$iv2, # "stim_ordered",
        dv = plot_keys$dv #"NPSpos"
    )
    subjectwise <<- as.data.frame(summary[[1]])
    groupwise <<- as.data.frame(summary[[2]])
    if (any(startsWith(plot_keys$dv_keyword, c("expect", "Expect")))) {
        plot_keys$color <- c("#1B9E77", "#D95F02", "#D95F02")
    } else {
        plot_keys$color <- c("#4575B4", "#FFA500", "#D73027")
    }
    p <- plot_halfrainclouds_twofactor(
        subjectwise, groupwise, iv1 = plot_keys$iv1, iv2 = plot_keys$iv2,sub_mean = plot_keys$sub_mean, group_mean = plot_keys$group_mean, se = plot_keys$se, subject = plot_keys$sub,
        ggtitle = plot_keys$ggtitle, title = plot_keys$title, xlab = plot_keys$xlab, ylab = plot_keys$ylab, task_name = plot_keys$taskname, ylim = plot_keys$ylim,
        w = plot_keys$w, h = plot_keys$h, dv_keyword = plot_keys$dv_keyword, color = plot_keys$color, save_fname = plot_keys$plot_savefname
    )
    return(p)
}

summary_for_plots_PVC <- function(df, groupwise_measurevar, subject_keyword, model_iv1, model_iv2, dv) {
    #  [ PLOT ] calculate mean and se  _________________________
    subjectwise <- meanSummary(
        df,
        c(subject_keyword, model_iv1, model_iv2), dv
    )
    groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = groupwise_measurevar,
        withinvars = c(model_iv1, model_iv2), idvar = subject_keyword
    )

    return(list(subjectwise,groupwise))
}
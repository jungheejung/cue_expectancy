plot_signature_tworaincloud <- function(signature_key = NULL, plot_keys = NULL, df = NULL) {
    # feed in signature keyword # signature_key = "NPSpos"

    file.sources = list.files(c("/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils"),
                            pattern="*.R", 
                            full.names=TRUE, 
                            ignore.case=TRUE)
    sapply(file.sources,source,.GlobalEnv)
    
    # summry statistics
    groupwise <- data.frame()
    subjectwise <- data.frame()
    summary <- summaryplotPVC(
        df,
        groupwise_measurevar = plot_keys$sub_mean, # "mean_per_sub",
        subject_keyword = plot_keys$sub, # "sub",
        model_iv1 = plot_keys$iv1, # "task",
        model_iv2 = plot_keys$iv2, # "stim_ordered",
        dv = plot_keys$dv #"NPSpos"
    )
    subjectwise <<- as.data.frame(summary[[1]])
    groupwise <<- as.data.frame(summary[[2]])

    # plot
    p <- plot_halfrainclouds_twofactor(
        summary[[1]], summary[[2]], iv1 = plot_keys$iv1, iv2 = plot_keys$iv2,sub_mean = plot_keys$sub_mean, group_mean = plot_keys$group_mean, se = plot_keys$error, subject = plot_keys$sub,
        ggtitle = plot_keys$ggtitle, legend_title = plot_keys$legend_title, xlab = plot_keys$xlab, ylab = plot_keys$ylab, task_name = plot_keys$taskname, ylim = plot_keys$ylim,
        w = plot_keys$w, h = plot_keys$h, dv_keyword = plot_keys$dv_keyword, color = plot_keys$color, save_fname = plot_keys$save_fname
    )
    return(p)
}


plot_signature_twolineplot <- function(signature_key = NULL, plot_keys = NULL, df = NULL) {
    # feed in signature keyword # signature_key = "NPSpos"

    file.sources = list.files(c("/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils"),
                            pattern="*.R", 
                            full.names=TRUE, 
                            ignore.case=TRUE)
    sapply(file.sources,source,.GlobalEnv)
    
    groupwise <- data.frame()
    subjectwise <- data.frame()
    print(plot_keys$iv1)
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

p <- plot_lineplot_twofactor(summary[[2]],
    iv1 = plot_keys$iv1,
    iv2 = plot_keys$iv2,
    mean = plot_keys$group_mean,
    error = plot_keys$error,
    color = plot_keys$color,
    ggtitle = plot_keys$ggtitle,
    xlab = plot_keys$xlab, ylab = plot_keys$ylab)
 return(p)
                      }
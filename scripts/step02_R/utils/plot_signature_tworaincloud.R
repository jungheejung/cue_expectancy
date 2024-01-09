#' Plot Signature with Two-Factor Raincloud Plots
#'
#' This function creates raincloud plots for a specified signature key with data
#' grouped by two factors. It first computes summary statistics and then uses these
#' to generate the plots.
#'
#' @param signature_key (Optional) A key or identifier for the signature being plotted.
#' @param plot_keys A list of keys specifying the plotting parameters and variables to be used.
#'   This includes variables for mean per subject, subject identification, independent
#'   variables, dependent variable, plot titles, labels, and other plotting parameters.
#'   
#'   Important keys include:
#'   - `sub_mean`: Mean value per subject.
#'   - `iv1`: First independent variable.
#'   - `iv2`: Second independent variable.
#'   - `dv`: Dependent variable.
#'   - `ggtitle`: Title for the plot.
#'   (additional keys can be found in the documentation for `plot_halfrainclouds_twofactor`)
#'   
#' @param df A dataframe containing the data to be plotted.
#'
#' @return A ggplot object representing the two-factor raincloud plot.
#'
#' @examples
#' # Assuming appropriate data and plot_keys
#' # p <- plot_signature_tworaincloud(signature_key = "signature1",
#' #                                  plot_keys = list_of_keys, df = mydata)
#'
#' @export

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
    summary <- compute_summary_twofactor(
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


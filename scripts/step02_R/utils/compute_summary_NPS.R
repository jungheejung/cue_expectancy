#' Summarize NPS extraction data for Plotting
#'
#' This function preprocesses and summarizes neurophysiological data for plotting purposes. 
#' It categorizes and orders cue and stimulus levels, then calculates subject-wise and group-wise
#' summary statistics for a given measure.
#'
#' @param df A data frame containing the neurophysiological data.
#' @param groupwise_measurevar The name of the column in `df` that contains the variable for 
#'   which group-wise summary statistics are to be calculated.
#' @param subject_keyword The name of the column in `df` that identifies individual subjects.
#' @param model_iv1 The first independent variable for the model, used for grouping in the analysis.
#' @param model_iv2 The second independent variable for the model, used for grouping in the analysis.
#'
#' @return A list containing two elements: `subjectwise` and `groupwise`. 
#'   `subjectwise` is a data frame with subject-level summary statistics, 
#'   and `groupwise` is a data frame with group-level summary statistics.
#'
#' @examples
#' # Example usage:
#' # NPS_summary_for_plots(data_frame, "measure_var", "subject_id", "iv1", "iv2")
#'
#' @importFrom plyr ddply
#' @export
compute_summary_NPS <- function(df, groupwise_measurevar, subject_keyword, model_iv1, model_iv2) {
    df$cue_name[df$cue == "highcue"] <- "high cue"
    df$cue_name[df$cue == "lowcue"] <- "low cue"

    df$stim_name[df$stim == "highstim"] <- "high"
    df$stim_name[df$stim == "medstim"] <- "med"
    df$stim_name[df$stim == "lowstim"] <- "low"

    df$stim_ordered <- factor(
        df$stim_name,
        levels = c("low", "med", "high")
    )
    df$cue_ordered <- factor(
        df$cue_name,
        levels = c("low cue", "high cue")
    )
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

    #groupwise$task <- taskname
    return(list(subjectwise,groupwise))
}
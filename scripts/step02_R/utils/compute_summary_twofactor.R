#' Compute Summary Statistics for Two-Factor Data
#'
#' This function computes summary statistics for data with two factors. It sources
#' utility scripts from the current script directory, calculates mean summaries for
#' each subject and group, and provides a summary with standard errors within groups.
#'
#' @param df A dataframe containing the data for analysis.
#' @param groupwise_measurevar The name of the variable for which to calculate group-wise measures.
#' @param subject_keyword The name of the variable identifying subjects in the dataset.
#' @param model_iv1 The name of the first independent variable (factor) in the model.
#' @param model_iv2 The name of the second independent variable (factor) in the model.
#' @param dv The name of the dependent variable in the dataset.
#'
#' @return A list containing two dataframes: the first (`subjectwise`) contains mean summaries
#'   for each combination of subject and independent variables; the second (`groupwise`) contains
#'   summary statistics with standard errors within groups defined by the independent variables.
#'
#' @examples
#' # Assuming df is your dataframe and appropriate variables are defined:
#' # result <- compute_summary_twofactor(df, "measure_var", "subjectID",
#' #                                    "factor1", "factor2", "dependentVar")
#'
#' @export
compute_summary_twofactor <- function(df, groupwise_measurevar, subject_keyword, model_iv1, model_iv2, dv) {
    # calculate within subject summary stats (per factor `model_iv1`, `model_iv2` and `dv`)
    subjectwise <- meanSummary(
        df,
        c(subject_keyword, model_iv1, model_iv2), dv
    )
    
    # aggregate the within-subject summary stats and produce a group-level statistic for `dv` as a function of `model_iv1` and `model_iv2`
    groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = groupwise_measurevar,
        withinvars = c(model_iv1, model_iv2), idvar = subject_keyword
    )

    return(list(subjectwise,groupwise))
}
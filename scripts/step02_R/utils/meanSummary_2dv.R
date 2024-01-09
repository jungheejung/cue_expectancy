#' Calculate Summary Statistics for Two Continuous Variables
#'
#' This function computes summary statistics for two continuous variables within specified groups in a dataset. It calculates the mean and standard deviation for each variable in each group.
#'
#' @param DATA A dataframe containing the data for analysis.
#' @param GROUP A vector of column names or a single column name used for grouping the data.
#' @param DV1 The name of the first continuous variable (dependent variable) for which summary statistics are calculated.
#' @param DV2 The name of the second continuous variable (dependent variable) for which summary statistics are calculated.
#'
#' @return A dataframe where each row represents a group defined in `GROUP` and contains the mean and standard deviation for `DV1` and `DV2`.
#'
#' @examples
#' # Assuming DATA is your dataframe with appropriate columns and groups:
#' # summary_stats <- meanSummary_2continuous(DATA, c("Group1", "Group2"),
#' #                                         "Variable1", "Variable2")
#'
#' @import plyr
#' @export
meanSummary_2continuous <- function(DATA, GROUP, DV1, DV2) {
  z <- plyr::ddply(DATA, GROUP, .fun = function(xx) {
    c(
      DV1_mean_per_sub = mean(xx[, DV1], na.rm = TRUE),
      DV1_sd = sd(xx[, DV1], na.rm = TRUE),
      DV2_mean_per_sub = mean(xx[, DV2], na.rm = TRUE),
      DV2_sd = sd(xx[, DV1], na.rm = TRUE)
    )
  })
  return(z)
}
# 
# meanSummary_2continuous <- function(DATA, GROUP, DV1, DV2) {
#   library(plyr)
#   z <- ddply(DATA, GROUP, .fun = function(xx) {
#     c(
#       DV1_mean_per_sub = mean(xx[, DV1], na.rm = TRUE),
#       DV1_sd = sd(xx[, DV1], na.rm = TRUE),
#       DV2_mean_per_sub = mean(xx[, DV2], na.rm = TRUE),
#       DV2_sd = sd(xx[, DV1], na.rm = TRUE)
#     )
#   })
#   return(z)
# }
# 

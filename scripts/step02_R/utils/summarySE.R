#' Summary Statistics with Standard Error and Confidence Interval
#'
#' Calculates and returns summary statistics for a given variable in a data frame, 
#' grouped by one or more variables. It provides count, mean, median, standard deviation, 
#' standard error of the mean, and confidence interval (default 95%).
#'
#' @param data A data frame containing the data to be summarized.
#' @param measurevar The name of the column in `data` that contains the variable to be summarized.
#' @param groupvars A vector containing the names of columns in `data` that contain grouping variables.
#'   If NULL, the function will summarize the entire dataset without grouping.
#' @param na.rm Logical. Indicates whether to ignore NA values in `measurevar`. 
#'   Defaults to FALSE.
#' @param conf.interval The confidence level for the interval. The default is 0.95 
#'   for a 95% confidence interval.
#' @param .drop Logical. If TRUE (default), will drop levels that do not occur in 
#'   the data frame `groupvars`.
#'
#' @return A data frame with the following columns: number of observations (N), 
#'   mean, median, standard deviation (sd), standard error (se), and confidence interval (ci).
#'
#' @importFrom plyr ddply
#' @importFrom plyr rename
#' @importFrom stats qt
#'
#' @examples
#' # Example usage with mtcars dataset
#' summarySE(mtcars, measurevar="mpg", groupvars="cyl")
#'
#' @references
#' This code is aa direct copy of the function used in RaincloudPlots: 
#' https://github.com/RainCloudPlots/RainCloudPlots/blob/master/tutorial_R/summarySE.R
#' This version is an Adapted code of Ryan Hope's Rmis::summarySE function: 
#' https://www.rdocumentation.org/packages/Rmisc/versions/1.5/topics/summarySE

#' @export
summarySE <- function(data = NULL, measurevar, groupvars = NULL, na.rm = FALSE,
                      conf.interval = .95, .drop = TRUE) {
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function(x, na.rm = FALSE) {
    if (na.rm) {
      sum(!is.na(x))
    } else {
      length(x)
    }
  }

  # This does the summary. For each group's data frame, return a vector with
  # N, mean, median, and sd

  datac <- plyr::ddply(data, groupvars, .drop=.drop,
                   .fun = function(xx, col) {
                       c(N      = length2(xx[[col]], na.rm=na.rm),
                         mean   = mean(xx[[col]], na.rm=na.rm),
                         median = median(xx[[col]], na.rm=na.rm),
                         sd      = sd(xx[[col]], na.rm=na.rm)
                       )
                   },
                   measurevar
  )

  # Rename the "mean" and "median" columns
 datac <- plyr::rename(datac, c("mean" = paste(measurevar, "_mean", sep = "")))
 datac <- plyr::rename(datac, c("median" = paste(measurevar, "_median", sep = "")))

 datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean

  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval:
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- stats::qt(conf.interval / 2 + .5, datac$N - 1)
  datac$ci <- datac$se * ciMult

  return(datac)
}

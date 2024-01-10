#' Calculate Mean and Standard Deviation for Groups
#'
#' This function computes the mean and standard deviation for a specified dependent variable (dv),
#' grouped by a specified variable in a data frame. It returns a data frame with these summary statistics.
#'
#' @param data A data frame containing the data to be summarized.
#' @param group The grouping variable as a string or a vector of strings if multiple grouping variables are used.
#' @param dv The name of the column in `data` that contains the dependent variable for which the mean and standard deviation are calculated.
#'
#' @return A data frame with each row representing a group defined by `group`. Each row contains
#'   the mean (`mean_per_sub`) and standard deviation (`sd`) of the specified dependent variable `dv` for that group.
#'
#' @examples
#' # Example usage with the built-in mtcars dataset, grouping by 'cyl' and summarizing 'mpg'
#' meanSummary(mtcars, "cyl", "mpg")
#'
#' @importFrom plyr ddply
#' @export
meanSummary <- function(data, group, dv) {
  z <- plyr::ddply(data, group, .fun = function(xx) {
    c(
      mean_per_sub = mean(xx[, dv], na.rm = TRUE),
      sd = sd(xx[, dv], na.rm = TRUE)
    )
  })
  return(z)
}

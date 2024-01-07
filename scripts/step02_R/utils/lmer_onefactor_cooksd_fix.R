#' Function to compute Cook's distance for a one-factor linear mixed-effects model
#'
#' This function fits a linear mixed-effects model to the specified data
#' and calculates Cook's distance for the model, which is a measure of
#' the influence of each observation.
#'
#' @param dataframe A data frame containing the data.
#' @param taskname A string indicating the name of the task.
#' @param iv The column name that contains the independent variable.
#' @param dv A vector of dependent variable names.
#' @param subject The column name indicating the subject (random effect).
#' @param dv_keyword A string representing the dependent variable for display purposes.
#' @param model_savefname The filename where the model summary will be saved.
#'
#' @return A vector of Cook's distance values for each observation in the model.
#' @import lme4
#' @importFrom stringr str_to_title
#' @export
#'
#' @examples
#' # Example usage:
#' # lmer_onefactor_cooksd_fix(dataframe, "Task1", "IV1", "DV1", "Subject", "dv_keyword", "model.txt")
lmer_onefactor_cooksd_fix <- function(dataframe, taskname, iv, dv, subject,
                                  dv_keyword, model_savefname) {
  library(lme4)
  eval(substitute(iv), dataframe)
  eval(substitute(dv), dataframe)
  eval(substitute(subject), dataframe)
  eval(substitute(model_savefname))
  model_onefactor <- lmer( dv ~ iv + (iv | subject), data = dataframe)
  print(paste("model: ", stringr::str_to_title(dv_keyword), " ratings - ", taskname))
  print(summary(model_onefactor))
  sink(model_savefname)
  print(summary(model_onefactor))
  # used to redirect the output from the R console to a file. 
  sink()
  fixEffect <<- as.data.frame(fixef(model_onefactor))
  randEffect <<- as.data.frame(ranef(model_onefactor))
  cooksd <- cooks.distance(model_onefactor)
 return(cooksd)
}

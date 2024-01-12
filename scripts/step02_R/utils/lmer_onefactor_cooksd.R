#' LMER Analysis with One Factor and Cook's Distance Calculation
#'
#' This function performs a linear mixed-effects regression using the lme4 package,
#' calculates Cook's distance, and optionally prints the model output. It is
#' designed for analyses involving one fixed effect and one random effect.
#'
#' @param df A data frame containing the data to be analyzed.
#' @param taskname A string representing the task name, used in the filename.
#' @param iv The column name in `df` that contains the independent variable.
#' @param dv The dependent variable for the LMER model.
#' @param subject_keyword The keyword identifying the random effect subject.
#' @param dv_keyword A string describing the dependent variable, used in output.
#' @param model_savefname Filename where the model output will be saved.
#' @param print_lmer_output Logical; if TRUE, prints the summary of the LMER model.
#'
#' @return Returns Cook's distance for the fitted model.
#'
#' @import lme4
#' @export
#'
#' @examples
#' # Example usage:
#' # lmer_onefactor_cooksd(df, "task1", "time", "score", "subject", "Score", "model_output.txt", TRUE)
lmer_onefactor_cooksd <- function(df, taskname, iv, dv, subject_keyword,
                                  dv_keyword, model_savefname, print_lmer_output) {
      library(lme4)
      model_onefactor <- lmer(as.formula(reformulate(c(iv,sprintf("(%s|%s)",iv,subject_keyword)),response=dv)), data = df) #nolint
      sink(file = model_savefname)
      print(paste("model: ", stringr::str_to_title(dv_keyword), " ratings - ", taskname)) #nolint
      print(reformulate(c(iv,sprintf("(%s|%s)",iv,subject_keyword)),response=dv)) #nolint
      print(summary(model_onefactor))
      sink()
      if(print_lmer_output == TRUE) {
      print(summary(model_onefactor))
      }
      fixEffect <<- as.data.frame(fixef(model_onefactor))
      randEffect <<- as.data.frame(ranef(model_onefactor))
      cooksd <- cooks.distance(model_onefactor)
      return(cooksd)
}
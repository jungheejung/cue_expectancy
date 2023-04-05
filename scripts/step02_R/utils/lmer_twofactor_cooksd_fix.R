#' Run lmer on two factors
#'
#' @param data dataframe
#' @param taskname string of task name
#' @param iv 1st factor with two levels
#' @param stim_con1 2nd factor with three levels. first contrast
#' @param stim_con2 2nd factor with three levels. second contrast
#' @param dv a string of dependent variable
#' @param subject_keyword random factor. e.g. subject or sessions
#' @param dv_keyword string of dependent variable. for saving filenames
#' @param model_savefname full path of filename to save lmer results
#' @param effects options c("random_intercept", "random_slopes", "no_random")
#' @param print_lmer_output bool: TRUE if you want the output printed in the Rmd; FALSE if you want the output silent
#'
#' @return cooks d distance
#' @export
#'
#' @examples
lmer_twofactor_cooksd_fix <- function(data, taskname,
                                       iv, stim_con1, stim_con2, dv,
                                       subject_keyword, dv_keyword, model_savefname, effects, print_lmer_output) {
      #   """
      #   Parameters
      #   ----------
      #   data:
      #         a data frame.
      #   taskname:
      #         string of task name
      #   iv:
      #         first factor
      #   stim_con1:
      #         contrast of second factor, if more than 2 levels
      #   stim_con2:
      #         contrast of second factor, if more than 2 levels
      #   dv:
      #         a string of dependent variable
      #   subject_keyword:
      #         random factor. e.g. subject or sessions
      #   dv_keyword:
      #         string of dependent variable. for saving filenames
      #   save_fname:
      #         full path of filename to save
      #   effects:
      #         options "random_intercept" "random_slopes" "no_random"
      #   print_lmer_output; bool
      #         TRUE if you want the output printed in the Rmd
      #         FALSE if you want the output silent
      #   """

      library(lme4)
      library(equatiomatic)

      if (effects == "random_intercept") {
            model_string <- reformulate(c(sprintf("%s*%s", iv, stim_con1), sprintf("%s*%s", iv, stim_con2), sprintf("(1|%s)", subject_keyword)), response = dv) #nolint
            model_full <- lmer(as.formula(model_string), data = data)
            fixEffect <<- as.data.frame(fixef(model_full))
            randEffect <<- as.data.frame(ranef(model_full))
            equatiomatic::extract_eq(model_full)
            # model_string = paste0(dv, "~ ", iv,"*",stim_con1, "+", iv,"*",stim_con2, "+","(1|", subject, ")") #nolint
      } else if (effects == "random_slopes") {
            model_string <- reformulate(c(sprintf("%s*%s", iv, stim_con1), sprintf("%s*%s", iv, stim_con2), sprintf("(%s*%s+%s*%s|%s)", iv, stim_con1, iv, stim_con2, subject_keyword)), response = dv) # nolint
            model_full <- lmer(as.formula(model_string), data = data)
            fixEffect <<- as.data.frame(fixef(model_full))
            randEffect <<- as.data.frame(ranef(model_full))
            equatiomatic::extract_eq(model_full)
            # model_string = paste0(dv, "~ ", iv,"*",stim_con1, "+", iv,"*",stim_con2, "+ (", iv,"*",stim_con1, "+", iv,"*",stim_con2,"|", subject, ")") #nolint
      } else if (effects == "no_random") {
            model_string <- reformulate(c(sprintf("%s*%s", iv, stim_con1), sprintf("%s*%s", iv, stim_con2)), response = dv) #nolint
            model_full <- lm(as.formula(model_string), data = data)
            # model_string = paste0(dv, "~ ", iv,"*",stim_con1, "+", iv,"*",stim_con2) #nolint
      }

      sink(model_savefname)
      print(paste("model: ", str_to_title(dv_keyword), " ratings - ", taskname))
      print(model_string)
      print(summary(model_full))
      print(model_string)
      sink()

      if (print_lmer_output == TRUE) {
            print(paste("model: ", str_to_title(dv_keyword), " ratings - ", taskname)) #nolint
            print(summary(model_full))
            equatiomatic::extract_eq(model_full, wrap = TRUE, intercept = "beta")
      }

      cooksd <- cooks.distance(model_full)
      return(cooksd)
}

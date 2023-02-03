lmer_onefactor_cooksd <- function(df, taskname, iv, dv, subject_keyword,
                                  dv_keyword, model_savefname, print_lmer_output) {

      #   """
      #   Parameters
      #   ----------
      #   data:
      #         a data frame
      #   taskname:
      #         a string of the task. will be saved in filename
      #   iv:
      #         the column name that contains the variable to be summariezed
      #   dv:
      #         a vector containing that are between-subjects column names
      #   random_factor:
      #         random effects
      #   dv_keyword:
      #         a string of the dependent variable
      #   model_savefname:
      #         model save filename
      #   """
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
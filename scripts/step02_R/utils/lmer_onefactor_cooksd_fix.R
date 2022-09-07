lmer_onefactor_cooksd_fix <- function(dataframe, taskname, iv, dv, subject,
                                  dv_keyword, model_savefname) {

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
      
      eval(substitute(iv), dataframe)
      eval(substitute(dv), dataframe)
      eval(substitute(subject), dataframe)
      eval(substitute(model_savefname))
      model_onefactor <- lmer( dv ~ iv + (iv | subject), data = dataframe)
      print(paste("model: ", stringr::str_to_title(dv_keyword), " ratings - ", taskname))
      print(summary(model_onefactor))
      sink(model_savefname)
      print(summary(model_onefactor))
      sink()
      fixEffect <<- as.data.frame(fixef(model_onefactor))
      randEffect <<- as.data.frame(ranef(model_onefactor))
      cooksd <- cooks.distance(model_onefactor)
      return(cooksd)
}

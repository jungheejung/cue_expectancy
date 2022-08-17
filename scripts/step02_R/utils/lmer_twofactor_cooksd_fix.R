lmer_two_factor_cooksd_fix <- function(data, taskname,
                                   iv, stim_con1, stim_con2, dv,
                                   subject, dv_keyword, model_savefname, effects) {
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
      #   subject:
      #         random factor. e.g. subject or sessions
      #   dv_keyword:
      #         string of dependent variable. for saving filenames
      #   save_fname:
      #         full path of filename to save

      #   """
      eval(substitute(iv), data)
      eval(substitute(dv), data)
      eval(substitute(subject), data)
      eval(substitute(model_savefname))
      if (effects == "random_intercept"){
            model_string = paste0(dv, "~ ", iv,"*",stim_con1, "+", iv,"*",stim_con2, "+","(1|", subject, ")")
      } else if (effects == "random_slopes"){
            model_string = paste0(dv, "~ ", iv,"*",stim_con1, "+", iv,"*",stim_con2, "+ (", iv,"*",stim_con1, "+", iv,"*",stim_con2,"|", subject, ")")
      } else if (effects == "no_random"){
            model_string = paste0(dv, "~ ", iv,"*",stim_con1, "+", iv,"*",stim_con2)
      }
      
      model_full <- lmer(as.formula(model_string), data = data)
      # model_full <- lmer(
      #       data[, dv] ~
      #       data[, iv] * data[, stim_con1] +
      #             data[, iv] * data[, stim_con2] +
      #             (data[, iv] * data[, stim_con1] + data[, iv] * data[, stim_con2] | data[, subject])
      # )
      sink(model_savefname)
      print(paste("model: ", str_to_title(dv_keyword), " ratings - ", taskname))
      print(model_string)
      print(summary(model_full))
      print(model_string)
      print(equatiomatic::extract_eq(model_full))

      sink()

      print(summary(model_full))
      fixEffect <<- as.data.frame(fixef(model_full))
      randEffect <<- as.data.frame(ranef(model_full))
      cooksd <- cooks.distance(model_full)
      print(equatiomatic::extract_eq(model_full))
      return(cooksd)
}
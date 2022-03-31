lmer_two_factor_cooksd <- function(data, taskname,
                                   iv, stimc1, stimc2, dv,
                                   subject, dv_keyword, save_fname) {
  """
  Parameters
  ----------
  data:
        a data frame.
  taskname:
        string of task name
  iv:
        first factor
  stimc1:
        contrast of second factor, if more than 2 levels
  stimc2:
        contrast of second factor, if more than 2 levels
  dv:
        a string of dependent variable
  subject:
        random factor. e.g. subject or sessions
  dv_keyword:
        string of dependent variable. for saving filenames
  save_fname:
        full path of filename to save

  """
    model_full <- lmer(data[, DV] ~
    data[, iv] * data[, stimc1] + data[, iv] * data[, stimc2] +
        (data[, iv] * data[, stimc1] +
            data[, iv] * data[, stimc2] | data[, subject]))
    sink(save_fname)
    print(paste("model: ", str_to_title(dv_keyword), " ratings - ", taskname))
    print(summary(model_full))
    sink()
    print(summary(model_full))
    fixEffect <<- as.data.frame(fixef(model_full))
    randEffect <<- as.data.frame(ranef(model_full))
    cooksd <- cooks.distance(model_full)
    return(cooksd)
}
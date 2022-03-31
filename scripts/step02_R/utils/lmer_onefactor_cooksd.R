lmer_onefactor_cooksd <- function(data, taskname, iv, dv, random_factor,
                                dv_keyword, model_save_fname) {

  """
  Parameters
  ----------
  data:
        a data frame
  taskname:
        a string of the task. will be saved in filename
  iv:
        the column name that contains the variable to be summariezed
  dv:
        a vector containing that are between-subjects column names
  random_factor:
        random effects
  dv_keyword:
        a string of the dependent variable
  model_save_fname:
        model save filename
  """
    model_onefactor <- lmer(data[, dv] ~ data[, iv] +
        (data[, iv] | data[, random_factor]))
    print(paste("model: ", str_to_title(dv_keyword), " ratings - ", taskname))
    print(summary(model_onefactor))
    sink(model_save_fname)
    print(summary(model_onefactor))
    sink()
    cooksd <- cooks.distance(model_onefactor)
    return(cooksd)
}
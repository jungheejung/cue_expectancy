#' Load and Process Behavioral Data for Specified Task
#'
#' This function loads behavioral data for a specified task from a given directory,
#' binds them into a single dataframe, and processes the data according to specified criteria.
#' It handles missing values, factors, and optionally filters the data based on a dependent variable.
#' this code allows the function to behave differently based on whether a specific column name (dv) is provided or not. 
#' 
#' Regarding dv,
#' If dv is given, the function returns the original dataframe but with rows containing missing values in the dv column removed. 
#' If dv is not provided, the function returns the original dataframe as is. 
#' This functionality is useful when you want to make the data cleaning step conditional based on the presence of a specific variable.
#'
#' @param datadir A string specifying the directory path where the data is stored.
#' @param taskname A string specifying the name of the task (e.g., 'pain', 'cognitive', 'vicarious').
#' @param subject_varkey A string specifying the variable key for subjects 
#'   (e.g., 'src_subject_id' or 'subject').
#' @param iv A string specifying the independent variable in the analysis.
#' @param dv A string specifying the dependent variable in the analysis. 
#'   If provided, the function will return data with NA values in this column removed.
#' @param exclude A vector specifying any criteria for excluding data.
#'
#' @return A dataframe containing the loaded and processed data. If 'dv' is specified,
#'   returns data with NA values in the 'dv' column removed.
#'
#' @examples
#' # Assuming appropriate data and parameters
#' # df <- df_load_beh(datadir = "path/to/data", taskname = "pain",
#' #                  subject_varkey = "subjectID", iv = "independentVar", 
#' #                  dv = "dependentVar", exclude = c("criteria1", "criteria2"))
#'
#' @export
df_load_beh <- function(datadir, taskname, subject_varkey, iv, dv, exclude) {
  # 1. load data ______________________________________________________________
  filename <- paste("*_task-social_*-", taskname, "_beh.csv", sep = "")
  common_path <- Sys.glob(file.path(datadir, "sub-*", "ses-*", filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

  df <- do.call("rbind", lapply(filter_path, FUN = function(files) {
    as.data.frame(read.csv(files))
  }))

  is.nan.data.frame <- function(x) {
    do.call(cbind, lapply(x, is.nan))
  }
  df[is.nan(df)] <- NA
  df[, "subject"] <- factor(df[, subject_varkey])

  # B. plot expect rating NA ___________________________________________________
  if (hasArg(dv)){
  df_expect_NA <- aggregate(df[, dv], list(df$subject), function(x) sum(is.na(x)))
  df_remove_NA <- df[!is.na(df[dv]), ]
  df_remove_NA <- as.data.frame(df_remove_NA)
      return(df_remove_NA)}
  else {return(df)}
}

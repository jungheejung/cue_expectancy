load_task_social_df <- function(taskname, subject_varkey, iv, dv, exclude) {
  # INPUT:
  # * taskname (e.g. pain, cognitive, vicarious)
  # * subject_varkey (e.g. src_subject_id or subject)
  # A. load data ______________________________________________________________
  filename <- paste("*_task-social_*-", taskname, "_beh.csv", sep = "")
  common_path <- Sys.glob(file.path(
    main_dir, "data", "dartmouth", "d02_preprocessed",
    "sub-*", "ses-*", filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

  df <- do.call("rbind", lapply(filter_path, FUN = function(files) {
    read.csv(files)
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

NPS_load_df <- function(keys) { # nolint
  # keys:
  # - con_list (e.g. c(43,44,45))
  # - contrast_name (e.g. P_simple)
  # - task_name (e.g. "pain")
  df <- data.frame()
  contrast_df <- data.frame()
  print(keys$contrast_name)
  for (conname in keys$con_list) {
    contrast_df <- data.frame()
    fpath <- Sys.glob(file.path(
      keys$npsdir,paste0('extract-nps_model01-6cond_',sprintf("con_%04d", conname),'*',keys$contrast_name,'*.csv' # nolint
      )
    ))
    fname <- basename(fpath)
    contrast_df <- read.csv(fpath)
    pattern <- paste0(keys$contrast_name, "_\\s*(.*?)\\s*", ".csv")
    conname <- regmatches(fname, regexec(pattern, fname))[[1]][2]
    cuelevel <- strsplit(conname, "_")[[1]][1]
    stimlevel <- strsplit(conname, "_")[[1]][2]
    contrast_df$conname <- conname
    contrast_df$cue <- cuelevel
    contrast_df$stim <- stimlevel
    contrast_df$task <- keys$taskname
    df <- rbind(df, contrast_df)
  }
  return(df)
}
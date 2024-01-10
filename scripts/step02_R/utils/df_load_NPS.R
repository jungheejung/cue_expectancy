#' Load and Process NPS Data
#'
#' This function loads and processes NPS (Neurological Pain Signature) data 
#' based on specified keys. It iterates over a list of contrast numbers, 
#' constructs file paths, reads data from these files, and combines them 
#' into a single dataframe. Each file's data is augmented with metadata 
#' like contrast name, cue level, stimulus level, and task name.
#'
#' @param keys A list containing specific keys for loading the data:
#'   - `con_list`: A vector of contrast numbers (e.g., `c(43,44,45)`).
#'   - `contrast_name`: The name of the contrast (e.g., `"P_simple"`).
#'   - `task_name`: The name of the task (e.g., `"pain"`).
#'   - `npsdir`: The directory path where NPS data files are stored.
#'
#' @return A dataframe that combines all the loaded and processed NPS data
#'   across the specified contrasts and other keys.
#'
#' @examples
#' # Assuming appropriate keys and data directory
#' # keys <- list(con_list = c(43,44,45), contrast_name = "P_simple",
#' #             task_name = "pain", npsdir = "path/to/nps_data")
#' # df_nps <- df_load_NPS(keys)
#'
#' @export

df_load_NPS <- function(keys) {
  df <- data.frame()
  contrast_df <- data.frame()
  print(keys$contrast_name)
  for (conname in keys$con_list) {
    contrast_df <- data.frame()
    fpath <- Sys.glob(file.path(
      keys$npsdir,paste0('extract-nps_model01-6cond_',sprintf("con_%04d", conname),'*',keys$contrast_name,'*.csv'
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
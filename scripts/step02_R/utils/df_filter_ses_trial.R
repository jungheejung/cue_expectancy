#' Filter dataframe using session and trial number as criterion
#'
#' @param data dataframe
#' @param session_colname within dataframe, column name that contains information on session id
#' @param subject_colname within dataframe, column name that contains information on subject id
#' @param session_threshold int: What is the cutoff of the dataframe? subjects with all three sessions?
#' @param trial_threshold int: bare minimum number of trials that each participant should have.
#'
#' @return dataframe with filtered participants that match trial_threshold, session_threshold criterion
#'
#' @examples
df_filter_ses_trial <- function(data, session_colname, subject_colname, session_threshold, trial_threshold) {
  
  data.2 <- data %>%
    arrange({{subject_colname}}) %>%
    group_by({{subject_colname}}) %>%
    mutate(trial_number = row_number())
  
  df_with_trial_number <- data.2 %>%
    group_by({{subject_colname}}) %>%
    summarize(trial_number = n_distinct(trial_number))
  
  sessions_per_subject <- data %>%
    group_by({{subject_colname}}) %>%
    summarize(sessions = n_distinct({{session_colname}}))
  
  df_summary <- df_with_trial_number %>%
    inner_join(sessions_per_subject, by = {{subject_colname}}) %>%
    filter(trial_number > trial_threshold, {{subject_colname}} == session_threshold)
  
  return(df_summary)
}

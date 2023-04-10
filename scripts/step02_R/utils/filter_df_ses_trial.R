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

filter_df_ses_trial <- function(data, session_colname, subject_colname, session_threshold, trial_threshold) {

data.2= data %>%
  arrange(.data[[subject_colname]] ) %>%
  group_by(.data[[subject_colname]]) %>%
  mutate(trial_number = row_number())

df_with_trial_number <- aggregate(trial_number ~ .data[[subject_colname]], data = data.2, FUN = function(x) length(unique(x)))
sessions_per_subject <- aggregate(.data[[session_colname]] ~ .data[[subject_colname]], data = data, FUN = function(x) length(unique(x)))

df_summary <- df_with_trial_number %>%
  inner_join(sessions_per_subject, by = subject_colname) %>%
  filter(trial_number > trial_threshold,
  .data[[subject_colname]] == session_threshold)

  return(df_summary)

}


"""
sessions_per_subject <- aggregate(session_id ~ src_subject_id, data = data, FUN = function(x) length(unique(x)))
data.2= data %>%
  arrange(src_subject_id ) %>%
  group_by(src_subject_id) %>%
  mutate(trial_number = row_number())

df_with_trial_number <- aggregate(trial_number ~ src_subject_id, data = data.2, FUN = function(x) length(unique(x)))
sessions_per_subject <- aggregate(session_id ~ src_subject_id, data = data_p2, FUN = function(x) length(unique(x)))
df_summary <- df_with_trial_number %>% 
  inner_join(sessions_per_subject, by = "src_subject_id") %>% 
  filter(trial_number > 50, session_id == 3)
"""

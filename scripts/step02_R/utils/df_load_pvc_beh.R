#' Load and Process PVC Behavioral Data
#'
#' @description
#' This function loads and processes behavioral data for pain, vicarious, and cognitive tasks
#' from a specified directory. It arranges and groups the data based on subject IDs and
#' other parameters, calculates trial indices, and binds the data from different task types.
#'
#' @param datadir A string specifying the directory path where the data is stored.
#' @param subject_varkey A string or character vector specifying the variable key for subjects.
#' @param iv A string specifying the independent variable in the analysis.
#' @param dv A string specifying the dependent variable in the analysis.
#' @param exclude A vector specifying any criteria for excluding data.
#'
#' @return A dataframe containing the processed and combined data from pain, vicarious, and cognitive tasks.
#' @examples
#' # Assuming appropriate data and parameters
#' # data <- df_load_pvc_beh(datadir = "path/to/data", subject_varkey = "subjectID",
#' #                         iv = "independentVar", dv = "dependentVar", exclude = c("criteria1", "criteria2"))
#' @import dplyr
#' @import stringr
#' @export

df_load_pvc_beh <- function(datadir, subject_varkey, iv, dv, exclude) {
  
  
  # Define a helper function to process individual task dataframes
  process_task_df <- function(df, taskname, subject_varkey) {
    df %>%
      arrange(!!sym(subject_varkey)) %>%
      group_by(!!sym(subject_varkey), session_id, param_run_num) %>%
      dplyr::mutate(trial_index = row_number(param_run_num)) %>%
      ungroup() %>%
      group_by(!!sym(subject_varkey)) %>%
      dplyr::mutate(trial_count_sub = row_number()) %>%
      ungroup() %>%
      select(
        src_subject_id,
        session_id,
        param_run_num,
        param_task_name,
        event02_expect_angle,
        param_cue_type,
        param_stimulus_type,
        event04_actual_angle,
        trial_index, 
        trial_count_sub
      ) 
  }
  
  # Load and process each task's data
  pvc.sub <- bind_rows(
    process_task_df(df_load_beh(datadir, "pain", subject_varkey, iv, dv, exclude), "pain", subject_varkey),
    process_task_df(df_load_beh(datadir, "vicarious", subject_varkey, iv, dv, exclude), "vicarious", subject_varkey),
    process_task_df(df_load_beh(datadir, "cognitive", subject_varkey, iv, dv, exclude), "cognitive", subject_varkey)
  )
  
  # Post-processing
  pvc.sub <- pvc.sub %>%
    dplyr::mutate(
      trial_ind = trial_index - 1,
      sub = sprintf("sub-%04d", src_subject_id),
      ses = sprintf("ses-%02d", session_id),
      run = sprintf("run-%02d", param_run_num),
      runtype = sprintf("runtype-%s", param_task_name),
      task = as.character(param_task_name), # Assuming task name is a character string
      trial_sub = trial_count_sub,
      trial = sprintf("trial-%03d", trial_ind),
      cue = str_split_fixed(param_cue_type, '_', 2)[, 1],
      cuetype = sprintf("cuetype-%s", cue),
      stimintensity = str_split_fixed(param_stimulus_type, '_', 2)[, 1],
      DEPc = str_split_fixed(param_cue_type, '_', 2)[, 2],
      DEP = str_split_fixed(param_stimulus_type, '_', 2)[, 2]
    ) %>%
    select(-cue) # Remove the intermediate 'cue' column
  
  return(pvc.sub)
}
#' Center data using Enders & Tofighi (2007) method
#'
#' This function processes the input data by calculating several statistical measures
#' including outcome averages, demeaned outcomes, and trial indices. It also computes
#' lagged outcomes and contrast measures for behavioral analysis.
#'
#' @param data A dataframe containing the input data.
#' @param sub The name of the column in 'data' representing subject IDs.
#' @param outcome The name of the column in 'data' representing outcome measures.
#' @param expect The name of the column in 'data' representing expected values.
#' @param ses The name of the column in 'data' representing session IDs.
#' @param run The name of the column in 'data' representing run numbers.
#'
#' @return A dataframe processed with added statistical measures.
#'   - `OUTCOME`: Numeric version of the outcome column.
#'   - `EXPECT`: Numeric version of the expect column.
#'   - `OUTCOME_cm`: Mean of `OUTCOME` for each subject.
#'   - `OUTCOME_demean`: `OUTCOME` demeaned for each data point.
#'   - `EXPECT_cm`: Mean of `EXPECT` for each subject.
#'   - `EXPECT_demean`: `EXPECT` demeaned for each data point.
#'   - `trial_index`: Sequential trial number for each subject.
#'   - `lag.OUTCOME_demean`: Lagged version of `OUTCOME_demean`.
#'   - `EXPECT_cmc`: Centered mean contrast for `EXPECT`.
#'   - The function returns a subset of data with complete cases for `lag.OUTCOME_demean`.
#'
#' @examples
#' # Assuming data is your dataframe with appropriate columns:
#' # processed_data <- process_main_data(data, "src_subject_id",
#' #                                    "event04_actual_angle", "event02_expect_angle",
#' #                                    "session_id", "param_run_num")
#' 
#' @references
#' Main text: Enders & Tofighi (2007). Centering predictor variables in cross-sectional multilevel models: 
#'   A new look at an old issue. Psychological Methods, 12(2), 121–138.
#'   https://doi.org/10.1037/1082-989X.12.2.121
#' Masur, P. (2018). How to Center in Multilevel Models. 
#'   Retrieved from https://philippmasur.de/2018/05/23/how-to-center-in-multilevel-models/
#' Shaw. M., & Flake, J. K. . Module 8: Centering in MLMs. 
#'   Retrieved from https://www.learn-mlms.com/08-module-8.html
#'
#' 
#' @export
#' 
#' 
compute_enderstofighi <- function(data, sub, outcome, expect, ses, run) {
  maindata <- data %>%
    group_by(!!sym(sub)) %>%
    mutate(OUTCOME = as.numeric(!!sym(outcome))) %>%
    mutate(EXPECT = as.numeric(!!sym(expect))) %>%
    mutate(OUTCOME_cm = mean(OUTCOME, na.rm = TRUE)) %>%
    mutate(OUTCOME_demean = OUTCOME - OUTCOME_cm) %>%
    mutate(EXPECT_cm = mean(EXPECT, na.rm = TRUE)) %>%
    mutate(EXPECT_demean = EXPECT - EXPECT_cm) %>%
    mutate(OUTCOME_zscore = as.numeric(scale(OUTCOME, center = TRUE, scale = TRUE)[, 1])) %>%
    mutate(EXPECT_zscore = as.numeric(scale(EXPECT, center = TRUE, scale = TRUE)[, 1])) 
  
  data_p2 <- maindata %>%
    arrange(!!sym(sub)) %>%
    group_by(!!sym(sub)) %>%
    mutate(trial_index = row_number())
  
  data_a3 <- data_p2 %>%
    group_by(!!sym(sub), !!sym(ses), !!sym(run)) %>%
    mutate(trial_index = row_number(!!sym(run)))
  
  data_a3lag <- data_a3 %>%
    group_by(!!sym(sub), !!sym(ses), !!sym(run)) %>%
    mutate(lag.OUTCOME_demean = dplyr::lag(OUTCOME_demean, n = 1, default = NA))
  
  # Create Subjectwise Mean, centered in relation to the group mean
  data_a3cmc <- data_a3lag %>%
    ungroup %>%
    mutate(EXPECT_cmc = EXPECT_cm - mean(EXPECT_cm, na.rm=TRUE)) %>%
    mutate(OUTCOME_cmc = OUTCOME_cm - mean(OUTCOME_cm, na.rm=TRUE))
  
  
  # Remove NA values ___________________________________________________________
  data_centered_NA <- data_a3cmc %>% 
    filter(!is.na(OUTCOME)) %>% # Remove NA values
    filter(!is.na(EXPECT))

  return(data_centered_NA)
  
}

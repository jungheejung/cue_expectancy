#' NPS Simple Contrasts
#'
#' This function computes simple contrasts for the "stim" and "cue" variables in a data frame.
#'
#' @param df A data frame containing the variables "stim" and "cue".
#' @return The data frame with additional columns for simple contrasts.
#'
#' @details
#' This function calculates two types of contrasts for the "stim" variable: linear and quadratic.
#' It also calculates a contrast for the "cue" variable.
#'
#' The linear contrast for "stim" assigns -0.5 to "lowstim," 0 to "medstim," and 0.5 to "highstim."
#' The quadratic contrast for "stim" assigns -0.33 to "lowstim," 0.66 to "medstim," and -0.33 to "highstim."
#' The cue contrast assigns -0.5 to "lowcue" and 0.5 to "highcue."
#'
#' @examples
#' # Create a sample data frame
#' df <- data.frame(stim = c("lowstim", "medstim", "highstim"),
#'                  cue = c("lowcue", "highcue", "lowcue"))
#'
#' # Calculate simple contrasts
#' result <- NPS_simple_contrasts(df)
#'
#' @export
NPS_simple_contrasts <- function(df) {

df$stim_factor <- factor(df$stim)

# contrast code 1 linear
df$stim_con_linear[df$stim == "lowstim"] <-  -0.5
df$stim_con_linear[df$stim == "medstim"] <-  0
df$stim_con_linear[df$stim == "highstim"] <-  0.5

# contrast code 2 quadratic
df$stim_con_quad[df$stim == "lowstim"] <-  -0.33
df$stim_con_quad[df$stim == "medstim"] <-  0.66
df$stim_con_quad[df$stim == "highstim"] <-  -0.33

# cue contrast
df$cue_con[df$cue == "lowcue"] <-  -0.5 # social influence task
df$cue_con[df$cue == "highcue"] <-  0.5 # no influence task
return(df)
}
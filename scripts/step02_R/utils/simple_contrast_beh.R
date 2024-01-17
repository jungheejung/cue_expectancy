#' Add Contrast and Ordered Categorical Columns to a Data Frame
#'
#' This function takes a data frame and adds several new columns to it. These new columns include
#' contrast codes (linear and quadratic), ordered categorical variables, and factorized variables.
#' The function is specifically tailored for a behavioral file with a fixed structure.
#'
#' @param df A data frame to which new columns will be added. The data frame is expected to have
#'           specific columns like `src_subject_id`, `param_stimulus_type`, and `param_cue_type`.
#'
#' @return A modified data frame with added columns for contrasts and ordered categoricals.
#'         The function also prints out a message listing the names of the new columns.
#'
#' @examples
#' # Assuming `data` is your data frame with the required structure:
#' modified_data <- simple_contrast_beh(data)
#'
#' @export
simple_contrast_beh <- function(df) {

    # List of new columns to be added
    new_columns <- c(
        "subject", "stim_factor", "STIM_con_linear",
        "STIM_con_quad", "CUE_high_gt_low",
        "stim_ordered", "cue_name", "cue_ordered"
    )

    # Loop through the new columns and initialize each with NA
    for (col in new_columns) {
        df[[col]] <- NA
    }

    # Given that the behavioral file has a fixed structure,
    # we'll create contrast codes directly based on its name.
    df$subject <- factor(df$src_subject_id)
    df$stim_factor <- factor(df$param_stimulus_type)

    # contrast code 1 linear
    df$STIM_con_linear[df$param_stimulus_type == "low_stim"] <- -0.5
    df$STIM_con_linear[df$param_stimulus_type == "med_stim"] <- 0
    df$STIM_con_linear[df$param_stimulus_type == "high_stim"] <- 0.5

    # contrast code 2 quadratic
    df$STIM_con_quad[df$param_stimulus_type == "low_stim"] <- -0.33
    df$STIM_con_quad[df$param_stimulus_type == "med_stim"] <- 0.66
    df$STIM_con_quad[df$param_stimulus_type == "high_stim"] <- -0.33

    # cue contrast
    df$CUE_high_gt_low[df$param_cue_type == "low_cue"] <- -0.5 # social influence task
    df$CUE_high_gt_low[df$param_cue_type == "high_cue"] <- 0.5 # no influence task

    df$stim_ordered <- factor(
        df$param_stimulus_type,
        levels = c("low_stim", "med_stim", "high_stim")
    )

    df$cue_name[df$param_cue_type == "low_cue"] <- "low"
    df$cue_name[df$param_cue_type == "high_cue"] <- "high"

    df$cue_ordered <- factor(
        df$cue_name,
        levels = c("low", "high")
    )

    print(paste(
        "new contrast names include:\n",
        "\t* STIM_con_linear\n",
        "\t* STIM_con_quad\n",
        "\t* CUE_high_gt_low\n",
        "Also included are ordered categoricals:\n ",
        "\t* stim_ordered\n",
        "\t* cue_ordered\n",
        "The following variables are factorized:\n",
        "\t* subject\n",
        "\tstim-factor",
        sep = ""
    ))

    return(df)
}

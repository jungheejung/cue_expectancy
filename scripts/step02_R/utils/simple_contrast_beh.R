simple_contrast_beh <- function(df) {

    df$subject <- NA
    df$stim_factor <- NA
    df$STIM_con_linear <- NA
    df$STIM_con_quad <- NA
    df$CUE_high_gt_low <- NA
    df$stim_ordered <- NA
    df$cue_name <- NA
    df$cue_ordered <- NA


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

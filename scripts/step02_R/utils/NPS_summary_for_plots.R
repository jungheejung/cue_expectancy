NPS_summary_for_plots <- function(df, groupwise_measurevar, subject_keyword, model_iv1, model_iv2) {
    df$cue_name[df$cue == "highcue"] <- "high cue"
    df$cue_name[df$cue == "lowcue"] <- "low cue"

    df$stim_name[df$stim == "highstim"] <- "high"
    df$stim_name[df$stim == "medstim"] <- "med"
    df$stim_name[df$stim == "lowstim"] <- "low"

    df$stim_ordered <- factor(
        df$stim_name,
        levels = c("low", "med", "high")
    )
    df$cue_ordered <- factor(
        df$cue_name,
        levels = c("low cue", "high cue")
    )
    #  [ PLOT ] calculate mean and se  _________________________
    subjectwise <- meanSummary(
        df,
        c(subject_keyword, model_iv1, model_iv2), dv
    )
    groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = groupwise_measurevar,
        withinvars = c(model_iv1, model_iv2), idvar = subject_keyword
    )

    #groupwise$task <- taskname
    return(list(subjectwise,groupwise))
}
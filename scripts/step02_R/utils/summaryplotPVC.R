
summaryplotPVC <- function(df, groupwise_measurevar, subject_keyword, model_iv1, model_iv2, dv) {
    # Get the directory of the currently running script
    script_dir <- dirname(sys.frame(1)$ofile)

    # List and source files from the utils directory
    file.sources <- list.files(script_dir, pattern="*.R", full.names=TRUE, ignore.case=TRUE)
    sapply(file.sources, source, .GlobalEnv)
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

    return(list(subjectwise,groupwise))
}
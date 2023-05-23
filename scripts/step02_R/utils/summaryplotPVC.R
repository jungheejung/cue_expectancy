
summaryplotPVC <- function(df, groupwise_measurevar, subject_keyword, model_iv1, model_iv2, dv) {
    file.sources = list.files(c("/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils"),
                            pattern="*.R", 
                            full.names=TRUE, 
                            ignore.case=TRUE)
    sapply(file.sources,source,.GlobalEnv)
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
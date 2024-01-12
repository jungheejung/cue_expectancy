#' Summarize Data with Within-Subject Variability Handling
#'
#' Summarizes data by handling within-subjects variables, removing inter-subject variability. 
#' It will still work if there are no within-subject variables. 
#' The function calculates count, un-normed mean, normed mean (with the same between-group mean), 
#' standard deviation, standard error of the mean, and confidence interval. 
#' For within-subject variables, it calculates adjusted values using the method from Morey (2008).
#' This function is directly based on functionality from the Rmisc package.
#'
#' @param data A data frame containing the dataset to be summarized.
#' @param measurevar The name of a column that contains the variable to be summarized.
#' @param betweenvars A vector containing names of columns that are between-subjects variables.
#' @param withinvars A vector containing names of columns that are within-subjects variables.
#' @param idvar The name of a column that identifies each subject (or matched subjects).
#' @param na.rm A boolean indicating whether to ignore NA's.
#' @param conf.interval The percent range of the confidence interval (default is 95%).
#' @param .drop A logical value indicating whether to drop unused factor levels.
#'
#' @return A data frame with summarized statistics.
#'
#' @importFrom Rmisc summarySE
#' @importFrom Rmisc normDataWithin
#' @export
#'
#' @examples
#' # Example usage:
#' data <- data.frame(
#'     subject = factor(rep(1:10, each = 3)),
#'     group = factor(rep(1:2, each = 15)),
#'     response = rnorm(30)
#' )
#' summarySEwithin(data, measurevar="response", betweenvars="group", idvar="subject")
summarySEwithin <- function(data = NULL, measurevar, betweenvars = NULL, withinvars = NULL,
                            idvar = NULL, na.rm = FALSE, conf.interval = .95, .drop = TRUE) {

    factorvars <- vapply(data[, c(betweenvars, withinvars), drop = FALSE],
        FUN = is.factor, FUN.VALUE = logical(1)
    )

    if (!all(factorvars)) {
        nonfactorvars <- names(factorvars)[!factorvars]
        message(
            "Automatically converting the following non-factors to factors: ",
            paste(nonfactorvars, collapse = ", ")
        )
        data[nonfactorvars] <- lapply(data[nonfactorvars], factor)
    }

    # Get the means from the un-normed data
    datac <- summarySE(data, measurevar,
        groupvars = c(betweenvars, withinvars),
        na.rm = na.rm, conf.interval = conf.interval, .drop = .drop
    )

    # Drop all the unused columns (these will be calculated with normed data)
    datac$sd <- NULL
    datac$se <- NULL
    datac$ci <- NULL

    # Norm each subject's data
    ndata <- normDataWithin(data, idvar, measurevar, betweenvars, na.rm, .drop = .drop)

    # This is the name of the new column
    measurevar_n <- paste(measurevar, "_norm", sep = "")

    # Collapse the normed data - now we can treat between and within vars the same
    ndatac <- summarySE(ndata, measurevar_n,
        groupvars = c(betweenvars, withinvars),
        na.rm = na.rm, conf.interval = conf.interval, .drop = .drop
    )

    # Apply correction from Morey (2008) to the standard error and confidence interval
    #  Get the product of the number of conditions of within-S variables
    nWithinGroups <- prod(vapply(ndatac[, withinvars, drop = FALSE],
        FUN = nlevels,
        FUN.VALUE = numeric(1)
    ))
    correctionFactor <- sqrt(nWithinGroups / (nWithinGroups - 1))

    # Apply the correction factor
    ndatac$sd <- ndatac$sd * correctionFactor
    ndatac$se <- ndatac$se * correctionFactor
    ndatac$ci <- ndatac$ci * correctionFactor

    # Combine the un-normed means with the normed results
    df <- merge(datac, ndatac)
    return(df)
}
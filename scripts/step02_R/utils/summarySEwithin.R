#' Summarizes Data with Within-Subjects Variables
#'
#' This function summarizes data, especially handling within-subjects variables by removing
#' inter-subject variability. It calculates count, un-normed mean, normed mean, standard
#' deviation, standard error of the mean, and confidence interval. Adjusted values are calculated
#' using the method from Morey (2008) if there are within-subject variables.
#'
#' @param data A data frame containing the data to be summarized.
#' @param measurevar The name of a column that contains the variable to be summarized.
#' @param betweenvars A vector containing names of columns that are between-subjects variables.
#' @param withinvars A vector containing names of columns that are within-subjects variables.
#' @param idvar The name of a column that identifies each subject (or matched subjects).
#' @param na.rm A boolean indicating whether to ignore NA's in calculations.
#' @param conf.interval The percent range of the confidence interval (default is 95%).
#' @param .drop A boolean indicating whether to drop levels that do not appear in the data.
#'
#' @return A data frame with summarized statistics including mean, standard deviation,
#'         standard error, and confidence interval for both normed and un-normed data.

#' @examples
#' # Assuming `data` is your data frame with the appropriate structure:
#' result <- summarySEwithin(data, "measurevar", c("betweenVar1", "betweenVar2"),
#'                           c("withinVar1", "withinVar2"), "idvar", TRUE, .95, TRUE)
#' @references
#' This code is aa direct copy of the function used in RaincloudPlots:
#' https://github.com/RainCloudPlots/RainCloudPlots/blob/master/tutorial_R/summarySE.R
#' This version is an Adapted code of Ryan Hope's Rmis::summarySE function:
#' https://www.rdocumentation.org/packages/Rmisc/versions/1.5/topics/summarySE
#' @export
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

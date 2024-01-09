#' Normalize within-group data
#' 
#' Norms the data within specified groups in a data frame; it normalizes each
#' subject (identified by idvar) so that they have the same mean, within each group
#' specified by betweenvars.
#' 
#' @param data a data frame.
#' @param idvar the name of a column that identifies each subject (or matched subjects)
#' @param measurevar the name of a column that contains the variable to be summariezed
#' @param betweenvars a vector containing names of columns that are between-subjects variables
#' @param na.rm a boolean that indicates whether to ignore NA's
#' @param .drop should combinations of variables that do not appear in the input data be preserved (FALSE) or dropped (TRUE, default)
#' 
#' @return a data frame with normalized data
#' 
#' @references http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)
#' This code is a direct copy of Rmisc::summarySE, normDataWithin function
#' 
#' @importFrom plyr ddply
#' 
#' @export
#' 
normDataWithin <- function(data=NULL, idvar, measurevar, betweenvars=NULL,
                           na.rm=FALSE, .drop=TRUE) {
  # Measure var on left, idvar + between vars on right of formula.
  data.subjMean <- ddply(data, c(idvar, betweenvars), .drop=.drop,
                         .fun = function(xx, col, na.rm) {
                           c(subjMean = mean(xx[,col], na.rm=na.rm))
                         },
                         measurevar,
                         na.rm
  )
  
  # Put the subject means with original data
  data <- merge(data, data.subjMean)
  
  # Get the normalized data in a new column
  measureNormedVar <- paste(measurevar, "_norm", sep="")
  data[,measureNormedVar] <- data[,measurevar] - data[,"subjMean"] +
    mean(data[,measurevar], na.rm=na.rm)
  
  # Remove this subject mean column
  data$subjMean <- NULL
  
  return(data)
}
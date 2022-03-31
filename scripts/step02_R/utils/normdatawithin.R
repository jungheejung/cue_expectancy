normDataWithin <- function(data = NULL, idvar, measurevar, betweenvars = NULL,
                           na.rm = FALSE, .drop = TRUE) {
#   """
#   Norms the data within specified groups in a data frame;
#   it normalizes each subject (identified by idvar),
#   within each group specified by betweenvars.

#   Parameters
#   ----------
#   data:
#         a data frame.
#   idvar:
#         the column name that identifies each subject (or matched subjects)
#   measurevar:
#         the column name that contains the variable to be summariezed
#   betweenvars:
#         a vector containing that are between-subjects column names
#   na.rm:
#         a boolean that indicates whether to ignore NA's
#   """
  library(plyr)

  # Measure var on left, idvar + between vars on right of formula.
  data.subjMean <- ddply(data, c(idvar, betweenvars),
    .drop = .drop,
    .fun = function(xx, col, na.rm) {
      c(subjMean = mean(xx[, col], na.rm = na.rm))
    },
    measurevar,
    na.rm
  )

  # Put the subject means with original data
  data <- merge(data, data.subjMean)

  # Get the normalized data in a new column
  measureNormedVar <- paste(measurevar, "_norm", sep = "")
  data[, measureNormedVar] <- data[, measurevar] - data[, "subjMean"] +
    mean(data[, measurevar], na.rm = na.rm)

  # Remove this subject mean column
  data$subjMean <- NULL

  return(data)
}
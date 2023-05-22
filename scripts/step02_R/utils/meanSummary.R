meanSummary <- function(data, group, dv) {
    library(plyr)
    z <- plyr::ddply(data, group, .fun = function(xx) {
        c(
            mean_per_sub = mean(xx[, dv], na.rm = TRUE),
            sd = sd(xx[, dv], na.rm = TRUE)
        )
    })
    return(z)
}
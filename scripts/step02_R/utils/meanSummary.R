meanSummary <- function(DATA, GROUP, DV) {
    z <- ddply(DATA, GROUP, .fun = function(xx) {
        c(
            mean_per_sub = mean(xx[, DV], na.rm = TRUE),
            sd = sd(xx[, DV], na.rm = TRUE)
        )
    })
    return(z)
}
ggplot_hline_bartoshuk <- function(xposition) {
    library(ggplot2)
    geom_hline(yintercept = 3) +
        annotate("text", x = xposition, y = 3, label = "Barely detectable", vjust = -0.5) +
        geom_hline(yintercept = 10) +
        annotate("text", x = xposition, y = 10, label = "Weak", vjust = -0.5) +
        geom_hline(yintercept = 29) +
        annotate("text", x = xposition, y = 29, label = "Moderate", vjust = -0.5) +
        geom_hline(yintercept = 64) +
        annotate("text", x = xposition, y = 64, label = "Strong", vjust = -0.5) +
        geom_hline(yintercept = 96) +
        annotate("text", x = xposition, y = 96, label = "Very Strong", vjust = -0.5) +
        geom_hline(yintercept = 180) +
        annotate("text", x = xposition, y = 180, label = "Strongest imaginable", vjust = -0.5)
}
# abline(h = 3, lty = 2) + # "Barely detectable"
# abline(h = 10, lty = 2) + # "Weak"
# abline(h = 29, lty = 2) + # "Moderate"
# abline(h = 64, lty = 2) + # "Strong"
# abline(h = 96, lty = 2) + # "Very Strong"
# abline(h = 180, lty = 2) + # "Strongest imaginable"
# text(x = 3.5, y = 10, labels = "Barely detectable", pos = 3.5)

simple_contrast_singletrial <- function(df) {
# [ CONTRASTS ]  ________________________________________________________________________________ # nolint
# contrast code ________________________________________
df$STIM <- factor(df$stim)

# contrast code 1 linear
df$STIM_linear[df$stimintensity == "low"] <-  -0.5
df$STIM_linear[df$stimintensity == "med"] <-  0
df$STIM_linear[df$stimintensity == "high"] <-  0.5

# contrast code 2 quadratic
df$STIM_quadratic[df$stimintensity == "low"] <-  -0.33
df$STIM_quadratic[df$stimintensity == "med"] <-  0.66
df$STIM_quadratic[df$stimintensity == "high"] <-  -0.33

# cue contrast
df$CUE_high_gt_low[df$cuetype == "cuetype-low"] <-  -0.5 # social influence task
df$CUE_high_gt_low[df$cuetype == "cuetype-high"] <-  0.5 # no influence task

df$stim_ordered <- factor(
        df$stimintensity,
        levels = c("low", "med", "high")
    )

df$cue_name[df$cuetype == "cuetype-low"] <- "low"
df$cue_name[df$cuetype == "cuetype-high"] <- "high"

df$cue_ordered <- factor(
        df$cue_name,
        levels = c("low", "high")
    )
return(df)
}
NPS_simple_contrasts <- function(df) {
# [ CONTRASTS ]  ________________________________________________________________________________ # nolint
# contrast code ________________________________________
df$stim_factor <- factor(df$stim)

# contrast code 1 linear
df$stim_con_linear[df$stim == "lowstim"] <-  -0.5
df$stim_con_linear[df$stim == "medstim"] <-  0
df$stim_con_linear[df$stim == "highstim"] <-  0.5

# contrast code 2 quadratic
df$stim_con_quad[df$stim == "lowstim"] <-  -0.33
df$stim_con_quad[df$stim == "medstim"] <-  0.66
df$stim_con_quad[df$stim == "highstim"] <-  -0.33

# cue contrast
df$cue_con[df$cue == "lowcue"] <-  -0.5 # social influence task
df$cue_con[df$cue == "highcue"] <-  0.5 # no influence task
return(df)
}
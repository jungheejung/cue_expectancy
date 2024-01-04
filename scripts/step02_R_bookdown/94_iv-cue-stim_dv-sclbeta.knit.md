# [physio] SCL {#ch94_SCL}


## Outline
### load data
### subjectwise, groupwise mean






```r
beta <- read.table(file = "/Volumes/spacetop_projects_cue/analysis/physio/glm/factorial/glm-factorial_task-pain_scr.tsv", sep = '\t', header = TRUE)
```



```r
# beta_long <- gather(beta, key = "cue_type", value = "scl_value", intercept, high_stim.high_cue, high_stim.low_cue, med_stim.high_cue, med_stim.low_cue, low_stim.high_cue, low_stim.low_cue)
# beta_con <- simple_contrasts_singletrial(beta_long)

# data_long <- beta %>%
#   gather(key = "stim_cue", value = "value") %>%
#   separate(stim_cue, into = c("stim", "cue"), sep = "\\.")
beta_long <- beta %>%
  gather(key = "stim_cue", value = "beta", starts_with("high_stim"), starts_with("med_stim"), starts_with("low_stim")) %>%
  separate(stim_cue, into = c("stim", "cue"), sep = "\\.")
beta_con <- simple_contrasts_singletrial(beta_long)
```






# [fMRI] FIR ~ task {#ch47_fir_glasser}
---
title: "47_iv-cue-stim_dv-firglasserSPM"
output: html_document
date: "2023-08-13"
---


## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot



## parameters {TODO: ignore}

```r
# parameters
main_dir <- dirname(dirname(getwd()))
datadir <- file.path(main_dir, 'analysis/fmri/nilearn/glm/fir')
analysis_folder  = paste0("model47_iv-cue-stim_dv-firglasserSPM")
analysis_dir <-
  file.path(main_dir,
            "analysis",
            "mixedeffect",
            analysis_folder,
            as.character(Sys.Date())) # nolint
dir.create(analysis_dir,
           showWarnings = FALSE,
           recursive = TRUE)
savedir <- analysis_dir
```


## epoch: stim, high stim vs low stim































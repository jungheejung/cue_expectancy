# [fMRI] FIR ~ task {#ch45_fir_task}
---
title: "45_iv-task_dv-fir.Rmd"
output: html_document
date: "2023-08-04"
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
analysis_folder  = paste0("model46_iv-task_dv-firglasser")
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
























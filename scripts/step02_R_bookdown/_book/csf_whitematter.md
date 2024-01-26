# [QC] SCL {#ch100_white matter csf}
---
title: "whitematter_csf"
output: html_document
date: "2023-07-28"
---




```r
# parameters
main_dir <- dirname(dirname(getwd()))
analysis_folder  = paste0("model96_iv-cue-stim_dv-nuissance")
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

## load data

```r
df <- read.csv(file.path(main_dir, 'scripts/step10_nilearn/whitematter_csf/whitematter_csf_pain.csv' ))
```


```r
myData <- separate(df, fname, into = c("sub", "ses", "run", "runtype","event", "trial", "cuetype", "stimintensity"), sep = "_", remove = FALSE)
myData$sub <- sub("_.*", "", myData$sub)
myData$ses <- sub("_.*", "", myData$ses)
myData$run <- sub("_.*", "", myData$run)
myData$runtype <- str_extract(myData$runtype, "(?<=runtype-).*")
myData$event <- sub("_.*", "", myData$event)
myData$trial <- sub("_.*", "", myData$trial)
myData$cue <- str_extract(myData$cuetype, "(?<=cuetype-).*")
myData$stim <- str_extract(myData$stimintensity, "(?<=stimintensity-)[^.]+")
```

## whitematter


```
## # A tibble: 5,907 × 18
##    fname  sub   ses   run   runtype event trial cuetype stimintensity graymatter
##    <chr>  <chr> <chr> <chr> <chr>   <chr> <chr> <chr>   <chr>              <dbl>
##  1 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.623
##  2 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…     -0.475
##  3 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.26 
##  4 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.116
##  5 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.620
##  6 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.34 
##  7 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.33 
##  8 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.121
##  9 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.790
## 10 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.57 
## # ℹ 5,897 more rows
## # ℹ 8 more variables: whitematter <dbl>, csf <dbl>, cue <chr>, stim <chr>,
## #   STIM <fct>, STIM_linear <dbl>, STIM_quadratic <dbl>, CUE_high_gt_low <dbl>
```

<img src="csf_whitematter_files/figure-html/unnamed-chunk-5-1.png" width="672" />

<img src="csf_whitematter_files/figure-html/unnamed-chunk-6-1.png" width="672" />

## CSF



```
## # A tibble: 5,895 × 18
##    fname  sub   ses   run   runtype event trial cuetype stimintensity graymatter
##    <chr>  <chr> <chr> <chr> <chr>   <chr> <chr> <chr>   <chr>              <dbl>
##  1 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.623
##  2 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…     -0.475
##  3 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.26 
##  4 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.116
##  5 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.620
##  6 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.34 
##  7 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.33 
##  8 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.121
##  9 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.790
## 10 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.57 
## # ℹ 5,885 more rows
## # ℹ 8 more variables: whitematter <dbl>, csf <dbl>, cue <chr>, stim <chr>,
## #   STIM <fct>, STIM_linear <dbl>, STIM_quadratic <dbl>, CUE_high_gt_low <dbl>
```

<img src="csf_whitematter_files/figure-html/unnamed-chunk-7-1.png" width="672" />

<img src="csf_whitematter_files/figure-html/unnamed-chunk-8-1.png" width="672" />

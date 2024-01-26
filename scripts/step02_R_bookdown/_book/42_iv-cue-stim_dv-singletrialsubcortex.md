# [fMRI] singletrial ~ subcortex {#ch42_singletrial_subcortex}

```
author: "Heejung Jung"
date: "2023-07-17"
```
TODO: run and load for every participant
TODO: for loop for roi of interest


## Function {.unlisted .unnumbered}






##TODO: outline

```r
taskname <- 'pain'
# load dataframe
datadir = "/Volumes/spacetop_projects_cue/analysis/fmri/nilearn/deriv08_parcel/subcortex_Tian2020"
filename <- paste("roi-subcortex_task-", taskname, "_*.tsv", sep = "")
common_path <- Sys.glob(file.path(datadir, "sub-*", filename))
df <- do.call("rbind", lapply(common_path, FUN = function(files) {
    as.data.frame(read.csv(files))
  }))
```

```r
df$sub <- sub("^(sub-\\d+).*", "\\1", df$filename)
df$ses <- sub("^.*(ses-\\d+).*", "\\1", df$filename)
df$run <- sub("^.*(run-\\d+).*", "\\1", df$filename)
df$runtype <- sub("^.*runtype-(\\w+)_.*", "\\1", df$filename)
df$trial <- sub("^.*(trial-\\d+).*", "\\1", df$filename)
df$cuetype <- sub("^.*(cuetype-\\w+)_.*", "\\1", df$filename)
df$stimintensity <- sub("^.*(stimintensity-\\w+).*", "\\1", df$filename)
```


```r
# parameters
main_dir <- dirname(dirname(getwd()))
analysis_folder  = paste0("model42_iv-cue-stim_dv-subcortex")
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



```r
pvc <- simple_contrasts_singletrial(df)
  # pvc$task[pvc$runtype == "runtype-pain"] <- "pain"
  # pvc$task[pvc$runtype == "runtype-vicarious"] <- "vicarious"
  # pvc$task[pvc$runtype == "runtype-cognitive"] <- "cognitive"
  # pvc$task <- factor(pvc$task)
```

## LMER

```r
# ----------------------------------------------------------------------
#                               parameters
# ----------------------------------------------------------------------

for (dv in c("HIP.rh", "AMY.rh", "pTHA.rh", "aTHA.rh", "NAc.rh", "GP.rh","PUT.rh","CAU.rh",
             "HIP.lh","AMY.lh","pTHA.lh","aTHA.lh","NAc.lh","GP.lh","PUT.lh","CAU.lh"  )){
taskname = "pain"
ggtitle <- paste(taskname, " - NPS (degree)")
title <- paste(taskname, " - actual")
subject <- "sub"
w <- 10
h <- 6
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
# dv <- "HIP.rh"
dv_keyword = paste0("subcortex-",dv)

data <- pvc
data <- pvc[complete.cases(pvc[[dv]]), ]

model_savefname <- file.path(
  analysis_dir,  
  paste(
    "lmer_task-",taskname,"_rating-",dv_keyword,"_",as.character(Sys.Date()),"_cooksd.txt",
    sep = ""
  )
)

# ----------------------------------------------------------------------
#                               lmer model
# ----------------------------------------------------------------------

cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,
  subject,  dv_keyword,  model_savefname,
  'random_intercept',  print_lmer_output = FALSE
)
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])

data_screen <- data #data[-influential,]

# ----------------------------------------------------------------------
#                     summary statistics for plots
# ----------------------------------------------------------------------

model_iv1 <- "stim_ordered"
model_iv2 <- "cue_ordered"


# ======= NOTE: calculate mean and se ----------------------------------
NPSstimcue_subjectwise <- meanSummary(data_screen,
                                      c(subject, model_iv1, model_iv2), dv)
NPSstimcue_groupwise <- summarySEwithin(
  data = NPSstimcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

# combined_se_calc_cooksd <-NPSstimcue_groupwise
# calculate mean and se
sub_mean <- "mean_per_sub"
group_mean <- "mean_per_sub_norm_mean"
se <- "se"
subject <- "sub"
ggtitle <- paste(taskname, " - ", dv, "Cooksd removed")
title <- paste(taskname, " - ", dv)
xlab <- ""
ylab <- "ROI average activation (A.U)"
ylim <- c(-10, 60)

if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
  color <- c("#1B9E77", "#D95F02")
} else {
  color <- c("#4575B4", "#D73027")
} # if keyword starts with
plot_savefname <- file.path(
  analysis_dir,
  paste(
    "raincloud_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.png",
    sep = ""
  )
)

# ----------------------------------------------------------------------
#                            raincloudplots
# ----------------------------------------------------------------------

g <- plot_halfrainclouds_twofactor(
  NPSstimcue_subjectwise,
  NPSstimcue_groupwise,
  model_iv1,
  model_iv2,
  sub_mean,
  group_mean,
  se,
  subject,
  ggtitle,
  title,
  xlab,
  ylab,
  taskname,
  ylim,
  w,
  h,
  dv_keyword,
  color,
  plot_savefname
)
g
print(g)

k <- plot_lineplot_twofactor(NPSstimcue_groupwise,
                        iv1 = "stim_ordered", iv2 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("high" = "red",
                                  # "med" = "orange",
                                  "low" = "blue"), 
                        ggtitle = title, 
                        xlab = "Stimulus intensity", ylab = "ROI average activation (A.U.)")
k <- k + theme(aspect.ratio=.8)
print(k)
}
```

```
## 
## Attaching package: 'raincloudplots'
```

```
## The following object is masked _by_ '.GlobalEnv':
## 
##     GeomFlatViolin
```

<img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-1.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-2.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-3.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-4.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-5.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-6.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-7.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-8.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-9.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-10.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-11.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-12.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-13.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-14.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-15.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-16.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-17.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-18.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-19.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-20.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-21.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-22.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-23.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-24.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-25.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-26.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-27.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-28.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-29.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-30.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-31.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-5-32.png" width="672" />

## Plot different axis


```r
# ----------------------------------------------------------------------
#                               parameters
# ----------------------------------------------------------------------

for (dv in c("HIP.rh", "AMY.rh", "pTHA.rh", "aTHA.rh", "NAc.rh", "GP.rh","PUT.rh","CAU.rh",
             "HIP.lh","AMY.lh","pTHA.lh","aTHA.lh","NAc.lh","GP.lh","PUT.lh","CAU.lh"  )){
taskname = "pain"
ggtitle <- paste(taskname, " - NPS (degree)")
title <- paste(taskname, " - actual")
subject <- "sub"
w <- 10
h <- 6
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
# dv <- "HIP.rh"
dv_keyword = paste0("subcortex-",dv)

data <- pvc
data <- pvc[complete.cases(pvc[[dv]]), ]

model_savefname <- file.path(
  analysis_dir,  
  paste(
    "lmer_task-",taskname,"_rating-",dv_keyword,"_",as.character(Sys.Date()),"_cooksd.txt",
    sep = ""
  )
)

# ----------------------------------------------------------------------
#                               lmer model
# ----------------------------------------------------------------------

cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,
  subject,  dv_keyword,  model_savefname,
  'random_intercept',  print_lmer_output = FALSE
)
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])

data_screen <- data #data[-influential,]

# ----------------------------------------------------------------------
#                     summary statistics for plots
# ----------------------------------------------------------------------

model_iv2 <- "stim_ordered"
model_iv1 <- "cue_ordered"


# ======= NOTE: calculate mean and se ----------------------------------
NPSstimcue_subjectwise <- meanSummary(data_screen,
                                      c(subject, model_iv1, model_iv2), dv)
NPSstimcue_groupwise <- summarySEwithin(
  data = NPSstimcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

# combined_se_calc_cooksd <-NPSstimcue_groupwise
# calculate mean and se
sub_mean <- "mean_per_sub"
group_mean <- "mean_per_sub_norm_mean"
se <- "se"
subject <- "sub"
ggtitle <- paste(taskname, " - ", dv, "Cooksd removed")
title <- paste(taskname, " - ", dv)
xlab <- ""
ylab <- "ROI average activation (A.U)"
ylim <- c(-10, 60)

if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
  color <- c("#1B9E77", "#D95F02", "black")
} else {
  color <- c("#4575B4", "#D73027", "black")
} # if keyword starts with
plot_savefname <- file.path(
  analysis_dir,
  paste(
    "raincloud_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.png",
    sep = ""
  )
)

# ----------------------------------------------------------------------
#                            raincloudplots
# ----------------------------------------------------------------------

g <- plot_halfrainclouds_twofactor(
  NPSstimcue_subjectwise,
  NPSstimcue_groupwise,
  model_iv1,
  model_iv2,
  sub_mean,
  group_mean,
  se,
  subject,
  ggtitle,
  title,
  xlab,
  ylab,
  taskname,
  ylim,
  w,
  h,
  dv_keyword,
  color,
  plot_savefname
)
g
print(g)

k <- plot_lineplot_twofactor(NPSstimcue_groupwise,
                        iv2 = "stim_ordered", iv1 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("high" = "red",
                                   "med" = "orange",
                                  "low" = "blue"), 
                        ggtitle = title, 
                        xlab = "cue type", ylab = "ROI average activation (A.U.)")
k <- k + theme(aspect.ratio=.8)
print(k)
}
```

<img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-1.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-2.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-3.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-4.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-5.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-6.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-7.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-8.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-9.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-10.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-11.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-12.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-13.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-14.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-15.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-16.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-17.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-18.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-19.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-20.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-21.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-22.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-23.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-24.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-25.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-26.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-27.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-28.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-29.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-30.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-31.png" width="672" /><img src="42_iv-cue-stim_dv-singletrialsubcortex_files/figure-html/unnamed-chunk-6-32.png" width="672" />




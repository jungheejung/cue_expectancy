---
title: "45_iv-task_dv-fir.Rmd"
output: html_document
date: "2023-08-04"
---

## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot





```r
# parameters
main_dir <- dirname(dirname(getwd()))
datadir <- file.path(main_dir, 'analysis/fmri/nilearn/glm/fir')
analysis_folder  = paste0("model45_iv-task_dv-fir")
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


## high stim vs low stim

```r
taskname = "pain"
exclude <- "sub-0001"

filename <- paste0("fir-beta_task-", taskname, "_*_cond-stimlow_delay-20.tsv")
  common_path <- Sys.glob(file.path(datadir, "sub-*",  filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

lowdf <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
    read.table(files, header = TRUE, sep = "\t")
    }))

lowdf$stim <- "low_stim"

filename <- paste0("fir-beta_task-", taskname, "_*_cond-stimhigh_delay-20.tsv")
  common_path <- Sys.glob(file.path(datadir, "sub-*",  filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

highdf <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
    read.table(files, header = TRUE, sep = "\t")
    }))
highdf$stim <- "high_stim"
```


```r
# Assuming your dataframe is named 'df'

# Load the tidyr package if not already loaded
# install.packages("tidyr")
library(tidyr)
df <- rbind(highdf, lowdf)
df_long <- pivot_longer(df, cols = starts_with("tr_"), names_to = "tr_num", values_to = "tr_value")
```



```r
df_long$tr_ordered <- factor(
        df_long$tr_num,
        levels = c(paste0("tr_", 0:19))
    )
df_long$stim_ordered <- factor(
        df_long$stim,
        levels = c("high_stim", "low_stim")
    )
subjectwise <- meanSummary(df_long,
                                      c("sub", "tr_ordered", "stim_ordered"), "tr_value")
groupwise <- summarySEwithin(
  data = subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c("stim_ordered", "tr_ordered"),
  idvar = "sub"
)
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

```r
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402
```




```
## Warning in geom_ribbon(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown parameters: `width`
```

<img src="45_iv-task-dv-fir_files/figure-html/unnamed-chunk-6-1.png" width="672" /><img src="45_iv-task-dv-fir_files/figure-html/unnamed-chunk-6-2.png" width="672" />

```r
# Assuming you have a dataframe named 'data' containing the 20 data points, 'x' and 'y' values, and corresponding standard deviations 'sd'

# Load the ggplot2 library
# install.packages("ggplot2")
library(ggplot2)

# Create the plot
# y = "mean_per_sub_mean"z
ggplot(groupwise, aes(x=tr_ordered,y=mean_per_sub_mean, group = stim_ordered, colour=stim_ordered)) +
  stat_smooth(method="loess", span=0.25, se=TRUE, aes(color=stim_ordered), alpha=0.3) +
  theme_bw()
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning in stats::qt(level/2 + 0.5, pred$df): NaNs produced

## Warning in stats::qt(level/2 + 0.5, pred$df): NaNs produced
```

```
## Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning
## -Inf

## Warning in max(ids, na.rm = TRUE): no non-missing arguments to max; returning
## -Inf
```

<img src="45_iv-task-dv-fir_files/figure-html/unnamed-chunk-7-1.png" width="672" />

```r
# ggplot(data=groupwise, aes(x=tr_ordered, y=mean_per_sub_mean, ymin=se, ymax=se, fill=stim_ordered, linetype=stim_ordered)) + 
#  geom_line() + 
#  geom_ribbon(alpha=0.5)  
# Assuming you have a dataframe named 'data' containing the 20 mean data points and corresponding standard errors
# 'x' represents the x-values (e.g., time points)
# 'mean_y' represents the mean y-values
# 'se_y' represents the standard errors of the mean y-values

# Load the ggplot2 library
# install.packages("ggplot2")
library(ggplot2)
# groupwise$x <- as.numeric(groupwise$x)
# 
# # Sort the dataframe by the 'x' variable (if it's not already sorted)
# data <- data[order(data$x), ]

# Create the plot
# Create the plot with custom span and smoothing method
ggplot(groupwise, aes(x=tr_ordered,y=mean_per_sub_mean)) +
  geom_line() +                                   # Plot the smooth line for the mean
  geom_ribbon(aes(ymin = mean_per_sub_mean - se, ymax = mean_per_sub_mean + se), alpha = 0.3) + # Add the ribbon for standard error
  geom_smooth(method = "loess", span = 0.1, se = FALSE) +       # Add the loess smoothing curve
  labs(x = "X-axis Label", y = "Y-axis Label", title = "Smooth Line with Standard Error Ribbon") +
  theme_minimal()
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="45_iv-task-dv-fir_files/figure-html/unnamed-chunk-8-1.png" width="672" />



## high cue vs low cue

```r
# load dataframes
taskname = "pain"
exclude <- "sub-0001"

filename <- paste0("fir-beta_task-", taskname, "_*_cond-cuelow_delay-20.tsv")
  common_path <- Sys.glob(file.path(datadir, "sub-*",  filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

lowcuedf <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
    read.table(files, header = TRUE, sep = "\t")
    }))

lowcuedf$cue <- "low_cue"

filename <- paste0("fir-beta_task-", taskname, "_*_cond-cuehigh_delay-20.tsv")
  common_path <- Sys.glob(file.path(datadir, "sub-*",  filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

highcuedf <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
    read.table(files, header = TRUE, sep = "\t")
    }))
highcuedf$cue <- "high_cue"

# concatenate dataframes
dfcue <- rbind(highcuedf, lowcuedf)
dfcue_long <- pivot_longer(dfcue, cols = starts_with("tr_"), names_to = "tr_num", values_to = "tr_value")
```



```r
# we want to order the levels so that they make sense in the plots
dfcue_long$tr_ordered <- factor(
        dfcue_long$tr_num,
        levels = c(paste0("tr_", 0:19))
    )
dfcue_long$cue_ordered <- factor(
        dfcue_long$cue,
        levels = c("high_cue", "low_cue")
    )
subjectwise.cue <- meanSummary(dfcue_long,
                                      c("sub", "tr_ordered", "cue_ordered"), "tr_value")
groupwise.cue <- summarySEwithin(
  data = subjectwise.cue,
  measurevar = "mean_per_sub",
  withinvars = c("cue_ordered", "tr_ordered"),
  idvar = "sub"
)
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402
```





```
## Warning in geom_ribbon(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown parameters: `width`
```

<img src="45_iv-task-dv-fir_files/figure-html/unnamed-chunk-11-1.png" width="672" /><img src="45_iv-task-dv-fir_files/figure-html/unnamed-chunk-11-2.png" width="672" />



# single trial correlation between cue and stim ~ cue x stim {#ch38_singletrial_corr}

```
author: "Heejung Jung"
date: "2023-03-04"
```

## What is the purpose of this notebook? {.unlisted .unnumbered}

* Identify the correlation between cue and stimulus phase single trial nifti files
* On discovery, I've calculated the correlated via script: `scripts/step10_nilearn/singletrialLSS/step07_corr_cue_stim.py`




## Function {.unlisted .unnumbered}







```r
main_dir = dirname(dirname(getwd()))
main_dir = "/Users/h/Dropbox/projects_dropbox/social_influence_analysis"
analysis_dir = 
single_trial_dir = file.path(main_dir, 'analysis/fmri/nilearn/deriv04_corrcuestim')
```

## Stack data

```r
combined_se_calc_cooksd <- data.frame()
subject_varkey = 'sub'; dv = 'dotprod'
taskname = "vicarious"
for (taskname in c("pain", "vicarious", "cognitive")) {
filename <- paste("*_runtype-", taskname, "_desc-singletrialcorrelation_x-cue_y-stim.tsv", sep = "")
common_path <- Sys.glob(file.path(single_trial_dir, filename
  ))

exclude <- "sub-0001|sub-0002|sub-0003|sub-0004|sub-0005|sub-0007|sub-0008|sub-0011|sub-0013|sub-0014|sub-0016|sub-0017|sub-0019|sub-0020|sub-0021|sub-0023|sub-0024|sub-0025|sub-0026|sub-0035|sub-0040|sub-0041|sub-0059|sub-0064|sub-0066|sub-0069|sub-0070|sub-0074|sub-0075|sub-0076|sub-0077|sub-0079|sub-0083|sub-0084|sub-0088|sub-0089|sub-0103|sub-0111|sub-0112|sub-0131"

filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

df <- do.call("rbind", lapply(filter_path, FUN = function(files) {
    as.data.frame(read.table(file = files, sep = '\t', header = TRUE))
  }))

is.nan.data.frame <- function(x) {
    do.call(cbind, lapply(x, is.nan))
  }
df[is.nan(df)] <- NA
df[, "sub"] <- factor(df[, subject_varkey])

# B. plot expect rating NA ___________________________________________________
if (hasArg(dv)){
  df_expect_NA <- aggregate(df[, dv], list(df$subject), function(x) sum(is.na(x)))
  df_remove_NA <- df[!is.na(df[dv]), ]
  df <- as.data.frame(df_remove_NA)}

summary(lmer(corr ~ 1 + (1|sub), data = df))



subject <- "sub"
dv <- "corr"
subjectwise_mean <- "mean_per_sub"
    ## summary statistics
subjectwise <- meanSummary(df, c(subject,"ses", "run"), dv)
groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = subjectwise_mean, # variable created from above
        withinvars = c("ses", "run"), #NULL,#c(subject), # iv
        idvar = "sub"
    )
groupwise$task <- taskname
combined_se_calc_cooksd <- rbind(combined_se_calc_cooksd, groupwise)
}
```

```
## Automatically converting the following non-factors to factors: ses, run
## Automatically converting the following non-factors to factors: ses, run
## Automatically converting the following non-factors to factors: ses, run
```

## plot correlation (one-sample-t)


## Lineplot

```r
library(ggpubr)
```

```
## 
## Attaching package: 'ggpubr'
```

```
## The following object is masked from 'package:plyr':
## 
##     mutate
```

```r
DATA = as.data.frame(combined_se_calc_cooksd)
color = c( "#4575B4", "#D73027")
LINEIV1 = "run"
LINEIV2 = "cue_ordered"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
p1 = plot_lineplot_onefactor(DATA, 'pain', 
               LINEIV1, MEAN, ERROR, color, xlab = "Runs" , ylab= "Correlation between \ncue and stimulus", ggtitle = 'pain' )
p2 = plot_lineplot_onefactor(DATA,'vicarious', 
               LINEIV1, MEAN, ERROR, color,xlab = "Runs" , ylab= "Correlation between \ncue and stimulus",ggtitle = 'vicarious')
p3 = plot_lineplot_onefactor(DATA, 'cognitive', 
               LINEIV1, MEAN, ERROR, color,xlab = "Runs" , ylab= "Correlation between \ncue and stimulus",ggtitle = 'cognitive')
ggpubr::ggarrange(p1,p2,p3,ncol = 3, nrow = 1, common.legend = TRUE,legend = "bottom")
```

<img src="38_iv-corr_dv-singletrial_files/figure-html/unnamed-chunk-3-1.png" width="672" />

```r
#plot_filename = file.path(analysis_dir,
       #                   paste('lineplot_task-all_rating-',dv_keyword,'.png', sep = ""))
#ggsave(plot_filename, width = 15, height = 6)
```



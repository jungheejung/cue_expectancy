# [physio] SCL {#ch93_SCL}
---
title: "93_iv-cue_dv-sclbeta"
output: html_document
date: "2023-07-20"
---


## Outline
## load data
## subjectwise, groupwise mean






```r
beta <- read.table(file = "/Volumes/spacetop_projects_cue/analysis/physio/glm/pmod-cue/glm-pmodcue_task-pain_scr.tsv", sep = '\t', header = TRUE)

beta_long <- gather(beta, key = "cue_type", value = "scl_value", intercept, low_cue, high_cue)
beta_con <- simple_contrasts_singletrial(beta_long)
```



```r
# ----------------------------------------------------------------------
#                     summary statistics for plots
# ----------------------------------------------------------------------
subject <- "sub"
model_iv <- "cue_ordered"
dv <- "scl_value"
dv_keyword <- "sclbeta"
taskname <- "pain"
analysis_dir <- "/Users/h/Desktop" # TODO

# ======= NOTE: calculate mean and se ----------------------------------
SCLcue_subjectwise <- meanSummary(beta_con,
                                      c(subject, model_iv), dv)
SCLcue_groupwise <- summarySEwithin(
  data = SCLcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv),
  idvar = subject
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
SCLcue_groupwise$task <- taskname
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
analysis_dir <- "/Users/h/Desktop"
# combined_se_calc_cooksd <-NPSstimcue_groupwise
# calculate mean and se
sub_mean <- "mean_per_sub"
group_mean <- "mean_per_sub_norm_mean"
se <- "se"
subject <- "sub"
ggtitle <- paste( dv)
title <- paste( dv)
xlab <- ""
ylab <- "SCL beta coefficients (A.U.)"

dv_keyword <- "fdmean"
if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
  color <- c("gray", "blue",  "red")
} else {
  color <- c("gray", "blue", "red")
} # if keyword starts with
plot_savefname <- file.path(
  analysis_dir,
  paste(
    "raincloud_qc-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.png",
    sep = ""
  )
)

# ----------------------------------------------------------------------
#                            raincloudplots
# ----------------------------------------------------------------------


ylim <- c(-1, 1.5)
# taskname = "pain"
w <- 10; h <- 5
g <- plot_halfrainclouds_onefactor(
  SCLcue_subjectwise,
  SCLcue_groupwise,
  model_iv,
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
```

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], x =
## as.numeric(as.factor(.data[[iv]])) - : Ignoring unknown aesthetics: fill
```

```r
g <- g + theme_bw() + theme_classic()
print(g)
```

<img src="93_iv-cue_dv-sclbeta_files/figure-html/unnamed-chunk-3-1.png" width="672" />

```r
SCLcue_groupwise$task = taskname

k <- plot_lineplot_onefactorthick(SCLcue_groupwise,
                             taskname = "pain", 
                        iv = "cue_ordered",
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("intercept" = "gray",
                                  "high" = "red",
                                  "low" = "blue"), 
                        ggtitle = title, 
                        xlab = "Cue level", ylab = "SCL activation (A.U.)")
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## ℹ Please use `linewidth` instead.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

```r
k <- k + theme(aspect.ratio=.8)
print(k)
```

<img src="93_iv-cue_dv-sclbeta_files/figure-html/unnamed-chunk-3-2.png" width="672" />



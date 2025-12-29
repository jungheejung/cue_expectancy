# [physio] SCL {#ch92_SCL}

---

title: "92_SCL_beta"
output: html_document
date: "2023-07-20"

---

## Outline

### load data

### subjectwise, groupwise mean

```r
# df <- read.csv("/Users/h/Documents/summer/summer_RA/fdmean_run_type.tsv")
beta <- read.table(file = "/Volumes/spacetop_projects_cue/analysis/physio/glm/pmod-stimintensity/glm-pmodintenisy_task-pain_scr.tsv", sep = '\t', header = TRUE)
```

```r
beta_long <- gather(beta, key = "stim_type", value = "scl_value", intercept, low_stim, med_stim, high_stim)
beta_con <- simple_contrasts_singletrial(beta_long)
```

```r
# ----------------------------------------------------------------------
#                     summary statistics for plots
# ----------------------------------------------------------------------
subject <- "sub"
model_iv <- "stim_ordered"
dv <- "scl_value"
taskname <- "pain"
dv_keyword <- "SCL"
analysis_dir <- file.path(main_dir, "analysis", "mixedeffect", "model92_iv-stim_dv-sclbeta")
# model_iv2 <- "cue_ordered"


# ======= NOTE: calculate mean and se ----------------------------------
SCLstim_subjectwise <- meanSummary(beta_con,
                                      c(subject, model_iv), dv)
SCLstim_groupwise <- summarySEwithin(
  data = SCLstim_subjectwise,
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
SCLstim_groupwise$task <- taskname
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
  color <- c("#4274AD", "#C5263A")
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
  color <- c("gray", "#1B9E77", "#D95F02", "red")
} else {
  color <- c("gray", "#1B9E77", "#D95F02", "red")
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
# TODO:
# * change the range of the figure
# * change the x-axis
# * drop the NA conditions
# * change theme
# * adjust the box plots

ylim <- c(-2, 2)
taskname = "all"
w <- 10; h <- 5
g <- plot_halfrainclouds_onefactor(
  SCLstim_subjectwise,
  SCLstim_groupwise,
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

<img src="92_iv-stim_dv-sclbeta_files/figure-html/unnamed-chunk-4-1.png" width="672" />

```r
SCLstim_groupwise$task = "pain"

k <- plot_lineplot_onefactorthick(SCLstim_groupwise,
                             taskname = "pain",
                        iv = "stim_ordered",
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("intercept" = "gray",
                                  "high" = "red",
                                  "med" = "orange",
                                  "low" = "blue"),
                        ggtitle = title,
                        xlab = "Stimulus intensity", ylab = "ROI average activation (A.U.)")
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

<img src="92_iv-stim_dv-sclbeta_files/figure-html/unnamed-chunk-4-2.png" width="672" />

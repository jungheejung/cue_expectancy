# [QC] fdmean {#ch98_QCfdmean}

---

title: "fdmean"
output: html_document
date: "2023-07-18"

---

```r
library(car)
```

```
## Loading required package: carData
```

```r
library(psych)
```

```
##
## Attaching package: 'psych'
```

```
## The following object is masked from 'package:car':
##
##     logit
```

```r
library(reshape)
library(plyr); library(dplyr)
```

```
##
## Attaching package: 'plyr'
```

```
## The following objects are masked from 'package:reshape':
##
##     rename, round_any
```

```
##
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:plyr':
##
##     arrange, count, desc, failwith, id, mutate, rename, summarise,
##     summarize
```

```
## The following object is masked from 'package:reshape':
##
##     rename
```

```
## The following object is masked from 'package:car':
##
##     recode
```

```
## The following objects are masked from 'package:stats':
##
##     filter, lag
```

```
## The following objects are masked from 'package:base':
##
##     intersect, setdiff, setequal, union
```

```r
library(tidyselect)
library(tidyr)
```

```
##
## Attaching package: 'tidyr'
```

```
## The following objects are masked from 'package:reshape':
##
##     expand, smiths
```

```r
library(stringr)
library(lmerTest)
```

```
## Loading required package: lme4
```

```
## Loading required package: Matrix
```

```
##
## Attaching package: 'Matrix'
```

```
## The following objects are masked from 'package:tidyr':
##
##     expand, pack, unpack
```

```
## The following object is masked from 'package:reshape':
##
##     expand
```

```
##
## Attaching package: 'lmerTest'
```

```
## The following object is masked from 'package:lme4':
##
##     lmer
```

```
## The following object is masked from 'package:stats':
##
##     step
```

```r
library(gghalves)
```

```
## Loading required package: ggplot2
```

```
##
## Attaching package: 'ggplot2'
```

```
## The following objects are masked from 'package:psych':
##
##     %+%, alpha
```

```r
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")
main_dir = dirname(dirname(getwd()))
file.sources = list.files(file.path(main_dir, "scripts/step02_R/utils"),
                          pattern="*.R",
                          full.names=TRUE,
                          ignore.case=TRUE)
sapply(file.sources,source,.GlobalEnv)
```

```
## ✔ Setting active project to
## '/Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R_bookdown'
```

```
## ✔ Saving
## 'ropenscilabs/actions_sandbox/.github/workflows/deploy_bookdown.yml@master' to
## '.github/workflows/deploy_bookdown.yml'
```

```
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/compute_ICC.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/filter_df_ses_trial.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/ggplot_hline_bartoshuk.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/lmer_onefactor_cooksd_fix.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/lmer_onefactor_cooksd_randomintercept_fix.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/lmer_onefactor_cooksd_randomintercept.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/lmer_onefactor_cooksd.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/lmer_twofactor_cooksd_fix.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/lmer_twofactor_cooksd.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/load_extraction.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/load_pvc_beh.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/load_task_social_df.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/load_tasksocial_ses.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/meanSummary_2dv.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/meanSummary.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/normdatawithin.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/NPS_load_df.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/NPS_simple_contrast.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/NPS_summary_for_plots.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_binned_rating.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_errorbar.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_geompointrange_onefactor.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_ggplot_correlation.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_halfrainclouds_onefactor.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_halfrainclouds_sigmoid.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_halfrainclouds_twofactor.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_halfrainclouds_twofactorthick.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_lineplot_onefactor.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_lineplot_onefactorthick.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_lineplot_twofactor_subset.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_lineplot_twofactor_subsetthick.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_lineplot_twofactor.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_lineplot_twofactorthick.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_rainclouds_onefactor.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_rainclouds_twofactor.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_signature_twolineplot.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_signature_tworaincloud.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_timeseries_bar_grayarrange.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_timeseries_bar.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_timeseries.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/plot_twovariable.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/R_rainclouds.R
## value   GeomFlatViolin,3
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/simple_contrast_singletrial.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/summaryplotPVC.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/summarySE.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/summarySEwithin.R
## value   ?
## visible FALSE
##         /Users/h/Documents/projects_local/cue_expectancy/scripts/step02_R/utils/use_github_action-bookdown.R
## value   FALSE
## visible FALSE
```

```r
# load in the dataframe
# create contrasts for pain vs non-pain runs
# summary statistics for each subject
# group wise statistics
# plot
```

```r
# df <- read.csv("/Users/h/Documents/summer/summer_RA/fdmean_run_type.tsv")

fdmeandf <- read.table(file = file.path(main_dir, "resources/qcreports/fdmean_run_type.tsv"), sep = '\t', header = TRUE)
```

```r
# contrast code 1 linear

fdmeandf$PAIN_NOPAIN[fdmeandf$run_type == "pain"] <- 0.5
fdmeandf$PAIN_NOPAIN[fdmeandf$run_type == "vicarious"] <- -0.5
fdmeandf$PAIN_NOPAIN[fdmeandf$run_type == "cognitive"] <- -0.5
df <- fdmeandf %>% drop_na(PAIN_NOPAIN)
```

```r
df$sub_factor <- factor(df$sub)
model.fdmean <- lmer(fd_mean ~ PAIN_NOPAIN + (1|sub_factor), data=df)
```

```r
summary(model.fdmean)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: fd_mean ~ PAIN_NOPAIN + (1 | sub_factor)
##    Data: df
##
## REML criterion at convergence: -4862.4
##
## Scaled residuals:
##     Min      1Q  Median      3Q     Max
## -3.6591 -0.4129 -0.0673  0.2707 12.2627
##
## Random effects:
##  Groups     Name        Variance Std.Dev.
##  sub_factor (Intercept) 0.002447 0.04947
##  Residual               0.002633 0.05131
## Number of obs: 1668, groups:  sub_factor, 112
##
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)
## (Intercept) 1.555e-01  4.905e-03 1.131e+02   31.70   <2e-16 ***
## PAIN_NOPAIN 3.394e-02  2.733e-03 1.560e+03   12.42   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## Correlation of Fixed Effects:
##             (Intr)
## PAIN_NOPAIN 0.106
```

```r
df$run_name[df$run_type == "pain"] <- "pain"
df$run_name[df$run_type == "vicarious"] <- "non-pain"
df$run_name[df$run_type == "cognitive"] <- "non-pain"

df$pain_ordered <- factor(
        df$run_name,
        levels = c("non-pain", "pain")
    )

subject <- "sub_factor"
model_iv <- "pain_ordered"
dv <- "fd_mean"
subjectwise <- meanSummary(df,c(subject, model_iv), dv)

groupwise <- summarySEwithin(
  data=subjectwise,
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
analysis_dir <- "/Users/h/Desktop"
# combined_se_calc_cooksd <-NPSstimcue_groupwise
# calculate mean and se
sub_mean <- "mean_per_sub"
group_mean <- "mean_per_sub_norm_mean"
se <- "se"
subject <- "sub_factor"
ggtitle <- paste( dv)
title <- paste( dv)
xlab <- ""
ylab <- "FD mean (mm)"

dv_keyword <- "fdmean"
if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
  color <- c("#1B9E77", "#D95F02")
} else {
  color <- c("#4274AD", "#C5263A")
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

ylim <- c(0,.6)
taskname = "all"
w <- 10; h <- 5
g <- plot_halfrainclouds_onefactor(
  subjectwise,
  groupwise,
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

<img src="98_qc-fdmean_files/figure-html/unnamed-chunk-8-1.png" width="672" />

```r
k <- plot_lineplot_twofactor(groupwise,
                        iv1 = "stim_ordered", iv2 = "cue_ordered",
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("pain" = "red",
                                  "non-pain" = "gray"),
                        ggtitle="fdmean pain vs nonpain")
                                  # "med" = "orange",
```

```r
df_example <- tibble(x = c(1,2,NA), y = c("a", NA, "b"))
df_example %>% drop_na(x)
```

```
## # A tibble: 2 × 2
##       x y
##   <dbl> <chr>
## 1     1 a
## 2     2 <NA>
```

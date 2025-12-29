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

```r
model.factorial <- lmer(beta ~ STIM_linear*cue_factor + STIM_quadratic*cue_factor + (1|sub), data = beta_con)
summary(model.factorial)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: beta ~ STIM_linear * cue_factor + STIM_quadratic * cue_factor +
##     (1 | sub)
##    Data: beta_con
##
## REML criterion at convergence: 1146.3
##
## Scaled residuals:
##     Min      1Q  Median      3Q     Max
## -5.7161 -0.4172 -0.0975  0.2666  7.7671
##
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 0.07296  0.2701
##  Residual             0.29447  0.5427
## Number of obs: 660, groups:  sub, 44
##
## Fixed effects:
##                                   Estimate Std. Error        df t value
## (Intercept)                        0.35230    0.05191  68.51381   6.787
## STIM_linear                        0.36609    0.07317 617.28580   5.003
## cue_factorlow_cue                 -0.00186    0.04224 617.28580  -0.044
## STIM_quadratic                     0.06508    0.06401 617.28580   1.017
## STIM_linear:cue_factorlow_cue     -0.13010    0.10348 617.28580  -1.257
## cue_factorlow_cue:STIM_quadratic  -0.15433    0.09052 617.28580  -1.705
##                                  Pr(>|t|)
## (Intercept)                      3.32e-09 ***
## STIM_linear                      7.36e-07 ***
## cue_factorlow_cue                  0.9649
## STIM_quadratic                     0.3097
## STIM_linear:cue_factorlow_cue      0.2091
## cue_factorlow_cue:STIM_quadratic   0.0887 .
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## Correlation of Fixed Effects:
##             (Intr) STIM_l c_fct_ STIM_q STIM_:
## STIM_linear  0.000
## cu_fctrlw_c -0.407  0.000
## STIM_qudrtc  0.000  0.000  0.000
## STIM_lnr:__  0.000 -0.707  0.000  0.000
## c_fc_:STIM_  0.000  0.000  0.000 -0.707  0.000
```

```r
# ----------------------------------------------------------------------
#                     summary statistics for plots
# ----------------------------------------------------------------------
subject <- "sub"
model_iv1 <- "stim_ordered"
model_iv2 <- "cue_ordered"
dv <- "beta"
dv_keyword <- "sclbeta"
taskname <- "pain"
# model_iv2 <- "cue_ordered"
analysis_dir <- "/Users/h/Desktop" # TODO
beta_con$taskname <- taskname
# ======= NOTE: calculate mean and se ----------------------------------
SCLstim_subjectwise <- meanSummary(beta_con,
                                      c(subject, model_iv1, model_iv2), dv)
SCLstim_groupwise <- summarySEwithin(
  data = SCLstim_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
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
  color <- c( "blue",  "red")
} else {
  color <- c( "blue", "red")
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

ylim <- c(-1, 1)
# taskname = "pain"
w <- 10; h <- 5
g <- plot_halfrainclouds_twofactor(
  SCLstim_subjectwise,
  SCLstim_groupwise,
  model_iv1, model_iv2,
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
g <- g + theme_bw() + theme_classic()
print(g)
```

<img src="94_iv-cue-stim_dv-sclbeta_files/figure-html/unnamed-chunk-5-1.png" width="672" />

```r
SCLstim_groupwise$task = taskname

k <- plot_lineplot_twofactor_subsetthick(SCLstim_groupwise,
                             taskname="pain",
                        iv1="stim_ordered",
                        iv2="cue_ordered",
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c( "high" = "red",
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

<img src="94_iv-cue-stim_dv-sclbeta_files/figure-html/unnamed-chunk-5-2.png" width="672" />

# RL simulation Jepma PE {#ch23_jepmaPE}


## Overview
The purpose of this markdown is to benchmark the plots from Jepma et al. (2018). 
Here, we plot the expectancy ratings and the actual ratings, with the high and low cues -- in one panel. 
PE is calculated based on behavioral ratings

### Some thoughts, TODOs {.unlisted .unnumbered}
* plot 2. some runs were repeated or omitted for the subjects that have more than 72 trials. I need to identify that list and work on the behavioral data. 
* I need to check whether the counterbalancing was done correctly. 




## load behavioral daata

```r
df = read.csv(file.path(main_dir, 'resources', 'references', 'cue_behavioraldata.csv'))
```


```r
colnames(df)
```

```
##  [1] "X"                  "sub"                "ses"               
##  [4] "run"                "task"               "trialindex"        
##  [7] "IV_cuelevel"        "IV_stimintensity"   "RATING_expectation"
## [10] "RATING_outcome"
```


```r
# PE :: prediction error ______________________________________________________
df$PE =   df$RATING_outcome - df$RATING_expectation
# Lag expectation rating ______________________________________________________
# per run/ses/sub
data_a3lag <- df %>%
  group_by(sub,ses,run) %>% 
  mutate(prev_trial.RATING_expectation = lag(RATING_expectation, n = 1, default = NA)) %>% 
  mutate(next_trial.RATING_expectation = lead(RATING_expectation, n = 1, default = NA)) %>%
  mutate(ave.RATING_expectation = mean(RATING_expectation, na.rm = TRUE))
data_a3lag <- data_a3lag[!is.na(data_a3lag$ave.RATING_expectation),]
taskname = 'pain'
data_a3lag$next_trial.RATING_expect_fill = coalesce(data_a3lag$next_trial.RATING_expectation, data_a3lag$ave.RATING_expectation) 
data_a3lag$prev_trial.RATING_expect_fill = coalesce(data_a3lag$prev_trial.RATING_expectation, data_a3lag$ave.RATING_expectation) 

data_a3lag <- data_a3lag[data_a3lag$task == 'pain',]
# EXPECTUPDATE :: expectation (N) - expectation (N-1) ________________________
df_jepma <- data_a3lag %>%
  # group_by(sub,ses,run) %>%
  mutate(EXPECTUPDATE_NEXT =  RATING_expectation- next_trial.RATING_expect_fill)  %>%
  mutate(EXPECTUPDATE_PREV =  RATING_expectation- prev_trial.RATING_expect_fill)  %>%
  mutate(EXPECTUPDATE_PREV_JEPMA =  (RATING_expectation- prev_trial.RATING_expect_fill)/(PE+1))
```


```r
df_jepma$PE_type[df_jepma$PE >  0] <- "aversive" # outcome > expect
```

```
## Warning: Unknown or uninitialised column: `PE_type`.
```

```r
df_jepma$PE_type[df_jepma$PE <= 0] <- "appetitive" # outcome < expect
df_jepma$PE_con[df_jepma$PE <=  0] <- -1
```

```
## Warning: Unknown or uninitialised column: `PE_con`.
```

```r
df_jepma$PE_con[df_jepma$PE > 0] <-  1
df_jepma$cue_con[df_jepma$IV_cuelevel == "low_cue"] <- -1
```

```
## Warning: Unknown or uninitialised column: `cue_con`.
```

```r
df_jepma$cue_con[df_jepma$IV_cuelevel == "high_cue"] <- 1
df_jepma <- df_jepma[!is.na(df_jepma$RATING_expectation),]

write.csv(df_jepma, '/Users/h/Desktop/cuerating_0505.csv')
```

## JEPMA

```r
# summary statistics ____________________________________________________________
subject = "sub"
model_iv1 = "PE_type"
model_iv2 =  "IV_cuelevel"

dv <- "EXPECTUPDATE_PREV_JEPMA" #"PE"
    subjectwise <- meanSummary(
        df_jepma,
        c(subject, model_iv1, model_iv2), dv
    )
    groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = "mean_per_sub",
        withinvars = c(model_iv1, model_iv2), idvar = subject
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

```
## Automatically converting the following non-factors to factors: PE_type, IV_cuelevel
```

```r
    #  calculate mean and se  ----------------------------------------------------------------------------
    sub_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    se <- "se"
    subject <- "sub"
    ggtitle <- paste(taskname, "Confirmation bias in expectation updating")
    legend_title <- "cue levels"
    title <- paste(taskname, " - Actual")
    xlab <- ""
    ylab <- "Learning Rate"
    ylim <- c(-250,250)
    dv_keyword <- "learning rate"
    if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color <- c("#1B9E77", "#D95F02")
    } else {
        color <- c( "#D73027", "#4575B4")
    } # if keyword starts with]
    analysis_dir = '/Users/h/Desktop'
    plot_savefname <- file.path(
        analysis_dir,
        paste("raincloud_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), "_cooksd.png",
            sep = ""
        )
    )

plot_halfrainclouds_twofactor(subjectwise, groupwise,
                                      model_iv1, model_iv2, sub_mean, group_mean, se, subject,
                                      ggtitle, legend_title, xlab, ylab, task_name, ylim,
                                      w, h, dv_keyword, color, save_fname)
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-6-1.png" width="672" />

```r
plot_lineplot_twofactor(groupwise, model_iv1, model_iv2, "mean_per_sub_norm_mean", error = "se",
                      color = c( high_cue = "#D73027", low_cue = "#4575B4"), 
                      ggtitle, 
                      xlab= "Stimulus intensity", 
                      ylab = "Learning rate") 
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-6-2.png" width="672" />

## PREVIOUS TRIAL w/o dividing (PE+1)

```r
# summary statistics ____________________________________________________________
subject = "sub"
model_iv1 = "PE_type"
model_iv2 =  "IV_cuelevel"

dv <- "EXPECTUPDATE_PREV" #"PE"
    subjectwise <- meanSummary(
        df_jepma,
        c(subject, model_iv1, model_iv2), dv
    )
    groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = "mean_per_sub",
        withinvars = c(model_iv1, model_iv2), idvar = subject
    )
```

```
## Automatically converting the following non-factors to factors: PE_type, IV_cuelevel
```

```r
    #  calculate mean and se  ----------------------------------------------------------------------------
    sub_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    se <- "se"
    subject <- "sub"
    ggtitle <- paste(taskname, "Confirmation bias in expectation updating")
    legend_title <- "cue levels"
    title <- paste(taskname, " - Actual")
    xlab <- ""
    ylab <- "Expectation update on previous trial"
    ylim <- c(-250,250)
    dv_keyword <- "learning rate"
    if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color <- c("#1B9E77", "#D95F02")
    } else {
        color <- c( "#D73027", "#4575B4")
    } # if keyword starts with]
    analysis_dir = '/Users/h/Desktop'
    plot_savefname <- file.path(
        analysis_dir,
        paste("raincloud_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), "_cooksd.png",
            sep = ""
        )
    )

plot_halfrainclouds_twofactor(subjectwise, groupwise,
                                      model_iv1, model_iv2, sub_mean, group_mean, se, subject,
                                      ggtitle, legend_title, xlab, ylab, task_name, ylim,
                                      w, h, dv_keyword, color, save_fname)
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-7-1.png" width="672" />

```r
plot_lineplot_twofactor(groupwise, model_iv1, model_iv2, "mean_per_sub_norm_mean", error = "se",
                      color = c( high_cue = "#D73027", low_cue = "#4575B4"), 
                      ggtitle, 
                      xlab= "", 
                      ylab = "Expectation update on next trial") 
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-7-2.png" width="672" />


## NEXT TRIAL WITHOUT DIVIDING (PE+1)

```r
# summary statistics ____________________________________________________________
subject = "sub"
model_iv1 = "PE_type"
model_iv2 =  "IV_cuelevel"

dv <- "EXPECTUPDATE_NEXT" #"PE"
    subjectwise <- meanSummary(
        df_jepma,
        c(subject, model_iv1, model_iv2), dv
    )
    groupwise <- summarySEwithin(
        data = subjectwise,
        measurevar = "mean_per_sub",
        withinvars = c(model_iv1, model_iv2), idvar = subject
    )
```

```
## Automatically converting the following non-factors to factors: PE_type, IV_cuelevel
```

```r
    #  calculate mean and se  ----------------------------------------------------------------------------
    sub_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    se <- "se"
    subject <- "sub"
    ggtitle <- paste(taskname, " - Confirmation bias in expectation updating")
    legend_title <- "cue levels"
    title <- paste(taskname, " - Actual")
    xlab <- ""
    ylab <- "Expectation update on next trial"
    ylim <- c(-250,250)
    dv_keyword <- "learning rate"
    if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color <- c("#1B9E77", "#D95F02")
    } else {
        color <- c( "#D73027", "#4575B4")
    } # if keyword starts with]
    analysis_dir = '/Users/h/Desktop'
    plot_savefname <- file.path(
        analysis_dir,
        paste("raincloud_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), "_cooksd.png",
            sep = ""
        )
    )

plot_halfrainclouds_twofactor(subjectwise, groupwise,
                                      model_iv1, model_iv2, sub_mean, group_mean, se, subject,
                                      ggtitle, legend_title, xlab, ylab, task_name, ylim,
                                      w, h, dv_keyword, color, save_fname)
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-8-1.png" width="672" />

```r
plot_lineplot_twofactor(groupwise, model_iv1, model_iv2, "mean_per_sub_norm_mean", error = "se",
                      color = c( high_cue = "#D73027", low_cue = "#4575B4"), 
                      ggtitle, 
                      xlab= "Stimulus intensity", 
                      ylab = "Expectation difference from previous trial") 
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-8-2.png" width="672" />


```r
plot_lineplot_twofactor(groupwise, model_iv1, model_iv2, "mean_per_sub_norm_mean", error = "se",
                      color = c( high_cue = "#D73027", low_cue = "#4575B4"), 
                      ggtitle, 
                      xlab= "Stimulus intensity", 
                      ylab = "Learning rate") 
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-9-1.png" width="672" />

```
library(plyr)
subjectwise_cuetype = meanSummary_2dv(DATA=df_jepma,
        GROUP = c("sub", "trialindex", "IV_cuelevel"), DV1 = "PE", DV2 = "EXPECTUPDATE")
plot_twovariable(subjectwise_cuetype, iv1 = "DV1_mean_per_sub", iv2 = "DV2_mean_per_sub", group = "IV_cuelevel", subject = "sub", xmin=-50, xmax=50, ymin=-50,ymax=50,
xlab="PE", ylab="Expectation update", ggtitle="", color_scheme=c( high_cue = "#D73027", low_cue = "#4575B4"), alpha=.8, fit_lm=TRUE, lm_method = "lm", identity_line=TRUE, size=NULL)

```

```r
subjectwise_cuetype_groupby = meanSummary_2dv(DATA=df_jepma,
        GROUP = c("sub", "IV_cuelevel"), DV1 = "PE", DV2 = "EXPECTUPDATE_PREV")
plot_twovariable(df_jepma, iv1 = "PE", iv2 = "EXPECTUPDATE_PREV", group = "IV_cuelevel", subject = "sub", xmin=-50, xmax=50, ymin=-50,ymax=50,
xlab="PE", ylab="Expectation update", ggtitle="", color_scheme=c( high_cue = "#D73027", low_cue = "#4575B4"), alpha=.8, fit_lm=TRUE, lm_method = "lm", identity_line=TRUE, size=NULL)
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## ℹ Please use `linewidth` instead.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 8 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 8 rows containing missing values (`geom_point()`).
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-10-1.png" width="672" />

```r
subjectwise_cuetype_groupby = meanSummary_2dv(DATA=df_jepma,
        GROUP = c("sub", "IV_cuelevel"), DV1 = "PE", DV2 = "EXPECTUPDATE_PREV_JEPMA")
plot_twovariable(df_jepma, iv1 = "PE", iv2 = "EXPECTUPDATE_PREV_JEPMA", group = "IV_cuelevel", subject = "sub", xmin=-50, xmax=50, ymin=-50,ymax=50,
xlab="PE", ylab="Expectation update", ggtitle="", color_scheme=c( high_cue = "#D73027", low_cue = "#4575B4"), alpha=.8, fit_lm=TRUE, lm_method = "lm", identity_line=TRUE, size=NULL)
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 10 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 10 rows containing missing values (`geom_point()`).
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-11-1.png" width="672" />

# use sjplot

```r
model.l <- lmer(EXPECTUPDATE_PREV_JEPMA ~ 1+ PE*IV_cuelevel + (1+ IV_cuelevel|sub), data = df_jepma, 
                control=lmerControl(check.conv.singular = .makeCC(action = "ignore",  tol = 1e-4)))
```

```
## Warning: Model failed to converge with 1 negative eigenvalue: -2.2e+00
```

```r
summary(model.l)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: EXPECTUPDATE_PREV_JEPMA ~ 1 + PE * IV_cuelevel + (1 + IV_cuelevel |  
##     sub)
##    Data: df_jepma
## Control: lmerControl(check.conv.singular = .makeCC(action = "ignore",  
##     tol = 1e-04))
## 
## REML criterion at convergence: 56318.6
## 
## Scaled residuals: 
##    Min     1Q Median     3Q    Max 
## -9.066 -0.047 -0.023 -0.001 56.454 
## 
## Random effects:
##  Groups   Name               Variance Std.Dev. Corr
##  sub      (Intercept)           0      0.00        
##           IV_cuelevellow_cue  230     15.17     NaN
##  Residual                    5458     73.88        
## Number of obs: 4916, groups:  sub, 95
## 
## Fixed effects:
##                         Estimate Std. Error         df t value Pr(>|t|)
## (Intercept)              1.85058    1.56077 4799.92655   1.186    0.236
## PE                       0.03418    0.04992 4799.92655   0.685    0.494
## IV_cuelevellow_cue       1.63106    2.83138  160.03575   0.576    0.565
## PE:IV_cuelevellow_cue   -0.08428    0.07071 3669.63634  -1.192    0.233
## 
## Correlation of Fixed Effects:
##             (Intr) PE     IV_cl_
## PE           0.300              
## IV_clvllw_c -0.551 -0.166       
## PE:IV_clvl_ -0.212 -0.706 -0.093
```

```r
library(sjPlot)
plot_model(model.l, type = "pred", terms = c("PE", "IV_cuelevel"))
```

<img src="23_RL_jepma_simulation_PE_files/figure-html/unnamed-chunk-13-1.png" width="672" />




```r
# subjectwise_cuetype_groupby = meanSummary_2dv(DATA=df_jepma,
#         GROUP = c("sub", "IV_cuelevel"), DV1 = "PE", DV2 = "EXPECTUPDATE_JEPMA")
# plot_twovariable(df_jepma, iv1 = "PE", iv2 = "EXPECTUPDATE", group = "IV_cuelevel", subject = "sub", xmin=-50, xmax=50, ymin=-50,ymax=50,
# xlab="PE", ylab="Expectation update", ggtitle="", color_scheme=c( high_cue = "#D73027", low_cue = "#4575B4"), alpha=.8, fit_lm=TRUE, lm_method = "lm", identity_line=TRUE, size=NULL)
```




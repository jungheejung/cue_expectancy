# PE and NPS {#ch24_RL_PE_NPS}
---
title: "24_RL_iv-PE_dv-NPS"
output: html_document
date: "2023-11-05"
---

## What is the purpose of this notebook? {.unlisted .unnumbered}
Here, I investigate the relationship between prediction errors and NPS extracted values.
The question we ask is, whether the cue-expectancy effects of NPS are driven by prediction errors. 






```r
# load NPS dot product
NPSdf <- read.csv(file.path(main_dir, 'analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv' ))

# load RL data
RLdf <- read.csv(file.path(main_dir, "/data/RL/modelfit_jepma_0525/table_pain.csv"))
# grab intersection of data using the sub column
```

some data wrangling: split filenames into columns. This will serve as metadata. NPSsplit
We'll use this to merge NPSsplit and RLdf


```r
NPSsplit <- NPSdf %>%
  # Extract the components from the filename column
  extract(col = singletrial_fname, into = c("sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"),
          regex = "(sub-\\w+)_+(ses-\\w+)_+(run-\\w+)_+(runtype-\\w+)_+(event-\\w+)_+(trial-\\w+)_+(cuetype-\\w+)_+(stimintensity-\\w+).nii.gz") %>%
  # Extract numbers and keywords as specified
  mutate(
    src_subject_id = as.integer(str_extract(sub, "\\d+")),
    session_id = as.integer(str_extract(ses, "\\d+")),
    param_run_num = as.integer(str_extract(run, "\\d+")),
    trial_index_runwise = as.integer(str_extract(trial, "\\d+")) + 1,
    param_cue_type = case_when(
      str_detect(cuetype, "low") ~ "low_cue",
      str_detect(cuetype, "high") ~ "high_cue"
    ), 
    param_task_name = str_replace(runtype, "runtype-", ""), 
    param_stimulus_type = case_when(
      stimintensity == "stimintensity-low" ~ "low_stim",
      stimintensity == "stimintensity-med" ~ "med_stim",
      stimintensity == "stimintensity-high" ~ "high_stim",
      TRUE ~ stimintensity  # Retain original value if neither "low" nor "high"
    )
  ) %>%
  
  # Select and rename the necessary columns
  select(
    src_subject_id,
    session_id,
    param_run_num,
    param_task_name,
    event,
    trial_index_runwise,
    param_cue_type,
    param_stimulus_type,
    NPSpos
  )
    # stimintensity
```

merge the two dataframes

```r
merge_df <- inner_join(NPSsplit, RLdf, by = c("src_subject_id",
    "session_id",
    "param_run_num",
    "param_task_name","param_cue_type", "param_stimulus_type", "trial_index_runwise"))

# result_df will contain rows that have matching values in columns A, B, and C in both df1 and df2.
```

## scatter plot

```r
merge_df$sub <- factor(merge_df$src_subject_id)
model.NPSRL = lmer(NPSpos ~ PE_mdl3 + (PE_mdl3 | sub) + (1|session_id), data = merge_df)
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## Model failed to converge with max|grad| = 0.269418 (tol = 0.002, component 1)
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, : Model is nearly unidentifiable: very large eigenvalue
##  - Rescale variables?
```

```r
summary(model.NPSRL)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: NPSpos ~ PE_mdl3 + (PE_mdl3 | sub) + (1 | session_id)
##    Data: merge_df
## 
## REML criterion at convergence: 22760.2
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.1075 -0.4954  0.0101  0.5324  4.5892 
## 
## Random effects:
##  Groups     Name        Variance  Std.Dev. Corr
##  sub        (Intercept) 2.364e+01 4.86171      
##             PE_mdl3     3.377e-04 0.01838  0.48
##  session_id (Intercept) 5.922e-02 0.24336      
##  Residual               6.460e+01 8.03742      
## Number of obs: 3221, groups:  sub, 60; session_id, 3
## 
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept)  5.490005   0.661891 46.862946   8.294 9.50e-11 ***
## PE_mdl3      0.038255   0.006598 47.726289   5.798 5.19e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##         (Intr)
## PE_mdl3 0.109 
## optimizer (nloptwrap) convergence code: 0 (OK)
## Model failed to converge with max|grad| = 0.269418 (tol = 0.002, component 1)
## Model is nearly unidentifiable: very large eigenvalue
##  - Rescale variables?
```

structure: sub, NPS, PE
subjectwise correlations

```r
ggplot(merge_df, aes(y = NPSpos, 
                       x = PE_mdl2, 
                       colour = src_subject_id), size = .3, color = 'gray') + 
  geom_point(size = .1) + 
  geom_smooth(method = 'lm', formula= y ~ x, se = FALSE, size = .3) +
  theme_bw()
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## ℹ Please use `linewidth` instead.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

```
## Warning: The following aesthetics were dropped during statistical transformation: colour
## ℹ This can happen when ggplot fails to infer the correct grouping structure in
##   the data.
## ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
##   variable into a factor?
```

<img src="24_RL_iv-PE_dv-NPS_files/figure-html/unnamed-chunk-6-1.png" width="672" />


```r
library(dplyr)
library(ggplot2)
library(broom)

# Assuming you have a dataframe `df` with the variables `subject`, `trial`, `NPS`, `PE`

# Calculate the coefficients for each participant
df <- merge_df
df$subject <- df$src_subject_id
df$NPS <- df$NPSpos
df$PE <- df$PE_mdl2

coefficients <- df %>%
  group_by(subject) %>%
  do(tidy(lm(PE ~ NPS, data = .)))

# Extract slopes and intercepts
slopes_intercepts <- coefficients %>%
  filter(term == "NPS") %>%
  select(subject, slope = estimate)

intercepts <- coefficients %>%
  filter(term == "(Intercept)") %>%
  select(subject, intercept = estimate)

# Merge slopes and intercepts
subject_lines <- full_join(slopes_intercepts, intercepts, by = "subject")

# Calculate the average slope and intercept for the group
avg_slope <- mean(subject_lines$slope)
avg_intercept <- mean(subject_lines$intercept)

# Plot
ggplot(df, aes(x = NPS, y = PE)) +
  geom_point(alpha = 0.4) +  # Plot the raw data points
  geom_abline(data = subject_lines, aes(slope = slope, intercept = intercept, color = as.factor(subject)), size = 1) +
  geom_abline(slope = avg_slope, intercept = avg_intercept, color = "black", size = 1.5, linetype = "dashed") +
  labs(color = "Subject") +
  theme_minimal() +
  theme(legend.position = "none")  # Remove legend if not needed
```

<img src="24_RL_iv-PE_dv-NPS_files/figure-html/unnamed-chunk-7-1.png" width="672" />


## re-run brain results from `XX.md`
## re-run behavioral results from `XX.Rmd`

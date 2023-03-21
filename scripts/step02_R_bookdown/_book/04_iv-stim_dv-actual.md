# outcome_rating ~ stimulus_intensity {#ch04_outcome-stim}

## What is the purpose of this notebook? 
Here, I plot the outcome ratings as a function of stimulus intensity 
* Main model: `lmer(outcome_rating ~ stim)` 
* Main question: do outcome ratings differ as a function of stimulus intensity? We should expect to see a linear effect of stimulus intensity.
* If there is a main effect of cue on expectation ratings, does this cue effect differ depending on task type?
* IV: stim (high / med / low)
* DV: outcome rating

FIX: plot statistics in random effect plot - what is broken?






```r
# parameters _____________________________________ # nolint
subject_varkey <- "src_subject_id"
iv <- "param_stimulus_type"; iv_keyword <- "stim"; dv <- "event04_actual_angle"; dv_keyword <- "outcome"
xlab <- ""; ylim = c(0,180); ylab <- "ratings (degree)"
subject <- "subject"
exclude <- "sub-0001|sub-0003|sub-0004|sub-0005|sub-0025|sub-0999"
subjectwise_mean <- "mean_per_sub"; group_mean <- "mean_per_sub_norm_mean"; se <- "se"
color_scheme <-     if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color_scheme <- c("#1B9E77", "#D95F02")
    } else {
        color_scheme <- c("#4575B4", "#D73027")
    }
print_lmer_output <- FALSE
ggtitle_phrase <- " - Outcome Rating (degree)"
analysis_dir <- file.path(main_dir, "analysis", "mixedeffect", paste0("model03_iv-",iv_keyword,"_dv-",dv_keyword), as.character(Sys.Date()))
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)
```



## Pain

### For the pain task, what is the effect of stimulus intensity on outcome ratings? {.unlisted .unnumbered}
[ INSERT DESCRIPTION ]

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], x =
## as.numeric(factor(.data[[iv]])) - : Ignoring unknown aesthetics: fill
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## ℹ Please use `linewidth` instead.
```

<img src="04_iv-stim_dv-actual_files/figure-html/pain_iv-stim_dv-outcome-1.png" width="672" />

## Vicarious
### For the vicarious task, what is the effect of stimulus intensity on outcome ratings? {.unlisted .unnumbered}
[ INSERT DESCRIPTION ]

```
## Warning: Model failed to converge with 1 negative eigenvalue: -8.5e+01
```

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], x =
## as.numeric(factor(.data[[iv]])) - : Ignoring unknown aesthetics: fill
```

<img src="04_iv-stim_dv-actual_files/figure-html/vicarious_iv-stim_dv-outcome-1.png" width="672" />

## Cognitive
### For the cognitive task, what is the effect of stimulus intensity on outcome ratings? {.unlisted .unnumbered}
[ INSERT DESCRIPTION ]

```
## Warning: Model failed to converge with 1 negative eigenvalue: -1.1e+02
```

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], x =
## as.numeric(factor(.data[[iv]])) - : Ignoring unknown aesthetics: fill
```

<img src="04_iv-stim_dv-actual_files/figure-html/cognitive_iv-stim_dv-outcome-1.png" width="672" />



## individual differences in outcome rating cue effect 
[ INSERT DESCRIPTION ]



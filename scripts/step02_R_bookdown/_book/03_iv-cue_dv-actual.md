# outcome_rating ~ cue {#ch03_cue}

## What is the purpose of this notebook? 
Here, I plot the outcome ratings as a function of cue. 
* Main model: `lmer(outcome_rating ~ cue)` 
* Main question: do outcome ratings differ as a function of cue type? 
* If there is a main effect of cue on outcome ratings, does this cue effect differ depending on task type?
* IV: cue (high / low)
* DV: outcome rating

FIX: plot statistics in random effect plot - what is broken?






```r
# parameters _____________________________________ # nolint
subject_varkey <- "src_subject_id"
iv <- "param_cue_type"; iv_keyword <- "cue"; dv <- "event04_actual_angle"; dv_keyword <- "outcome"
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
analysis_dir <- file.path(main_dir, "analysis", "mixedeffect", "model02_iv-cue_dv-outcome", as.character(Sys.Date()))
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)
```



## Pain
### For the vicarious task, what is the effect of cue on outcome ratings? {.unlisted .unnumbered}
[ INSERT DESCRIPTION ]

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], x =
## as.numeric(factor(.data[[iv]])) - : Ignoring unknown aesthetics: fill
```

<img src="03_iv-cue_dv-actual_files/figure-html/pain_iv-cue_dv-outcome-1.png" width="672" />

## Vicarious
### For the vicarious task, what is the effect of cue on outcome ratings? {.unlisted .unnumbered}
[ INSERT DESCRIPTION ]

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], x =
## as.numeric(factor(.data[[iv]])) - : Ignoring unknown aesthetics: fill
```

<img src="03_iv-cue_dv-actual_files/figure-html/vicarious_iv-cue_dv-outcome-1.png" width="672" />

## Cognitive
### For the cognitive task, what is the effect of cue on outcome ratings? {.unlisted .unnumbered}
[ INSERT DESCRIPTION ]

```
## Warning in geom_line(data = subjectwise, aes(group = .data[[subject]], x =
## as.numeric(factor(.data[[iv]])) - : Ignoring unknown aesthetics: fill
```

<img src="03_iv-cue_dv-actual_files/figure-html/cognitive_iv-cue_dv-outcome-1.png" width="672" />




## individual differences analysis
Using the random effects from the mixed effects model, I'm plotting the random effect of cue types per task. 



[ INSERT DESCRIPTION ]

```
## Warning: Removed 2 rows containing non-finite values (`stat_cor()`).
```

```
## Warning: Removed 2 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_text()`).
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_cor()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_text()`).
```

```
## Warning: Removed 2 rows containing non-finite values (`stat_cor()`).
```

```
## Warning: Removed 2 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_text()`).
```

<img src="03_iv-cue_dv-actual_files/figure-html/random_cue_scatter_plot_2-1.png" width="672" />



## individual differences analysis
based on Tor's suggestion, plotting the random efects with the random intercepts as well. not just the cue effects

```
## Warning: Removed 49 rows containing non-finite values (`stat_cor()`).
```

```
## Warning: Removed 49 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_text()`).
```

```
## Warning: Removed 8 rows containing non-finite values (`stat_cor()`).
```

```
## Warning: Removed 8 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_text()`).
```

```
## Warning: Removed 52 rows containing non-finite values (`stat_cor()`).
```

```
## Warning: Removed 52 rows containing missing values (`geom_point()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_text()`).
```

<img src="03_iv-cue_dv-actual_files/figure-html/random_effects_scatter_plot_2-1.png" width="672" />


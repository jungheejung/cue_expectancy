---
output:
  pdf_document: default
  html_document: default
---
# [beh] outcome_rating ~ cue * stim {#ch05_outcome-cueXstim}

## What is the purpose of this notebook? {.unlisted .unnumbered}

Here, we want to test whether lmer is the equivalent of repeated measures anova

I test the outcome ratings as a function of cue and stimulus intensity. 

* Main model: `lmer(outcome_rating ~ cue * stim)` 
* Main question: do outcome ratings differ as a function of cue type and stimulus intensity? 
* If there is a main effect of cue on outcome ratings, does this cue effect differ depending on task type?
* Is there an interaction between the two factors?
* IV: 
  - cue (high / low)
  - stim (high / med / low)
* DV: outcome rating

## load data





## lmer

```r
analysis_dir <- file.path(
    main_dir, "analysis",
    "mixedeffect", "model04_iv-cuecontrast_dv-outcome", as.character(Sys.Date()))
dir.create(analysis_dir, recursive = TRUE, showWarnings = FALSE)
taskname <- "pain"

    subject_varkey <- "src_subject_id"
    iv <- "param_cue_type"; iv_keyword <- "cue"
    dv <- "event04_actual_angle"
    dv_keyword <- "actual"
    subject <- "subject"
    xlab <- ""
    ylab <- "ratings (degree)"
    exclude <- "sub-0001|sub-0003|sub-0004|sub-0005|sub-0025|sub-0999"
    w <- 10
    h <- 6
    model_savefname <- file.path(
        analysis_dir,
        paste("lmer_task-", taskname, "_cue_on_rating-", dv_keyword, "_",
            as.character(Sys.Date()), ".txt",
            sep = ""
        )
    )
    # ___ 1) load data _______________________________________________________________ # nolint
    data <- load_task_social_df(datadir, taskname, subject_varkey, iv, dv, exclude)
    unique(data$src_subject_id)
```

```
##   [1]   2   6   7   8   9  10  11  13  14  15  16  17  18  19  20  98  21  23
##  [19]  24  26  28  29  30  31  32  33  34  35  36  37  38  39  40  41  43  44
##  [37]  46  47  50  51  52  53  55  56  57  58  59  60  61  62  63  64  65  66
##  [55]  68  69  70  73  74  75  76  77  78  79  80  81  82  83  84  85  86  87
##  [73]  88  89  90  91  92  93  94  95  97  99 100 101 103 104 105 106 107 109
##  [91] 111 112 114 115 116 117 118 119 120 122 123 124 126 127 128 129 130 131
## [109] 132 133
```

```r
    data$subject <- factor(data$src_subject_id)

    
    w <- 10
    h <- 6

    # [ CONTRASTS ]  ________________________________________________________________________________ # nolint
    # contrast code ________________________________________
    data$stim[data$event03_stimulus_type == "low_stim"] <- -0.5 # social influence task
    data$stim[data$event03_stimulus_type == "med_stim"] <- 0 # no influence task
    data$stim[data$event03_stimulus_type == "high_stim"] <- 0.5 # no influence task

    data$stim_factor <- factor(data$event03_stimulus_type)

    # contrast code 1 linear
    data$stim_con_linear[data$event03_stimulus_type == "low_stim"] <- -0.5
    data$stim_con_linear[data$event03_stimulus_type == "med_stim"] <- 0
    data$stim_con_linear[data$event03_stimulus_type == "high_stim"] <- 0.5

    # contrast code 2 quadratic
    data$stim_con_quad[data$event03_stimulus_type == "low_stim"] <- -0.33
    data$stim_con_quad[data$event03_stimulus_type == "med_stim"] <- 0.66
    data$stim_con_quad[data$event03_stimulus_type == "high_stim"] <- -0.33

    # social cude contrast
    data$social_cue[data$param_cue_type == "low_cue"] <- -0.5 # social influence task
    data$social_cue[data$param_cue_type == "high_cue"] <- 0.5 # no influence task

    stim_con1 <- "stim_con_linear"
    stim_con2 <- "stim_con_quad"
    iv1 <- "social_cue"
    dv <- "event04_actual_angle"
```

## full random slopes
Matrix is singular. model estimation is bound to be overfitted and inaccurate

```r
fullmodel <- lmer(event04_actual_angle ~ 1+ social_cue*stim_con_linear + social_cue*stim_con_quad +
     + (1+ social_cue*stim_con_linear + social_cue*stim_con_quad| src_subject_id), data=data)
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
summary(fullmodel)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: 
## event04_actual_angle ~ 1 + social_cue * stim_con_linear + social_cue *  
##     stim_con_quad + +(1 + social_cue * stim_con_linear + social_cue *  
##     stim_con_quad | src_subject_id)
##    Data: data
## 
## REML criterion at convergence: 52603.7
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.8153 -0.5487  0.0090  0.5498  4.8424 
## 
## Random effects:
##  Groups         Name                       Variance Std.Dev. Corr             
##  src_subject_id (Intercept)                847.814  29.117                    
##                 social_cue                  50.068   7.076    0.00            
##                 stim_con_linear            131.233  11.456    0.31  0.06      
##                 stim_con_quad                2.143   1.464    0.98  0.20  0.28
##                 social_cue:stim_con_linear   2.003   1.415   -0.19  0.98 -0.04
##                 social_cue:stim_con_quad     5.291   2.300   -0.67  0.33 -0.82
##  Residual                                  415.315  20.379                    
##             
##             
##             
##             
##             
##   0.01      
##  -0.56  0.48
##             
## Number of obs: 5851, groups:  src_subject_id, 110
## 
## Fixed effects:
##                             Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept)                  65.9777     2.7929  109.0434  23.623  < 2e-16 ***
## social_cue                    8.3269     0.8792  102.4281   9.470 1.17e-15 ***
## stim_con_linear              29.2255     1.2978  107.6250  22.519  < 2e-16 ***
## stim_con_quad                 0.8353     0.5887  863.1429   1.419    0.156    
## social_cue:stim_con_linear   -0.4345     1.3135 2179.2593  -0.331    0.741    
## social_cue:stim_con_quad     -4.6099     1.1652 1050.4480  -3.956 8.12e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                (Intr) socl_c stm_cn_l stm_cn_q scl_c:stm_cn_l
## social_cue     -0.001                                        
## stim_cn_lnr     0.260  0.041                                 
## stim_con_qd     0.231  0.037  0.055                          
## scl_c:stm_cn_l -0.020  0.083 -0.003    0.000                 
## scl_c:stm_cn_q -0.126  0.052 -0.135   -0.027    0.011        
## optimizer (nloptwrap) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

## remove interaction randomslopes
Matrix is still singular, potentially due to the correlated random effects

```r
model.noint <- lmer(event04_actual_angle ~ 1+ social_cue*stim_con_linear + social_cue*stim_con_quad +
     + (1+ social_cue + stim_con_linear + stim_con_quad| src_subject_id), data=data)
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
summary(model.noint)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: 
## event04_actual_angle ~ 1 + social_cue * stim_con_linear + social_cue *  
##     stim_con_quad + +(1 + social_cue + stim_con_linear + stim_con_quad |  
##     src_subject_id)
##    Data: data
## 
## REML criterion at convergence: 52608.1
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.8149 -0.5442  0.0069  0.5483  4.8566 
## 
## Random effects:
##  Groups         Name            Variance Std.Dev. Corr          
##  src_subject_id (Intercept)     847.864  29.118                 
##                 social_cue       49.797   7.057   0.00          
##                 stim_con_linear 131.153  11.452   0.31 0.06     
##                 stim_con_quad     2.162   1.470   0.98 0.21 0.27
##  Residual                       415.754  20.390                 
## Number of obs: 5851, groups:  src_subject_id, 110
## 
## Fixed effects:
##                             Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept)                  65.9782     2.7930  109.0441  23.622  < 2e-16 ***
## social_cue                    8.3326     0.8780  102.2530   9.490 1.07e-15 ***
## stim_con_linear              29.2266     1.2979  107.5258  22.519  < 2e-16 ***
## stim_con_quad                 0.8405     0.5892  856.2483   1.427    0.154    
## social_cue:stim_con_linear   -0.3968     1.3067 5535.7764  -0.304    0.761    
## social_cue:stim_con_quad     -4.6580     1.1443 5530.6946  -4.071 4.75e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                (Intr) socl_c stm_cn_l stm_cn_q scl_c:stm_cn_l
## social_cue     -0.001                                        
## stim_cn_lnr     0.260  0.042                                 
## stim_con_qd     0.232  0.040  0.054                          
## scl_c:stm_cn_l  0.000  0.000  0.000    0.000                 
## scl_c:stm_cn_q  0.000  0.001  0.000   -0.003    0.001        
## optimizer (nloptwrap) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

## remove correlated random slope
After removal of the correlated random slope: intercept and stim_con_quad, the matrix is no longer singular.

```r
model.noint <- lmer(event04_actual_angle ~ 1+ social_cue*stim_con_linear + social_cue*stim_con_quad +
     + (1+ social_cue + stim_con_linear | src_subject_id), data=data)
summary(model.noint)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: 
## event04_actual_angle ~ 1 + social_cue * stim_con_linear + social_cue *  
##     stim_con_quad + +(1 + social_cue + stim_con_linear | src_subject_id)
##    Data: data
## 
## REML criterion at convergence: 52614.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.8285 -0.5415  0.0072  0.5471  4.8403 
## 
## Random effects:
##  Groups         Name            Variance Std.Dev. Corr     
##  src_subject_id (Intercept)     847.98   29.120            
##                 social_cue       49.76    7.054   0.00     
##                 stim_con_linear 131.09   11.450   0.31 0.06
##  Residual                       416.26   20.402            
## Number of obs: 5851, groups:  src_subject_id, 110
## 
## Fixed effects:
##                             Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept)                  65.9785     2.7932  109.0491  23.621  < 2e-16 ***
## social_cue                    8.3322     0.8780  102.2225   9.490 1.08e-15 ***
## stim_con_linear              29.2208     1.2979  107.5408  22.513  < 2e-16 ***
## stim_con_quad                 0.8641     0.5725 5532.2034   1.509    0.131    
## social_cue:stim_con_linear   -0.3992     1.3075 5535.8361  -0.305    0.760    
## social_cue:stim_con_quad     -4.6655     1.1449 5530.7504  -4.075 4.67e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                (Intr) socl_c stm_cn_l stm_cn_q scl_c:stm_cn_l
## social_cue     -0.002                                        
## stim_cn_lnr     0.258  0.042                                 
## stim_con_qd     0.000 -0.001  0.000                          
## scl_c:stm_cn_l  0.000  0.000  0.000    0.000                 
## scl_c:stm_cn_q  0.000  0.001  0.000   -0.003    0.001
```


## repeated measures

```r
################################################################################

data <- data %>%
  group_by(src_subject_id) %>%
  mutate(trial = row_number())

df <- data %>%
  group_by(src_subject_id,session_id, param_run_num, param_cond_type) %>%
  mutate(repeat_order = row_number()) %>%
  ungroup()

# long to wide
wide.df = df[c("src_subject_id","session_id","param_run_num", "param_cue_type", "param_stimulus_type", "repeat_order","event04_actual_angle" )] %>% 
   pivot_wider(names_from = c(param_cue_type, param_stimulus_type), values_from = event04_actual_angle) 

################################################################################
# average within subject


wide.ave <- wide.df %>%
  dplyr::group_by(src_subject_id) %>%
  dplyr::summarize(
    across(c(high_cue_high_stim, high_cue_med_stim, high_cue_low_stim, low_cue_high_stim, low_cue_med_stim, low_cue_low_stim), mean, na.rm = TRUE)
  )
```

```
## Warning: There was 1 warning in `dplyr::summarize()`.
## ℹ In argument: `across(...)`.
## ℹ In group 1: `src_subject_id = 2`.
## Caused by warning:
## ! The `...` argument of `across()` is deprecated as of dplyr 1.1.0.
## Supply arguments directly to `.fns` through an anonymous function instead.
## 
##   # Previously
##   across(a:b, mean, na.rm = TRUE)
## 
##   # Now
##   across(a:b, \(x) mean(x, na.rm = TRUE))
```

```r
################################################################################
# contrast coding
# modeling the average performance (intercept)
wide.ave$ave = (+1/6) * wide.ave$high_cue_high_stim + 
  (+1/6) * wide.ave$high_cue_med_stim + 
  (+1/6) * wide.ave$high_cue_low_stim + 
  (+1/6) * wide.ave$low_cue_high_stim + 
  (+1/6) * wide.ave$low_cue_med_stim + 
  (+1/6) * wide.ave$low_cue_low_stim 
t.ave = lm(wide.ave$ave ~ 1)
summary(t.ave)
```

```
## 
## Call:
## lm(formula = wide.ave$ave ~ 1)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -50.803 -19.181  -6.562  10.112  89.814 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   65.991      2.816   23.43   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 29.4 on 108 degrees of freedom
##   (1 observation deleted due to missingness)
```

```r
# model :: cue effect
wide.ave$cue_effect = (+1/2) * wide.ave$high_cue_high_stim + 
  (+1/2) * wide.ave$high_cue_med_stim + 
  (+1/2) * wide.ave$high_cue_low_stim + 
  (-1/2) * wide.ave$low_cue_high_stim + 
  (-1/2) * wide.ave$low_cue_med_stim + 
  (-1/2) * wide.ave$low_cue_low_stim 
t.cue = lm(wide.ave$cue_effect ~ 1)
summary(t.cue)
```

```
## 
## Call:
## lm(formula = wide.ave$cue_effect ~ 1)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -66.320  -8.091  -1.922   8.530  34.004 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   12.325      1.352   9.115 4.77e-15 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 14.12 on 108 degrees of freedom
##   (1 observation deleted due to missingness)
```

```r
# model :: stim effect
wide.ave$stim_effect = 
  (+1/2) * wide.ave$high_cue_high_stim + 
  (0) * wide.ave$high_cue_med_stim + 
  (-1/2) * wide.ave$high_cue_low_stim + 
  (+1/2) * wide.ave$low_cue_high_stim + 
  (0) * wide.ave$low_cue_med_stim + 
  (-1/2) * wide.ave$low_cue_low_stim 
t.stim = lm(wide.ave$stim_effect ~ 1)
summary(t.stim)
```

```
## 
## Call:
## lm(formula = wide.ave$stim_effect ~ 1)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -34.414  -8.296  -1.699   9.908  31.413 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   28.866      1.314   21.96   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 13.72 on 108 degrees of freedom
##   (1 observation deleted due to missingness)
```

```r
# model :: interaction
wide.ave$interaction = 
  (+1/4) * wide.ave$high_cue_high_stim + 
  (0) * wide.ave$high_cue_med_stim + 
  (-1/4) * wide.ave$high_cue_low_stim + 
  (-1/4) * wide.ave$low_cue_high_stim + 
  (0) * wide.ave$low_cue_med_stim + 
  (+1/4) * wide.ave$low_cue_low_stim 
t.int = lm(wide.ave$interaction ~ 1)
summary(t.int)
```

```
## 
## Call:
## lm(formula = wide.ave$interaction ~ 1)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -7.8957 -1.3891  0.0891  1.6730  6.0117 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  -0.2180     0.2525  -0.863     0.39
## 
## Residual standard error: 2.637 on 108 degrees of freedom
##   (1 observation deleted due to missingness)
```


## converges with more than 36 observations?


```r
################################################################################
# filter subject with more than 36 trials
data
```

```
## # A tibble: 5,851 × 64
## # Groups:   src_subject_id [110]
##    src_subject_id session_id param_task_name param_run_num
##             <int>      <int> <chr>                   <int>
##  1              2          1 pain                        1
##  2              2          1 pain                        1
##  3              2          1 pain                        1
##  4              2          1 pain                        1
##  5              2          1 pain                        1
##  6              2          1 pain                        1
##  7              2          1 pain                        1
##  8              2          1 pain                        1
##  9              2          1 pain                        1
## 10              2          1 pain                        1
## # ℹ 5,841 more rows
## # ℹ 60 more variables: param_counterbalance_ver <int>,
## #   param_counterbalance_block_num <int>, param_cue_type <chr>,
## #   param_stimulus_type <chr>, param_cond_type <int>,
## #   param_trigger_onset <dbl>, param_start_biopac <dbl>, ITI_onset <dbl>,
## #   ITI_biopac <dbl>, ITI_duration <dbl>, event01_cue_onset <dbl>,
## #   event01_cue_biopac <dbl>, event01_cue_type <chr>, …
```

```r
data <- data %>%
  group_by(src_subject_id) %>%
  mutate(trial = row_number())

df_filtered <- data %>%
  group_by(src_subject_id) %>%
  filter(n() > 36) %>%
  ungroup()


frequency_df <- df_filtered %>%
  dplyr::group_by(src_subject_id) %>%
  dplyr::summarize(frequency = n(), .groups = 'drop')

################################################################################
# run null model
# library(performance)
# model.null <- lmer(event04_actual_angle ~ 1+ social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear + social_cue:stim_con_quad
#      + (1| src_subject_id), data=df_filtered, REML = TRUE)
# performance::icc(model.null)

################################################################################
# model.36 <- lmer(event04_actual_angle ~ 1+ social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear + social_cue:stim_con_quad
#      + (1+ social_cue + stim_con_linear| src_subject_id), data=df_filtered, REML = TRUE)
# summary(model.36)

################################################################################
model.36full <- lmer(event04_actual_angle ~ 1+ social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear + social_cue:stim_con_quad
     + (1+ social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear + social_cue:stim_con_quad | src_subject_id), data=df_filtered, REML = TRUE)
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
summary(model.36full)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: 
## event04_actual_angle ~ 1 + social_cue + stim_con_linear + stim_con_quad +  
##     social_cue:stim_con_linear + social_cue:stim_con_quad + (1 +  
##     social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear +  
##     social_cue:stim_con_quad | src_subject_id)
##    Data: df_filtered
## 
## REML criterion at convergence: 47150.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.7831 -0.5535  0.0064  0.5550  4.7959 
## 
## Random effects:
##  Groups         Name                       Variance Std.Dev. Corr             
##  src_subject_id (Intercept)                847.623  29.114                    
##                 social_cue                  53.559   7.318    0.02            
##                 stim_con_linear            132.614  11.516    0.26  0.14      
##                 stim_con_quad                1.807   1.344    0.96  0.28  0.23
##                 social_cue:stim_con_linear   2.555   1.598   -0.04  0.98 -0.07
##                 social_cue:stim_con_quad     5.253   2.292   -0.62  0.31 -0.81
##  Residual                                  423.326  20.575                    
##             
##             
##             
##             
##             
##   0.23      
##  -0.47  0.48
##             
## Number of obs: 5240, groups:  src_subject_id, 83
## 
## Fixed effects:
##                             Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept)                  66.5603     3.2087   81.9840  20.744  < 2e-16 ***
## social_cue                    8.4886     0.9873   77.1583   8.598 7.04e-13 ***
## stim_con_linear              29.8484     1.4469   82.3593  20.629  < 2e-16 ***
## stim_con_quad                 0.8433     0.6275  676.1477   1.344 0.179384    
## social_cue:stim_con_linear   -0.1886     1.4041 1468.2453  -0.134 0.893169    
## social_cue:stim_con_quad     -4.7602     1.2453  784.1427  -3.822 0.000143 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                (Intr) socl_c stm_cn_l stm_cn_q scl_c:stm_cn_l
## social_cue      0.014                                        
## stim_cn_lnr     0.227  0.097                                 
## stim_con_qd     0.226  0.053  0.048                          
## scl_c:stm_cn_l -0.005  0.099 -0.007    0.006                 
## scl_c:stm_cn_q -0.124  0.051 -0.144   -0.023    0.014        
## optimizer (nloptwrap) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

```r
################################################################################
# deviance
# anova(model.36, model.36full, refit = FALSE)
```

<!-- ```{r} -->
<!-- random_intercepts <- getME(model.36full, "Z") -->
<!-- # random_intercepts -->
<!-- fixed_effects_matrix <- model.matrix(~ 1+ social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear + social_cue:stim_con_quad, data = df_filtered) -->
<!-- fixed_effects_matrix -->
<!-- # heatmap(fixed_effects_matrix, col=heat.colors(256), scale="column") -->
<!-- # Convert matrix to data frame -->
<!-- mat_df <- melt(t(fixed_effects_matrix)) -->

<!-- ggplot(mat_df, aes(x=Var1, y=Var2, fill=value)) +  -->
<!--     geom_tile() -->
<!-- ``` -->

<!-- ```{r} -->
<!-- # Compute the covariance matrix -->
<!-- cov_matrix <- cov(fixed_effects_matrix) -->
<!-- # Base R image plot -->
<!-- image(cov_matrix, main = "Covariance Matrix of Fixed Effects") -->

<!-- # Alternatively, use the `heatmap()` function for a more detailed plot -->
<!-- heatmap(cov_matrix, main = "Covariance Matrix of Fixed Effects") -->
<!-- library(ggplot2) -->
<!-- library(reshape2) -->

<!-- # Ensure your matrix has proper row and column names -->
<!-- rownames(cov_matrix) <- colnames(fixed_effects_matrix) -->
<!-- colnames(cov_matrix) <- colnames(fixed_effects_matrix) -->

<!-- # Reshape the matrix to long format -->
<!-- long_cor_matrix <- melt(cov_matrix) -->

<!-- # Plot using ggplot2 -->
<!-- ggplot(long_cor_matrix, aes(Var1, Var2, fill = value)) + -->
<!--   geom_tile() + -->
<!--   scale_fill_gradient2() + -->
<!--   theme_minimal() + -->
<!--   theme(axis.text.x = element_text(angle = 45, hjust = 1)) + -->
<!--   labs(x = "Regressors", y = "Regressors", fill = "Correlation", title = "Correlation Matrix of Fixed Effects") -->
<!-- # corrplot(long_cor_matrix) -->

<!-- # M<-cor(fixed_effects_matrix) -->
<!-- # corrplot(M, method="circle") -->
<!-- ``` -->


<!-- ```{r} -->
<!-- library(lme4) -->
<!-- # For random intercepts -->
<!-- random_intercepts <- getME(model.36full, "Z") -->
<!-- # For random slopes -->
<!-- random_slopes <- getME(model.36full, "Zt") -->
<!-- dim(random_slopes) -->
<!-- library(Matrix) -->
<!-- par(mar = c(5, 4, 4, 2) + 0.1) -->
<!-- image(random_slopes, ylab = "Rows", xlab = "Columns", main = "Sparse Matrix Plot") -->
<!-- image(t(random_intercepts), ylab = "Rows", xlab = "Columns", main = "Sparse Matrix Plot") -->

<!-- ``` -->









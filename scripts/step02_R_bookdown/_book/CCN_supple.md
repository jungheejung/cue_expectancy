# [CCN] SCL {#ch100_CCNsupplementary}
---
title: "CCNfigures"
output: html_document
date: "2023-08-16"
---





## empirical

```r
# STEP
# * load csv
data <- read.csv(file.path(main_dir, "data/RL/modelfit_jepma_0525/table_pain.csv"))
analysis_dir <- file.path(main_dir, "analysis/mixedeffect/CCNfigures")
data$sub <- data$src_subject_id
data$ses <- data$session_id
data$run <- data$param_run_num

data$stim[data$param_stimulus_type == "low_stim"] <-  -0.5 # social influence task
data$stim[data$param_stimulus_type == "med_stim"] <- 0 # no influence task
data$stim[data$param_stimulus_type == "high_stim"] <-  0.5 # no influence task

data$STIM <- factor(data$param_stimulus_type)

# contrast code 1 linear
data$STIM_linear[data$param_stimulus_type == "low_stim"] <- -0.5
data$STIM_linear[data$param_stimulus_type == "med_stim"] <- 0
data$STIM_linear[data$param_stimulus_type == "high_stim"] <- 0.5

# contrast code 2 quadratic
data$STIM_quadratic[data$param_stimulus_type == "low_stim"] <- -0.33
data$STIM_quadratic[data$param_stimulus_type == "med_stim"] <- 0.66
data$STIM_quadratic[data$param_stimulus_type == "high_stim"] <- -0.33

# social cue contrast
data$CUE_high_gt_low[data$param_cue_type == "low_cue"] <-  -0.5 # social influence task
data$CUE_high_gt_low[data$param_cue_type == "high_cue"] <-  0.5 # no influence task

data$EXPECT <- data$event02_expect_angle
data$OUTCOME <- data$event04_actual_angle
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
dv <- "OUTCOME"
dv_keyword <- "outcome"
subject <- "sub"
taskname <- "pain"

  model_savefname <- file.path(
  analysis_dir,
  paste(
    "lmer_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.txt",
    sep = ""
  )
)


# * cooks d lmer
cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject = "sub",  dv_keyword,  model_savefname,  'random_intercept',
  print_lmer_output = TRUE
)
```

```
## [1] "model:  Outcome  ratings -  pain"
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: as.formula(model_string)
##    Data: data
## 
## REML criterion at convergence: 37210.7
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.5799 -0.5721  0.0073  0.5724  4.7231 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 887.3    29.79   
##  Residual             454.9    21.33   
## Number of obs: 4122, groups:  sub, 63
## 
## Fixed effects:
##                                 Estimate Std. Error        df t value Pr(>|t|)
## (Intercept)                      66.3157     3.7676   62.0058  17.601  < 2e-16
## CUE_high_gt_low                   9.6107     0.6647 4054.0682  14.458  < 2e-16
## STIM_linear                      30.3322     0.8130 4054.0979  37.311  < 2e-16
## STIM_quadratic                    1.0146     0.7133 4054.0585   1.422 0.154990
## CUE_high_gt_low:STIM_linear       0.1785     1.6257 4054.0750   0.110 0.912577
## CUE_high_gt_low:STIM_quadratic   -4.7469     1.4265 4054.0523  -3.328 0.000884
##                                   
## (Intercept)                    ***
## CUE_high_gt_low                ***
## STIM_linear                    ***
## STIM_quadratic                    
## CUE_high_gt_low:STIM_linear       
## CUE_high_gt_low:STIM_quadratic ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                      (Intr) CUE_h__ STIM_l STIM_q CUE_hgh_gt_lw:STIM_l
## CUE_hgh_gt_           0.000                                           
## STIM_linear          -0.001 -0.001                                    
## STIM_qudrtc           0.000 -0.002   0.006                            
## CUE_hgh_gt_lw:STIM_l  0.000 -0.008  -0.001  0.001                     
## CUE_hgh_gt_lw:STIM_q  0.000  0.004   0.001 -0.005  0.006
```

```r
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])
if (length(influential) > 0) {
data_screen <- data[-influential,]
} else {
  data_screen <- data
}
# * demean ___________
maindata <- data_screen %>%
  group_by(src_subject_id) %>%
  mutate(event04_actual_angle = as.numeric(event04_actual_angle)) %>%
  mutate(event02_expect_angle = as.numeric(event02_expect_angle)) %>%
  mutate(avg_outcome = mean(event04_actual_angle, na.rm = TRUE)) %>%
  mutate(demean_outcome = event04_actual_angle - avg_outcome) %>%
  mutate(avg_expect = mean(event02_expect_angle, na.rm = TRUE)) %>%
  mutate(demean_expect = event02_expect_angle - avg_expect) 
  # ungroup() %>%

cmc <- maindata %>%
mutate(OUTCOME_cmc = avg_outcome - mean(avg_outcome)) %>%
mutate(EXPECT_cmc = avg_expect - mean(avg_expect)) 


maindata$OUTCOME_cmc <- maindata$avg_outcome - mean(maindata$avg_outcome)
maindata$EXPECT_cmc <- maindata$avg_expect - mean(maindata$avg_expect)

data_p2= maindata %>%
  arrange(sub ) %>%
  group_by(sub) %>%
  mutate(trial_index = row_number())
data_a3 <- data_p2 %>% 
  group_by(sub, ses, run) %>% 
  mutate(trial_index = row_number(run))
data_a3lag <- 
    data_a3 %>%
    group_by(sub, ses, run) %>%
    mutate(lag.04outcomeangle = dplyr::lag(event04_actual_angle, n = 1, default = NA))
# data_a3lag_omit <- data_a3lag[complete.cases(data_a3lag$lag.04outcomeangle),]
main.df <- data_a3lag

# %% main lmer
main.df$EXPECT_demean <- main.df$demean_expect
main.df$OUTCOME_demean <- main.df$demean_outcome
model.behexpectdemean <- lmer(OUTCOME_demean ~ 
                          CUE_high_gt_low*STIM_linear*EXPECT_demean +
                          CUE_high_gt_low*STIM_quadratic*EXPECT_demean + #EXPECT_cmc + 
                          (CUE_high_gt_low|sub), data = main.df, REML = FALSE,  control = lmerControl(optimizer ="Nelder_Mead"))  # lag.04outcomeangle +
```

```
## boundary (singular) fit: see help('isSingular')
```

```
## Warning: Model failed to converge with 1 negative eigenvalue: -3.7e+00
```

```r
summary(model.behexpectdemean)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: OUTCOME_demean ~ CUE_high_gt_low * STIM_linear * EXPECT_demean +  
##     CUE_high_gt_low * STIM_quadratic * EXPECT_demean + (CUE_high_gt_low |  
##     sub)
##    Data: main.df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  36308.7  36409.9 -18138.4  36276.7     4106 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.2964 -0.5943 -0.0128  0.5741  4.8444 
## 
## Random effects:
##  Groups   Name            Variance Std.Dev. Corr
##  sub      (Intercept)       0.00    0.000       
##           CUE_high_gt_low  20.96    4.579    NaN
##  Residual                 384.97   19.621       
## Number of obs: 4122, groups:  sub, 63
## 
## Fixed effects:
##                                                Estimate Std. Error         df
## (Intercept)                                     0.39210    0.38748 4064.60949
## CUE_high_gt_low                                -2.12851    0.97770  101.78470
## STIM_linear                                    27.55257    0.94757 4070.07513
## EXPECT_demean                                   0.33037    0.01399 2750.91976
## STIM_quadratic                                  1.66987    0.83206 4068.97374
## CUE_high_gt_low:STIM_linear                    -2.53630    1.89586 4076.62013
## CUE_high_gt_low:EXPECT_demean                  -0.05367    0.02684 4061.26795
## STIM_linear:EXPECT_demean                       0.06870    0.03296 4092.88065
## CUE_high_gt_low:STIM_quadratic                 -5.71329    1.66460 4073.65892
## EXPECT_demean:STIM_quadratic                    0.02066    0.02877 4093.85096
## CUE_high_gt_low:STIM_linear:EXPECT_demean       0.31175    0.06589 4086.60238
## CUE_high_gt_low:EXPECT_demean:STIM_quadratic   -0.03282    0.05749 4082.86940
##                                              t value Pr(>|t|)    
## (Intercept)                                    1.012 0.311640    
## CUE_high_gt_low                               -2.177 0.031787 *  
## STIM_linear                                   29.077  < 2e-16 ***
## EXPECT_demean                                 23.606  < 2e-16 ***
## STIM_quadratic                                 2.007 0.044826 *  
## CUE_high_gt_low:STIM_linear                   -1.338 0.181034    
## CUE_high_gt_low:EXPECT_demean                 -2.000 0.045574 *  
## STIM_linear:EXPECT_demean                      2.084 0.037207 *  
## CUE_high_gt_low:STIM_quadratic                -3.432 0.000605 ***
## EXPECT_demean:STIM_quadratic                   0.718 0.472792    
## CUE_high_gt_low:STIM_linear:EXPECT_demean      4.731 2.31e-06 ***
## CUE_high_gt_low:EXPECT_demean:STIM_quadratic  -0.571 0.568099    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                      (Intr) CUE_h__ STIM_l EXPECT_d STIM_q CUE_hgh_gt_lw:STIM_l
## CUE_hgh_gt_           0.030                                                    
## STIM_linear          -0.002  0.006                                             
## EXPECT_demn          -0.063 -0.509  -0.015                                     
## STIM_qudrtc           0.005 -0.018   0.001  0.017                              
## CUE_hgh_gt_lw:STIM_l  0.008 -0.001   0.051 -0.003   -0.005                     
## CUE_h__:EXPECT_      -0.614 -0.052  -0.001  0.105   -0.001 -0.015              
## STIM_:EXPEC          -0.015 -0.002  -0.073 -0.003    0.010 -0.615              
## CUE_hgh_gt_lw:STIM_q -0.022  0.003  -0.006  0.000    0.018  0.001              
## EXPECT_:STI           0.017  0.001   0.011 -0.006   -0.049  0.001              
## CUE___:STIM_:        -0.001 -0.013  -0.614  0.026    0.001 -0.073              
## CUE___:EXPECT_:      -0.001  0.012   0.001  0.002   -0.615  0.010              
##                      CUE_h__:EXPECT_ STIM_: CUE_hgh_gt_lw:STIM_q EXPECT_:
## CUE_hgh_gt_                                                              
## STIM_linear                                                              
## EXPECT_demn                                                              
## STIM_qudrtc                                                              
## CUE_hgh_gt_lw:STIM_l                                                     
## CUE_h__:EXPECT_                                                          
## STIM_:EXPEC           0.026                                              
## CUE_hgh_gt_lw:STIM_q  0.016           0.001                              
## EXPECT_:STI           0.001           0.003 -0.615                       
## CUE___:STIM_:        -0.005           0.101  0.011               -0.019  
## CUE___:EXPECT_:      -0.003          -0.018 -0.049                0.102  
##                      CUE___:STIM_:
## CUE_hgh_gt_                       
## STIM_linear                       
## EXPECT_demn                       
## STIM_qudrtc                       
## CUE_hgh_gt_lw:STIM_l              
## CUE_h__:EXPECT_                   
## STIM_:EXPEC                       
## CUE_hgh_gt_lw:STIM_q              
## EXPECT_:STI                       
## CUE___:STIM_:                     
## CUE___:EXPECT_:       0.003       
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

```r
# print(model.behexpectdemean, correlation=TRUE)
# * plot results
sjPlot::tab_model(model.behexpectdemean,
                  title = "Multilevel-modeling: \nlmer(OUTCOME_demean ~ CUE * STIM * EXPECT_demean + EXPECT_subjectwisemean +( CUE * STIM | sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(OUTCOME_demean ~ CUE * STIM * EXPECT_demean + EXPECT_subjectwisemean +( CUE * STIM | sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">OUTCOME_demean</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.39</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.37&nbsp;&ndash;&nbsp;1.15</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.312</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.13</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.05&nbsp;&ndash;&nbsp;-0.21</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.030</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">27.55</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">25.69&nbsp;&ndash;&nbsp;29.41</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.33</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.30&nbsp;&ndash;&nbsp;0.36</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.67</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.04&nbsp;&ndash;&nbsp;3.30</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.045</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.54</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;6.25&nbsp;&ndash;&nbsp;1.18</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.181</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.11&nbsp;&ndash;&nbsp;-0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.046</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.00&nbsp;&ndash;&nbsp;0.13</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.037</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;5.71</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;8.98&nbsp;&ndash;&nbsp;-2.45</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.473</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.31</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.18&nbsp;&ndash;&nbsp;0.44</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.15&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.568</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">384.97</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.00</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>11</sub> <sub>sub.CUE_high_gt_low</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">20.96</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&rho;<sub>01</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">&nbsp;</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">63</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">4122</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.383 / NA</td>
</tr>

</table>

```r
# * report stats
```



## model fit


```r
# STEP
# * load csv
data <- read.csv(file.path(main_dir, "/data/RL/modelfit_jepma_0525/table_pain.csv"))
analysis_dir <- file.path(main_dir, "/analysis/mixedeffect/CCNfigures")
data$sub <- data$src_subject_id
data$ses <- data$session_id
data$run <- data$param_run_num

data$stim[data$param_stimulus_type == "low_stim"] <-  -0.5 # social influence task
data$stim[data$param_stimulus_type == "med_stim"] <- 0 # no influence task
data$stim[data$param_stimulus_type == "high_stim"] <-  0.5 # no influence task

data$STIM <- factor(data$param_stimulus_type)

# contrast code 1 linear
data$STIM_linear[data$param_stimulus_type == "low_stim"] <- -0.5
data$STIM_linear[data$param_stimulus_type == "med_stim"] <- 0
data$STIM_linear[data$param_stimulus_type == "high_stim"] <- 0.5

# contrast code 2 quadratic
data$STIM_quadratic[data$param_stimulus_type == "low_stim"] <- -0.33
data$STIM_quadratic[data$param_stimulus_type == "med_stim"] <- 0.66
data$STIM_quadratic[data$param_stimulus_type == "high_stim"] <- -0.33

# social cue contrast
data$CUE_high_gt_low[data$param_cue_type == "low_cue"] <-  -0.5 # social influence task
data$CUE_high_gt_low[data$param_cue_type == "high_cue"] <-  0.5 # no influence task

data$EXPECT <- data$Exp_mdl2
data$OUTCOME <- data$Pain_mdl2
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
dv <- "OUTCOME"
dv_keyword <- "outcome_Jepma"
subject <- "sub"
taskname <- "pain"

  model_savefname <- file.path(
  analysis_dir,
  paste(
    "lmer_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.txt",
    sep = ""
  )
)


# * cooks d lmer
cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject = "sub",  dv_keyword,  model_savefname,  'random_intercept',
  print_lmer_output = TRUE
)
```

```
## [1] "model:  Outcome_jepma  ratings -  pain"
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: as.formula(model_string)
##    Data: data
## 
## REML criterion at convergence: 28019.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -6.4300 -0.5524 -0.0100  0.5268  7.5221 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 869.19   29.482  
##  Residual              47.15    6.867  
## Number of obs: 4122, groups:  sub, 63
## 
## Fixed effects:
##                                  Estimate Std. Error         df t value
## (Intercept)                     6.566e+01  3.716e+00  6.200e+01  17.671
## CUE_high_gt_low                 4.884e+00  2.140e-01  4.054e+03  22.823
## STIM_linear                     2.616e+01  2.617e-01  4.054e+03  99.967
## STIM_quadratic                  8.734e-01  2.296e-01  4.054e+03   3.803
## CUE_high_gt_low:STIM_linear    -9.294e-03  5.234e-01  4.054e+03  -0.018
## CUE_high_gt_low:STIM_quadratic  3.802e-02  4.593e-01  4.054e+03   0.083
##                                Pr(>|t|)    
## (Intercept)                     < 2e-16 ***
## CUE_high_gt_low                 < 2e-16 ***
## STIM_linear                     < 2e-16 ***
## STIM_quadratic                 0.000145 ***
## CUE_high_gt_low:STIM_linear    0.985833    
## CUE_high_gt_low:STIM_quadratic 0.934034    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                      (Intr) CUE_h__ STIM_l STIM_q CUE_hgh_gt_lw:STIM_l
## CUE_hgh_gt_           0.000                                           
## STIM_linear           0.000 -0.001                                    
## STIM_qudrtc           0.000 -0.002   0.006                            
## CUE_hgh_gt_lw:STIM_l  0.000 -0.008  -0.001  0.001                     
## CUE_hgh_gt_lw:STIM_q  0.000  0.004   0.001 -0.005  0.006
```

```r
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])
if (length(influential) > 0) {
data_screen <- data[-influential,]
} else {
  data_screen <- data
}
# * demean ___________
maindata <- data_screen %>%
  group_by(src_subject_id) %>%
  mutate(event04_actual_angle = as.numeric(event04_actual_angle)) %>%
  mutate(event02_expect_angle = as.numeric(event02_expect_angle)) %>%
  mutate(avg_outcome = mean(event04_actual_angle, na.rm = TRUE)) %>%
  mutate(demean_outcome = event04_actual_angle - avg_outcome) %>%
  mutate(avg_expect = mean(event02_expect_angle, na.rm = TRUE)) %>%
  mutate(demean_expect = event02_expect_angle - avg_expect) 
  # ungroup() %>%

cmc <- maindata %>%
mutate(OUTCOME_cmc = avg_outcome - mean(avg_outcome)) %>%
mutate(EXPECT_cmc = avg_expect - mean(avg_expect)) 

maindata$OUTCOME_cmc <- maindata$avg_outcome - mean(maindata$avg_outcome)
maindata$EXPECT_cmc <- maindata$avg_expect - mean(maindata$avg_expect)


data_p2= maindata %>%
  arrange(sub ) %>%
  group_by(sub) %>%
  mutate(trial_index = row_number())
data_a3 <- data_p2 %>% 
  group_by(sub, ses, run) %>% 
  mutate(trial_index = row_number(run))
data_a3lag <- 
    data_a3 %>%
    group_by(sub, ses, run) %>%
    mutate(lag.04outcomeangle = dplyr::lag(event04_actual_angle, n = 1, default = NA))
# data_a3lag_omit <- data_a3lag[complete.cases(data_a3lag$lag.04outcomeangle),]
main.df <- data_a3lag

# %% main lmer
main.df$EXPECT_demean <- main.df$demean_expect; 
main.df$OUTCOME_demean <- main.df$demean_outcome
model.behexpectdemean <- lmer(OUTCOME_demean ~ 
                          CUE_high_gt_low*STIM_linear*EXPECT_demean +
                          CUE_high_gt_low*STIM_quadratic*EXPECT_demean +
                          # EXPECT_cmc + # lag.04outcomeangle +
                          (CUE_high_gt_low|sub), data = main.df, REML = FALSE, control = lmerControl(optimizer ="Nelder_Mead"))
summary(model.behexpectdemean)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: OUTCOME_demean ~ CUE_high_gt_low * STIM_linear * EXPECT_demean +  
##     CUE_high_gt_low * STIM_quadratic * EXPECT_demean + (CUE_high_gt_low |  
##     sub)
##    Data: main.df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  36174.7  36275.8 -18071.3  36142.7     4096 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.3290 -0.5913 -0.0126  0.5723  4.8687 
## 
## Random effects:
##  Groups   Name            Variance  Std.Dev. Corr 
##  sub      (Intercept)     9.471e-03  0.09732      
##           CUE_high_gt_low 2.029e+01  4.50407 -1.00
##  Residual                 3.807e+02 19.51242      
## Number of obs: 4112, groups:  sub, 63
## 
## Fixed effects:
##                                                Estimate Std. Error         df
## (Intercept)                                   3.546e-01  3.889e-01  3.809e+03
## CUE_high_gt_low                              -1.569e+00  9.742e-01  1.045e+02
## STIM_linear                                   2.768e+01  9.511e-01  4.061e+03
## EXPECT_demean                                 3.148e-01  1.417e-02  2.652e+03
## STIM_quadratic                                1.400e+00  8.343e-01  4.062e+03
## CUE_high_gt_low:STIM_linear                  -3.235e+00  1.903e+00  4.067e+03
## CUE_high_gt_low:EXPECT_demean                -5.064e-02  2.716e-02  4.034e+03
## STIM_linear:EXPECT_demean                     8.907e-02  3.343e-02  4.083e+03
## CUE_high_gt_low:STIM_quadratic               -5.245e+00  1.669e+00  4.066e+03
## EXPECT_demean:STIM_quadratic                  9.746e-03  2.907e-02  4.086e+03
## CUE_high_gt_low:STIM_linear:EXPECT_demean     3.055e-01  6.684e-02  4.077e+03
## CUE_high_gt_low:EXPECT_demean:STIM_quadratic -1.769e-02  5.809e-02  4.076e+03
##                                              t value Pr(>|t|)    
## (Intercept)                                    0.912  0.36187    
## CUE_high_gt_low                               -1.611  0.11027    
## STIM_linear                                   29.099  < 2e-16 ***
## EXPECT_demean                                 22.219  < 2e-16 ***
## STIM_quadratic                                 1.678  0.09335 .  
## CUE_high_gt_low:STIM_linear                   -1.700  0.08918 .  
## CUE_high_gt_low:EXPECT_demean                 -1.865  0.06227 .  
## STIM_linear:EXPECT_demean                      2.664  0.00775 ** 
## CUE_high_gt_low:STIM_quadratic                -3.143  0.00169 ** 
## EXPECT_demean:STIM_quadratic                   0.335  0.73739    
## CUE_high_gt_low:STIM_linear:EXPECT_demean      4.572 4.99e-06 ***
## CUE_high_gt_low:EXPECT_demean:STIM_quadratic  -0.304  0.76077    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                      (Intr) CUE_h__ STIM_l EXPECT_d STIM_q CUE_hgh_gt_lw:STIM_l
## CUE_hgh_gt_           0.011                                                    
## STIM_linear          -0.006  0.008                                             
## EXPECT_demn          -0.062 -0.518  -0.016                                     
## STIM_qudrtc           0.004 -0.027   0.004  0.030                              
## CUE_hgh_gt_lw:STIM_l  0.010 -0.004   0.059  0.003   -0.006                     
## CUE_h__:EXPECT_      -0.621 -0.052   0.005  0.104    0.003 -0.017              
## STIM_:EXPEC          -0.017  0.004  -0.084 -0.013    0.011 -0.623              
## CUE_hgh_gt_lw:STIM_q -0.034  0.002  -0.007  0.004    0.011  0.004              
## EXPECT_:STI           0.031  0.004   0.012 -0.012   -0.041 -0.003              
## CUE___:STIM_:         0.005 -0.014  -0.623  0.027   -0.003 -0.084              
## CUE___:EXPECT_:       0.002  0.023  -0.003 -0.014   -0.621  0.011              
##                      CUE_h__:EXPECT_ STIM_: CUE_hgh_gt_lw:STIM_q EXPECT_:
## CUE_hgh_gt_                                                              
## STIM_linear                                                              
## EXPECT_demn                                                              
## STIM_qudrtc                                                              
## CUE_hgh_gt_lw:STIM_l                                                     
## CUE_h__:EXPECT_                                                          
## STIM_:EXPEC           0.027                                              
## CUE_hgh_gt_lw:STIM_q  0.030          -0.003                              
## EXPECT_:STI          -0.015           0.010 -0.622                       
## CUE___:STIM_:        -0.015           0.113  0.012               -0.019  
## CUE___:EXPECT_:      -0.009          -0.018 -0.041                0.093  
##                      CUE___:STIM_:
## CUE_hgh_gt_                       
## STIM_linear                       
## EXPECT_demn                       
## STIM_qudrtc                       
## CUE_hgh_gt_lw:STIM_l              
## CUE_h__:EXPECT_                   
## STIM_:EXPEC                       
## CUE_hgh_gt_lw:STIM_q              
## EXPECT_:STI                       
## CUE___:STIM_:                     
## CUE___:EXPECT_:       0.010
```

```r
# * plot results
sjPlot::tab_model(model.behexpectdemean,
                  title = "Multilevel-modeling: \nlmer(OUTCOME_demean ~ CUE * STIM * EXPECT_demean + EXPECT_subjectwisemean +( CUE * STIM | sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(OUTCOME_demean ~ CUE * STIM * EXPECT_demean + EXPECT_subjectwisemean +( CUE * STIM | sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">OUTCOME_demean</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.35</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.41&nbsp;&ndash;&nbsp;1.12</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.362</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.57</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;3.48&nbsp;&ndash;&nbsp;0.34</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.107</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">27.68</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">25.81&nbsp;&ndash;&nbsp;29.54</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.31</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.29&nbsp;&ndash;&nbsp;0.34</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.40</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.24&nbsp;&ndash;&nbsp;3.04</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.093</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;3.24</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;6.97&nbsp;&ndash;&nbsp;0.50</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.089</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.10&nbsp;&ndash;&nbsp;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.062</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.09</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02&nbsp;&ndash;&nbsp;0.15</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.008</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;5.25</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;8.52&nbsp;&ndash;&nbsp;-1.97</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.002</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05&nbsp;&ndash;&nbsp;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.737</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.31</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.17&nbsp;&ndash;&nbsp;0.44</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.13&nbsp;&ndash;&nbsp;0.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.761</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">380.73</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.01</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>11</sub> <sub>sub.CUE_high_gt_low</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">20.29</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&rho;<sub>01</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">-1.00</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.01</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">63</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">4112</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.377 / 0.385</td>
</tr>

</table>

```r
# * report stats
```



```r
df_lowClowS <- main.df[(main.df$STIM == "low_stim") & (main.df$param_cue_type == "low_cue"), ]

ggplot(
  df_lowClowS, 
  aes(
    x = EXPECT_demean,
    y = OUTCOME_demean,
    colour = src_subject_id
  )
) + 
geom_point() + # Add more layers or adjustments as needed
geom_smooth(method = 'lm', formula= y ~ x, se = FALSE)
```

```
## Warning: The following aesthetics were dropped during statistical transformation: colour
## ℹ This can happen when ggplot fails to infer the correct grouping structure in
##   the data.
## ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
##   variable into a factor?
```

<img src="CCN_supple_files/figure-html/unnamed-chunk-3-1.png" width="672" />

```r
df_medClowS <- main.df[(main.df$STIM == "med_stim") & (main.df$param_cue_type == "low_cue"), ]

ggplot(
  df_medClowS, 
  aes(
    x = EXPECT_demean,
    y = OUTCOME_demean,
    colour = src_subject_id
  )
) + 
geom_point() + # Add more layers or adjustments as needed
geom_smooth(method = 'lm', formula= y ~ x, se = FALSE)
```

```
## Warning: The following aesthetics were dropped during statistical transformation: colour
## ℹ This can happen when ggplot fails to infer the correct grouping structure in
##   the data.
## ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
##   variable into a factor?
```

<img src="CCN_supple_files/figure-html/unnamed-chunk-3-2.png" width="672" />

```r
df_highClowS <- main.df[(main.df$STIM == "high_stim") & (main.df$param_cue_type == "low_cue"), ]

ggplot(
  df_highClowS, 
  aes(
    x = EXPECT_demean,
    y = OUTCOME_demean,
    colour = src_subject_id
  )
) + 
geom_point() + # Add more layers or adjustments as needed
geom_smooth(method = 'lm', formula= y ~ x, se = FALSE)
```

```
## Warning: The following aesthetics were dropped during statistical transformation: colour
## ℹ This can happen when ggplot fails to infer the correct grouping structure in
##   the data.
## ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
##   variable into a factor?
```

<img src="CCN_supple_files/figure-html/unnamed-chunk-3-3.png" width="672" />

<!-- ```{r} -->
<!-- # library(lme4) -->
<!-- df_highClowS %>% -->
<!--   filter(src_subject_id %in% sample(levels(src_subject_id), 10)) %>% -->
<!--   ggplot(aes(EXPECT_demean, OUTCOME_demean, group=src_subject_id, color=src_subject_id)) + -->
<!--   geom_smooth(method="lm", se=F) + -->
<!--   geom_jitter(size=1) + -->
<!--   theme_minimal() -->
<!-- ``` -->
<!-- ```{r} -->
<!-- # extract the random effects from the model (intercept and slope) -->
<!-- ranef(model.behexpectdemean)$sub %>% -->
<!--   # implicitly convert them to a dataframe and add a column with the subject number -->
<!--   rownames_to_column(var="sub") %>% -->
<!--   # plot the intercept and slobe values with geom_abline() -->
<!--   ggplot(aes()) + -->
<!--   geom_abline(aes(intercept=`(Intercept)`, slope=CUE_high_gt_low, color=sub)) + -->
<!--   # add axis label -->
<!--   xlab("EXPECT_demean") + ylab("Residual RT") + -->
<!--   # set the scale of the plot to something sensible -->
<!--   scale_x_continuous(limits=c(0,10), expand=c(0,0)) + -->
<!--   scale_y_continuous(limits=c(-100, 100)) -->
<!-- ``` -->

<!-- ```{r} -->

<!-- # https://stackoverflow.com/questions/40297206/overlaying-two-plots-using-ggplot2-in-r -->
<!-- # https://www.r-bloggers.com/2021/02/using-random-effects-in-gams-with-mgcv/ -->
<!-- cue_high <- main.df[ (main.df$param_cue_type == "high_cue"), ] -->
<!-- ggplot(cue_high, aes(x = EXPECT, y = OUTCOME, -->
<!--                  group = sub, colour = CUE_high_gt_low)) + -->
<!--     geom_line() + -->
<!--     facet_wrap(~ STIM_linear, ncol = 3) -->
<!-- cue_low <- main.df[ (main.df$param_cue_type == "low_cue"), ] -->
<!-- ggplot(cue_low, aes(x = EXPECT, y = OUTCOME, -->
<!--                  group = sub, colour = CUE_high_gt_low)) +  -->
<!--     geom_line() + -->
<!--     facet_wrap(~ STIM_linear, ncol = 3) + -->
<!--     geom_line(data = cue_high, color = "red") -->


<!-- # group slope  -->

<!-- # ggplot( -->
<!-- #   df_highClowS,  -->
<!-- #   aes( -->
<!-- #     x = EXPECT_demean, -->
<!-- #     y = OUTCOME_demean, -->
<!-- #     colour = src_subject_id -->
<!-- #   ) -->
<!-- # ) +  -->
<!-- # geom_point() + # Add more layers or adjustments as needed -->
<!-- # geom_smooth(method = 'lm', formula= y ~ x, se = FALSE) -->


<!-- cue_high <- main.df[ (main.df$param_cue_type == "high_cue"), ] -->
<!-- ggplot(cue_high, aes(x = EXPECT, y = OUTCOME, -->
<!--                  group = sub, colour = CUE_high_gt_low)) + -->
<!--   geom_line() + -->
<!--   geom_smooth(method = 'lm', formula= y ~ x, se = FALSE) + -->

<!--     facet_wrap(~ STIM_linear, ncol = 3) -->
<!-- cue_low <- main.df[ (main.df$param_cue_type == "low_cue"), ] -->
<!-- ggplot(cue_low, aes(x = EXPECT, y = OUTCOME, -->
<!--                  group = sub, colour = CUE_high_gt_low)) + -->
<!--     geom_line() + -->
<!--     facet_wrap(~ STIM_linear, ncol = 3) + -->
<!--     geom_line(data = cue_high, color = "red") -->
<!-- ``` -->

<!-- ```{r} -->
<!-- cue_high <- main.df[ (main.df$param_cue_type == "high_cue"), ] -->
<!-- # ggplot(cue_high, aes(x = EXPECT_demean, y = OUTCOME_demean, -->
<!-- #                  group = sub, colour = CUE_high_gt_low)) + -->
<!-- #     geom_line() + -->
<!-- #     facet_wrap(~ STIM_linear, ncol = 3) -->
<!-- cue_low <- main.df[ (main.df$param_cue_type == "low_cue"), ] -->


<!-- ggplot(cue_low, aes(x = EXPECT, y = OUTCOME_demean, -->
<!--                  group = sub, colour = CUE_high_gt_low)) + -->
<!--     geom_line() + -->
<!--     facet_wrap(~ STIM_linear, ncol = 3) + -->
<!--     geom_line(data = cue_high, color = "red") -->
<!-- #  -->
<!-- # ggplot(cue_low, aes(x = EXPECT, y = OUTCOME_demean, -->
<!-- #                  group = sub, colour = CUE_high_gt_low)) + -->
<!-- #     geom_line(data = cue_low, color = "blue") + -->
<!-- #     geom_smooth(method = 'lm', formula= y ~ x, se = FALSE) -->
<!-- #     facet_wrap(~ STIM_linear, ncol = 3) + -->
<!-- #     geom_line(data = cue_high, color = "red") -->
<!-- ``` -->




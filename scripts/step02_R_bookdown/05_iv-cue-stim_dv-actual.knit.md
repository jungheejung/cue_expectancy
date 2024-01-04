# [beh] outcome_rating ~ cue * stim {#ch05_outcome-cueXstim}

## What is the purpose of this notebook? {.unlisted .unnumbered}

Here, I plot the outcome ratings as a function of cue and stimulus intensity. 

* Main model: `lmer(outcome_rating ~ cue * stim)` 
* Main question: do outcome ratings differ as a function of cue type and stimulus intensity? 
* If there is a main effect of cue on outcome ratings, does this cue effect differ depending on task type?
* Is there an interaction between the two factors?
* IV: 
  - cue (high / low)
  - stim (high / med / low)
* DV: outcome rating





## model 03 iv-cuecontrast dv-actual
<img src="05_iv-cue-stim_dv-actual_files/figure-html/common_parameters_4-1.png" width="672" /><img src="05_iv-cue-stim_dv-actual_files/figure-html/common_parameters_4-2.png" width="672" /><img src="05_iv-cue-stim_dv-actual_files/figure-html/common_parameters_4-3.png" width="672" /><img src="05_iv-cue-stim_dv-actual_files/figure-html/common_parameters_4-4.png" width="672" /><img src="05_iv-cue-stim_dv-actual_files/figure-html/common_parameters_4-5.png" width="672" /><img src="05_iv-cue-stim_dv-actual_files/figure-html/common_parameters_4-6.png" width="672" />



```r
# DELETE LATER
subset_df<- data[,c("src_subject_id", "session_id", "param_run_num", "param_task_name", "param_cue_type", "param_stimulus_type","event02_expect_RT", "event02_expect_angle","event04_actual_RT", "event04_actual_angle")]
df_trials <- subset_df %>% 
  group_by(src_subject_id, session_id, param_run_num) %>% 
  mutate(trial_index_runwise = row_number(param_run_num))
df_filtered <- subset(df_trials, complete.cases(df_trials) & !is.na(event02_expect_angle) & !is.na(event04_actual_angle))
df_filtered_final= df_filtered %>%
  arrange(src_subject_id ) %>%
  group_by(src_subject_id) %>%
  mutate(trial_index_subjectwise = row_number())
write.csv(df_filtered_final, file = "spacetop_cue_0405.csv", row.names = FALSE)
```

### model 03 3-2. individual difference


### model 04 iv-cue-stim dv-actual
<img src="05_iv-cue-stim_dv-actual_files/figure-html/unnamed-chunk-2-1.png" width="672" /><img src="05_iv-cue-stim_dv-actual_files/figure-html/unnamed-chunk-2-2.png" width="672" /><img src="05_iv-cue-stim_dv-actual_files/figure-html/unnamed-chunk-2-3.png" width="672" />

### Nov 17 lmer

```r
    # stim_con1 <- "stim_con_linear"
    # stim_con2 <- "stim_con_quad"
    # iv1 <- "social_cue"
    # dv <- "event04_actual_angle"

fullmodel <- lmer(event04_actual_angle ~ 1+ social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear + social_cue:stim_con_quad
     + (1+ social_cue + stim_con_linear + stim_con_quad+ social_cue:stim_con_linear  | src_subject_id), data=data)
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## Model failed to converge with max|grad| = 0.00289359 (tol = 0.002, component 1)
```

```r
summary(fullmodel)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: 
## event04_actual_angle ~ 1 + social_cue + stim_con_linear + stim_con_quad +  
##     social_cue:stim_con_linear + social_cue:stim_con_quad + (1 +  
##     social_cue + stim_con_linear + stim_con_quad + social_cue:stim_con_linear |  
##     src_subject_id)
##    Data: data
## 
## REML criterion at convergence: 54523.3
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -3.4933 -0.6226 -0.1494  0.4685  7.0855 
## 
## Random effects:
##  Groups         Name                       Variance Std.Dev. Corr             
##  src_subject_id (Intercept)                160.754  12.679                    
##                 social_cue                  27.920   5.284    0.37            
##                 stim_con_linear             11.125   3.335    0.60 -0.04      
##                 stim_con_quad                2.762   1.662    0.79  0.24  0.72
##                 social_cue:stim_con_linear   3.194   1.787   -0.29  0.68 -0.08
##  Residual                                  349.847  18.704                    
##       
##       
##       
##       
##       
##  -0.15
##       
## Number of obs: 6220, groups:  src_subject_id, 110
## 
## Fixed effects:
##                             Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept)                  28.4134     1.2360  109.1700  22.989  < 2e-16 ***
## social_cue                    8.0490     0.7017  106.1701  11.470  < 2e-16 ***
## stim_con_linear               8.1671     0.6657  106.6629  12.269  < 2e-16 ***
## stim_con_quad                 3.0904     0.5349  110.9917   5.777 7.05e-08 ***
## social_cue:stim_con_linear    2.5872     1.1738 1374.8959   2.204   0.0277 *  
## social_cue:stim_con_quad     -1.6740     1.0200 5843.4900  -1.641   0.1008    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                (Intr) socl_c stm_cn_l stm_cn_q scl_c:stm_cn_l
## social_cue      0.262                                        
## stim_cn_lnr     0.284 -0.015                                 
## stim_con_qd     0.232  0.049  0.106                          
## scl_c:stm_cn_l -0.041  0.074 -0.002   -0.008                 
## scl_c:stm_cn_q -0.001  0.004 -0.002    0.000    0.001        
## optimizer (nloptwrap) convergence code: 0 (OK)
## Model failed to converge with max|grad| = 0.00289359 (tol = 0.002, component 1)
```


### model 04 4-2 individual differences in cue effects


### model 04 4-3 scatter plot








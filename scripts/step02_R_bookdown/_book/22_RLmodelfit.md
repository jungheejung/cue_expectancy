
# [RL] model fit data {#ch22_RL}

* Given that the brain results only includes 80 participants, I'm plotting the behavioral data with identical participants as well
* behavioral results

```
title: "CCN_figures"
author: "Heejung Jung"
date: "2023-04-06"
output: html_document
```








## behavioral outcome ratings ~ expectations * cue
Plot pain outcome rating as a function of expectation rating and cue {.unlisted .unnumbered}

<img src="22_RLmodelfit_files/figure-html/load_data_and_exclude_m1-1.png" width="672" />

## behavioral demeaned (both)


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

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-1-1.png" width="672" />
## behavioral only expectaiton deman


```r
# maindata <- pvc %>%
# group_by(src_subject_id, session_id, param_run_num) %>%
# mutate(event04_actual_angle = as.numeric(event04_actual_angle)) %>%
# mutate(event02_expect_angle = as.numeric(event02_expect_angle)) %>%
# mutate(avg_outcome = mean(event04_actual_angle, na.rm = TRUE)) %>%
# mutate(demean_outcome = event04_actual_angle - avg_outcome) %>%
# mutate(avg_expect = mean(event02_expect_angle, na.rm = TRUE)) %>%
# mutate(demean_expect = event02_expect_angle - avg_expect)


sp <- plot_twovariable(
  df = maindata, 
  iv1 = "demean_expect", iv2 = "event04_actual_angle",
  group = "param_cue_type", subject ="src_subject_id", 
  xmin=-50, xmax=50, ymin=0,ymax=180,
  xlab = "Expectation rating\n(subjectwise-demeaned)", ylab = "Outcome rating", 
  ggtitle="", color_scheme = c("high_cue" ="#941100","low_cue" =  "#5D5C5C"), 
  alpha = .9, fit_lm = TRUE, lm_method = "lm", identity_line=FALSE, size=NULL)

# Add description ______________________________________________________________
sp +  

  theme(text = element_text(size = 15)) +theme(aspect.ratio=1) +
  theme(axis.line = element_line(colour = "black"),
      panel.background = element_blank(),
      plot.subtitle = ggtext::element_textbox_simple(size= 11))
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-2-1.png" width="672" />

## behavioral :: line plot cue * stim (outcome demena)
### model 04 4-4 lineplot (demean)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-3-1.png" width="672" />

## behavioral :: line plots cue * stim * intensity (demean outcome)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-4-1.png" width="672" />
  
## behavioral :: line plots cue * stim * intensity (demean outcome)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-5-1.png" width="672" />

## NPS: stim * cue


### Fig B: cue * stim lineplot
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-7-1.png" width="672" />


### NPS demeaned: stim*cue

```r
#  [ PLOT ] calculate mean and se  _________________________
NPSmaindata <- data_screen %>%
  group_by(sub) %>%
  mutate(event04_actual_angle = as.numeric(event04_actual_angle)) %>%
  mutate(event02_expect_angle = as.numeric(event02_expect_angle)) %>%
  mutate(avg_outcome = mean(event04_actual_angle, na.rm = TRUE)) %>%
  mutate(demean_outcome = event04_actual_angle - avg_outcome) %>%
  mutate(avg_expect = mean(event02_expect_angle, na.rm = TRUE)) %>%
  mutate(demean_expect = event02_expect_angle - avg_expect) 
  # ungroup() %>%

NPS.df <- NPSmaindata %>%
  group_by(sub) %>%
  mutate(NPSpos = as.numeric(NPSpos)) %>%
  mutate(avg_NPS = mean(NPSpos, na.rm = TRUE)) %>%
  mutate(demean_NPS = NPSpos - avg_NPS)

cmc <- NPS.df %>%
mutate(OUTCOME_cmc = avg_outcome - mean(avg_outcome)) %>%
mutate(EXPECT_cmc = avg_expect - mean(avg_expect)) %>%
mutate(NPS_cmc = avg_NPS - mean(avg_NPS)) 


data_p2= cmc %>%
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
NPS.df <- data_a3lag
# pvc <- simple_contrasts_beh(df)

# pvc <-simple_contrasts_beh(maindata)
LINEIV1 = "stim_ordered"
LINEIV2 = "cue_ordered"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
dv = "demean_NPS"
subject = "sub"
model_iv1 = "stim_ordered"
model_iv2 = "cue_ordered"

taskname <- "pain"
NPSstimcue_subjectwise <- meanSummary(NPS.df,
                                      c(subject, model_iv1, model_iv2), dv)
df_dropna <- NPSstimcue_subjectwise[!is.na(NPSstimcue_subjectwise[, "mean_per_sub"]), ]
NPSstimcue_groupwise <- summarySEwithin(
  data = df_dropna,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
DATA = as.data.frame(NPSstimcue_groupwise)
color = c( "#4575B4", "#D73027")
LINEIV1 = "stim_ordered"
LINEIV2 = "cue_ordered"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
p1 = plot_lineplot_twofactor(DATA,
               LINEIV1, LINEIV2, MEAN, ERROR, color, ggtitle = 'pain', ylab = "NPSpos\n(subject/runwise mean-centered" )

p1 +   theme(aspect.ratio=.9) + 
  theme(text = element_text(size = 15)) 
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-8-1.png" width="672" />

### lmer


```r
NPS.df$EXPECT_demean <- NPS.df$demean_expect; NPS.df$OUTCOME_demean <- NPS.df$demean_outcome
model.NPSdemean <- lmer(NPSpos ~ 
                          CUE_high_gt_low*STIM_linear +
                          CUE_high_gt_low*STIM_quadratic +
                           # lag.04outcomeangle +
                          (1 |sub), data = NPS.df
                    ) 
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.NPSdemean,
                  title = "Multilevel-modeling: \nlmer(OUTCOME ~ CUE * STIM * EXPECT_demean + (1| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(OUTCOME ~ CUE * STIM * EXPECT_demean + (1| sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">NPSpos</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">6.90</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">5.71&nbsp;&ndash;&nbsp;8.09</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.78</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.29&nbsp;&ndash;&nbsp;-0.28</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.002</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">2.60</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.99&nbsp;&ndash;&nbsp;3.21</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.49&nbsp;&ndash;&nbsp;0.59</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.858</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.65</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.88&nbsp;&ndash;&nbsp;0.57</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.298</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.71</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.78&nbsp;&ndash;&nbsp;0.37</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.198</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">63.74</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">29.04</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.31</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">84</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">3904</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.014 / 0.323</td>
</tr>

</table>



### NPS: cue * expect (expect demean)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-10-1.png" width="672" />
### NPS: cue * expect (both demean)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-11-1.png" width="672" />

### NPS: stim * cue * expect
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-12-1.png" width="672" />


### NPS: stim * cue * expect (demean)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-13-1.png" width="672" />

### NPS demeaned (both)


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-14-1.png" width="672" />

### NPS demeaned cue *expect


```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-15-1.png" width="672" />



## Behavioral data
### lmer

```r
NPS.df$EXPECT_demean <- NPS.df$demean_expect; NPS.df$OUTCOME_demean <- NPS.df$demean_outcome
model.behexpectdemean <- lmer(event04_actual_angle ~ 
                          CUE_high_gt_low*STIM_linear*EXPECT_demean +
                          CUE_high_gt_low*STIM_quadratic*EXPECT_demean +
                          EXPECT_cmc + # lag.04outcomeangle +
                          (1 |sub), data = NPS.df
                    ) 
```

```
## fixed-effect model matrix is rank deficient so dropping 1 column / coefficient
```

```r
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.behexpectdemean,
                  title = "Multilevel-modeling: \nlmer(OUTCOME ~ CUE * STIM * EXPECT_demean + (1| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(OUTCOME ~ CUE * STIM * EXPECT_demean + (1| sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">event04_actual_angle</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">68.19</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">62.03&nbsp;&ndash;&nbsp;74.34</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.27</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;3.85&nbsp;&ndash;&nbsp;-0.68</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.005</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">27.96</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">26.03&nbsp;&ndash;&nbsp;29.89</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.31</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.28&nbsp;&ndash;&nbsp;0.34</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.81</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.10&nbsp;&ndash;&nbsp;3.51</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.038</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;7.92&nbsp;&ndash;&nbsp;-0.19</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.040</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.12&nbsp;&ndash;&nbsp;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.053</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.01&nbsp;&ndash;&nbsp;0.13</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.072</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;5.70</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;9.12&nbsp;&ndash;&nbsp;-2.29</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.502</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.31</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.17&nbsp;&ndash;&nbsp;0.44</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.15&nbsp;&ndash;&nbsp;0.09</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.601</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">383.68</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">810.46</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.68</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">84</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">3780</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.160 / 0.730</td>
</tr>

</table>


```r
# NPS.df$EXPECT_demean <- NPS.df$demean_expect; NPS.df$OUTCOME_demean <- NPS.df$demean_outcome
model.fig1<- lmer(OUTCOME_demean ~ 
                          CUE_high_gt_low*EXPECT_demean +
                          
                          (1|sub), data = NPS.df
                    ) 
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.fig1,
                  title = "Multilevel-modeling: \nlmer(OUTCOME ~ CUE * STIM + (CUE| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(OUTCOME ~ CUE * STIM + (CUE| sub), data = pvc)</caption>
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
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.54&nbsp;&ndash;&nbsp;1.33</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.407</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;3.93&nbsp;&ndash;&nbsp;-0.19</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.031</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.30</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.27&nbsp;&ndash;&nbsp;0.34</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.11&nbsp;&ndash;&nbsp;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.200</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">536.17</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.00</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">84</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">3780</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.109 / NA</td>
</tr>

</table>


```r
# NPS.df$EXPECT_demean <- NPS.df$demean_expect; NPS.df$OUTCOME_demean <- NPS.df$demean_outcome
model.behoutcome<- lmer(event04_actual_angle ~ 
                          CUE_high_gt_low*STIM_linear +
                          CUE_high_gt_low*STIM_quadratic +
                          (CUE_high_gt_low|sub), data = NPS.df
                    ) 
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.behoutcome,
                  title = "Multilevel-modeling: \nlmer(OUTCOME ~ CUE * STIM + (CUE| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(OUTCOME ~ CUE * STIM + (CUE| sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">event04_actual_angle</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">67.70</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">61.55&nbsp;&ndash;&nbsp;73.85</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">8.55</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">6.67&nbsp;&ndash;&nbsp;10.43</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">30.65</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">29.05&nbsp;&ndash;&nbsp;32.24</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.16</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.24&nbsp;&ndash;&nbsp;2.56</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.105</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.48</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.67&nbsp;&ndash;&nbsp;1.71</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.363</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.74</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;7.55&nbsp;&ndash;&nbsp;-1.94</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.001</strong></td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">431.42</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">814.46</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>11</sub> <sub>sub.CUE_high_gt_low</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">36.58</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&rho;<sub>01</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.04</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.66</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">84</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">3904</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.123 / 0.699</td>
</tr>

</table>


### Fig A2: behavioral demeaned (both)


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-19-1.png" width="672" />

```
## Saving 7 x 5 in image
## `geom_smooth()` using formula = 'y ~ x'
```

### Fig A1: behavioral lineplots
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-20-1.png" width="672" />
### Fig A1, A2, B

```r
a1.combine <- a1 + theme(text = element_text(size = 14), 
                       aspect.ratio=1,
                       axis.line = element_line(colour = "grey50"),
                       panel.background = element_blank())
a2.combine <- a2 + theme(text = element_text(size = 14), 
                       aspect.ratio=1,
                       axis.line = element_line(colour = "grey50"),
                       panel.background = element_blank())
fig.b <- fig.b + theme(text = element_text(size = 14), 
                       aspect.ratio=1,
                       axis.line = element_line(colour = "grey50"),
                       panel.background = element_blank())

fig.ab <- ggpubr::ggarrange(a1.combine, a2.combine, fig.b, ncol = 3, nrow = 1, common.legend = FALSE, legend = "bottom")
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```r
plots_title <- annotate_figure(plots, top = text_grob("individual differences\n - cue effects from outcome ratings", color = "black", face = "bold", size = 15))
ggsave('/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/mixedeffect/CCNfigures/figAB.png', fig.ab)
```

```
## Saving 7 x 5 in image
```

```
## Warning in grDevices::dev.off(): agg could not write to the given file
```

```r
fig.ab
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-21-1.png" width="672" />



### Fig C: behavioral cue * stim * expect
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-22-1.png" width="672" />

## Model fit (model)
load data

```r
paindf <- read.csv("/Users/h/Documents/projects_local/cue_expectancy/data/RL/modelfit_jepma_0525/table_pain.csv")
analysis_dir <- file.path(main_dir, "analysis", "mixedeffect", "22_modelfit", as.character(Sys.Date()))

# load data ____________________________________________________________________ # nolint
# df <- load_task_social_df(datadir, taskname = taskname, subject_varkey = subject_varkey, iv = iv, exclude = exclude)
data.2= paindf %>%
  arrange(src_subject_id ) %>%
  group_by(src_subject_id) %>%
  mutate(trial_number = row_number(Pain_mdl2))
df_with_trial_number <- aggregate(trial_number ~ src_subject_id, data = data.2, FUN = function(x) length(unique(x)))
sessions_per_subject <- aggregate(session_id ~ src_subject_id, data = data.2, FUN = function(x) length(unique(x)))
# subset_N <- df_with_trial_number %>%
#   inner_join(sessions_per_subject, by = "src_subject_id") %>%
#   filter(trial_number > 50, session_id == 3)
# TODO: FIX scripts/step02_R/utils/filter_df_ses_trial.R
# df_summary <- filter_df_ses_trial(data, session_colname = "session_id", subject_colname = "src_subject_id", session_threshold = 3, trial_threshold = 50)
# data <- df %>%
# semi_join(subset_N, by = "src_subject_id")
data <- data.2

# demean ratings _______________________________________________________________ # nolint
maindata <- data %>%
group_by(src_subject_id) %>%
mutate(Pain_mdl2 = as.numeric(Pain_mdl2)) %>%
mutate(Exp_mdl2 = as.numeric(Exp_mdl2)) %>%
mutate(avg_outcome_model = mean(Pain_mdl2, na.rm = TRUE)) %>%
mutate(demean_outcome_model = Pain_mdl2 - avg_outcome_model) %>%
mutate(avg_expect_model = mean(Exp_mdl2, na.rm = TRUE)) %>%
mutate(demean_expect_model = Exp_mdl2 - avg_expect_model)



# count trial index and shift __________________________________________________ # nolint
data_p2= maindata %>%
  arrange(src_subject_id ) %>%
  group_by(src_subject_id) %>%
  mutate(trial_index = row_number())
data_a3 <- data_p2 %>% 
  group_by(src_subject_id, session_id, param_run_num) %>% 
  mutate(trial_index = row_number(param_run_num))
data_a3lag <- 
    data_a3 %>%
    group_by(src_subject_id, session_id, param_run_num) %>%
    mutate(lag.04outcomeangle = dplyr::lag(Pain_mdl2, n = 1, default = NA))
data_a3lag_omit <- data_a3lag[complete.cases(data_a3lag$lag.04outcomeangle),]
df <- data_a3lag_omit
pvc <- simple_contrasts_beh(df)
```

```
## Warning: Unknown or uninitialised column: `stim_con_linear`.
```

```
## Warning: Unknown or uninitialised column: `stim_con_quad`.
```

```
## Warning: Unknown or uninitialised column: `CUE_high_gt_low`.
```

```
## Warning: Unknown or uninitialised column: `cue_name`.
```

### plot 

```r
# summarize dataframe __________________________________________________________ # nolint
iv1 = "Exp_mdl2"; iv2 = "Pain_mdl2"
df_dropna <- pvc[!is.na(pvc[, iv1]) & !is.na(pvc[, iv2]), ]
subjectwise_2dv = meanSummary_2dv(df_dropna,
        c("src_subject_id", "param_cue_type"), 
          "Exp_mdl2", "Pain_mdl2")
subjectwise_naomit_2dv <- na.omit(subjectwise_2dv)
subjectwise_naomit_2dv$param_cue_type <- as.factor(subjectwise_naomit_2dv$param_cue_type)

# plot _________________________________________________________________________ # nolint
sp <- plot_twovariable(
  df = pvc, 
  iv1 = "Exp_mdl2", iv2 = "Pain_mdl2",
  group = "param_cue_type", subject ="src_subject_id", 
  xmin=0, xmax=180, ymin=0,ymax=180,
  xlab = "Expectation rating", ylab = "Outcome rating", 
  ggtitle="", color_scheme = c("high_cue" ="#941100","low_cue" =  "#5D5C5C"), 
  alpha = .9, fit_lm = FALSE, lm_method = NULL, identity_line=TRUE, size=NULL)

# add plot description _________________________________________________________  # nolint
sp +  
  # labs(title =paste0("task-",taskname, "- What is the pattern for outcome and expect ratings? \nHow is does this pattern differ depending on high vs low cues?\n\n")
  #         ) + 
  theme(text = element_text(size = 15)) +theme(aspect.ratio=1) +
  theme(axis.line = element_line(colour = "black"),
      panel.background = element_blank(),
      plot.subtitle = ggtext::element_textbox_simple(size= 11))
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-24-1.png" width="672" />

```r
sp <- plot_twovariable(
  df = pvc, 
  iv1 = "demean_expect_model", iv2 = "demean_outcome_model",
  group = "param_cue_type", subject ="src_subject_id", 
  xmin=-50, xmax=50, ymin=-25,ymax=25,
  xlab = "Expectation rating\n(subjectwise-demeaned)", ylab = "Outcome rating\n(subjectwise-demeaned)", 
  ggtitle="", color_scheme = c("high_cue" ="#941100","low_cue" =  "#5D5C5C"), 
  alpha = .9, fit_lm = TRUE, lm_method = "lm", identity_line=TRUE, size=NULL)

# Add description ______________________________________________________________
sp +  

  theme(text = element_text(size = 15)) +theme(aspect.ratio=1) +
  theme(axis.line = element_line(colour = "black"),
      panel.background = element_blank(),
      plot.subtitle = ggtext::element_textbox_simple(size= 11))
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-24-2.png" width="672" />



### 3 way interaction behavioral :: line plots cue * stim * intensity (demean outcome)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-25-1.png" width="672" />

## congruent incongruent


### 3 way interaction behavioral :: line plots cue * stim * intensity (demean outcome)
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-26-1.png" width="672" />








### Fig D: 3 panel cue * stim * expect
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-28-1.png" width="672" />


## congruent incongruent for model fitted results
<img src="22_RLmodelfit_files/figure-html/unnamed-chunk-29-1.png" width="672" />
## save dataframe

```r
write.csv(NPS.df, 
          file.path(main_dir, 'analysis', 'mixedeffect', 'CCNfigures', 'dataframe.csv'))
```





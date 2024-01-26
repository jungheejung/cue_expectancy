# [fMRI] NPS ~ singletrial {#ch41_EndersTofighi}

---
title: "[fMRI] NPS ~ singletrial"
output:
  html_document:
    toc: true
    toc_float:
      collapsed: false
      smooth_scroll: false
---

## What is the purpose of this notebook? {.unlisted .unnumbered}

-   Here, I model NPS dot products as a function of cue, stimulus intensity and expectation ratings.
-   One of the findings is that low cues lead to higher NPS dotproducts in the high intensity group, and that this effect becomes non-significant across sessions.
-   03/23/2023: For now, I'm grabbing participants that have complete data, i.e. 18 runs, all three sessions.









## 1. NPS \~ 3 task x 3 stimulus intensity


```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-NPS_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-1.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-2.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-3.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-4.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-NPSneg_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-5.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-6.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-VPS_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-7.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-8.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-ZhouVPS_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-9.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-10.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-PINES_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-11.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-12.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-GSR_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-13.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-14.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-GeuterPaincPDM_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-15.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-16.png" width="672" />

```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-SIIPS_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-17.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-1-18.png" width="672" />

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-2-1.png" width="672" />



```
## [1] "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/nilearn/deriv01_signature/ttl2/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv"
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-3-1.png" width="672" />



```r
# contrast code 1 linear
pvc$task_V_gt_C[pvc$task == "pain"] <-  0
pvc$task_V_gt_C[pvc$task == "vicarious"] <-  0.5
pvc$task_V_gt_C[pvc$task == "cognitive"] <- -0.5

# contrast code 2 quadratic
pvc$task_P_gt_VC[pvc$task == "pain"] <-  0.66
pvc$task_P_gt_VC[pvc$task == "vicarious"] <-  0.34
pvc$task_P_gt_VC[pvc$task == "cognitive"] <-  -0.34
```

#### Contrast weight table {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 15px; ">
<caption style="font-size: initial !important;">(\#tab:unnamed-chunk-5)Contrast weights</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> pain </th>
   <th style="text-align:right;"> vicarious </th>
   <th style="text-align:right;"> cognitive </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> task_V_gt_C </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> -0.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> task_P_gt_VC </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> -0.34 </td>
   <td style="text-align:right;"> -0.34 </td>
  </tr>
</tbody>
</table>


### Linear model results (NPS \~ paintask: 2 cue x 3 stimulus_intensity)


```r
model.task_stim <- lmer(NPSpos ~ 
                          task_P_gt_VC*stimintensity +  task_V_gt_C*stimintensity +
                          (1|sub), data = pvc
                    )
sjPlot::tab_model(model.task_stim,
                  title = "Multilevel-modeling: \nlmer(DATA ~ TASK * STIM + (1 | sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(DATA ~ TASK * STIM + (1 | sub), data = pvc)</caption>
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
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.41&nbsp;&ndash;&nbsp;0.41</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.995</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">task P gt VC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">11.27</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">10.66&nbsp;&ndash;&nbsp;11.88</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">stimintensity [low]</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.43</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.11&nbsp;&ndash;&nbsp;0.75</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.008</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">stimintensity [med]</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.25</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.07&nbsp;&ndash;&nbsp;0.56</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.127</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">task V gt C</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;8.51</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;9.12&nbsp;&ndash;&nbsp;-7.90</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">task P gt VC ×<br>stimintensity [low]</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;3.84</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.70&nbsp;&ndash;&nbsp;-2.98</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">task P gt VC ×<br>stimintensity [med]</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.58</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.44&nbsp;&ndash;&nbsp;-0.71</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">stimintensity [low] ×<br>task V gt C</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">2.69</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.83&nbsp;&ndash;&nbsp;3.55</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">stimintensity [med] ×<br>task V gt C</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.24&nbsp;&ndash;&nbsp;1.96</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.012</strong></td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">60.14</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">3.43</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.05</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">112</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">20041</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.121 / 0.168</td>
</tr>

</table>

```         
lmer(NPSpos ~ 
                          CUE_high_gt_low*STIM_linear +CUE_high_gt_low * STIM_quadratic +
                          (CUE_high_gt_low+STIM|sub), data = data_screen
                    )
```


```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: NPSpos ~ task_P_gt_VC * stimintensity + task_V_gt_C * stimintensity +  
##     (1 | sub)
##    Data: pvc
## 
## REML criterion at convergence: 139241.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -6.8241 -0.4906  0.0003  0.4993 10.5500 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept)  3.427   1.851   
##  Residual             60.142   7.755   
## Number of obs: 20041, groups:  sub, 112
## 
## Fixed effects:
##                                 Estimate Std. Error         df t value Pr(>|t|)
## (Intercept)                   -1.223e-03  2.103e-01  1.843e+02  -0.006 0.995367
## task_P_gt_VC                   1.127e+01  3.113e-01  1.995e+04  36.199  < 2e-16
## stimintensitylow               4.313e-01  1.616e-01  1.992e+04   2.668 0.007628
## stimintensitymed               2.469e-01  1.616e-01  1.992e+04   1.528 0.126647
## task_V_gt_C                   -8.509e+00  3.113e-01  1.993e+04 -27.331  < 2e-16
## task_P_gt_VC:stimintensitylow -3.844e+00  4.393e-01  1.992e+04  -8.749  < 2e-16
## task_P_gt_VC:stimintensitymed -1.576e+00  4.392e-01  1.992e+04  -3.587 0.000335
## stimintensitylow:task_V_gt_C   2.688e+00  4.399e-01  1.992e+04   6.111 1.01e-09
## stimintensitymed:task_V_gt_C   1.102e+00  4.398e-01  1.992e+04   2.505 0.012262
##                                  
## (Intercept)                      
## task_P_gt_VC                  ***
## stimintensitylow              ** 
## stimintensitymed                 
## task_V_gt_C                   ***
## task_P_gt_VC:stimintensitylow ***
## task_P_gt_VC:stimintensitymed ***
## stimintensitylow:task_V_gt_C  ***
## stimintensitymed:task_V_gt_C  *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                        (Intr) ts_P__VC stmntnstyl stmntnstym t_V__C
## tsk_P_gt_VC            -0.303                                      
## stmntnstylw            -0.384  0.393                               
## stmntnstymd            -0.384  0.393    0.500                      
## task_V_gt_C             0.205 -0.679   -0.266     -0.266           
## tsk_P_gt_VC:stmntnstyl  0.214 -0.706   -0.557     -0.279      0.479
## tsk_P_gt_VC:stmntnstym  0.214 -0.706   -0.279     -0.558      0.479
## stmntnstyl:_V__C       -0.145  0.478    0.377      0.188     -0.706
## stmntnstym:_V__C       -0.145  0.479    0.188      0.377     -0.706
##                        tsk_P_gt_VC:stmntnstyl tsk_P_gt_VC:stmntnstym
## tsk_P_gt_VC                                                         
## stmntnstylw                                                         
## stmntnstymd                                                         
## task_V_gt_C                                                         
## tsk_P_gt_VC:stmntnstyl                                              
## tsk_P_gt_VC:stmntnstym  0.500                                       
## stmntnstyl:_V__C       -0.678                 -0.339                
## stmntnstym:_V__C       -0.339                 -0.678                
##                        stmntnstyl:_V__C
## tsk_P_gt_VC                            
## stmntnstylw                            
## stmntnstymd                            
## task_V_gt_C                            
## tsk_P_gt_VC:stmntnstyl                 
## tsk_P_gt_VC:stmntnstym                 
## stmntnstyl:_V__C                       
## stmntnstym:_V__C        0.500
```

#### Linear model eta-squared {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Parameter </th>
   <th style="text-align:right;"> Eta2_partial </th>
   <th style="text-align:right;"> CI </th>
   <th style="text-align:right;"> CI_low </th>
   <th style="text-align:right;"> CI_high </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> task_P_gt_VC </td>
   <td style="text-align:right;"> 0.1209155 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.1140771 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stimintensity </td>
   <td style="text-align:right;"> 0.0003598 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000208 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> task_V_gt_C </td>
   <td style="text-align:right;"> 0.0750113 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0693075 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> task_P_gt_VC:stimintensity </td>
   <td style="text-align:right;"> 0.0038688 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0025142 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stimintensity:task_V_gt_C </td>
   <td style="text-align:right;"> 0.0018916 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0009720 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

#### Linear model Cohen's d: NPS stimulus_intensity d = 1.16, cue d = 0.45 {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> t </th>
   <th style="text-align:right;"> df </th>
   <th style="text-align:right;"> d </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> task_P_gt_VC </td>
   <td style="text-align:right;"> 36.198673 </td>
   <td style="text-align:right;"> 19945.70 </td>
   <td style="text-align:right;"> 0.5126229 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stimintensitylow </td>
   <td style="text-align:right;"> 2.668379 </td>
   <td style="text-align:right;"> 19921.26 </td>
   <td style="text-align:right;"> 0.0378111 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stimintensitymed </td>
   <td style="text-align:right;"> 1.527524 </td>
   <td style="text-align:right;"> 19921.26 </td>
   <td style="text-align:right;"> 0.0216451 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> task_V_gt_C </td>
   <td style="text-align:right;"> -27.330963 </td>
   <td style="text-align:right;"> 19933.46 </td>
   <td style="text-align:right;"> -0.3871627 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> task_P_gt_VC:stimintensitylow </td>
   <td style="text-align:right;"> -8.748880 </td>
   <td style="text-align:right;"> 19921.27 </td>
   <td style="text-align:right;"> -0.1239721 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> task_P_gt_VC:stimintensitymed </td>
   <td style="text-align:right;"> -3.587019 </td>
   <td style="text-align:right;"> 19921.32 </td>
   <td style="text-align:right;"> -0.0508282 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stimintensitylow:task_V_gt_C </td>
   <td style="text-align:right;"> 6.111455 </td>
   <td style="text-align:right;"> 19921.27 </td>
   <td style="text-align:right;"> 0.0865996 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> stimintensitymed:task_V_gt_C </td>
   <td style="text-align:right;"> 2.504736 </td>
   <td style="text-align:right;"> 19921.29 </td>
   <td style="text-align:right;"> 0.0354922 </td>
  </tr>
</tbody>
</table>






#### Contrast weight table {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 15px; ">
<caption style="font-size: initial !important;">(\#tab:unnamed-chunk-12)Contrast weights</caption>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> pain </th>
   <th style="text-align:right;"> vicarious </th>
   <th style="text-align:right;"> cognitive </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> task_V_gt_C </td>
   <td style="text-align:right;"> 0.00 </td>
   <td style="text-align:right;"> 0.50 </td>
   <td style="text-align:right;"> -0.50 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> task_P_gt_VC </td>
   <td style="text-align:right;"> 0.66 </td>
   <td style="text-align:right;"> -0.34 </td>
   <td style="text-align:right;"> -0.34 </td>
  </tr>
</tbody>
</table>

## 2. NPS \~ paintask: 2 cue x 3 stimulus_intensity

### Q. Within pain task, Does stimulus intenisty level and cue level significantly predict NPS dotproducts? {.unlisted .unnumbered}


```
## # A tibble: 4,012 × 25
##    sub      ses    run   runtype trial cuetype stimintensity     X event  NPSpos
##    <chr>    <chr>  <chr> <chr>   <chr> <chr>   <chr>         <int> <chr>   <dbl>
##  1 sub-0006 ses-01 run-… runtyp… tria… cuetyp… med             864 even…  19.3  
##  2 sub-0006 ses-01 run-… runtyp… tria… cuetyp… low             865 even…   4.34 
##  3 sub-0006 ses-01 run-… runtyp… tria… cuetyp… high            866 even…   9.60 
##  4 sub-0006 ses-01 run-… runtyp… tria… cuetyp… low             867 even…  10.1  
##  5 sub-0006 ses-01 run-… runtyp… tria… cuetyp… med             868 even…  13.2  
##  6 sub-0006 ses-01 run-… runtyp… tria… cuetyp… high            869 even…  -0.847
##  7 sub-0006 ses-01 run-… runtyp… tria… cuetyp… low             870 even…   8.65 
##  8 sub-0006 ses-01 run-… runtyp… tria… cuetyp… high            871 even…   7.51 
##  9 sub-0006 ses-01 run-… runtyp… tria… cuetyp… high            872 even… -11.1  
## 10 sub-0006 ses-01 run-… runtyp… tria… cuetyp… med             873 even…   0.602
## # ℹ 4,002 more rows
## # ℹ 15 more variables: STIM <fct>, STIM_linear <dbl>, STIM_quadratic <dbl>,
## #   CUE_high_gt_low <dbl>, stim_ordered <fct>, cue_name <chr>,
## #   cue_ordered <fct>, task <fct>, task_V_gt_C <dbl>, task_P_gt_VC <dbl>,
## #   event02_expect_angle <dbl>, event04_actual_angle <dbl>, stim <dbl>,
## #   EXPECT <dbl>, NPS_gmc <dbl>
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-13-1.png" width="672" />

### Lineplots with only low cue {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-14-1.png" width="672" />

### Lineplots {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-15-1.png" width="672" />



### Lineplots {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-16-1.png" width="672" />

### Linear model results (NPS \~ paintask: 2 cue x 3 stimulus_intensity)


```r
model.npscuestim <- lmer(NPS_gmc ~ 
                          CUE_high_gt_low*STIM_linear +CUE_high_gt_low * STIM_quadratic + 
                          (1|sub), data = data_screen
                    )
sjPlot::tab_model(model.npscuestim,
                  title = "Multilevel-modeling: \nlmer(NPSpos ~ CUE * STIM + (CUE + STIM | sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(NPSpos ~ CUE * STIM + (CUE + STIM | sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">NPS_gmc</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.24</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.81&nbsp;&ndash;&nbsp;1.30</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.648</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.91</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.41&nbsp;&ndash;&nbsp;-0.42</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.98</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.37&nbsp;&ndash;&nbsp;2.58</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.21</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.32&nbsp;&ndash;&nbsp;0.74</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.445</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.53</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.74&nbsp;&ndash;&nbsp;0.68</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.388</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.98</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.04&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.070</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">63.46</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">24.33</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.28</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">92</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">4012</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.011 / 0.285</td>
</tr>

</table>

```         
lmer(NPSpos ~ 
                          CUE_high_gt_low*STIM_linear +CUE_high_gt_low * STIM_quadratic +
                          (CUE_high_gt_low+STIM|sub), data = data_screen
                    )
```


```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: 
## NPS_gmc ~ CUE_high_gt_low * STIM_linear + CUE_high_gt_low * STIM_quadratic +  
##     (1 | sub)
##    Data: data_screen
## 
## REML criterion at convergence: 28283.4
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.3302 -0.5055 -0.0131  0.5129  6.5291 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 24.33    4.932   
##  Residual             63.46    7.966   
## Number of obs: 4012, groups:  sub, 92
## 
## Fixed effects:
##                                 Estimate Std. Error        df t value Pr(>|t|)
## (Intercept)                       0.2448     0.5360   88.9536   0.457 0.649030
## CUE_high_gt_low                  -0.9123     0.2518 3915.3529  -3.623 0.000295
## STIM_linear                       1.9782     0.3082 3915.9937   6.419 1.54e-10
## STIM_quadratic                    0.2063     0.2700 3916.3036   0.764 0.444921
## CUE_high_gt_low:STIM_linear      -0.5319     0.6163 3916.7743  -0.863 0.388159
## CUE_high_gt_low:STIM_quadratic   -0.9786     0.5398 3915.0600  -1.813 0.069934
##                                   
## (Intercept)                       
## CUE_high_gt_low                ***
## STIM_linear                    ***
## STIM_quadratic                    
## CUE_high_gt_low:STIM_linear       
## CUE_high_gt_low:STIM_quadratic .  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                      (Intr) CUE_h__ STIM_l STIM_q CUE_hgh_gt_lw:STIM_l
## CUE_hgh_gt_           0.000                                           
## STIM_linear           0.004  0.008                                    
## STIM_qudrtc           0.000  0.007  -0.006                            
## CUE_hgh_gt_lw:STIM_l  0.005  0.008  -0.004 -0.006                     
## CUE_hgh_gt_lw:STIM_q  0.002  0.002  -0.006  0.006 -0.006
```

#### Linear model eta-squared {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Parameter </th>
   <th style="text-align:right;"> Eta2_partial </th>
   <th style="text-align:right;"> CI </th>
   <th style="text-align:right;"> CI_low </th>
   <th style="text-align:right;"> CI_high </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low </td>
   <td style="text-align:right;"> 0.0033415 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0009969 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear </td>
   <td style="text-align:right;"> 0.0104125 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0057754 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic </td>
   <td style="text-align:right;"> 0.0001490 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear </td>
   <td style="text-align:right;"> 0.0001901 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic </td>
   <td style="text-align:right;"> 0.0008387 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

#### Linear model Cohen's d: NPS stimulus_intensity d = 1.16, cue d = 0.45 {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> t </th>
   <th style="text-align:right;"> df </th>
   <th style="text-align:right;"> d </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low </td>
   <td style="text-align:right;"> -3.6231472 </td>
   <td style="text-align:right;"> 3915.353 </td>
   <td style="text-align:right;"> -0.1158059 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear </td>
   <td style="text-align:right;"> 6.4190480 </td>
   <td style="text-align:right;"> 3915.994 </td>
   <td style="text-align:right;"> 0.2051538 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic </td>
   <td style="text-align:right;"> 0.7639874 </td>
   <td style="text-align:right;"> 3916.304 </td>
   <td style="text-align:right;"> 0.0244162 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear </td>
   <td style="text-align:right;"> -0.8630572 </td>
   <td style="text-align:right;"> 3916.774 </td>
   <td style="text-align:right;"> -0.0275807 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic </td>
   <td style="text-align:right;"> -1.8128314 </td>
   <td style="text-align:right;"> 3915.060 </td>
   <td style="text-align:right;"> -0.0579453 </td>
  </tr>
</tbody>
</table>

## 3. NPS \~ SES \* CUE \* STIM

### Q. Is the cue effect on NPS different across sessions? {.unlisted .unnumbered}

> Quick answer: Yes, the cue effect in session 1 (for high intensity group) is significantly different; whereas this different becomes non significant in session 4. To unpack, a participant was informed to experience a low stimulus intensity, when in fact they were delivered a high intensity stimulus. This violation presumably leads to a higher NPS response, given that they were delivered a much painful stimulus than expected. The fact that the cue effect is almost non significant during the last session indicates that the cue effects are not just an anchoring effect.


```r
# code session
# contrast code 1 linear
combined_psig$SES_linear[combined_psig$ses == "ses-01"] <- -0.5
combined_psig$SES_linear[combined_psig$ses == "ses-03"] <- 0
combined_psig$SES_linear[combined_psig$ses == "ses-04"] <- 0.5

# contrast code 2 quadratic
combined_psig$SES_quadratic[combined_psig$ses == "ses-01"] <- -0.33
combined_psig$SES_quadratic[combined_psig$ses == "ses-03"] <- 0.66
combined_psig$SES_quadratic[combined_psig$ses == "ses-04"] <- -0.33

model.npsses <- lmer(NPSpos ~ 
                          CUE_high_gt_low*STIM_linear*SES_linear + 
                          CUE_high_gt_low*STIM_quadratic*SES_linear + 
                          CUE_high_gt_low*STIM_linear*SES_quadratic + 
                          CUE_high_gt_low*STIM_quadratic*SES_quadratic +
                          (1|sub), data = combined_psig
                    ) 
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.npsses,
                  title = "Multilevel-modeling: \nlmer(NPSpos ~ CUE * STIM * SES + (1| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(NPSpos ~ CUE * STIM * SES + (1| sub), data = pvc)</caption>
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
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">6.12</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">5.06&nbsp;&ndash;&nbsp;7.18</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.90</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.39&nbsp;&ndash;&nbsp;-0.41</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.99</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.39&nbsp;&ndash;&nbsp;2.60</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.83</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.49&nbsp;&ndash;&nbsp;-0.18</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.013</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.18</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.35&nbsp;&ndash;&nbsp;0.71</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.496</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.95</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.53&nbsp;&ndash;&nbsp;-0.38</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.50</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.71&nbsp;&ndash;&nbsp;0.71</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.421</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × SES<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.71</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.48&nbsp;&ndash;&nbsp;1.90</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.242</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.51</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.96&nbsp;&ndash;&nbsp;0.94</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.488</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.98</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.04&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.070</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">SES linear × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.44</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.72&nbsp;&ndash;&nbsp;0.84</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.499</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.17&nbsp;&ndash;&nbsp;0.98</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.861</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.56</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.88&nbsp;&ndash;&nbsp;0.76</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.405</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.23&nbsp;&ndash;&nbsp;1.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.894</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.93</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.97&nbsp;&ndash;&nbsp;4.83</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.193</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × SES<br>linear) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.22</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.34&nbsp;&ndash;&nbsp;2.78</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.864</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.43</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;3.07&nbsp;&ndash;&nbsp;2.22</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.752</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>quadratic) × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.79</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;3.08&nbsp;&ndash;&nbsp;1.51</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.502</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">63.37</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">24.70</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.28</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">92</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">4021</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.015 / 0.291</td>
</tr>

</table>

#### eta squared {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Parameter </th>
   <th style="text-align:right;"> Eta2_partial </th>
   <th style="text-align:right;"> CI </th>
   <th style="text-align:right;"> CI_low </th>
   <th style="text-align:right;"> CI_high </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low </td>
   <td style="text-align:right;"> 0.0032497 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0009463 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear </td>
   <td style="text-align:right;"> 0.0105810 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0059003 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SES_linear </td>
   <td style="text-align:right;"> 0.0015519 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0001782 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic </td>
   <td style="text-align:right;"> 0.0001185 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SES_quadratic </td>
   <td style="text-align:right;"> 0.0026857 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0006659 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear </td>
   <td style="text-align:right;"> 0.0001658 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:SES_linear </td>
   <td style="text-align:right;"> 0.0003505 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear:SES_linear </td>
   <td style="text-align:right;"> 0.0001229 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic </td>
   <td style="text-align:right;"> 0.0008408 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SES_linear:STIM_quadratic </td>
   <td style="text-align:right;"> 0.0001167 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:SES_quadratic </td>
   <td style="text-align:right;"> 0.0000079 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear:SES_quadratic </td>
   <td style="text-align:right;"> 0.0001772 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic:SES_quadratic </td>
   <td style="text-align:right;"> 0.0000045 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear:SES_linear </td>
   <td style="text-align:right;"> 0.0004337 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:SES_linear:STIM_quadratic </td>
   <td style="text-align:right;"> 0.0000075 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear:SES_quadratic </td>
   <td style="text-align:right;"> 0.0000256 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic:SES_quadratic </td>
   <td style="text-align:right;"> 0.0001152 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

#### Cohen's d {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> t </th>
   <th style="text-align:right;"> df </th>
   <th style="text-align:right;"> d </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low </td>
   <td style="text-align:right;"> -3.5713993 </td>
   <td style="text-align:right;"> 3912.241 </td>
   <td style="text-align:right;"> -0.1141972 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear </td>
   <td style="text-align:right;"> 6.4688379 </td>
   <td style="text-align:right;"> 3912.951 </td>
   <td style="text-align:right;"> 0.2068255 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SES_linear </td>
   <td style="text-align:right;"> -2.4943822 </td>
   <td style="text-align:right;"> 4002.990 </td>
   <td style="text-align:right;"> -0.0788498 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic </td>
   <td style="text-align:right;"> 0.6809850 </td>
   <td style="text-align:right;"> 3913.214 </td>
   <td style="text-align:right;"> 0.0217721 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SES_quadratic </td>
   <td style="text-align:right;"> -3.2756436 </td>
   <td style="text-align:right;"> 3984.443 </td>
   <td style="text-align:right;"> -0.1037870 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear </td>
   <td style="text-align:right;"> -0.8055133 </td>
   <td style="text-align:right;"> 3913.707 </td>
   <td style="text-align:right;"> -0.0257519 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:SES_linear </td>
   <td style="text-align:right;"> 1.1712953 </td>
   <td style="text-align:right;"> 3913.031 </td>
   <td style="text-align:right;"> 0.0374490 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear:SES_linear </td>
   <td style="text-align:right;"> -0.6934780 </td>
   <td style="text-align:right;"> 3912.313 </td>
   <td style="text-align:right;"> -0.0221741 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic </td>
   <td style="text-align:right;"> -1.8143621 </td>
   <td style="text-align:right;"> 3912.042 </td>
   <td style="text-align:right;"> -0.0580166 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SES_linear:STIM_quadratic </td>
   <td style="text-align:right;"> -0.6758733 </td>
   <td style="text-align:right;"> 3913.269 </td>
   <td style="text-align:right;"> -0.0216085 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:SES_quadratic </td>
   <td style="text-align:right;"> -0.1756151 </td>
   <td style="text-align:right;"> 3914.088 </td>
   <td style="text-align:right;"> -0.0056141 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear:SES_quadratic </td>
   <td style="text-align:right;"> -0.8328416 </td>
   <td style="text-align:right;"> 3913.550 </td>
   <td style="text-align:right;"> -0.0266261 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic:SES_quadratic </td>
   <td style="text-align:right;"> -0.1328290 </td>
   <td style="text-align:right;"> 3913.077 </td>
   <td style="text-align:right;"> -0.0042468 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear:SES_linear </td>
   <td style="text-align:right;"> 1.3032873 </td>
   <td style="text-align:right;"> 3914.497 </td>
   <td style="text-align:right;"> 0.0416612 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:SES_linear:STIM_quadratic </td>
   <td style="text-align:right;"> 0.1711939 </td>
   <td style="text-align:right;"> 3913.094 </td>
   <td style="text-align:right;"> 0.0054734 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear:SES_quadratic </td>
   <td style="text-align:right;"> -0.3162682 </td>
   <td style="text-align:right;"> 3913.337 </td>
   <td style="text-align:right;"> -0.0101114 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic:SES_quadratic </td>
   <td style="text-align:right;"> -0.6712826 </td>
   <td style="text-align:right;"> 3912.085 </td>
   <td style="text-align:right;"> -0.0214650 </td>
  </tr>
</tbody>
</table>

#### Session wise plots {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-24-1.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-24-2.png" width="672" /><img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-24-3.png" width="672" />

#### session wise line plots {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-25-1.png" width="672" />

------------------------------------------------------------------------

## 4. [INCORRECT] no cmc NPS \~ CUE \* STIM \* EXPECT {.unlisted .unnumbered}

-   2 cue \* 3 stimulus_intensity \* expectation_rating



#### eta squared {.unlisted .unnumbered}



#### Cohen's d {.unlisted .unnumbered}



------------------------------------------------------------------------

## 6. OUTCOME \~ NPS

### Q. Do higher NPS values indicate higher outcome ratings? (Pain task only) {.unlisted .unnumbered}

> TODO: update. Yes, Higher NPS values are associated with higher outcome ratings. The linear relationship between NPS value and outcome ratings are stronger for conditions where cue level is congruent with stimulus intensity levels. In other words, NPS-outcome rating relationship is stringent in the low cue-low intensity group, as is the case for high cue-ghigh intensity group.



### Linear model (without CMC subjectwise mean) {.unlisted .unnumbered}






```r
# organize variable names
# NPS_demean vs. NPSpos
model.npsoutcome <- lmer(OUTCOME_gmc ~ 
                           CUE_high_gt_low*STIM_linear*NPS_demean + 
                           CUE_high_gt_low*STIM_quadratic*NPS_demean + 
                           NPS_cmc + (1|sub), data = demean_dropna)
sjPlot::tab_model(model.npsoutcome,
                  title = "Multilevel-modeling: \nlmer(OUTCOME_gmc ~ CUE * STIM * NPSpos_demean + NPS_cmc + (1| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(OUTCOME_gmc ~ CUE * STIM * NPSpos_demean + NPS_cmc + (1| sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">OUTCOME_gmc</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.15</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;5.51&nbsp;&ndash;&nbsp;5.80</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.960</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">8.69</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">7.38&nbsp;&ndash;&nbsp;10.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">30.40</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">28.80&nbsp;&ndash;&nbsp;32.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">NPS demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.17</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.08&nbsp;&ndash;&nbsp;0.26</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.81</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.60&nbsp;&ndash;&nbsp;2.21</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.259</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">NPS cmc</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.81</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.57&nbsp;&ndash;&nbsp;1.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;5.27&nbsp;&ndash;&nbsp;1.16</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.210</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × NPS<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.19&nbsp;&ndash;&nbsp;0.17</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.917</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × NPS demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.34</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.56&nbsp;&ndash;&nbsp;-0.12</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.003</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.40</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;7.20&nbsp;&ndash;&nbsp;-1.59</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.002</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">NPS demean × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.22&nbsp;&ndash;&nbsp;0.16</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.732</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × NPS demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.34&nbsp;&ndash;&nbsp;0.54</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.647</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × NPS<br>demean) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.31</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.70&nbsp;&ndash;&nbsp;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.107</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">440.83</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">749.12</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.63</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">92</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">4021</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.143 / 0.682</td>
</tr>

</table>

### 6-0. No transformation {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-32-1.png" width="672" />

### 6-1. outcome_rating \* cue {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-33-1.png" width="672" />

### 6-2. outcome_rating \* stimulus_intensity \* cue {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-34-1.png" width="672" />

### 6-3. OUTCOMEgmc \~ NPScmc \* cue {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-35-1.png" width="672" />

### 6-4. OUTCOMEgmc \~ NPScmc \* cue \* stim

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-36-1.png" width="672" />

### 6-5. OUTCOMEgmc \~ NPSdemean {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 63 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 63 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-37-1.png" width="672" />

### facet wrap {.unlisted .unnumbered}

> same plot as 6-5, but adding subjectwise slopes


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 3729 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-38-1.png" width="672" />

### 6-6. OUTCOMEgmc \~ NPSdemean \* cue \* stim {.unlisted .unnumbered}


```
## Warning: Removed 1 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-39-1.png" width="672" />

------------------------------------------------------------------------

## 7. NPS \~ expectation_rating

### Q. What is the relationship betweeen expectation ratings & NPS? (Pain task only) {.unlisted .unnumbered}

Do we see a linear effect between expectation rating and NPS dot products? Also, does this effect differ as a function of cue and stimulus intensity ratings, as is the case for behavioral ratings?

> Quick answer: Yes, expectation ratings predict NPS dotproducts; Also, there tends to be a different relationship depending on cues, just by looking at the figures, although this needs to be tested statistically.

### 7. linear model {.unlisted .unnumbered}



GEORGE SUGGESTION


```r
model.npsexpectdemean <- lmer(NPS_gmc ~ 
                          CUE_high_gt_low*STIM_linear*EXPECT_demean +
                          CUE_high_gt_low*STIM_quadratic*EXPECT_demean +
                          EXPECT_cmc +
                          (1 |sub), data = demean_dropna, REML = FALSE
                    ) 
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.npsexpectdemean,
                  title = "Multilevel-modeling: \nlmer(NPSpos ~ CUE * STIM * EXPECT_demean + (1| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(NPSpos ~ CUE * STIM * EXPECT_demean + (1| sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">NPS_gmc</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.44</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.61&nbsp;&ndash;&nbsp;1.48</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.414</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.37</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.01&nbsp;&ndash;&nbsp;0.26</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.248</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.78</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.00&nbsp;&ndash;&nbsp;2.56</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;-0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.007</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.74&nbsp;&ndash;&nbsp;0.62</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.859</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT cmc</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.04</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.01&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.023</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.42</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.97&nbsp;&ndash;&nbsp;1.13</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.596</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04&nbsp;&ndash;&nbsp;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.105</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.826</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.64</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.01&nbsp;&ndash;&nbsp;0.72</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.355</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04&nbsp;&ndash;&nbsp;0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.215</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.361</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02&nbsp;&ndash;&nbsp;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.270</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">63.12</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">22.91</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.27</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">92</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">3884</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.029 / 0.288</td>
</tr>

</table>

### 7-1. [correct] NPSgmc \~ EXPECTdemean \* cue {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-42-1.png" width="672" />


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 3593 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-43-1.png" width="672" />


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 3593 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-44-1.png" width="672" />


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 3593 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-45-1.png" width="672" />


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 91. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 1209 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-46-1.png" width="672" />

```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 1194 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-46-2.png" width="672" />


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 3593 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-47-1.png" width="672" />


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 3593 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-48-1.png" width="672" />


```
## Warning: The shape palette can deal with a maximum of 6 discrete values because
## more than 6 becomes difficult to discriminate; you have 92. Consider
## specifying shapes manually if you must have them.
```

```
## Warning: Removed 3593 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-49-1.png" width="672" />

### 7-2. [correct] NPSgmc \~ EXPECTdemean \* cue \* stim {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-50-1.png" width="672" />

### 7-3. [correct] NPSgmc \~ EXPECTcmc {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-51-1.png" width="672" />

### 7-4. [correct] NPSgmc \~ EXPECTcmc \* cue \* stim {.unlisted .unnumbered}

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-52-1.png" width="672" />

-   <https://stats.stackexchange.com/questions/365466/significance-of-slope-different-than-zero-in-triple-interaction-with-factors>
-   <https://stats.stackexchange.com/questions/586748/calculating-trends-with-emtrends-for-three-way-interaction-model-results-in-sa>
-   emtrends(model.npsexpectdemean, var = 'EXPECT_demean', lmer.df = "asymptotic")

### 7-5. ICC




```r
compute_icc(model.npsexpectdemean)
```

```
## [1] 0.2663305
```

> The ICC of the dependent variable is .30 and thus very close to the value that we wanted to simulate. It means that about 30% of the variance in this variable is explainable by interindividual differences (i.e., person-related characteristics). This also means that a larger part of the variance is potentially explainable by situational characteristics (e.g., by other variables measured on level 1).


```r
emtrends(model.npsexpectdemean, var = 'EXPECT_demean', lmer.df = "asymptotic") 
```

```
## 'emmGrid' object with variables:
##     CUE_high_gt_low = -0.5,  0.5
##     STIM_linear = -0.0021885
##     EXPECT_demean = 6.3298e-16
##     STIM_quadratic = -0.33,  0.66
##     EXPECT_cmc = 0.097767
```

### eta squared {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;"> Parameter </th>
   <th style="text-align:right;"> Eta2_partial </th>
   <th style="text-align:right;"> CI </th>
   <th style="text-align:right;"> CI_low </th>
   <th style="text-align:right;"> CI_high </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low </td>
   <td style="text-align:right;"> 0.0003516 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear </td>
   <td style="text-align:right;"> 0.0052927 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0021301 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EXPECT_demean </td>
   <td style="text-align:right;"> 0.0019357 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0002994 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic </td>
   <td style="text-align:right;"> 0.0000084 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EXPECT_cmc </td>
   <td style="text-align:right;"> 0.0546121 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0036937 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear </td>
   <td style="text-align:right;"> 0.0000741 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:EXPECT_demean </td>
   <td style="text-align:right;"> 0.0006798 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear:EXPECT_demean </td>
   <td style="text-align:right;"> 0.0000128 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic </td>
   <td style="text-align:right;"> 0.0002256 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EXPECT_demean:STIM_quadratic </td>
   <td style="text-align:right;"> 0.0004043 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear:EXPECT_demean </td>
   <td style="text-align:right;"> 0.0002195 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:EXPECT_demean:STIM_quadratic </td>
   <td style="text-align:right;"> 0.0003202 </td>
   <td style="text-align:right;"> 0.95 </td>
   <td style="text-align:right;"> 0.0000000 </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table>

### Cohen's d {.unlisted .unnumbered}

<table class="table table-striped" style="font-size: 12px; ">
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> t </th>
   <th style="text-align:right;"> df </th>
   <th style="text-align:right;"> d </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low </td>
   <td style="text-align:right;"> -1.1536979 </td>
   <td style="text-align:right;"> 3784.61048 </td>
   <td style="text-align:right;"> -0.0375069 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear </td>
   <td style="text-align:right;"> 4.4880971 </td>
   <td style="text-align:right;"> 3783.71780 </td>
   <td style="text-align:right;"> 0.1459261 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EXPECT_demean </td>
   <td style="text-align:right;"> -2.7085636 </td>
   <td style="text-align:right;"> 3782.51740 </td>
   <td style="text-align:right;"> -0.0880803 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_quadratic </td>
   <td style="text-align:right;"> -0.1780034 </td>
   <td style="text-align:right;"> 3785.19784 </td>
   <td style="text-align:right;"> -0.0057865 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EXPECT_cmc </td>
   <td style="text-align:right;"> 2.2486118 </td>
   <td style="text-align:right;"> 87.80331 </td>
   <td style="text-align:right;"> 0.4799423 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear </td>
   <td style="text-align:right;"> -0.5291940 </td>
   <td style="text-align:right;"> 3785.52889 </td>
   <td style="text-align:right;"> -0.0172021 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:EXPECT_demean </td>
   <td style="text-align:right;"> -1.6196163 </td>
   <td style="text-align:right;"> 3856.67115 </td>
   <td style="text-align:right;"> -0.0521598 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> STIM_linear:EXPECT_demean </td>
   <td style="text-align:right;"> -0.2205010 </td>
   <td style="text-align:right;"> 3788.04029 </td>
   <td style="text-align:right;"> -0.0071653 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_quadratic </td>
   <td style="text-align:right;"> -0.9240023 </td>
   <td style="text-align:right;"> 3784.81166 </td>
   <td style="text-align:right;"> -0.0300387 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> EXPECT_demean:STIM_quadratic </td>
   <td style="text-align:right;"> -1.2386371 </td>
   <td style="text-align:right;"> 3790.03610 </td>
   <td style="text-align:right;"> -0.0402395 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:STIM_linear:EXPECT_demean </td>
   <td style="text-align:right;"> 0.9104925 </td>
   <td style="text-align:right;"> 3785.35871 </td>
   <td style="text-align:right;"> 0.0295973 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> CUE_high_gt_low:EXPECT_demean:STIM_quadratic </td>
   <td style="text-align:right;"> 1.1013235 </td>
   <td style="text-align:right;"> 3787.42581 </td>
   <td style="text-align:right;"> 0.0357909 </td>
  </tr>
</tbody>
</table>

### 7-6 simple slopes when STIM == 'high', EXPECT_demean slope difference between high vs. low cue {.unlisted .unnumbered}


```r
interactions::sim_slopes(model=model.npsexpectdemean, pred=EXPECT_demean, modx=CUE_high_gt_low, mod2 =STIM_linear, mod2.values = 0.5, centered = 'all', data = demean_dropna)
```

```
## ███████████████████ While STIM_linear (2nd moderator) = 0.50 ███████████████████ 
## 
## JOHNSON-NEYMAN INTERVAL 
## 
## The Johnson-Neyman interval could not be found. Is the p value for your
## interaction term below the specified alpha?
## 
## SIMPLE SLOPES ANALYSIS 
## 
## Slope of EXPECT_demean when CUE_high_gt_low = -0.50 (-0.5): 
## 
##    Est.   S.E.   t val.      p
## ------- ------ -------- ------
##   -0.01   0.01    -1.07   0.28
## 
## Slope of EXPECT_demean when CUE_high_gt_low =  0.50 (0.5): 
## 
##    Est.   S.E.   t val.      p
## ------- ------ -------- ------
##   -0.02   0.01    -1.48   0.14
```

#### emtrneds {.unlisted .unnumbered}


```r
emt.t <- emtrends(model.npsexpectdemean, ~ STIM_linear | CUE_high_gt_low, 
         var = "EXPECT_demean", 
         # nuisance = c("EXPECT_cmc"),
         at = list(STIM_linear=c(0.5, 0, -0.5)),
         lmer.df = "asymp")
pairs(emt.t, simple = "each")
```

```
## $`simple contrasts for STIM_linear`
## CUE_high_gt_low = -0.5:
##  contrast                           estimate      SE  df z.ratio p.value
##  STIM_linear0.5 - STIM_linear0      -0.00792 0.00943 Inf  -0.840  0.6783
##  STIM_linear0.5 - (STIM_linear-0.5) -0.01584 0.01887 Inf  -0.840  0.6783
##  STIM_linear0 - (STIM_linear-0.5)   -0.00792 0.00943 Inf  -0.840  0.6783
## 
## CUE_high_gt_low =  0.5:
##  contrast                           estimate      SE  df z.ratio p.value
##  STIM_linear0.5 - STIM_linear0       0.00484 0.01031 Inf   0.469  0.8857
##  STIM_linear0.5 - (STIM_linear-0.5)  0.00968 0.02063 Inf   0.469  0.8857
##  STIM_linear0 - (STIM_linear-0.5)    0.00484 0.01031 Inf   0.469  0.8857
## 
## Results are averaged over the levels of: STIM_quadratic 
## Degrees-of-freedom method: asymptotic 
## P value adjustment: tukey method for comparing a family of 3 estimates 
## 
## $`simple contrasts for CUE_high_gt_low`
## STIM_linear = -0.5:
##  contrast                                   estimate     SE  df z.ratio p.value
##  (CUE_high_gt_low-0.5) - CUE_high_gt_low0.5  0.02858 0.0190 Inf   1.503  0.1330
## 
## STIM_linear =  0.0:
##  contrast                                   estimate     SE  df z.ratio p.value
##  (CUE_high_gt_low-0.5) - CUE_high_gt_low0.5  0.01582 0.0131 Inf   1.211  0.2261
## 
## STIM_linear =  0.5:
##  contrast                                   estimate     SE  df z.ratio p.value
##  (CUE_high_gt_low-0.5) - CUE_high_gt_low0.5  0.00306 0.0192 Inf   0.159  0.8738
## 
## Results are averaged over the levels of: STIM_quadratic 
## Degrees-of-freedom method: asymptotic
```

```r
# contrast(emt.t, "revpairwise")
```



## 8. NPS and session effects



#### 8-1. [correct] NPS \~ EXPECT_demean \* CUE \* STIM + CMC (Session as covariate) {.unlisted .unnumbered}


```r
model.npsexpectdemean.sescontrol <- lmer(NPS_gmc ~ 
                          CUE_high_gt_low*STIM_linear*EXPECT_demean + 
                          CUE_high_gt_low*STIM_quadratic*EXPECT_demean + 
                          # CUE_high_gt_low*STIM_linear*EXPECT_demean + 
                          # CUE_high_gt_low*STIM_quadratic*EXPECT_demean +
                          EXPECT_cmc +
                          ses + 
                          (CUE_high_gt_low|sub), data = demean_dropna
                    ) 
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.npsexpectdemean.sescontrol,
                  title = "Multilevel-modeling: \nlmer(NPSpos ~ CUE * STIM * EXPECT_demean + SES + (CUE + EXPECT| sub), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(NPSpos ~ CUE * STIM * EXPECT_demean + SES + (CUE + EXPECT| sub), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">NPS_gmc</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;2.23</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.056</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.33</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.01&nbsp;&ndash;&nbsp;0.35</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.338</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.79</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.01&nbsp;&ndash;&nbsp;2.56</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;-0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.004</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.74&nbsp;&ndash;&nbsp;0.62</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.854</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT cmc</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.01&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.022</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">sesses&#45;03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.42</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.10&nbsp;&ndash;&nbsp;-0.74</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">sesses&#45;04</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.78</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.44&nbsp;&ndash;&nbsp;-0.11</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.023</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.45</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.00&nbsp;&ndash;&nbsp;1.10</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.567</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05&nbsp;&ndash;&nbsp;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.060</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.854</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.61</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.97&nbsp;&ndash;&nbsp;0.75</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.381</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04&nbsp;&ndash;&nbsp;0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.189</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.385</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.237</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">62.74</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">24.11</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>11</sub> <sub>sub.CUE_high_gt_low</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">1.13</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&rho;<sub>01</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">-0.48</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.28</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">92</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">3884</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.034 / 0.304</td>
</tr>

</table>

#### 8-2. [correct] NPS \~ EXPECT_demean \* CUE \* STIM \* SES + CMC (Session as interaction) {.unlisted .unnumbered}


```r
model.npsexpectdemean.ses <- lmer(NPS_gmc ~ 
                          CUE_high_gt_low*STIM_linear*EXPECT_demean*SES_linear + 
                          CUE_high_gt_low*STIM_quadratic*EXPECT_demean*SES_linear + 
                          CUE_high_gt_low*STIM_linear*EXPECT_demean*SES_quadratic + 
                          CUE_high_gt_low*STIM_quadratic*EXPECT_demean*SES_quadratic +
                          EXPECT_cmc +
                          (CUE_high_gt_low|sub) + (1|ses), data = demean_dropna
                    ) 
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## unable to evaluate scaled gradient
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## Model failed to converge: degenerate Hessian with 1 negative eigenvalues
```

```r
# CUE_high_gt_low+STIM+EXPECT_demean
sjPlot::tab_model(model.npsexpectdemean.ses,
                  title = "Multilevel-modeling: \nlmer(NPS_gmc ~ CUE * STIM * EXPECT_demean * SES + EXPECT_cmc + (CUE| sub) + (1|ses), data = pvc)",
                  CSS = list(css.table = '+font-size: 12;'))
```

<table style="border-collapse:collapse; border:none;font-size: 12;">
<caption style="font-weight: bold; text-align:left;">Multilevel-modeling: 
lmer(NPS_gmc ~ CUE * STIM * EXPECT_demean * SES + EXPECT_cmc + (CUE| sub) + (1|ses), data = pvc)</caption>
<tr>
<th style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black; text-align:left; ">&nbsp;</th>
<th colspan="3" style="border-top: double; text-align:center; font-style:italic; font-weight:normal; padding:0.2cm; border-bottom:1px solid black;">NPS_gmc</th>
</tr>
<tr>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; text-align:left; ">Predictors</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">Estimates</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">CI</td>
<td style=" text-align:center; border-bottom:1px solid; font-style:italic; font-weight:normal; border-bottom:1px solid black; ">p</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(Intercept)</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.40</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;11.88&nbsp;&ndash;&nbsp;12.67</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.949</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.41</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.10&nbsp;&ndash;&nbsp;0.27</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.233</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.79</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.01&nbsp;&ndash;&nbsp;2.57</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>&lt;0.001</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02&nbsp;&ndash;&nbsp;-0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.027</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.38</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;30.35&nbsp;&ndash;&nbsp;29.59</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.980</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.72&nbsp;&ndash;&nbsp;0.66</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.930</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;27.23&nbsp;&ndash;&nbsp;25.20</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.939</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT cmc</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.04</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.01&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.023</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.55</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.12&nbsp;&ndash;&nbsp;1.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.490</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05&nbsp;&ndash;&nbsp;-0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  "><strong>0.030</strong></td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × EXPECT<br>demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.000</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × SES<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.36</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.95&nbsp;&ndash;&nbsp;1.23</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.659</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.89&nbsp;&ndash;&nbsp;1.94</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.979</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × SES<br>linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.00&nbsp;&ndash;&nbsp;0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.064</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.56</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.93&nbsp;&ndash;&nbsp;0.82</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.428</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04&nbsp;&ndash;&nbsp;0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.210</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">SES linear × STIM<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.70</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.36&nbsp;&ndash;&nbsp;0.95</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.403</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">CUE high gt low × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.78</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.21&nbsp;&ndash;&nbsp;0.65</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.283</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM linear × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.09</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.59&nbsp;&ndash;&nbsp;1.78</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.913</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">EXPECT demean × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.01&nbsp;&ndash;&nbsp;0.04</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.258</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">STIM quadratic × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.39</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.89&nbsp;&ndash;&nbsp;1.11</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.610</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × EXPECT demean</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.04&nbsp;&ndash;&nbsp;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.546</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">1.55</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;2.27&nbsp;&ndash;&nbsp;5.38</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.426</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.10&nbsp;&ndash;&nbsp;0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.116</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(STIM linear × EXPECT<br>demean) × SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.06&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.790</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.02&nbsp;&ndash;&nbsp;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.310</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × SES<br>linear) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.81</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.12&nbsp;&ndash;&nbsp;2.50</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.631</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(EXPECT demean × SES<br>linear) × STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.03</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.03&nbsp;&ndash;&nbsp;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.403</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear) × SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.89</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.25&nbsp;&ndash;&nbsp;2.47</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.603</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean) × SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05&nbsp;&ndash;&nbsp;0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.895</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(STIM linear × EXPECT<br>demean) × SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.00</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.06&nbsp;&ndash;&nbsp;0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.908</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>quadratic) × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;1.23</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;4.24&nbsp;&ndash;&nbsp;1.78</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.423</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(EXPECT demean × STIM<br>quadratic) × SES<br>quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.01</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05&nbsp;&ndash;&nbsp;0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.767</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear × EXPECT demean) ×<br>SES linear</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.20&nbsp;&ndash;&nbsp;0.07</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.361</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean × SES linear) ×<br>STIM quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.02</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.10&nbsp;&ndash;&nbsp;0.14</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.769</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × STIM<br>linear × EXPECT demean) ×<br>SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.08</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.20&nbsp;&ndash;&nbsp;0.05</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.215</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; ">(CUE high gt low × EXPECT<br>demean × STIM quadratic)<br>× SES quadratic</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.06</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">&#45;0.05&nbsp;&ndash;&nbsp;0.17</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:center;  ">0.270</td>
</tr>
<tr>
<td colspan="4" style="font-weight:bold; text-align:left; padding-top:.8em;">Random Effects</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&sigma;<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">62.80</td>
</tr>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">24.07</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>00</sub> <sub>ses</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">116.73</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&tau;<sub>11</sub> <sub>sub.CUE_high_gt_low</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">1.05</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">&rho;<sub>01</sub> <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">-0.48</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">ICC</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.69</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>sub</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">92</td>

<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">N <sub>ses</sub></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">3</td>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm; border-top:1px solid;">Observations</td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center; border-top:1px solid;" colspan="3">3884</td>
</tr>
<tr>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; text-align:left; padding-top:0.1cm; padding-bottom:0.1cm;">Marginal R<sup>2</sup> / Conditional R<sup>2</sup></td>
<td style=" padding:0.2cm; text-align:left; vertical-align:top; padding-top:0.1cm; padding-bottom:0.1cm; text-align:center;" colspan="3">0.016 / 0.697</td>
</tr>

</table>

## 9. plotly 3 factors




```
## 
## Attaching package: 'plotly'
```

```
## The following objects are masked from 'package:plyr':
## 
##     arrange, mutate, rename, summarise
```

```
## The following object is masked from 'package:ggplot2':
## 
##     last_plot
```

```
## The following object is masked from 'package:reshape':
## 
##     rename
```

```
## The following object is masked from 'package:stats':
## 
##     filter
```

```
## The following object is masked from 'package:graphics':
## 
##     layout
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-b1cd17a830389f6bf645" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-b1cd17a830389f6bf645">{"x":{"visdat":{"4a8450e56ccd":["function () ","plotlyVisDat"],"4a8464a3039":["function () ","data"]},"cur_data":"4a8464a3039","attrs":{"4a8464a3039":{"x":{},"y":{},"z":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d","mode":"lines","color":{},"inherit":true}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"Cue"},"zaxis":{"title":"NPSpos"},"yaxis":{"title":"Expectation rating"}},"xaxis":{"type":"category","categoryorder":"array","categoryarray":["cuetype-high","cuetype-low"]},"hovermode":"closest","showlegend":false,"legend":{"yanchor":"top","y":0.5}},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":["cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high",null,"cuetype-high",null,"cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-high",null,"cuetype-low",null,"cuetype-high",null,"cuetype-high",null,"cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-low",null,"cuetype-high",null,"cuetype-low",null,"cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high",null,"cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low","cuetype-low",null,"cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high","cuetype-low",null,"cuetype-high",null,"cuetype-low",null,"cuetype-high",null,"cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low","cuetype-low",null,"cuetype-low","cuetype-low",null,"cuetype-high","cuetype-high","cuetype-low","cuetype-low",null,"cuetype-high",null,"cuetype-high"],"y":[34.07502607838525,44.695856966078239,23.27241573804875,11.426914579322144,16.315286279840585,30.906857641881786,50.030272751536685,70.546822882550387,36.326166802471178,50.888099345443166,38.311879737590175,52.513852748651161,5.4763803116992733,-21.505199764688825,48.99074382901027,57.363297074446265,14.830482578337616,17.776653648877016,7.5014778259565418,-5.1338215892169572,13.41956665056334,22.57312856573094,-19.965704126284216,-2.9012063211618155,-30.979220536518419,-5.2385121802856176,-32.261481688259927,-15.876708779135825,-77.183080287394375,-17.211050817647724,-69.210233758201923,-50.656600733432839,54.717337354146267,48.333805389941276,-7.6173355041876825,-16.429816792344585,null,21.887814246057147,-15.174719688596255,47.366938769959248,20.678061281879039,36.988645342118488,11.847355170797684,33.74398478686868,15.861805016873383,43.978319199156175,32.639384282971179,43.466350796158167,49.828101300844182,-72.044061825400931,12.751203049973256,-9.7226974740307384,35.129278824456279,10.733332747719317,13.244490412100618,-37.780669036797555,13.716324898786141,23.279011098342451,45.278460943615244,-24.851614298135917,-37.059243358546759,-7.2102862651001161,-7.9692244477669192,-55.908201652159022,-23.214750272843325,-39.759847789943123,16.777960313472974,-93.385979078774227,-75.778769449355536,-18.058480353919734,58.335216206697268,9.5877735925169176,12.208944799484613,null,4.6829351044220431,24.188763663298943,39.349511001625245,30.413184040836242,39.33804747129858,-0.57165380884661943,24.194245951353281,56.672752908255887,26.752016836079179,24.292199612070178,44.993542162907175,52.44565254073116,-1.6347018624397265,-5.3515475884617274,57.460681452613258,57.781927509707273,13.508956563841416,15.903962080713718,12.431439003019548,-14.293028658424056,26.101654844323946,22.799446274287945,-32.872850732963698,-32.872850732963698,-30.798477352109416,-28.907322650424014,-50.869042767697124,-72.069909048299564,-16.581327907293428,-49.419235683477424,-24.484335579230631,-88.346875353256436,47.847672183068269,45.991939635434264,0.93652457396671451,-5.184377347427386,null,47.765456520682704,-3.8266820511746928,58.142750648921805,-20.701053297009892,-28.64059154029551,-6.1745968984469926,-28.560301276549382,-9.6911180642458987,null,19.931461422135406,34.185903845639402,38.771401440339602,40.287619001662605,-26.10451689132622,-32.786629198919904,-8.242594023105994,-31.867435596581142,-17.869846448947996,null,39.783876251081011,28.934410129892811,1.7325143418220108,69.304580690928105,-34.166827506321681,-2.0494863019768914,-20.81093859352999,-20.360686333492392,-37.100964650650496,null,28.023521746895305,41.55832837811591,39.632625113147917,42.160592293195911,-13.326783842614629,1.7845557310265114,1.7357702221161126,15.083060962704213,15.438942062787866,40.051862566575167,22.469626964753267,28.577022643004469,2.5789995887334882,-54.258667257118596,1.9812965544501822,17.356451833489679,0.83732820124572527,22.106643059113324,6.5078283779369315,27.273129444226626,-0.46163462069212358,25.437418339076572,13.625453001622574,22.026886832844582,55.114387778585524,33.438496179328226,15.383466008127826,44.867574925712731,32.984816742099625,50.321896186602913,40.649129203065826,47.436432646981814,7.7662672847681051,22.598896550407503,-37.679165464907591,-39.058733776563585,-13.695706647959589,-11.592399827537186,-15.210519019248338,-13.520010980524059,-8.9068594012944882,-2.9477734550187904,-23.325853798457231,-30.177487635092202,-22.275707619391035,-52.948232440679888,-44.610272359895319,-24.606712169741613,31.072220181415879,-38.502581702030866,-23.182277080603669,-24.344849794209267,-1.9411228364699724,-66.735405478724715,-0.82120640101072695,-6.3155461153844215,5.3086820462876858,-10.245158605292374,-34.496538145160976,-35.794604205689978,-37.30744459822138,-37.521088565720582,-31.35965773294388,-52.574623479236791,-31.223643231583193,-42.885836918869991,null,39.859552638074909,66.653270177690899,16.679775057376709,46.217369834487904,4.5597850985989119,14.07167387097881,10.116586440240415,5.0731645084771095,13.856718544980865,33.425689690217467,47.040873320614566,-26.936640807642114,42.41595976057409,36.848500149624378,-25.827088758922514,17.852011477768727,19.357889536189134,27.856072301587432,27.398260046997635,-44.45452450424532,5.753127305405684,11.988221314446577,6.4953988597205807,26.42202406303312,27.880357350590231,25.247024691309718,37.683385523547329,68.387691382811227,-5.5730789259895772,33.248320542124716,23.594534453588224,0.031156095145007612,11.715422739951904,-32.262387488117689,-18.744151036361991,-41.350936036268692,-8.9740296319901915,-11.023055284757788,-9.1305512391826884,-15.666346477665059,-2.3611099715739883,-34.128229987639862,-17.379972333135633,-10.160081015367332,-57.286035593163845,-25.827088758922514,-32.409601821792016,-31.276623663958915,-39.629299337975866,-38.394230214018471,6.0015635976829316,-13.934490449531069,-86.542271229167426,1.3699743910239732,8.7725099067262846,9.2073823271655755,-38.901112766629858,-18.676253335461777,-3.6889756733147792,-37.336742231377684,-39.633072284643049,-42.921350255906923,-32.655065526571278,-47.047083327580623,-38.818415804482491,-45.363275031663072,null,36.793034112930904,5.9239760098506125,10.023023833397609,-4.37954682571349,-0.69078022405838979,18.643598893638615,8.7769987537285097,13.750413199475009,22.755787197935668,-0.31483201390883409,3.4446133990272685,-3.9677869734981321,40.525113138460078,22.741091908194583,4.769031652272183,14.406393245094286,-9.4821594804391722,33.527440136391533,35.405584578326526,34.439292039670534,27.532766837020574,0.6233456461573752,34.318620459181574,31.73626840734758,19.792588102907018,34.655507618514719,28.396045110157317,14.244195473451825,11.304789805719622,14.024625888466623,63.446649629452224,27.653880818387421,5.5911709752040082,13.155103261453704,-40.207110107088994,-46.552290746541189,-44.776859738571389,-34.251751867543092,-15.43832673468776,-9.1305512391826884,-2.044873910911889,-6.7924953800815882,-31.611303309334524,-34.59203925661464,1.2135359243828674,-20.341378371840033,-30.357548572069316,5.1867289070795906,-58.454474344257768,36.61917341747958,-36.018498590243567,-22.323563085660069,-21.012098870638368,-1.8316204920216705,-4.0026270373838173,0.90823722259797535,5.3942818258331755,-1.1653593358498142,-31.311470120653976,-40.037784644228637,-29.855683421520578,-26.213197046304675,-29.161091013844981,-40.150490726125497,-40.360679565937829,-24.590992770713179,-52.574623479236791,-47.276058409336855,-45.677195921485044,null,41.28290260994963,41.026424727780636,35.960488153898638,27.042506996456027,-7.0218748526031689,-1.067439502432066,-10.392097104090467,14.079544937913127,-52.719327656273563,-31.301680461203169,-44.788046355831071,-32.946640752417863,-35.917929983801073,1.0801459258664323,-4.2122835153080658,null,35.934084570738634,35.831152528175636,22.341163617063827,7.8895730324726401,3.8462180372713348,-2.5162051404326675,7.4838506418962325,-17.298949825980365,-23.476543130736765,-28.31689581489767,-38.110070986206566,-15.034658104284169,null,21.870747241655636,13.513252025342638,32.099755529015638,36.911206050932634,-16.892263654750067,3.7669153252821346,0.06052890912743436,11.390689499069637,-44.813567859494171,-29.827757535131866,-22.501704188395465,-20.381837181524965,-3.5673094415574695,0.56972932157773215,null,31.118466479770561,1.2316428377335455,16.014281403320552,25.761727016098561,-20.358261743961947,1.3936801003655432,-6.9188277272646559,null,-0.56602132292545093,18.941277396263544,16.470061903353553,-9.9410471529244546,-19.260733108000949,-42.088531024141254,1.5436612070805467,null,7.9719947216095477,8.7211650313445546,26.882139827950553,28.028807932092562,-74.498400291290949,-29.277317226981253,-77.683785868813345,-1.5938475683594504,null,16.465896886658811,9.1431934128028018,-7.8392503882107007,28.5588626122058,-21.130657800964599,-1.14649773050769,15.959695814990809,null,13.554793066204809,-9.008162945237487,26.37436842176281,23.897901420000807,-84.932216577699748,-15.747225593415592,-12.042432032798487,1.593681136063708,null,34.196443715687806,3.0565117739576095,19.739991717288802,6.2386734864270039,-30.201292203780795,-7.0062250546569942,-12.005389348764098,2.2793362119847131,null,16.096272128712883,null,-30.347140203385912,20.404128015163892,29.479531607872886,6.2539587529258824,null,41.924666290524897,23.513068872808887,33.765995427696879,47.527767414152891,-57.987622904459791,null,9.3142527825188779,50.254805830337887,-14.637801386375116,26.335003873875891,null,-44.328417362030194,-35.49026794070469,-50.586587169867876,43.364223706542319,-6.7819620618168699,-6.7819620618168699,-88.748391393194268,-12.705289091986074,-18.431204754167666,13.490441929326323,-18.875363473391275,null,-8.3919499670152788,15.887967015662326,13.490441929326323,8.6977711535733278,5.2998177400148307,27.26225496793333,23.717838082692325,-26.224054013649067,-64.258528829493116,null,-16.021968721492399,30.467732358457326,-6.0903634373803754,-13.735907591910376,20.204603028440332,-82.499511284715339,-2.616912608230777,-15.681890337021571,3.1716568198192334,-18.15130216353397,null,41.935699053165081,42.640119864545085,41.248593211997076,42.640119864545085,38.102107679195996,70.690950275969897,25.607588284031991,87.499149553667905,91.917812551049678,37.219286338090669,37.165660139470759,-30.749021144908909,-16.98759377780992,-21.836455634386908,-9.3367496303121058,-11.021097138090902,-44.72140885840335,17.000637395882094,-24.817256525673635,null,42.640119864545085,42.640119864545085,40.799924608152082,42.640119864545085,56.438069539222894,38.102107679195996,67.183628165444901,87.863089763894891,2.9899803384685697,-64.081681761792112,-18.768449289617919,-4.2405583736419032,-38.665939115021104,-28.603134694140405,-23.918886995066803,4.3932471402693949,-40.021047613336954,-12.671679097522933,null,31.193660771606091,42.640119864545085,42.640119864545085,32.095360989538079,32.739091926782095,50.318567872389892,66.156912169240897,29.540692028307092,28.611509071072064,-69.816819135397012,-121.87415397854511,-40.23486378655312,-33.492983305960919,-33.1260884771729,-42.899493411404485,-6.3683467631475068,-24.614467786251303,-10.376063102140236,null,-7.2750346968611055,-1.9040951184888044,-12.989485638314832,-9.8695230326697327,-25.243034875905643,-26.022022055535906,null,29.617971734382962,1.7926963851418947,11.724999417830794,-8.8073715191587354,-10.055286030139605,-31.424414039769534,null,16.071185528243063,17.749728939564491,4.5916741938399923,-14.521486877401035,-29.640889299270196,-30.330139730252714,null,23.302474000902819,15.540828172084517,-6.4407907348144846,-37.957730707409183,-35.887700054368082,null,48.967352361974918,16.642387722469515,-36.793342667285302,-35.887700054368082,-28.655675996110361,null,-0.1637877087924835,-1.2716200158636823,-24.090833877914683,-37.957730707409183,null,9.4141114823800152,9.981416886763995,54.184799578614303,9.2029042700136969,18.819626748584298,-12.015435217537483,-8.2705490682154839,-41.056473583402905,-15.846916834553106,-30.782135587627703,-19.466382107066504,null,10.350482826462816,47.460284747650192,57.383844479185299,44.12262718829119,24.317999710161303,-40.828067109772704,-37.336239166494607,-30.021527312411102,-23.804897177623005,null,12.413263988126516,13.704746399187115,35.071336271323901,20.3677844475623,29.340411062458699,11.716825718904396,-23.085518653653281,-10.953640004649483,-36.990500611755301,-44.101512778229534,-31.770612512846203,-39.0701756945856,null,-21.171642511888535,null,-8.3266054315336362,-3.6661007061553263,16.940236045681662,11.085042864711564,14.380490073397382,null,9.9510376540452619,-27.986589307623973,41.821785690554265,9.522138562111472,null,14.884747596886168,27.631281508596064,-8.2591931556715359,null,68.321623958130573,-15.344558993253123,23.704530607432673,-23.215766459796125,-4.1456483804773256,-12.943059090468424,null,58.323579266614573,26.321718087449682,8.0064949109443759,-4.1194970142112268,-16.525133777781924,null,69.914432981731579,40.431827914683282,-11.971723632529525,10.369251782173272,-17.222773208542925,-18.575714073572023,null,-1.6708304240760583,44.368670468091835,-49.793914541925162,-38.230131835813161,null,32.775918264329533,-52.315407470057558,-40.596830275930756,null,-10.226179188481957,32.352580906027342,-35.833354466639861,null,47.197450779361695,53.99569068262749,-6.1073654737068779,-35.900293738496956,29.159363614552198,null,42.918454177158836,21.991819324295086,21.48695201477269,-39.832208279323282,-21.63517053794201,null,32.055326465844196,13.402340543882794,-35.640415064132661,-42.7790717551459,null,2.3959300295061183,9.6144168603834785,19.077984033415078,18.330593166828677,41.555181776418273,-14.782256851093763,35.224893264729957,27.728474981614937,42.519104649067941,-10.829198461986053,39.670634584314456,-20.272952987350749,36.188314501063445,9.1589972927871202,-19.561565477613925,-35.078047486546417,-1.1102148002732264,-65.69504884207376,-13.776082688291851,25.465135048367955,21.546209404529947,-52.369027854630446,-27.383983180254248,-35.967950753871747,14.540668104830445,null,-0.17030798386608126,4.2885108427691279,14.227315655619378,32.171797690127782,33.621549001419673,-54.265526781033557,31.310525845552945,16.086066177017941,36.827115317984948,-1.394583359315746,41.419375384619457,8.9537228704330545,28.025459100367456,-12.629310341433069,6.4011101640791281,-29.844157520393026,-34.201477770749442,-28.291757236760425,-105.97142307315019,-46.246235238857253,-12.36303806356716,20.708922536082952,-46.841366494140146,-62.184955483121044,-9.5685537000060492,29.765609244564445,null,2.6697131649191306,1.9466977563561301,19.048159959323975,24.834765697177069,24.951096521543569,26.412611514003942,14.173317699369946,26.906758451007931,33.93003714721894,-31.809155079041851,48.321456108628439,40.956759693894455,40.956759693894455,-5.2484452255722687,-2.7055302258384728,-30.655288489171724,-32.054496059636662,-26.635855521112127,-20.56039237275435,-28.116343492019254,-5.7871163899180544,8.7242917562089417,-53.325289647664448,-14.592831052932155,3.2014001942629449,34.539688573441452,null,15.572253090797709,null,20.616465427052212,19.892051177549014,3.6203943863308439,-4.4039203052441565,-18.506693096735148,58.685055859485615,55.708819386324606,32.019053853170618,36.879361525753623,38.896505000172567,19.892051177549014,-7.6812603056071396,-2.0690918790681394,-1.6231257267691319,-70.367728926056088,-29.795545377256083,-27.494988606563282,-20.48399480816348,-73.007991668726916,null,-18.106536762117145,-25.088072386969145,1.8615369673708528,64.479151150599606,61.606620098458606,39.247115404942619,10.945483531802125,1.3619699454758631,-10.375770097767145,2.3586435931088658,-58.075049653497182,-5.2088278930526855,-43.928808156940782,-40.592737315196182,-72.551416890090593,-42.539544327113731,null,21.015462374512104,4.3512956643498626,-1.8463320538051562,1.1314742382448628,36.800058813764622,36.761008729918615,29.466053569932612,21.979647135376624,49.399820989692557,-4.0962501347551381,7.0310328035258465,3.3954702205798526,-50.945424941417684,-25.444054823435678,-28.195546408204585,-27.942182390613681,null,35.070818101484562,null,49.850152011873575,null,39.810281768344566,null,-29.591162847599598,-79.065150146070394,null,45.945789566016572,null,0.078266245071972662,null,13.002405023461293,null,14.628921691954105,null,-13.099636055400543,null,11.638595506279309,0.30625787206520627,null,-2.3795866671576924,null,2.1901629643247063,null,1.3442063798890089,null,-38.278285583822154,null,16.849936928630697,15.881095499972687,29.130282277150698,9.6531213948636889,-0.040052562992912044,-3.7375878446109425,-7.04469714540231,18.165165335775683,22.877478890306705,45.080319203499684,null,4.2556367406785611,-18.819808406383203,33.664320383880707,-7.9317867135933113,33.462721374682687,-15.886042918565643,-25.954330878141604,-6.7121132425183134,31.219291640477692,-6.1860649909303049,null,15.514041289264654,11.055723436487753,21.731090581676696,20.821234750416707,30.78613592396168,41.92400951725368,13.378740163732189,-5.7662198524355404,6.0051333900456996,35.408123283905681,37.166154694451691,9.1908968668666944,null,4.0485375915676869,22.076797450877073,53.933742036621972,-27.923166314610924,26.808216358520177,-8.3040724802448196,16.541292760027382,-20.64971477967692,23.371621046129782,46.0070807734742,39.3676102545802,-14.046637726041773,8.6845144878016214,6.3354938749801875,-19.711127103412213,-15.176006844268827,-32.826131064198925,-43.778388718166724,1.7314165364402783,-2.6864306838059235,-7.9693312878571234,-15.449041284306119,-9.2213772499894233,-77.313870874377002,-22.980422200457397,-19.420106163256875,null,12.695460852410186,18.441257951498081,19.93309225629087,22.12252953427727,24.19570925005727,3.2737909298455818,0.70294846317637649,12.961471543535175,11.812373504890282,30.559909897465204,31.654183231946206,0.94936398889292661,1.0606432131092873,-13.045576468166114,-30.183934195594325,-28.131326125534624,-2.4708371541712211,10.588951297279877,3.7879925054516761,6.2395285599777779,-7.8348519375624193,-3.6380757878746195,-79.908910647620104,-42.211258196652501,-22.870602022148674,-35.58681720290997,null,17.746418275125585,19.239284980770172,25.368390322404871,32.947182924523169,3.5826435035733724,-5.6192677523060226,-4.4041583643683211,0.85679540963457868,16.742604449919575,13.322099252748203,-8.874878900729172,21.083724426803528,-3.0537049314006168,-25.774351730795114,-30.733803978300923,-41.695907692226825,24.91841340809507,-18.530607483129224,-7.4644344396983229,4.2188499916115845,-3.5135500202604248,-15.616013192216123,-66.995809965692104,-51.019041342136902,-40.827659992713272,null,-5.0810722877387775,8.484579877292532,52.898148449588554,-0.57129284721494145,21.379453693266761,52.194810845704659,-21.581411313509975,9.6246439110789339,-21.059806159588341,13.034637690528157,-33.723463570191569,-29.987896275054641,null,2.6322008883769286,-0.62275443496187677,20.469210657166727,22.616691354557361,19.231868264968263,73.078984063071459,50.141137602034355,-12.503612649861672,18.880084149377922,-41.023250438089541,-36.394015490291949,-40.563053270110849,-30.630358276794141,null,24.764499361406621,30.036740506744323,55.64636940422276,8.5247919710358602,-8.4814968780944398,5.1192489849547584,-45.559435461415276,-44.332278294318968,7.0436654532027205,-33.641432016169659,-36.14397665508281,-17.854863284592042,-38.24183676881438,null,18.587488482477085,42.382925232553291,38.243918095405192,24.040202347745392,13.85007939398966,2.25249846104726,18.274528180390057,-2.1339798818604407,37.620492138889873,-5.8009775853049135,-19.712114898492416,-5.197397698384016,18.699887198247687,-32.086926730538863,0.082548111317855444,-13.107936264386844,13.85007939398966,null,40.923320399150683,23.431473207150987,32.050653980021679,9.052217651879559,-14.801837063011941,7.0283671638612546,19.28683786439656,26.229739251209274,-17.661385564536815,-15.194756352572213,14.434689302742882,10.646286063493086,8.0540903801979553,-17.68314110336734,-21.741849765369043,15.011503751440259,-19.232259160715422,-28.686826834431272,null,1.2961276141552887,20.846797104192085,34.508334600739687,10.602609841949288,28.890559111223055,-7.5515582302797419,-14.578038875358541,4.230644765910661,-4.3145642377157145,-13.346968546358514,1.1376979184356841,-8.8223581039275132,-3.8396731839933409,-22.369492615913842,2.7067758666278579,7.3237036178082562,-28.982729959932293,-32.130102886906627,null,-30.535111963510904,null,20.809833650514875,-31.618898239642665,14.525283575367929,1.9442759385248323,20.40262034181783,-48.783668205526496,-41.190849444288659,-19.199298176782762,null,18.965316816807075,-8.1680782066487652,32.663318733452932,-43.173190593153763,-46.707280326322262,null,35.941648948075382,38.212702263511638,38.979507221649733,1.3514866079778329,39.896710898341034,-39.283410521390564,null,20.794184954074233,16.202002395632533,1.7272631600154327,9.2165475084664976,13.841564959649894,17.110677619940198,40.624533498373999,8.7086509812300648,-6.1291977253540324,40.244585158546016,38.563750802870999,24.664188447111016,27.036934873156014,-16.598405439388369,12.46210832112093,2.737225524060193,-15.723961632936501,-54.527548203832204,-28.373212425519306,1.9086011974582675,-2.0448248790112302,-59.886948090731387,-34.02945023769589,4.0742032533607073,-22.521971921982797,null,40.030431312474228,-8.4554424298600708,8.6915983269018966,10.857578724062698,67.185387797381793,65.331467961090794,-6.4529769792710354,-2.6903318602701347,-0.45655910993609439,23.532161415474008,29.090761638375014,1.7413370288229117,-14.124832123280068,0.4020923309795279,9.6948037696576321,-30.937558033088905,-22.241180367105201,-25.016049646741905,-27.655009212176402,13.134633679393062,3.2481128280777654,-74.114422809704095,-1.7018393959899925,-66.159988029484992,12.824142004854011,null,20.28637580175733,15.231714361398232,27.071290486730831,34.322088734838097,11.579949488141203,9.0102654628137984,6.4401678282221937,-14.109226065714935,-3.6825934602709367,17.124662242587007,36.074197880870997,47.512353072194998,39.279368670037002,-11.556279691684871,5.4675309253437945,-22.220213748950101,12.638797618250202,-23.802854733041602,-3.839138916391434,-9.8611939921566361,-57.271824467876392,-63.992325262922591,-33.626422605141791,1.2563501400087063,null,-35.547124073767456,-15.498606603866957,-23.903433552494455,null,10.732413180061343,3.693862316149243,-36.660176504435604,-41.570171665109839,null,-30.106881454186258,-14.942123504607355,-2.1653255506898574,null,29.919554503030945,3.7189700180973446,2.1227520528779991,4.5664370648452959,22.121498698941203,22.774400600507199,1.6054576510578755,27.079864231156265,-12.582870989446526,17.135253049876347,-14.670240602274802,-19.281515563478703,-24.487068702052902,-33.949114075120427,-23.384519112126625,-62.682676822558818,-44.782343303652169,null,17.0730543105389,17.472051257998793,32.338726665993995,19.014410195879975,32.706528867707476,-19.036182970157956,8.7834055176560994,-32.257996586198502,-64.089500171799415,-37.809621819303231,-36.937313552764827,-45.183104318742259,-33.025753005287349,null,23.224411728604743,-16.007264291197004,8.0115419780674983,8.839059487052296,28.820985504584193,26.172240405174975,14.861583465951668,-38.471107297284405,-29.990765417918102,-51.238300059867328,-65.683840590817852,-43.376104871686231,-31.093416493023049,null,27.920892595952957,42.090398654788011,21.187563440042204,-7.9756624092839488,-35.39895921736165,-7.8198670313695899,-1.5536327744973946,-26.714931055164893,null,7.9768221095048517,23.127379335130804,0.052300846621008645,-30.913656218438849,-45.339503710620392,-19.10834749416189,null,23.911065054018543,45.076428404072949,40.949162593089206,24.111991830776709,-12.358590633306854,-35.056546509177394,-40.87500296935459,-29.387156815757393,null,54.890331961577509,-15.295257432235893,null,42.212870680165203,-27.22848723443969,null,0.82022483848860617,27.811184877554503,-28.87467603145469,null,-14.173003160721976,-4.3048331883870716,4.4406697199163716,10.654127670799369,20.203363107886062,5.1389640721232723,66.094408366024254,-56.387935217545305,-22.903218805762236,-25.377463311029537,4.3334606720455611,null,10.406989181828926,12.116720514712867,2.7069426689126601,3.6069628330369596,2.5813758206842721,-11.399053636189375,-60.383658803101568,-22.109111292635937,-29.813721780054536,-6.057600644399237,-34.527635879062444,null,-19.975870814021334,-5.781133201230432,12.929372108966561,6.2983413407060596,-28.031555718469512,-43.558704461079635,-41.625141041602632,-9.6855553567401316,5.5713421257599691,null,44.944856736675263,-18.659485105657545,-23.314642944554343,null,-9.2105224495933413,-30.605745739113544,null,54.05712009784726,-48.77835308256558,null,34.184122641776753,37.636678395632259,26.287228042347465,18.483343566130024,12.164390933967233,10.273860357604526,-10.260445957731037,-24.893253659483541,6.4545779996282349,null,41.553792928814161,14.517522388326356,5.6284044357317313,10.998852349478732,15.728560307728436,-52.82724490299384,-8.6387455867057383,-36.150182541493635,-50.368600751236073,16.628502078327124,5.3283521727875254,null,41.479787283008463,39.931862755626454,12.607333632641136,18.975081139442132,-42.150889220298041,-17.53177422419904,-43.13845834262704,6.6971797678082297,6.5664185285256238,12.607333632641136,null,27.519661582841231,19.237422618912127,null,3.3768412101881324,20.469149554195305,30.932352517359199,31.913171675285405,55.544422210483511,-10.502093343015169,-6.3544718188235692,-30.255549602950797,-25.977415996560197,-49.567406167303496,-36.502184630456199,null,22.392059237104732,16.516332840723635,44.813631664504506,10.060307475051602,36.47941433089931,57.466766711805498,5.1922088760310317,-47.489035921941529,-42.816866705124525,-40.821243904748286,-39.159694854813395,-27.549272455432579,null,2.9072841660596325,20.763326168679406,-16.832179895195893,45.37180937482271,17.265159259160207,-33.528161168268397,-42.442389818401693,-48.417043105973832,-48.87434586459225,-44.039866015647327,null,7.4663469201477426,-6.2107640794829599,null,-1.8783249819519625,-11.551566924575859,null,-20.838453943863662,-8.4689045439984589,-22.645174796355761,-23.576008074212261,null,-5.5858747040575594,38.965325386460137,-11.671869931824162,-8.2633592017534596,-20.22278697766976,null,-4.3608431271082608,-18.606467555549461,-21.79706857095616,null,-9.2900850530471608,-3.9277927507883597,-27.03030145351266,null,-19.25613970213908,null,24.484619642972227,15.935884366445627,67.06956188823311,61.867567293481116,63.16424141429313,52.414933475952125,-9.3217028626718772,1.5231772645855202,46.488814612015119,57.917531859638117,64.856293234627131,47.241290327196126,null,-1.7830397200514767,9.4651210949119147,51.349196653019121,69.97741021614813,62.840285836374122,63.334432773378111,-18.593934384134478,10.052826784587218,56.087809754009115,42.497770565173127,43.614575660652122,31.667289489949127,null,13.930197357158015,17.331405704862526,53.882544316939132,45.977332531881117,37.251061704075127,62.043661823254112,22.892343870284627,4.8113849874079264,70.491281072228119,48.631883582849127,38.698637538502126,50.436787171088127,null,18.607817028170174,3.5985298989134584,24.810330592080259,-34.567085957905519,-7.5409061714854424,null,1.7261515559880571,-15.772929808004321,-15.217096718926662,null,54.137644614105881,4.2178797500337559,-11.960858450804944,null,8.6630839298897584,27.405863951806058,-17.072758324706843,-0.72501210437764385,null,12.88752393213186,4.4228727197586579,-13.396016194764133,-18.420865192569583,5.1573937540134587,null,-0.29820153488184431,17.986430511156559,21.555868870101758,-20.739296924667872,-2.9820053353380445,null,36.079522342022699,32.0770362805047,null,11.811922811666705,null,55.642080631195711,null,49.975908972846696,null,24.096818734590698,null,67.233664877874162,-14.631517517470417,39.013492232159706,null,2.0801136869185086,46.01803283193815,19.267279340579705,15.256138008302251,-5.2970561621715504,null,-6.3754637520015507,-8.8689184601987563,null,8.1413848551587833,20.673933712094779,-28.125901582046922,-9.817819590489016,null,-10.011292302601518,null,57.361899815878374],"z":[10.083601,8.6517479999999995,5.7234350000000003,-10.029465,2.0042643999999998,7.7599539999999996,10.513826999999999,-5.1175870000000003,13.444191,-0.96534025999999995,11.090548999999999,3.1487202999999999,6.5535079999999999,1.9186916000000001,-1.8692853,-0.020552023999999999,16.132989999999999,41.844830000000002,4.3419460000000001,0.27631694000000001,13.29541,11.436946000000001,1.5303929999999999,3.3774023,2.5306334000000001,3.1495655,12.859593,-1.9358268999999999,0.77607219999999999,0.15881435999999999,-0.22485004,4.8210940000000004,-10.581054999999999,4.9492992999999998,38.837643,25.235046000000001,null,13.24193,7.8840693999999996,14.820817,27.620739,4.0413959999999998,5.7179029999999997,5.7879209999999999,2.3578782,-4.4721700000000002,8.0968669999999996,-2.8099205,6.0335520000000002,11.040036000000001,4.0131490000000003,4.6796556000000002,-4.3079042000000003,26.491427999999999,14.817145999999999,19.313965,0.60212200000000005,14.49414,-6.2111305999999997,1.3486590000000001,10.442211,3.1030525999999998,-13.418872,7.5442666999999997,1.4526684000000001,5.7627160000000002,0.72215050000000003,7.5624180000000001,8.1001650000000005,-0.81923615999999999,7.1169285999999996,14.391463,15.326316,null,-0.84721135999999997,-11.068448,10.930821999999999,22.658676,2.722261,1.5794973000000001,-0.99165577000000005,0.44460013999999998,3.1227182999999998,2.9611450000000001,4.9116426000000004,1.3944502000000001,5.3441552999999997,10.599935,-1.2655599,8.9391400000000001,4.1924744,14.412008,9.599945,7.5136193999999996,23.479946000000002,1.87483,13.033454000000001,14.907605999999999,6.7764892999999997,8.6977449999999994,7.3710355999999999,5.9522567000000004,5.0807529999999996,6.0322164999999996,-0.4893806,9.0655249999999992,3.407823,-4.0940064999999999,19.826350000000001,25.499196999999999,null,0.36042344999999998,-6.7047239999999997,4.8559400000000004,-1.0107094000000001,4.8559136000000001,2.1779597000000002,-7.5966715999999996,11.994374000000001,null,4.6345887000000001,-10.006603,12.908033,7.6804104000000004,-0.23792352,11.193483000000001,-3.366641,13.410192500000001,32.071404000000001,null,-4.6256184999999999,5.766451,10.926377,-1.3360552999999999,10.446391,3.7857064999999999,12.870358,11.120075,39.421314000000002,null,8.6138750000000002,3.3696828000000001,-1.7592375,-1.7866671999999999,-0.31079440000000003,-2.2652728999999998,10.266069999999999,3.6159043,-0.1161396,5.5007051999999996,7.2001480000000004,-2.6387775000000002,2.3369049999999998,3.4254283999999999,6.5549369999999998,7.1216730000000004,11.119339,-2.2295102999999998,4.6400322999999997,-1.7623861999999999,5.5088634000000001,2.1829947999999999,6.4849224000000003,-1.2020332,-0.19049051,1.9504817999999999,8.2297180000000001,7.0348153,6.3136196,1.3510268999999999,16.872337000000002,6.8328819999999997,12.446396999999999,-0.89623989999999998,7.930491,-1.4839648999999999,-3.5426593,0.79226947000000003,-0.106339715,1.1996967000000001,-0.80553189999999997,-3.1018279,2.4706573000000001,-2.3409781000000001,4.1666613000000003,3.4379396,6.9612045,8.0938350000000003,4.0970006000000003,-1.2961893,9.5061689999999999,3.2225679999999999,1.5968336999999999,9.7595419999999997,9.0685730000000007,5.3197125999999999,-11.652297000000001,0.97167230000000004,5.7144979999999999,4.1368960000000001,11.453106,12.2663145,9.4445069999999998,3.6793892000000001,6.8590197999999996,2.6666143,null,-1.113888,-3.4153463999999998,-0.24679670000000001,-3.2957622999999998,-0.98204789999999997,1.1058633,5.5467250000000003,1.2872617,3.3338263000000001,7.4012440000000002,1.6506152000000001,5.0551456999999997,5.9078939999999998,7.079332,9.1571230000000003,1.4165283,1.3717798000000001,14.562346,0.016770884,4.9608382999999998,3.0817535,0.47908777000000002,12.043240000000001,10.531323,6.7313194000000003,10.08211,11.171821,-2.9687815,7.4631610000000004,7.8326044000000001,6.7270874999999997,3.8207659999999999,7.4144310000000004,7.6185403000000003,2.1858504000000001,10.627872,-12.264523499999999,1.662374,-3.1481819999999998,5.7253299999999996,-0.39579006999999999,13.095076000000001,-5.6509603999999998,2.8107324,-1.2615689000000001,3.0925189999999998,10.303894,11.370352,9.6154030000000006,7.2338896000000004,9.2748574999999995,10.378494999999999,6.1620549999999996,21.167214999999999,6.0081810000000004,13.362579,2.6149583000000001,2.1038065000000001,6.5780089999999998,11.648524,14.502340999999999,13.746460000000001,21.229153,5.1588716999999997,6.0799709999999996,2.0886786000000002,null,3.9634258999999998,9.1933389999999999,-3.5737410000000001,2.0151940000000002,-1.7487258999999999,-0.14150447999999999,6.1252604000000002,3.9621230000000001,-1.1932959999999999,4.9946465,-2.4891272,7.7365339999999998,9.4154420000000005,4.2031830000000001,7.4463100000000004,7.7976150000000004,12.044140000000001,1.9785725000000001,6.8972563999999998,11.492023,0.17171226000000001,10.368104000000001,4.0211277000000001,9.6585859999999997,2.9371423999999999,14.013164,11.002666,3.7223055,10.461180000000001,14.262185000000001,7.2251763000000002,16.428352,4.8001604000000002,9.8511349999999993,9.8014749999999999,-3.2642093000000001,-3.0032348999999998,-5.6817802999999998,0.79876846000000001,2.0143523000000001,5.3393291999999999,10.284663,4.7088165000000002,7.1484670000000001,2.1655421000000001,-4.7009540000000003,11.919326999999999,7.8909326000000002,9.5015429999999999,6.8666799999999997,1.5467706000000001,4.9872794000000003,13.801392999999999,14.751462999999999,11.730715,9.1221160000000001,4.7865843999999997,-5.6371655000000001,1.2209148000000001,5.0779386000000004,19.034493999999999,12.770549000000001,7.3097469999999998,11.716509,16.267572000000001,9.7934009999999994,5.0827116999999999,4.6375523000000003,12.790532000000001,null,10.339333,4.8932969999999996,4.6218950000000003,-0.79502070000000002,-4.2652802000000003,3.6890990000000001,6.0033735999999998,-7.5715836999999997,5.4794846000000001,-0.49137035000000001,-1.4587079000000001,3.889059,12.026723,-8.951003,7.3802050000000001,null,7.1496843999999999,6.0435280000000002,3.6780694,-1.2676244000000001,1.4148296,13.138137,-13.036783,5.9880614000000003,12.878586,4.645556,2.0478689999999999,4.2143483000000002,null,3.0486042000000002,-4.7692889999999997,-0.13326122000000001,-8.1907759999999996,-16.041302000000002,-3.5594857000000002,-0.89852743999999996,1.6397678,5.2454095000000001,6.9721640000000003,2.633451,7.7810072999999997,7.7929596999999999,0.89330399999999999,null,2.3905040999999998,5.0260930000000004,7.1978926999999997,11.023937,-10.956512999999999,10.155844999999999,2.6048054999999999,null,8.2582719999999998,5.9595222000000003,5.2900914999999999,2.4905555000000001,8.7835889999999992,4.7295775000000004,8.3210949999999997,null,5.3131640000000004,9.7948339999999998,4.3940663000000004,5.2452154000000002,4.902228,1.9115432999999999,10.181884,18.630053,null,18.435047000000001,11.977406500000001,12.94914,24.430423999999999,15.109928,15.824087,16.905176000000001,null,13.2014265,17.846312999999999,21.690632000000001,11.582991,25.176349999999999,20.469930000000002,31.953537000000001,13.697884,null,17.518878999999998,25.225552,18.805554999999998,12.028112999999999,25.686762000000002,19.198338,31.300412999999999,6.7507485999999997,null,-0.68462710000000004,null,23.597227,18.060832999999999,31.628005999999999,4.5972776,null,2.3918477999999999,10.588798499999999,9.5033130000000003,1.869165,28.020762999999999,null,3.3218011999999999,23.146979999999999,8.1178310000000007,10.036973,null,11.436769,22.280304000000001,6.0845283999999999,4.4063406000000001,4.0081115,4.5767179999999996,9.0227310000000003,5.6205080000000001,3.9510288,9.2102830000000004,0.041699022000000002,null,4.5196896000000004,1.3651804999999999,2.2726207,5.3061030000000002,6.1905264999999998,3.4338573999999999,4.7945399999999996,-0.57354110000000003,18.936619,null,17.509502000000001,3.5192296999999999,4.6578350000000004,3.5573990000000002,6.1395400000000002,27.904012999999999,5.5032500000000004,6.3113390000000003,8.507676,3.0656406999999999,null,18.487970000000001,14.303966000000001,16.566513,18.737905999999999,6.7143253999999999,1.9636661,11.423503999999999,-0.22755522,0.34622251999999998,4.0007687000000001,-1.6339737000000001,20.918184,21.705425000000002,2.6141746000000001,23.877376999999999,7.1509020000000003,18.709230000000002,-0.13252043999999999,3.1113789999999999,null,-11.566523999999999,23.968412000000001,14.813958,-6.9589952999999998,7.7737265000000004,12.171967,-1.1482509999999999,-5.8201280000000004,7.5079675000000003,28.658940000000001,33.845649999999999,4.2344384000000002,3.6004225999999999,5.9022864999999998,9.3371870000000001,9.4952279999999991,-7.9907311999999999,-2.9844773,null,19.278074,23.406683000000001,8.5884649999999993,10.500322000000001,17.174036000000001,18.137657000000001,-3.3494275,0.97157395000000002,8.327299,23.997595,16.390094999999999,49.100389999999997,39.902264000000002,17.318134000000001,5.7871560000000004,8.4506940000000004,5.0328020000000002,6.5339822999999999,null,0.54832599999999998,0.11801206,-1.5844259999999999,7.8015122000000003,1.9354852,1.0697296000000001,null,-1.4438323,-2.6161115000000001,0.64358340000000003,10.644992999999999,2.1507882999999999,6.1272039999999999,null,7.849316,-1.5526043,5.6540749999999997,12.925732,5.1332307000000004,3.9145093000000002,null,2.9589409999999998,-0.063963816000000007,6.3512000000000004,7.9228959999999997,13.540675,null,5.4709152999999997,11.422708999999999,8.7195429999999998,5.3705040000000004,8.7094749999999994,null,11.145514500000001,6.8592553000000001,7.8508690000000003,9.3255389999999991,null,4.4620147000000001,10.786735999999999,-1.3638870000000001,15.012961000000001,8.6417929999999998,5.7597847,14.805539,1.9774058999999999,-0.46393269999999998,8.0962940000000003,12.569623,null,1.9192142000000001,6.7564516000000001,-23.701504,7.1808050000000003,6.9829109999999996,0.91596869999999997,16.041193,14.763261999999999,1.4299508000000001,null,8.3248289999999994,9.2452839999999998,-3.8555869999999999,1.4067869,2.9094625000000001,-9.1247834999999995,3.4312444000000002,1.5585845,0.15661070999999999,3.8711373999999998,11.377242000000001,16.97353,null,11.590873999999999,null,5.9521559999999996,17.656545999999999,-19.380414999999999,9.168075,12.245198,null,25.058561000000001,13.612197,6.8057404000000004,7.3913060000000002,null,0.54392160000000001,-1.6826441000000001,2.7485827999999999,null,7.7656163999999999,14.429276,3.3018413,2.6663477000000002,4.7240405000000001,3.7599735000000001,null,3.2993630999999999,6.1109033000000004,12.358763,20.391047,9.0413080000000008,null,5.2588476999999996,11.068118999999999,14.902082999999999,11.737318999999999,14.091794999999999,10.528816000000001,null,13.040552,12.045007,18.629719999999999,8.9363880000000009,null,8.0618440000000007,12.207734,26.907202000000002,null,20.723593000000001,14.863587000000001,23.946470000000001,null,1.404674,0.35203185999999997,0.90558810000000001,1.8317140000000001,7.549893,null,19.55134,4.1868920000000003,1.1876338,8.4143380000000008,8.683548,null,-0.0085678509999999996,11.847588999999999,4.4808279999999998,-4.7088966000000001,null,-4.9211879999999999,-4.4188780000000003,1.0390526,7.6636660000000001,-4.9469029999999998,-2.8271891999999998,1.8504653,0.32162817999999999,2.325996,17.343551999999999,7.7036785999999999,5.9696389999999999,19.313095000000001,-6.4954723999999997,-1.5855007999999999,-4.1258059999999999,11.745105000000001,-2.1231035999999999,1.8412310999999999,4.5523676999999996,5.9089184000000001,6.0566000000000004,18.901546,-3.6629681999999999,20.995481000000002,null,17.198172,13.208693,0.39597072999999999,-15.007599000000001,15.668101,1.8325993,0.90343280000000004,10.106185999999999,-1.8729897,13.683662999999999,15.817852999999999,24.286380000000001,34.968345999999997,-0.91003239999999996,3.4853325000000002,4.9090132999999998,-8.6568959999999997,3.3871186,0.74237799999999998,5.8511924999999998,3.3422092999999999,3.1439222999999998,16.348972,11.679128,17.775434000000001,10.459463,null,5.8983673999999997,-19.789455,10.6709795,-2.6223296999999999,3.0360863,1.7155704000000001,1.5154034999999999,6.8378715999999997,6.5777210000000004,25.883710000000001,12.630836499999999,24.367477000000001,31.182652999999998,6.4793304999999997,-11.445137000000001,12.297048,5.5331353999999999,-2.4143998999999998,-1.9835924,0.18446119,4.8604827000000004,-5.3580379999999996,5.6870510000000003,19.378499999999999,24.977353999999998,42.857098000000001,null,18.466564000000002,null,22.136734000000001,9.434742,9.8798080000000006,2.1387963000000001,-0.36921095999999998,-2.8733879999999998,7.7354507000000003,-3.2160790000000001,2.9974229999999999,-1.5179586,10.870957000000001,-15.575298,-2.0256118999999999,7.319604,-0.35553306000000001,3.1141390000000002,6.1736984000000001,11.437675,12.810805999999999,null,-3.9715020000000001,-0.70591599999999999,10.999302,6.7953897000000003,10.942707,3.6030039999999999,4.2498839999999998,-4.9699479999999996,0.72325410000000001,4.7657366000000003,6.3084517,11.040906,10.797606,10.238457,0.45327034999999999,12.845241,null,16.980592999999999,-7.9188013000000002,2.7531560000000002,25.571943000000001,9.5078289999999992,2.3584394,3.763287,-6.99756,14.368081999999999,1.7946641000000001,-17.750565000000002,2.8833343999999999,10.586073000000001,10.117179,1.4824090000000001,5.4815930000000002,null,18.200182000000002,null,12.448251000000001,null,14.927396999999999,null,-2.751341,1.6622139,null,11.5497055,null,0.30435497,null,3.8607442000000001,null,0.41302070000000002,null,11.243843,null,-7.6626180000000002,7.8661393999999998,null,6.6220949999999998,null,11.681043000000001,null,3.6911893,null,8.1052669999999996,null,6.5664167000000004,8.9918650000000007,11.129632000000001,23.896339999999999,3.5926985999999999,4.5482659999999999,14.088488999999999,-1.3070786000000001,17.228401000000002,20.114832,null,2.6416335000000002,9.6958140000000004,7.6231723000000002,15.858991,14.360151999999999,14.5724745,1.3621555999999999,14.692432,16.3294,7.8880423999999998,null,4.034891,23.754852,6.4097586,16.097801,17.929392,17.880299000000001,9.0108689999999996,13.496489,2.9995015,6.4523807,8.0137809999999998,17.625895,null,4.1545104999999998,14.113455999999999,-1.7570695999999999,13.390364,-10.750152,-0.10318491,-1.0217187000000001,8.6002759999999991,-0.18670365,1.3633892999999999,-7.3945379999999998,3.3712005999999999,-10.941656,3.7856312000000001,6.3072375999999997,14.741607,2.7709693999999998,8.709384,3.6795241999999999,10.480732,10.688186,2.3865411000000001,0.95471839999999997,8.4415980000000008,1.7697896,0.66217095000000004,null,3.1837833,2.7451158000000002,-3.0972833999999998,-1.9269476000000001,-4.4732969999999996,24.367798000000001,6.6694202000000002,-0.76165989999999995,-5.2315560000000003,1.0537801,6.0116339999999999,-1.8445480999999999,8.0570544999999996,6.7966924000000004,32.339745000000001,4.1938849999999999,-1.6725124,1.4550812,-10.796239999999999,2.8331525000000002,12.105276999999999,28.756326999999999,24.705233,-0.86059039999999998,6.2602696,14.119379,null,9.4530899999999995,-0.53994006000000005,-6.1144457000000001,-12.306062000000001,0.42866515999999999,22.370927999999999,30.958853000000001,16.247575999999999,39.134390000000003,10.679226,15.625496,-1.7204434,11.477741999999999,5.2361930000000001,9.694782,-0.86537929999999996,-5.7755419999999997,-2.5093429999999999,31.352993000000001,8.7345009999999998,16.824133,25.747523999999999,3.134843,17.417290000000001,8.3424189999999996,null,-3.6884396000000002,-6.3430989999999996,-14.196123999999999,11.948043999999999,7.7667479999999998,-22.548003999999999,-10.466161,9.8673500000000001,13.451419,5.4750529999999999,-0.60118364999999996,-7.5322595000000003,null,0.97649229999999998,5.4579230000000001,-19.212557,3.0867567,-3.4573941000000001,-13.880615000000001,-10.316521,4.4997167999999999,12.060157,13.557914999999999,4.0036826000000003,13.594447000000001,-8.5726099999999992,null,-5.5163096999999999,-6.8973240000000002,-3.2505804999999999,9.1140729999999994,3.4905192999999999,5.7271140000000003,16.511972,8.6264540000000007,2.8216237999999998,11.269747000000001,10.3524475,1.5459303,-1.8088871,null,3.5554290000000002,5.8839373999999998,12.711727,0.3281307,-9.8719319999999993,1.4930969999999999,18.806576,-12.765421999999999,1.6636359999999999,5.5162982999999999,1.6638541,13.630190000000001,1.8531154000000001,5.5282289999999996,-15.2281885,-14.645001000000001,11.248177,null,12.109508,2.9720892999999999,-2.5789802000000002,-0.75570090000000001,13.86462,-0.38786846000000003,-0.74713039999999997,7.3884480000000003,7.9806347000000004,5.129645,14.446158,8.0071519999999996,2.121264,-4.3357169999999998,2.0830462000000001,2.8476111999999998,20.506681,19.792683,null,13.211928,13.320055999999999,12.903103,7.6796490000000004,-0.40748679999999998,-2.8192732,0.55334799999999995,-11.107616999999999,12.711016000000001,14.514132,15.852706,3.8069362999999998,1.6725409,-1.9383192,3.8951568999999999,10.936769999999999,32.83728,16.424424999999999,null,25.167729999999999,null,10.527618,3.918666,1.5078232,5.4548500000000004,1.5870333000000001,-1.1883836999999999,4.7228317000000004,0.37642908000000003,null,1.3097589999999999,10.427757,3.6842945,7.1661339999999996,2.4855797000000002,null,26.555070000000001,8.0705209999999994,3.4407386999999998,17.135244,6.9622406999999997,13.664807,null,0.15334118999999999,6.7683764000000002,-0.68594379999999999,1.0764997999999999,-2.1600134,7.7111590000000003,-0.96907573999999996,0.32130635000000002,-0.78268694999999999,10.992149,9.7867259999999998,5.7112020000000001,16.752389999999998,1.5073953,1.6710552999999999,6.284459,0.25870144,1.8714997,6.2034406999999998,2.4472458000000001,5.8373523,12.4414015,14.074534999999999,11.825348999999999,23.979424999999999,null,3.8252155999999999,6.629874,2.8113440000000001,1.3289572000000001,6.0314449999999997,7.4162936000000004,3.06223,-0.48341962999999999,22.508482000000001,21.82667,14.763089000000001,18.616833,2.1331755999999999,-2.4154680000000002,2.6719618000000001,5.7323903999999999,3.910075,6.1441053999999999,-3.8995625999999999,0.64334570000000002,1.7845773,24.16611,8.9987980000000007,14.794198,6.3778977000000001,null,6.2874416999999996,6.0117399999999996,4.8737392000000002,3.8037763,2.6500010000000001,1.5574732,4.7638087000000002,3.940175,6.3995842999999999,9.8851410000000008,17.604664,27.569759999999999,-21.635505999999999,5.4934586999999997,2.6454048000000001,1.8312953999999999,5.3645779999999998,1.7367033999999999,5.6270889999999998,2.0167277000000001,23.014299999999999,17.028282000000001,26.042380000000001,16.13363,null,6.0931753999999998,8.7295350000000003,7.4145054999999997,null,8.3910049999999998,4.6493796999999999,5.5557920000000003,5.9733352999999996,null,6.8068204000000003,8.0121310000000001,5.8119415999999999,null,8.8368029999999997,10.715937,-7.9087509999999996,6.5121655000000001,17.111311000000001,3.7224488,4.8606379999999998,0.23669527000000001,2.0973616000000002,9.3186490000000006,3.9624733999999999,6.1452723000000002,-5.3055719999999997,8.6725680000000001,-1.3963213000000001,3.811855,2.8894882000000002,null,-11.859094000000001,10.984146000000001,12.833657000000001,1.2374339999999999,1.3995230999999999,10.361222,9.3108989999999991,9.4641129999999993,1.7674171000000001,-2.5923417,6.6753235000000002,11.297435999999999,13.398262000000001,null,10.519033,3.3098635999999999,9.7435080000000003,0.19786145999999999,8.7114039999999999,1.8817638000000001,-3.2337440000000002,-1.7936432,18.96077,3.1180479999999999,-1.2868108,-3.4148626000000002,2.6968613000000001,null,3.5056251999999999,1.0119174,4.4112305999999997,5.6902122000000004,15.118186,-3.6117492000000002,-2.3905313000000001,-0.56152004,null,12.224023000000001,9.6504100000000008,5.5254683,2.5934699000000001,24.067709000000001,14.324350000000001,null,14.680027000000001,0.75519630000000004,5.1827535999999998,9.704034,10.632186000000001,20.195974,19.554867000000002,2.7743812000000001,null,3.2916202999999999,3.0780728000000002,null,20.912110999999999,17.924156,null,3.6997805000000001,1.233962,10.80626,null,7.3629546000000001,6.8995122999999996,8.3284830000000003,0.86288136000000004,9.9758410000000008,9.0005749999999995,2.6312180000000001,7.8547916000000004,3.5594834999999998,4.8214990000000002,7.5329949999999997,null,11.224694,-3.7763371000000001,4.4368277000000003,-1.5203962,4.4066796000000004,8.4275509999999993,8.1299530000000004,6.3195430000000004,9.937621,8.735811,3.1434228000000002,null,11.494543,0.9602562,8.2617449999999995,4.7642045,6.3271704,5.7118716000000003,11.545787000000001,10.093799000000001,0.75607765000000005,null,5.4341983999999997,-0.13647100000000001,10.355214,null,2.8715476999999998,-2.0355097999999998,null,-0.72616683999999998,-2.4419689999999998,null,8.8070470000000007,18.689959000000002,3.4993742000000001,-0.67612589999999995,-0.31848952000000003,6.8389430000000004,5.1796426999999996,8.2922010000000004,6.1330441999999996,null,13.196145,15.128947,8.8215850000000007,5.4710000000000001,2.5580862,19.223482000000001,7.3927946000000002,12.501598,1.9107772999999999,4.5092359999999996,-0.37223339999999999,null,19.064753,13.7184925,14.043172,1.6243216,12.766938,3.5520271999999999,7.591907,-1.2437697999999999,3.1610996999999998,15.318097,null,0.69683050000000002,2.5104673000000002,null,28.396984,-4.3073180000000004,-4.7072495999999999,4.7605250000000003,-8.3015349999999994,-3.5128455000000001,7.3700330000000003,0.2289707,0.48594502000000001,-0.11204386500000001,-3.0408778000000001,null,5.5640697000000001,7.0353289999999999,-3.9662278,4.2539325000000003,-6.0920480000000001,-10.839888,5.7386499999999998,-0.62740295999999995,5.3452387000000003,-2.1990699999999999,-8.7255640000000003,-1.3090241,null,7.0586677,-1.19248,-2.1519408000000002,-0.8562478,2.2393698999999998,7.2700060000000004,-0.28563827000000003,-5.3438262999999999,3.1388275999999999,3.936585,null,-3.7304425000000001,-13.434195000000001,null,-1.0034784999999999,-13.055191000000001,null,0.2335642,-10.0616255,-6.5154920000000001,-7.1329564999999997,null,-2.5658034999999999,-4.9882635999999998,-7.4609075000000002,-5.9470695999999998,3.349437,null,1.5553075000000001,8.4013089999999995,-3.4089138999999999,null,-12.388954999999999,5.3756022000000003,-2.2072923000000002,null,12.714460000000001,null,12.173873,9.2064249999999994,2.6605775,3.2730823,3.1682925000000002,4.742775,-4.7857539999999998,2.7999597000000001,10.753154,-0.43903086000000002,3.1280709999999998,12.376604,null,10.638341,16.546233999999998,10.433130999999999,6.860169,14.880589499999999,1.5938056,11.312541,-2.2324860000000002,7.3011074000000002,9.8566699999999994,4.9523663999999998,10.910171500000001,null,10.693942,24.753702000000001,4.7320140000000004,15.195838,10.820133,18.336355000000001,5.8922577,24.030166999999999,4.0387683000000001,8.4324539999999999,2.4540042999999998,7.0756373000000004,null,8.3903719999999993,-0.52280020000000005,-0.62530226,14.428908,2.7297463,null,-0.32876438000000002,10.892757,1.2092471,null,10.349951000000001,5.2898019999999999,-2.6435065,null,5.4631949999999998,-4.5500280000000002,-4.1616572999999999,-3.7811313000000002,null,-1.8847948000000001,2.9451537000000001,2.9673834000000001,1.0779401,2.1940521999999998,null,-3.0604627,2.1932402,-4.0037326999999996,-1.5583435000000001,-1.9639168,null,7.3428360000000001,2.5098813,null,9.2011660000000006,null,10.597383499999999,null,7.3836190000000004,null,3.41804,null,-5.8179360000000004,2.1915488000000001,9.066675,null,7.2443624,11.928146999999999,7.6411619999999996,16.465161999999999,2.8169696000000002,null,2.3618006999999999,-5.1404969999999999,null,-1.1785296000000001,7.8377246999999999,-3.6099887000000002,-0.63500489999999998,null,0.53657513999999995,null,4.3944239999999999],"type":"scatter3d","mode":"lines","marker":{"colorbar":{"title":"STIM_linear","ticklen":2},"cmin":-0.5,"cmax":0.5,"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":false,"color":[-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0,null,0.5,null,-0.5,null,-0.5,-0.5,null,0,null,0.5,null,-0.5,null,0.5,null,0,null,0,0,null,0,null,0.5,null,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,null,0,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,null,0,0,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,null,0.5,null,-0.5,null,0.5,null,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,null,0.5],"line":{"colorbar":{"title":"","ticklen":2},"cmin":-0.5,"cmax":0.5,"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":false,"color":[-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0,null,0.5,null,-0.5,null,-0.5,-0.5,null,0,null,0.5,null,-0.5,null,0.5,null,0,null,0,0,null,0,null,0.5,null,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,null,0,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,null,0,0,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,null,0.5,null,-0.5,null,0.5,null,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,null,0.5]}},"line":{"colorbar":{"title":"STIM_linear","ticklen":2},"cmin":-0.5,"cmax":0.5,"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":false,"color":[-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0,null,0.5,null,-0.5,null,-0.5,-0.5,null,0,null,0.5,null,-0.5,null,0.5,null,0,null,0,0,null,0,null,0.5,null,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,null,0,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,null,0,0,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,0,null,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,0,0,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,-0.5,null,0,0,0,null,0.5,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,0.5,0.5,0.5,null,-0.5,-0.5,null,0,null,0.5,null,-0.5,null,0.5,null,-0.5,-0.5,-0.5,null,0,0,0,0,0,null,0.5,0.5,null,-0.5,-0.5,-0.5,-0.5,null,0,null,0.5]},"frame":null},{"x":["cuetype-high","cuetype-low"],"y":[-121.87415397854511,91.917812551049678],"type":"scatter3d","mode":"markers","opacity":0,"hoverinfo":"none","showlegend":false,"marker":{"colorbar":{"title":"STIM_linear","ticklen":2,"len":0.5,"lenmode":"fraction","y":1,"yanchor":"top"},"cmin":-0.5,"cmax":0.5,"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"color":[-0.5,0.5],"line":{"color":"rgba(255,127,14,1)"}},"z":[-23.701504,49.100389999999997],"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```


```r
library(plotly)
ses1.Lh = p.demean[p.demean$ses == "ses-01" & p.demean$STIM == "low" & p.demean$cue_name == "high",]
ses1.Lph <- plot_ly(ses1.Lh,x = ~EXPECT_demean, y = ~NPSpos)
ses1.Mh = p.demean[p.demean$ses == "ses-01" & p.demean$STIM == "med" & p.demean$cue_name == "high",]
ses1.Mph <- plot_ly(ses1.Mh,x = ~EXPECT_demean, y = ~NPSpos)
ses1.Hh = p.demean[p.demean$ses == "ses-01" & p.demean$STIM == "high" & p.demean$cue_name == "high",]
ses1.Hph <- plot_ly(ses1.Hh,x = ~EXPECT_demean, y = ~NPSpos )

ses1.Ll = p.demean[p.demean$ses == "ses-01" & p.demean$STIM == "low" & p.demean$cue_name == "low",]
ses1.Lpl <- plot_ly(ses1.Ll,x = ~EXPECT_demean, y = ~NPSpos)
ses1.Ml = p.demean[p.demean$ses == "ses-01" & p.demean$STIM == "med" & p.demean$cue_name == "low",]
ses1.Mpl <- plot_ly(ses1.Ml,x = ~EXPECT_demean, y = ~NPSpos)
ses1.Hl = p.demean[p.demean$ses == "ses-01" & p.demean$STIM == "high"& p.demean$cue_name == "low",]
ses1.Hpl <- plot_ly(ses1.Hl,x = ~EXPECT_demean, y = ~NPSpos )

subplot(
  add_histogram2d(ses1.Lph, zsmooth = "best") %>%
    colorbar() %>%
    layout(xaxis = list(title = "low_stim high_cue")),
  add_histogram2d(ses1.Mph, zsmooth = "best") %>%
    colorbar() %>%
    layout(xaxis = list(title = "med_stim high_cue")),
  add_histogram2d(ses1.Hph, zsmooth = "best") %>%
    colorbar() %>%
    layout(xaxis = list(title = "high_stim high_cue")),

  add_histogram2d(ses1.Lpl, zsmooth = "best") %>%
    colorbar() %>%
    layout(xaxis = list(title = "low_stim")),
  add_histogram2d(ses1.Mpl, zsmooth = "best") %>%
    colorbar() %>%
    layout(xaxis = list(title = "med_stim")),
  add_histogram2d(ses1.Hpl, zsmooth = "best") %>%
    colorbar() %>%
    layout(xaxis = list(title = "high_stim")),
  shareY = TRUE, titleX = TRUE
)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-f9d6c86af39196a50e85" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-f9d6c86af39196a50e85">{"x":{"data":[{"colorbar":{"title":"","ticklen":2,"len":0.14285714285714285,"lenmode":"fraction","y":1,"yanchor":"top"},"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"x":[34.07502607838525,44.695856966078239,23.27241573804875,11.426914579322144,16.315286279840585,30.906857641881786,50.030272751536685,70.546822882550387,36.326166802471178,50.888099345443166,38.311879737590175,52.513852748651161,5.4763803116992733,-21.505199764688825,48.99074382901027,57.363297074446265,14.830482578337616,17.776653648877016,null,47.765456520682704,-3.8266820511746928,58.142750648921805,null,null,28.023521746895305,41.55832837811591,39.632625113147917,42.160592293195911,-13.326783842614629,1.7845557310265114,1.7357702221161126,15.083060962704213,15.438942062787866,40.051862566575167,22.469626964753267,28.577022643004469,2.5789995887334882,-54.258667257118596,1.9812965544501822,17.356451833489679,0.83732820124572527,22.106643059113324,6.5078283779369315,27.273129444226626,-0.46163462069212358,25.437418339076572,13.625453001622574,22.026886832844582,55.114387778585524,33.438496179328226,15.383466008127826,44.867574925712731,32.984816742099625,50.321896186602913,40.649129203065826,47.436432646981814,7.7662672847681051,22.598896550407503,41.28290260994963,41.026424727780636,35.960488153898638,27.042506996456027,-7.0218748526031689,-1.067439502432066,-10.392097104090467,14.079544937913127,31.118466479770561,1.2316428377335455,16.014281403320552,25.761727016098561,16.465896886658811,9.1431934128028018,-7.8392503882107007,28.5588626122058,null,-30.347140203385912,20.404128015163892,-44.328417362030194,-35.49026794070469,-50.586587169867876,43.364223706542319,-6.7819620618168699,-6.7819620618168699,41.935699053165081,42.640119864545085,41.248593211997076,42.640119864545085,38.102107679195996,70.690950275969897,25.607588284031991,87.499149553667905,91.917812551049678,37.219286338090669,37.165660139470759,-7.2750346968611055,-1.9040951184888044,23.302474000902819,15.540828172084517,-6.4407907348144846,9.4141114823800152,9.981416886763995,54.184799578614303,9.2029042700136969,18.819626748584298,null,-8.3266054315336362,-3.6661007061553263,68.321623958130573,-15.344558993253123,23.704530607432673,-1.6708304240760583,44.368670468091835,47.197450779361695,53.99569068262749,-6.1073654737068779,2.3959300295061183,9.6144168603834785,19.077984033415078,18.330593166828677,41.555181776418273,-14.782256851093763,35.224893264729957,27.728474981614937,42.519104649067941,-10.829198461986053,39.670634584314456,-20.272952987350749,36.188314501063445,null,20.616465427052212,19.892051177549014,3.6203943863308439,-4.4039203052441565,-18.506693096735148,58.685055859485615,55.708819386324606,32.019053853170618,36.879361525753623,38.896505000172567,null,-29.591162847599598,13.002405023461293,null,null,null,16.849936928630697,15.881095499972687,29.130282277150698,9.6531213948636889,-0.040052562992912044,4.0485375915676869,22.076797450877073,53.933742036621972,-27.923166314610924,26.808216358520177,-8.3040724802448196,16.541292760027382,-20.64971477967692,23.371621046129782,46.0070807734742,39.3676102545802,-14.046637726041773,8.6845144878016214,-5.0810722877387775,8.484579877292532,52.898148449588554,-0.57129284721494145,21.379453693266761,52.194810845704659,18.587488482477085,42.382925232553291,38.243918095405192,24.040202347745392,13.85007939398966,2.25249846104726,18.274528180390057,-2.1339798818604407,37.620492138889873,20.809833650514875,-31.618898239642665,14.525283575367929,1.9442759385248323,20.40262034181783,20.794184954074233,16.202002395632533,1.7272631600154327,9.2165475084664976,13.841564959649894,17.110677619940198,40.624533498373999,8.7086509812300648,-6.1291977253540324,40.244585158546016,38.563750802870999,24.664188447111016,27.036934873156014,null,29.919554503030945,3.7189700180973446,2.1227520528779991,4.5664370648452959,22.121498698941203,22.774400600507199,1.6054576510578755,27.079864231156265,-12.582870989446526,17.135253049876347,27.920892595952957,42.090398654788011,21.187563440042204,54.890331961577509,-14.173003160721976,-4.3048331883870716,4.4406697199163716,10.654127670799369,20.203363107886062,5.1389640721232723,66.094408366024254,44.944856736675263,34.184122641776753,37.636678395632259,26.287228042347465,18.483343566130024,12.164390933967233,10.273860357604526,null,3.3768412101881324,20.469149554195305,30.932352517359199,31.913171675285405,55.544422210483511,7.4663469201477426,-6.2107640794829599,-5.5858747040575594,38.965325386460137,null,24.484619642972227,15.935884366445627,67.06956188823311,61.867567293481116,63.16424141429313,52.414933475952125,null,18.607817028170174,3.5985298989134584,24.810330592080259,8.6630839298897584,27.405863951806058,36.079522342022699,49.975908972846696,67.233664877874162,-14.631517517470417,8.1413848551587833,20.673933712094779],"y":[10.083601,8.6517479999999995,5.7234350000000003,-10.029465,2.0042643999999998,7.7599539999999996,10.513826999999999,-5.1175870000000003,13.444191,-0.96534025999999995,11.090548999999999,3.1487202999999999,6.5535079999999999,1.9186916000000001,-1.8692853,-0.020552023999999999,16.132989999999999,41.844830000000002,4.1480180000000004,0.36042344999999998,-6.7047239999999997,4.8559400000000004,0.23935424999999999,11.70796,8.6138750000000002,3.3696828000000001,-1.7592375,-1.7866671999999999,-0.31079440000000003,-2.2652728999999998,10.266069999999999,3.6159043,-0.1161396,5.5007051999999996,7.2001480000000004,-2.6387775000000002,2.3369049999999998,3.4254283999999999,6.5549369999999998,7.1216730000000004,11.119339,-2.2295102999999998,4.6400322999999997,-1.7623861999999999,5.5088634000000001,2.1829947999999999,6.4849224000000003,-1.2020332,-0.19049051,1.9504817999999999,8.2297180000000001,7.0348153,6.3136196,1.3510268999999999,16.872337000000002,6.8328819999999997,12.446396999999999,-0.89623989999999998,10.339333,4.8932969999999996,4.6218950000000003,-0.79502070000000002,-4.2652802000000003,3.6890990000000001,6.0033735999999998,-7.5715836999999997,2.3905040999999998,5.0260930000000004,7.1978926999999997,11.023937,18.435047000000001,11.977406500000001,12.94914,24.430423999999999,-1.3474827,23.597227,18.060832999999999,11.436769,22.280304000000001,6.0845283999999999,4.4063406000000001,4.0081115,4.5767179999999996,18.487970000000001,14.303966000000001,16.566513,18.737905999999999,6.7143253999999999,1.9636661,11.423503999999999,-0.22755522,0.34622251999999998,4.0007687000000001,-1.6339737000000001,0.54832599999999998,0.11801206,2.9589409999999998,-0.063963816000000007,6.3512000000000004,4.4620147000000001,10.786735999999999,-1.3638870000000001,15.012961000000001,8.6417929999999998,9.9224650000000008,5.9521559999999996,17.656545999999999,7.7656163999999999,14.429276,3.3018413,13.040552,12.045007,1.404674,0.35203185999999997,0.90558810000000001,-4.9211879999999999,-4.4188780000000003,1.0390526,7.6636660000000001,-4.9469029999999998,-2.8271891999999998,1.8504653,0.32162817999999999,2.325996,17.343551999999999,7.7036785999999999,5.9696389999999999,19.313095000000001,6.2674760000000003,22.136734000000001,9.434742,9.8798080000000006,2.1387963000000001,-0.36921095999999998,-2.8733879999999998,7.7354507000000003,-3.2160790000000001,2.9974229999999999,-1.5179586,8.8896080000000008,-2.751341,3.8607442000000001,6.4336634000000004,5.6718143999999997,11.414602,6.5664167000000004,8.9918650000000007,11.129632000000001,23.896339999999999,3.5926985999999999,4.1545104999999998,14.113455999999999,-1.7570695999999999,13.390364,-10.750152,-0.10318491,-1.0217187000000001,8.6002759999999991,-0.18670365,1.3633892999999999,-7.3945379999999998,3.3712005999999999,-10.941656,-3.6884396000000002,-6.3430989999999996,-14.196123999999999,11.948043999999999,7.7667479999999998,-22.548003999999999,3.5554290000000002,5.8839373999999998,12.711727,0.3281307,-9.8719319999999993,1.4930969999999999,18.806576,-12.765421999999999,1.6636359999999999,10.527618,3.918666,1.5078232,5.4548500000000004,1.5870333000000001,0.15334118999999999,6.7683764000000002,-0.68594379999999999,1.0764997999999999,-2.1600134,7.7111590000000003,-0.96907573999999996,0.32130635000000002,-0.78268694999999999,10.992149,9.7867259999999998,5.7112020000000001,16.752389999999998,9.2439999999999998,8.8368029999999997,10.715937,-7.9087509999999996,6.5121655000000001,17.111311000000001,3.7224488,4.8606379999999998,0.23669527000000001,2.0973616000000002,9.3186490000000006,3.5056251999999999,1.0119174,4.4112305999999997,3.2916202999999999,7.3629546000000001,6.8995122999999996,8.3284830000000003,0.86288136000000004,9.9758410000000008,9.0005749999999995,2.6312180000000001,5.4341983999999997,8.8070470000000007,18.689959000000002,3.4993742000000001,-0.67612589999999995,-0.31848952000000003,6.8389430000000004,5.0092220000000003,28.396984,-4.3073180000000004,-4.7072495999999999,4.7605250000000003,-8.3015349999999994,-3.7304425000000001,-13.434195000000001,-2.5658034999999999,-4.9882635999999998,-0.44981092,12.173873,9.2064249999999994,2.6605775,3.2730823,3.1682925000000002,4.742775,14.170332,8.3903719999999993,-0.52280020000000005,-0.62530226,5.4631949999999998,-4.5500280000000002,7.3428360000000001,7.3836190000000004,-5.8179360000000004,2.1915488000000001,-1.1785296000000001,7.8377246999999999],"type":"histogram2d","zsmooth":"best","marker":{"line":{"color":"rgba(31,119,180,1)"}},"xaxis":"x","yaxis":"y","frame":null},{"colorbar":{"title":"","ticklen":2,"len":0.14285714285714285,"lenmode":"fraction","y":0.85714285714285721,"yanchor":"top"},"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"x":[21.887814246057147,-15.174719688596255,47.366938769959248,20.678061281879039,36.988645342118488,11.847355170797684,33.74398478686868,15.861805016873383,43.978319199156175,32.639384282971179,43.466350796158167,49.828101300844182,-72.044061825400931,12.751203049973256,-9.7226974740307384,35.129278824456279,10.733332747719317,13.244490412100618,19.931461422135406,34.185903845639402,38.771401440339602,40.287619001662605,null,39.859552638074909,66.653270177690899,16.679775057376709,46.217369834487904,4.5597850985989119,14.07167387097881,10.116586440240415,5.0731645084771095,13.856718544980865,33.425689690217467,47.040873320614566,-26.936640807642114,42.41595976057409,36.848500149624378,-25.827088758922514,17.852011477768727,19.357889536189134,27.856072301587432,27.398260046997635,-44.45452450424532,5.753127305405684,11.988221314446577,6.4953988597205807,26.42202406303312,27.880357350590231,25.247024691309718,37.683385523547329,68.387691382811227,-5.5730789259895772,33.248320542124716,23.594534453588224,0.031156095145007612,11.715422739951904,35.934084570738634,35.831152528175636,22.341163617063827,7.8895730324726401,3.8462180372713348,-2.5162051404326675,7.4838506418962325,-0.56602132292545093,18.941277396263544,16.470061903353553,-9.9410471529244546,13.554793066204809,-9.008162945237487,26.37436842176281,23.897901420000807,41.924666290524897,23.513068872808887,-8.3919499670152788,15.887967015662326,13.490441929326323,8.6977711535733278,42.640119864545085,42.640119864545085,40.799924608152082,42.640119864545085,56.438069539222894,38.102107679195996,67.183628165444901,87.863089763894891,2.9899803384685697,29.617971734382962,1.7926963851418947,11.724999417830794,null,48.967352361974918,16.642387722469515,10.350482826462816,47.460284747650192,57.383844479185299,44.12262718829119,24.317999710161303,9.9510376540452619,-27.986589307623973,58.323579266614573,26.321718087449682,8.0064949109443759,null,32.775918264329533,42.918454177158836,21.991819324295086,21.48695201477269,-0.17030798386608126,4.2885108427691279,14.227315655619378,32.171797690127782,33.621549001419673,-54.265526781033557,31.310525845552945,16.086066177017941,36.827115317984948,-1.394583359315746,41.419375384619457,8.9537228704330545,28.025459100367456,null,-18.106536762117145,-25.088072386969145,1.8615369673708528,64.479151150599606,61.606620098458606,39.247115404942619,10.945483531802125,35.070818101484562,45.945789566016572,null,null,11.638595506279309,null,4.2556367406785611,-18.819808406383203,33.664320383880707,-7.9317867135933113,33.462721374682687,null,12.695460852410186,18.441257951498081,19.93309225629087,22.12252953427727,24.19570925005727,3.2737909298455818,0.70294846317637649,12.961471543535175,11.812373504890282,30.559909897465204,31.654183231946206,0.94936398889292661,2.6322008883769286,-0.62275443496187677,20.469210657166727,22.616691354557361,19.231868264968263,73.078984063071459,50.141137602034355,null,40.923320399150683,23.431473207150987,32.050653980021679,9.052217651879559,-14.801837063011941,7.0283671638612546,19.28683786439656,26.229739251209274,18.965316816807075,-8.1680782066487652,32.663318733452932,null,40.030431312474228,-8.4554424298600708,8.6915983269018966,10.857578724062698,67.185387797381793,65.331467961090794,-6.4529769792710354,-2.6903318602701347,-0.45655910993609439,23.532161415474008,29.090761638375014,1.7413370288229117,10.732413180061343,3.693862316149243,17.0730543105389,17.472051257998793,32.338726665993995,19.014410195879975,32.706528867707476,null,7.9768221095048517,23.127379335130804,0.052300846621008645,null,42.212870680165203,null,10.406989181828926,12.116720514712867,2.7069426689126601,3.6069628330369596,2.5813758206842721,-9.2105224495933413,null,41.553792928814161,14.517522388326356,5.6284044357317313,10.998852349478732,15.728560307728436,22.392059237104732,16.516332840723635,44.813631664504506,10.060307475051602,36.47941433089931,57.466766711805498,-1.8783249819519625,null,-4.3608431271082608,-1.7830397200514767,9.4651210949119147,51.349196653019121,69.97741021614813,62.840285836374122,63.334432773378111,1.7261515559880571,12.88752393213186,4.4228727197586579,11.811922811666705,2.0801136869185086,46.01803283193815,-10.011292302601518],"y":[13.24193,7.8840693999999996,14.820817,27.620739,4.0413959999999998,5.7179029999999997,5.7879209999999999,2.3578782,-4.4721700000000002,8.0968669999999996,-2.8099205,6.0335520000000002,11.040036000000001,4.0131490000000003,4.6796556000000002,-4.3079042000000003,26.491427999999999,14.817145999999999,4.6345887000000001,-10.006603,12.908033,7.6804104000000004,2.4354089999999999,-1.113888,-3.4153463999999998,-0.24679670000000001,-3.2957622999999998,-0.98204789999999997,1.1058633,5.5467250000000003,1.2872617,3.3338263000000001,7.4012440000000002,1.6506152000000001,5.0551456999999997,5.9078939999999998,7.079332,9.1571230000000003,1.4165283,1.3717798000000001,14.562346,0.016770884,4.9608382999999998,3.0817535,0.47908777000000002,12.043240000000001,10.531323,6.7313194000000003,10.08211,11.171821,-2.9687815,7.4631610000000004,7.8326044000000001,6.7270874999999997,3.8207659999999999,7.4144310000000004,7.1496843999999999,6.0435280000000002,3.6780694,-1.2676244000000001,1.4148296,13.138137,-13.036783,8.2582719999999998,5.9595222000000003,5.2900914999999999,2.4905555000000001,13.2014265,17.846312999999999,21.690632000000001,11.582991,2.3918477999999999,10.588798499999999,4.5196896000000004,1.3651804999999999,2.2726207,5.3061030000000002,-11.566523999999999,23.968412000000001,14.813958,-6.9589952999999998,7.7737265000000004,12.171967,-1.1482509999999999,-5.8201280000000004,7.5079675000000003,-1.4438323,-2.6161115000000001,0.64358340000000003,11.010173,5.4709152999999997,11.422708999999999,1.9192142000000001,6.7564516000000001,-23.701504,7.1808050000000003,6.9829109999999996,25.058561000000001,13.612197,3.2993630999999999,6.1109033000000004,12.358763,10.025281,8.0618440000000007,19.55134,4.1868920000000003,1.1876338,17.198172,13.208693,0.39597072999999999,-15.007599000000001,15.668101,1.8325993,0.90343280000000004,10.106185999999999,-1.8729897,13.683662999999999,15.817852999999999,24.286380000000001,34.968345999999997,16.468927000000001,-3.9715020000000001,-0.70591599999999999,10.999302,6.7953897000000003,10.942707,3.6030039999999999,4.2498839999999998,18.200182000000002,11.5497055,14.4638195,-6.7450780000000004,-7.6626180000000002,-1.2343118,2.6416335000000002,9.6958140000000004,7.6231723000000002,15.858991,14.360151999999999,4.6239246999999999,3.1837833,2.7451158000000002,-3.0972833999999998,-1.9269476000000001,-4.4732969999999996,24.367798000000001,6.6694202000000002,-0.76165989999999995,-5.2315560000000003,1.0537801,6.0116339999999999,-1.8445480999999999,0.97649229999999998,5.4579230000000001,-19.212557,3.0867567,-3.4573941000000001,-13.880615000000001,-10.316521,14.409368499999999,12.109508,2.9720892999999999,-2.5789802000000002,-0.75570090000000001,13.86462,-0.38786846000000003,-0.74713039999999997,7.3884480000000003,1.3097589999999999,10.427757,3.6842945,11.074731,3.8252155999999999,6.629874,2.8113440000000001,1.3289572000000001,6.0314449999999997,7.4162936000000004,3.06223,-0.48341962999999999,22.508482000000001,21.82667,14.763089000000001,18.616833,8.3910049999999998,4.6493796999999999,-11.859094000000001,10.984146000000001,12.833657000000001,1.2374339999999999,1.3995230999999999,6.8043265000000002,12.224023000000001,9.6504100000000008,5.5254683,4.4593999999999996,20.912110999999999,7.8407249999999999,11.224694,-3.7763371000000001,4.4368277000000003,-1.5203962,4.4066796000000004,2.8715476999999998,15.092616,13.196145,15.128947,8.8215850000000007,5.4710000000000001,2.5580862,5.5640697000000001,7.0353289999999999,-3.9662278,4.2539325000000003,-6.0920480000000001,-10.839888,-1.0034784999999999,-11.080622999999999,1.5553075000000001,10.638341,16.546233999999998,10.433130999999999,6.860169,14.880589499999999,1.5938056,-0.32876438000000002,-1.8847948000000001,2.9451537000000001,9.2011660000000006,7.2443624,11.928146999999999,0.53657513999999995],"type":"histogram2d","zsmooth":"best","marker":{"line":{"color":"rgba(255,127,14,1)"}},"xaxis":"x2","yaxis":"y","frame":null},{"colorbar":{"title":"","ticklen":2,"len":0.14285714285714285,"lenmode":"fraction","y":0.7142857142857143,"yanchor":"top"},"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"x":[4.6829351044220431,24.188763663298943,39.349511001625245,30.413184040836242,39.33804747129858,-0.57165380884661943,24.194245951353281,56.672752908255887,26.752016836079179,24.292199612070178,44.993542162907175,52.44565254073116,-1.6347018624397265,-5.3515475884617274,57.460681452613258,57.781927509707273,13.508956563841416,15.903962080713718,39.783876251081011,28.934410129892811,1.7325143418220108,69.304580690928105,null,36.793034112930904,5.9239760098506125,10.023023833397609,-4.37954682571349,-0.69078022405838979,18.643598893638615,8.7769987537285097,13.750413199475009,22.755787197935668,-0.31483201390883409,3.4446133990272685,-3.9677869734981321,40.525113138460078,22.741091908194583,4.769031652272183,14.406393245094286,-9.4821594804391722,33.527440136391533,35.405584578326526,34.439292039670534,27.532766837020574,0.6233456461573752,34.318620459181574,31.73626840734758,19.792588102907018,34.655507618514719,28.396045110157317,14.244195473451825,11.304789805719622,14.024625888466623,63.446649629452224,27.653880818387421,5.5911709752040082,13.155103261453704,21.870747241655636,13.513252025342638,32.099755529015638,36.911206050932634,-16.892263654750067,3.7669153252821346,0.06052890912743436,11.390689499069637,7.9719947216095477,8.7211650313445546,26.882139827950553,28.028807932092562,34.196443715687806,3.0565117739576095,19.739991717288802,6.2386734864270039,9.3142527825188779,50.254805830337887,-16.021968721492399,30.467732358457326,-6.0903634373803754,-13.735907591910376,20.204603028440332,31.193660771606091,42.640119864545085,42.640119864545085,32.095360989538079,32.739091926782095,50.318567872389892,66.156912169240897,29.540692028307092,28.611509071072064,16.071185528243063,17.749728939564491,4.5916741938399923,-0.1637877087924835,-1.2716200158636823,12.413263988126516,13.704746399187115,35.071336271323901,20.3677844475623,29.340411062458699,11.716825718904396,14.884747596886168,27.631281508596064,69.914432981731579,40.431827914683282,-11.971723632529525,10.369251782173272,-10.226179188481957,32.352580906027342,32.055326465844196,13.402340543882794,2.6697131649191306,1.9466977563561301,19.048159959323975,24.834765697177069,24.951096521543569,26.412611514003942,14.173317699369946,26.906758451007931,33.93003714721894,-31.809155079041851,48.321456108628439,40.956759693894455,40.956759693894455,15.572253090797709,21.015462374512104,4.3512956643498626,-1.8463320538051562,1.1314742382448628,36.800058813764622,36.761008729918615,29.466053569932612,21.979647135376624,49.399820989692557,49.850152011873575,null,14.628921691954105,null,null,2.1901629643247063,15.514041289264654,11.055723436487753,21.731090581676696,20.821234750416707,30.78613592396168,41.92400951725368,13.378740163732189,17.746418275125585,19.239284980770172,25.368390322404871,32.947182924523169,3.5826435035733724,-5.6192677523060226,-4.4041583643683211,0.85679540963457868,16.742604449919575,13.322099252748203,-8.874878900729172,21.083724426803528,24.764499361406621,30.036740506744323,55.64636940422276,8.5247919710358602,-8.4814968780944398,5.1192489849547584,1.2961276141552887,20.846797104192085,34.508334600739687,10.602609841949288,28.890559111223055,-7.5515582302797419,-14.578038875358541,4.230644765910661,null,35.941648948075382,38.212702263511638,38.979507221649733,1.3514866079778329,39.896710898341034,20.28637580175733,15.231714361398232,27.071290486730831,34.322088734838097,11.579949488141203,9.0102654628137984,6.4401678282221937,-14.109226065714935,-3.6825934602709367,17.124662242587007,36.074197880870997,47.512353072194998,39.279368670037002,null,23.224411728604743,-16.007264291197004,8.0115419780674983,8.839059487052296,28.820985504584193,26.172240405174975,14.861583465951668,23.911065054018543,45.076428404072949,40.949162593089206,24.111991830776709,0.82022483848860617,27.811184877554503,-19.975870814021334,-5.781133201230432,12.929372108966561,6.2983413407060596,54.05712009784726,41.479787283008463,39.931862755626454,12.607333632641136,18.975081139442132,27.519661582841231,2.9072841660596325,20.763326168679406,-16.832179895195893,45.37180937482271,17.265159259160207,-20.838453943863662,-8.4689045439984589,-9.2900850530471608,13.930197357158015,17.331405704862526,53.882544316939132,45.977332531881117,37.251061704075127,62.043661823254112,54.137644614105881,4.2178797500337559,-0.29820153488184431,17.986430511156559,21.555868870101758,null,null,null,57.361899815878374],"y":[-0.84721135999999997,-11.068448,10.930821999999999,22.658676,2.722261,1.5794973000000001,-0.99165577000000005,0.44460013999999998,3.1227182999999998,2.9611450000000001,4.9116426000000004,1.3944502000000001,5.3441552999999997,10.599935,-1.2655599,8.9391400000000001,4.1924744,14.412008,-4.6256184999999999,5.766451,10.926377,-1.3360552999999999,8.2111025000000009,3.9634258999999998,9.1933389999999999,-3.5737410000000001,2.0151940000000002,-1.7487258999999999,-0.14150447999999999,6.1252604000000002,3.9621230000000001,-1.1932959999999999,4.9946465,-2.4891272,7.7365339999999998,9.4154420000000005,4.2031830000000001,7.4463100000000004,7.7976150000000004,12.044140000000001,1.9785725000000001,6.8972563999999998,11.492023,0.17171226000000001,10.368104000000001,4.0211277000000001,9.6585859999999997,2.9371423999999999,14.013164,11.002666,3.7223055,10.461180000000001,14.262185000000001,7.2251763000000002,16.428352,4.8001604000000002,9.8511349999999993,3.0486042000000002,-4.7692889999999997,-0.13326122000000001,-8.1907759999999996,-16.041302000000002,-3.5594857000000002,-0.89852743999999996,1.6397678,5.3131640000000004,9.7948339999999998,4.3940663000000004,5.2452154000000002,17.518878999999998,25.225552,18.805554999999998,12.028112999999999,3.3218011999999999,23.146979999999999,17.509502000000001,3.5192296999999999,4.6578350000000004,3.5573990000000002,6.1395400000000002,19.278074,23.406683000000001,8.5884649999999993,10.500322000000001,17.174036000000001,18.137657000000001,-3.3494275,0.97157395000000002,8.327299,7.849316,-1.5526043,5.6540749999999997,11.145514500000001,6.8592553000000001,8.3248289999999994,9.2452839999999998,-3.8555869999999999,1.4067869,2.9094625000000001,-9.1247834999999995,0.54392160000000001,-1.6826441000000001,5.2588476999999996,11.068118999999999,14.902082999999999,11.737318999999999,20.723593000000001,14.863587000000001,-0.0085678509999999996,11.847588999999999,5.8983673999999997,-19.789455,10.6709795,-2.6223296999999999,3.0360863,1.7155704000000001,1.5154034999999999,6.8378715999999997,6.5777210000000004,25.883710000000001,12.630836499999999,24.367477000000001,31.182652999999998,18.466564000000002,16.980592999999999,-7.9188013000000002,2.7531560000000002,25.571943000000001,9.5078289999999992,2.3584394,3.763287,-6.99756,14.368081999999999,12.448251000000001,4.677753,0.41302070000000002,3.7242525,4.4539204000000003,11.681043000000001,4.034891,23.754852,6.4097586,16.097801,17.929392,17.880299000000001,9.0108689999999996,9.4530899999999995,-0.53994006000000005,-6.1144457000000001,-12.306062000000001,0.42866515999999999,22.370927999999999,30.958853000000001,16.247575999999999,39.134390000000003,10.679226,15.625496,-1.7204434,-5.5163096999999999,-6.8973240000000002,-3.2505804999999999,9.1140729999999994,3.4905192999999999,5.7271140000000003,13.211928,13.320055999999999,12.903103,7.6796490000000004,-0.40748679999999998,-2.8192732,0.55334799999999995,-11.107616999999999,9.2207550000000005,26.555070000000001,8.0705209999999994,3.4407386999999998,17.135244,6.9622406999999997,6.2874416999999996,6.0117399999999996,4.8737392000000002,3.8037763,2.6500010000000001,1.5574732,4.7638087000000002,3.940175,6.3995842999999999,9.8851410000000008,17.604664,27.569759999999999,-21.635505999999999,14.940227999999999,10.519033,3.3098635999999999,9.7435080000000003,0.19786145999999999,8.7114039999999999,1.8817638000000001,-3.2337440000000002,14.680027000000001,0.75519630000000004,5.1827535999999998,9.704034,3.6997805000000001,1.233962,11.494543,0.9602562,8.2617449999999995,4.7642045,-0.72616683999999998,19.064753,13.7184925,14.043172,1.6243216,0.69683050000000002,7.0586677,-1.19248,-2.1519408000000002,-0.8562478,2.2393698999999998,0.2335642,-10.0616255,-12.388954999999999,10.693942,24.753702000000001,4.7320140000000004,15.195838,10.820133,18.336355000000001,10.349951000000001,5.2898019999999999,-3.0604627,2.1932402,-4.0037326999999996,7.765962,3.4705572,0.38722985999999998,4.3944239999999999],"type":"histogram2d","zsmooth":"best","marker":{"line":{"color":"rgba(44,160,44,1)"}},"xaxis":"x3","yaxis":"y","frame":null},{"colorbar":{"title":"","ticklen":2,"len":0.14285714285714285,"lenmode":"fraction","y":0.5714285714285714,"yanchor":"top"},"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"x":[7.5014778259565418,-5.1338215892169572,13.41956665056334,22.57312856573094,-19.965704126284216,-2.9012063211618155,-30.979220536518419,-5.2385121802856176,-32.261481688259927,-15.876708779135825,-77.183080287394375,-17.211050817647724,-69.210233758201923,-50.656600733432839,54.717337354146267,48.333805389941276,-7.6173355041876825,-16.429816792344585,-20.701053297009892,-28.64059154029551,-6.1745968984469926,-28.560301276549382,-9.6911180642458987,null,null,-37.679165464907591,-39.058733776563585,-13.695706647959589,-11.592399827537186,-15.210519019248338,-13.520010980524059,-8.9068594012944882,-2.9477734550187904,-23.325853798457231,-30.177487635092202,-22.275707619391035,-52.948232440679888,-44.610272359895319,-24.606712169741613,31.072220181415879,-38.502581702030866,-23.182277080603669,-24.344849794209267,-1.9411228364699724,-66.735405478724715,-0.82120640101072695,-6.3155461153844215,5.3086820462876858,-10.245158605292374,-34.496538145160976,-35.794604205689978,-37.30744459822138,-37.521088565720582,-31.35965773294388,-52.574623479236791,-31.223643231583193,-42.885836918869991,-52.719327656273563,-31.301680461203169,-44.788046355831071,-32.946640752417863,-35.917929983801073,1.0801459258664323,-4.2122835153080658,null,-20.358261743961947,1.3936801003655432,-6.9188277272646559,null,-21.130657800964599,-1.14649773050769,15.959695814990809,16.096272128712883,29.479531607872886,6.2539587529258824,null,-88.748391393194268,-12.705289091986074,-18.431204754167666,13.490441929326323,-18.875363473391275,null,-30.749021144908909,-16.98759377780992,-21.836455634386908,-9.3367496303121058,-11.021097138090902,-44.72140885840335,17.000637395882094,-24.817256525673635,-12.989485638314832,-9.8695230326697327,-25.243034875905643,-26.022022055535906,-37.957730707409183,-35.887700054368082,-12.015435217537483,-8.2705490682154839,-41.056473583402905,-15.846916834553106,-30.782135587627703,-19.466382107066504,16.940236045681662,11.085042864711564,14.380490073397382,-23.215766459796125,-4.1456483804773256,-12.943059090468424,null,-49.793914541925162,-38.230131835813161,-35.900293738496956,29.159363614552198,null,9.1589972927871202,-19.561565477613925,-35.078047486546417,-1.1102148002732264,-65.69504884207376,-13.776082688291851,25.465135048367955,21.546209404529947,-52.369027854630446,-27.383983180254248,-35.967950753871747,14.540668104830445,null,19.892051177549014,-7.6812603056071396,-2.0690918790681394,-1.6231257267691319,-70.367728926056088,-29.795545377256083,-27.494988606563282,-20.48399480816348,-73.007991668726916,39.810281768344566,-79.065150146070394,null,-38.278285583822154,null,-3.7375878446109425,-7.04469714540231,18.165165335775683,22.877478890306705,45.080319203499684,6.3354938749801875,-19.711127103412213,-15.176006844268827,-32.826131064198925,-43.778388718166724,1.7314165364402783,-2.6864306838059235,-7.9693312878571234,-15.449041284306119,-9.2213772499894233,-77.313870874377002,-22.980422200457397,-19.420106163256875,null,-21.581411313509975,9.6246439110789339,-21.059806159588341,13.034637690528157,-33.723463570191569,-29.987896275054641,-5.8009775853049135,-19.712114898492416,-5.197397698384016,18.699887198247687,-32.086926730538863,0.082548111317855444,-13.107936264386844,13.85007939398966,-30.535111963510904,null,-48.783668205526496,-41.190849444288659,-19.199298176782762,-16.598405439388369,12.46210832112093,2.737225524060193,-15.723961632936501,-54.527548203832204,-28.373212425519306,1.9086011974582675,-2.0448248790112302,-59.886948090731387,-34.02945023769589,4.0742032533607073,-22.521971921982797,-35.547124073767456,-15.498606603866957,-23.903433552494455,-14.670240602274802,-19.281515563478703,-24.487068702052902,-33.949114075120427,-23.384519112126625,-62.682676822558818,-44.782343303652169,-7.9756624092839488,-35.39895921736165,-7.8198670313695899,-1.5536327744973946,-26.714931055164893,-15.295257432235893,-56.387935217545305,-22.903218805762236,-25.377463311029537,4.3334606720455611,-18.659485105657545,-23.314642944554343,-10.260445957731037,-24.893253659483541,6.4545779996282349,-10.502093343015169,-6.3544718188235692,-30.255549602950797,-25.977415996560197,-49.567406167303496,-36.502184630456199,null,-11.671869931824162,-8.2633592017534596,-20.22278697766976,-19.25613970213908,-9.3217028626718772,1.5231772645855202,46.488814612015119,57.917531859638117,64.856293234627131,47.241290327196126,-34.567085957905519,-7.5409061714854424,-17.072758324706843,-0.72501210437764385,32.0770362805047,39.013492232159706,-28.125901582046922,-9.817819590489016],"y":[4.3419460000000001,0.27631694000000001,13.29541,11.436946000000001,1.5303929999999999,3.3774023,2.5306334000000001,3.1495655,12.859593,-1.9358268999999999,0.77607219999999999,0.15881435999999999,-0.22485004,4.8210940000000004,-10.581054999999999,4.9492992999999998,38.837643,25.235046000000001,-1.0107094000000001,4.8559136000000001,2.1779597000000002,-7.5966715999999996,11.994374000000001,2.0855549999999998,-1.1319675,7.930491,-1.4839648999999999,-3.5426593,0.79226947000000003,-0.106339715,1.1996967000000001,-0.80553189999999997,-3.1018279,2.4706573000000001,-2.3409781000000001,4.1666613000000003,3.4379396,6.9612045,8.0938350000000003,4.0970006000000003,-1.2961893,9.5061689999999999,3.2225679999999999,1.5968336999999999,9.7595419999999997,9.0685730000000007,5.3197125999999999,-11.652297000000001,0.97167230000000004,5.7144979999999999,4.1368960000000001,11.453106,12.2663145,9.4445069999999998,3.6793892000000001,6.8590197999999996,2.6666143,5.4794846000000001,-0.49137035000000001,-1.4587079000000001,3.889059,12.026723,-8.951003,7.3802050000000001,2.8099569999999998,-10.956512999999999,10.155844999999999,2.6048054999999999,14.856211,15.109928,15.824087,16.905176000000001,-0.68462710000000004,31.628005999999999,4.5972776,16.100556999999998,9.0227310000000003,5.6205080000000001,3.9510288,9.2102830000000004,0.041699022000000002,13.565664,20.918184,21.705425000000002,2.6141746000000001,23.877376999999999,7.1509020000000003,18.709230000000002,-0.13252043999999999,3.1113789999999999,-1.5844259999999999,7.8015122000000003,1.9354852,1.0697296000000001,7.9228959999999997,13.540675,5.7597847,14.805539,1.9774058999999999,-0.46393269999999998,8.0962940000000003,12.569623,-19.380414999999999,9.168075,12.245198,2.6663477000000002,4.7240405000000001,3.7599735000000001,8.2055530000000001,18.629719999999999,8.9363880000000009,1.8317140000000001,7.549893,-7.1806159999999997,-6.4954723999999997,-1.5855007999999999,-4.1258059999999999,11.745105000000001,-2.1231035999999999,1.8412310999999999,4.5523676999999996,5.9089184000000001,6.0566000000000004,18.901546,-3.6629681999999999,20.995481000000002,13.042688,10.870957000000001,-15.575298,-2.0256118999999999,7.319604,-0.35553306000000001,3.1141390000000002,6.1736984000000001,11.437675,12.810805999999999,14.927396999999999,1.6622139,4.8495799999999996,8.1052669999999996,24.649709999999999,4.5482659999999999,14.088488999999999,-1.3070786000000001,17.228401000000002,20.114832,3.7856312000000001,6.3072375999999997,14.741607,2.7709693999999998,8.709384,3.6795241999999999,10.480732,10.688186,2.3865411000000001,0.95471839999999997,8.4415980000000008,1.7697896,0.66217095000000004,20.282897999999999,-10.466161,9.8673500000000001,13.451419,5.4750529999999999,-0.60118364999999996,-7.5322595000000003,5.5162982999999999,1.6638541,13.630190000000001,1.8531154000000001,5.5282289999999996,-15.2281885,-14.645001000000001,11.248177,25.167729999999999,15.352379000000001,-1.1883836999999999,4.7228317000000004,0.37642908000000003,1.5073953,1.6710552999999999,6.284459,0.25870144,1.8714997,6.2034406999999998,2.4472458000000001,5.8373523,12.4414015,14.074534999999999,11.825348999999999,23.979424999999999,6.0931753999999998,8.7295350000000003,7.4145054999999997,3.9624733999999999,6.1452723000000002,-5.3055719999999997,8.6725680000000001,-1.3963213000000001,3.811855,2.8894882000000002,5.6902122000000004,15.118186,-3.6117492000000002,-2.3905313000000001,-0.56152004,3.0780728000000002,7.8547916000000004,3.5594834999999998,4.8214990000000002,7.5329949999999997,-0.13647100000000001,10.355214,5.1796426999999996,8.2922010000000004,6.1330441999999996,-3.5128455000000001,7.3700330000000003,0.2289707,0.48594502000000001,-0.11204386500000001,-3.0408778000000001,-4.4659709999999997,-7.4609075000000002,-5.9470695999999998,3.349437,12.714460000000001,-4.7857539999999998,2.7999597000000001,10.753154,-0.43903086000000002,3.1280709999999998,12.376604,14.428908,2.7297463,-4.1616572999999999,-3.7811313000000002,2.5098813,9.066675,-3.6099887000000002,-0.63500489999999998],"type":"histogram2d","zsmooth":"best","marker":{"line":{"color":"rgba(214,39,40,1)"}},"xaxis":"x4","yaxis":"y","frame":null},{"colorbar":{"title":"","ticklen":2,"len":0.14285714285714285,"lenmode":"fraction","y":0.4285714285714286,"yanchor":"top"},"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"x":[-37.780669036797555,13.716324898786141,23.279011098342451,45.278460943615244,-24.851614298135917,-37.059243358546759,-7.2102862651001161,-7.9692244477669192,-55.908201652159022,-23.214750272843325,-39.759847789943123,16.777960313472974,-93.385979078774227,-75.778769449355536,-18.058480353919734,58.335216206697268,9.5877735925169176,12.208944799484613,-26.10451689132622,-32.786629198919904,-8.242594023105994,-31.867435596581142,-17.869846448947996,null,null,-32.262387488117689,-18.744151036361991,-41.350936036268692,-8.9740296319901915,-11.023055284757788,-9.1305512391826884,-15.666346477665059,-2.3611099715739883,-34.128229987639862,-17.379972333135633,-10.160081015367332,-57.286035593163845,-25.827088758922514,-32.409601821792016,-31.276623663958915,-39.629299337975866,-38.394230214018471,6.0015635976829316,-13.934490449531069,-86.542271229167426,1.3699743910239732,8.7725099067262846,9.2073823271655755,-38.901112766629858,-18.676253335461777,-3.6889756733147792,-37.336742231377684,-39.633072284643049,-42.921350255906923,-32.655065526571278,-47.047083327580623,-38.818415804482491,-45.363275031663072,null,-17.298949825980365,-23.476543130736765,-28.31689581489767,-38.110070986206566,-15.034658104284169,null,-19.260733108000949,-42.088531024141254,1.5436612070805467,-84.932216577699748,-15.747225593415592,-12.042432032798487,1.593681136063708,null,33.765995427696879,47.527767414152891,-57.987622904459791,5.2998177400148307,27.26225496793333,23.717838082692325,-26.224054013649067,-64.258528829493116,-64.081681761792112,-18.768449289617919,-4.2405583736419032,-38.665939115021104,-28.603134694140405,-23.918886995066803,4.3932471402693949,-40.021047613336954,-12.671679097522933,-8.8073715191587354,-10.055286030139605,-31.424414039769534,-36.793342667285302,-35.887700054368082,-28.655675996110361,null,-40.828067109772704,-37.336239166494607,-30.021527312411102,-23.804897177623005,null,-21.171642511888535,41.821785690554265,9.522138562111472,-4.1194970142112268,-16.525133777781924,null,-52.315407470057558,-40.596830275930756,-39.832208279323282,-21.63517053794201,-12.629310341433069,6.4011101640791281,-29.844157520393026,-34.201477770749442,-28.291757236760425,-105.97142307315019,-46.246235238857253,-12.36303806356716,20.708922536082952,-46.841366494140146,-62.184955483121044,-9.5685537000060492,29.765609244564445,1.3619699454758631,-10.375770097767145,2.3586435931088658,-58.075049653497182,-5.2088278930526855,-43.928808156940782,-40.592737315196182,-72.551416890090593,-42.539544327113731,null,null,-13.099636055400543,0.30625787206520627,-2.3795866671576924,-15.886042918565643,-25.954330878141604,-6.7121132425183134,31.219291640477692,-6.1860649909303049,1.0606432131092873,-13.045576468166114,-30.183934195594325,-28.131326125534624,-2.4708371541712211,10.588951297279877,3.7879925054516761,6.2395285599777779,-7.8348519375624193,-3.6380757878746195,-79.908910647620104,-42.211258196652501,-22.870602022148674,-35.58681720290997,-12.503612649861672,18.880084149377922,-41.023250438089541,-36.394015490291949,-40.563053270110849,-30.630358276794141,-17.661385564536815,-15.194756352572213,14.434689302742882,10.646286063493086,8.0540903801979553,-17.68314110336734,-21.741849765369043,15.011503751440259,-19.232259160715422,-28.686826834431272,-43.173190593153763,-46.707280326322262,-14.124832123280068,0.4020923309795279,9.6948037696576321,-30.937558033088905,-22.241180367105201,-25.016049646741905,-27.655009212176402,13.134633679393062,3.2481128280777654,-74.114422809704095,-1.7018393959899925,-66.159988029484992,12.824142004854011,-36.660176504435604,-41.570171665109839,-19.036182970157956,8.7834055176560994,-32.257996586198502,-64.089500171799415,-37.809621819303231,-36.937313552764827,-45.183104318742259,-33.025753005287349,-30.913656218438849,-45.339503710620392,-19.10834749416189,-27.22848723443969,-11.399053636189375,-60.383658803101568,-22.109111292635937,-29.813721780054536,-6.057600644399237,-34.527635879062444,-30.605745739113544,-52.82724490299384,-8.6387455867057383,-36.150182541493635,-50.368600751236073,16.628502078327124,5.3283521727875254,null,5.1922088760310317,-47.489035921941529,-42.816866705124525,-40.821243904748286,-39.159694854813395,-27.549272455432579,-11.551566924575859,-18.606467555549461,-21.79706857095616,null,-18.593934384134478,10.052826784587218,56.087809754009115,42.497770565173127,43.614575660652122,31.667289489949127,-15.772929808004321,-15.217096718926662,-13.396016194764133,-18.420865192569583,5.1573937540134587,null,19.267279340579705,15.256138008302251,-5.2970561621715504],"y":[19.313965,0.60212200000000005,14.49414,-6.2111305999999997,1.3486590000000001,10.442211,3.1030525999999998,-13.418872,7.5442666999999997,1.4526684000000001,5.7627160000000002,0.72215050000000003,7.5624180000000001,8.1001650000000005,-0.81923615999999999,7.1169285999999996,14.391463,15.326316,-0.23792352,11.193483000000001,-3.366641,13.410192500000001,32.071404000000001,9.9889060000000001,11.545024,7.6185403000000003,2.1858504000000001,10.627872,-12.264523499999999,1.662374,-3.1481819999999998,5.7253299999999996,-0.39579006999999999,13.095076000000001,-5.6509603999999998,2.8107324,-1.2615689000000001,3.0925189999999998,10.303894,11.370352,9.6154030000000006,7.2338896000000004,9.2748574999999995,10.378494999999999,6.1620549999999996,21.167214999999999,6.0081810000000004,13.362579,2.6149583000000001,2.1038065000000001,6.5780089999999998,11.648524,14.502340999999999,13.746460000000001,21.229153,5.1588716999999997,6.0799709999999996,2.0886786000000002,-0.54264133999999997,5.9880614000000003,12.878586,4.645556,2.0478689999999999,4.2143483000000002,15.016263,8.7835889999999992,4.7295775000000004,8.3210949999999997,25.176349999999999,20.469930000000002,31.953537000000001,13.697884,3.8861656,9.5033130000000003,1.869165,28.020762999999999,6.1905264999999998,3.4338573999999999,4.7945399999999996,-0.57354110000000003,18.936619,28.658940000000001,33.845649999999999,4.2344384000000002,3.6004225999999999,5.9022864999999998,9.3371870000000001,9.4952279999999991,-7.9907311999999999,-2.9844773,10.644992999999999,2.1507882999999999,6.1272039999999999,8.7195429999999998,5.3705040000000004,8.7094749999999994,2.7219815000000001,0.91596869999999997,16.041193,14.763261999999999,1.4299508000000001,16.351942000000001,11.590873999999999,6.8057404000000004,7.3913060000000002,20.391047,9.0413080000000008,6.1056436999999999,12.207734,26.907202000000002,8.4143380000000008,8.683548,-0.91003239999999996,3.4853325000000002,4.9090132999999998,-8.6568959999999997,3.3871186,0.74237799999999998,5.8511924999999998,3.3422092999999999,3.1439222999999998,16.348972,11.679128,17.775434000000001,10.459463,-4.9699479999999996,0.72325410000000001,4.7657366000000003,6.3084517,11.040906,10.797606,10.238457,0.45327034999999999,12.845241,13.3303175,12.0545635,11.243843,7.8661393999999998,6.6220949999999998,14.5724745,1.3621555999999999,14.692432,16.3294,7.8880423999999998,8.0570544999999996,6.7966924000000004,32.339745000000001,4.1938849999999999,-1.6725124,1.4550812,-10.796239999999999,2.8331525000000002,12.105276999999999,28.756326999999999,24.705233,-0.86059039999999998,6.2602696,14.119379,4.4997167999999999,12.060157,13.557914999999999,4.0036826000000003,13.594447000000001,-8.5726099999999992,7.9806347000000004,5.129645,14.446158,8.0071519999999996,2.121264,-4.3357169999999998,2.0830462000000001,2.8476111999999998,20.506681,19.792683,7.1661339999999996,2.4855797000000002,2.1331755999999999,-2.4154680000000002,2.6719618000000001,5.7323903999999999,3.910075,6.1441053999999999,-3.8995625999999999,0.64334570000000002,1.7845773,24.16611,8.9987980000000007,14.794198,6.3778977000000001,5.5557920000000003,5.9733352999999996,10.361222,9.3108989999999991,9.4641129999999993,1.7674171000000001,-2.5923417,6.6753235000000002,11.297435999999999,13.398262000000001,2.5934699000000001,24.067709000000001,14.324350000000001,17.924156,8.4275509999999993,8.1299530000000004,6.3195430000000004,9.937621,8.735811,3.1434228000000002,-2.0355097999999998,19.223482000000001,7.3927946000000002,12.501598,1.9107772999999999,4.5092359999999996,-0.37223339999999999,10.112190999999999,5.7386499999999998,-0.62740295999999995,5.3452387000000003,-2.1990699999999999,-8.7255640000000003,-1.3090241,-13.055191000000001,8.4013089999999995,-3.4089138999999999,5.4124626999999998,11.312541,-2.2324860000000002,7.3011074000000002,9.8566699999999994,4.9523663999999998,10.910171500000001,10.892757,1.2092471,2.9673834000000001,1.0779401,2.1940521999999998,8.6225100000000001,7.6411619999999996,16.465161999999999,2.8169696000000002],"type":"histogram2d","zsmooth":"best","marker":{"line":{"color":"rgba(148,103,189,1)"}},"xaxis":"x5","yaxis":"y","frame":null},{"colorbar":{"title":"","ticklen":2,"len":0.14285714285714285,"lenmode":"fraction","y":0.2857142857142857,"yanchor":"top"},"colorscale":[["0","rgba(68,1,84,1)"],["0.0416666666666667","rgba(70,19,97,1)"],["0.0833333333333333","rgba(72,32,111,1)"],["0.125","rgba(71,45,122,1)"],["0.166666666666667","rgba(68,58,128,1)"],["0.208333333333333","rgba(64,70,135,1)"],["0.25","rgba(60,82,138,1)"],["0.291666666666667","rgba(56,93,140,1)"],["0.333333333333333","rgba(49,104,142,1)"],["0.375","rgba(46,114,142,1)"],["0.416666666666667","rgba(42,123,142,1)"],["0.458333333333333","rgba(38,133,141,1)"],["0.5","rgba(37,144,140,1)"],["0.541666666666667","rgba(33,154,138,1)"],["0.583333333333333","rgba(39,164,133,1)"],["0.625","rgba(47,174,127,1)"],["0.666666666666667","rgba(53,183,121,1)"],["0.708333333333333","rgba(79,191,110,1)"],["0.75","rgba(98,199,98,1)"],["0.791666666666667","rgba(119,207,85,1)"],["0.833333333333333","rgba(147,214,70,1)"],["0.875","rgba(172,220,52,1)"],["0.916666666666667","rgba(199,225,42,1)"],["0.958333333333333","rgba(226,228,40,1)"],["1","rgba(253,231,37,1)"]],"showscale":true,"x":[12.431439003019548,-14.293028658424056,26.101654844323946,22.799446274287945,-32.872850732963698,-32.872850732963698,-30.798477352109416,-28.907322650424014,-50.869042767697124,-72.069909048299564,-16.581327907293428,-49.419235683477424,-24.484335579230631,-88.346875353256436,47.847672183068269,45.991939635434264,0.93652457396671451,-5.184377347427386,-34.166827506321681,-2.0494863019768914,-20.81093859352999,-20.360686333492392,-37.100964650650496,null,null,-40.207110107088994,-46.552290746541189,-44.776859738571389,-34.251751867543092,-15.43832673468776,-9.1305512391826884,-2.044873910911889,-6.7924953800815882,-31.611303309334524,-34.59203925661464,1.2135359243828674,-20.341378371840033,-30.357548572069316,5.1867289070795906,-58.454474344257768,36.61917341747958,-36.018498590243567,-22.323563085660069,-21.012098870638368,-1.8316204920216705,-4.0026270373838173,0.90823722259797535,5.3942818258331755,-1.1653593358498142,-31.311470120653976,-40.037784644228637,-29.855683421520578,-26.213197046304675,-29.161091013844981,-40.150490726125497,-40.360679565937829,-24.590992770713179,-52.574623479236791,-47.276058409336855,-45.677195921485044,-44.813567859494171,-29.827757535131866,-22.501704188395465,-20.381837181524965,-3.5673094415574695,0.56972932157773215,-74.498400291290949,-29.277317226981253,-77.683785868813345,-1.5938475683594504,-30.201292203780795,-7.0062250546569942,-12.005389348764098,2.2793362119847131,null,-14.637801386375116,26.335003873875891,-82.499511284715339,-2.616912608230777,-15.681890337021571,3.1716568198192334,-18.15130216353397,-69.816819135397012,-121.87415397854511,-40.23486378655312,-33.492983305960919,-33.1260884771729,-42.899493411404485,-6.3683467631475068,-24.614467786251303,-10.376063102140236,null,-14.521486877401035,-29.640889299270196,-30.330139730252714,-24.090833877914683,-37.957730707409183,-23.085518653653281,-10.953640004649483,-36.990500611755301,-44.101512778229534,-31.770612512846203,-39.0701756945856,null,-8.2591931556715359,null,-17.222773208542925,-18.575714073572023,null,-35.833354466639861,null,-35.640415064132661,-42.7790717551459,-5.2484452255722687,-2.7055302258384728,-30.655288489171724,-32.054496059636662,-26.635855521112127,-20.56039237275435,-28.116343492019254,-5.7871163899180544,8.7242917562089417,-53.325289647664448,-14.592831052932155,3.2014001942629449,34.539688573441452,-4.0962501347551381,7.0310328035258465,3.3954702205798526,-50.945424941417684,-25.444054823435678,-28.195546408204585,-27.942182390613681,null,0.078266245071972662,null,1.3442063798890089,-5.7662198524355404,6.0051333900456996,35.408123283905681,37.166154694451691,9.1908968668666944,-3.0537049314006168,-25.774351730795114,-30.733803978300923,-41.695907692226825,24.91841340809507,-18.530607483129224,-7.4644344396983229,4.2188499916115845,-3.5135500202604248,-15.616013192216123,-66.995809965692104,-51.019041342136902,-40.827659992713272,-45.559435461415276,-44.332278294318968,7.0436654532027205,-33.641432016169659,-36.14397665508281,-17.854863284592042,-38.24183676881438,-4.3145642377157145,-13.346968546358514,1.1376979184356841,-8.8223581039275132,-3.8396731839933409,-22.369492615913842,2.7067758666278579,7.3237036178082562,-28.982729959932293,-32.130102886906627,-39.283410521390564,-11.556279691684871,5.4675309253437945,-22.220213748950101,12.638797618250202,-23.802854733041602,-3.839138916391434,-9.8611939921566361,-57.271824467876392,-63.992325262922591,-33.626422605141791,1.2563501400087063,-30.106881454186258,-14.942123504607355,-2.1653255506898574,-38.471107297284405,-29.990765417918102,-51.238300059867328,-65.683840590817852,-43.376104871686231,-31.093416493023049,-12.358590633306854,-35.056546509177394,-40.87500296935459,-29.387156815757393,-28.87467603145469,-28.031555718469512,-43.558704461079635,-41.625141041602632,-9.6855553567401316,5.5713421257599691,null,-48.77835308256558,-42.150889220298041,-17.53177422419904,-43.13845834262704,6.6971797678082297,6.5664185285256238,12.607333632641136,19.237422618912127,-33.528161168268397,-42.442389818401693,-48.417043105973832,-48.87434586459225,-44.039866015647327,-22.645174796355761,-23.576008074212261,-3.9277927507883597,-27.03030145351266,null,22.892343870284627,4.8113849874079264,70.491281072228119,48.631883582849127,38.698637538502126,50.436787171088127,-11.960858450804944,null,-20.739296924667872,-2.9820053353380445,55.642080631195711,24.096818734590698,-6.3754637520015507,-8.8689184601987563],"y":[9.599945,7.5136193999999996,23.479946000000002,1.87483,13.033454000000001,14.907605999999999,6.7764892999999997,8.6977449999999994,7.3710355999999999,5.9522567000000004,5.0807529999999996,6.0322164999999996,-0.4893806,9.0655249999999992,3.407823,-4.0940064999999999,19.826350000000001,25.499196999999999,10.446391,3.7857064999999999,12.870358,11.120075,39.421314000000002,12.691807000000001,2.5776694,9.8014749999999999,-3.2642093000000001,-3.0032348999999998,-5.6817802999999998,0.79876846000000001,2.0143523000000001,5.3393291999999999,10.284663,4.7088165000000002,7.1484670000000001,2.1655421000000001,-4.7009540000000003,11.919326999999999,7.8909326000000002,9.5015429999999999,6.8666799999999997,1.5467706000000001,4.9872794000000003,13.801392999999999,14.751462999999999,11.730715,9.1221160000000001,4.7865843999999997,-5.6371655000000001,1.2209148000000001,5.0779386000000004,19.034493999999999,12.770549000000001,7.3097469999999998,11.716509,16.267572000000001,9.7934009999999994,5.0827116999999999,4.6375523000000003,12.790532000000001,5.2454095000000001,6.9721640000000003,2.633451,7.7810072999999997,7.7929596999999999,0.89330399999999999,4.902228,1.9115432999999999,10.181884,18.630053,25.686762000000002,19.198338,31.300412999999999,6.7507485999999997,21.424292000000001,8.1178310000000007,10.036973,27.904012999999999,5.5032500000000004,6.3113390000000003,8.507676,3.0656406999999999,23.997595,16.390094999999999,49.100389999999997,39.902264000000002,17.318134000000001,5.7871560000000004,8.4506940000000004,5.0328020000000002,6.5339822999999999,6.0387000000000004,12.925732,5.1332307000000004,3.9145093000000002,7.8508690000000003,9.3255389999999991,3.4312444000000002,1.5585845,0.15661070999999999,3.8711373999999998,11.377242000000001,16.97353,-5.0062319999999998,2.7485827999999999,17.801767000000002,14.091794999999999,10.528816000000001,16.651892,23.946470000000001,24.078112000000001,4.4808279999999998,-4.7088966000000001,6.4793304999999997,-11.445137000000001,12.297048,5.5331353999999999,-2.4143998999999998,-1.9835924,0.18446119,4.8604827000000004,-5.3580379999999996,5.6870510000000003,19.378499999999999,24.977353999999998,42.857098000000001,1.7946641000000001,-17.750565000000002,2.8833343999999999,10.586073000000001,10.117179,1.4824090000000001,5.4815930000000002,8.5190289999999997,0.30435497,-2.0327790000000001,3.6911893,13.496489,2.9995015,6.4523807,8.0137809999999998,17.625895,11.477741999999999,5.2361930000000001,9.694782,-0.86537929999999996,-5.7755419999999997,-2.5093429999999999,31.352993000000001,8.7345009999999998,16.824133,25.747523999999999,3.134843,17.417290000000001,8.3424189999999996,16.511972,8.6264540000000007,2.8216237999999998,11.269747000000001,10.3524475,1.5459303,-1.8088871,12.711016000000001,14.514132,15.852706,3.8069362999999998,1.6725409,-1.9383192,3.8951568999999999,10.936769999999999,32.83728,16.424424999999999,13.664807,5.4934586999999997,2.6454048000000001,1.8312953999999999,5.3645779999999998,1.7367033999999999,5.6270889999999998,2.0167277000000001,23.014299999999999,17.028282000000001,26.042380000000001,16.13363,6.8068204000000003,8.0121310000000001,5.8119415999999999,-1.7936432,18.96077,3.1180479999999999,-1.2868108,-3.4148626000000002,2.6968613000000001,10.632186000000001,20.195974,19.554867000000002,2.7743812000000001,10.80626,6.3271704,5.7118716000000003,11.545787000000001,10.093799000000001,0.75607765000000005,4.0051103000000001,-2.4419689999999998,12.766938,3.5520271999999999,7.591907,-1.2437697999999999,3.1610996999999998,15.318097,2.5104673000000002,7.2700060000000004,-0.28563827000000003,-5.3438262999999999,3.1388275999999999,3.936585,-6.5154920000000001,-7.1329564999999997,5.3756022000000003,-2.2072923000000002,18.339435999999999,5.8922577,24.030166999999999,4.0387683000000001,8.4324539999999999,2.4540042999999998,7.0756373000000004,-2.6435065,-2.3027673000000002,-1.5583435000000001,-1.9639168,10.597383499999999,3.41804,2.3618006999999999,-5.1404969999999999],"type":"histogram2d","zsmooth":"best","marker":{"line":{"color":"rgba(140,86,75,1)"}},"xaxis":"x6","yaxis":"y","frame":null}],"layout":{"xaxis":{"domain":[5.5511151231257827e-17,0.14666666666666672],"automargin":true,"title":"low_stim high_cue","anchor":"y"},"xaxis2":{"domain":[0.1866666666666667,0.31333333333333335],"automargin":true,"title":"med_stim high_cue","anchor":"y"},"xaxis3":{"domain":[0.35333333333333339,0.47999999999999998],"automargin":true,"title":"high_stim high_cue","anchor":"y"},"xaxis4":{"domain":[0.52000000000000002,0.64666666666666672],"automargin":true,"title":"low_stim","anchor":"y"},"xaxis5":{"domain":[0.68666666666666676,0.81333333333333324],"automargin":true,"title":"med_stim","anchor":"y"},"xaxis6":{"domain":[0.85333333333333328,1],"automargin":true,"title":"high_stim","anchor":"y"},"yaxis":{"domain":[0,1],"automargin":true,"title":"NPSpos","anchor":"x"},"annotations":[],"shapes":[],"images":[],"margin":{"b":40,"l":60,"t":25,"r":10},"hovermode":"closest","showlegend":true,"legend":{"yanchor":"top","y":0.1428571428571429}},"attrs":{"4a841b3e1c9e":{"x":{},"y":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"histogram2d","zsmooth":"best","inherit":true},"4a84ac8d70b":{"x":{},"y":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"histogram2d","zsmooth":"best","inherit":true},"4a8479e18b5":{"x":{},"y":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"histogram2d","zsmooth":"best","inherit":true},"4a841c6816fb":{"x":{},"y":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"histogram2d","zsmooth":"best","inherit":true},"4a8475bcc74e":{"x":{},"y":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"histogram2d","zsmooth":"best","inherit":true},"4a843cc10e45":{"x":{},"y":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"histogram2d","zsmooth":"best","inherit":true}},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"subplot":true,"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```


```r
# save tsv
test = ses1[, c("sub", "cuetype", "stimintensity", "EXPECT_demean", "NPSpos")]
write.table(test, file='/Users/h/Downloads/test.tsv', quote=FALSE, sep='\t', row.names = FALSE)
```

#### 3x3 plots EXPECT_demean {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_smooth()`).
## Removed 1 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-68-1.png" width="672" />


```r
fig.height = 50
fig.width = 10
ggplot(aes(x=EXPECT_demean, y=NPSpos, color = CUE_high_gt_low, shape =), data=demean_dropna) +
  geom_smooth(method='lm', se=F, size=0.75) +
  geom_point(size=0.1) + 
    # geom_abline(intercept = 0, slope = 1, color="green", 
    #              linetype="dashed", size=0.5) +
  facet_wrap(~ses) + 
  theme(legend.position='none') + 
  xlim(-50,50) + ylim(-50,50) +
  xlab("raw data from each participant: n-1 lagged outcome angle") + 
  ylab("n current expectation rating") 
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 420 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: The following aesthetics were dropped during statistical transformation: colour
## ℹ This can happen when ggplot fails to infer the correct grouping structure in
##   the data.
## ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
##   variable into a factor?
## The following aesthetics were dropped during statistical transformation: colour
## ℹ This can happen when ggplot fails to infer the correct grouping structure in
##   the data.
## ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
##   variable into a factor?
## The following aesthetics were dropped during statistical transformation: colour
## ℹ This can happen when ggplot fails to infer the correct grouping structure in
##   the data.
## ℹ Did you forget to specify a `group` aesthetic or to convert a numerical
##   variable into a factor?
```

```
## Warning: Removed 420 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-69-1.png" width="672" />

#### NPSpos \~ EXPECT_demean \* STIM \* CUE {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 7 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 7 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 7 rows containing non-finite values (`stat_smooth()`).
## Removed 7 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 3 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 3 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 4 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 4 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 2 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 2 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 3 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 3 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 3 rows containing non-finite values (`stat_smooth()`).
## Removed 3 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 5 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 5 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 3 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 3 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 4 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 4 rows containing missing values (`geom_point()`).
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-70-1.png" width="672" />

## 9. NPS \~ trial order


```r
pvc$run_num = as.numeric(as.factor(pvc$run))
pvc <- pvc %>%
  dplyr::group_by(sub, ses, runtype) %>%
  dplyr::mutate(mean_run = mean(run_num))
# compared to mean_run, is the run_num smaller or larger?
pvc$formerlatter_run <-
  ifelse(pvc$mean_run >= pvc$run_num , "former", "latter")
pvc$ses_run <-
  interaction(pvc$formerlatter_run, pvc$ses, sep = "_")
NPStrialorder = pvc
```


```r
NPStrialorder$ses_run <-
  interaction(NPStrialorder$formerlatter_run, NPStrialorder$ses, sep = "_")

NPStrialorder$ses_run_trial <-
  interaction(NPStrialorder$trial,NPStrialorder$formerlatter_run, NPStrialorder$ses, sep = "_")

NPStrialorder$ses_run_num <- as.numeric(as.factor(NPStrialorder$ses_run))
NPStrialorder$ses_run_trial_num <- as.numeric(as.factor(NPStrialorder$ses_run_trial))
```


```r
data.frame(table(NPStrialorder$ses_run_trial_num ))
```

```
##    Var1 Freq
## 1     1  320
## 2     2  320
## 3     3  320
## 4     4  320
## 5     5  320
## 6     6  320
## 7     7  319
## 8     8  319
## 9     9  319
## 10   10  319
## 11   11  319
## 12   12  319
## 13   13  305
## 14   14  305
## 15   15  305
## 16   16  305
## 17   17  304
## 18   18  304
## 19   19  303
## 20   20  303
## 21   21  303
## 22   22  303
## 23   23  303
## 24   24  303
## 25   25  268
## 26   26  268
## 27   27  267
## 28   28  267
## 29   29  267
## 30   30  267
## 31   31  267
## 32   32  267
## 33   33  267
## 34   34  267
## 35   35  267
## 36   36  267
## 37   37  260
## 38   38  260
## 39   39  260
## 40   40  260
## 41   41  260
## 42   42  260
## 43   43  260
## 44   44  260
## 45   45  260
## 46   46  260
## 47   47  260
## 48   48  260
## 49   49  266
## 50   50  266
## 51   51  266
## 52   52  266
## 53   53  266
## 54   54  266
## 55   55  266
## 56   56  265
## 57   57  265
## 58   58  265
## 59   59  265
## 60   60  265
## 61   61  254
## 62   62  254
## 63   63  254
## 64   64  254
## 65   65  254
## 66   66  254
## 67   67  254
## 68   68  254
## 69   69  254
## 70   70  254
## 71   71  254
## 72   72  254
```

## pain  {.tabset}

### trial order \* cue {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-74-1.png" width="672" />

### trial order only {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-75-1.png" width="672" />


```r
model.trial = lm(NPSpos ~ trial*cuetype, data = NPStrialorder[NPStrialorder$runtype == "runtype-pain",], )
Anova(model.trial, type = "III")
```

```
## Warning in printHypothesis(L, rhs, names(b)): one or more coefficients in the hypothesis include
##      arithmetic operators in their names;
##   the printed representation of the hypothesis will be omitted

## Warning in printHypothesis(L, rhs, names(b)): one or more coefficients in the hypothesis include
##      arithmetic operators in their names;
##   the printed representation of the hypothesis will be omitted

## Warning in printHypothesis(L, rhs, names(b)): one or more coefficients in the hypothesis include
##      arithmetic operators in their names;
##   the printed representation of the hypothesis will be omitted
```

```
## Anova Table (Type III tests)
## 
## Response: NPSpos
##               Sum Sq   Df  F value Pr(>F)    
## (Intercept)    15866    1 155.5842 <2e-16 ***
## trial           1161   11   1.0349 0.4118    
## cuetype          117    1   1.1442 0.2848    
## trial:cuetype   1121   11   0.9996 0.4438    
## Residuals     632766 6205                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
summary(model.trial)
```

```
## 
## Call:
## lm(formula = NPSpos ~ trial * cuetype, data = NPStrialorder[NPStrialorder$runtype == 
##     "runtype-pain", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -53.242  -5.531  -0.861   4.469  81.517 
## 
## Coefficients:
##                                    Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                        7.568215   0.606751  12.473   <2e-16 ***
## trialtrial-001                    -2.051771   0.961976  -2.133   0.0330 *  
## trialtrial-002                    -1.868279   0.882804  -2.116   0.0344 *  
## trialtrial-003                    -1.303392   0.917855  -1.420   0.1556    
## trialtrial-004                    -1.897514   0.783880  -2.421   0.0155 *  
## trialtrial-005                    -0.439573   0.863620  -0.509   0.6108    
## trialtrial-006                    -1.772311   0.917855  -1.931   0.0535 .  
## trialtrial-007                    -1.316665   0.866073  -1.520   0.1285    
## trialtrial-008                    -1.175790   0.851299  -1.381   0.1673    
## trialtrial-009                    -1.963293   0.975126  -2.013   0.0441 *  
## trialtrial-010                    -1.182241   0.809571  -1.460   0.1443    
## trialtrial-011                    -1.717821   0.929075  -1.849   0.0645 .  
## cuetypecuetype-low                 0.947359   0.885652   1.070   0.2848    
## trialtrial-001:cuetypecuetype-low  0.045573   1.281579   0.036   0.9716    
## trialtrial-002:cuetypecuetype-low  0.877165   1.252644   0.700   0.4838    
## trialtrial-003:cuetypecuetype-low  0.537268   1.261724   0.426   0.6703    
## trialtrial-004:cuetypecuetype-low  0.006645   1.411646   0.005   0.9962    
## trialtrial-005:cuetypecuetype-low -1.561935   1.252987  -1.247   0.2126    
## trialtrial-006:cuetypecuetype-low -0.690260   1.263031  -0.547   0.5847    
## trialtrial-007:cuetypecuetype-low  0.138811   1.254680   0.111   0.9119    
## trialtrial-008:cuetypecuetype-low -2.147377   1.257934  -1.707   0.0879 .  
## trialtrial-009:cuetypecuetype-low  0.301961   1.290458   0.234   0.8150    
## trialtrial-010:cuetypecuetype-low  0.182745   1.304271   0.140   0.8886    
## trialtrial-011:cuetypecuetype-low -1.019529   1.267798  -0.804   0.4213    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 10.1 on 6205 degrees of freedom
## Multiple R-squared:  0.006555,	Adjusted R-squared:  0.002873 
## F-statistic:  1.78 on 23 and 6205 DF,  p-value: 0.01223
```


```r
model.trial = lm(NPSpos ~ trial*cuetype, data = NPStrialorder[NPStrialorder$runtype == "runtype-pain",], )
Anova(model.trial, type = "III")
```

```
## Warning in printHypothesis(L, rhs, names(b)): one or more coefficients in the hypothesis include
##      arithmetic operators in their names;
##   the printed representation of the hypothesis will be omitted

## Warning in printHypothesis(L, rhs, names(b)): one or more coefficients in the hypothesis include
##      arithmetic operators in their names;
##   the printed representation of the hypothesis will be omitted

## Warning in printHypothesis(L, rhs, names(b)): one or more coefficients in the hypothesis include
##      arithmetic operators in their names;
##   the printed representation of the hypothesis will be omitted
```

```
## Anova Table (Type III tests)
## 
## Response: NPSpos
##               Sum Sq   Df  F value Pr(>F)    
## (Intercept)    15866    1 155.5842 <2e-16 ***
## trial           1161   11   1.0349 0.4118    
## cuetype          117    1   1.1442 0.2848    
## trial:cuetype   1121   11   0.9996 0.4438    
## Residuals     632766 6205                    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

```r
summary(model.trial)
```

```
## 
## Call:
## lm(formula = NPSpos ~ trial * cuetype, data = NPStrialorder[NPStrialorder$runtype == 
##     "runtype-pain", ])
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -53.242  -5.531  -0.861   4.469  81.517 
## 
## Coefficients:
##                                    Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                        7.568215   0.606751  12.473   <2e-16 ***
## trialtrial-001                    -2.051771   0.961976  -2.133   0.0330 *  
## trialtrial-002                    -1.868279   0.882804  -2.116   0.0344 *  
## trialtrial-003                    -1.303392   0.917855  -1.420   0.1556    
## trialtrial-004                    -1.897514   0.783880  -2.421   0.0155 *  
## trialtrial-005                    -0.439573   0.863620  -0.509   0.6108    
## trialtrial-006                    -1.772311   0.917855  -1.931   0.0535 .  
## trialtrial-007                    -1.316665   0.866073  -1.520   0.1285    
## trialtrial-008                    -1.175790   0.851299  -1.381   0.1673    
## trialtrial-009                    -1.963293   0.975126  -2.013   0.0441 *  
## trialtrial-010                    -1.182241   0.809571  -1.460   0.1443    
## trialtrial-011                    -1.717821   0.929075  -1.849   0.0645 .  
## cuetypecuetype-low                 0.947359   0.885652   1.070   0.2848    
## trialtrial-001:cuetypecuetype-low  0.045573   1.281579   0.036   0.9716    
## trialtrial-002:cuetypecuetype-low  0.877165   1.252644   0.700   0.4838    
## trialtrial-003:cuetypecuetype-low  0.537268   1.261724   0.426   0.6703    
## trialtrial-004:cuetypecuetype-low  0.006645   1.411646   0.005   0.9962    
## trialtrial-005:cuetypecuetype-low -1.561935   1.252987  -1.247   0.2126    
## trialtrial-006:cuetypecuetype-low -0.690260   1.263031  -0.547   0.5847    
## trialtrial-007:cuetypecuetype-low  0.138811   1.254680   0.111   0.9119    
## trialtrial-008:cuetypecuetype-low -2.147377   1.257934  -1.707   0.0879 .  
## trialtrial-009:cuetypecuetype-low  0.301961   1.290458   0.234   0.8150    
## trialtrial-010:cuetypecuetype-low  0.182745   1.304271   0.140   0.8886    
## trialtrial-011:cuetypecuetype-low -1.019529   1.267798  -0.804   0.4213    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 10.1 on 6205 degrees of freedom
## Multiple R-squared:  0.006555,	Adjusted R-squared:  0.002873 
## F-statistic:  1.78 on 23 and 6205 DF,  p-value: 0.01223
```

## pain per session  {.tabset}

### trial order \* cue \* ses 01 {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-78-1.png" width="672" />

### trial order \* cue \* ses-03 {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-79-1.png" width="672" />

### trial order \* cue \* ses-04 {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-80-1.png" width="672" />


## vicarious  {.tabset}

### trial order \* cue {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-81-1.png" width="672" />

### trial order only {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-82-1.png" width="672" />

## cognitive  {.tabset}

### trial order \* cue {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-83-1.png" width="672" />

### trial order only {.unlisted .unnumbered}


```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="41_iv-task-stim_dv-nps_singletrialttl2_files/figure-html/unnamed-chunk-84-1.png" width="672" />

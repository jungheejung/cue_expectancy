# signature effect size ~ single trial {#singletrial_signature_effectsize}

```
author: "Heejung Jung"
date: "2023-03-04"
```




## Function {.unlisted .unnumbered}






## Step 1: Common parameters {.unlisted .unnumbered}

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv"
```

## effeect size


```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: NPSpos ~ stimintensity * task + (1 | sub)
##    Data: pvc
## 
## REML criterion at convergence: 45393.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -6.3527 -0.5125 -0.0067  0.5117  6.2646 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept)  4.583   2.141   
##  Residual             45.958   6.779   
## Number of obs: 6780, groups:  sub, 100
## 
## Fixed effects:
##                                 Estimate Std. Error        df t value Pr(>|t|)
## (Intercept)                       0.6786     0.3241  360.5605   2.094  0.03697
## stimintensitylow                  0.5165     0.3433 6665.6929   1.505  0.13248
## stimintensitymed                  0.3315     0.3433 6665.6929   0.966  0.33426
## taskpain                          6.8478     0.3542 6687.3213  19.334  < 2e-16
## taskvicarious                    -1.1285     0.3433 6666.8351  -3.287  0.00102
## stimintensitylow:taskpain        -2.9738     0.4991 6665.6928  -5.958 2.69e-09
## stimintensitymed:taskpain        -1.2688     0.4991 6665.6928  -2.542  0.01105
## stimintensitylow:taskvicarious   -0.1282     0.4855 6665.6929  -0.264  0.79173
## stimintensitymed:taskvicarious    0.1151     0.4855 6665.6929   0.237  0.81253
##                                   
## (Intercept)                    *  
## stimintensitylow                  
## stimintensitymed                  
## taskpain                       ***
## taskvicarious                  ** 
## stimintensitylow:taskpain      ***
## stimintensitymed:taskpain      *  
## stimintensitylow:taskvicarious    
## stimintensitymed:taskvicarious    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                  (Intr) stmntnstyl stmntnstym taskpn tskvcr stmntnstylw:tskp
## stmntnstylw      -0.530                                                     
## stmntnstymd      -0.530  0.500                                              
## taskpain         -0.514  0.485      0.485                                   
## taskvicaris      -0.530  0.500      0.500      0.484                        
## stmntnstylw:tskp  0.364 -0.688     -0.344     -0.705 -0.344                 
## stmntnstymd:tskp  0.364 -0.344     -0.688     -0.705 -0.344  0.500          
## stmntnstylw:tskv  0.374 -0.707     -0.354     -0.343 -0.707  0.486          
## stmntnstymd:tskv  0.374 -0.354     -0.707     -0.343 -0.707  0.243          
##                  stmntnstymd:tskp stmntnstylw:tskv
## stmntnstylw                                       
## stmntnstymd                                       
## taskpain                                          
## taskvicaris                                       
## stmntnstylw:tskp                                  
## stmntnstymd:tskp                                  
## stmntnstylw:tskv  0.243                           
## stmntnstymd:tskv  0.486            0.500
```

```
## $emmeans
##  stimintensity task        emmean    SE  df asymp.LCL asymp.UCL
##  high          cognitive  0.67862 0.324 Inf    0.0434     1.314
##  low           cognitive  1.19511 0.324 Inf    0.5599     1.830
##  med           cognitive  1.01010 0.324 Inf    0.3749     1.645
##  high          pain       7.52646 0.335 Inf    6.8690     8.184
##  low           pain       5.06919 0.335 Inf    4.4118     5.727
##  med           pain       6.58919 0.335 Inf    5.9318     7.247
##  high          vicarious -0.44985 0.324 Inf   -1.0851     0.185
##  low           vicarious -0.06156 0.324 Inf   -0.6968     0.574
##  med           vicarious -0.00323 0.324 Inf   -0.6384     0.632
## 
## Degrees-of-freedom method: asymptotic 
## Confidence level used: 0.95 
## 
## $contrasts
##  contrast                        estimate    SE  df z.ratio p.value
##  high cognitive - low cognitive   -0.5165 0.343 Inf  -1.505  0.8539
##  high cognitive - med cognitive   -0.3315 0.343 Inf  -0.966  0.9889
##  high cognitive - high pain       -6.8478 0.354 Inf -19.334  <.0001
##  high cognitive - low pain        -4.3906 0.354 Inf -12.396  <.0001
##  high cognitive - med pain        -5.9106 0.354 Inf -16.688  <.0001
##  high cognitive - high vicarious   1.1285 0.343 Inf   3.287  0.0282
##  high cognitive - low vicarious    0.7402 0.343 Inf   2.156  0.4350
##  high cognitive - med vicarious    0.6818 0.343 Inf   1.986  0.5533
##  low cognitive - med cognitive     0.1850 0.343 Inf   0.539  0.9998
##  low cognitive - high pain        -6.3313 0.354 Inf -17.876  <.0001
##  low cognitive - low pain         -3.8741 0.354 Inf -10.938  <.0001
##  low cognitive - med pain         -5.3941 0.354 Inf -15.230  <.0001
##  low cognitive - high vicarious    1.6450 0.343 Inf   4.791  0.0001
##  low cognitive - low vicarious     1.2567 0.343 Inf   3.660  0.0078
##  low cognitive - med vicarious     1.1983 0.343 Inf   3.490  0.0143
##  med cognitive - high pain        -6.5164 0.354 Inf -18.398  <.0001
##  med cognitive - low pain         -4.0591 0.354 Inf -11.460  <.0001
##  med cognitive - med pain         -5.5791 0.354 Inf -15.752  <.0001
##  med cognitive - high vicarious    1.4600 0.343 Inf   4.252  0.0007
##  med cognitive - low vicarious     1.0717 0.343 Inf   3.121  0.0472
##  med cognitive - med vicarious     1.0133 0.343 Inf   2.951  0.0770
##  high pain - low pain              2.4573 0.362 Inf   6.781  <.0001
##  high pain - med pain              0.9373 0.362 Inf   2.587  0.1921
##  high pain - high vicarious        7.9763 0.354 Inf  22.511  <.0001
##  high pain - low vicarious         7.5880 0.354 Inf  21.415  <.0001
##  high pain - med vicarious         7.5297 0.354 Inf  21.250  <.0001
##  low pain - med pain              -1.5200 0.362 Inf  -4.195  0.0009
##  low pain - high vicarious         5.5190 0.354 Inf  15.576  <.0001
##  low pain - low vicarious          5.1307 0.354 Inf  14.480  <.0001
##  low pain - med vicarious          5.0724 0.354 Inf  14.315  <.0001
##  med pain - high vicarious         7.0390 0.354 Inf  19.866  <.0001
##  med pain - low vicarious          6.6508 0.354 Inf  18.770  <.0001
##  med pain - med vicarious          6.5924 0.354 Inf  18.605  <.0001
##  high vicarious - low vicarious   -0.3883 0.343 Inf  -1.131  0.9696
##  high vicarious - med vicarious   -0.4466 0.343 Inf  -1.301  0.9314
##  low vicarious - med vicarious    -0.0583 0.343 Inf  -0.170  1.0000
## 
## Degrees-of-freedom method: asymptotic 
## P value adjustment: tukey method for comparing a family of 9 estimates
```


## contrastt (stim intensity)


<img src="36_iv-task-stim_dv-nps_singletrial_effectsize_files/figure-html/unnamed-chunk-4-1.png" width="672" />

  



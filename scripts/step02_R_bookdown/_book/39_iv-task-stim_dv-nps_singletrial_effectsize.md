# signature effect size ~ single trial {#ch39_signature_effectsize}

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
## REML criterion at convergence: 134907.4
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -6.8697 -0.5094 -0.0091  0.4969  9.7710 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept)  3.606   1.899   
##  Residual             59.875   7.738   
## Number of obs: 19428, groups:  sub, 111
## 
## Fixed effects:
##                                  Estimate Std. Error         df t value
## (Intercept)                     5.988e-01  2.448e-01  2.817e+02   2.447
## stimintensitylow                3.534e-01  2.316e-01  1.930e+04   1.526
## stimintensitymed                2.038e-01  2.316e-01  1.930e+04   0.880
## taskpain                        7.253e+00  2.384e-01  1.932e+04  30.426
## taskvicarious                  -8.351e-01  2.315e-01  1.930e+04  -3.607
## stimintensitylow:taskpain      -2.731e+00  3.366e-01  1.930e+04  -8.114
## stimintensitymed:taskpain      -1.151e+00  3.366e-01  1.930e+04  -3.419
## stimintensitylow:taskvicarious  3.206e-02  3.274e-01  1.930e+04   0.098
## stimintensitymed:taskvicarious  2.891e-02  3.274e-01  1.930e+04   0.088
##                                Pr(>|t|)    
## (Intercept)                    0.015035 *  
## stimintensitylow               0.127042    
## stimintensitymed               0.378945    
## taskpain                        < 2e-16 ***
## taskvicarious                  0.000311 ***
## stimintensitylow:taskpain      5.17e-16 ***
## stimintensitymed:taskpain      0.000630 ***
## stimintensitylow:taskvicarious 0.921995    
## stimintensitymed:taskvicarious 0.929639    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                  (Intr) stmntnstyl stmntnstym taskpn tskvcr stmntnstylw:tskp
## stmntnstylw      -0.473                                                     
## stmntnstymd      -0.473  0.500                                              
## taskpain         -0.460  0.486      0.486                                   
## taskvicaris      -0.473  0.500      0.500      0.486                        
## stmntnstylw:tskp  0.326 -0.688     -0.344     -0.706 -0.344                 
## stmntnstymd:tskp  0.326 -0.344     -0.688     -0.706 -0.344  0.500          
## stmntnstylw:tskv  0.335 -0.707     -0.354     -0.344 -0.707  0.487          
## stmntnstymd:tskv  0.335 -0.354     -0.707     -0.344 -0.707  0.243          
##                  stmntnstymd:tskp stmntnstylw:tskv
## stmntnstylw                                       
## stmntnstymd                                       
## taskpain                                          
## taskvicaris                                       
## stmntnstylw:tskp                                  
## stmntnstymd:tskp                                  
## stmntnstylw:tskv  0.243                           
## stmntnstymd:tskv  0.487            0.500
```

```
## $emmeans
##  stimintensity task        emmean    SE  df asymp.LCL asymp.UCL
##  high          cognitive  0.59881 0.245 Inf     0.119     1.079
##  low           cognitive  0.95226 0.245 Inf     0.473     1.432
##  med           cognitive  0.80261 0.245 Inf     0.323     1.282
##  high          pain       7.85206 0.251 Inf     7.360     8.344
##  low           pain       5.47433 0.251 Inf     4.982     5.966
##  med           pain       6.90507 0.251 Inf     6.413     7.397
##  high          vicarious -0.23633 0.245 Inf    -0.716     0.243
##  low           vicarious  0.14918 0.245 Inf    -0.330     0.629
##  med           vicarious -0.00362 0.245 Inf    -0.483     0.476
## 
## Degrees-of-freedom method: asymptotic 
## Confidence level used: 0.95 
## 
## $contrasts
##  contrast                        estimate    SE  df z.ratio p.value
##  high cognitive - low cognitive    -0.353 0.232 Inf  -1.526  0.8436
##  high cognitive - med cognitive    -0.204 0.232 Inf  -0.880  0.9940
##  high cognitive - high pain        -7.253 0.238 Inf -30.426  <.0001
##  high cognitive - low pain         -4.876 0.238 Inf -20.452  <.0001
##  high cognitive - med pain         -6.306 0.238 Inf -26.453  <.0001
##  high cognitive - high vicarious    0.835 0.232 Inf   3.607  0.0094
##  high cognitive - low vicarious     0.450 0.232 Inf   1.942  0.5843
##  high cognitive - med vicarious     0.602 0.232 Inf   2.602  0.1856
##  low cognitive - med cognitive      0.150 0.232 Inf   0.646  0.9993
##  low cognitive - high pain         -6.900 0.238 Inf -28.943  <.0001
##  low cognitive - low pain          -4.522 0.238 Inf -18.969  <.0001
##  low cognitive - med pain          -5.953 0.238 Inf -24.971  <.0001
##  low cognitive - high vicarious     1.189 0.232 Inf   5.134  <.0001
##  low cognitive - low vicarious      0.803 0.232 Inf   3.469  0.0154
##  low cognitive - med vicarious      0.956 0.232 Inf   4.128  0.0012
##  med cognitive - high pain         -7.049 0.238 Inf -29.571  <.0001
##  med cognitive - low pain          -4.672 0.238 Inf -19.597  <.0001
##  med cognitive - med pain          -6.102 0.238 Inf -25.598  <.0001
##  med cognitive - high vicarious     1.039 0.232 Inf   4.487  0.0002
##  med cognitive - low vicarious      0.653 0.232 Inf   2.822  0.1088
##  med cognitive - med vicarious      0.806 0.232 Inf   3.482  0.0147
##  high pain - low pain               2.378 0.244 Inf   9.737  <.0001
##  high pain - med pain               0.947 0.244 Inf   3.878  0.0034
##  high pain - high vicarious         8.088 0.238 Inf  33.940  <.0001
##  high pain - low vicarious          7.703 0.238 Inf  32.322  <.0001
##  high pain - med vicarious          7.856 0.238 Inf  32.963  <.0001
##  low pain - med pain               -1.431 0.244 Inf  -5.859  <.0001
##  low pain - high vicarious          5.711 0.238 Inf  23.963  <.0001
##  low pain - low vicarious           5.325 0.238 Inf  22.345  <.0001
##  low pain - med vicarious           5.478 0.238 Inf  22.986  <.0001
##  med pain - high vicarious          7.141 0.238 Inf  29.966  <.0001
##  med pain - low vicarious           6.756 0.238 Inf  28.348  <.0001
##  med pain - med vicarious           6.909 0.238 Inf  28.990  <.0001
##  high vicarious - low vicarious    -0.386 0.231 Inf  -1.666  0.7675
##  high vicarious - med vicarious    -0.233 0.231 Inf  -1.006  0.9855
##  low vicarious - med vicarious      0.153 0.231 Inf   0.660  0.9992
## 
## Degrees-of-freedom method: asymptotic 
## P value adjustment: tukey method for comparing a family of 9 estimates
```


## contrastt (stim intensity)


<img src="39_iv-task-stim_dv-nps_singletrial_effectsize_files/figure-html/unnamed-chunk-4-1.png" width="672" />

## layer in metadata
plot expectation rating, cue, stimulus intensity, N-1 outcome rating
predict NPS response




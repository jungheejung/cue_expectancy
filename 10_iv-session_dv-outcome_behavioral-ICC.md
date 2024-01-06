# outcome_rating ~ session ("behavioral ICC") {#ch10_icc}

---
title: "behavioral_ICC"
author: "Heejung Jung"
date: "2/22/2022"
output: html_document
---


```r
library(psych)
library(car)
```

```
## Loading required package: carData
```

```
## 
## Attaching package: 'car'
```

```
## The following object is masked from 'package:psych':
## 
##     logit
```

```r
library(lme4)
```

```
## Loading required package: Matrix
```

```r
library(lmerTest)
```

```
## 
## Attaching package: 'lmerTest'
```

```
## The following object is masked from 'package:lme4':
## 
##     lmer
```

```
## The following object is masked from 'package:stats':
## 
##     step
```

```r
library(plyr)
#library(dplyr)
library(tidyr)
```

```
## 
## Attaching package: 'tidyr'
```

```
## The following objects are masked from 'package:Matrix':
## 
##     expand, pack, unpack
```

```r
library(stringr)
library(ggplot2)
```

```
## 
## Attaching package: 'ggplot2'
```

```
## The following objects are masked from 'package:psych':
## 
##     %+%, alpha
```

```r
library(png)
library(knitr)
library(TMB)
```

```
## Warning in checkMatrixPackageVersion(): Package version inconsistency detected.
## TMB was built with Matrix version 1.4.1
## Current Matrix version is 1.5.1
## Please re-install 'TMB' from source using install.packages('TMB', type = 'source') or ask CRAN for a binary version of 'TMB' matching CRAN's 'Matrix' package
```

```r
library(sjPlot)
```

```
## Learn more about sjPlot with 'browseVignettes("sjPlot")'.
```

```r
library(ggpubr)
```

```
## 
## Attaching package: 'ggpubr'
```

```
## The following object is masked from 'package:plyr':
## 
##     mutate
```

```r
library(gridExtra)
library(merTools)
```

```
## Loading required package: arm
```

```
## Loading required package: MASS
```

```
## 
## arm (Version 1.13-1, built: 2022-8-25)
```

```
## Working directory is /Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/scripts/step02_R_bookdown
```

```
## 
## Attaching package: 'arm'
```

```
## The following object is masked from 'package:car':
## 
##     logit
```

```
## The following objects are masked from 'package:psych':
## 
##     logit, rescale, sim
```

```
## 
## Attaching package: 'merTools'
```

```
## The following object is masked from 'package:psych':
## 
##     ICC
```

```r
library(sjstats) #to get ICC
```

```
## 
## Attaching package: 'sjstats'
```

```
## The following object is masked from 'package:psych':
## 
##     phi
```

```r
library(broom)
```

```
## 
## Attaching package: 'broom'
```

```
## The following object is masked from 'package:sjstats':
## 
##     bootstrap
```

```r
library(tidyverse)
```

```
## ── Attaching packages
## ───────────────────────────────────────
## tidyverse 1.3.2 ──
```

```
## ✔ tibble  3.1.8      ✔ dplyr   1.0.10
## ✔ readr   2.1.2      ✔ forcats 0.5.2 
## ✔ purrr   1.0.1      
## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
## ✖ ggplot2::%+%()     masks psych::%+%()
## ✖ ggplot2::alpha()   masks psych::alpha()
## ✖ dplyr::arrange()   masks plyr::arrange()
## ✖ broom::bootstrap() masks sjstats::bootstrap()
## ✖ dplyr::combine()   masks gridExtra::combine()
## ✖ purrr::compact()   masks plyr::compact()
## ✖ dplyr::count()     masks plyr::count()
## ✖ tidyr::expand()    masks Matrix::expand()
## ✖ dplyr::failwith()  masks plyr::failwith()
## ✖ dplyr::filter()    masks stats::filter()
## ✖ dplyr::id()        masks plyr::id()
## ✖ dplyr::lag()       masks stats::lag()
## ✖ dplyr::mutate()    masks ggpubr::mutate(), plyr::mutate()
## ✖ tidyr::pack()      masks Matrix::pack()
## ✖ dplyr::recode()    masks car::recode()
## ✖ dplyr::rename()    masks plyr::rename()
## ✖ dplyr::select()    masks MASS::select()
## ✖ purrr::some()      masks car::some()
## ✖ dplyr::summarise() masks plyr::summarise()
## ✖ dplyr::summarize() masks plyr::summarize()
## ✖ tidyr::unpack()    masks Matrix::unpack()
```

```r
library(GGally)
```

```
## Registered S3 method overwritten by 'GGally':
##   method from   
##   +.gg   ggplot2
```

```r
library(RCurl)
```

```
## 
## Attaching package: 'RCurl'
## 
## The following object is masked from 'package:tidyr':
## 
##     complete
```

```r
library(rstanarm)
```

```
## Loading required package: Rcpp
## This is rstanarm version 2.21.3
## - See https://mc-stan.org/rstanarm/articles/priors for changes to default priors!
## - Default priors may change, so it's safest to specify priors, even if equivalent to the defaults.
## - For execution on a local, multicore CPU with excess RAM we recommend calling
##   options(mc.cores = parallel::detectCores())
## 
## Attaching package: 'rstanarm'
## 
## The following object is masked from 'package:sjstats':
## 
##     se
## 
## The following objects are masked from 'package:arm':
## 
##     invlogit, logit
## 
## The following object is masked from 'package:car':
## 
##     logit
## 
## The following object is masked from 'package:psych':
## 
##     logit
```

```r
library(reshape)
```

```
## 
## Attaching package: 'reshape'
## 
## The following object is masked from 'package:dplyr':
## 
##     rename
## 
## The following objects are masked from 'package:tidyr':
## 
##     expand, smiths
## 
## The following objects are masked from 'package:plyr':
## 
##     rename, round_any
## 
## The following object is masked from 'package:Matrix':
## 
##     expand
```

```r
library(boot)
```

```
## 
## Attaching package: 'boot'
## 
## The following object is masked from 'package:rstanarm':
## 
##     logit
## 
## The following object is masked from 'package:arm':
## 
##     logit
## 
## The following object is masked from 'package:car':
## 
##     logit
## 
## The following object is masked from 'package:psych':
## 
##     logit
```

```r
library(afex)
```

```
## ************
## Welcome to afex. For support visit: http://afex.singmann.science/
## - Functions for ANOVAs: aov_car(), aov_ez(), and aov_4()
## - Methods for calculating p-values with mixed(): 'S', 'KR', 'LRT', and 'PB'
## - 'afex_aov' and 'mixed' objects can be passed to emmeans() for follow-up tests
## - NEWS: emmeans() for ANOVA models now uses model = 'multivariate' as default.
## - Get and set global package options with: afex_options()
## - Set orthogonal sum-to-zero contrasts globally: set_sum_contrasts()
## - For example analyses see: browseVignettes("afex")
## ************
## 
## Attaching package: 'afex'
## 
## The following object is masked from 'package:lme4':
## 
##     lmer
```

```r
library(cowplot)
```

```
## 
## Attaching package: 'cowplot'
## 
## The following object is masked from 'package:reshape':
## 
##     stamp
## 
## The following object is masked from 'package:ggpubr':
## 
##     get_legend
## 
## The following objects are masked from 'package:sjPlot':
## 
##     plot_grid, save_plot
```

```r
library(readr)
library(lavaan)
```

```
## This is lavaan 0.6-12
## lavaan is FREE software! Please report any bugs.
## 
## Attaching package: 'lavaan'
## 
## The following object is masked from 'package:psych':
## 
##     cor2cov
```

```r
library(rmarkdown)
library(readr)
library(caTools)
library(bitops)
```

```
## 
## Attaching package: 'bitops'
## 
## The following object is masked from 'package:Matrix':
## 
##     %&%
```

```r
library(stringr)
library(ggpubr)
library(ggrepel)
# library(PupillometryR)
source('http://psych.colorado.edu/~jclab/R/mcSummaryLm.R')
source("/Users/h/Documents/projects_local/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/Users/h/Documents/projects_local/RainCloudPlots/tutorial_R/summarySE.R")
source("/Users/h/Documents/projects_local/RainCloudPlots/tutorial_R/simulateData.R")
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")
library(r2mlm)
```

```
## Loading required package: nlme
## 
## Attaching package: 'nlme'
## 
## The following object is masked from 'package:dplyr':
## 
##     collapse
## 
## The following object is masked from 'package:lme4':
## 
##     lmList
```

```r
file.sources = list.files(c("/Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils"),
                          pattern="*.R", 
                          full.names=TRUE, 
                          ignore.case=TRUE)
sapply(file.sources,source,.GlobalEnv)
```

```
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/ggplot_hline_bartoshuk.R
## value   ?                                                                                                          
## visible FALSE                                                                                                      
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/lmer_onefactor_cooksd_fix.R
## value   ?                                                                                                             
## visible FALSE                                                                                                         
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/lmer_onefactor_cooksd_randomintercept_fix.R
## value   ?                                                                                                                             
## visible FALSE                                                                                                                         
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/lmer_onefactor_cooksd_randomintercept.R
## value   ?                                                                                                                         
## visible FALSE                                                                                                                     
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/lmer_onefactor_cooksd.R
## value   ?                                                                                                         
## visible FALSE                                                                                                     
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/lmer_twofactor_cooksd_fix.R
## value   ?                                                                                                             
## visible FALSE                                                                                                         
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/lmer_twofactor_cooksd.R
## value   ?                                                                                                         
## visible FALSE                                                                                                     
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/load_task_social_df.R
## value   ?                                                                                                       
## visible FALSE                                                                                                   
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/meanSummary_2dv.R
## value   ?                                                                                                   
## visible FALSE                                                                                               
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/meanSummary.R
## value   ?                                                                                               
## visible FALSE                                                                                           
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/normdatawithin.R
## value   ?                                                                                                  
## visible FALSE                                                                                              
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/NPS_load_df.R
## value   ?                                                                                               
## visible FALSE                                                                                           
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/NPS_simple_contrast.R
## value   ?                                                                                                       
## visible FALSE                                                                                                   
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/NPS_summary_for_plots.R
## value   ?                                                                                                         
## visible FALSE                                                                                                     
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_binned_rating.R
## value   ?                                                                                                      
## visible FALSE                                                                                                  
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_errorbar.R
## value   ?                                                                                                 
## visible FALSE                                                                                             
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_geompointrange_onefactor.R
## value   ?                                                                                                                 
## visible FALSE                                                                                                             
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_ggplot_correlation.R
## value   ?                                                                                                           
## visible FALSE                                                                                                       
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_halfrainclouds_onefactor.R
## value   ?                                                                                                                 
## visible FALSE                                                                                                             
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_halfrainclouds_sigmoid.R
## value   ?                                                                                                               
## visible FALSE                                                                                                           
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_halfrainclouds_twofactor.R
## value   ?                                                                                                                 
## visible FALSE                                                                                                             
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_lineplot_onefactor.R
## value   ?                                                                                                           
## visible FALSE                                                                                                       
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_lineplot_twofactor.R
## value   ?                                                                                                           
## visible FALSE                                                                                                       
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_rainclouds_onefactor.R
## value   ?                                                                                                             
## visible FALSE                                                                                                         
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_rainclouds_twofactor.R
## value   ?                                                                                                             
## visible FALSE                                                                                                         
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_signature_twofactor.R
## value   ?                                                                                                            
## visible FALSE                                                                                                        
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/plot_twovariable.R
## value   ?                                                                                                    
## visible FALSE                                                                                                
##         /Users/h/Dropbox/projects_dropbox/social_influence_analysis/scripts/step02_R/utils/summarySEwithin.R
## value   ?                                                                                                   
## visible FALSE
```

## Functions


http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/#Helper%20functions













combined expect_df / run_cue_lmer / meanSummary / plot_expect_rainclouds



```r
raincloud_theme = theme(
text = element_text(size = 10),
axis.title.x = element_text(size = 16),
axis.title.y = element_text(size = 16),
axis.text = element_text(size = 14),
axis.text.x = element_text(angle = 45, vjust = 0.5),
legend.title=element_text(size=16),
legend.text=element_text(size=16),
legend.position = "right",
plot.title = element_text(lineheight=.8, face="bold", size = 16),
panel.border = element_blank(),
panel.grid.minor = element_blank(),
panel.grid.major = element_blank(),
axis.line.x = element_line(colour = 'black', size=0.5, linetype='solid'),
axis.line.y = element_line(colour = 'black', size=0.5, linetype='solid'))
```

```
## Warning: The `size` argument of `element_line()` is deprecated as of ggplot2 3.4.0.
## ℹ Please use the `linewidth` argument instead.
```

```r
w = 5
h = 3
```



```r
# parameters
TASKNAME = 'cognitive'
SUBJECT_VARKEY = "src_subject_id"
IV = "param_cue_type"
DV = "event02_expect_angle"
DV_KEYWORD = "expect"
XLAB = ""; YLAB = "ratings (degree)"; 

GGTITLE = paste(TASKNAME, " - Expectation Rating (degree)")
TITLE = paste(TASKNAME, " - Expect")
SUBJECT = "subject"
EXCLUDE = ""
main_dir = dirname(dirname(getwd()))
datadir = file.path(main_dir, 'data', 'beh', 'beh02_preproc')
analysis_dir =file.path(main_dir,'analysis', 'mixedeffect', 'model04_behavioral-ICC', as.character(Sys.Date()))
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)
for (TASKNAME in c("pain", "vicarious", "cognitive")){

SAVE_FNAME = file.path(analysis_dir, paste('lmer_task-', TASKNAME, '_rating-',DV_KEYWORD,'_', as.character(Sys.Date()),'.txt',sep = ''))
DATA = expect_df(TASKNAME, SUBJECT_VARKEY, IV, DV, EXCLUDE )
}
```


```r
FILENAME = paste('*_task-social_*-' ,TASKNAME, '_beh.csv', sep = "")
common_path = Sys.glob(file.path(main_dir,'data', 'beh', 'beh02_preproc', 'sub-*','ses-*',FILENAME))
filter_path = common_path[!str_detect(common_path,pattern="sub-0001|sub-0003|sub-0004|sub-0005|sub-0025")]

DF <- do.call("rbind",lapply(filter_path,FUN=function(files){ read.csv(files)}))
is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))
DF[is.nan(DF)] <- NA
DF = as.data.frame(DF)
# subjects as factor
DF$subject = factor(DF$src_subject_id)
```


```r
# subjectwise = meanSummary(DF, c(src_subject_id, session_id), event04_actual_angle)
# groupwise = summarySEwithin(data=subjectwise, 
#                   measurevar = "mean_per_sub", # variable created from above
#                     withinvars = c(IV), # IV
#                     idvar = "subject")
# 
main_dir = '/Users/h/Dropbox/projects_dropbox/social_influence_analysis'
for (TASKNAME in c("pain","vicarious","cognitive")){
  print(TASKNAME)
  DV_KEYWORD = "actual-rating"
FILENAME = paste('*_task-social_*-' ,TASKNAME, '_beh.csv', sep = "")
common_path = Sys.glob(file.path(main_dir,'data', 'beh', 'beh02_preproc', 'sub-*','ses-*',FILENAME))
filter_path = common_path[!str_detect(common_path,pattern="sub-0001|sub-0003|sub-0004|sub-0005|sub-0025")]

DF <- do.call("rbind",lapply(filter_path,FUN=function(files){ read.csv(files)}))
is.nan.data.frame <- function(x)
  do.call(cbind, lapply(x, is.nan))
DF[is.nan(DF)] <- NA
DF = as.data.frame(DF)
# subjects as factor
DF$subject = factor(DF$src_subject_id)
SUBJECT = "src_subject_id"
IV = "session_id"
DV = "event04_actual_angle"
DF[is.nan(DF)]<-NA
subjectwise_ses = meanSummary(DF, c("subject", IV), DV)
subjectwise_ses[is.nan(subjectwise_ses)]<-NA

# long to wide

ses_beh = subset(subjectwise_ses,select = c("subject", "session_id", "mean_per_sub"))
ses_beh[is.nan(ses_beh)]<-NA
ses_beh_wide = reshape(ses_beh, idvar = "subject", timevar = "session_id", direction = "wide")
sub_ses = ses_beh_wide[rowSums(is.na(ses_beh_wide[,-1])) != ncol(ses_beh_wide[,-1]), ]
sub_13 = sub_ses[,c("mean_per_sub.1", "mean_per_sub.3")]
c13 = psych::ICC(sub_13[complete.cases(sub_13),])
icc13 = irr::icc(
  sub_13[complete.cases(sub_13),], model = "twoway", 
  type = "agreement", unit = "average"
  )
icc13_text = c13$results$ICC[5]# icc13_text = c13$results$ICC[5]

c34 = psych::ICC(sub_ses[,c("mean_per_sub.3", "mean_per_sub.4")])
icc34 = irr::icc(
  sub_ses[,c("mean_per_sub.3", "mean_per_sub.4")], model = "twoway", 
  type = "agreement", unit = "average"
  )
icc34_text = c34$results$ICC[5]

c41 = psych::ICC(sub_ses[,c("mean_per_sub.4", "mean_per_sub.1")])
ses41 = irr::icc(
  sub_ses[,c("mean_per_sub.4", "mean_per_sub.1")], model = "twoway", 
  type = "agreement", unit = "average"
  )
icc41_text = c41$results$ICC[5]

beh13 = ggplot(data = sub_ses, aes(x = mean_per_sub.1, y = mean_per_sub.3)) +
  stat_smooth(method = 'lm', color = "black") + 
  geom_point(size = 2, alpha = .8) +
  xlab("sesion 1") + ylab("session 3") + xlim(0, 150) + ylim(0, 200) +
  theme_classic() +
  theme(axis.title = element_text(size = 20))  +
    annotate(geom = "text", x = 120, y = 200, 
           label = as.character(paste("ICC = ",format(icc13_text, digits = 2),sep = "")),
           color = "black", size = 5)

beh34 = ggplot(data = sub_ses, aes(x = mean_per_sub.3, y = mean_per_sub.4)) +
  stat_smooth(method = 'lm', color = "black") + 
  geom_point(size = 2, alpha = .8) +
  xlab("session 3") + ylab("session 4") + xlim(0, 150) + ylim(0, 200) +
  theme_classic() +
  theme(axis.title = element_text(size = 20))  +
    annotate(geom = "text", x = 120, y = 200, 
           label = as.character(paste("ICC = ",format(icc34_text, digits = 2),sep = "")),
           color = "black", size = 5)

beh41 = ggplot(data = sub_ses, aes(x = mean_per_sub.4, y = mean_per_sub.1)) +
  stat_smooth(method = 'lm', color = "black") + 
  geom_point(size = 2, alpha = .8) +
  xlab("session 4") + ylab("session 1") + xlim(0, 150) + ylim(0, 200) +
  theme_classic() + 
  theme(axis.title = element_text(size = 20))  +
  annotate(geom = "text", x = 120, y = 200, 
           label = as.character(paste("ICC = ",format(icc41_text, digits = 2),sep = "")),
           color = "black", size = 5)


ggpubr::ggarrange(beh13,beh34,beh41,ncol = 3, nrow = 1, common.legend = FALSE,legend = "bottom")
plot_filename = file.path(main_dir, 'analysis','mixedeffect','model04_behavioral-ICC', paste('socialinfluence_task-',TASKNAME,'_',DV_KEYWORD,'_icc','_', as.character(Sys.Date()),'.png', sep = ""))
ggsave(plot_filename, width = 10, height = 3)
}
```

```
## [1] "pain"
```

```
## boundary (singular) fit: see help('isSingular')
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 38 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 38 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 32 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 32 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 35 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 35 rows containing missing values (`geom_point()`).
```

```
## [1] "vicarious"
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 22 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 22 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 18 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 18 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 21 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 21 rows containing missing values (`geom_point()`).
```

```
## [1] "cognitive"
```

```
## boundary (singular) fit: see help('isSingular')
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## Model failed to converge with max|grad| = 0.00281869 (tol = 0.002, component 1)
```

```
## boundary (singular) fit: see help('isSingular')
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 22 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 22 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 17 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 17 rows containing missing values (`geom_point()`).
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Removed 20 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 20 rows containing missing values (`geom_point()`).
```


## TODO:
* calculate average rating per session across participants
* row: sub-num
* columns: ses 1,3,4
* calculate 

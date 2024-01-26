
# [fMRI] singletrial ~ NPS {#ch53_NPS}

## load NPS





### load beahvarioa
### load bad json
### drop based on NPS and bad json


#### datawrangle :: load NPS

```r
# load NPS dot product
NPSdf <- read.csv(file.path(main_dir, 'analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv' ))


NPSsplit <- NPSdf %>%
  # 1) Extract the components from the singletrial_fname column (sub,ses, run etc)
  extract(col = singletrial_fname, into = c("sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"),
          regex = "(sub-\\w+)_+(ses-\\w+)_+(run-\\w+)_+(runtype-\\w+)_+(event-\\w+)_+(trial-\\w+)_+(cuetype-\\w+)_+(stimintensity-\\w+).nii.gz") %>%
  # 2) Extract numbers and keywords as specified
  mutate(
    sub = as.integer(str_extract(sub, "\\d+")),
    ses = as.integer(str_extract(ses, "\\d+")),
    run = as.integer(str_extract(run, "\\d+")),
    trail = as.integer(str_extract(trial, "\\d+")) + 1,
    cue = case_when(
      str_detect(cuetype, "low") ~ "low_cue",
      str_detect(cuetype, "high") ~ "high_cue"
    ), 
    task = str_replace(runtype, "runtype-", ""), 
    stim = case_when(
      stimintensity == "stimintensity-low" ~ "low_stim",
      stimintensity == "stimintensity-med" ~ "med_stim",
      stimintensity == "stimintensity-high" ~ "high_stim",
      TRUE ~ stimintensity  # Retain original value if neither "low" nor "high"
    )
  ) %>%
  # 3) Select and rename the necessary columns
  select(
    sub,
    ses,
    run,
    task,
    event,
    trial,
    cue,
    stim,
    NPSpos
  )
# Let's assume 'df' is your data frame and 'trial' is the column with trial identifiers
NPSsplit$trial_char <- NPSsplit$trial
NPSsplit$trial <- as.numeric(sub("trial-", "", NPSsplit$trial_char)) + 1
```


##### datawrangle :: remove bad runs

```r
library(jsonlite)
jsonfname <- "/Users/h/Documents/projects_local/cue_expectancy/scripts/bad_runs.json"


bad_runs <- fromJSON(jsonfname, simplifyDataFrame = FALSE)

# Initialize an empty data frame to store bad run entries
bad_runs_df <- data.frame(sub = integer(), ses = integer(), run = integer(), stringsAsFactors = FALSE)

# Parse the JSON content
for (sub_id in names(bad_runs)) {
  sub_num <- as.integer(substring(sub_id, 5))  # Extract the numeric part of the subject ID
  
  # Iterate over sessions and their runs for each subject
  for (ses_run_str in bad_runs[[sub_id]]) {
    ses_num <- as.integer(substring(strsplit(ses_run_str, "_")[[1]][1], 5))  # Extract session number
    run_num <- as.integer(substring(strsplit(ses_run_str, "_")[[1]][2], 5))  # Extract run number
    
    # Append to the bad_runs_df data frame
    bad_runs_df <- rbind(bad_runs_df, data.frame(sub = sub_num, ses = ses_num, run = run_num))
  }
}

# drop rows in merge_df if they overlap with bad_runs_df 
clean_merge_df <- NPSsplit %>%
  anti_join(bad_runs_df, by = c("sub", "ses", "run"))
# clean_merge_df <- merge_df %>%
#   anti_join(NPSsplit, by = c("sub", "ses", "run"))
```
### datawrangle :: load beahvarioal

```r
datadir = file.path(main_dir, 'data', 'beh', 'beh02_preproc')
taskname = '*'
subject_varkey <- "src_subject_id"
iv <- "param_stimulus_type"; 
iv_keyword <- "stim"; 
dv <- "event04_actual_angle"; dv_keyword <- "outcome"
exclude <- "sub-0001"
#sub-0074|sub-0085|sub-0118|sub-0117|sub-0103|sub-0063|sub-0002|sub-0003|sub-0004|sub-0005|sub-0007|sub-0008|sub-0013|sub-0016|sub-0017|sub-0019|sub-0020|sub-0021|sub-0025|sub-0075|sub-0009|sub-0117|sub-0119|sub-0081|sub-0060

p.df <- load_task_social_df(datadir, taskname = "pain", subject_varkey, iv, dv, exclude)
p.df <- p.df %>%
group_by(src_subject_id, session_id, param_run_num) %>%
mutate(trial_index_runwise = row_number()) %>%
ungroup() 
names(p.df)[names(p.df) == "src_subject_id"] <- "sub"
names(p.df)[names(p.df) == "session_id"] <- "ses"
names(p.df)[names(p.df) == "param_run_num"] <- "run"
names(p.df)[names(p.df) == "param_task_name"] <- "task"
names(p.df)[names(p.df) == "param_cue_type"] <- "cue"
names(p.df)[names(p.df) == "param_stimulus_type"] <- "stim"
names(p.df)[names(p.df) == "trial_index_runwise"] <- "trial"
names(p.df)[names(p.df) == "event02_expect_angle"] <- "RATING_expectation"
names(p.df)[names(p.df) == "event04_actual_angle"] <- "RATING_outcome"
```


### datawrangle :: merge NPS and behavioral

```r
library(dplyr)
# Assuming your dataframe is called df

merge_df <- inner_join(NPSsplit, p.df, by = c("sub", "ses", "run","cue",
"task", "stim","trial"))
```

## load fear of pain

```r
fop <- read.csv('/Users/h/Downloads/IndividualizedSpatia_DATA_2023-11-11_1303.csv')

# select rows that start with sub-@
fop.sub <- fop[grepl("^sub-", fop$record_id), ]

# convert rows to indices
fop.sub$sub <- as.integer(sub("sub-", "", fop.sub$record_id))
```

```
## Warning: NAs introduced by coercion
```

```r
# drop row: sub-0062
fop.sub <- fop.sub[fop.sub$sub != "sub-0062 (2) (pre-ses)", ]


# calculate fop total score
columns_to_sum <- paste0("fop", 1:30)
fop.sub$composite_score <- rowSums(fop.sub[, columns_to_sum], na.rm = TRUE)

fop.comp <- fop.sub[, c("sub", "composite_score")]

# merge sub and fop total score
nps.beh.fop <- inner_join(merge_df, fop.comp, by = c("sub"))
```
### merge and save

```r
clean_df <- nps.beh.fop[, c("sub", "ses", "run", "NPSpos", "cue",
"stim", "RATING_expectation", "RATING_outcome", "composite_score")]

clean_df_na <- clean_df[!is.na(clean_df$RATING_expectation),]
clean_df <- clean_df_na[!is.na(clean_df_na$RATING_expectation),]
clean_df$stimintensity <- clean_df$stim
clean_df$stim[clean_df$stimintensity == "low_stim"] <- -0.5
clean_df$stim[clean_df$stimintensity == "med_stim"] <- 0
clean_df$stim[clean_df$stimintensity == "high_stim"] <- 0.5

write.csv(clean_df , '/Users/h/Desktop/cleanmerge_NPS.csv')
```

#### datawrangle :: check number of trials

```r
frequency_per_sub <- table(clean_df$sub)
frequency_per_sub_df <- as.data.frame(frequency_per_sub)
# Step 1: Identify subjects with less than 10 occurrences
subjects_to_remove <- frequency_per_sub_df %>%
  filter(Freq < 10) %>%
  select(Var1)
subjects_to_remove$Var1 <- as.integer(as.character(subjects_to_remove$Var1))

# Step 2: Remove these subjects from the main data frame
filtered_main_df <- clean_df %>%
  anti_join(subjects_to_remove, by = c("sub" = "Var1"))
write.csv(filtered_main_df , '/Users/h/Desktop/cleanmerge_NPS.csv')
```

#### datawrangle :: between vs within

```r
p.demean <- filtered_main_df %>%
group_by(sub) %>%
mutate(RATING_outcome = as.numeric(RATING_outcome)) %>%
mutate(RATING_expectation = as.numeric(RATING_expectation)) %>%
mutate(avg_outcome = mean(RATING_outcome, na.rm = TRUE)) %>%
mutate(OUTCOME_demean = RATING_outcome - avg_outcome) %>%
mutate(avg_expect = mean(RATING_expectation, na.rm = TRUE)) %>%
mutate(EXPECT_demean = RATING_expectation - avg_expect)

p.demean <- p.demean %>%
group_by(sub) %>%
mutate(NPSpos = as.numeric(NPSpos)) %>%
mutate(avg_NPS = mean(NPSpos, na.rm = TRUE)) %>%
mutate(NPS_demean = NPSpos - avg_NPS) %>%
  ungroup %>%
mutate(OUTCOME_cmc = avg_outcome - mean(avg_outcome)) %>%
mutate(EXPECT_cmc = avg_expect - mean(avg_expect)) %>%
mutate(NPS_cmc = avg_NPS - mean(avg_NPS)) 
write.csv(p.demean , '/Users/h/Desktop/pain_withinbetween.csv')
```


## ggplot NPS and Outcome

```r
library(ggplot2)

min_value <- -40
max_value <- 40
p.demean$sub <- factor(p.demean$sub)
plot.PE_NPS <- ggplot(p.demean, aes(x = NPSpos, y = RATING_outcome)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  ylim(0, 180) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
```

```
## Warning: Using `size` aesthetic for lines was deprecated in ggplot2 3.4.0.
## ℹ Please use `linewidth` instead.
## This warning is displayed once every 8 hours.
## Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
## generated.
```

```r
plot.PE_NPS
```

```
## Warning: Removed 22 rows containing missing values (`geom_smooth()`).
```

<img src="53_NPSmediation_files/figure-html/unnamed-chunk-10-1.png" width="672" />


```r
library(ggplot2)

min_value <- -40
max_value <- 40
p.demean$sub <- factor(p.demean$sub)
plot.PE_NPS <- ggplot(p.demean, aes(x = NPS_demean, y = RATING_outcome)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  ylim(0, 180) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
plot.PE_NPS
```

```
## Warning: Removed 22 rows containing missing values (`geom_smooth()`).
```

<img src="53_NPSmediation_files/figure-html/unnamed-chunk-11-1.png" width="672" />

```r
library(ggplot2)

min_value <- -40
max_value <- 40
p.demean$sub <- factor(p.demean$sub)
plot.PE_NPS <- ggplot(p.demean, aes(x = RATING_expectation, y = NPSpos)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  ylim(-40, 40) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
plot.PE_NPS
```

```
## Warning: Removed 48 rows containing non-finite values (`stat_smooth()`).
## Removed 48 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 48 rows containing missing values (`geom_point()`).
```

<img src="53_NPSmediation_files/figure-html/unnamed-chunk-12-1.png" width="672" />


```r
ggplot(p.demean, aes(x=NPS_cmc, y=OUTCOME_cmc)) + 
  geom_point() + 
  theme_minimal() + 
  labs(x = "NPS cmc", y = "Outcome cmc", title = "Scatter plot of NPS cmc vs. Outcome cmc")
```

<img src="53_NPSmediation_files/figure-html/unnamed-chunk-13-1.png" width="672" />

## 6. OUTCOME ~ NPS
### Q. Do higher NPS values indicate higher outcome ratings? (Pain task only) {.unlisted .unnumbered}

> Yes, Higher NPS values are associated with higher outcome ratings. The linear relationship between NPS value and outcome ratings are stronger for conditions where cue level is congruent with stimulus intensity levels. In other words, NPS-outcome rating relationship is stringent in the low cue-low intensity group, as is the case for high cue-ghigh intensity group. 

<img src="53_NPSmediation_files/figure-html/unnamed-chunk-14-1.png" width="672" />
> NPS_demean is the within subject data, removing each subject's mean NPS response. Centering around the person’s mean (also known as centering within clusters; CWC) NPS_cmc is the subject's mean NPS response.
> 


```r
# NPS.between_within <- lmer(RATING_outcome ~ NPS_demean + NPS_cmc + (1|sub), data = p.demean)
NPS.between_within <- lmer(RATING_outcome ~ NPS_demean + NPS_cmc + (1|sub), data = p.demean)
summary(NPS.between_within)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: RATING_outcome ~ NPS_demean + NPS_cmc + (1 | sub)
##    Data: p.demean
## 
## REML criterion at convergence: 41695.5
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.0285 -0.6229  0.0134  0.6156  4.0915 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 904.4    30.07   
##  Residual             603.3    24.56   
## Number of obs: 4468, groups:  sub, 100
## 
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept) 6.505e+01  3.035e+00 9.799e+01  21.435  < 2e-16 ***
## NPS_demean  3.687e-01  4.477e-02 4.367e+03   8.235 2.34e-16 ***
## NPS_cmc     8.547e-01  5.149e-01 9.789e+01   1.660      0.1    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##            (Intr) NPS_dm
## NPS_demean  0.000       
## NPS_cmc    -0.014  0.000
```


```r
p.demean$NPS_within <- p.demean$NPS_demean
p.demean$NPS_between <- p.demean$NPS_cmc
p.demean$EXPECT_within <- p.demean$EXPECT_demean
p.demean$EXPECT_between <- p.demean$EXPECT_cmc

model.nps <- lmer(NPSpos ~ EXPECT_demean + EXPECT_cmc + (1|sub), data = p.demean)
summary(model.nps)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: NPSpos ~ EXPECT_demean + EXPECT_cmc + (1 | sub)
##    Data: p.demean
## 
## REML criterion at convergence: 31893.3
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -6.0829 -0.4784 -0.0113  0.5001  6.4154 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 32.23    5.678   
##  Residual             68.75    8.292   
## Number of obs: 4468, groups:  sub, 100
## 
## Fixed effects:
##                 Estimate Std. Error         df t value Pr(>|t|)    
## (Intercept)    6.527e+00  5.840e-01  9.796e+01  11.175   <2e-16 ***
## EXPECT_demean -1.413e-02  4.361e-03  4.367e+03  -3.240   0.0012 ** 
## EXPECT_cmc     4.034e-02  2.012e-02  9.775e+01   2.005   0.0477 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) EXPECT_d
## EXPECT_demn 0.000          
## EXPECT_cmc  0.013  0.000
```

```r
model.npsmd <- lmer(RATING_outcome ~ NPS_demean + NPS_cmc + EXPECT_demean + EXPECT_cmc + (1|sub), data = p.demean)
summary(model.npsmd)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: RATING_outcome ~ NPS_demean + NPS_cmc + EXPECT_demean + EXPECT_cmc +  
##     (1 | sub)
##    Data: p.demean
## 
## REML criterion at convergence: 40952.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.2385 -0.5905 -0.0120  0.6128  5.0233 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 150.3    12.26   
##  Residual             527.9    22.98   
## Number of obs: 4468, groups:  sub, 100
## 
## Fixed effects:
##                 Estimate Std. Error         df t value Pr(>|t|)    
## (Intercept)     65.46425    1.28284   95.36111  51.031   <2e-16 ***
## NPS_demean       0.42009    0.04193 4364.74874  10.019   <2e-16 ***
## NPS_cmc         -0.06948    0.22194   95.55792  -0.313    0.755    
## EXPECT_demean    0.30267    0.01210 4364.74874  25.016   <2e-16 ***
## EXPECT_cmc       0.95734    0.04510   95.50844  21.229   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) NPS_dm NPS_cm EXPECT_d
## NPS_demean   0.000                       
## NPS_cmc     -0.016  0.000                
## EXPECT_demn  0.000  0.049  0.000         
## EXPECT_cmc   0.016  0.000 -0.201  0.000
```

```r
# vif(model.npsmd)
```


```r
iv1 = "NPSpos"
nbins = 10

p.demean <- p.demean %>%
  dplyr::group_by(sub) %>%
  mutate(NPS_demean = NPSpos - mean(NPSpos)) %>%
  mutate(bin = ggplot2::cut_interval(as.numeric(NPS_demean), n = nbins)) %>%
  mutate(NPSlevels = as.numeric(bin))

NPS <- lmer(RATING_outcome~ NPSpos + (NPSlevels|sub), data = p.demean)
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
summary(NPS)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: RATING_outcome ~ NPSpos + (NPSlevels | sub)
##    Data: p.demean
## 
## REML criterion at convergence: 41704.5
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -3.9798 -0.6202  0.0148  0.6137  4.0749 
## 
## Random effects:
##  Groups   Name        Variance  Std.Dev.  Corr
##  sub      (Intercept) 6.098e+02 24.694844     
##           NPSlevels   1.210e-05  0.003478 1.00
##  Residual             6.079e+02 24.654675     
## Number of obs: 4468, groups:  sub, 100
## 
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept) 6.288e+01  2.685e+00 1.070e+02   23.42   <2e-16 ***
## NPSpos      3.729e-01  4.472e-02 4.414e+03    8.34   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##        (Intr)
## NPSpos -0.110
## optimizer (nloptwrap) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```
## what is the relationshipe between expect-> NPS and NPS -> pain
Participants with the most positive expectancy effects on NPS also have the most positive NPS-pain relationships (to verify...).

```r
model.1 <- lme4::lmer(NPSpos ~ RATING_expectation + (RATING_expectation|sub), data = p.demean)
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## Model failed to converge with max|grad| = 7.56891 (tol = 0.002, component 1)
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, : Model is nearly unidentifiable: very large eigenvalue
##  - Rescale variables?
```

```r
summary(model.1)
```

```
## Linear mixed model fit by REML ['lmerMod']
## Formula: NPSpos ~ RATING_expectation + (RATING_expectation | sub)
##    Data: p.demean
## 
## REML criterion at convergence: 31899.8
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -6.0617 -0.4793 -0.0073  0.4988  6.3994 
## 
## Random effects:
##  Groups   Name               Variance  Std.Dev. Corr 
##  sub      (Intercept)        6.557e+01 8.09763       
##           RATING_expectation 9.695e-04 0.03114  -0.04
##  Residual                    6.724e+01 8.20027       
## Number of obs: 4468, groups:  sub, 100
## 
## Fixed effects:
##                     Estimate Std. Error t value
## (Intercept)         7.220869   0.868583   8.313
## RATING_expectation -0.012402   0.005626  -2.204
## 
## Correlation of Fixed Effects:
##             (Intr)
## RATING_xpct -0.286
## optimizer (nloptwrap) convergence code: 0 (OK)
## Model failed to converge with max|grad| = 7.56891 (tol = 0.002, component 1)
## Model is nearly unidentifiable: very large eigenvalue
##  - Rescale variables?
```

```r
model.2 <- lmer(RATING_outcome ~ NPSpos + (NPSpos|sub), data = p.demean)
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, :
## Model failed to converge with max|grad| = 0.00319433 (tol = 0.002, component 1)
```

```r
summary(model.2)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: RATING_outcome ~ NPSpos + (NPSpos | sub)
##    Data: p.demean
## 
## REML criterion at convergence: 41673.2
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -4.0533 -0.6216  0.0144  0.6105  4.1136 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr 
##  sub      (Intercept) 880.4829 29.6729       
##           NPSpos        0.1926  0.4389  -0.04
##  Residual             592.4063 24.3394       
## Number of obs: 4468, groups:  sub, 100
## 
## Fixed effects:
##             Estimate Std. Error      df t value Pr(>|t|)    
## (Intercept)  62.0918     3.0143 98.7152  20.599  < 2e-16 ***
## NPSpos        0.4128     0.0687 63.9282   6.009 9.79e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##        (Intr)
## NPSpos -0.104
## optimizer (nloptwrap) convergence code: 0 (OK)
## Model failed to converge with max|grad| = 0.00319433 (tol = 0.002, component 1)
```

```r
fixEffect1 <- as.data.frame(fixef(model.1))
randEffect1 <- as.data.frame(ranef(model.1))
RE_expectation <- randEffect1 %>%
  filter(term == "RATING_expectation")
fixEffect2 <- as.data.frame(fixef(model.2))
randEffect2 <- as.data.frame(ranef(model.2))
RE_NPS <- randEffect2 %>%
  filter(term == "NPSpos")
model.NPSexpectation <- lm(RE_NPS$condval ~ RE_expectation$condval)
model.NPSexpectationvariance <- lm(RE_NPS$condval ~ RE_expectation$condsd)
summary(model.NPSexpectation)
```

```
## 
## Call:
## lm(formula = RE_NPS$condval ~ RE_expectation$condval)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -0.52657 -0.13211 -0.02189  0.09599  0.81942 
## 
## Coefficients:
##                          Estimate Std. Error t value Pr(>|t|)    
## (Intercept)            -8.254e-16  2.422e-02   0.000        1    
## RE_expectation$condval  8.130e+00  1.383e+00   5.877 5.77e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.2422 on 98 degrees of freedom
## Multiple R-squared:  0.2606,	Adjusted R-squared:  0.2531 
## F-statistic: 34.54 on 1 and 98 DF,  p-value: 5.765e-08
```


--- 
title: "A Minimal Book Example"
author: "John Doe"
date: "2023-03-22"
site: bookdown::bookdown_site
documentclass: book
bibliography: [book.bib, packages.bib]
# url: your book url like https://bookdown.org/yihui/bookdown
# cover-image: path to the social sharing image like images/cover.jpg
description: |
  This is a minimal example of using the bookdown package to write a book.
  The HTML output format for this example is bookdown::gitbook,
  set in the _output.yml file.
link-citations: yes
github-repo: rstudio/bookdown-demo
---

# url: your book url like https://bookdown.org/yihui/bookdown

Placeholder


## Usage 
## Render book
## Preview book

<!--chapter:end:index.Rmd-->

# Hello bookdown 

All chapters start with a first-level heading followed by your chapter title, like the line above. There should be only one first-level heading (`#`) per .Rmd file.

## A section

All chapter sections start with a second-level (`##`) or higher heading followed by your section title, like the sections above and below here. You can have as many as you want within a chapter.

### An unnumbered section {-}

Chapters and sections are numbered by default. To un-number a heading, add a `{.unnumbered}` or the shorter `{-}` at the end of the heading, like in this section.

<!--chapter:end:01-intro.Rmd-->


# [beh] expectation ~ cue {#ch2_expect}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## Pain
### For the pain task, what is the effect of cue on expectation ratings? {.unlisted .unnumbered}
## Vicarious
### For the vicarious task, what is the effect of cue on expectation ratings? {.unlisted .unnumbered}
## Cognitive
### For the cognitive task, what is the effect of cue on expectation ratings? {.unlisted .unnumbered}
## Individual difference analysis
### Are cue effects (on expectation ratings) similar across tasks? {.unlisted .unnumbered}

<!--chapter:end:02_iv-cue_dv-expect.Rmd-->


# [ beh ] outcome ~ cue {#ch03_cue}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## Pain
### For the vicarious task, what is the effect of cue on outcome ratings? {.unlisted .unnumbered}
## Vicarious
### For the vicarious task, what is the effect of cue on outcome ratings? {.unlisted .unnumbered}
## Cognitive
### For the cognitive task, what is the effect of cue on outcome ratings? {.unlisted .unnumbered}
## Individual differences analysis: random cue effects
## Individual differences analysis 2: random intercept + random slopes of cue effect

<!--chapter:end:03_iv-cue_dv-actual.Rmd-->


# [ beh ] outcome ~ stimulus_intensity {#ch04_outcome-stim}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## Pain
### For the pain task, what is the effect of stimulus intensity on outcome ratings? {.unlisted .unnumbered}
## Vicarious
### For the vicarious task, what is the effect of stimulus intensity on outcome ratings? {.unlisted .unnumbered}
## Cognitive
### For the cognitive task, what is the effect of stimulus intensity on outcome ratings? {.unlisted .unnumbered}
## for loop
## Lineplot
## individual differences in outcome rating cue effect 

<!--chapter:end:04_iv-stim_dv-actual.Rmd-->


# outcome_rating ~ cue * stim {#ch05_outcome-cueXstim}

Placeholder


## What is the purpose of this notebook? 
## model 03 iv-cuecontrast dv-actual
### model 03 3-2. individual difference
### model 04 iv-cue-stim dv-actual
### model 04 4-2 individual differences in cue effects
### model 04 4-3 scatter plot
### model 04 4-4 lineplot

<!--chapter:end:05_iv-cue-stim_dv-actual.Rmd-->


# [beh] outcome_rating ~ cue * stim {#ch05_outcome-cueXstim}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## load data
## lmer
## full random slopes
## remove interaction randomslopes
## remove correlated random slope
## repeated measures
## converges with more than 36 observations?

<!--chapter:end:05_lmer_iv-cuestim_dv-outcome.Rmd-->


# expect-actual ~ cue * trial {#ch06_Jepma}

Placeholder


## Overview
### Some thoughts, TODOs {.unlisted .unnumbered}
## plot 1 - one run, average across participants
## plot 2 - average across participant, but spread all 6 runs in one x axis
### p2 :: check number of trials per participant {.unlisted .unnumbered}
### p2 :: identify erroneous participant {.unlisted .unnumbered}
### p2 :: convert to long form {.unlisted .unnumbered}
### p2 :: plot data {.unlisted .unnumbered}
## Do current expectation ratings predict outcome ratings?
### Additional analyse 01/18/2023 {.unlisted .unnumbered}
## Additional analysis

<!--chapter:end:06_iv-cue-trial_dv-expect-actual_jepma.Rmd-->


# [beh] RT ~ cue {#ch07_RT-cue}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
### parameters
### 1) plot RT data
### plot RT distribution per participant
### exclude participants with RT of 5 seconds
## model 1: 
## model 1-1
## model 1-2: 
## model 2: 

<!--chapter:end:07_iv-cue_dv-RT_FIX.Rmd-->


# [beh] RT ~ cue * stim {#ch08_RT-cueXstim}

Placeholder


## Overview model 05 iv-cue dv-RT summary
## Prepare data and preprocess
### 1) load data  {.unlisted .unnumbered}
### 2) plot RT distribution per participant  {.unlisted .unnumbered}
### 3) exclude participants with RT of 5 seconds  {.unlisted .unnumbered}
## model 1: 
## model 1-1
## model 1-2: 
## model 2: Log transformation
## Conclusion across model 1 and 2

<!--chapter:end:08_iv-cue-stim_dv-RT_FIX.Rmd-->


# cognitive RT tradeoff ~ cue * stim (withinsubject) {#ch09_tradeoff-cueXstim}

Placeholder


## Overview
## Why use multilevel models?
## Terminology
## Model versions {.tabset}
### Method 1: repeated measures and `one-sample t-tests` {.unlisted .unnumbered}
### Method 1-1: repeated measures using `**aov**` in R {.unlisted .unnumbered}
### Method 2: multilevel modeling using `**glmfit_multilevel**` in matlab {.unlisted .unnumbered}
### Method 3: multilevel modeling using `**lmer**` in R {.unlisted .unnumbered}
## Method 1 one-sample t
### Method 1 one-sample t {.unlisted .unnumbered}
### Method 1 effectsize {.unlisted .unnumbered}
## Method 1-1 aov 
### Method 1-1 effectsize {.unlisted .unnumbered}
## Method 1-2 aov contrast-coding
### Method 1-2 effectsize {.unlisted .unnumbered}
## Method 1 effectsize
### Method 1 effectsize estimate (one-sample t-test) {.unlisted .unnumbered}
### Method 1-1 effectsize estimate (one-sample t-test) {.unlisted .unnumbered}
### Method 1-2 effectsize estimate (one-sample t-test) {.unlisted .unnumbered}
## Method 2 matlab {.tabset}
### Method 2 matlab {.unlisted .unnumbered}
## Method 3 multilevel modeling
## Method 3 - Effect size estimates {.unlisted .unnumbered}
## Method 3 plotting {.unlisted .unnumbered}
## Conclusion: Method 1 vs Method 3 {.unnumbered}
### **Comparison between Method 1 and Method 3** {.unlisted .unnumbered}
#### 1) Statistics of Cue effect {.unlisted .unnumbered}
#### 4) Interaction effect {.unlisted .unnumbered}
### In otherwords, the results are identical. {.unlisted .unnumbered}
## References
## Other links

<!--chapter:end:09_iv-cue-stim_dv-tradeoff_withinsubj.Rmd-->


# outcome_rating ~ session ("behavioral ICC") {#ch10_icc}

Placeholder


## Functions
## TODO:

<!--chapter:end:10_iv-session_dv-outcome_behavioral-ICC.Rmd-->


# [beh] N-1 outcome rating ~ N expectation rating {#ch11_n-1outcome}

Placeholder


### DONE {.unlisted .unnumbered}
### Overview  {.unlisted .unnumbered}
## expectation_rating ~ N-1_outcome_rating 
### Additional analyse 01/18/2023: Q. Do previous outcome ratings predict current expectation ratings? {.unlisted .unnumbered}
### Not sure whether this is accurate {.unlisted .unnumbered}
## Current expectation_rating ~ N-1_outcomerating * cue
### Additional analysis 01/23/2023 Q. Do these models differ as a function of cue? {.unlisted .unnumbered}
## Let's demean the ratings.
## DEMEAN AND THEN DISCRETIZE

<!--chapter:end:11_iv-cue-trial_dv-expectjayazeri_N-1.Rmd-->


#  (N-2) shifted outcome ratings ~ (N) expectation ratings; Jayazeri (2018) {#ch12_n-1outcome}

Placeholder


## Overview  {.unlisted .unnumbered}
## Do previous outcome ratings predict current expectation ratings?
### Additional analyse 01/18/2023 {.unlisted .unnumbered}
## Do these models differ as a function of cue?
### Additional analysis 01/23/2023 {.unlisted .unnumbered}
## Let's demean the ratings. {.unlisted .unnumbered}
### confirm that df discrete has 5 levels per participant
## Demean and discretize
### Check how many trials land in each outcome level  {.unlisted .unnumbered}

<!--chapter:end:12_iv-cue-trial_dv-expectjayazeri_N-2.Rmd-->


# outcome ~ expect Jayazeri (2018) {#ch13_outcome-expect}

Placeholder


### TODO  {.unlisted .unnumbered}
## Overview 
## Do expectation ratings predict current outcome ratings? Does this differ as a function of cue?
## task-pain, HLM modeling
## Fig. Expectation ratings predict outcome ratings 
## TODO: PLOT participant rating  {.unlisted .unnumbered}
## Check bin process {.unlisted .unnumbered}
### Let's demean the ratings for one participant  {.unlisted .unnumbered}
### subjectwise plot {.unlisted .unnumbered}
## binned expectation ratings per task
### Pain: binned expectation ratings
#### Pain: low and high cues separately
### Vicarious: binned expectation ratings
### Cognitive: binned expectation ratings
## not splitting into cue groups

<!--chapter:end:13_iv-cue-trial_dv-expectjayazeri.Rmd-->


# [ beh ] outcome ~ cue * stim * expectrating * n-1outcomerating  {#ch14_factorize}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
### Some thoughts, TODOs {.unlisted .unnumbered}
### load data and combine participant data {.unlisted .unnumbered}
### summarize data {.unlisted .unnumbered}
### Covariance matrix: ratings and RT {.unlisted .unnumbered}
### Covariance matrix: fixation durations (e.g. ISIs) {.unlisted .unnumbered}
## Original motivation: 
## Pain
### linear model {.unlisted .unnumbered}
### pain plot parameters
### Pain run, collapsed across stimulus intensity {.unlisted .unnumbered}
### loess
### ODR distance: Q. Are those overestimating for high cues also underestimators for low cues?  {.unlisted .unnumbered}
## Vicarious
### Vicarious linear model {.unlisted .unnumbered}
### Vicarious run, collapsed across stimulus intensity {.unlisted .unnumbered}
### ODR distance: Q. Are those overestimating for high cues also underestimators for low cues?  {.unlisted .unnumbered}
## Cognitive
### Cognitive linear model {.unlisted .unnumbered}
### cognitive parameters
### Cognitive run, collapsed across stimulus intensity {.unlisted .unnumbered}
### ODR distance: Q. Are those overestimating for high cues also underestimators for low cues?  {.unlisted .unnumbered}

<!--chapter:end:14_iv-cue-stim-outcome-expect_dv-outcome.Rmd-->


# [ beh ] outcome_demean ~ cue * stim * expectrating * n-1outcomerating  {#ch15_demean_per_sub}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
### Some thoughts, TODOs {.unlisted .unnumbered}
### groupby subject and average
## linear model
## Q. Are those overestimating for high cues also underestimators for low cues?
## pain run, collapsed across stimulus intensity
## vicarious
## cognitive
## across tasks (PVC), is the  slope for (highvslow cue) the same?Tor question

<!--chapter:end:15_iv-cue-stim-outcome-expect_dv-outcome_demean.Rmd-->


# [ beh ] outcome_demean_per_run ~ cue * stim * expectrating * n-1outcomerating  {#ch16_demean_per_run}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
### Some thoughts, TODOs {.unlisted .unnumbered}
### Covariance matrix: ratings and RT {.unlisted .unnumbered}
### Covariance matrix: fixation durations (e.g. ISIs) {.unlisted .unnumbered}
## Linear model with three factors: cue X stim X expectation rating
## Pain run, collapsed across stimulus intensity
### Q. Are those overestimating for high cues also underestimators for low cues? {.unlisted .unnumbered}
## vicarious
## cognitive
## across tasks (PVC), is the  slope for (highvslow cue) the same?Tor question

<!--chapter:end:16_iv-cue-stim-outcome-expect_dv-outcome_demean_per_run.Rmd-->


# [beh] Mediation outcome ~ cue * stim * expectrating * n-1outcomerating  {#ch17_mediation}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
### Some thoughts, TODOs {.unlisted .unnumbered}
### Covariance matrix: ratings and RT {.unlisted .unnumbered}
### Covariance matrix: fixation durations (e.g. ISIs) {.unlisted .unnumbered}
## mediation
## mediation 2
## mediation 3: Test same model using mediation() from MBESS
## mediation 4: Test library mediation

<!--chapter:end:17_mediation_cue-stim-expect_outcome.Rmd-->


# [beh] RL simulation {#ch18_simulation}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## load data {.unlisted .unnumbered}
## function
## plot data {.unlisted .unnumbered}
### model 04 4-4 lineplot

<!--chapter:end:18_RLsimulation.Rmd-->

---
title: "model_generated_pain"
author: "Heejung Jung"
date: "2023-05-08"
output: html_document
---



## load data

## plot using same scheme as iv15




### groupby subject and average

## pain run, collapsed across stimulus intensity
<img src="19_RLsimulation_Aryan_files/figure-html/unnamed-chunk-2-1.png" width="672" />
<img src="19_RLsimulation_Aryan_files/figure-html/unnamed-chunk-3-1.png" width="672" />

## model version 2

### groupby subject and average

## pain run, collapsed across stimulus intensity
<img src="19_RLsimulation_Aryan_files/figure-html/unnamed-chunk-5-1.png" width="672" />
<img src="19_RLsimulation_Aryan_files/figure-html/unnamed-chunk-6-1.png" width="672" />

<!--chapter:end:19_RLsimulation_Aryan.Rmd-->


# [model] NPSsimulation {#ch20_npssimulation}

Placeholder


### Function
### NPS data
### behavioral data
### Q. Within pain task, Does stimulus intenisty level and cue level significantly predict NPS dotproducts? {.unlisted .unnumbered}
### get pain relationship, controlling for cue, cuetype, expect
## simulation **
## Lineplots Original {.unlisted .unnumbered}
### Lineplots P.assim {.unlisted .unnumbered}
### P.assim ~ demeaned_expect * cue * stim
### Lineplots P.pe {.unlisted .unnumbered}
### P.pe ~ demeaned_expect * cue * stim
### Lineplots P.adapt {.unlisted .unnumbered}
### P.adapt ~ demeaned_expect * cue * stim

<!--chapter:end:20_NPS_simulation.Rmd-->


# [RL] model fit data {#ch22_RL}

Placeholder


## behavioral outcome ratings ~ expectations * cue
## behavioral demeaned (both)
## behavioral only expectaiton deman
## behavioral :: line plot cue * stim (outcome demena)
### model 04 4-4 lineplot (demean)
## behavioral :: line plots cue * stim * intensity (demean outcome)
## behavioral :: line plots cue * stim * intensity (demean outcome)
## NPS: stim * cue
### Fig B: cue * stim lineplot
### NPS demeaned: stim*cue
### lmer
### NPS: cue * expect (expect demean)
### NPS: cue * expect (both demean)
### NPS: stim * cue * expect
### NPS: stim * cue * expect (demean)
### NPS demeaned (both)
### NPS demeaned cue *expect
## Behavioral data
### lmer
### Fig A2: behavioral demeaned (both)
### Fig A1: behavioral lineplots
### Fig A1, A2, B
### Fig C: behavioral cue * stim * expect
## Model fit (model)
### plot 
### 3 way interaction behavioral :: line plots cue * stim * intensity (demean outcome)
## congruent incongruent
### 3 way interaction behavioral :: line plots cue * stim * intensity (demean outcome)
### Fig D: 3 panel cue * stim * expect
## congruent incongruent for model fitted results
## save dataframe

<!--chapter:end:22_RLmodelfit.Rmd-->


# RL simulation Jepma PE {#ch23_jepmaPE}

Placeholder


## Overview
### Some thoughts, TODOs {.unlisted .unnumbered}
## load behavioral daata
## JEPMA
## PREVIOUS TRIAL w/o dividing (PE+1)
## NEXT TRIAL WITHOUT DIVIDING (PE+1)

<!--chapter:end:23_RL_jepma_simulation_PE.Rmd-->


# PE and NPS {#ch24_RL_PE_NPS}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## scatter plot
## re-run brain results from `XX.md`
## re-run behavioral results from `XX.Rmd`

<!--chapter:end:24_RL_iv-PE_dv-NPS.Rmd-->


# [model] RL-simulated PE & NPS{#ch25_NPSandPE}

Placeholder


## The purpose of this notebook? {.unlisted .unnumbered}
### load dataframe
### some data wrangling: 
### rename RL dataframe so that columns are identical. we will merge on these columns
### merge the two dataframes
### remove bad runs
### calculate behavioral PE
## NPS plot N = 120
## contrast coding for the merged dataframe
## A. NPS plot N = 60
## B. PE plot
## C. behavior PE plot
## D. outcome rating plot
## 1. Relationship between NPS and PE
### 1.1 lmer model 1 - NPSpos_demean ~ PE + (PE | sub) >> singular
### 1.2 lmer model 2 - No demean: NPSpos ~ PE + ( PE | sub)
### 1.3 lmer model 3
### 1.4 plot group level slope of PE & NPS, alongside subjectwise slopes
#### 1.4.1 subsetting medium intensity value - are the aforementioned effects mainly driven by the medium stimulus intensity?
#### 1.4.2 subsetting high intensity value - are the aforementioned effects mainly driven by the medium stimulus intensity?
#### 1.4.3 subsetting low intensity value - are the aforementioned effects mainly driven by the medium stimulus intensity?
## 2. Relationship between behavioral PE and NPS
### 2.1 lmer model 1 - NPSpos_demean ~ PE + (PE | sub) >> singular
### 2.2 lmer model 2 - No demean: NPSpos ~ PE + ( PE | sub)
### 2.3 lmer model 3
### 2.4 plot behavioral PE & NPS.
## 3. What did I submit to SfN?
### 3.1 test relationship between PE and cue type and stimintensity (06/16/2023)
### 3.2 plot using PE and NPS as a function of cue
### 3.3 plot the relationship between PE and NPS as a function of cue and stimulus intensity
## 4. Manipulation check: bin the Jepma PE levels and look at the relationship with behavioral PE
## 5. Relationshipe between NPS and binned PE
### 5.1 lmer
### 5.2. plot NPS and binned PE (jepma)
### 5.3 plot NPS and binned PE (within subjects: average within bins -> aggregate this at the group lvel)
### 5.4. plot NPS,binned PE and cue type
### 5.5 plot the relationship between PE and NPS as a function of cue and stimulus intensity

<!--chapter:end:25_RL_NPS.Rmd-->


# NPS_contrast_notscaled ~ cue * stim {#nps_contrast_notscaled}

Placeholder


## Overview
## regressors and contrasts
### What regressors were used in the neural model and how did you create contrasts? {.unlisted .unnumbered}
## main effect: stim-linear high > low
### Linear effect of stimulus intensity {.unlisted .unnumbered}
## main_effect: stim-quadratic med > high&low
### Quadratic effect of stimulus intensity {.unlisted .unnumbered}
## interaction: cue X stim-linear
### Interaction between cue effect and stimulus intensity {.unlisted .unnumbered}
## interaction: cue X stim-quadratic
### Interaction between cue effect and quadratic effect of stimulus intensity {.unlisted .unnumbered}

<!--chapter:end:31-iv-cue-stim_dv-nps_contrast_notscaled.Rmd-->


# [fMRI] NPS_contrast ~ cue * stim {#ch31_npscontrast}

Placeholder


## Overview
## regressors and contrasts
### What regressors were used in the neural model and how did you create contrasts? {.unlisted .unnumbered}
## main effect: stim-linear high > low
### Linear effect of stimulus intensity {.unlisted .unnumbered}
## main_effect: stim-quadratic med > high&low
### Quadratic effect of stimulus intensity {.unlisted .unnumbered}
## interaction: cue X stim-linear
### Interaction between cue effect and stimulus intensity {.unlisted .unnumbered}
## interaction: cue X stim-quadratic
### Interaction between cue effect and quadratic effect of stimulus intensity {.unlisted .unnumbered}

<!--chapter:end:31-iv-cue-stim_dv-nps_contrast.Rmd-->


# [fMRI] nps_contrast ~ cue * stim ("error, contrast not scaled") {#nps_dummy_notscaled}

Placeholder


## Overview 
### For loop for all the pvc dummy codes {.unlisted .unnumbered}
## contrast plot

<!--chapter:end:32-iv-cue-stim_dv-nps_dummy_notscaled.Rmd-->


# [fMRI] nps_contrast ~ cue * stim {#ch32_nps_dummy}

Placeholder


## Overview 
## 'P_simple_stimlin_high_gt_low', 'V_simple_stimlin_high_gt_low', 'C_simple_stimlin_high_gt_low',...
## 'P_simple_stimquad_med_gt_other', 'V_simple_stimquad_med_gt_other', 'C_simple_stimquad_med_gt_other',...
## For loop for all the pvc dummy codes

<!--chapter:end:32-iv-cue-stim_dv-nps_dummy.Rmd-->


# nps_dummy ~ stim {#nps_stim}

Placeholder


## TODO
## regressors and contrasts
### What regressors were used in the neural model and how did you create contrasts? {.unlisted .unnumbered}
## Functions
## Pain
## Vicarious
## Cognitive

<!--chapter:end:33_iv-stim-dv-nps-dummy_notscaled.Rmd-->


# [fMRI] biomarker NPS ~ cue * stim (2022) {#nps_22}

Placeholder


## load libraries
### NPS load csv file {.unlisted .unnumbered}
### NPS run 2 factor model (task x cue) {.unlisted .unnumbered}
### NPS cue effect
## NPS stim effect
## VPS
### VPS load csv file {.unlisted .unnumbered}
### VPS run 2 factor model (task x cue) {.unlisted .unnumbered}
## VPS cue effect
## VPS stim effect

<!--chapter:end:34_iv-cue-stim_dv-biomarker22.Rmd-->


# [fMRI] NPSdummy ~ stim * task (contrast-notscaled-error) {#nps_stim_error}

Placeholder


## Overview  {.unlisted .unnumbered}
### Raincloud plots
### Line plots

<!--chapter:end:34_iv-task-stim_dv-nps_dummy_notscaled.Rmd-->


# NPSdummy ~ stim * task (contrast-scaled) {#nps_stim_task}

Placeholder


## Function {.unlisted .unnumbered}
## Common parameters {.unlisted .unnumbered}
## Raincloud plots
## Line plots

<!--chapter:end:34_iv-task-stim_dv-nps_dummy.Rmd-->


# [fMRI] NPS ~ singletrial {#ch99_singletrial_clean}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## 1. NPS ~ 3 task x 3 stimulus intensity
#### Contrast weight table {.unlisted .unnumbered}
## 2. NPS ~ paintask: 2 cue x 3 stimulus_intensity
### Q. Within pain task, Does stimulus intenisty level and cue level significantly predict NPS dotproducts? {.unlisted .unnumbered}
### Lineplots with only low cue {.unlisted .unnumbered}
### Lineplots {.unlisted .unnumbered}
### Lineplots {.unlisted .unnumbered}
### Linear model results (NPS ~ paintask: 2 cue x 3 stimulus_intensity)
#### Linear model eta-squared {.unlisted .unnumbered}
#### Linear model Cohen's d: NPS stimulus_intensity d = 1.16, cue d = 0.45 {.unlisted .unnumbered}
## 3. NPS ~ SES * CUE * STIM
### Q. Is the cue effect on NPS different across sessions? {.unlisted .unnumbered}
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
#### Session wise plots {.unlisted .unnumbered}
#### session wise line plots {.unlisted .unnumbered}
## 4. [INCORRECT] no cmc NPS ~ CUE * STIM * EXPECT 
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
## 6. OUTCOME ~ NPS
### Q. Do higher NPS values indicate higher outcome ratings? (Pain task only) {.unlisted .unnumbered}
### 6-1. outcome_rating * cue
### 6-2. outcome_rating * stimulus_intensity * cue
### 6-3. demeaned outcome rating * cue
### 6-4. demeaned outcome rating ~ demeaned NPS
### facet wrap
### 6-4. demeaned_outcome_rating * stimulus_intensity * cue
#### Is 6-4 this statistically significant? (without CMC subjectwise mean) {.unlisted .unnumbered}
### 6-5. OUTCOMEdemean ~ NPSdemean
### 6-6. demeaned_outcome_rating ~ stimulus_intensity * cue * NPS demean
## 7. NPS ~ expectation_rating
### Q. What is the relationship betweeen expectation ratings & NPS? (Pain task only) {.unlisted .unnumbered}
### 7-1. [ correct ] NPS ~ demeaned_expect * cue {.unlisted .unnumbered}
### 7-1-2. NPS ~ EXPECT * cue {.unlisted .unnumbered} + CMC
### 7-2. [ correct ] NPS ~ demeaned_expect * cue * stim {.unlisted .unnumbered}
### 7-3. NPS_demean ~ demeaned_expect * cue * stim {.unlisted .unnumbered}
### 7-3. [ correct ] NPS ~ EXPECTdemean x CUE x STIM + CMC {.unlisted .unnumbered}
### ICC
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
## 7-3 simple slopes when STIM == 'high', EXPECT_demean slope difference between high vs. low cue {.unlisted .unnumbered}
#### emtrneds {.unlisted .unnumbered}
## 8. NPS and session effects
#### 8-1. [ correct ] NPS ~ EXPECT_demean * CUE * STIM + CMC (Session as covariate)
#### 8-2. [ correct ] NPS ~ EXPECT_demean * CUE * STIM * SES + CMC (Session as interaction) 
## 9. plotly 3 factors
#### 3x3 plots EXPECT_demean
#### NPSpos ~ EXPECT_demean * STIM * CUE
## 9. NPS ~ trial order
### trial order * cue
### trial order only
## vicarious
### trial order * cue
### trial order only
## cognitive
### trial order * cue
### trial order only

<!--chapter:end:35_iv-task-stim_dv-nps_singletrial_clean.Rmd-->


# fMRI Pain signature ~ single trial {#ch36_singletrial_V}

Placeholder


## Function {.unlisted .unnumbered}
## Step 1: Common parameters {.unlisted .unnumbered}
### Load behavioral data {.unlisted .unnumbered}
## PVC all task comparison
## Vicarious only Stim x cue interaction
### 2x3 stimulus intensity * cue 
### Linear model
### VPS stimulus intensity Cohen's d = 0.2131521
### VPS stimulus & cue effect size: stim_d = 0.217, cue_d = 0.013
### Lineplots
### Linear model with Stim x Cue x Expectation rating
## Vicarious only: Outcome ratings & VPS
### outcome ratings * cue
### outcome ratings * stim * cue
## Vicarious only: Expectation ratings & VPS

<!--chapter:end:36_iv-task-stim_dv-vps_singletrial.Rmd-->


# Cognitive signature ~ single trial {#ch37_singletrial_C}

Placeholder


## Function {.unlisted .unnumbered}
## Step 1: Common parameters {.unlisted .unnumbered}
### Load behavioral data {.unlisted .unnumbered}
## PVC all task comparison
## Cognitive only Stim x cue interaction
### 2x3 stimulus intensity * cue 
### Linear model
### Cog stimulus intensity Cohen's d = 0.72
### Cognitive stimulus & cue effect size: stim_d = 0.73, cue_d = 0.069
### Lineplots
### Linear model with Stim x Cue x Expectation rating
### Session 1: 2x3 stimulus intensity * cue 
### Session 3: 2x3 stimulus intensity * cue 
### Session 4: 2x3 stimulus intensity * cue 
## Cognitive only: Outcome ratings & Kragel 2018
### outcome ratings * cue
### outcome ratings * stim * cue
## Cognitive only: Expectation ratings & NPS

<!--chapter:end:37_iv-task-stim_dv-cps_singletrial.Rmd-->


# single trial correlation between cue and stim ~ cue x stim {#ch38_singletrial_corr}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## Function {.unlisted .unnumbered}
## Stack data
## plot correlation (one-sample-t)
## Lineplot

<!--chapter:end:38_iv-corr_dv-singletrial.Rmd-->


# [fMRI] single trial QC {#ch39_singletrialqc}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## Reference {.unlisted .unnumbered}
## functions
## load data {.unlisted .unnumbered}
## trial-order wise {.unlisted .unnumbered}
### line plots {.unlisted .unnumbered}
### linear model: 
### trial order emmeans
## run wise {.unlisted .unnumbered}
### linear model: run/ses wise
### emmeans run wise

<!--chapter:end:39_checkrunsandtrialsNPS.Rmd-->


# signature effect size ~ single trial {#ch39_signature_effectsize}

Placeholder


## Function {.unlisted .unnumbered}
## Step 1: Common parameters {.unlisted .unnumbered}
## effeect size
## contrastt (stim intensity)
## layer in metadata

<!--chapter:end:39_iv-task-stim_dv-nps_singletrial_effectsize.Rmd-->


# [fMRI] NPS ~ singletrial {#ch40_EndersTofighi}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## 1. NPS ~ 3 task x 3 stimulus intensity
#### Contrast weight table {.unlisted .unnumbered}
## 2. NPS ~ paintask: 2 cue x 3 stimulus_intensity
### Q. Within pain task, Does stimulus intenisty level and cue level significantly predict NPS dotproducts? {.unlisted .unnumbered}
### Lineplots with only low cue {.unlisted .unnumbered}
### Lineplots {.unlisted .unnumbered}
### Lineplots {.unlisted .unnumbered}
### Linear model results (NPS ~ paintask: 2 cue x 3 stimulus_intensity)
#### Linear model eta-squared {.unlisted .unnumbered}
#### Linear model Cohen's d: NPS stimulus_intensity d = 1.16, cue d = 0.45 {.unlisted .unnumbered}
## 3. NPS ~ SES * CUE * STIM
### Q. Is the cue effect on NPS different across sessions? {.unlisted .unnumbered}
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
#### Session wise plots {.unlisted .unnumbered}
#### session wise line plots {.unlisted .unnumbered}
## 4. [INCORRECT] no cmc NPS ~ CUE * STIM * EXPECT 
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
## 6. OUTCOME ~ NPS
### Q. Do higher NPS values indicate higher outcome ratings? (Pain task only) {.unlisted .unnumbered}
### 6-1. outcome_rating * cue
### 6-2. outcome_rating * stimulus_intensity * cue
### 6-3. OUTCOMEgmc ~ NPScmc * cue
### 6-4. OUTCOMEgmc ~ NPScmc * cue * stim
#### Is 6-4 this statistically significant? (without CMC subjectwise mean) {.unlisted .unnumbered}
### 6-5. OUTCOMEgmc ~ NPSdemean
### facet wrap
### 6-6. OUTCOMEgmc ~ NPSdemean * cue * stim
## 7. NPS ~ expectation_rating
### Q. What is the relationship betweeen expectation ratings & NPS? (Pain task only) {.unlisted .unnumbered}
### 7. linear model
### GEORGE SUGGESTION
### 7-1. [correct] NPSgmc ~ EXPECTdemean * cue {.unlisted .unnumbered}
### 7-2. [correct] NPSgmc ~ EXPECTdemean * cue * stim {.unlisted .unnumbered}
### 7-3. [correct] NPSgmc ~ EXPECTcmc
### 7-4. [correct] NPSgmc ~ EXPECTcmc * cue * stim {.unlisted .unnumbered}
### ICC
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
## 7-3 simple slopes when STIM == 'high', EXPECT_demean slope difference between high vs. low cue {.unlisted .unnumbered}
#### emtrneds {.unlisted .unnumbered}
## 8. NPS and session effects
#### 8-1. [correct] NPS ~ EXPECT_demean * CUE * STIM + CMC (Session as covariate)
#### 8-2. [correct] NPS ~ EXPECT_demean * CUE * STIM * SES + CMC (Session as interaction) 
## 9. plotly 3 factors
#### 3x3 plots EXPECT_demean
#### NPSpos ~ EXPECT_demean * STIM * CUE
## 9. NPS ~ trial order
## pain
### trial order * cue
### trial order * cue * ses
### trial order cue * ses-03
### trial order cue * ses-03
### trial order only
## vicarious
### trial order * cue
### trial order only
## cognitive
### trial order * cue
### trial order only

<!--chapter:end:40_iv-task-stim_dv-nps_singletrial_Enders_Tofighi.Rmd-->


# [fMRI] NPS ~ singletrial {#ch41_EndersTofighi}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## 1. NPS \~ 3 task x 3 stimulus intensity
#### Contrast weight table {.unlisted .unnumbered}
### Linear model results (NPS \~ paintask: 2 cue x 3 stimulus_intensity)
#### Linear model eta-squared {.unlisted .unnumbered}
#### Linear model Cohen's d: NPS stimulus_intensity d = 1.16, cue d = 0.45 {.unlisted .unnumbered}
#### Contrast weight table {.unlisted .unnumbered}
## 2. NPS \~ paintask: 2 cue x 3 stimulus_intensity
### Q. Within pain task, Does stimulus intenisty level and cue level significantly predict NPS dotproducts? {.unlisted .unnumbered}
### Lineplots with only low cue {.unlisted .unnumbered}
### Lineplots {.unlisted .unnumbered}
### Lineplots {.unlisted .unnumbered}
### Linear model results (NPS \~ paintask: 2 cue x 3 stimulus_intensity)
#### Linear model eta-squared {.unlisted .unnumbered}
#### Linear model Cohen's d: NPS stimulus_intensity d = 1.16, cue d = 0.45 {.unlisted .unnumbered}
## 3. NPS \~ SES \* CUE \* STIM
### Q. Is the cue effect on NPS different across sessions? {.unlisted .unnumbered}
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
#### Session wise plots {.unlisted .unnumbered}
#### session wise line plots {.unlisted .unnumbered}
## 4. [INCORRECT] no cmc NPS \~ CUE \* STIM \* EXPECT {.unlisted .unnumbered}
#### eta squared {.unlisted .unnumbered}
#### Cohen's d {.unlisted .unnumbered}
## 6. OUTCOME \~ NPS
### Q. Do higher NPS values indicate higher outcome ratings? (Pain task only) {.unlisted .unnumbered}
### Linear model (without CMC subjectwise mean) {.unlisted .unnumbered}
### 6-0. No transformation {.unlisted .unnumbered}
### 6-1. outcome_rating \* cue {.unlisted .unnumbered}
### 6-2. outcome_rating \* stimulus_intensity \* cue {.unlisted .unnumbered}
### 6-3. OUTCOMEgmc \~ NPScmc \* cue {.unlisted .unnumbered}
### 6-4. OUTCOMEgmc \~ NPScmc \* cue \* stim
### 6-5. OUTCOMEgmc \~ NPSdemean {.unlisted .unnumbered}
### facet wrap {.unlisted .unnumbered}
### 6-6. OUTCOMEgmc \~ NPSdemean \* cue \* stim {.unlisted .unnumbered}
## 7. NPS \~ expectation_rating
### Q. What is the relationship betweeen expectation ratings & NPS? (Pain task only) {.unlisted .unnumbered}
### 7. linear model {.unlisted .unnumbered}
### 7-1. [correct] NPSgmc \~ EXPECTdemean \* cue {.unlisted .unnumbered}
### 7-2. [correct] NPSgmc \~ EXPECTdemean \* cue \* stim {.unlisted .unnumbered}
### 7-3. [correct] NPSgmc \~ EXPECTcmc {.unlisted .unnumbered}
### 7-4. [correct] NPSgmc \~ EXPECTcmc \* cue \* stim {.unlisted .unnumbered}
### 7-5. ICC
### eta squared {.unlisted .unnumbered}
### Cohen's d {.unlisted .unnumbered}
### 7-6 simple slopes when STIM == 'high', EXPECT_demean slope difference between high vs. low cue {.unlisted .unnumbered}
#### emtrneds {.unlisted .unnumbered}
## 8. NPS and session effects
#### 8-1. [correct] NPS \~ EXPECT_demean \* CUE \* STIM + CMC (Session as covariate) {.unlisted .unnumbered}
#### 8-2. [correct] NPS \~ EXPECT_demean \* CUE \* STIM \* SES + CMC (Session as interaction) {.unlisted .unnumbered}
## 9. plotly 3 factors
#### 3x3 plots EXPECT_demean {.unlisted .unnumbered}
#### NPSpos \~ EXPECT_demean \* STIM \* CUE {.unlisted .unnumbered}
## 9. NPS \~ trial order
## pain  {.tabset}
### trial order \* cue {.unlisted .unnumbered}
### trial order only {.unlisted .unnumbered}
## pain per session  {.tabset}
### trial order \* cue \* ses 01 {.unlisted .unnumbered}
### trial order \* cue \* ses-03 {.unlisted .unnumbered}
### trial order \* cue \* ses-04 {.unlisted .unnumbered}
## vicarious  {.tabset}
### trial order \* cue {.unlisted .unnumbered}
### trial order only {.unlisted .unnumbered}
## cognitive  {.tabset}
### trial order \* cue {.unlisted .unnumbered}
### trial order only {.unlisted .unnumbered}

<!--chapter:end:41_iv-task-stim_dv-nps_singletrialttl2.Rmd-->


# [fMRI] ROI ~ cue * stim {#ch41_painpathway}

Placeholder


## What is the purpose of this notebook? {.unlisted .unnumbered}
## common parameters
## merge two dataframes {.unlisted .unnumbered}
## plot task x intensity
## plot cue x intensity

<!--chapter:end:41_painpathway.Rmd-->


# vif {#vif}

Placeholder



<!--chapter:end:41_test_vif_calc.Rmd-->


# [fMRI] singletrial ~ subcortex {#ch42_singletrial_subcortex}

Placeholder


## Function {.unlisted .unnumbered}
## LMER
## Plot different axis

<!--chapter:end:42_iv-cue-stim_dv-singletrialsubcortex.Rmd-->


# [fMRI] singletrial ~ subcortex {#ch43_singletrial_cerebellum}

Placeholder


## Function {.unlisted .unnumbered}
## TODO: outline
## LMER

<!--chapter:end:43_iv-cue-stim_dv-singletrialcerebellum_TTL.Rmd-->


# [fMRI] singletrial ~ subcortex {#ch435_singletrial_cerebellum}

Placeholder


## Function {.unlisted .unnumbered}
## LMER

<!--chapter:end:43_iv-cue-stim_dv-singletrialcerebellum.Rmd-->



## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot
## high stim vs low stim
## high cue vs low cue

<!--chapter:end:45_iv-task-dv-fir.Rmd-->


# [fMRI] FIR ~ task {#ch47_fir_glasser}

Placeholder


## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot
## parameters {TODO: ignore}
## epoch: stim, high stim vs low stim
### PCA subjectwise
### PCA groupwise
### lmer per region
## epoch: stim, high cue vs low cue
## epoch: 6 cond

<!--chapter:end:47_iv-cue-stim_dv-firglasserSPM.Rmd-->


# 48_iv-cue-stim_dv-firglasserSPM_ttl2 {#ch48_timeseries}

Placeholder


## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot
## function
## parameters {TODO: ignore}
## epoch: stim, high stim vs low stim
### PCA subjectwise
### PCA subjectwise try 2
### PCA groupwise
## epoch: stim, high cue vs low cue
## rating
## epoch: 6 cond
## test
## epoch: cue, high cue vs low cue

<!--chapter:end:48_iv-6cond_dv-firglasserSPM_ttl2.Rmd-->


# 49_iv-cue-stim_dv-firglasserSPM_ttl1 {#ch49_timeseries}

Placeholder


## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot
## parameters {TODO: ignore}
## epoch: stim, high stim vs low stim
### PCA subjectwise
### PCA groupwise
## epoch: stim, high cue vs low cue
## epoch: stim, rating
## epoch: 6 cond

<!--chapter:end:49_iv-6cond_dv-firglasserSPM_ttl1.Rmd-->


# [fMRI] FIR ~ task {#ch50_fir_glasser}

Placeholder


## parameters {TODO: ignore}
## load dataframe
## taskwise stim effect
### PCA subjectwise
### PCA groupwise
## DEP: epoch: stim, high cue vs low cue
## taskwise cue effect
## epoch: stim, rating
## epoch: 6 cond
## taskwise 6 cond effect

<!--chapter:end:50_iv-6cond_dv-firglasserSPM_ttl2_rINS.Rmd-->


# [fMRI] FIR ~ task {#ch50_fir_glasserTPJ}

Placeholder


## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot
## parameters {TODO: ignore}
## epoch: stim, high stim vs low stim
### PCA subjectwise
### PCA groupwise
## epoch: stim, high cue vs low cue
### PCA subjectwise
## epoch: stim, rating
## epoch: 6 cond

<!--chapter:end:50_iv-6cond_dv-firglasserSPM_ttl2_TPJ.Rmd-->


# [fMRI] FIR ~ task {#ch51_fir_glasserTPJttl2}

Placeholder


## parameters {TODO: ignore}
### PCA subjectwise
### PCA groupwise
## DEP: epoch: stim, high cue vs low cue
## taskwise cue effect
## epoch: stim, rating
## epoch: 6 cond

<!--chapter:end:51_iv-6cond_dv-firglasserSPM_ttl2_rois.Rmd-->


# [fMRI] FIR ~ task TTL1 {#ch52_timeseries}

Placeholder


## parameters {TODO: ignore}
## taskwise stim effect
### PCA subjectwise
### PCA groupwise
### taskwise cue effect
### epoch: stim, rating
### epoch: 6 cond
## taskwise 6 cond effect

<!--chapter:end:52_iv-6cond_dv-firglasserSPM_ttl1_rois.Rmd-->


# [fMRI] singletrial ~ NPS {#ch53_NPS}

Placeholder


## load NPS
### load beahvarioa
### load bad json
### drop based on NPS and bad json
#### datawrangle :: load NPS
##### datawrangle :: remove bad runs
### datawrangle :: load beahvarioal
### datawrangle :: merge NPS and behavioral
## load fear of pain
### merge and save
#### datawrangle :: check number of trials
#### datawrangle :: between vs within
## ggplot NPS and Outcome
## 6. OUTCOME ~ NPS
### Q. Do higher NPS values indicate higher outcome ratings? (Pain task only) {.unlisted .unnumbered}
## what is the relationshipe between expect-> NPS and NPS -> pain

<!--chapter:end:53_NPSmediation.Rmd-->


# [physio] scl ~ cue*stim {#scl}

Placeholder


## overview
## Overview
### full model with all tasks
### PAIN
### VICARIOUS
### COGNITIVE
### TASKWISE PLOTS

<!--chapter:end:91_iv-cue-stim_dv-scl.Rmd-->


# [physio] SCL {#ch92_SCL}

Placeholder


## Outline
### load data
### subjectwise, groupwise mean

<!--chapter:end:92_iv-stim_dv-sclbeta.Rmd-->


# [physio] SCL {#ch93_SCL}

Placeholder


## Outline
## load data
## subjectwise, groupwise mean

<!--chapter:end:93_iv-cue_dv-sclbeta.Rmd-->


# [physio] SCL {#ch94_SCL}

Placeholder


## Outline
### load data
### subjectwise, groupwise mean

<!--chapter:end:94_iv-cue-stim_dv-sclbeta.Rmd-->


# [QC] fdmean {#ch98_QCfdmean}

Placeholder



<!--chapter:end:98_qc-fdmean.Rmd-->


# CCN figures

Placeholder


## behavioral outcome ratings ~ expectations * cue
## behavioral demeaned (both)
## behavioral only expectaiton deman
## behavioral :: line plot cue * stim (outcome demena)
### model 04 4-4 lineplot (demean)
## behavioral :: line plots cue * stim * intensity (demean outcome)
## behavioral :: line plots cue * stim * intensity (demean outcome)
## NPS: stim * cue
## NPS demeaned: stim*cue
## NPS:ccue * expect (expect demean)
## NPS:ccue * expect (both demean)
## NPS: stim * cue * expect
## NPS: stim * cue * expect (demean)
## NPS demeaned (both)
## NPS demeaned cue *expect
## Behavioral data
### behavioral demeaned (both)
### behavioral lineplots
### behavioral cue * stim * expect

<!--chapter:end:99_CCNfigures.Rmd-->


# [CCN] SCL {#ch100_CCNsupplementary}

Placeholder


## empirical
## model fit

<!--chapter:end:CCN_supple.Rmd-->

# [QC] SCL {#ch100_white matter csf}
---
title: "whitematter_csf"
output: html_document
date: "2023-07-28"
---




```r
# parameters
main_dir <- dirname(dirname(getwd()))
analysis_folder  = paste0("model96_iv-cue-stim_dv-nuissance")
analysis_dir <-
  file.path(main_dir,
            "analysis",
            "mixedeffect",
            analysis_folder,
            as.character(Sys.Date())) # nolint
dir.create(analysis_dir,
           showWarnings = FALSE,
           recursive = TRUE)
savedir <- analysis_dir
```

## load data

```r
df <- read.csv(file.path(main_dir, 'scripts/step10_nilearn/whitematter_csf/whitematter_csf_pain.csv' ))
```


```r
myData <- separate(df, fname, into = c("sub", "ses", "run", "runtype","event", "trial", "cuetype", "stimintensity"), sep = "_", remove = FALSE)
myData$sub <- sub("_.*", "", myData$sub)
myData$ses <- sub("_.*", "", myData$ses)
myData$run <- sub("_.*", "", myData$run)
myData$runtype <- str_extract(myData$runtype, "(?<=runtype-).*")
myData$event <- sub("_.*", "", myData$event)
myData$trial <- sub("_.*", "", myData$trial)
myData$cue <- str_extract(myData$cuetype, "(?<=cuetype-).*")
myData$stim <- str_extract(myData$stimintensity, "(?<=stimintensity-)[^.]+")
```

## whitematter


```
## # A tibble: 5,907 × 18
##    fname  sub   ses   run   runtype event trial cuetype stimintensity graymatter
##    <chr>  <chr> <chr> <chr> <chr>   <chr> <chr> <chr>   <chr>              <dbl>
##  1 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.623
##  2 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…     -0.475
##  3 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.26 
##  4 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.116
##  5 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.620
##  6 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.34 
##  7 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.33 
##  8 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.121
##  9 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.790
## 10 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.57 
## # ℹ 5,897 more rows
## # ℹ 8 more variables: whitematter <dbl>, csf <dbl>, cue <chr>, stim <chr>,
## #   STIM <fct>, STIM_linear <dbl>, STIM_quadratic <dbl>, CUE_high_gt_low <dbl>
```

<img src="csf_whitematter_files/figure-html/unnamed-chunk-5-1.png" width="672" />

<img src="csf_whitematter_files/figure-html/unnamed-chunk-6-1.png" width="672" />

## CSF



```
## # A tibble: 5,895 × 18
##    fname  sub   ses   run   runtype event trial cuetype stimintensity graymatter
##    <chr>  <chr> <chr> <chr> <chr>   <chr> <chr> <chr>   <chr>              <dbl>
##  1 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.623
##  2 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…     -0.475
##  3 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.26 
##  4 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.116
##  5 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.620
##  6 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.34 
##  7 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.33 
##  8 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.121
##  9 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      0.790
## 10 sub-0… sub-… ses-… run-… pain    even… tria… cuetyp… stimintensit…      1.57 
## # ℹ 5,885 more rows
## # ℹ 8 more variables: whitematter <dbl>, csf <dbl>, cue <chr>, stim <chr>,
## #   STIM <fct>, STIM_linear <dbl>, STIM_quadratic <dbl>, CUE_high_gt_low <dbl>
```

<img src="csf_whitematter_files/figure-html/unnamed-chunk-7-1.png" width="672" />

<img src="csf_whitematter_files/figure-html/unnamed-chunk-8-1.png" width="672" />

<!--chapter:end:csf_whitematter.Rmd-->


# load behavioral daata

Placeholder



<!--chapter:end:jepma_simulation_PE.Rmd-->


# load behavioral daata

Placeholder



<!--chapter:end:jepma_simulation.Rmd-->


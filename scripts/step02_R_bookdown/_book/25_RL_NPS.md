# [model] RL-simulated PE & NPS{#ch25_NPSandPE}

---
title: "PE & NPS "
output:
  html_document:
    code_folding: hide
---

## The purpose of this notebook? {.unlisted .unnumbered}
Investigate the relationship between prediction errors and NPS extracted values.






### load dataframe

```r
# load NPS dot product
NPSdf <- read.csv(file.path(main_dir, 'analysis/fmri/nilearn/deriv01_signature/rampupdown/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv' ))

# load RL data
RLdf <- read.csv(file.path(main_dir, "/data/RL/modelfit_jepma_0525/table_pain.csv"))

# create analysis directory to save files
analysis_dir <- file.path(main_dir, 'analysis', 'mixedeffect', 'model25_RL_NPS')
dir.create(analysis_dir, recursive = TRUE)
```

```
## Warning in dir.create(analysis_dir, recursive = TRUE):
## '/Users/h/Documents/projects_local/cue_expectancy/analysis/mixedeffect/model25_RL_NPS'
## already exists
```

### some data wrangling: 
split filenames into columns. This will serve as metadata. NPSsplit
We'll use this to merge NPSsplit and RLdf


```r
NPSsplit <- NPSdf %>%
  # 1) Extract the components from the singletrial_fname column (sub,ses, run etc)
  extract(col = singletrial_fname, into = c("sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"),
          regex = "(sub-\\w+)_+(ses-\\w+)_+(run-\\w+)_+(runtype-\\w+)_+(event-\\w+)_+(trial-\\w+)_+(cuetype-\\w+)_+(stimintensity-\\w+).nii.gz") %>%
  # 2) Extract numbers and keywords as specified
  mutate(
    src_subject_id = as.integer(str_extract(sub, "\\d+")),
    session_id = as.integer(str_extract(ses, "\\d+")),
    param_run_num = as.integer(str_extract(run, "\\d+")),
    trial_index_runwise = as.integer(str_extract(trial, "\\d+")) + 1,
    param_cue_type = case_when(
      str_detect(cuetype, "low") ~ "low_cue",
      str_detect(cuetype, "high") ~ "high_cue"
    ), 
    param_task_name = str_replace(runtype, "runtype-", ""), 
    param_stimulus_type = case_when(
      stimintensity == "stimintensity-low" ~ "low_stim",
      stimintensity == "stimintensity-med" ~ "med_stim",
      stimintensity == "stimintensity-high" ~ "high_stim",
      TRUE ~ stimintensity  # Retain original value if neither "low" nor "high"
    )
  ) %>%
  # 3) Select and rename the necessary columns
  select(
    src_subject_id,
    session_id,
    param_run_num,
    param_task_name,
    event,
    trial_index_runwise,
    param_cue_type,
    param_stimulus_type,
    NPSpos
  )

# names(NPSsplit)[names(NPSsplit) == "src_subject_id"] <- "sub"
# names(NPSsplit)[names(NPSsplit) == "session_id"] <- "ses"
# names(NPSsplit)[names(NPSsplit) == "param_run_num"] <- "run"
```


```r
NPSsplit <- NPSdf %>%
  # 1) Extract the components from the singletrial_fname column (sub,ses, run etc)
  extract(col = singletrial_fname, into = c("sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"),
          regex = "(sub-\\w+)_+(ses-\\w+)_+(run-\\w+)_+(runtype-\\w+)_+(event-\\w+)_+(trial-\\w+)_+(cuetype-\\w+)_+(stimintensity-\\w+).nii.gz") %>%
  # 2) Extract numbers and keywords as specified
  mutate(
    sub = as.integer(str_extract(sub, "\\d+")),
    ses = as.integer(str_extract(ses, "\\d+")),
    run = as.integer(str_extract(run, "\\d+")),
    trial = as.integer(str_extract(trial, "\\d+")) + 1,
    cue = case_when(
      str_detect(cuetype, "low") ~ "low_cue",
      str_detect(cuetype, "high") ~ "high_cue"
    ), 
    task = str_replace(runtype, "runtype-", ""), 
    stimintensity = case_when(
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
    stimintensity,
    NPSpos
  )
```

### rename RL dataframe so that columns are identical. we will merge on these columns

```r
names(RLdf)[names(RLdf) == "src_subject_id"] <- "sub"
names(RLdf)[names(RLdf) == "session_id"] <- "ses"
names(RLdf)[names(RLdf) == "param_run_num"] <- "run"
names(RLdf)[names(RLdf) == "param_task_name"] <- "task"
names(RLdf)[names(RLdf) == "param_cue_type"] <- "cue"
names(RLdf)[names(RLdf) == "param_stimulus_type"] <- "stimintensity"
names(RLdf)[names(RLdf) == "trial_index_runwise"] <- "trial"
```

### merge the two dataframes

```r
merge_df <- inner_join(NPSsplit, RLdf, by = c("sub", "ses", "run", "task", "cue", "stimintensity", "trial"))
```

### remove bad runs

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
clean_merge_df <- merge_df %>%
  anti_join(bad_runs_df, by = c("sub", "ses", "run"))
```


### calculate behavioral PE


```r
# change columns names for better modeling
clean_merge_df$RATING_expectation <- clean_merge_df$event02_expect_angle
clean_merge_df$RATING_outcome <- clean_merge_df$event04_actual_angle

# PE :: prediction error ______________________________________________________
clean_merge_df$PE =   clean_merge_df$RATING_outcome - clean_merge_df$RATING_expectation

# Lag expectation rating ______________________________________________________
# per run/ses/sub
data_a3lag <- clean_merge_df %>%
  group_by(sub,ses,run) %>% 
  mutate(prev_trial.RATING_expectation = lag(RATING_expectation, n = 1, default = NA)) %>% 
  mutate(next_trial.RATING_expectation = lead(RATING_expectation, n = 1, default = NA)) %>%
  mutate(ave.RATING_expectation = mean(RATING_expectation, na.rm = TRUE))
data_a3lag <- data_a3lag[!is.na(data_a3lag$ave.RATING_expectation),]
taskname = 'pain'
data_a3lag$next_trial.RATING_expect_fill = coalesce(data_a3lag$next_trial.RATING_expectation, data_a3lag$ave.RATING_expectation) 
data_a3lag$prev_trial.RATING_expect_fill = coalesce(data_a3lag$prev_trial.RATING_expectation, data_a3lag$ave.RATING_expectation) 

# EXPECTUPDATE :: expectation (N) - expectation (N-1) ________________________
clean_merge_df <- data_a3lag %>%
  # group_by(sub,ses,run) %>%
  mutate(beh_PE =  next_trial.RATING_expect_fill-RATING_expectation )  %>%
  mutate(beh_PE_JEPMA =  (next_trial.RATING_expect_fill - RATING_expectation)/(PE+1))
# beh_PE_JEPMA: Jepma (2018)
```



## NPS plot N = 120

```r
################################################################################
# contrast coding ______________________________________________________________
NPSdf <- NPSsplit %>%
  anti_join(bad_runs_df, by = c("sub", "ses", "run"))
data <- NPSdf
data$sub <- factor(data$sub)
# contrast code 
data$stim[data$stimintensity == "low_stim"] <-  -0.5 # social influence task
data$stim[data$stimintensity == "med_stim"] <- 0 # no influence task
data$stim[data$stimintensity == "high_stim"] <-  0.5 # no influence task

data$STIM <- factor(data$stimintensity)

# contrast code 1 linear
data$STIM_linear[data$stimintensity == "low_stim"] <- -0.5
data$STIM_linear[data$stimintensity == "med_stim"] <- 0
data$STIM_linear[data$stimintensity == "high_stim"] <- 0.5

# contrast code 2 quadratic
data$STIM_quadratic[data$stimintensity == "low_stim"] <- -0.33
data$STIM_quadratic[data$stimintensity == "med_stim"] <- 0.66
data$STIM_quadratic[data$stimintensity == "high_stim"] <- -0.33

# social cue contrast
data$CUE_high_gt_low[data$cue == "low_cue"] <-  -0.5 # social influence task
data$CUE_high_gt_low[data$cue == "high_cue"] <-  0.5 # no influence task

data$EXPECT <- data$event02_expect_angle
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
dv <- "NPSpos"; dv_keyword <- "NPSpos"
subject <- "sub"

################################################################################
# linear model _________________________________________________________________
model_savefname <- file.path(
  analysis_dir,
  paste(
    "lmer_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.txt",
    sep = ""
  )
)

cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject = "sub",  dv_keyword,  model_savefname,  'random_intercept',
  print_lmer_output = FALSE
)
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])
# data_screen <- data[-influential,]
data_screen <- data
################################################################################
# plot :: reorder column levels and names for plots ____________________________
data_screen$cue_name <- 0

data_screen$cue_name[data_screen$cue == "high_cue"] <-  "high cue"
data_screen$cue_name[data_screen$cue == "low_cue"] <-  "low cue"

data_screen$stim_name[data_screen$stimintensity == "high_stim"] <-  "high"
data_screen$stim_name[data_screen$stimintensity == "med_stim"] <-  "med"
data_screen$stim_name[data_screen$stimintensity == "low_stim"] <-  "low"

data_screen$stim_ordered <- factor(data_screen$stim_name, levels = c("low", "med", "high"))
data_screen$cue_ordered <- factor(data_screen$cue_name, levels = c("low cue", "high cue"))
model_iv1 <- "stim_ordered"
model_iv2 <- "cue_ordered"

################################################################################
# plot :: calculate mean and se  _______________________________________________
NPSstimcue_subjectwise <- meanSummary(data_screen,
                                      c(subject, model_iv1, model_iv2), dv)
NPSstimcue_groupwise <- summarySEwithin(
  data = NPSstimcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
signature_key <- "NPSpos"
  taskname <- "pain"
  plot_keyword <- "stimulusintensity"
  ggtitle_phrase <-  ""
  data_screen$task = factor(data_screen$task)
  plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key),
      " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ),
    title = paste0(
      str_to_title(signature_key), " - ", str_to_title(plot_keyword)
    ),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  

################################################################################
### Lineplots {.unlisted .unnumbered} __________________________________________

fig.nps120 <- plot_lineplot_twofactor(NPSstimcue_groupwise, 
                        iv1 = "stim_ordered", iv2 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("#5D5C5C", "#941100"), ggtitle = paste0(
      str_to_title(signature_key),
      " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ), #"Within pain task: NPS dotproducts as a function of stimulus intensity level and cue", 
                        xlab = "Stimulus intensity", ylab = "NPS (dot product)")
fig.nps120
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-9-1.png" width="672" />
## contrast coding for the merged dataframe

```r
clean_merge_df$sub <- factor(clean_merge_df$sub)
# contrast code ________________________________________
clean_merge_df$stim[clean_merge_df$stimintensity == "low_stim"] <-  -0.5 # social influence task
clean_merge_df$stim[clean_merge_df$stimintensity == "med_stim"] <- 0 # no influence task
clean_merge_df$stim[clean_merge_df$stimintensity == "high_stim"] <-  0.5 # no influence task
clean_merge_df$STIM <- factor(clean_merge_df$stimintensity)

# contrast code 1 linear
clean_merge_df$STIM_linear[clean_merge_df$stimintensity == "low_stim"] <- -0.5
clean_merge_df$STIM_linear[clean_merge_df$stimintensity == "med_stim"] <- 0
clean_merge_df$STIM_linear[clean_merge_df$stimintensity == "high_stim"] <- 0.5

# contrast code 2 quadratic
clean_merge_df$STIM_quadratic[clean_merge_df$stimintensity == "low_stim"] <- -0.33
clean_merge_df$STIM_quadratic[clean_merge_df$stimintensity == "med_stim"] <- 0.66
clean_merge_df$STIM_quadratic[clean_merge_df$stimintensity == "high_stim"] <- -0.33

# social cue contrast
clean_merge_df$CUE_high_gt_low[clean_merge_df$cue == "low_cue"] <-  -0.5 # social influence task
clean_merge_df$CUE_high_gt_low[clean_merge_df$cue == "high_cue"] <-  0.5 # no influence task

clean_merge_df$EXPECT <- clean_merge_df$event02_expect_angle
clean_merge_df$sub <- factor(clean_merge_df$sub)
# contrast code ________________________________________
clean_merge_df$stim[clean_merge_df$stimintensity == "low_stim"] <-  -0.5 # social influence task
clean_merge_df$stim[clean_merge_df$stimintensity == "med_stim"] <- 0 # no influence task
clean_merge_df$stim[clean_merge_df$stimintensity == "high_stim"] <-  0.5 # no influence task
clean_merge_df$STIM <- factor(clean_merge_df$stimintensity)

# contrast code 1 linear
clean_merge_df$STIM_linear[clean_merge_df$stimintensity == "low_stim"] <- -0.5
clean_merge_df$STIM_linear[clean_merge_df$stimintensity == "med_stim"] <- 0
clean_merge_df$STIM_linear[clean_merge_df$stimintensity == "high_stim"] <- 0.5

# contrast code 2 quadratic
clean_merge_df$STIM_quadratic[clean_merge_df$stimintensity == "low_stim"] <- -0.33
clean_merge_df$STIM_quadratic[clean_merge_df$stimintensity == "med_stim"] <- 0.66
clean_merge_df$STIM_quadratic[clean_merge_df$stimintensity == "high_stim"] <- -0.33

# social cue contrast
clean_merge_df$CUE_high_gt_low[clean_merge_df$cue == "low_cue"] <-  -0.5 # social influence task
clean_merge_df$CUE_high_gt_low[clean_merge_df$cue == "high_cue"] <-  0.5 # no influence task

clean_merge_df$EXPECT <- clean_merge_df$event02_expect_angle
```

## A. NPS plot N = 60

```r
################################################################################
# contrast coding ______________________________________________________________

data <- clean_merge_df
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
dv <- "NPSpos"
subject <- "sub"

################################################################################
# linear model _________________________________________________________________
model_savefname <- file.path(
  analysis_dir,
  paste(
    "lmer_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.txt",
    sep = ""
  )
)

cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject = "sub",  dv_keyword,  model_savefname,  'random_intercept',
  print_lmer_output = FALSE
)
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])
data_screen <- data[-influential,]

################################################################################
# plot :: reorder column levels and names for plots ____________________________
data_screen$cue_name[data_screen$cue == "high_cue"] <-  "high cue"
data_screen$cue_name[data_screen$cue == "low_cue"] <-  "low cue"

data_screen$stim_name[data_screen$stimintensity == "high_stim"] <-  "high"
data_screen$stim_name[data_screen$stimintensity == "med_stim"] <-  "med"
data_screen$stim_name[data_screen$stimintensity == "low_stim"] <-  "low"

data_screen$stim_ordered <- factor(data_screen$stim_name, levels = c("low", "med", "high"))
data_screen$cue_ordered <- factor(data_screen$cue_name, levels = c("low cue", "high cue"))
model_iv1 <- "stim_ordered"
model_iv2 <- "cue_ordered"

################################################################################
# plot :: calculate mean and se  _______________________________________________
NPSstimcue_subjectwise <- meanSummary(data_screen,
                                      c(subject, model_iv1, model_iv2), dv)
NPSstimcue_groupwise <- summarySEwithin(
  data = NPSstimcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
signature_key <- "NPSpos"
taskname <- "pain"
plot_keyword <- "stimulusintensity"
ggtitle_phrase <-  ""
data_screen$task = factor(data_screen$task)
plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key),
      " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ),
    title = paste0(
      str_to_title(signature_key), " - ", str_to_title(plot_keyword)
    ),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  
################################################################################
# Lineplots {.unlisted .unnumbered} ____________________________________________
fig.nps60 <- plot_lineplot_twofactor(NPSstimcue_groupwise, 
                        iv1 = "stim_ordered", iv2 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("#5D5C5C", "#941100"), 
                        ggtitle = paste0(      str_to_title(signature_key), " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ), 
                        xlab = "Stimulus intensity", ylab = "NPS (dot product)")
fig.nps60
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-11-1.png" width="672" />


## B. PE plot

```r
################################################################################
# contrast coding ______________________________________________________________

data <- clean_merge_df
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
dv <- "PE_mdl2"
subject <- "sub"

################################################################################
# linear model _________________________________________________________________
model_savefname <- file.path(
  analysis_dir,
  paste(
    "lmer_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.txt",
    sep = ""
  )
)

cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject = "sub",  dv_keyword,  model_savefname,  'random_intercept',
  print_lmer_output = FALSE
)
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])
data_screen <- data[-influential,]

################################################################################
# plot :: reorder column levels and names for plots ____________________________
data_screen$cue_name[data_screen$cue == "high_cue"] <-  "high cue"
data_screen$cue_name[data_screen$cue == "low_cue"] <-  "low cue"

data_screen$stim_name[data_screen$stimintensity == "high_stim"] <-  "high"
data_screen$stim_name[data_screen$stimintensity == "med_stim"] <-  "med"
data_screen$stim_name[data_screen$stimintensity == "low_stim"] <-  "low"

data_screen$stim_ordered <- factor(data_screen$stim_name, levels = c("low", "med", "high"))
data_screen$cue_ordered <- factor(data_screen$cue_name, levels = c("low cue", "high cue"))
model_iv1 <- "stim_ordered"
model_iv2 <- "cue_ordered"

################################################################################
# plot :: calculate mean and se  _______________________________________________
NPSstimcue_subjectwise <- meanSummary(data_screen,
                                      c(subject, model_iv1, model_iv2), dv)
NPSstimcue_groupwise <- summarySEwithin(
  data = NPSstimcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
signature_key <- "PE (Jepma)"
taskname <- "pain"
plot_keyword <- "stimulusintensity"
ggtitle_phrase <-  ""
data_screen$task = factor(data_screen$task)
plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key),
      " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ),
    title = paste0(
      str_to_title(signature_key), " - ", str_to_title(plot_keyword)
    ),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  
################################################################################
# Lineplots {.unlisted .unnumbered} ____________________________________________
fig.PE <- plot_lineplot_twofactor(NPSstimcue_groupwise, 
                        iv1 = "stim_ordered", iv2 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("#5D5C5C", "#941100"), 
                        ggtitle = paste0( "PE", " (N = ", length(unique(data_screen$sub)), ")"
    ), 
                        xlab = "Stimulus intensity", ylab = "PE")
fig.PE
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-12-1.png" width="672" />

## C. behavior PE plot

```r
################################################################################
# contrast coding ______________________________________________________________

data <- clean_merge_df
stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
dv <- "beh_PE"
subject <- "sub"

################################################################################
# linear model _________________________________________________________________
model_savefname <- file.path(
  analysis_dir,
  paste("lmer_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.txt", sep = ""  )
)

cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject = "sub",  dv_keyword,  model_savefname,  'random_intercept',
  print_lmer_output = FALSE
)
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])
# data_screen <- data[-influential,]
data_screen <- data
################################################################################
# plot :: reorder column levels and names for plots ____________________________
data_screen$cue_name[data_screen$cue == "high_cue"] <-  "high cue"
```

```
## Warning: Unknown or uninitialised column: `cue_name`.
```

```r
data_screen$cue_name[data_screen$cue == "low_cue"] <-  "low cue"

data_screen$stim_name[data_screen$stimintensity == "high_stim"] <-  "high"
```

```
## Warning: Unknown or uninitialised column: `stim_name`.
```

```r
data_screen$stim_name[data_screen$stimintensity == "med_stim"] <-  "med"
data_screen$stim_name[data_screen$stimintensity == "low_stim"] <-  "low"

data_screen$stim_ordered <- factor(data_screen$stim_name, levels = c("low", "med", "high"))
data_screen$cue_ordered <- factor(data_screen$cue_name, levels = c("low cue", "high cue"))
model_iv1 <- "stim_ordered"
model_iv2 <- "cue_ordered"

################################################################################
# plot :: calculate mean and se  _______________________________________________
NPSstimcue_subjectwise <- meanSummary(data_screen,
                                      c(subject, model_iv1, model_iv2), dv)
NPSstimcue_groupwise <- summarySEwithin(
  data = NPSstimcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
signature_key <- "PE (behavioral)"
taskname <- "pain"
plot_keyword <- "stimulusintensity"
ggtitle_phrase <-  ""
data_screen$task = factor(data_screen$task)
plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key), " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ),
    title = paste0(      str_to_title(signature_key), " - ", str_to_title(plot_keyword)    ),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  
################################################################################
# Lineplots {.unlisted .unnumbered} ____________________________________________
fig.PE_beh <- plot_lineplot_twofactor(NPSstimcue_groupwise, 
                        iv1 = "stim_ordered", iv2 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("#5D5C5C", "#941100"), 
                        ggtitle = paste0( "PE (behavioral) ", " (N = ", length(unique(data_screen$sub)), ")"    ), 
                        xlab = "Stimulus intensity", ylab = "PE")
fig.PE_beh
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-13-1.png" width="672" />

## D. outcome rating plot

```r
################################################################################
# contrast coding ______________________________________________________________

data <- clean_merge_df

stim_con1 <- "STIM_linear"
stim_con2 <- "STIM_quadratic"
iv1 <- "CUE_high_gt_low"
dv <- "RATING_outcome"
subject <- "sub"

################################################################################
# linear model _________________________________________________________________
model_savefname <- file.path(
  analysis_dir,
  paste("lmer_task-", taskname, "_rating-", dv_keyword, "_", as.character(Sys.Date()), "_cooksd.txt", sep = ""  )
)

cooksd <- lmer_twofactor_cooksd_fix(
  data,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject = "sub",  dv_keyword,  model_savefname,  'random_intercept',
  print_lmer_output = FALSE
)
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(unique(
  data$sub
)))))])
# data_screen <- data[-influential,]
data_screen <- data
################################################################################
# plot :: reorder column levels and names for plots ____________________________
data_screen$cue_name[data_screen$cue == "high_cue"] <-  "high cue"
```

```
## Warning: Unknown or uninitialised column: `cue_name`.
```

```r
data_screen$cue_name[data_screen$cue == "low_cue"] <-  "low cue"

data_screen$stim_name[data_screen$stimintensity == "high_stim"] <-  "high"
```

```
## Warning: Unknown or uninitialised column: `stim_name`.
```

```r
data_screen$stim_name[data_screen$stimintensity == "med_stim"] <-  "med"
data_screen$stim_name[data_screen$stimintensity == "low_stim"] <-  "low"

data_screen$stim_ordered <- factor(data_screen$stim_name, levels = c("low", "med", "high"))
data_screen$cue_ordered <- factor(data_screen$cue_name, levels = c("low cue", "high cue"))
model_iv1 <- "stim_ordered"
model_iv2 <- "cue_ordered"

################################################################################
# plot :: calculate mean and se  _______________________________________________
NPSstimcue_subjectwise <- meanSummary(data_screen,
                                      c(subject, model_iv1, model_iv2), dv)
NPSstimcue_groupwise <- summarySEwithin(
  data = NPSstimcue_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
NPSstimcue_groupwise$task <- taskname
signature_key <- "Outcome rating"
taskname <- "pain"
plot_keyword <- "stimulusintensity"
ggtitle_phrase <-  ""
data_screen$task = factor(data_screen$task)
plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key), " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ),
    title = paste0(      str_to_title(signature_key), " - ", str_to_title(plot_keyword)    ),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  
################################################################################
# Lineplots {.unlisted .unnumbered} ____________________________________________
fig.outcome <- plot_lineplot_twofactor(NPSstimcue_groupwise, 
                        iv1 = "stim_ordered", iv2 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("#5D5C5C", "#941100"), 
                        ggtitle = paste0( "Outcome rating ", " (N = ", length(unique(data_screen$sub)), ")"    ), 
                        xlab = "Stimulus intensity", ylab = "PE")
fig.outcome
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-14-1.png" width="672" />


## 1. Relationship between NPS and PE

```r
# demean NPS just i case
clean_merge_df <- clean_merge_df %>%
  dplyr::group_by(.data[["sub"]]) %>%
  select(everything())  %>%
  mutate(NPSpos_demean = .data[["NPSpos"]] - mean(.data[["NPSpos"]]))

# check range of value
range(clean_merge_df$NPSpos)
```

```
## [1] -40.95723  59.61942
```

```r
range(clean_merge_df$NPSpos_demean)
```

```
## [1] -40.74617  37.45259
```

```r
range(clean_merge_df$PE_mdl2)
```

```
## [1] -68.4843 104.4470
```

### 1.1 lmer model 1 - NPSpos_demean ~ PE + (PE | sub) >> singular
* IV: PE (Jepma)
* DV: NPSpos (demean)
* random effects: random slopes, PE effects per subject

```r
library(optimx)
```

```
## Warning: package 'optimx' was built under R version 4.3.1
```

```
## 
## Attaching package: 'optimx'
```

```
## The following object is masked from 'package:nlme':
## 
##     coef<-
```

```r
clean_merge_df$sub <- factor(clean_merge_df$sub)

model.NPSRL = lmer(NPSpos_demean ~ PE_mdl2 + (PE_mdl2| sub) , data = clean_merge_df, 
                   REML = FALSE, lmerControl(optimizer ="Nelder_Mead"))
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
          # control = lmerControl(
          #                  optimizer ='optimx', optCtrl=list(method='L-BFGS-B')))
summary(model.NPSRL)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: NPSpos_demean ~ PE_mdl2 + (PE_mdl2 | sub)
##    Data: clean_merge_df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  21969.1  22005.5 -10978.6  21957.1     3143 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.1382 -0.4980  0.0091  0.5310  4.5474 
## 
## Random effects:
##  Groups   Name        Variance  Std.Dev. Corr 
##  sub      (Intercept) 1.950e-02 0.13963       
##           PE_mdl2     5.487e-04 0.02342  -1.00
##  Residual             6.223e+01 7.88846       
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##               Estimate Std. Error         df t value Pr(>|t|)    
## (Intercept)  -0.209187   0.146217 900.575615  -1.431    0.153    
## PE_mdl2       0.039895   0.007103  51.926716   5.617 7.73e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##         (Intr)
## PE_mdl2 -0.241
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

### 1.2 lmer model 2 - No demean: NPSpos ~ PE + ( PE | sub)
* IV: PE (Jepma)
* DV: NPSpos
* random effects: random intercepts per subject

```r
library(optimx)
model.NPSRL = lmer(NPSpos ~ PE_mdl2 + (PE_mdl2| sub) , data = clean_merge_df, 
                   REML = FALSE, lmerControl(optimizer ="Nelder_Mead"))
```

```
## Warning in checkConv(attr(opt, "derivs"), opt$par, ctrl = control$checkConv, : Model is nearly unidentifiable: very large eigenvalue
##  - Rescale variables?
```

```r
summary(model.NPSRL)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: NPSpos ~ PE_mdl2 + (PE_mdl2 | sub)
##    Data: clean_merge_df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  22198.3  22234.6 -11093.2  22186.3     3143 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.1238 -0.5027  0.0081  0.5250  4.5302 
## 
## Random effects:
##  Groups   Name        Variance  Std.Dev. Corr
##  sub      (Intercept) 2.269e+01 4.76346      
##           PE_mdl2     6.601e-04 0.02569  0.54
##  Residual             6.332e+01 7.95732      
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept)  5.555358   0.634752 59.460195   8.752 2.78e-12 ***
## PE_mdl2      0.044960   0.007556 44.649076   5.950 3.80e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##         (Intr)
## PE_mdl2 0.186 
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## Model is nearly unidentifiable: very large eigenvalue
##  - Rescale variables?
```

model 2

```r
hist(clean_merge_df$PE_mdl2)
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-18-1.png" width="672" />

### 1.3 lmer model 3
* IV: PE (Jepma) * Stim * cue
* DV: NPSpos
* random effects: random intercepts per subject

```r
model.NPSRL = lmer(NPSpos ~ STIM_linear*cue*PE_mdl2 + STIM_quadratic*cue*PE_mdl2 + 
                     (1 + STIM_linear | sub) , data = clean_merge_df,
                   REML = FALSE, lmerControl(optimizer ="Nelder_Mead"))
summary(model.NPSRL)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: NPSpos ~ STIM_linear * cue * PE_mdl2 + STIM_quadratic * cue *  
##     PE_mdl2 + (1 + STIM_linear | sub)
##    Data: clean_merge_df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  22193.5  22290.4 -11080.7  22161.5     3133 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.1508 -0.5091  0.0072  0.5178  4.5044 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr
##  sub      (Intercept) 24.052   4.904        
##           STIM_linear  3.479   1.865    0.73
##  Residual             62.720   7.920        
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##                                     Estimate Std. Error         df t value
## (Intercept)                          5.09671    0.70447   81.49874   7.235
## STIM_linear                          1.51231    0.82253  423.17514   1.839
## cuelow_cue                           0.39218    0.46040 1992.24669   0.852
## PE_mdl2                              0.01392    0.01975 2274.01091   0.704
## STIM_quadratic                      -0.75816    0.59423 2920.36282  -1.276
## STIM_linear:cuelow_cue              -0.31538    1.17454 2852.12159  -0.269
## STIM_linear:PE_mdl2                  0.05936    0.04342 1007.98889   1.367
## cuelow_cue:PE_mdl2                   0.03362    0.02478 3112.69854   1.357
## cuelow_cue:STIM_quadratic            0.88467    0.90765 2850.75129   0.975
## PE_mdl2:STIM_quadratic              -0.03905    0.03856 3033.34767  -1.013
## STIM_linear:cuelow_cue:PE_mdl2      -0.07175    0.05163  703.86714  -1.390
## cuelow_cue:PE_mdl2:STIM_quadratic    0.05081    0.04583 3082.58318   1.109
##                                   Pr(>|t|)    
## (Intercept)                        2.3e-10 ***
## STIM_linear                         0.0667 .  
## cuelow_cue                          0.3944    
## PE_mdl2                             0.4812    
## STIM_quadratic                      0.2021    
## STIM_linear:cuelow_cue              0.7883    
## STIM_linear:PE_mdl2                 0.1719    
## cuelow_cue:PE_mdl2                  0.1749    
## cuelow_cue:STIM_quadratic           0.3298    
## PE_mdl2:STIM_quadratic              0.3113    
## STIM_linear:cuelow_cue:PE_mdl2      0.1650    
## cuelow_cue:PE_mdl2:STIM_quadratic   0.2676    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) STIM_l culw_c PE_md2 STIM_q STIM_l:_ STIM_:P cl_:PE_2 c_:STI
## STIM_linear -0.004                                                             
## cuelow_cue  -0.266  0.273                                                      
## PE_mdl2      0.184 -0.490 -0.265                                               
## STIM_qudrtc -0.074  0.295  0.097  0.159                                        
## STIM_lnr:c_  0.153 -0.662  0.088  0.356 -0.220                                 
## STIM_l:PE_2 -0.220  0.275  0.287  0.224  0.407 -0.240                          
## clw_c:PE_m2 -0.161  0.416 -0.106 -0.817 -0.116 -0.465   -0.147                 
## clw_c:STIM_  0.046 -0.194 -0.075 -0.104 -0.657 -0.030   -0.256   0.051         
## PE_m2:STIM_  0.065  0.265 -0.082  0.121  0.492 -0.166   -0.151  -0.108   -0.335
## STIM_:_:PE_  0.176 -0.216 -0.373 -0.193 -0.333 -0.079   -0.806   0.102    0.311
## c_:PE_2:STI -0.055 -0.219  0.044 -0.102 -0.408  0.213    0.130   0.091   -0.020
##             PE_2:S STIM_:_:
## STIM_linear                
## cuelow_cue                 
## PE_mdl2                    
## STIM_qudrtc                
## STIM_lnr:c_                
## STIM_l:PE_2                
## clw_c:PE_m2                
## clw_c:STIM_                
## PE_m2:STIM_                
## STIM_:_:PE_  0.114         
## c_:PE_2:STI -0.834 -0.066
```

structure: sub, NPS, PE
subjectwise correlations


### 1.4 plot group level slope of PE & NPS, alongside subjectwise slopes

```r
library(ggplot2)

min_value <- -40
max_value <- 40
clean_merge_df$sub <- factor(clean_merge_df$sub)
ggplot(clean_merge_df, aes(x = PE_mdl2, y = NPSpos)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  ylim(min_value, max_value) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
```

```
## Warning: Removed 15 rows containing non-finite values (`stat_smooth()`).
## Removed 15 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 15 rows containing missing values (`geom_point()`).
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-20-1.png" width="672" />



#### 1.4.1 subsetting medium intensity value - are the aforementioned effects mainly driven by the medium stimulus intensity?

```r
subset_med <- clean_merge_df[clean_merge_df$stimintensity == "med_stim", ]

min_value <- -40
max_value <- 40
subset_med$sub <- factor(subset_med$sub)
ggplot(subset_med, aes(x = PE_mdl2, y = NPSpos)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  # ylim(min_value, max_value) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-21-1.png" width="672" />

#### 1.4.2 subsetting high intensity value - are the aforementioned effects mainly driven by the medium stimulus intensity?

```r
subset_high <- clean_merge_df[clean_merge_df$stimintensity == "high_stim", ]

min_value <- -40
max_value <- 40
subset_high$sub <- factor(subset_high$sub)
ggplot(subset_high, aes(x = PE_mdl2, y = NPSpos)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  # ylim(min_value, max_value) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-22-1.png" width="672" />

#### 1.4.3 subsetting low intensity value - are the aforementioned effects mainly driven by the medium stimulus intensity?

```r
subset_low <- clean_merge_df[clean_merge_df$stimintensity == "low_stim", ]
min_value <- -40;max_value <- 40
subset_low$sub <- factor(subset_low$sub)
ggplot(subset_high, aes(x = PE_mdl2, y = NPSpos)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  # ylim(min_value, max_value) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-23-1.png" width="672" />



## 2. Relationship between behavioral PE and NPS

```r
hist(clean_merge_df$beh_PE)
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-24-1.png" width="672" />

### 2.1 lmer model 1 - NPSpos_demean ~ PE + (PE | sub) >> singular
* IV: PE (beh)
* DV: NPSpos (demean)
* random effects: random slopes, PE effects per subject

```r
library(optimx)
clean_merge_df <- clean_merge_df %>%
  dplyr::group_by(.data[["sub"]]) %>%
  select(everything())  %>%
  mutate(NPSpos_demean = .data[["NPSpos"]] - mean(.data[["NPSpos"]]))
model.behPE1 = lmer(NPSpos ~ beh_PE + (beh_PE| sub) , data = clean_merge_df, 
                   REML = FALSE, lmerControl(optimizer ="Nelder_Mead"))
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
summary(model.behPE1)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: NPSpos ~ beh_PE + (beh_PE | sub)
##    Data: clean_merge_df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  22215.4  22251.7 -11101.7  22203.4     3143 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.0388 -0.5006  0.0113  0.5306  4.6070 
## 
## Random effects:
##  Groups   Name        Variance  Std.Dev. Corr
##  sub      (Intercept) 2.349e+01 4.846635     
##           beh_PE      3.436e-05 0.005861 1.00
##  Residual             6.386e+01 7.991383     
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept) 5.767e+00  6.443e-01 5.983e+01   8.951 1.22e-12 ***
## beh_PE      2.321e-02  4.038e-03 6.969e+02   5.749 1.35e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##        (Intr)
## beh_PE 0.178 
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

### 2.2 lmer model 2 - No demean: NPSpos ~ PE + ( PE | sub)
* IV: PE (beh)
* DV: NPSpos
* random effects: random intercepts per subject

```r
library(optimx)
model.behPE2 = lmer(NPSpos ~ beh_PE + (beh_PE| sub) , data = clean_merge_df, 
                   REML = FALSE, lmerControl(optimizer ="Nelder_Mead"))
```

```
## boundary (singular) fit: see help('isSingular')
```

```r
summary(model.behPE2)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: NPSpos ~ beh_PE + (beh_PE | sub)
##    Data: clean_merge_df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  22215.4  22251.7 -11101.7  22203.4     3143 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.0388 -0.5006  0.0113  0.5306  4.6070 
## 
## Random effects:
##  Groups   Name        Variance  Std.Dev. Corr
##  sub      (Intercept) 2.349e+01 4.846635     
##           beh_PE      3.436e-05 0.005861 1.00
##  Residual             6.386e+01 7.991383     
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##              Estimate Std. Error        df t value Pr(>|t|)    
## (Intercept) 5.767e+00  6.443e-01 5.983e+01   8.951 1.22e-12 ***
## beh_PE      2.321e-02  4.038e-03 6.969e+02   5.749 1.35e-08 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##        (Intr)
## beh_PE 0.178 
## optimizer (Nelder_Mead) convergence code: 0 (OK)
## boundary (singular) fit: see help('isSingular')
```

### 2.3 lmer model 3
* IV: PE (beh) * Stim * cue
* DV: NPSpos
* random effects: random intercepts per subject

```r
model.behPE3 = lmer(NPSpos ~ STIM_linear*cue*beh_PE + STIM_quadratic*cue*beh_PE + 
                     (1 + STIM_linear | sub) , data = clean_merge_df,
                   REML = FALSE, lmerControl(optimizer ="Nelder_Mead"))
summary(model.behPE3)
```

```
## Linear mixed model fit by maximum likelihood . t-tests use Satterthwaite's
##   method [lmerModLmerTest]
## Formula: NPSpos ~ STIM_linear * cue * beh_PE + STIM_quadratic * cue *  
##     beh_PE + (1 + STIM_linear | sub)
##    Data: clean_merge_df
## Control: lmerControl(optimizer = "Nelder_Mead")
## 
##      AIC      BIC   logLik deviance df.resid 
##  22187.5  22284.4 -11077.8  22155.5     3133 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.1064 -0.5084  0.0115  0.5215  4.5330 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr
##  sub      (Intercept) 23.686   4.867        
##           STIM_linear  3.221   1.795    0.74
##  Residual             62.644   7.915        
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##                                    Estimate Std. Error         df t value
## (Intercept)                       5.657e+00  6.732e-01  7.023e+01   8.404
## STIM_linear                       2.011e+00  6.085e-01  2.299e+02   3.304
## cuelow_cue                        4.551e-01  3.347e-01  3.071e+03   1.360
## beh_PE                            2.444e-02  6.934e-03  3.107e+03   3.525
## STIM_quadratic                   -6.622e-01  5.100e-01  3.043e+03  -1.298
## STIM_linear:cuelow_cue           -3.412e-01  8.211e-01  3.061e+03  -0.416
## STIM_linear:beh_PE                2.545e-02  1.612e-02  2.915e+03   1.579
## cuelow_cue:beh_PE                -1.259e-02  9.967e-03  3.124e+03  -1.263
## cuelow_cue:STIM_quadratic         1.131e+00  7.201e-01  3.054e+03   1.571
## beh_PE:STIM_quadratic             4.119e-03  1.494e-02  3.066e+03   0.276
## STIM_linear:cuelow_cue:beh_PE    -9.668e-03  2.289e-02  2.112e+03  -0.422
## cuelow_cue:beh_PE:STIM_quadratic  3.213e-03  2.063e-02  3.074e+03   0.156
##                                  Pr(>|t|)    
## (Intercept)                      3.22e-12 ***
## STIM_linear                       0.00110 ** 
## cuelow_cue                        0.17406    
## beh_PE                            0.00043 ***
## STIM_quadratic                    0.19423    
## STIM_linear:cuelow_cue            0.67774    
## STIM_linear:beh_PE                0.11445    
## cuelow_cue:beh_PE                 0.20676    
## cuelow_cue:STIM_quadratic         0.11636    
## beh_PE:STIM_quadratic             0.78272    
## STIM_linear:cuelow_cue:beh_PE     0.67278    
## cuelow_cue:beh_PE:STIM_quadratic  0.87626    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##             (Intr) STIM_l culw_c beh_PE STIM_q STIM_l:_ STIM_:_P cl_:_PE c_:STI
## STIM_linear  0.254                                                             
## cuelow_cue  -0.240  0.027                                                      
## beh_PE       0.184 -0.038 -0.345                                               
## STIM_qudrtc  0.020  0.025 -0.039  0.075                                        
## STIM_lnr:c_  0.010 -0.628  0.050  0.040 -0.017                                 
## STIM_ln:_PE -0.011  0.455  0.029  0.037  0.024 -0.333                          
## clw_c:bh_PE -0.136  0.029 -0.013 -0.737 -0.056 -0.087   -0.024                 
## clw_c:STIM_ -0.013 -0.017  0.004 -0.056 -0.709 -0.038   -0.017    0.054        
## bh_PE:STIM_  0.024  0.021 -0.048  0.093  0.541 -0.013   -0.033   -0.071  -0.384
## STIM_:_:_PE  0.007 -0.322 -0.075 -0.036 -0.019 -0.048   -0.711    0.004   0.051
## c_:_PE:STIM -0.019 -0.016  0.047 -0.067 -0.391  0.046    0.023    0.062   0.023
##             b_PE:S STIM_:_:
## STIM_linear                
## cuelow_cue                 
## beh_PE                     
## STIM_qudrtc                
## STIM_lnr:c_                
## STIM_ln:_PE                
## clw_c:bh_PE                
## clw_c:STIM_                
## bh_PE:STIM_                
## STIM_:_:_PE  0.020         
## c_:_PE:STIM -0.723  0.006
```




### 2.4 plot behavioral PE & NPS.
group level slope, alongside subjectwise slopes

```r
library(ggplot2)

min_value <- -40
max_value <- 40
clean_merge_df$sub <- factor(clean_merge_df$sub)
plot.PE_NPS <- ggplot(clean_merge_df, aes(x = beh_PE, y = NPSpos)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  ylim(min_value, max_value) +  # Set y-axis limits
  theme_classic2()  # Use a theme with a white background
plot.PE_NPS
```

```
## Warning: Removed 15 rows containing non-finite values (`stat_smooth()`).
## Removed 15 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 15 rows containing missing values (`geom_point()`).
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-28-1.png" width="672" />


## 3. What did I submit to SfN?
* I Modeled the NPS as a function of PE, cue, and stim. 
* A discussion on whether this is a valid model would help.
* NOTE: The significant results I report today are coming from a model with just NPS and PE. 


### 3.1 test relationship between PE and cue type and stimintensity (06/16/2023)

```r
model.PENPS <- lmer(NPSpos ~ PE_mdl2*cue*stimintensity + (1|sub), data = clean_merge_df)
summary(model.PENPS)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: NPSpos ~ PE_mdl2 * cue * stimintensity + (1 | sub)
##    Data: clean_merge_df
## 
## REML criterion at convergence: 22208
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.1728 -0.5010 -0.0039  0.5144  4.4705 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  sub      (Intercept) 24.46    4.946   
##  Residual             63.52    7.970   
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##                                            Estimate Std. Error         df
## (Intercept)                                 6.10623    0.74449   96.82182
## PE_mdl2                                     0.05216    0.03408 3113.88819
## cuelow_cue                                  0.18526    0.83682 3117.14092
## stimintensitylow_stim                      -1.73262    0.78848 3110.68017
## stimintensitymed_stim                      -1.50598    0.59892 3098.17327
## PE_mdl2:cuelow_cue                         -0.02317    0.03938 3114.76956
## PE_mdl2:stimintensitylow_stim              -0.06475    0.04238 3110.24277
## PE_mdl2:stimintensitymed_stim              -0.06347    0.04631 3094.28132
## cuelow_cue:stimintensitylow_stim            0.30014    1.17257 3122.29563
## cuelow_cue:stimintensitymed_stim            0.80473    1.08363 3093.25778
## PE_mdl2:cuelow_cue:stimintensitylow_stim    0.08709    0.05028 3089.86651
## PE_mdl2:cuelow_cue:stimintensitymed_stim    0.08878    0.05352 3085.42303
##                                          t value Pr(>|t|)    
## (Intercept)                                8.202 1.01e-12 ***
## PE_mdl2                                    1.531   0.1260    
## cuelow_cue                                 0.221   0.8248    
## stimintensitylow_stim                     -2.197   0.0281 *  
## stimintensitymed_stim                     -2.514   0.0120 *  
## PE_mdl2:cuelow_cue                        -0.588   0.5563    
## PE_mdl2:stimintensitylow_stim             -1.528   0.1267    
## PE_mdl2:stimintensitymed_stim             -1.371   0.1706    
## cuelow_cue:stimintensitylow_stim           0.256   0.7980    
## cuelow_cue:stimintensitymed_stim           0.743   0.4578    
## PE_mdl2:cuelow_cue:stimintensitylow_stim   1.732   0.0833 .  
## PE_mdl2:cuelow_cue:stimintensitymed_stim   1.659   0.0972 .  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                           (Intr) PE_md2 culw_c stmntnstyl_ stmntnstym_
## PE_mdl2                   -0.200                                      
## cuelow_cue                -0.226  0.157                               
## stmntnstyl_               -0.251  0.211  0.274                        
## stmntnstym_               -0.330  0.286  0.303  0.355                 
## PE_mdl2:cl_                0.171 -0.854 -0.547 -0.218      -0.255     
## PE_mdl2:stmntnstyl_        0.154 -0.785 -0.077  0.303      -0.192     
## PE_mdl2:stmntnstym_        0.133 -0.675 -0.080 -0.083       0.169     
## clw_c:stmntnstyl_          0.167 -0.125 -0.745 -0.709      -0.246     
## clw_c:stmntnstym_          0.180 -0.144 -0.738 -0.220      -0.559     
## PE_mdl2:clw_c:stmntnstyl_ -0.128  0.641  0.347 -0.234       0.163     
## PE_mdl2:clw_c:stmntnstym_ -0.114  0.577  0.325  0.080      -0.142     
##                           PE_mdl2:c_ PE_mdl2:stmntnstyl_ PE_mdl2:stmntnstym_
## PE_mdl2                                                                     
## cuelow_cue                                                                  
## stmntnstyl_                                                                 
## stmntnstym_                                                                 
## PE_mdl2:cl_                                                                 
## PE_mdl2:stmntnstyl_        0.639                                            
## PE_mdl2:stmntnstym_        0.559      0.577                                 
## clw_c:stmntnstyl_          0.421     -0.249               0.028             
## clw_c:stmntnstym_          0.417      0.075              -0.117             
## PE_mdl2:clw_c:stmntnstyl_ -0.708     -0.806              -0.463             
## PE_mdl2:clw_c:stmntnstym_ -0.646     -0.486              -0.853             
##                           clw_c:stmntnstyl_ clw_c:stmntnstym_
## PE_mdl2                                                      
## cuelow_cue                                                   
## stmntnstyl_                                                  
## stmntnstym_                                                  
## PE_mdl2:cl_                                                  
## PE_mdl2:stmntnstyl_                                          
## PE_mdl2:stmntnstym_                                          
## clw_c:stmntnstyl_                                            
## clw_c:stmntnstym_          0.559                             
## PE_mdl2:clw_c:stmntnstyl_ -0.060            -0.284           
## PE_mdl2:clw_c:stmntnstym_ -0.214            -0.251           
##                           PE_mdl2:clw_c:stmntnstyl_
## PE_mdl2                                            
## cuelow_cue                                         
## stmntnstyl_                                        
## stmntnstym_                                        
## PE_mdl2:cl_                                        
## PE_mdl2:stmntnstyl_                                
## PE_mdl2:stmntnstym_                                
## clw_c:stmntnstyl_                                  
## clw_c:stmntnstym_                                  
## PE_mdl2:clw_c:stmntnstyl_                          
## PE_mdl2:clw_c:stmntnstym_  0.527
```

### 3.2 plot using PE and NPS as a function of cue

```r
subjectwise_2dv <- meanSummary_2dv(clean_merge_df, c("sub","stimintensity", "cue"), 
                                   "PE_mdl2", "NPSpos" )
plot.SfN_PE_NPS <- ggplot(data = subjectwise_2dv, 
       aes(x = .data[["DV1_mean_per_sub"]], 
           y = .data[["DV2_mean_per_sub"]],
           color = .data[["cue"]],
           # shape = .data[["stimintensity"]],
           # size = .5
           )) +
  geom_point(size = 2, alpha = .5  ) + 
  ylim(-50,50) + 
  xlim(-50,50) +
  coord_fixed() +
  scale_color_manual(values = c("high_cue" ="red","low_cue" =  "#5D5C5C"))+
  geom_abline(intercept = 0, slope = 1, color = "#373737", linetype = "dashed", linewidth = .5) + 
  xlab("PE") + 
  ylab("NPSpos")+
  theme(
    axis.line = element_line(colour = "grey50"),
    panel.background = element_blank(),
    plot.subtitle = ggtext::element_textbox_simple(size = 1), 
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15),
    axis.title.x = element_text(size = 20),
    axis.title.y = element_text(size = 20)
      
  )
plot.SfN_PE_NPS
```

```
## Warning: Removed 12 rows containing missing values (`geom_point()`).
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-30-1.png" width="672" />

### 3.3 plot the relationship between PE and NPS as a function of cue and stimulus intensity
<img src="25_RL_NPS_files/figure-html/unnamed-chunk-31-1.png" width="672" />

## 4. Manipulation check: bin the Jepma PE levels and look at the relationship with behavioral PE

```
## `geom_smooth()` using formula = 'y ~ x'
```

```
## Warning: Computation failed in `stat_smooth()`
## Caused by error in `get()`:
## ! object 'rlm' of mode 'function' was not found
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-32-1.png" width="672" />

## 5. Relationshipe between NPS and binned PE


### 5.1 lmer
* IV: PE (beh) * Stim * cue
* DV: NPSpos
* random effects: random intercepts per subject

```r
model.binPE <- lmer(NPSpos ~ pelevels + (pelevels|sub), data=clean_merge_df)
summary(model.binPE)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: NPSpos ~ pelevels + (pelevels | sub)
##    Data: clean_merge_df
## 
## REML criterion at convergence: 22191.3
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.1319 -0.4990 -0.0022  0.5214  4.4646 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr
##  sub      (Intercept) 22.25220 4.7172       
##           pelevels     0.05229 0.2287   0.07
##  Residual             63.24200 7.9525       
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##             Estimate Std. Error       df t value Pr(>|t|)    
## (Intercept)  3.95212    0.68689 57.39761   5.754 3.56e-07 ***
## pelevels     0.35090    0.06065 61.67305   5.786 2.59e-07 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##          (Intr)
## pelevels -0.322
```


```r
model.binPE_cue_stim <- lmer(NPSpos ~ pelevels*cue*stimintensity + (pelevels|sub), data=clean_merge_df)
summary(model.binPE_cue_stim)
```

```
## Linear mixed model fit by REML. t-tests use Satterthwaite's method [
## lmerModLmerTest]
## Formula: NPSpos ~ pelevels * cue * stimintensity + (pelevels | sub)
##    Data: clean_merge_df
## 
## REML criterion at convergence: 22179.5
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -5.2155 -0.4974  0.0014  0.5213  4.4811 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr
##  sub      (Intercept) 22.51815 4.7453       
##           pelevels     0.05553 0.2357   0.03
##  Residual             63.14620 7.9465       
## Number of obs: 3149, groups:  sub, 60
## 
## Fixed effects:
##                                            Estimate Std. Error        df
## (Intercept)                                  4.3784     1.3326  650.9588
## pelevels                                     0.3792     0.2179 1897.9212
## cuelow_cue                                   3.3922     2.2785 3026.6665
## stimintensitylow_stim                       -0.0366     1.2898 2933.9320
## stimintensitymed_stim                        0.2644     1.4295 3070.9412
## pelevels:cuelow_cue                         -0.4429     0.3052 2948.3169
## pelevels:stimintensitylow_stim              -0.1672     0.3424 2786.7013
## pelevels:stimintensitymed_stim              -0.3620     0.3110 3074.6781
## cuelow_cue:stimintensitylow_stim            -4.4956     2.5214 2754.9989
## cuelow_cue:stimintensitymed_stim            -3.8132     2.8068 3023.0486
## pelevels:cuelow_cue:stimintensitylow_stim    0.5976     0.4430 2609.2217
## pelevels:cuelow_cue:stimintensitymed_stim    0.7641     0.4272 3041.1439
##                                           t value Pr(>|t|)   
## (Intercept)                                 3.286  0.00107 **
## pelevels                                    1.740  0.08196 . 
## cuelow_cue                                  1.489  0.13665   
## stimintensitylow_stim                      -0.028  0.97736   
## stimintensitymed_stim                       0.185  0.85327   
## pelevels:cuelow_cue                        -1.451  0.14691   
## pelevels:stimintensitylow_stim             -0.488  0.62536   
## pelevels:stimintensitymed_stim             -1.164  0.24464   
## cuelow_cue:stimintensitylow_stim           -1.783  0.07469 . 
## cuelow_cue:stimintensitymed_stim           -1.359  0.17439   
## pelevels:cuelow_cue:stimintensitylow_stim   1.349  0.17745   
## pelevels:cuelow_cue:stimintensitymed_stim   1.789  0.07378 . 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Correlation of Fixed Effects:
##                         (Intr) pelvls culw_c stmntnstyl_ stmntnstym_ plvls:c_
## pelevels                -0.837                                               
## cuelow_cue              -0.425  0.451                                        
## stmntnstyl_             -0.791  0.842  0.428                                 
## stmntnstym_             -0.672  0.712  0.373  0.694                          
## plvls:clw_c              0.570 -0.667 -0.945 -0.572      -0.491              
## plvls:stmntnstyl_        0.485 -0.568 -0.257 -0.786      -0.452       0.383  
## plvls:stmntnstym_        0.508 -0.594 -0.283 -0.533      -0.914       0.412  
## clw_c:stmntnstyl_        0.361 -0.380 -0.867 -0.467      -0.333       0.815  
## clw_c:stmntnstym_        0.310 -0.324 -0.751 -0.323      -0.488       0.703  
## plvls:clw_c:stmntnstyl_ -0.341  0.399  0.593  0.573       0.333      -0.622  
## plvls:clw_c:stmntnstym_ -0.345  0.403  0.606  0.365       0.649      -0.634  
##                         plvls:stmntnstyl_ plvls:stmntnstym_ clw_c:stmntnstyl_
## pelevels                                                                     
## cuelow_cue                                                                   
## stmntnstyl_                                                                  
## stmntnstym_                                                                  
## plvls:clw_c                                                                  
## plvls:stmntnstyl_                                                            
## plvls:stmntnstym_        0.396                                               
## clw_c:stmntnstyl_        0.369             0.259                             
## clw_c:stmntnstym_        0.210             0.449             0.680           
## plvls:clw_c:stmntnstyl_ -0.747            -0.297            -0.823           
## plvls:clw_c:stmntnstym_ -0.274            -0.715            -0.556           
##                         clw_c:stmntnstym_ plvls:clw_c:stmntnstyl_
## pelevels                                                         
## cuelow_cue                                                       
## stmntnstyl_                                                      
## stmntnstym_                                                      
## plvls:clw_c                                                      
## plvls:stmntnstyl_                                                
## plvls:stmntnstym_                                                
## clw_c:stmntnstyl_                                                
## clw_c:stmntnstym_                                                
## plvls:clw_c:stmntnstyl_ -0.486                                   
## plvls:clw_c:stmntnstym_ -0.913             0.454
```

### 5.2. plot NPS and binned PE (jepma)

```r
iv1 = "PE_mdl2"; iv2 = "NPSpos"; levels = 10
k <-clean_merge_df %>% group_by(sub) %>% filter(n()>= 5) %>% ungroup()

clean_merge_df <- k %>%
  dplyr::group_by(.data[["sub"]]) %>%
  select(everything())  %>%
  mutate(
    bin = ggplot2::cut_interval(.data[[iv1]], n = levels),
    pelevels = as.numeric(cut_interval(.data[[iv1]], n = levels))
  )

# swp <- ggplot(
#   clean_merge_df,
#   aes(y = NPSpos,
#       x = pelevels,
#       colour = subject),
#   size = .01,
#   color = 'gray'
# ) +
#   geom_point(position = position_jitter(width = .1),size = .1, alpha = .3) +
#   # geom_smooth(method = 'lm', formula= y ~ x, se = FALSE, size = .1) +
#   geom_smooth(method = 'rlm', se = F, linewidth = .1, alpha = .5) +
#   theme(axis.line = element_line(colour = "grey50"), 
#       panel.background = element_blank(),
#       plot.subtitle = ggtext::element_textbox_simple(size= 11))
# swp 


ggplot(clean_merge_df, aes(x = pelevels, y = NPSpos)) + 
  geom_point(aes(colour = sub), size = .1) +  # Points colored by subject
  geom_smooth(aes(colour = sub), method = 'lm', formula = y ~ x, se = FALSE, size = .3, linetype = "dashed") +  # Subject-wise regression lines
  geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .5, color = "black") +  # Group regression line
  ylim(min_value, max_value) +  # Set y-axis limits
xlab( "PE (binned)" ) + ylab("NPSpos") +
  theme_classic2()  # Use a theme with a white background
```

```
## Warning: Removed 15 rows containing non-finite values (`stat_smooth()`).
## Removed 15 rows containing non-finite values (`stat_smooth()`).
```

```
## Warning: Removed 15 rows containing missing values (`geom_point()`).
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-35-1.png" width="672" />
### 5.3 plot NPS and binned PE (within subjects: average within bins -> aggregate this at the group lvel)

```r
iv1 = "PE_mdl2"; iv2 = "NPSpos"; levels = 10
k <-clean_merge_df %>% group_by(sub) %>% filter(n()>= 5) %>% ungroup()

clean_merge_df <- k %>%
  dplyr::group_by(.data[["sub"]]) %>%
  select(everything())  %>%
  mutate(
    bin = ggplot2::cut_interval(.data[[iv1]], n = levels),
    pelevels = as.numeric(cut_interval(.data[[iv1]], n = levels))
  )
################################################################################
model_iv1 <- "pelevels"
model_iv2 <- "NPSpos"
dv <- "NPSpos"
clean_merge_df$pelevels <- factor(clean_merge_df$pelevels)
PEbin_subjectwise <- meanSummary(clean_merge_df,
                                      c(subject, model_iv1), dv)
PEbin_groupwise <- summarySEwithin(
  data = PEbin_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1), #, model_iv2),
  idvar = subject
)
PEbin_groupwise$task <- taskname
signature_key <- "PE (behavioral)"
taskname <- "pain"
plot_keyword <- "stimulusintensity"
ggtitle_phrase <-  ""
data_screen$task = factor(data_screen$task)
plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key), " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ),
    title = paste0(str_to_title(signature_key), " - ", str_to_title(plot_keyword)),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  
################################################################################
# Lineplots {.unlisted .unnumbered} ____________________________________________
fig.PE_jepmabin <- plot_lineplot_onefactor(PEbin_groupwise, taskname = "pain",
                        iv = model_iv1, #iv2 = "cue_ordered", 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("#5D5C5C", "#941100"), 
                        ggtitle = paste0( "PE (behavioral) ", " (N = ", length(unique(data_screen$sub)), ")"    ), 
                        xlab = "PE (binned)", 
                        ylab = "NPSpos")
fig.PE_jepmabin
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-36-1.png" width="672" />


### 5.4. plot NPS,binned PE and cue type


```r
iv1 = "PE_mdl2"; iv2 = "NPSpos"; levels = 10
k <-clean_merge_df %>% group_by(sub) %>% filter(n()>= 5) %>% ungroup()

clean_merge_df <- k %>%
  dplyr::group_by(.data[["sub"]]) %>%
  select(everything())  %>%
  mutate(
    bin = ggplot2::cut_interval(.data[[iv1]], n = levels),
    pelevels = as.numeric(cut_interval(.data[[iv1]], n = levels))
  )
################################################################################
model_iv1 <- "pelevels"
model_iv2 <- "cue"
dv <- "NPSpos"
clean_merge_df$pelevels <- factor(clean_merge_df$pelevels)
PEbin_subjectwise <- meanSummary(clean_merge_df,
                                      c(subject, model_iv1, model_iv2), dv)
PEbin_groupwise <- summarySEwithin(
  data = PEbin_subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c(model_iv1, model_iv2),
  idvar = subject
)
```

```
## Automatically converting the following non-factors to factors: cue
```

```r
PEbin_groupwise$task <- taskname
signature_key <- "PE (behavioral)"
taskname <- "pain"
plot_keyword <- "stimulusintensity"
ggtitle_phrase <-  ""
data_screen$task = factor(data_screen$task)
plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key), " dot product: ", str_to_title(taskname), ' ', ggtitle_phrase, " (N = ", length(unique(data_screen$sub)), ")"
    ),
    title = paste0(str_to_title(signature_key), " - ", str_to_title(plot_keyword)),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  
################################################################################
# Lineplots {.unlisted .unnumbered} ____________________________________________
fig.PE_beh <- plot_lineplot_twofactor(PEbin_groupwise, #taskname = "pain",
                        iv = model_iv1, iv2 = model_iv2, 
                        mean = "mean_per_sub_norm_mean", error = "se",
                        color = c("#5D5C5C", "#941100"), 
                        ggtitle = paste0( "PE (behavioral) ", " (N = ", length(unique(data_screen$sub)), ")"    ), 
                        xlab = "PE (binned)", 
                        ylab = "NPSpos")
fig.PE_beh
```

<img src="25_RL_NPS_files/figure-html/unnamed-chunk-37-1.png" width="672" />

### 5.5 plot the relationship between PE and NPS as a function of cue and stimulus intensity
<img src="25_RL_NPS_files/figure-html/unnamed-chunk-38-1.png" width="672" />

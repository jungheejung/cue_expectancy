library(car)
library(psych)
library(reshape)
library(dplyr)
library(tidyselect)
library(tidyr)
library(stringr)
library(lmerTest)
library(gghalves)
library(plyr)
library(ggpubr)
library(r2mlm)
library(effectsize)
library(devtools)
options(es.use_symbols = TRUE) # get nice symbols when printing! (On Windows, requires R >= 4.2.0)
library(EMAtools)
library(emmeans)
library(sjPlot)
library(sjmisc)
library(sjlabelled)
library(DT)
library(raincloudplots)
# devtools::source_url("https://raw.githubusercontent.com/RainCloudPlots/RainCloudPlots/master/tutorial_R/R_rainclouds.R")
# devtools::source_url("https://raw.githubusercontent.com/RainCloudPlots/RainCloudPlots/master/tutorial_R/summarySE.R")

devtools::source_url("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")
library(r2mlm)
main_dir <- dirname(dirname(getwd()))
file.sources = list.files(file.path(main_dir, 'scripts', 'step02_R', 'utils'),
                          pattern="*.R",
                          full.names=TRUE,
                          ignore.case=TRUE)
sapply(file.sources,source,.GlobalEnv)

# extract sub directories ______________________________________________________
events_dir <- file.path(main_dir, 'data', 'beh')
sub_dirs <- list.files(path = events_dir, pattern = "^sub-", full.names = TRUE, recursive = FALSE, include.dirs = TRUE)

list_of_dfs <- list()
library(readr)
library(dplyr)
library(purrr)

# function :: construct filename based on BIDS metadata ________________________
construct_trial_name <- function(trial_index, cue, stimulusintensity, sub, ses, run, runtype) {
  sprintf("%s_%s_%s_runtype-%s_event-stimulus_trial-%03d_cuetype-%s_stimintensity-%s.nii.gz",
          sub, ses, run, runtype, trial_index - 1, 
          gsub("_cue", "", cue), gsub("_stim", "", stimulusintensity))
}

for (sub_dir in sub_dirs) {
  # Find "_events.tsv" files within each sub-directory
  event_files <- list.files(path = sub_dir, pattern = "_events\\.tsv$", full.names = TRUE, recursive = TRUE)
  
  # Loop through each file, read it, and store it in the list
  for (file_path in event_files) {
    df <- read_tsv(file_path, show_col_types = FALSE)  # Or read.delim(file_path, sep = "\t") for base R
    
    # extract rating data ______________________________________________________
    expect <- df[df$trial_type == "expectrating", c("trial_index", "rating_value_fillna", "rating_glmslabel_fillna")]
    names(expect) <- c("trial_index", "expectrating", "expectlabel")
    
    stim <- df[df$trial_type == "stimulus", c("trial_index", "cue", "stimulusintensity")]
    outcome <- df[df$trial_type == "outcomerating", c("trial_index", "rating_value_fillna", "rating_glmslabel_fillna")]
    names(outcome) <- c("trial_index", "outcomerating", "outcomelabel")
    
    # extract metadata and construct singletrial fname _________________________
    sub <- str_extract(file_path, "sub-\\d+")
    ses <- str_extract(file_path, "ses-\\d+")
    run <- str_extract(file_path, "run-\\d+")
    runtype <- str_extract(file_path, "(?<=desc-)[a-zA-Z]+(?=_events\\.tsv)")
    stim$sub <- sub;    stim$ses <- ses;    stim$run <- run;    stim$runtype <- runtype
    stim$singletrial_fname <- stim %>%
      mutate(trial_index = as.numeric(as.character(trial_index))) %>%
      pmap_chr(function(trial_index, cue, stimulusintensity, sub, ses, run, runtype) {
        construct_trial_name(trial_index, cue, stimulusintensity, sub, ses, run, runtype)
      })
    stim <- stim[c( "sub","ses","run","runtype","trial_index", "cue","stimulusintensity","singletrial_fname")]

    cleandf <- stim %>%
      inner_join(expect, by = "trial_index") %>%
      inner_join(outcome, by = "trial_index")
    
    list_of_dfs[[length(list_of_dfs) + 1]] <- cleandf
  }
}

# Combine all data frames into one
final_df <- bind_rows(list_of_dfs)  # Or do.call("rbind", list_of_dfs) for base R
write.table(final_df, 
            file = file.path(events_dir, "sub-all_task-all_events.tsv"), 
            sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

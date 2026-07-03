#!/usr/bin/env Rscript
# ==============================================================================
# vascular_carryover_control.R
#
# Reviewer control: is the "reverse" cue effect on stim-epoch NPS (cueL > cueH)
# just a hemodynamic tail carried over from the anticipation (cue) epoch?
#
# Test: add each trial's CUE-EPOCH NPS as a covariate to the stim-epoch model.
# If the stim-epoch cue effect survives controlling for anticipatory NPS, it is
# not explained by vascular carry-over.
#
#   M0: NPS_stim ~ CUE*STIM + (CUE|sub)                      (reverse cue effect)
#   M1: NPS_stim ~ CUE*STIM + NPS_cueepoch + (CUE|sub)       (+ carry-over covar)
#
# Run from scripts/step02_R_bookdown:  Rscript vascular_carryover_control.R
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse); library(lme4); library(lmerTest); library(broom.mixed)
})
main_dir <- dirname(dirname(getwd()))
if (!dir.exists(file.path(main_dir, "analysis")))
  main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"
out_dir <- file.path(main_dir, "analysis", "mixedeffect_revision", "painpathway", "tables")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- trial key that ignores event + stimintensity ----------------------------
# stim fname: ..._event-stimulus_trial-XX_cuetype-hi_stimintensity-hi.nii.gz
# cue  fname: ..._event-cue_trial-XX_cuetype-hi.nii.gz
trial_key <- function(x) {
  x <- sub("_event-(cue|stimulus)", "", x)
  x <- sub("_stimintensity-(high|med|low)", "", x)
  sub("\\.nii\\.gz$", "", x)
}

# ---- stim-epoch NPS + behaviour ----------------------------------------------
beh <- readr::read_tsv(file.path(main_dir, "data/beh/sub-all_task-all_events.tsv"),
                       show_col_types = FALSE)
NPS_stim <- read.csv(file.path(main_dir,
  "analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab/signature-NPS_sub-all_runtype-pvc_event-stimulus.csv")) %>%
  select(singletrial_fname, NPS = nps, NPSpos = npspos)

stim <- inner_join(beh, NPS_stim, by = "singletrial_fname") %>%
  mutate(singletrial_fname = as.character(singletrial_fname)) %>%
  extract(singletrial_fname,
          into = c("sub","ses","run","runtype","event","trial","cuetype","stimintensity"),
          regex = "^(sub-\\d+)_(ses-\\d+)_(run-\\d+)_runtype-(pain|vicarious|cognitive)_event-(cue|stimulus)_trial-(\\d+)_cuetype-(high|low)(?:_stimintensity-(high|med|low))?\\.nii.gz$",
          remove = FALSE) %>%
  filter(runtype == "pain") %>%
  mutate(
    key = trial_key(singletrial_fname),
    CUE_high_gt_low = dplyr::recode(cue, low_cue = -0.5, high_cue = 0.5),
    STIM_linear     = dplyr::recode(stimulusintensity, low_stim = -0.5, med_stim = 0,    high_stim = 0.5),
    STIM_quadratic  = dplyr::recode(stimulusintensity, low_stim = -0.33, med_stim = 0.66, high_stim = -0.33)
  )

# ---- cue-epoch NPS -----------------------------------------------------------
NPS_cue <- read.csv(file.path(main_dir,
  "data/curated/sub-all_signature-NPS_runtype-pain_event-cue.csv")) %>%
  transmute(key = trial_key(as.character(singletrial_fname)),
            NPS_cueepoch = NPS, NPSpos_cueepoch = NPSpos)

dat <- inner_join(stim, NPS_cue, by = "key")
cat(sprintf("matched trials: %d   subjects: %d\n", nrow(dat), dplyr::n_distinct(dat$sub)))

# ---- models ------------------------------------------------------------------
fit <- function(fml) lmer(fml, data = dat,
                          control = lmerControl(optimizer = "bobyqa",
                                                check.conv.singular = .makeCC("ignore", 1e-4)))
M0 <- fit(NPS ~ CUE_high_gt_low * STIM_linear + CUE_high_gt_low * STIM_quadratic + (CUE_high_gt_low | sub))
M1 <- fit(NPS ~ CUE_high_gt_low * STIM_linear + CUE_high_gt_low * STIM_quadratic +
            scale(NPS_cueepoch) + (CUE_high_gt_low | sub))

cue0 <- tidy(M0, effects = "fixed") %>% filter(term == "CUE_high_gt_low")
cue1 <- tidy(M1, effects = "fixed") %>% filter(term == "CUE_high_gt_low")

cat("\n=== stim-epoch NPS cue effect, before vs after controlling for cue-epoch NPS ===\n")
comp <- bind_rows(
  cue0 %>% mutate(model = "M0: no covariate", .before = 1),
  cue1 %>% mutate(model = "M1: + cue-epoch NPS", .before = 1)
) %>% select(model, estimate, std.error, statistic, df, p.value)
print(as.data.frame(comp %>% mutate(across(where(is.numeric), ~round(., 4)))), row.names = FALSE)

pct <- 100 * (abs(cue0$estimate) - abs(cue1$estimate)) / abs(cue0$estimate)
cat(sprintf("\ncue-effect magnitude change after covarying anticipatory NPS: %+.1f%% (neg = attenuated)\n", pct))
cat(sprintf(">> NPS cue effect: M0 p=%.3f (%s) -> M1 p=%.3f (%s).\n",
            cue0$p.value, ifelse(cue0$p.value < .05, "sig", "n.s."),
            cue1$p.value, ifelse(cue1$p.value < .05, "sig", "n.s.")))
cat("   (Interpret relative to whether M0 was significant; full NPS cue effect is n.s. by design.)\n")

readr::write_csv(comp, file.path(out_dir, "vascular_carryover_NPS.csv"))

# Same test for NPSpos (the signature that carries the significant cue effect)
P0 <- fit(NPSpos ~ CUE_high_gt_low * STIM_linear + CUE_high_gt_low * STIM_quadratic + (CUE_high_gt_low | sub))
P1 <- fit(NPSpos ~ CUE_high_gt_low * STIM_linear + CUE_high_gt_low * STIM_quadratic +
            scale(NPSpos_cueepoch) + (CUE_high_gt_low | sub))
cat("\n=== NPSpos: same control ===\n")
compp <- bind_rows(
  tidy(P0, effects="fixed") %>% filter(term=="CUE_high_gt_low") %>% mutate(model="M0", .before=1),
  tidy(P1, effects="fixed") %>% filter(term=="CUE_high_gt_low") %>% mutate(model="M1 + cueNPSpos", .before=1)
) %>% select(model, estimate, std.error, statistic, df, p.value)
print(as.data.frame(compp %>% mutate(across(where(is.numeric), ~round(., 4)))), row.names = FALSE)
readr::write_csv(compp, file.path(out_dir, "vascular_carryover_NPSpos.csv"))

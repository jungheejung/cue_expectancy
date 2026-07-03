#!/usr/bin/env Rscript
# ==============================================================================
# revision_intersection_and_cueepoch.R
#
# (1) Define the common analysis sample = beh INTERSECT NPS INTERSECT SIIPS
#     INTERSECT ROI (SCR handled separately). Save the subject list.
# (2) Cue-epoch (anticipatory) NPS analysis, restricted to that common sample:
#         cueepoch_NPS    ~ CUE + (CUE | sub)
#         cueepoch_NPSpos ~ CUE + (CUE | sub)
#     Answers "does the NPS cue effect appear during anticipation?" -- separate
#     from the STIM-epoch cue effect reported in the main NPS analysis.
#
# Run from scripts/step02_R_bookdown:  Rscript revision_intersection_and_cueepoch.R
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse); library(lme4); library(lmerTest); library(broom.mixed)
})
main_dir <- dirname(dirname(getwd()))
if (!dir.exists(file.path(main_dir, "analysis")))
  main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"

canlab <- file.path(main_dir, "analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab")
subs_of <- function(path, sep = ",", col = "singletrial_fname") {
  d <- readr::read_delim(path, delim = sep, show_col_types = FALSE)
  unique(str_extract(as.character(d[[col]]), "sub-[0-9]+"))
}

beh   <- subs_of(file.path(main_dir, "data/beh/sub-all_task-all_events.tsv"), sep = "\t")
nps   <- subs_of(file.path(canlab, "signature-NPS_sub-all_runtype-pvc_event-stimulus.csv"))
siips <- subs_of(file.path(canlab, "signature-SIIPS_sub-all_runtype-pain_event-stimulus.csv"))
roi   <- subs_of(file.path(main_dir,
  "analysis/fmri/nilearn/deriv01_signature/rampup_plateau_painpathway/roi-painpathway_sub-all_runtype-pvc_event-stimulus.tsv"),
  sep = "\t")

common <- sort(Reduce(intersect, list(beh = beh, NPS = nps, SIIPS = siips, ROI = roi)))
cat(sprintf("beh=%d  NPS=%d  SIIPS=%d  ROI=%d\n", length(beh), length(nps), length(siips), length(roi)))
cat(sprintf(">> COMMON analysis sample (beh n NPS n SIIPS n ROI): N = %d\n\n", length(common)))

rev_dir <- file.path(main_dir, "analysis", "mixedeffect_revision")
dir.create(rev_dir, showWarnings = FALSE, recursive = TRUE)
readr::write_csv(tibble(sub = common), file.path(rev_dir, "participants_intersection.csv"))
cat("saved subject list ->", file.path(rev_dir, "participants_intersection.csv"), "\n\n")

# ---- (2) cue-epoch NPS, restricted to the common sample ----------------------
out_dir <- file.path(rev_dir, "cueepoch_nps"); dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

cueNPS <- read.csv(file.path(main_dir, "data/curated/sub-all_signature-NPS_runtype-pain_event-cue.csv")) %>%
  mutate(
    singletrial_fname = as.character(singletrial_fname),
    sub = str_extract(singletrial_fname, "sub-[0-9]+"),
    cue = paste0(str_replace(str_extract(singletrial_fname, "cuetype-(high|low)"), "cuetype-", ""), "_cue"),
    CUE_high_gt_low = dplyr::recode(cue, low_cue = -0.5, high_cue = 0.5)
  ) %>%
  filter(sub %in% common)

cat(sprintf("cue-epoch NPS trials: %d   subjects (in common sample): %d\n\n",
            nrow(cueNPS), n_distinct(cueNPS$sub)))

fit <- function(dv) lmer(as.formula(paste(dv, "~ CUE_high_gt_low + (CUE_high_gt_low | sub)")),
                         data = cueNPS, control = lmerControl(optimizer = "bobyqa"))

res <- purrr::map_dfr(c("NPS", "NPSpos", "NPSneg"), function(dv) {
  m <- fit(dv)
  tidy(m, effects = "fixed") %>% filter(term == "CUE_high_gt_low") %>%
    mutate(signature = paste0("cueepoch_", dv), .before = 1) %>%
    mutate(conf.low = estimate - 1.96 * std.error, conf.high = estimate + 1.96 * std.error)
})

cat("=== CUE-EPOCH (anticipatory) NPS cue effect (high - low) ===\n")
print(as.data.frame(res %>% transmute(signature, beta = round(estimate, 3), SE = round(std.error, 3),
       CI = sprintf("[%.2f, %.2f]", conf.low, conf.high), t = round(statistic, 2),
       df = round(df, 0), p = signif(p.value, 3))), row.names = FALSE)
readr::write_csv(res, file.path(out_dir, "cueepoch_NPS_cue_effect.csv"))
cat("\nsaved ->", file.path(out_dir, "cueepoch_NPS_cue_effect.csv"), "\n")

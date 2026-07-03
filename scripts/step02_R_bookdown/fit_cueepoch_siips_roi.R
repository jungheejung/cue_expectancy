#!/usr/bin/env Rscript
# ==============================================================================
# fit_cueepoch_siips_roi.R
#
# Anticipatory (cue-epoch) models for SIIPS and the 15 pain-pathway ROIs, on the
# common analysis sample (N=97, participants_intersection.csv). The cue epoch
# precedes the stimulus, so the model is a CUE main effect only (no stim terms):
#     signature/ROI ~ CUE_high_gt_low + (CUE_high_gt_low | sub)
# Mirrors the cue-epoch NPS model in revision_intersection_and_cueepoch.R.
#
# INPUTS (produced on the cluster by the CANlab extractors, then synced here):
#   .../deriv01_signature/rampup_plateau_canlab/signature-SIIPS_sub-all_runtype-pvc_event-cue.tsv
#   .../deriv01_signature/rampup_plateau_painpathway/roi-painpathway_sub-all_runtype-pvc_event-cue.tsv
#
# Run from scripts/step02_R_bookdown:  Rscript fit_cueepoch_siips_roi.R
# Outputs -> analysis/mixedeffect_revision/cueepoch_nps/
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse); library(lme4); library(lmerTest); library(broom.mixed); library(effectsize)
})
main_dir <- dirname(dirname(getwd()))
if (!dir.exists(file.path(main_dir, "analysis")))
  main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"

out_dir <- file.path(main_dir, "analysis", "mixedeffect_revision", "cueepoch_nps")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

siips_tsv <- file.path(main_dir, "analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab",
                       "signature-SIIPS_sub-all_runtype-pvc_event-cue.tsv")
roi_tsv   <- file.path(main_dir, "analysis/fmri/nilearn/deriv01_signature/rampup_plateau_painpathway",
                       "roi-painpathway_sub-all_runtype-pvc_event-cue.tsv")

if (!file.exists(siips_tsv) && !file.exists(roi_tsv)) {
  stop("Cue-epoch tsvs not found yet. Run the CANlab extractors on the cluster first:\n",
       "  step02_applysignature_cueepoch  (SIIPS)\n  step02_extract_ROI_cueepoch     (ROIs)\n",
       "expected:\n  ", siips_tsv, "\n  ", roi_tsv)
}

common <- readr::read_csv(file.path(main_dir, "analysis/mixedeffect_revision/participants_intersection.csv"),
                          show_col_types = FALSE)$sub

# parse sub / runtype / cue from singletrial_fname; keep pain trials, common sample
prep <- function(df) {
  df %>%
    mutate(
      singletrial_fname = as.character(singletrial_fname),
      sub     = str_extract(singletrial_fname, "sub-[0-9]+"),
      runtype = str_extract(singletrial_fname, "runtype-(pain|vicarious|cognitive)") %>% str_remove("runtype-"),
      cue     = paste0(str_remove(str_extract(singletrial_fname, "cuetype-(high|low)"), "cuetype-"), "_cue"),
      CUE_high_gt_low = dplyr::recode(cue, low_cue = -0.5, high_cue = 0.5)
    ) %>%
    filter(runtype == "pain", sub %in% common)
}

# per-effect effect sizes for the single CUE term
es_row <- function(m, label) {
  co <- as.data.frame(coef(summary(m))); co$term <- rownames(co)
  cue <- co[co$term == "CUE_high_gt_low", ]
  r <- effectsize::t_to_r(cue$`t value`, cue$df); d <- effectsize::t_to_d(cue$`t value`, cue$df)
  tibble(dv = label, estimate = cue$Estimate, std.error = cue$`Std. Error`,
         statistic = cue$`t value`, df = cue$df, p.value = cue$`Pr(>|t|)`,
         conf.low = cue$Estimate - 1.96*cue$`Std. Error`,
         conf.high = cue$Estimate + 1.96*cue$`Std. Error`,
         partial_r = r$r, cohens_d = d$d)
}
fit_cue <- function(df, dv) lmer(as.formula(paste(dv, "~ CUE_high_gt_low + (CUE_high_gt_low | sub)")),
                                 data = df, control = lmerControl(optimizer = "bobyqa"))

# ---- SIIPS -------------------------------------------------------------------
if (file.exists(siips_tsv)) {
  siips <- prep(readr::read_tsv(siips_tsv, show_col_types = FALSE))
  m <- fit_cue(siips, "SIIPS")
  siips_res <- es_row(m, "cueepoch_SIIPS")
  cat("\n=== CUE-EPOCH SIIPS ===\n")
  print(as.data.frame(siips_res %>% mutate(across(where(is.numeric), ~round(., 4)))), row.names = FALSE)
  readr::write_csv(siips_res, file.path(out_dir, "cueepoch_SIIPS_cue_effect.csv"))
}

# ---- 15 pain-pathway ROIs ----------------------------------------------------
if (file.exists(roi_tsv)) {
  roi <- prep(readr::read_tsv(roi_tsv, show_col_types = FALSE))
  rois <- c("Thal_VPLM","Thal_IL","Thal_MD","Hythal","pbn","Bstem_PAG","rvm","Amy",
            "dpIns","S2","mIns","aIns","aMCC_MPFC","s1_foot","s1_handplus")
  rois <- rois[rois %in% names(roi)]                       # only those present
  roi_res <- purrr::map_dfr(rois, ~ es_row(fit_cue(roi, .x), .x)) %>%
    mutate(p_FDR = p.adjust(p.value, method = "BH"), sig_FDR = p_FDR < .05) %>%
    arrange(p.value)
  cat("\n=== CUE-EPOCH pain-pathway ROIs (FDR across 15) ===\n")
  print(as.data.frame(roi_res %>% mutate(across(where(is.numeric), ~round(., 4)))), row.names = FALSE)
  cat(sprintf("\nROIs with anticipatory cue effect (FDR q<.05): %d of %d\n", sum(roi_res$sig_FDR), nrow(roi_res)))
  readr::write_csv(roi_res, file.path(out_dir, "cueepoch_ROI_cue_effect_FDR.csv"))
}

cat("\nsaved -> ", out_dir, "\n")

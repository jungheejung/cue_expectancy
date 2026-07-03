#!/usr/bin/env Rscript
# ==============================================================================
# revision_stats_hardening.R
#
# Three additions for revision:
#   (1) effect_size_lmer()  -- per-fixed-effect effect sizes (partial r, and
#       Cohen's d) + whole-model marginal/conditional R^2, for ANY lmer model.
#   (2) painpathway ROI family: refit the 15 ROI cue/stim models, tabulate cue
#       effects with FDR (Benjamini-Hochberg) correction + effect sizes.
#   (3) FORMAL double dissociation test: does cue modulate NPS differently than
#       SIIPS? Stacks the two signatures (z-scored within signature) and tests
#       the signature x cue interaction -- the correct test, instead of arguing
#       from "one significant, one not".
#
# Run:  cd scripts/step02_R_bookdown && Rscript revision_stats_hardening.R
# Outputs -> analysis/mixedeffect_revision/painpathway/tables/
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse); library(lme4); library(lmerTest); library(broom.mixed)
  library(effectsize)
})

`%||%` <- function(a, b) if (is.null(a)) b else a
# run from scripts/step02_R_bookdown -> main_dir is two levels up
main_dir <- dirname(dirname(getwd()))
if (!dir.exists(file.path(main_dir, "analysis"))) {
  main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"   # fallback
}
out_dir <- file.path(main_dir, "analysis", "mixedeffect_revision", "painpathway", "tables")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- (1) effect-size helper --------------------------------------------------
#' Per-fixed-effect effect sizes for a fitted (lmerTest) model, plus model R^2.
#' - partial_r : t_to_r(t, df) -- partial correlation for each fixed effect.
#' - cohens_d  : t_to_d(t, df) -- standardized mean-difference metric.
#' - std_beta  : fully standardized coefficient (predictors + outcome z-scored).
#' - R2m / R2c : marginal (fixed only) / conditional (fixed+random) R^2.
effect_size_lmer <- function(model, label = NULL) {
  co <- as.data.frame(coef(summary(model)))
  co$term <- rownames(co); rownames(co) <- NULL
  tcol  <- grep("t value", names(co), value = TRUE)
  dfcol <- grep("^df$",    names(co), value = TRUE)
  r  <- effectsize::t_to_r(co[[tcol]], co[[dfcol]])
  d  <- effectsize::t_to_d(co[[tcol]], co[[dfcol]])
  sb <- tryCatch(as.data.frame(effectsize::standardize_parameters(model)),
                 error = function(e) NULL)

  R2 <- tryCatch(
    if (requireNamespace("MuMIn", quietly = TRUE)) as.numeric(MuMIn::r.squaredGLMM(model))[1:2]
    else if (requireNamespace("performance", quietly = TRUE)) unlist(performance::r2(model))[1:2]
    else c(NA, NA),
    error = function(e) c(NA, NA))

  out <- tibble(
    label      = label %||% NA_character_,
    term       = co$term,
    estimate   = co$Estimate,
    partial_r  = r$r,
    r_CI_low   = r$CI_low, r_CI_high = r$CI_high,
    cohens_d   = d$d,
    std_beta   = if (!is.null(sb)) sb$Std_Coefficient[match(co$term, sb$Parameter)] else NA_real_,
    R2_marginal    = R2[1],
    R2_conditional = R2[2]
  )
  out
}

# ---- data prep (mirrors book_painpathway_flatten_claude.Rmd) ------------------
beh <- readr::read_tsv(file.path(main_dir, "data/beh/sub-all_task-all_events.tsv"),
                       show_col_types = FALSE)
roi <- readr::read_tsv(file.path(main_dir,
  "analysis/fmri/nilearn/deriv01_signature/rampup_plateau_painpathway/roi-painpathway_sub-all_runtype-pvc_event-stimulus.tsv"),
  show_col_types = FALSE)

contrast_code <- function(df) {
  df$STIM_linear    <- dplyr::recode(df$stimulusintensity, low_stim = -0.5, med_stim = 0,    high_stim = 0.5)
  df$STIM_quadratic <- dplyr::recode(df$stimulusintensity, low_stim = -0.33, med_stim = 0.66, high_stim = -0.33)
  df$CUE_high_gt_low <- dplyr::recode(df$cue, low_cue = -0.5, high_cue = 0.5)
  df
}

df <- inner_join(beh, roi, by = "singletrial_fname") %>%
  mutate(singletrial_fname = as.character(singletrial_fname)) %>%
  extract(singletrial_fname,
          into = c("sub","ses","run","runtype","event","trial","cuetype","stimintensity"),
          regex = "^(sub-\\d+)_(ses-\\d+)_(run-\\d+)_runtype-(pain|vicarious|cognitive)_event-(cue|stimulus)_trial-(\\d+)_cuetype-(high|low)(?:_stimintensity-(high|med|low))?\\.nii.gz$",
          remove = FALSE) %>%
  filter(runtype == "pain") %>%
  contrast_code()

# restrict to the common analysis sample (beh n NPS n SIIPS n ROI); SCR separate.
isect <- file.path(main_dir, "analysis", "mixedeffect_revision", "participants_intersection.csv")
if (file.exists(isect)) {
  common <- readr::read_csv(isect, show_col_types = FALSE)$sub
  df <- df %>% filter(sub %in% common)
  message(sprintf("restricted to common sample: N = %d", dplyr::n_distinct(df$sub)))
} else {
  message("participants_intersection.csv not found -- run revision_intersection_and_cueepoch.R first.")
}

# min-2-trials-per-cell filter
bad <- df %>% group_by(sub, CUE_high_gt_low, STIM_linear) %>%
  summarise(n = n(), .groups = "drop") %>% filter(n < 2) %>% distinct(sub) %>% pull(sub)
df <- df %>% filter(!(sub %in% bad))

rois <- c("Thal_VPLM","Thal_IL","Thal_MD","Hythal","pbn","Bstem_PAG","rvm","Amy",
          "dpIns","S2","mIns","aIns","aMCC_MPFC","s1_foot","s1_handplus")

# ---- (2) ROI family: effect sizes + FDR on the cue effect --------------------
roi_es <- purrr::map_dfr(rois, function(dv) {
  m <- lmer(as.formula(paste(dv, "~ CUE_high_gt_low * STIM_linear + CUE_high_gt_low * STIM_quadratic + (1|sub)")),
            data = df, control = lmerControl(optimizer = "bobyqa"))
  tidy(m, effects = "fixed") %>%
    left_join(effect_size_lmer(m, dv), by = c("term")) %>%
    mutate(dv = dv, .before = 1)
})

cue_family <- roi_es %>%
  filter(term == "CUE_high_gt_low") %>%
  mutate(p_FDR = p.adjust(p.value, method = "BH"),
         sig_FDR = p_FDR < .05) %>%
  select(dv, estimate = estimate.x, std.error, statistic, df, p.value, p_FDR, sig_FDR,
         partial_r, cohens_d, R2_marginal, R2_conditional) %>%
  arrange(p.value)

readr::write_csv(roi_es,     file.path(out_dir, "roi_effectsizes_all_terms.csv"))
readr::write_csv(cue_family, file.path(out_dir, "roi_cue_effect_FDR_effectsizes.csv"))
cat("\n=== ROI cue effects: FDR-corrected + effect sizes ===\n")
print(as.data.frame(cue_family %>% mutate(across(where(is.numeric), ~round(., 4)))), row.names = FALSE)

# ---- (3) formal NPS vs SIIPS double dissociation -----------------------------
canlab <- file.path(main_dir, "analysis/fmri/nilearn/deriv01_signature/rampup_plateau_canlab")
NPS   <- read.csv(file.path(canlab, "signature-NPS_sub-all_runtype-pvc_event-stimulus.csv"))  %>%
  select(singletrial_fname, NPS = nps)
SIIPS <- read.csv(file.path(canlab, "signature-SIIPS_sub-all_runtype-pain_event-stimulus.csv")) %>%
  select(singletrial_fname, SIIPS)

sig_wide <- df %>% select(singletrial_fname, sub, CUE_high_gt_low, STIM_linear, STIM_quadratic) %>%
  inner_join(NPS,   by = "singletrial_fname") %>%
  inner_join(SIIPS, by = "singletrial_fname")

# z-score each signature (different native scales) THEN stack long
sig_long <- sig_wide %>%
  mutate(NPS_z = as.numeric(scale(NPS)), SIIPS_z = as.numeric(scale(SIIPS))) %>%
  pivot_longer(c(NPS_z, SIIPS_z), names_to = "signature", values_to = "score_z") %>%
  mutate(signature = factor(sub("_z$", "", signature), levels = c("NPS", "SIIPS")))
# contrast-code signature: NPS = -0.5, SIIPS = +0.5 (interaction = SIIPS - NPS)
sig_long$sig_c <- ifelse(sig_long$signature == "SIIPS", 0.5, -0.5)

m_diss <- lmer(
  score_z ~ sig_c * CUE_high_gt_low + sig_c * STIM_linear + sig_c * STIM_quadratic +
    (1 | sub) + (1 | sub:signature),
  data = sig_long, control = lmerControl(optimizer = "bobyqa"))

cat("\n=== Double dissociation: signature (SIIPS-NPS) x cue interaction ===\n")
diss_tab <- tidy(m_diss, effects = "fixed") %>%
  left_join(effect_size_lmer(m_diss, "dissociation"), by = "term") %>%
  select(term, estimate = estimate.x, std.error, statistic, df, p.value, partial_r)
print(as.data.frame(diss_tab %>% mutate(across(where(is.numeric), ~round(., 4)))), row.names = FALSE)
readr::write_csv(diss_tab, file.path(out_dir, "signature_double_dissociation.csv"))

key <- diss_tab %>% filter(term == "sig_c:CUE_high_gt_low")
cat(sprintf("\n>> Interaction sig_c:CUE  b=%.3f, t(%.0f)=%.2f, p=%.4g  (partial r=%.3f)\n",
            key$estimate, key$df, key$statistic, key$p.value, key$partial_r))
cat("   Significant interaction == cue modulates the two signatures DIFFERENTLY (formal dissociation).\n\n")

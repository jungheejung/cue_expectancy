#!/usr/bin/env Rscript
# ==============================================================================
# cbpt_per_roi_report.R  (Results §11 reporting table)
#
# One row per ROI x epoch: omnibus Cauchy-combination p (cct_epoch_p), the
# significant temporal cluster(s) with window / mass / cluster_p, and a
# DESCRIPTIVE effect magnitude = peak cueH-cueL FIR difference (there is no beta:
# CBPT is F-based). N=86.
#
# Run from scripts/step02_R_bookdown:  Rscript cbpt_per_roi_report.R
# Output -> analysis/mixedeffect_revision/fir/cbpt_per_ROI_report.csv
# ==============================================================================
suppressPackageStartupMessages({library(tidyverse)})
main_dir <- dirname(dirname(getwd()))
if (!dir.exists(file.path(main_dir, "analysis")))
  main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"
fir <- file.path(main_dir, "analysis/mixedeffect_revision/fir")
TR <- 0.46

# ---- CBPT: one row per SIGNIFICANT cluster (cluster_p only; the cluster
#      permutation test already corrects across time -- no CCT, avoids extra tests)
cb <- readr::read_csv(file.path(fir, "cbpt_cluster_summary_flat.csv"), show_col_types = FALSE)
per <- cb %>% filter(cluster_sig) %>%
  transmute(ROI, epoch = contrast, N = n_subjects,
            window_s = sprintf("%.1f-%.1f", t_start_sec, t_end_sec),
            cluster_mass = round(cluster_mass, 1),
            cluster_p = signif(cluster_p, 2))

# ---- peak cueH-cueL magnitude (descriptive effect) from raw FIR --------------
files <- list.files(file.path(main_dir, "analysis/fmri/spm/fir/ttl2_painpathway"),
                    pattern = "runtype-pain_roi-painpathway_tr-42\\.csv$", recursive = TRUE, full.names = TRUE)
files <- files[!grepl("fir2htw2", files)]
raw <- map_dfr(files, ~ suppressMessages(readr::read_csv(.x, show_col_types = FALSE)))
long <- raw %>%
  mutate(sub = str_extract(sub, "sub-[0-9]+"), roi_flat = str_remove(ROI, "_(L|R)$")) %>%
  pivot_longer(matches("^tr[0-9]+$"), names_to = "tr", values_to = "beta") %>%
  mutate(tr = as.integer(str_remove(tr, "tr")), sec = (tr - 1) * TR)

diff_tc <- function(conds, epoch_label) {
  long %>% filter(condition %in% conds) %>%
    mutate(cue = ifelse(str_detect(condition, "cueH"), "H", "L")) %>%
    group_by(roi_flat, sub, tr, sec, cue) %>% summarise(beta = mean(beta), .groups = "drop") %>%
    group_by(roi_flat, tr, sec, cue) %>% summarise(beta = mean(beta), .groups = "drop") %>%
    pivot_wider(names_from = cue, values_from = beta) %>%
    mutate(diff = H - L, epoch = epoch_label)
}
stim_conds <- unique(long$condition[str_detect(long$condition, "_stim")])
peak <- bind_rows(diff_tc(stim_conds, "stim_epoch_cue"),
                  diff_tc(c("cueH","cueL"), "cue_epoch_cue")) %>%
  group_by(roi_flat, epoch) %>%
  slice_max(abs(diff), n = 1, with_ties = FALSE) %>%
  transmute(ROI = roi_flat, epoch, peak_cueH_minus_cueL = round(diff, 2),
            peak_sec = round(sec, 1),
            direction = ifelse(diff < 0, "cueL>cueH", "cueH>cueL"))

rep <- per %>% left_join(peak, by = c("ROI", "epoch")) %>%
  arrange(epoch, cluster_p)
readr::write_csv(rep, file.path(fir, "cbpt_significant_clusters_report.csv"))

cat("=== significant CBPT clusters (report these; cluster_p only) ===\n")
print(as.data.frame(rep %>% transmute(ROI, epoch = sub("_cue$", "", epoch), window_s,
            cluster_mass, cluster_p, peak_cueH_minus_cueL, direction)), row.names = FALSE)
cat(sprintf("\n%d significant clusters across %d ROIs (all stim epoch, cueL>cueH).\n",
            nrow(rep), dplyr::n_distinct(rep$ROI)))
cat("saved -> ", file.path(fir, "cbpt_significant_clusters_report.csv"), "\n")

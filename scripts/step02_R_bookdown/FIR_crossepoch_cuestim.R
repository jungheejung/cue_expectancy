# ==============================================================================
#   FIR_crossepoch_cuestim.R
#   Does the CUE-epoch cue effect predict the STIM-epoch cue effect?
#
#   Hypothesis (user): a positive anticipatory effect (cueH>cueL in the cue
#   epoch) predicts a reversed stimulus-period effect (cueL>cueH). With both
#   magnitudes signed as (cueH - cueL), that predicts a NEGATIVE relationship.
#
#   Magnitude per subject x ROI x epoch, two definitions (run both):
#     mean : mean (cueH - cueL) over the epoch window
#     peak : (cueH - cueL) at the TR of maximum |group-mean cueH - cueL| in the
#            window  (peak TR fixed from the GROUP curve -> no per-subject
#            selection bias; sign preserved)
#
#   Windows (from each epoch's own FIR onset):
#     CUE_WIN  = 0-6 s  (cue -> expectation rating; pre-stimulus, min SOA 6.3 s)
#     STIM_WIN = 0-15 s (9 s stimulus + HRF tail)
#
#   Per method: (1) per subject x ROI scatter + per-ROI Pearson r (BH-FDR)
#               (2) per ROI group-mean scatter (24 points)
#               (3) LMM stim_mag ~ cue_mag + (1+cue_mag|ROI) + (1|sub)
#               (4) flip test: paired cue vs stim; per-ROI sign tests
#   Outputs -> analysis/mixedeffect_revision/fir/crossepoch/  (suffixed _mean / _peak)
# ==============================================================================

library(plyr); library(dplyr); library(tidyr); library(stringr)
library(ggplot2); library(cueR); library(lmerTest)

main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"
file.sources <- list.files(file.path(main_dir, "scripts/step02_R/utils"),
                           pattern = "*.R", full.names = TRUE, ignore.case = TRUE)
sapply(file.sources, source, .GlobalEnv)

datadir <- file.path(main_dir, "analysis/fmri/spm/fir/ttl2_painpathway")
out_dir <- file.path(main_dir, "analysis", "mixedeffect_revision", "fir", "crossepoch")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

TR_length <- 42; TR_sec <- 0.46; run_type <- "pain"; exclude <- "sub-0001"
CUE_WIN  <- c(0, 6)
STIM_WIN <- c(0, 15)
tr_in_win <- function(win) which(((1:TR_length) - 1) * TR_sec >= win[1] &
                                 ((1:TR_length) - 1) * TR_sec <= win[2])

# ── load FIR data ─────────────────────────────────────────────────────────────
fp <- Sys.glob(file.path(datadir, "sub-*", "sub-*roi-painpathway_tr-42.csv"))
fp <- fp[!str_detect(fp, exclude)]
df <- do.call("rbind.fill", lapply(fp, function(f) read.table(f, header = TRUE, sep = ",")))
roi_labels <- sort(unique(df$ROI))

# per-subject (cueH - cueL) timecourse for one ROI x epoch -> long: sub, tr, diff
diff_tc <- function(roi_label, epoch) {
  if (epoch == "cue") {
    d <- df[df$condition %in% c("cueH","cueL") & df$runtype == run_type & df$ROI == roi_label, ]
    d$cue <- d$condition
  } else {
    d <- df[!(df$condition %in% c("rating","cueH","cueL")) & df$runtype == run_type & df$ROI == roi_label, ]
    d$cue <- ifelse(grepl("^cueH", d$condition), "cueH", "cueL")
  }
  d %>%
    pivot_longer(starts_with("tr"), names_to = "trn", values_to = "v") %>%
    mutate(v = as.numeric(v), tr = as.integer(sub("tr", "", trn))) %>%
    group_by(sub, cue, tr) %>% summarise(v = mean(v, na.rm = TRUE), .groups = "drop") %>%
    pivot_wider(names_from = cue, values_from = v) %>%
    transmute(sub, tr, diff = cueH - cueL)
}

# collapse a diff timecourse to one magnitude per subject, by method
mag_from_tc <- function(tc, win, method) {
  trs <- tr_in_win(win)
  tc  <- tc %>% filter(tr %in% trs)
  if (method == "mean") {
    tc %>% group_by(sub) %>% summarise(mag = mean(diff, na.rm = TRUE), .groups = "drop")
  } else {                                   # peak: group-defined peak TR, signed
    grp     <- tc %>% group_by(tr) %>% summarise(gd = mean(diff, na.rm = TRUE), .groups = "drop")
    peak_tr <- grp$tr[which.max(abs(grp$gd))]
    tc %>% filter(tr == peak_tr) %>% transmute(sub, mag = diff)
  }
}

theme_pub <- theme_classic(base_size = 14, base_family = "Helvetica") +
  theme(axis.text = element_text(color = "black", size = 11),
        axis.line = element_line(linewidth = 0.5, color = "black"),
        strip.text = element_text(face = "bold", size = 12),
        plot.title = element_text(face = "bold", size = 16))

# precompute the diff timecourses once (reused by both methods)
tc_cue  <- setNames(lapply(roi_labels, diff_tc, epoch = "cue"),  roi_labels)
tc_stim <- setNames(lapply(roi_labels, diff_tc, epoch = "stim"), roi_labels)

run_analysis <- function(method) {
  wlab_cue  <- sprintf("%s cueH-cueL, %g-%g s", method, CUE_WIN[1],  CUE_WIN[2])
  wlab_stim <- sprintf("%s cueH-cueL, %g-%g s", method, STIM_WIN[1], STIM_WIN[2])

  mag <- do.call(rbind, lapply(roi_labels, function(r) {
    cm <- mag_from_tc(tc_cue[[r]],  CUE_WIN,  method) %>% rename(cue_mag  = mag)
    sm <- mag_from_tc(tc_stim[[r]], STIM_WIN, method) %>% rename(stim_mag = mag)
    inner_join(cm, sm, by = "sub") %>% mutate(ROI = r)
  })) %>% filter(is.finite(cue_mag), is.finite(stim_mag))
  write.csv(mag, file.path(out_dir, sprintf("crossepoch_subject_magnitudes_%s.csv", method)), row.names = FALSE)

  # (1) per-ROI subject-level correlations
  roi_cor <- mag %>% group_by(ROI) %>%
    summarise(n = n(), r = cor(cue_mag, stim_mag),
              p = cor.test(cue_mag, stim_mag)$p.value, .groups = "drop") %>%
    mutate(fdr_p = p.adjust(p, "BH"), sig = fdr_p < 0.05) %>% arrange(r)
  write.csv(roi_cor, file.path(out_dir, sprintf("crossepoch_perROI_correlations_%s.csv", method)), row.names = FALSE)
  lab_df <- roi_cor %>% mutate(lab = sprintf("r=%.2f%s", r, ifelse(fdr_p < 0.05, "*", "")))

  p1 <- ggplot(mag, aes(cue_mag, stim_mag)) +
    geom_hline(yintercept = 0, linewidth = 0.3, color = "grey70") +
    geom_vline(xintercept = 0, linewidth = 0.3, color = "grey70") +
    geom_point(size = 1, alpha = 0.5, color = "#457b9d") +
    geom_smooth(method = "lm", se = TRUE, color = "#e63946", fill = "#e63946", alpha = 0.15, linewidth = 0.8) +
    geom_text(data = lab_df, aes(x = -Inf, y = Inf, label = lab), hjust = -0.1, vjust = 1.3, size = 4, family = "Helvetica") +
    facet_wrap(~ ROI, scales = "free", ncol = 4) +
    labs(x = wlab_cue, y = wlab_stim,
         title = sprintf("Cue vs stim cue effect, per subject (%s)", method),
         subtitle = "One point = one subject; line = within-ROI fit. * = BH-FDR p<0.05 (Pearson r).") + theme_pub
  ggsave(file.path(out_dir, sprintf("crossepoch_persubject_scatter_%s.png", method)), p1, width = 12, height = 15, dpi = 300, bg = "white")
  ggsave(file.path(out_dir, sprintf("crossepoch_persubject_scatter_%s.svg", method)), p1, width = 12, height = 15, bg = "white")

  # (2) group-level scatter
  roi_mean <- mag %>% group_by(ROI) %>% summarise(cue_mag = mean(cue_mag), stim_mag = mean(stim_mag), .groups = "drop")
  gct <- cor.test(roi_mean$cue_mag, roi_mean$stim_mag)
  p2 <- ggplot(roi_mean, aes(cue_mag, stim_mag)) +
    geom_hline(yintercept = 0, linewidth = 0.3, color = "grey70") +
    geom_vline(xintercept = 0, linewidth = 0.3, color = "grey70") +
    geom_smooth(method = "lm", se = TRUE, color = "#e63946", fill = "#e63946", alpha = 0.15, linewidth = 0.9) +
    geom_point(size = 3, color = "#1d3557") +
    ggrepel::geom_text_repel(aes(label = ROI), size = 3.5, family = "Helvetica", max.overlaps = 30) +
    labs(x = wlab_cue, y = wlab_stim,
         title = sprintf("Cue vs stim cue effect, per ROI group means (%s)", method),
         subtitle = sprintf("Each point = one ROI (N=%d). Pearson r = %.2f, p = %.3f", nrow(roi_mean), gct$estimate, gct$p.value)) + theme_pub
  ggsave(file.path(out_dir, sprintf("crossepoch_grouplevel_scatter_%s.png", method)), p2, width = 8, height = 7, dpi = 300, bg = "white")
  ggsave(file.path(out_dir, sprintf("crossepoch_grouplevel_scatter_%s.svg", method)), p2, width = 8, height = 7, bg = "white")

  # (3) LMM
  m <- tryCatch(lmer(stim_mag ~ cue_mag + (1 + cue_mag | ROI) + (1 | sub), data = mag), error = function(e) NULL)
  if (is.null(m) || isSingular(m)) m <- lmer(stim_mag ~ cue_mag + (1 | ROI) + (1 | sub), data = mag)
  lmm_co <- summary(m)$coefficients

  # (4) flip test
  across_paired <- t.test(roi_mean$cue_mag, roi_mean$stim_mag, paired = TRUE)
  flip_perROI <- mag %>% group_by(ROI) %>%
    summarise(mean_cue = mean(cue_mag), mean_stim = mean(stim_mag),
              p_paired = t.test(cue_mag, stim_mag, paired = TRUE)$p.value,
              p_stim_lt0 = t.test(stim_mag, alternative = "less")$p.value, .groups = "drop") %>%
    mutate(fdr_paired = p.adjust(p_paired, "BH"), fdr_stim_lt0 = p.adjust(p_stim_lt0, "BH"),
           flip = mean_cue > 0 & mean_stim < 0 & fdr_paired < 0.05) %>% arrange(mean_stim)
  write.csv(flip_perROI, file.path(out_dir, sprintf("crossepoch_flip_tests_%s.csv", method)), row.names = FALSE)

  cat(sprintf("\n########## METHOD = %s ##########\n", toupper(method)))
  cat(sprintf("LMM subject-level slope: b=%.3f, p=%.3g\n", lmm_co["cue_mag","Estimate"], lmm_co["cue_mag", ncol(lmm_co)]))
  cat(sprintf("Group-level across 24 ROIs: r=%.2f, p=%.3f\n", gct$estimate, gct$p.value))
  cat(sprintf("Flip (paired cue vs stim across ROIs): t=%.2f p=%.3g | cue_mean=%.2f stim_mean=%.2f\n",
              across_paired$statistic, across_paired$p.value, mean(roi_mean$cue_mag), mean(roi_mean$stim_mag)))
  cat(sprintf("Per-ROI n positive subject-corr (FDR<.05): %d/%d ; n negative (flip) sig: %d/%d\n",
              sum(roi_cor$sig & roi_cor$r > 0), nrow(roi_cor), sum(roi_cor$sig & roi_cor$r < 0), nrow(roi_cor)))
  cat(sprintf("Per-ROI joint flip (cue>0 & stim<0 & paired FDR<.05): %d/%d ; stim<0 FDR<.05: %d/%d\n",
              sum(flip_perROI$flip), nrow(flip_perROI), sum(flip_perROI$fdr_stim_lt0 < 0.05), nrow(flip_perROI)))
  invisible(list(roi_cor = roi_cor, gct = gct, lmm = lmm_co, flip = flip_perROI))
}

res_mean <- run_analysis("mean")
res_peak <- run_analysis("peak")
message("\nDone. Outputs (suffixed _mean / _peak) in: ", out_dir)

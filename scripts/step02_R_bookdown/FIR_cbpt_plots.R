# ==============================================================================
#   FIR_cbpt_plots.R
#   Visualise the CBPT results from FIR_cbpt_painpathway.R:
#     (1) per-ROI cueH-vs-cueL waveforms with a significance bar (both contrasts)
#         -> produced in TWO versions: regular (per hemisphere) and flattened
#            (L/R combined at subject level, full anatomical names).
#     (2) ROI x time signed-t significance heatmap -> FLATTENED (15 regions).
#
#   Sig bars/outlines come from the CBPT (cluster_sig); ribbons/points are display.
#   Requires both cbpt_perTR_Fstats.csv and cbpt_perTR_Fstats_flat.csv
#   (run FIR_cbpt_painpathway.R with and without the "flatten" arg).
# ==============================================================================

library(plyr); library(dplyr); library(tidyr); library(stringr)
library(ggplot2); library(cueR); library(ggpubr)

main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"
file.sources <- list.files(file.path(main_dir, "scripts/step02_R/utils"),
                           pattern = "*.R", full.names = TRUE, ignore.case = TRUE)
sapply(file.sources, source, .GlobalEnv)

datadir   <- file.path(main_dir, "analysis/fmri/spm/fir/ttl2_painpathway")
save_dir  <- file.path(main_dir, "analysis", "mixedeffect_revision", "fir")
TR_length <- 42; TR_sec <- 0.46; run_type <- "pain"; exclude <- "sub-0001"
tr_cols   <- paste0("tr", 1:TR_length)

CUE_COLORS <- c(cueH = "#e63946", cueL = "#457b9d")
CONTRAST_LABELS <- c(cue_epoch_cue  = "Cue epoch (cueH vs cueL)",
                     stim_epoch_cue = "Stim epoch (cueH vs cueL)")

NAME_MAP <- c(
  Amy = "Amygdala", Bstem_PAG = "Periaqueductal gray", Hythal = "Hypothalamus",
  S2 = "Secondary somatosensory ctx", Thal_IL = "Intralaminar thalamus",
  Thal_MD = "Medial dorsal thalamus", Thal_VPLM = "Ventral posterolateral thalamus",
  aIns = "Anterior insula", aMCC_MPFC = "Anterior midcingulate / mPFC",
  dpIns = "Dorsal posterior insula", mIns = "Mid insula", pbn = "Parabrachial nucleus",
  rvm = "Rostral ventral medulla", s1_foot = "Primary somatosensory ctx (foot)",
  s1_handplus = "Primary somatosensory ctx (hand)")
roi_fullname <- function(roi) {
  base <- sub("_(L|R)$", "", roi)
  hemi <- ifelse(grepl("_(L|R)$", roi), sub(".*_(L|R)$", " (\\1)", roi), "")
  paste0(unname(NAME_MAP[base]), hemi)
}

# ── load FIR data (optionally flattened: L/R combined at subject level) ────────
load_df <- function(flatten) {
  fp <- Sys.glob(file.path(datadir, "sub-*", "sub-*roi-painpathway_tr-42.csv"))
  fp <- fp[!str_detect(fp, exclude)]
  d  <- do.call("rbind.fill", lapply(fp, function(f) read.table(f, header = TRUE, sep = ",")))
  if (flatten) {
    d$ROI <- sub("_(L|R)$", "", d$ROI)
    d <- d %>% group_by(sub, ses, run, runtype, condition, ROI) %>%
      summarise(across(all_of(tr_cols), ~ mean(as.numeric(.x), na.rm = TRUE)), .groups = "drop") %>%
      as.data.frame()
  }
  d
}

# group cueH/cueL timecourse (within-subject SEM) for one ROI x epoch
group_cue_tc <- function(df, roi_label, epoch) {
  if (epoch == "cue_epoch_cue") {
    long <- df[df$condition %in% c("cueH","cueL") & df$runtype == run_type & df$ROI == roi_label, ] %>%
      pivot_longer(starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value = as.numeric(tr_value),
             tr_ordered = factor(tr_num, levels = tr_cols),
             cue_ordered = factor(condition, levels = c("cueH","cueL")))
  } else {
    long <- df[!(df$condition %in% c("rating","cueH","cueL")) & df$runtype == run_type & df$ROI == roi_label, ] %>%
      separate(condition, into = c("cue","stim"), sep = "_", remove = FALSE) %>%
      pivot_longer(starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value = as.numeric(tr_value),
             tr_ordered = factor(tr_num, levels = tr_cols),
             cue_ordered = factor(cue, levels = c("cueH","cueL")))
  }
  sw <- meanSummary(long, c("sub","tr_ordered","cue_ordered"), "tr_value")
  sw$mean_per_sub <- as.numeric(sw$mean_per_sub)
  gw <- cueR::summarySEwithin(sw, measurevar = "mean_per_sub",
                              withinvars = c("cue_ordered","tr_ordered"), idvar = "sub")
  gw$tr <- as.integer(sub("tr", "", as.character(gw$tr_ordered)))
  gw$tr_sec <- (gw$tr - 1) * TR_sec
  gw$ROI <- roi_label; gw$contrast <- epoch
  gw
}

build_wave <- function(df) {
  rl <- sort(unique(df$ROI))
  w <- do.call(rbind, lapply(rl, function(r)
    rbind(group_cue_tc(df, r, "cue_epoch_cue"), group_cue_tc(df, r, "stim_epoch_cue"))))
  w$contrast_raw <- w$contrast
  w$contrast <- factor(w$contrast, levels = names(CONTRAST_LABELS), labels = CONTRAST_LABELS)
  w
}

sig_windows_from <- function(perTR) {
  sw <- perTR %>% filter(cluster_sig) %>%
    group_by(ROI, contrast, cluster_id) %>%
    summarise(xmin = min(tr_sec) - TR_sec/2, xmax = max(tr_sec) + TR_sec/2, .groups = "drop")
  sw$contrast <- factor(sw$contrast, levels = names(CONTRAST_LABELS), labels = CONTRAST_LABELS)
  sw
}

x_breaks <- seq(0, (TR_length - 1) * TR_sec, by = 0.46 * 5)

make_wave_panel <- function(wave_df, sig_windows, roi_label, contrast_lab, letter) {
  d  <- wave_df     %>% filter(ROI == roi_label, contrast == contrast_lab)
  sw <- sig_windows %>% filter(ROI == roi_label, contrast == contrast_lab)
  yr    <- range(c(d$mean_per_sub_norm_mean - d$se, d$mean_per_sub_norm_mean + d$se), na.rm = TRUE)
  bar_h <- diff(yr) * 0.05; ybar <- yr[1] - bar_h * 1.5
  ggplot(d, aes(tr_sec, mean_per_sub_norm_mean, color = cue_ordered, fill = cue_ordered)) +
    { if (nrow(sw) > 0) geom_rect(data = sw, inherit.aes = FALSE,
        aes(xmin = xmin, xmax = xmax, ymin = ybar - bar_h, ymax = ybar), fill = "grey20", alpha = 0.85) } +
    geom_line(linewidth = 0.7, alpha = 0.9) +
    geom_pointrange(aes(ymin = mean_per_sub_norm_mean - se, ymax = mean_per_sub_norm_mean + se),
                    size = 0.45, fatten = 2.8, linewidth = 0.6) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60", linewidth = 0.4) +
    scale_color_manual(values = CUE_COLORS) + scale_fill_manual(values = CUE_COLORS) +
    scale_x_continuous(breaks = x_breaks, labels = round(x_breaks, 1)) +
    labs(title = paste0(letter, "  ", contrast_lab), x = "Time (s)", y = "BOLD (A.U.)", color = "Cue", fill = "Cue") +
    theme_classic(base_size = 15, base_family = "Helvetica") +
    theme(aspect.ratio = 1.05, legend.position = "right",
          plot.title = element_text(face = "bold", size = 17),
          axis.title = element_text(size = 15), axis.text = element_text(size = 13, color = "black"),
          axis.text.x = element_text(angle = 30, hjust = 1, size = 13),
          axis.ticks = element_line(linewidth = 0.5, color = "black"),
          axis.line = element_line(linewidth = 0.5, color = "black"),
          legend.title = element_text(size = 15), legend.text = element_text(size = 14))
}

gen_waveforms <- function(wave_df, sig_windows, roi_labels, wave_dir) {
  dir.create(wave_dir, showWarnings = FALSE, recursive = TRUE)
  for (roi_label in roi_labels) {
    p_cue  <- make_wave_panel(wave_df, sig_windows, roi_label, CONTRAST_LABELS["cue_epoch_cue"],  "A")
    p_stim <- make_wave_panel(wave_df, sig_windows, roi_label, CONTRAST_LABELS["stim_epoch_cue"], "B")
    fig <- ggpubr::ggarrange(p_cue, p_stim, ncol = 1, nrow = 2, common.legend = TRUE, legend = "right", align = "v")
    fig <- ggpubr::annotate_figure(fig, top = ggpubr::text_grob(
      sprintf("%s  |  pain  |  cueH vs cueL", roi_fullname(roi_label)), face = "bold", size = 16, family = "Helvetica"))
    ggsave(file.path(wave_dir, sprintf("roi-%s_cbpt_waveform.png", roi_label)), fig, width = 5.2, height = 9.6, dpi = 300, bg = "white")
    ggsave(file.path(wave_dir, sprintf("roi-%s_cbpt_waveform.svg", roi_label)), fig, width = 5.2, height = 9.6, bg = "white")
  }
  message(sprintf("Saved %d waveform figures to %s", length(roi_labels), wave_dir))
}

# pass "heatmap-only" to skip regenerating the 39 waveform figures
SKIP_WAVE <- "heatmap-only" %in% commandArgs(trailingOnly = TRUE)

# ── (1) WAVEFORMS — regular (per hemisphere) and flattened ───────────────────
if (!SKIP_WAVE) {
  df_reg  <- load_df(FALSE)
  per_reg <- read.csv(file.path(save_dir, "cbpt_perTR_Fstats.csv"), stringsAsFactors = FALSE)
  gen_waveforms(build_wave(df_reg), sig_windows_from(per_reg), sort(unique(df_reg$ROI)),
                file.path(save_dir, "waveforms"))
}

df_flat  <- load_df(TRUE)
per_flat <- read.csv(file.path(save_dir, "cbpt_perTR_Fstats_flat.csv"), stringsAsFactors = FALSE)
wave_flat <- build_wave(df_flat)
if (!SKIP_WAVE)
  gen_waveforms(wave_flat, sig_windows_from(per_flat), sort(unique(df_flat$ROI)),
                file.path(save_dir, "waveforms_flat"))

# ── (2) FLATTENED SIGNED-t HEATMAP ───────────────────────────────────────────
dir_df <- wave_flat %>%
  select(ROI, contrast_raw, tr, cue_ordered, mean_per_sub_norm_mean) %>%
  tidyr::pivot_wider(names_from = cue_ordered, values_from = mean_per_sub_norm_mean) %>%
  mutate(dir = sign(cueH - cueL)) %>% select(ROI, contrast = contrast_raw, tr, dir)

roi_order <- per_flat %>% filter(contrast == "stim_epoch_cue") %>%
  group_by(ROI) %>% summarise(n_sig = sum(cluster_sig), .groups = "drop") %>%
  arrange(n_sig) %>% pull(ROI)

hm <- per_flat %>% left_join(dir_df, by = c("ROI","contrast","tr")) %>%
  mutate(signed_t = dir * sqrt(F_obs))
hm$ROI      <- factor(hm$ROI, levels = roi_order, labels = roi_fullname(roi_order))
hm$contrast <- factor(hm$contrast, levels = names(CONTRAST_LABELS), labels = CONTRAST_LABELS)
tlim <- max(abs(hm$signed_t), na.rm = TRUE)

# one connected box per contiguous significant cluster (not per cell)
sig_box <- hm %>% filter(cluster_sig) %>%
  group_by(ROI, contrast, cluster_id) %>%
  summarise(xmin = min(tr_sec) - TR_sec/2, xmax = max(tr_sec) + TR_sec/2, .groups = "drop") %>%
  mutate(ymin = as.integer(ROI) - 0.5, ymax = as.integer(ROI) + 0.5)

p_hm <- ggplot(hm, aes(tr_sec, ROI)) +
  geom_tile(aes(fill = signed_t), color = "white", linewidth = 0.1) +
  geom_rect(data = sig_box, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = NA, color = "black", linewidth = 0.7) +
  scale_fill_gradient2(low = "#2166ac", mid = "#f7f7f7", high = "#b2182b",
                       midpoint = 0, limits = c(-tlim, tlim), name = "t\n(cueH - cueL)") +
  facet_wrap(~ contrast) +
  labs(x = "Time (s)", y = NULL,
       title = "Per-TR cue effect (signed t) with CBPT-significant timepoints outlined",
       subtitle = "L/R combined at subject level; black outline = cluster-significant (subject-wise CBPT, p<0.05)") +
  theme_minimal(base_size = 14, base_family = "Helvetica") +
  theme(panel.grid = element_blank(), strip.text = element_text(face = "bold", size = 15),
        plot.title = element_text(face = "bold", size = 16), plot.subtitle = element_text(size = 12),
        axis.title = element_text(size = 14), axis.text.x = element_text(size = 12, color = "black"),
        axis.text.y = element_text(size = 12, color = "black"),
        legend.title = element_text(size = 14), legend.text = element_text(size = 12))
ggsave(file.path(save_dir, "cbpt_significance_heatmap_flat.png"), p_hm, width = 12, height = 6, dpi = 300, bg = "white")
ggsave(file.path(save_dir, "cbpt_significance_heatmap_flat.svg"), p_hm, width = 12, height = 6, bg = "white")
message("Saved flattened heatmap.")

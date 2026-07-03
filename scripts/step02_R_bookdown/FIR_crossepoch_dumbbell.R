# ==============================================================================
#   FIR_crossepoch_dumbbell.R
#   Cleaner sign-flip figure: hemispheres combined at the SUBJECT level, full
#   anatomical names, regions as rows (dumbbell). A flip = arrow crossing 0.
#   Magnitude = peak (cueH-cueL) at the group-defined peak TR within each window.
# ==============================================================================
library(plyr); library(dplyr); library(tidyr); library(stringr); library(ggplot2)

main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"
datadir  <- file.path(main_dir, "analysis/fmri/spm/fir/ttl2_painpathway")
out_dir  <- file.path(main_dir, "analysis", "mixedeffect_revision", "fir", "crossepoch")
TR_length <- 42; TR_sec <- 0.46; run_type <- "pain"; exclude <- "sub-0001"
CUE_WIN <- c(0, 6); STIM_WIN <- c(0, 15)
tr_in_win <- function(w) which(((1:TR_length) - 1) * TR_sec >= w[1] & ((1:TR_length) - 1) * TR_sec <= w[2])

NAME_MAP <- c(
  Amy = "Amygdala", Bstem_PAG = "Periaqueductal gray", Hythal = "Hypothalamus",
  S2 = "Secondary somatosensory ctx", Thal_IL = "Intralaminar thalamus",
  Thal_MD = "Medial dorsal thalamus", Thal_VPLM = "Ventral posterolateral thalamus",
  aIns = "Anterior insula", aMCC_MPFC = "Anterior midcingulate / mPFC",
  dpIns = "Dorsal posterior insula", mIns = "Mid insula", pbn = "Parabrachial nucleus",
  rvm = "Rostral ventral medulla", s1_foot = "Primary somatosensory ctx (foot)",
  s1_handplus = "Primary somatosensory ctx (hand)")

# ── load + flatten L/R -> base region -> full name ───────────────────────────
fp <- Sys.glob(file.path(datadir, "sub-*", "sub-*roi-painpathway_tr-42.csv"))
fp <- fp[!str_detect(fp, exclude)]
df <- do.call("rbind.fill", lapply(fp, function(f) read.table(f, header = TRUE, sep = ",")))
df$base   <- sub("_(L|R)$", "", df$ROI)
df$region <- unname(NAME_MAP[df$base])
stopifnot(!any(is.na(df$region)))
regions <- sort(unique(df$region))

# per-subject (cueH-cueL) timecourse for a region x epoch; L+R+runs averaged per subject
diff_tc <- function(region, epoch) {
  if (epoch == "cue") {
    d <- df[df$condition %in% c("cueH","cueL") & df$runtype == run_type & df$region == region, ]; d$cue <- d$condition
  } else {
    d <- df[!(df$condition %in% c("rating","cueH","cueL")) & df$runtype == run_type & df$region == region, ]
    d$cue <- ifelse(grepl("^cueH", d$condition), "cueH", "cueL")
  }
  d %>% pivot_longer(starts_with("tr"), names_to = "trn", values_to = "v") %>%
    mutate(v = as.numeric(v), tr = as.integer(sub("tr", "", trn))) %>%
    group_by(sub, cue, tr) %>% summarise(v = mean(v, na.rm = TRUE), .groups = "drop") %>%  # combines L/R
    pivot_wider(names_from = cue, values_from = v) %>% transmute(sub, tr, diff = cueH - cueL)
}
peak_mag <- function(tc, win) {
  tc <- tc %>% filter(tr %in% tr_in_win(win))
  grp <- tc %>% group_by(tr) %>% summarise(gd = mean(diff, na.rm = TRUE), .groups = "drop")
  pk <- grp$tr[which.max(abs(grp$gd))]
  tc %>% filter(tr == pk) %>% transmute(sub, mag = diff)
}

mag <- do.call(rbind, lapply(regions, function(r) {
  cm <- peak_mag(diff_tc(r, "cue"),  CUE_WIN)  %>% rename(cue_mag  = mag)
  sm <- peak_mag(diff_tc(r, "stim"), STIM_WIN) %>% rename(stim_mag = mag)
  inner_join(cm, sm, by = "sub") %>% mutate(region = r)
})) %>% filter(is.finite(cue_mag), is.finite(stim_mag))
write.csv(mag, file.path(out_dir, "crossepoch_subject_magnitudes_flat_peak.csv"), row.names = FALSE)

roi <- mag %>% group_by(region) %>%
  summarise(cue_mag = mean(cue_mag), stim_mag = mean(stim_mag),
            p_paired = tryCatch(t.test(cue_mag, stim_mag, paired = TRUE)$p.value,
                                error = function(e) NA_real_), .groups = "drop") %>%
  mutate(fdr = p.adjust(p_paired, "BH"), flip = cue_mag > 0 & stim_mag < 0)
write.csv(roi, file.path(out_dir, "crossepoch_flip_flat_peak.csv"), row.names = FALSE)

ord  <- as.character(roi$region)[order(roi$cue_mag)]
long <- roi %>% select(region, cue_mag, stim_mag) %>%
  pivot_longer(c(cue_mag, stim_mag), names_to = "epoch", values_to = "mag") %>%
  mutate(epoch = factor(epoch, levels = c("cue_mag","stim_mag"),
                        labels = c("Cue epoch (0-6 s)","Stim epoch (0-15 s)")),
         region = factor(region, levels = ord))
roi$region <- factor(roi$region, levels = ord)

# ── dumbbell ─────────────────────────────────────────────────────────────────
g <- ggplot() +
  annotate("rect", xmin = 0, xmax = Inf, ymin = -Inf, ymax = Inf, fill = "#c1121f", alpha = 0.05) +
  annotate("rect", xmin = -Inf, xmax = 0, ymin = -Inf, ymax = Inf, fill = "#457b9d", alpha = 0.05) +
  geom_vline(xintercept = 0, linewidth = 0.5, color = "grey40") +
  geom_segment(data = roi, aes(x = cue_mag, xend = stim_mag, y = region, yend = region),
               color = "grey55", linewidth = 0.7,
               arrow = arrow(length = unit(0.10, "inches"), type = "closed")) +
  geom_point(data = long, aes(mag, region, color = epoch), size = 3.4) +
  scale_color_manual(values = c("Cue epoch (0-6 s)" = "#c1121f", "Stim epoch (0-15 s)" = "#457b9d"), name = NULL) +
  annotate("text", x = Inf, y = Inf, label = "cueH > cueL", color = "#c1121f", hjust = 1.05, vjust = 1.5, size = 4.2) +
  annotate("text", x = -Inf, y = Inf, label = "cueL > cueH", color = "#457b9d", hjust = -0.05, vjust = 1.5, size = 4.2) +
  labs(x = "Cue effect  (cueH - cueL)", y = NULL,
       title = "Anticipatory -> stimulus cue effect, per region",
       subtitle = sprintf("L/R combined at subject level; peak magnitude. Arrow = cue->stim; crossing 0 = sign flip. %d/%d flip.",
                          sum(roi$flip), nrow(roi))) +
  theme_classic(base_size = 15, base_family = "Helvetica") +
  theme(axis.text = element_text(color = "black", size = 12),
        axis.line = element_line(linewidth = 0.5, color = "black"),
        legend.position = "top", plot.title = element_text(face = "bold", size = 16))

ggsave(file.path(out_dir, "crossepoch_dumbbell_flat_peak.png"), g, width = 9, height = 6.5, dpi = 300, bg = "white")
ggsave(file.path(out_dir, "crossepoch_dumbbell_flat_peak.svg"), g, width = 9, height = 6.5, bg = "white")
cat(sprintf("Regions=%d  flip=%d/%d  saved dumbbell to %s\n", nrow(roi), sum(roi$flip), nrow(roi), out_dir))

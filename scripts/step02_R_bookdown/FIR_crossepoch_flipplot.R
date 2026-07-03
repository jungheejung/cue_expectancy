# ==============================================================================
#   FIR_crossepoch_flipplot.R
#   Re-plot the cross-epoch relationship with BOTH axes on the same convention
#   (cueH - cueL), directional axis labels, and the "flip" quadrant shaded.
#   Uses the peak magnitudes written by FIR_crossepoch_cuestim.R.
# ==============================================================================
library(dplyr); library(ggplot2)

out_dir <- "/Users/h/Documents/projects_local/cue_expectancy/analysis/mixedeffect_revision/fir/crossepoch"

for (method in c("peak", "mean")) {
  mag <- read.csv(file.path(out_dir, sprintf("crossepoch_subject_magnitudes_%s.csv", method)))
  roi <- mag %>% group_by(ROI) %>%
    summarise(cue_mag = mean(cue_mag), stim_mag = mean(stim_mag), .groups = "drop")
  ct  <- cor.test(roi$cue_mag, roi$stim_mag)

  xlab <- "Cue-epoch effect  (cueH - cueL)\n<-- cueL>cueH        cueH>cueL -->"
  ylab <- "Stim-epoch effect  (cueH - cueL)\n<-- cueL>cueH        cueH>cueL -->"
  roi <- roi %>% mutate(cue_sign = ifelse(cue_mag >= 0, "cueH > cueL (+)", "cueL > cueH (-)"))
  SIGN_COLORS <- c("cueH > cueL (+)" = "#c1121f", "cueL > cueH (-)" = "#457b9d")
  theme_pub <- theme_classic(base_size = 15, base_family = "Helvetica") +
    theme(axis.text = element_text(color = "black", size = 12),
          axis.line = element_line(linewidth = 0.5, color = "black"),
          legend.position = c(0.02, 0.02), legend.justification = c(0, 0),
          legend.background = element_rect(fill = "white", color = "grey80"),
          plot.title = element_text(face = "bold", size = 16))

  # ── group level: cue effect (x) vs stim effect (y) ──────────────────────────
  g <- ggplot(roi, aes(cue_mag, stim_mag)) +
    annotate("rect", xmin = 0, xmax = Inf, ymin = -Inf, ymax = 0,
             fill = "#e63946", alpha = 0.07) +                       # flip quadrant (cue+, stim-)
    annotate("text", x = Inf, y = -Inf, label = "flip quadrant\ncueH>cueL (cue) -> cueL>cueH (stim)",
             hjust = 1.03, vjust = -0.6, size = 3.4, color = "#a32d2d", family = "Helvetica") +
    geom_hline(yintercept = 0, linewidth = 0.4, color = "grey50") +
    geom_vline(xintercept = 0, linewidth = 0.4, color = "grey50") +
    geom_smooth(method = "lm", se = TRUE, color = "#1d3557", fill = "#1d3557",
                alpha = 0.12, linewidth = 0.9) +
    geom_point(aes(color = cue_sign), size = 3) +
    scale_color_manual(values = SIGN_COLORS, name = "Cue-epoch sign") +
    ggrepel::geom_text_repel(aes(label = ROI), size = 3.4, family = "Helvetica", max.overlaps = 30) +
    labs(x = xlab, y = ylab,
         title = sprintf("Cue (x) vs stim (y) cue effect per ROI (%s)", method),
         subtitle = sprintf("Both axes cueH - cueL. Pearson r = %.2f, p = %.3f (N=%d ROIs)",
                            ct$estimate, ct$p.value, nrow(roi))) +
    theme_pub
  ggsave(file.path(out_dir, sprintf("crossepoch_grouplevel_flipquadrant_%s.png", method)),
         g, width = 8, height = 7.2, dpi = 300, bg = "white")
  ggsave(file.path(out_dir, sprintf("crossepoch_grouplevel_flipquadrant_%s.svg", method)),
         g, width = 8, height = 7.2, bg = "white")

  # ── slopegraph: sign flip per ROI (cue -> stim), a flip = line crossing 0 ────
  roi <- roi %>% mutate(flip = cue_mag > 0 & stim_mag < 0)
  long <- roi %>% select(ROI, cue_mag, stim_mag, flip) %>%
    tidyr::pivot_longer(c(cue_mag, stim_mag), names_to = "epoch", values_to = "mag") %>%
    mutate(epoch = factor(epoch, levels = c("cue_mag", "stim_mag"),
                          labels = c("Cue epoch\n(0-6 s)", "Stim epoch\n(0-15 s)")))
  meanl <- long %>% group_by(epoch) %>% summarise(mag = mean(mag), .groups = "drop")

  sg <- ggplot(long, aes(epoch, mag, group = ROI)) +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = 0, ymax = Inf, fill = "#c1121f", alpha = 0.05) +
    annotate("rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 0, fill = "#457b9d", alpha = 0.05) +
    geom_hline(yintercept = 0, linewidth = 0.6, color = "grey40") +
    geom_line(aes(color = flip), linewidth = 0.7, alpha = 0.65) +
    geom_point(aes(color = flip), size = 2.2) +
    geom_line(data = meanl, aes(group = 1), color = "black", linewidth = 1.8) +
    geom_point(data = meanl, aes(group = 1), color = "black", size = 3.6) +
    ggrepel::geom_text_repel(data = subset(long, grepl("Stim", epoch)),
                             aes(label = ROI, color = flip), size = 2.9, family = "Helvetica",
                             direction = "y", nudge_x = 0.15, hjust = 0, segment.size = 0.2, max.overlaps = 30) +
    annotate("text", x = 2.45, y = Inf, label = "cueH > cueL", color = "#c1121f", vjust = 1.6, hjust = 1, size = 4.2) +
    annotate("text", x = 2.45, y = -Inf, label = "cueL > cueH", color = "#457b9d", vjust = -1.1, hjust = 1, size = 4.2) +
    scale_color_manual(values = c(`TRUE` = "#c1121f", `FALSE` = "#8d99ae"),
                       labels = c(`TRUE` = "sign flip", `FALSE` = "no flip"), name = NULL) +
    scale_x_discrete(expand = expansion(mult = c(0.25, 0.55))) +
    labs(x = NULL, y = "Cue effect  (cueH - cueL)",
         title = sprintf("Sign flip per ROI: cue -> stim (%s)", method),
         subtitle = sprintf("Group mean %.1f -> %.1f (black). %d/%d ROIs flip (line crosses 0).",
                            meanl$mag[1], meanl$mag[2], sum(roi$flip), nrow(roi))) +
    theme_pub + theme(legend.position = "top")
  ggsave(file.path(out_dir, sprintf("crossepoch_slopegraph_%s.png", method)), sg, width = 8, height = 7.5, dpi = 300, bg = "white")
  ggsave(file.path(out_dir, sprintf("crossepoch_slopegraph_%s.svg", method)), sg, width = 8, height = 7.5, bg = "white")

  cat(sprintf("%s: group-level r=%.2f p=%.3f | cue_mean=%.2f stim_mean=%.2f | ROIs in flip quadrant (cue>0 & stim<0)=%d/%d\n",
              method, ct$estimate, ct$p.value, mean(roi$cue_mag), mean(roi$stim_mag),
              sum(roi$cue_mag > 0 & roi$stim_mag < 0), nrow(roi)))
}
message("Saved flip-quadrant scatters to ", out_dir)

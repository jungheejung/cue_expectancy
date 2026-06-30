---
  title: "book_FIR_iv-cue_dv-painpathway.Rmd"
author: "Heejung Jung"
date: "`r Sys.Date()`"
output: html_document
---
  
# ==============================================================================
#   Libraries
# ==============================================================================
library(car)
library(psych)
library(reshape)
library(plyr)
library(dplyr)
library(tidyselect)
library(tidyr)
library(stringr)
library(lmerTest)
library(ggplot2)
library(gghalves)
library(ggpubr)
library(plotly)
library(FactoMineR)
library(grid)
library(gridExtra)
library(cueR)

main_dir <- dirname(dirname(getwd()))
file.sources <- list.files(
  file.path(main_dir, "scripts/step02_R/utils"),
  pattern    = "*.R",
  full.names = TRUE,
  ignore.case = TRUE
)
sapply(file.sources, source, .GlobalEnv)


# ==============================================================================
#   Parameters
# ==============================================================================

main_dir  <- "/Users/h/Documents/projects_local/cue_expectancy"
datadir   <- file.path(main_dir, "analysis/fmri/spm/fir/ttl2_painpathway")

analysis_dir <- file.path(
  main_dir, "analysis", "mixedeffect",
  "book_fir_iv-6cond_dv-firglasserSPM_ttl2",
  as.character(Sys.Date())
)
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)
save_dir <- analysis_dir

TR_length  <- 42
roi_list   <- c("painpathway")
run_types  <- c("pain")
exclude    <- "sub-0001"

# Color palettes
STIM_COLORS <- c(
  "stimH" = "#5f0f40",
  "stimM" = "#ae2012",
  "stimL" = "#fcbf49"
)

CUE_COLORS <- c(
  "cueH" = "#e63946",
  "cueL" = "#457b9d"
)

SIXCOND_COLORS <- c(
  "cueH_stimH" = "red",
  "cueL_stimH" = "#5f0f40",
  "cueH_stimM" = "#bc3908",
  "cueL_stimM" = "#f6aa1c",
  "cueH_stimL" = "#2541b2",
  "cueL_stimL" = "#00a6fb"
)

calculate_point_size <- function(figure_width, figure_height, point_size_base = 5) {
  scaling_factor <- min(figure_width, figure_height) / point_size_base
  return(scaling_factor)
}
AXIS_FONTSIZE       <- 10
COMMONAXIS_FONTSIZE <- 13
TITLE_FONTSIZE      <- 14
GEOMPOINT_SIZE      <- 0.8 #calculate_point_size(figure_width = 10, figure_height = 10)
PANEL_OVERHEAD <- 0.5
ASPECT_RATIO  <- 1.2    # panel height = width * aspect ratio
PANEL_WIDTH   <- 10     # ggsave width in inches
N_PANELS      <- 4      # number of stacked plots

# -------------------
# wide 4 x 1 column
# --------------------
PANEL_WIDTH    <- 8      # figure width in inches
FIGURE_HEIGHT  <- PANEL_WIDTH * (6/4)   # = 12 inches  (6:4 ratio)
ASPECT_RATIO   <- (FIGURE_HEIGHT / N_PANELS) / PANEL_WIDTH  # = 12/4/8 = 0.375
PANEL_OVERHEAD <- 0.3    # small overhead for titles/margins
N_PANELS       <- 4


# -------------------
# narrow 1 x 4 column
# --------------------
PANEL_WIDTH    <- 4
FIGURE_HEIGHT  <- 16
N_PANELS       <- 4
ASPECT_RATIO   <- (FIGURE_HEIGHT / N_PANELS) / PANEL_WIDTH  # = (16/4)/6 = 0.667
PANEL_OVERHEAD <- 0.3
figure_height  <- (PANEL_WIDTH * ASPECT_RATIO + PANEL_OVERHEAD) * N_PANELS
message(sprintf("Figure dimensions: %.1f x %.1f inches", PANEL_WIDTH, figure_height))
figure_height <- (PANEL_WIDTH * ASPECT_RATIO + PANEL_OVERHEAD) * N_PANELS


# ==============================================================================
#   Helper functions
# ==============================================================================

# Convert tr_ordered factor to seconds and sort
add_tr_sequence <- function(gw) {
  tr_numbers     <- as.numeric(sub("tr", "", as.character(gw$tr_ordered)))
  gw$tr_sequence <- (tr_numbers - 1) * 0.46
  gw[order(gw$tr_ordered), ]
}

# Compute x-axis breaks every 5 TRs
make_breaks <- function(gw) {
  seq(0, max(gw$tr_sequence), by = 0.46 * 5)
}

# Shared theme for all four panels
panel_theme <- function(p) {
  p +
    theme_classic() +
    theme(
      aspect.ratio  = ASPECT_RATIO,
      axis.title.x  = element_text(size = AXIS_FONTSIZE),  # ← was element_blank()
      axis.title.y  = element_text(size = AXIS_FONTSIZE), 
      # axis.title.x  = element_blank(),  # added once at bottom via p4
      # axis.title.y  = element_blank(),  # added once on left via y_label grob
      axis.text.x   = element_text(size = AXIS_FONTSIZE, angle = 30, hjust = 1),
      axis.text.y   = element_text(size = AXIS_FONTSIZE),
      legend.position = "right",
      legend.text   = element_text(size = AXIS_FONTSIZE),
      plot.title    = element_text(size = TITLE_FONTSIZE, face = "bold"),
      plot.margin   = margin(5, 5, 5, 5)
    )
}


# ==============================================================================
#   Main loop: load data, compute summaries, plot 4 effects per ROI
# ==============================================================================

# =======
# Per ROI
# =======

for (roi_file in roi_list) {
  
  # ----------------------------------------------------------------------------
  #   Load data
  # ----------------------------------------------------------------------------
  common_path <- Sys.glob(
    file.path(datadir, "sub-*", paste0("sub-*", "*roi-", roi_file, "_tr-42.csv"))
  )
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]
  
  df <- do.call("rbind.fill", lapply(filter_path, FUN = function(f) {
    read.table(f, header = TRUE, sep = ",")
  }))
  
  # get the unique ROI labels from the ROI column
  roi_labels <- sort(unique(df$ROI))
  message(sprintf("Found %d ROIs: %s", length(roi_labels), paste(roi_labels, collapse = ", ")))
  
  for (run_type in run_types) {
    for (roi_label in roi_labels) {
      
      message(sprintf("Processing ROI: %s | task: %s", roi_label, run_type))
      
      # ------------------------------------------------------------------------
      #   PLOT 1 — Main effect of CUE during cue epoch
      # ------------------------------------------------------------------------
      cue_long <- df[df$condition %in% c("cueH", "cueL") &
                       df$runtype == run_type &
                       df$ROI == roi_label, ] %>%
        pivot_longer(cols      = starts_with("tr"),
                     names_to  = "tr_num",
                     values_to = "tr_value") %>%
        mutate(
          tr_value    = as.numeric(tr_value),
          tr_ordered  = factor(tr_num, levels = paste0("tr", 1:TR_length)),
          cue_ordered = factor(condition, levels = c("cueH", "cueL"))
        )
      
      sw_cue <- meanSummary(cue_long,
                            c("sub", "tr_ordered", "cue_ordered"),
                            "tr_value")
      sw_cue$mean_per_sub <- as.numeric(sw_cue$mean_per_sub)
      
      gw_cue <- cueR::summarySEwithin(
        data       = sw_cue,
        measurevar = "mean_per_sub",
        withinvars = c("cue_ordered", "tr_ordered"),
        idvar      = "sub"
      ) %>% add_tr_sequence()
      
      p1 <- panel_theme(plot_timeseries_bar(
        gw_cue,
        iv1            = "tr_sequence",
        iv2            = "cue_ordered",
        mean           = "mean_per_sub_norm_mean",
        error          = "se",
        xlab           = "Time (s)",
        ylab           = paste0("BOLD (A.U.)"),
        ggtitle        = paste0("A  Cue epoch — Main effect of cue",
                                "  (N=", length(unique(sw_cue$sub)), ")"),
        color_mapping  = CUE_COLORS,
        show_legend    = TRUE,
        geompoint_size = GEOMPOINT_SIZE
      )) +
        scale_x_continuous(breaks = make_breaks(gw_cue),
                           labels = round(make_breaks(gw_cue), 2),
                           limits = range(gw_cue$tr_sequence))
      
      # ------------------------------------------------------------------------
      #   Shared stim epoch data prep for plots 2, 3, 4
      # ------------------------------------------------------------------------
      stim_long <- df[!(df$condition %in% c("rating", "cueH", "cueL")) &
                        df$runtype == run_type &
                        df$ROI == roi_label, ] %>%
        separate(condition,
                 into   = c("cue", "stim"),
                 sep    = "_",
                 remove = FALSE) %>%
        pivot_longer(cols      = starts_with("tr"),
                     names_to  = "tr_num",
                     values_to = "tr_value") %>%
        mutate(
          tr_value     = as.numeric(tr_value),
          tr_ordered   = factor(tr_num,      levels = paste0("tr", 1:TR_length)),
          cue_ordered  = factor(cue,         levels = c("cueH", "cueL")),
          stim_ordered = factor(stim,        levels = c("stimH", "stimM", "stimL")),
          sixcond      = factor(condition,   levels = names(SIXCOND_COLORS))
        )
      
      # ------------------------------------------------------------------------
      #   PLOT 2 — Main effect of STIM during stim epoch (collapsed across cue)
      # ------------------------------------------------------------------------
      sw_stim <- meanSummary(stim_long,
                             c("sub", "tr_ordered", "stim_ordered"),
                             "tr_value")
      sw_stim$mean_per_sub <- as.numeric(sw_stim$mean_per_sub)
      
      gw_stim <- cueR::summarySEwithin(
        data       = sw_stim,
        measurevar = "mean_per_sub",
        withinvars = c("stim_ordered", "tr_ordered"),
        idvar      = "sub"
      ) %>% add_tr_sequence()
      
      p2 <- panel_theme(plot_timeseries_bar(
        gw_stim,
        iv1            = "tr_sequence",
        iv2            = "stim_ordered",
        mean           = "mean_per_sub_norm_mean",
        error          = "se",
        xlab           = "Time (s)",
        ylab           = paste0("BOLD (A.U.)"),
        ggtitle        = paste0("B  Stim epoch — Main effect of stim",
                                "  (N=", length(unique(sw_stim$sub)), ")"),
        color_mapping  = STIM_COLORS,
        show_legend    = TRUE,
        geompoint_size = GEOMPOINT_SIZE
      )) +
        scale_x_continuous(breaks = make_breaks(gw_stim),
                           labels = round(make_breaks(gw_stim), 2),
                           limits = range(gw_stim$tr_sequence))
      
      # ------------------------------------------------------------------------
      #   PLOT 3 — Main effect of CUE during stim epoch (collapsed across stim)
      # ------------------------------------------------------------------------
      sw_cue_stim <- meanSummary(stim_long,
                                 c("sub", "tr_ordered", "cue_ordered"),
                                 "tr_value")
      sw_cue_stim$mean_per_sub <- as.numeric(sw_cue_stim$mean_per_sub)
      
      gw_cue_stim <- cueR::summarySEwithin(
        data       = sw_cue_stim,
        measurevar = "mean_per_sub",
        withinvars = c("cue_ordered", "tr_ordered"),
        idvar      = "sub"
      ) %>% add_tr_sequence()
      
      p3 <- panel_theme(plot_timeseries_bar(
        gw_cue_stim,
        iv1            = "tr_sequence",
        iv2            = "cue_ordered",
        mean           = "mean_per_sub_norm_mean",
        error          = "se",
        xlab           = "Time (s)",
        ylab           = paste0("BOLD (A.U.)"),
        ggtitle        = paste0("C  Stim epoch — Main effect of cue",
                                "  (N=", length(unique(sw_cue_stim$sub)), ")"),
        color_mapping  = CUE_COLORS,
        show_legend    = TRUE,
        geompoint_size = GEOMPOINT_SIZE
      )) +
        scale_x_continuous(breaks = make_breaks(gw_cue_stim),
                           labels = round(make_breaks(gw_cue_stim), 2),
                           limits = range(gw_cue_stim$tr_sequence))
      
      # ------------------------------------------------------------------------
      #   PLOT 4 — Cue x Stim interaction during stim epoch (all 6 conditions)
      # ------------------------------------------------------------------------
      sw_6cond <- meanSummary(stim_long,
                              c("sub", "tr_ordered", "sixcond"),
                              "tr_value")
      sw_6cond$mean_per_sub <- as.numeric(sw_6cond$mean_per_sub)
      
      gw_6cond <- cueR::summarySEwithin(
        data       = sw_6cond,
        measurevar = "mean_per_sub",
        withinvars = c("sixcond", "tr_ordered"),
        idvar      = "sub"
      ) %>% add_tr_sequence()
      
      p4 <- panel_theme(plot_timeseries_bar(
        gw_6cond,
        iv1            = "tr_sequence",
        iv2            = "sixcond",
        mean           = "mean_per_sub_norm_mean",
        error          = "se",
        xlab           = "Time (s)",
        ylab           = paste0("BOLD (A.U.)"),
        ggtitle        = paste0("D  Stim epoch — Cue x Stim interaction",
                                "  (N=", length(unique(sw_6cond$sub)), ")"),
        color_mapping  = SIXCOND_COLORS,
        show_legend    = TRUE,
        geompoint_size = GEOMPOINT_SIZE
      )) +
        scale_x_continuous(breaks = make_breaks(gw_6cond),
                           labels = round(make_breaks(gw_6cond), 2),
                           limits = range(gw_6cond$tr_sequence)) #+
      # theme(axis.title.x = element_text(size = COMMONAXIS_FONTSIZE))  # bottom panel only
      
      # ------------------------------------------------------------------------
      #   Assemble: single column, 4 rows, shared y-axis label
      # ------------------------------------------------------------------------
      final_plot <- grid.arrange(
        textGrob(
          paste0(roi_label, "  FIR BOLD activation (A.U.)"),
          rot = 90,
          gp  = gpar(fontsize = COMMONAXIS_FONTSIZE)
        ),
        ggpubr::ggarrange(p1, p2, p3, p4,
                          ncol          = 1,
                          nrow          = 4,
                          common.legend = FALSE,
                          align         = "v"),
        ncol   = 2,
        widths = c(0.5, 10),
        top    = textGrob(
          sprintf("%s  |  task: %s  |  %s", roi_label, run_type, Sys.Date()),
          gp = gpar(fontsize = TITLE_FONTSIZE, fontface = "bold")
        )
      )
      
      grid.draw(final_plot)
      
      # ------------------------------------------------------------------------
      #   Save — one file per ROI
      # ------------------------------------------------------------------------
      ggsave(
        filename = file.path(save_dir,
                             paste0("roi-", roi_label,
                                    "_task-", run_type,
                                    "_desc-4effects.svg")),
        plot   = final_plot,
        width  = PANEL_WIDTH,
        height = figure_height,
        dpi    = 300, 
        device = "svg"
      )
      
    } # end roi_label loop
  } # end run_type loop
} # end roi_file loop


# =================================
# Cluster based analysis
# =================================


# ==============================================================================
#   lmer timeseries — save results as CSV only, no txt
# ==============================================================================

library(lmerTest)

run_timeseries_lmer <- function(sw_data, condition_var, subject_var = "sub") {
  # sw_data: subject-level means with columns: sub, tr_ordered, tr_sequence, 
  #          condition_var, mean_per_sub
  
  tr_list <- sort(unique(sw_data$tr_ordered))
  results <- data.frame()
  
  for (tr in tr_list) {
    df_tr <- sw_data[sw_data$tr_ordered == tr, ]
    
    fit <- tryCatch(
      suppressMessages(
        lmer(as.formula(sprintf("mean_per_sub ~ %s + (1|%s)", condition_var, subject_var)),
             data = df_tr)
      ),
      error = function(e) NULL
    )
    
    if (is.null(fit)) next
    
    coefs <- as.data.frame(summary(fit)$coefficients)
    coefs$term <- rownames(coefs)
    non_int <- coefs[coefs$term != "(Intercept)", ]
    
    # one row per non-intercept term (e.g. conditioncueL, or conditionstimM, conditionstimL)
    for (r in 1:nrow(non_int)) {
      results <- rbind(results, data.frame(
        tr_ordered  = as.character(tr),
        tr_sec      = (as.numeric(sub("tr", "", as.character(tr))) - 1) * 0.46,
        term        = non_int$term[r],
        estimate    = non_int$Estimate[r],
        se          = non_int$`Std. Error`[r],
        t_value     = non_int$`t value`[r],
        p_value     = non_int$`Pr(>|t|)`[r],
        significant = non_int$`Pr(>|t|)`[r] < 0.05,
        stringsAsFactors = FALSE
      ))
    }
  }
  return(results)
}

all_results <- data.frame()

for (roi_label in unique(df$ROI)) {
  for (run_type in run_types) {
    message(sprintf("Processing ROI: %s | task: %s", roi_label, run_type))
    
    # --- cue_epoch_cue ---
    cue_long <- df[df$condition %in% c("cueH", "cueL") &
                     df$runtype == run_type & df$ROI == roi_label, ] %>%
      pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value    = as.numeric(tr_value),
             tr_ordered  = factor(tr_num, levels = paste0("tr", 1:TR_length)),
             cue_ordered = factor(condition, levels = c("cueH", "cueL")))
    sw_cue <- meanSummary(cue_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
    sw_cue$mean_per_sub <- as.numeric(sw_cue$mean_per_sub)
    res <- run_timeseries_lmer(sw_cue, "cue_ordered")
    res$ROI <- roi_label; res$contrast <- "cue_epoch_cue"; res$task <- run_type
    all_results <- rbind(all_results, res)
    
    # --- stim_epoch_stim + stim_epoch_cue + interaction ---
    stim_long <- df[!(df$condition %in% c("rating", "cueH", "cueL")) &
                      df$runtype == run_type & df$ROI == roi_label, ] %>%
      separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE) %>%
      pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value     = as.numeric(tr_value),
             tr_ordered   = factor(tr_num,     levels = paste0("tr", 1:TR_length)),
             cue_ordered  = factor(cue,        levels = c("cueH", "cueL")),
             stim_ordered = factor(stim,       levels = c("stimH", "stimM", "stimL")),
             sixcond      = factor(condition,  levels = names(SIXCOND_COLORS)))
    
    sw_stim <- meanSummary(stim_long, c("sub", "tr_ordered", "stim_ordered"), "tr_value")
    sw_stim$mean_per_sub <- as.numeric(sw_stim$mean_per_sub)
    res <- run_timeseries_lmer(sw_stim, "stim_ordered")
    res$ROI <- roi_label; res$contrast <- "stim_epoch_stim"; res$task <- run_type
    all_results <- rbind(all_results, res)
    
    sw_cue_stim <- meanSummary(stim_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
    sw_cue_stim$mean_per_sub <- as.numeric(sw_cue_stim$mean_per_sub)
    res <- run_timeseries_lmer(sw_cue_stim, "cue_ordered")
    res$ROI <- roi_label; res$contrast <- "stim_epoch_cue"; res$task <- run_type
    all_results <- rbind(all_results, res)
    
    sw_6cond <- meanSummary(stim_long, c("sub", "tr_ordered", "sixcond"), "tr_value")
    sw_6cond$mean_per_sub <- as.numeric(sw_6cond$mean_per_sub)
    res <- run_timeseries_lmer(sw_6cond, "sixcond")
    res$ROI <- roi_label; res$contrast <- "stim_epoch_interaction"; res$task <- run_type
    all_results <- rbind(all_results, res)
  }
}

# Save all results
write.csv(all_results,
          file.path(save_dir, "lmer_timeseries_all.csv"),
          row.names = FALSE)

# Save significant only
sig_results <- all_results[all_results$significant == TRUE, ]
sig_results  <- sig_results[order(sig_results$contrast, sig_results$ROI, sig_results$tr_sec), ]
write.csv(sig_results,
          file.path(save_dir, "lmer_timeseries_significant.csv"),
          row.names = FALSE)

message(sprintf("Done. %d significant TR-level effects found.", nrow(sig_results)))
print(sig_results[, c("contrast", "ROI", "tr_sec", "term", "estimate", "t_value", "p_value")])


# ==============================================================================
#   Combined: Cluster permutation test + lmer within significant windows
# ==============================================================================

cluster_permutation_test <- function(data, condition_var, time_var, value_var,
                                     subject_var, conditions,
                                     n_permutations = 5000,
                                     threshold_p = 0.05,
                                     alpha = 0.05) {
  require(tidyr)
  require(dplyr)
  
  # Get unique time points
  time_points_factor <- sort(unique(data[[time_var]]))
  
  if (is.factor(time_points_factor)) {
    time_indices <- as.numeric(time_points_factor)
    time_points  <- (time_indices - 1) * 0.46
  } else {
    time_points <- as.numeric(as.character(time_points_factor))
  }
  n_trs <- length(time_points)
  
  # Wide matrices: subjects x TRs for each condition
  cond1_data <- data %>%
    filter(!!sym(condition_var) == conditions[1]) %>%
    select(all_of(c(subject_var, time_var, value_var))) %>%
    pivot_wider(names_from  = all_of(time_var),
                values_from = all_of(value_var)) %>%
    select(-all_of(subject_var)) %>%
    as.matrix()
  
  cond2_data <- data %>%
    filter(!!sym(condition_var) == conditions[2]) %>%
    select(all_of(c(subject_var, time_var, value_var))) %>%
    pivot_wider(names_from  = all_of(time_var),
                values_from = all_of(value_var)) %>%
    select(-all_of(subject_var)) %>%
    as.matrix()
  
  n_subjects <- nrow(cond1_data)
  
  # Helper: find consecutive clusters
  find_clusters <- function(significant_trs) {
    if (sum(significant_trs) == 0) return(list())
    rle_result  <- rle(significant_trs)
    cluster_list <- list()
    current_pos  <- 1
    for (i in seq_along(rle_result$lengths)) {
      if (rle_result$values[i]) {
        cluster_list <- c(cluster_list,
                          list(current_pos:(current_pos + rle_result$lengths[i] - 1)))
      }
      current_pos <- current_pos + rle_result$lengths[i]
    }
    return(cluster_list)
  }
  
  # Helper: compute cluster mass
  compute_cluster_mass <- function(t_stats, clusters) {
    if (length(clusters) == 0) return(0)
    masses <- sapply(clusters, function(c) sum(t_stats[c]))
    return(max(abs(masses)))
  }
  
  # STEP 1: Observed t-statistics at each TR
  observed_t <- numeric(n_trs)
  observed_p <- numeric(n_trs)
  for (tr_idx in 1:n_trs) {
    test_result        <- t.test(cond1_data[, tr_idx],
                                 cond2_data[, tr_idx],
                                 paired = TRUE)
    observed_t[tr_idx] <- test_result$statistic
    observed_p[tr_idx] <- test_result$p.value
  }
  
  # STEP 2: Observed clusters
  t_threshold              <- qt(1 - threshold_p / 2, df = n_subjects - 1)
  observed_significant     <- abs(observed_t) > t_threshold
  observed_clusters        <- find_clusters(observed_significant)
  observed_cluster_mass    <- compute_cluster_mass(observed_t, observed_clusters)
  
  # STEP 3: Permutation null distribution
  null_distribution <- numeric(n_permutations)
  message(sprintf("Running %d permutations...", n_permutations))
  pb <- txtProgressBar(min = 0, max = n_permutations, style = 3)
  
  for (perm in 1:n_permutations) {
    flip   <- sample(c(-1, 1), n_subjects, replace = TRUE)
    perm_t <- numeric(n_trs)
    for (tr_idx in 1:n_trs) {
      diff              <- cond1_data[, tr_idx] - cond2_data[, tr_idx]
      diff_perm         <- diff * flip
      perm_t[tr_idx]    <- mean(diff_perm) / (sd(diff_perm) / sqrt(n_subjects))
    }
    perm_significant        <- abs(perm_t) > t_threshold
    perm_clusters           <- find_clusters(perm_significant)
    null_distribution[perm] <- compute_cluster_mass(perm_t, perm_clusters)
    setTxtProgressBar(pb, perm)
  }
  close(pb)
  
  # STEP 4: Cluster-corrected p-value
  cluster_p_value <- mean(null_distribution >= observed_cluster_mass)
  
  # STEP 5: Identify significant clusters
  significant_clusters <- list()
  if (cluster_p_value < alpha && length(observed_clusters) > 0) {
    for (i in seq_along(observed_clusters)) {
      cluster_mass <- sum(observed_t[observed_clusters[[i]]])
      cluster_p    <- mean(null_distribution >= abs(cluster_mass))
      if (cluster_p < alpha) {
        significant_clusters[[length(significant_clusters) + 1]] <- list(
          indices     = observed_clusters[[i]],
          time_points = time_points[observed_clusters[[i]]],
          mass        = cluster_mass,
          p_value     = cluster_p
        )
      }
    }
  }
  
  return(list(
    observed_t            = observed_t,
    observed_p            = observed_p,
    time_points           = time_points,
    cluster_p_value       = cluster_p_value,
    significant_clusters  = significant_clusters,
    null_distribution     = null_distribution,
    observed_cluster_mass = observed_cluster_mass,
    threshold             = t_threshold,
    conditions            = conditions
  ))
}

cluster_summary <- data.frame()
lmer_in_clusters <- data.frame()

for (roi in roi_list) {
  
  common_path <- Sys.glob(
    file.path(datadir, "sub-*", paste0("sub-*", "*roi-", roi, "_tr-42.csv"))
  )
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]
  df <- do.call("rbind.fill", lapply(filter_path, FUN = function(f) {
    read.table(f, header = TRUE, sep = ",")
  }))
  
  for (run_type in run_types) {
    for (roi_label in sort(unique(df$ROI))) {
      message(sprintf("Processing ROI: %s | task: %s", roi_label, run_type))
      
      # -----------------------------------------------------------------------
      # Helper: run cluster test + lmer, store results
      # -----------------------------------------------------------------------
      run_combined <- function(sw_data, condition_var, contrast_name,
                               conditions, subject_var = "sub") {
        
        sw_data <- sw_data %>% add_tr_sequence()
        
        # --- 1. Cluster permutation test (2-condition only) ---
        cluster_res <- NULL
        if (length(conditions) == 2) {
          cluster_res <- cluster_permutation_test(
            data          = sw_data,
            condition_var = condition_var,
            time_var      = "tr_sequence",
            value_var     = "mean_per_sub",
            subject_var   = subject_var,
            conditions    = conditions,
            n_permutations = 5000,
            threshold_p   = 0.05,
            alpha         = 0.05
          )
          
          # store cluster summary
          if (length(cluster_res$significant_clusters) == 0) {
            cluster_summary <<- rbind(cluster_summary, data.frame(
              ROI = roi_label, contrast = contrast_name,
              cluster_p = cluster_res$cluster_p_value,
              n_clusters = 0, t_start = NA, t_end = NA,
              cluster_mass = NA
            ))
          } else {
            for (clust in cluster_res$significant_clusters) {
              cluster_summary <<- rbind(cluster_summary, data.frame(
                ROI = roi_label, contrast = contrast_name,
                cluster_p    = cluster_res$cluster_p_value,
                n_clusters   = length(cluster_res$significant_clusters),
                t_start      = min(clust$time_points),
                t_end        = max(clust$time_points),
                cluster_mass = clust$mass
              ))
            }
          }
        }
        
        # --- 2. lmer at each TR ---
        lmer_res <- run_timeseries_lmer(sw_data, condition_var, subject_var)
        lmer_res$ROI      <- roi_label
        lmer_res$contrast <- contrast_name
        lmer_res$task     <- run_type
        
        # --- 3. Filter lmer to significant cluster windows only ---
        if (!is.null(cluster_res) &&
            length(cluster_res$significant_clusters) > 0) {
          
          in_window <- do.call(rbind, lapply(
            cluster_res$significant_clusters, function(clust) {
              lmer_res[lmer_res$tr_sec >= min(clust$time_points) &
                         lmer_res$tr_sec <= max(clust$time_points), ]
            }))
          lmer_in_clusters <<- rbind(lmer_in_clusters, in_window)
        }
        
        return(list(cluster = cluster_res, lmer = lmer_res))
      }
      
      # -----------------------------------------------------------------------
      # 1. Cue epoch: cueH vs cueL
      # -----------------------------------------------------------------------
      cue_long <- df[df$condition %in% c("cueH", "cueL") &
                       df$runtype == run_type & df$ROI == roi_label, ] %>%
        pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
        mutate(tr_value    = as.numeric(tr_value),
               tr_ordered  = factor(tr_num, levels = paste0("tr", 1:TR_length)),
               cue_ordered = factor(condition, levels = c("cueH", "cueL")))
      
      sw_cue <- meanSummary(cue_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
      sw_cue$mean_per_sub <- as.numeric(sw_cue$mean_per_sub)
      
      res_cue <- run_combined(sw_cue, "cue_ordered", "cue_epoch_cue", c("cueH", "cueL"))
      
      # -----------------------------------------------------------------------
      # Shared stim epoch prep
      # -----------------------------------------------------------------------
      stim_long <- df[!(df$condition %in% c("rating", "cueH", "cueL")) &
                        df$runtype == run_type & df$ROI == roi_label, ] %>%
        separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE) %>%
        pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
        mutate(tr_value     = as.numeric(tr_value),
               tr_ordered   = factor(tr_num,    levels = paste0("tr", 1:TR_length)),
               cue_ordered  = factor(cue,       levels = c("cueH", "cueL")),
               stim_ordered = factor(stim,      levels = c("stimH", "stimM", "stimL")),
               sixcond      = factor(condition, levels = names(SIXCOND_COLORS)))
      
      # -----------------------------------------------------------------------
      # 2. Stim epoch: stimH vs stimL (cluster test) + all 3 levels (lmer)
      # -----------------------------------------------------------------------
      sw_stim <- meanSummary(stim_long, c("sub", "tr_ordered", "stim_ordered"), "tr_value")
      sw_stim$mean_per_sub <- as.numeric(sw_stim$mean_per_sub)
      sw_stim_2level <- sw_stim %>% filter(stim_ordered %in% c("stimH", "stimL"))
      
      res_stim <- run_combined(sw_stim_2level, "stim_ordered", "stim_epoch_stim",
                               c("stimH", "stimL"))
      
      # -----------------------------------------------------------------------
      # 3. Stim epoch: cueH vs cueL
      # -----------------------------------------------------------------------
      sw_cue_stim <- meanSummary(stim_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
      sw_cue_stim$mean_per_sub <- as.numeric(sw_cue_stim$mean_per_sub)
      
      res_cue_stim <- run_combined(sw_cue_stim, "cue_ordered", "stim_epoch_cue",
                                   c("cueH", "cueL"))
      
      # -----------------------------------------------------------------------
      # 4. Stim epoch: cueH_stimH vs cueL_stimL (interaction)
      # -----------------------------------------------------------------------
      sw_6cond <- meanSummary(stim_long, c("sub", "tr_ordered", "sixcond"), "tr_value")
      sw_6cond$mean_per_sub <- as.numeric(sw_6cond$mean_per_sub)
      sw_interaction <- sw_6cond %>% filter(sixcond %in% c("cueH_stimH", "cueL_stimL"))
      
      res_interaction <- run_combined(sw_interaction, "sixcond", "stim_epoch_interaction",
                                      c("cueH_stimH", "cueL_stimL"))
      
    } # end roi_label
  } # end run_type
} # end roi

# ==============================================================================
#   Save outputs
# ==============================================================================
write.csv(cluster_summary,
          file.path(save_dir, "cluster_permutation_summary.csv"),
          row.names = FALSE)

write.csv(lmer_in_clusters,
          file.path(save_dir, "lmer_within_clusters.csv"),
          row.names = FALSE)

message("Cluster summary:")
print(cluster_summary[order(cluster_summary$contrast, cluster_summary$ROI), ])

message("\nlmer results within significant cluster windows:")
print(lmer_in_clusters[, c("contrast", "ROI", "tr_sec", "term", "estimate", "t_value", "p_value")])




# ==============================================================================
#   Run across ROIs and contrasts, save to file
# ==============================================================================
output_file  <- file.path(save_dir, "lmer_timeseries_results.txt")
results_list <- list()

sink(output_file)

for (roi_label in unique(df$ROI)) {
  for (run_type in run_types) {
    
    cat("================================================================================\n")
    cat(sprintf("ROI: %s  |  task: %s\n", roi_label, run_type))
    cat("================================================================================\n\n")
    
    # ------------------------------------------------------------------
    # 1. Cue epoch: cueH vs cueL
    # ------------------------------------------------------------------
    cue_long <- df[df$condition %in% c("cueH", "cueL") &
                     df$runtype == run_type &
                     df$ROI == roi_label, ] %>%
      pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value    = as.numeric(tr_value),
             tr_ordered  = factor(tr_num, levels = paste0("tr", 1:TR_length)),
             cue_ordered = factor(condition, levels = c("cueH", "cueL")))
    
    sw_cue <- meanSummary(cue_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
    sw_cue$mean_per_sub <- as.numeric(sw_cue$mean_per_sub)
    
    cat("--- Contrast: cue_epoch_cue (cueH vs cueL) ---\n")
    res_cue <- run_timeseries_lmer(sw_cue, "cue_ordered")
    res_cue$ROI <- roi_label; res_cue$contrast <- "cue_epoch_cue"
    print(res_cue[res_cue$significant == TRUE, ])
    cat("\n")
    results_list[[length(results_list) + 1]] <- res_cue
    
    # ------------------------------------------------------------------
    # 2. Stim epoch: stimH vs stimM vs stimL (collapsed across cue)
    # ------------------------------------------------------------------
    stim_long <- df[!(df$condition %in% c("rating", "cueH", "cueL")) &
                      df$runtype == run_type &
                      df$ROI == roi_label, ] %>%
      separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE) %>%
      pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value     = as.numeric(tr_value),
             tr_ordered   = factor(tr_num,  levels = paste0("tr", 1:TR_length)),
             cue_ordered  = factor(cue,     levels = c("cueH", "cueL")),
             stim_ordered = factor(stim,    levels = c("stimH", "stimM", "stimL")),
             sixcond      = factor(condition, levels = names(SIXCOND_COLORS)))
    
    sw_stim <- meanSummary(stim_long, c("sub", "tr_ordered", "stim_ordered"), "tr_value")
    sw_stim$mean_per_sub <- as.numeric(sw_stim$mean_per_sub)
    
    cat("--- Contrast: stim_epoch_stim (stimH vs stimM vs stimL) ---\n")
    res_stim <- run_timeseries_lmer(sw_stim, "stim_ordered")
    res_stim$ROI <- roi_label; res_stim$contrast <- "stim_epoch_stim"
    print(res_stim[res_stim$significant == TRUE, ])
    cat("\n")
    results_list[[length(results_list) + 1]] <- res_stim
    
    # ------------------------------------------------------------------
    # 3. Stim epoch: cueH vs cueL (collapsed across stim)
    # ------------------------------------------------------------------
    sw_cue_stim <- meanSummary(stim_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
    sw_cue_stim$mean_per_sub <- as.numeric(sw_cue_stim$mean_per_sub)
    
    cat("--- Contrast: stim_epoch_cue (cueH vs cueL) ---\n")
    res_cue_stim <- run_timeseries_lmer(sw_cue_stim, "cue_ordered")
    res_cue_stim$ROI <- roi_label; res_cue_stim$contrast <- "stim_epoch_cue"
    print(res_cue_stim[res_cue_stim$significant == TRUE, ])
    cat("\n")
    results_list[[length(results_list) + 1]] <- res_cue_stim
    
    # ------------------------------------------------------------------
    # 4. Stim epoch: all 6 conditions
    # ------------------------------------------------------------------
    sw_6cond <- meanSummary(stim_long, c("sub", "tr_ordered", "sixcond"), "tr_value")
    sw_6cond$mean_per_sub <- as.numeric(sw_6cond$mean_per_sub)
    
    cat("--- Contrast: stim_epoch_interaction (all 6 conditions) ---\n")
    res_6cond <- run_timeseries_lmer(sw_6cond, "sixcond")
    res_6cond$ROI <- roi_label; res_6cond$contrast <- "stim_epoch_interaction"
    print(res_6cond[res_6cond$significant == TRUE, ])
    cat("\n")
    results_list[[length(results_list) + 1]] <- res_6cond
  }
}

sink()

# ------------------------------------------------------------------------------
#   Save combined results as CSV
# ------------------------------------------------------------------------------
all_results <- do.call(rbind, results_list)
write.csv(all_results,
          file.path(save_dir, "lmer_timeseries_all.csv"),
          row.names = FALSE)

sig_results <- all_results[all_results$significant == TRUE, ]
write.csv(sig_results,
          file.path(save_dir, "lmer_timeseries_significant.csv"),
          row.names = FALSE)

message(sprintf("Done. %d significant TR-level effects found across all ROIs and contrasts.",
                nrow(sig_results)))



# ==============================================================================
#   Find ROIs significant in both cue_epoch_cue and stim_epoch_cue
#   with opposite estimate direction
# ==============================================================================
sig <- read.csv(file.path(save_dir, "lmer_timeseries_significant.csv"))

# Average estimate per ROI x contrast (across significant TRs)
est_summary <- sig %>%
  filter(contrast %in% c("cue_epoch_cue", "stim_epoch_cue")) %>%
  group_by(ROI, contrast) %>%
  summarise(mean_estimate = mean(estimate), .groups = "drop")

# Pivot wide so each ROI has one column per contrast
est_wide <- est_summary %>%
  pivot_wider(names_from  = contrast,
              values_from = mean_estimate)

# Filter to ROIs that have both contrasts significant AND opposite sign
opposite_rois <- est_wide %>%
  filter(!is.na(cue_epoch_cue) & !is.na(stim_epoch_cue)) %>%
  mutate(
    sign_cue_epoch  = sign(cue_epoch_cue),
    sign_stim_epoch = sign(stim_epoch_cue),
    opposite_sign   = sign_cue_epoch != sign_stim_epoch,
    direction_cue_epoch  = ifelse(cue_epoch_cue  > 0, "cueL > cueH", "cueH > cueL"),
    direction_stim_epoch = ifelse(stim_epoch_cue > 0, "cueL > cueH", "cueH > cueL")
  ) %>%
  filter(opposite_sign) %>%
  arrange(ROI)

# Print results
cat(sprintf("Found %d ROIs with opposite cue direction across epochs:\n\n",
            nrow(opposite_rois)))
print(opposite_rois[, c("ROI", "cue_epoch_cue", "stim_epoch_cue",
                        "direction_cue_epoch", "direction_stim_epoch")])

# Save
write.csv(opposite_rois,
          file.path(save_dir, "roi_opposite_cue_direction.csv"),
          row.names = FALSE)

# ==============================================================================
#   Use FIR2HTW
# ==============================================================================

# load dataframe and stack

# group average compare peak and 

# ==============================================================================
#   Parameters
# ==============================================================================
htw_dir    <- file.path(main_dir, "analysis/fmri/spm/fir/ttl2_painpathway_fir2htw")
subject    <- "sub"
exclude    <- "sub-0001"

METRICS <- c("height", "halfheight","width", "auc")
METRIC_LABELS <- c(
  height     = "Peak height (A.U.)",
  halfheight = "Half height (A.U.)",
  width = "Width (A.U.)",
  auc        = "AUC (A.U.)"
)

# ==============================================================================
#   Load & stack all fir2htw2 CSVs
# ==============================================================================
htw_paths <- Sys.glob(file.path(htw_dir, "sub-*", "*fir2htw2.csv"))
htw_paths <- htw_paths[!str_detect(htw_paths, exclude)]

df_htw <- do.call("rbind.fill", lapply(htw_paths, function(f) {
  d     <- read.csv(f)
  fname <- basename(f)
  d$sub <- str_extract(fname, "sub-\\d+")
  d$ses <- str_extract(fname, "ses-\\d+")
  d$run <- str_extract(fname, "run-\\d+")
  d
}))

message(sprintf("Loaded %d files, %d subjects",
                length(htw_paths), length(unique(df_htw$sub))))

# ==============================================================================
#   Contrast configs
# ==============================================================================
CONTRAST_CONFIGS <- list(
  
  cue_epoch_cue = list(
    iv          = "cue_ordered",
    conditions  = c("cueH", "cueL"),
    colors      = CUE_COLORS,
    title       = "Cue epoch — Main effect of cue"
  ),
  
  stim_epoch_stim = list(
    iv          = "stim_ordered",
    conditions  = c("stimH", "stimM", "stimL"),
    colors      = STIM_COLORS,
    title       = "Stim epoch — Main effect of stim"
  ),
  
  stim_epoch_cue = list(
    iv          = "cue_ordered",
    conditions  = c("cueH", "cueL"),
    colors      = CUE_COLORS,
    title       = "Stim epoch — Main effect of cue"
  )
)

# ==============================================================================
#   Main loop: per ROI x contrast_type x metric
# ==============================================================================
for (roi_name in unique(df_htw$ROI)) {
  for (ctr_name in names(CONTRAST_CONFIGS)) {
    
    cfg <- CONTRAST_CONFIGS[[ctr_name]]
    
    # ------------------------------------------------------------------
    # 1. Filter to this ROI + contrast + relevant conditions
    # ------------------------------------------------------------------
    df_ctr <- df_htw %>%
      filter(ROI           == roi_name,
             contrast_type == ctr_name,
             condition     %in% cfg$conditions) %>%
      mutate(
        cue_ordered  = factor(condition,
                              levels = c("cueH",  "cueL")),
        stim_ordered = factor(condition,
                              levels = c("stimH", "stimM", "stimL"))
      )
    
    if (nrow(df_ctr) == 0) {
      warning(sprintf("No data: ROI=%s contrast=%s", roi_name, ctr_name))
      next
    }
    
    iv <- cfg$iv   # "cue_ordered" or "stim_ordered"
    
    panel_list <- list()
    
    for (metric in METRICS) {
      
      # ----------------------------------------------------------------
      # 2. Subject-level mean (average across runs)
      # ----------------------------------------------------------------
      sw <- meanSummary(df_ctr, c(subject, iv), metric)
      sw$mean_per_sub <- as.numeric(sw$mean_per_sub)
      
      # ----------------------------------------------------------------
      # 3. Group-level mean ± SE (within-subject corrected)
      # ----------------------------------------------------------------
      # gw <- summarySEwithin(
      #   data       = sw,
      #   measurevar = "mean_per_sub",
      #   withinvars = iv,
      #   idvar      = subject
      # )
      
      gw <- Rmisc::summarySE(
        data       = sw,
        measurevar = "mean_per_sub",
        groupvars  = iv
      )
      # ----------------------------------------------------------------
      # 4. lmer: condition effect
      # ----------------------------------------------------------------
      lmer_formula <- as.formula(
        sprintf("mean_per_sub ~ %s + (1|%s)", iv, subject)
      )
      lmer_fit <- lmer(lmer_formula, data = sw)
      lmer_p   <- summary(lmer_fit)$coefficients[2, "Pr(>|t|)"]
      
      # ----------------------------------------------------------------
      # 5. Plot: individual lines + group mean bar ± SE
      # ----------------------------------------------------------------
      p <- ggplot() +
        # individual subject lines _____________________
        # geom_line(
        #   data = sw,
        #   aes(x = .data[[iv]], y = mean_per_sub, group = sub),
        #   color = "gray70", alpha = 0.5, linewidth = 0.3
        # ) +
        # individual subject points _____________________
        # geom_point(
        #   data = sw,
        #   aes(x = .data[[iv]], y = mean_per_sub,
        #       color = .data[[iv]]),
      #   position = position_jitter(width = 0.06, seed = 42),
      #   size = 0.1, alpha = 0.1
      # ) +
      # group mean ± SE as pointrange _____________________
      geom_pointrange(
        data = gw,
        aes(x    = .data[[iv]],
            y    = mean_per_sub,
            ymin = mean_per_sub - se,
            ymax = mean_per_sub + se,
            color = .data[[iv]]),
        size      = 0.5, show.legend = TRUE,
        linewidth = 0.7
      ) +
        scale_color_manual(values = cfg$colors) +
        scale_fill_manual(values  = cfg$colors) +
        labs(
          title = sprintf("%s\n(N=%d, lmer p=%.3f)",
                          METRIC_LABELS[[metric]],
                          length(unique(sw[[subject]])),
                          lmer_p),
          x = NULL,
          y = METRIC_LABELS[[metric]]
        ) +
        theme_classic() +
        theme(
          legend.position = "none",
          aspect.ratio    = 1.2,   #ASPECT_RATIO,
          axis.text.x     = element_text(size = AXIS_FONTSIZE, angle = 30, hjust = 1),
          axis.text.y     = element_text(size = AXIS_FONTSIZE),
          axis.title.y    = element_text(size = AXIS_FONTSIZE),
          plot.title      = element_text(size = AXIS_FONTSIZE, face = "bold")
        )
      
      panel_list[[metric]] <- p
      
    } # end metric loop
    
    # ------------------------------------------------------------------
    # 6. Assemble 3 panels side by side
    # ------------------------------------------------------------------
    final_plot <- grid.arrange(
      grobs = panel_list,
      ncol  = 3,
      top   = textGrob(
        sprintf("%s  |  %s  |  %s", roi_name, ctr_name, Sys.Date()),
        gp = gpar(fontsize = TITLE_FONTSIZE, fontface = "bold")
      )
    )
    
    # ------------------------------------------------------------------
    # 7. Save
    # ------------------------------------------------------------------
    ggsave(
      filename = file.path(
        save_dir,
        sprintf("roi-%s_contrast-%s_desc-htw.png", roi_name, ctr_name)
      ),
      plot   = final_plot,
      width  = PANEL_WIDTH, # * 1.2,
      
      height = PANEL_WIDTH * 1.5,
      dpi    = 300
    )
    
    message(sprintf("Saved: %s / %s", roi_name, ctr_name))
    
  } # end contrast loop
} # end ROI loop


# ==============
# FIR2HTW lmer 
# ==============

# Ensure lmerTest is loaded to provide p-values
library(lmerTest)

# Storage for the significant results summary
results_list <- list()

for (ctr_name in names(CONTRAST_CONFIGS)) {
  cfg <- CONTRAST_CONFIGS[[ctr_name]]
  
  # Define the individual file for this contrast
  contrast_file <- file.path(save_dir, paste0("results_", ctr_name, ".txt"))
  
  # Create/Overwrite the file with a header [cite: 2, 7, 12]
  cat(paste0("=====================================================\n",
             "CONTRAST: ", ctr_name, "\n",
             "=====================================================\n\n"), 
      file = contrast_file)
  
  for (roi_name in unique(df_htw$ROI)) {
    df_ctr <- df_htw %>%
      filter(ROI == roi_name,
             contrast_type == ctr_name,
             condition %in% cfg$conditions) %>%
      mutate(condition = factor(condition, levels = cfg$conditions))
    
    if (nrow(df_ctr) == 0) next
    
    # Write ROI section header [cite: 2, 3, 4]
    cat(paste0("  ROI: ", roi_name, "\n",
               "  ", paste(rep("-", 40), collapse = ""), "\n"), 
        file = contrast_file, append = TRUE)
    
    for (metric in METRICS) {
      # 1. Run the model [cite: 2, 8, 13]
      fit <- lmer(as.formula(sprintf("%s ~ condition + (1|sub)", metric)), data = df_ctr)
      coefs <- as.data.frame(summary(fit)$coefficients)
      coefs$term <- rownames(coefs)
      
      # 2. Force the console output into the file using capture.output 
      cat(paste0("\n  Metric: ", metric, "\n"), file = contrast_file, append = TRUE)
      
      # This captures the print() output as a character vector
      captured_coefs <- capture.output(print(coefs)) 
      cat(paste(captured_coefs, collapse = "\n"), "\n", file = contrast_file, append = TRUE)
      
      # 3. Process Significance for the final table 
      non_int <- coefs[coefs$term != "(Intercept)", ]
      if(nrow(non_int) > 0) {
        non_int$ROI      <- roi_name
        non_int$contrast <- ctr_name
        non_int$metric   <- metric
        
        # Identify the p-value column (handling potential naming variations)
        p_col <- grep("Pr\\(>\\|t\\|\\)", names(non_int), value = TRUE)
        if(length(p_col) > 0) {
          non_int$significant <- non_int[[p_col]] < 0.05
          results_list[[length(results_list) + 1]] <- non_int
        }
      }
    }
    cat("\n", file = contrast_file, append = TRUE)
  }
}

# ------------------------------------------------------------------------------
# FINAL SUMMARIES: Combined Text File and CSV
# ------------------------------------------------------------------------------
lmer_results <- do.call(rbind, results_list)
sig_results  <- lmer_results[lmer_results$significant == TRUE, ]

# 1. Save Significant Results to Text 
main_txt <- file.path(save_dir, "lmer_all_results_combined.txt")
cat("SUMMARY OF SIGNIFICANT RESULTS (p < 0.05)\n", file = main_txt)
cat("=========================================\n\n", file = main_txt, append = TRUE)

if (nrow(sig_results) > 0) {
  sig_results <- sig_results[order(sig_results$contrast, sig_results$ROI, sig_results$metric), ]
  cat(paste(capture.output(print(sig_results)), collapse = "\n"), file = main_txt, append = TRUE)
  
  # 2. Save Significant Results to CSV (The most "reliable" way to save data)
  write.csv(sig_results, file.path(save_dir, "significant_results_summary.csv"), row.names = FALSE)
  message("Significant results also saved to: significant_results_summary.csv")
} else {
  cat("No significant results found.", file = main_txt, append = TRUE)
}

message("Processing complete. Check your directory: ", save_dir)

# Ensure lmerTest is loaded to provide p-values
library(lmerTest)

# Storage for the significant results summary
results_list <- list()

for (ctr_name in names(CONTRAST_CONFIGS)) {
  cfg <- CONTRAST_CONFIGS[[ctr_name]]
  
  # Define the individual file for this contrast
  contrast_file <- file.path(save_dir, paste0("results_", ctr_name, ".txt"))
  
  # Create/Overwrite the file with a header [cite: 2, 7, 12]
  cat(paste0("=====================================================\n",
             "CONTRAST: ", ctr_name, "\n",
             "=====================================================\n\n"), 
      file = contrast_file)
  
  for (roi_name in unique(df_htw$ROI)) {
    df_ctr <- df_htw %>%
      filter(ROI == roi_name,
             contrast_type == ctr_name,
             condition %in% cfg$conditions) %>%
      mutate(condition = factor(condition, levels = cfg$conditions))
    
    if (nrow(df_ctr) == 0) next
    
    # Write ROI section header [cite: 2, 3, 4]
    cat(paste0("  ROI: ", roi_name, "\n",
               "  ", paste(rep("-", 40), collapse = ""), "\n"), 
        file = contrast_file, append = TRUE)
    
    for (metric in METRICS) {
      # 1. Run the model [cite: 2, 8, 13]
      fit <- lmer(as.formula(sprintf("%s ~ condition + (1|sub)", metric)), data = df_ctr)
      coefs <- as.data.frame(summary(fit)$coefficients)
      coefs$term <- rownames(coefs)
      
      # 2. Force the console output into the file using capture.output 
      cat(paste0("\n  Metric: ", metric, "\n"), file = contrast_file, append = TRUE)
      
      # This captures the print() output as a character vector
      captured_coefs <- capture.output(print(coefs)) 
      cat(paste(captured_coefs, collapse = "\n"), "\n", file = contrast_file, append = TRUE)
      
      # 3. Process Significance for the final table 
      non_int <- coefs[coefs$term != "(Intercept)", ]
      if(nrow(non_int) > 0) {
        non_int$ROI      <- roi_name
        non_int$contrast <- ctr_name
        non_int$metric   <- metric
        
        # Identify the p-value column (handling potential naming variations)
        p_col <- grep("Pr\\(>\\|t\\|\\)", names(non_int), value = TRUE)
        if(length(p_col) > 0) {
          non_int$significant <- non_int[[p_col]] < 0.05
          results_list[[length(results_list) + 1]] <- non_int
        }
      }
    }
    cat("\n", file = contrast_file, append = TRUE)
  }
}

# ------------------------------------------------------------------------------
# FINAL SUMMARIES: Combined Text File and CSV
# ------------------------------------------------------------------------------
lmer_results <- do.call(rbind, results_list)
sig_results  <- lmer_results[lmer_results$significant == TRUE, ]

# 1. Save Significant Results to Text 
main_txt <- file.path(save_dir, "lmer_all_results_combined.txt")
cat("SUMMARY OF SIGNIFICANT RESULTS (p < 0.05)\n", file = main_txt)
cat("=========================================\n\n", file = main_txt, append = TRUE)

if (nrow(sig_results) > 0) {
  sig_results <- sig_results[order(sig_results$contrast, sig_results$ROI, sig_results$metric), ]
  cat(paste(capture.output(print(sig_results)), collapse = "\n"), file = main_txt, append = TRUE)
  
  # 2. Save Significant Results to CSV (The most "reliable" way to save data)
  write.csv(sig_results, file.path(save_dir, "significant_results_summary.csv"), row.names = FALSE)
  message("Significant results also saved to: significant_results_summary.csv")
} else {
  cat("No significant results found.", file = main_txt, append = TRUE)
}

message("Processing complete. Check your directory: ", save_dir)



  
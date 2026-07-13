# ==============================================================================
#   FIR_cbpt_painpathway.R
#   Cluster-based permutation test (CBPT) on FIR BOLD timecourses, pain task.
#
#   Statistical core PORTED from the emotionalappraisal repo:
#     code/code05_clustering/step02b_valence_cbpt.R  (origin/main @ 3008c695)
#   Functions reused verbatim: CCT, one_way_rm_f, get_clusters,
#                              cbpt_subject_wise.
#
#   Why this over the existing cluster_permutation_test() in
#   book_FIR_iv-6cond_dv-painpathway.R:
#     - repeated-measures F statistic -> handles k>=2 conditions
#       (3-level stim, 6-cond interaction) without collapsing to a pair
#     - permutation shuffles condition labels WITHIN subject (valid for F)
#     - adds Cauchy Combination Test (CCT) as an epoch-level complement
#
#   Design mapping (emotional appraisal -> pain FIR):
#     timepoints   -> FIR TR bins (tr1..tr42, 0.46 s each)
#     conditions   -> cueH vs cueL
#     subjects     -> sub
#
#   Contrasts (both cueH vs cueL, k=2):
#     cue_epoch_cue   cue main effect during the cue epoch
#     stim_epoch_cue  cue main effect during the stim epoch (collapsed over stim)
#
#   Outputs (under analysis/mixedeffect/book_fir_cbpt_dv-painpathway/<date>/):
#     cbpt_cluster_summary.csv   one row per contrast x ROI x cluster
#     cbpt_perTR_Fstats.csv      per-TR F, p, cluster membership
# ==============================================================================

# %% ── LIBRARIES ──────────────────────────────────────────────────────────────
library(plyr)      # rbind.fill
library(dplyr)
library(tidyr)
library(stringr)
library(cueR)      # meanSummary
library(parallel)  # mclapply — parallelize across ROIs

main_dir <- "/Users/h/Documents/projects_local/cue_expectancy"
file.sources <- list.files(
  file.path(main_dir, "scripts/step02_R/utils"),
  pattern = "*.R", full.names = TRUE, ignore.case = TRUE
)
sapply(file.sources, source, .GlobalEnv)

# %% ── PARAMETERS ─────────────────────────────────────────────────────────────
# Pass "flatten" as a CLI arg to combine L/R hemispheres at the subject level
# before the CBPT (e.g. aIns_L + aIns_R -> aIns, averaged). Outputs suffixed _flat.
FLATTEN  <- "flatten" %in% commandArgs(trailingOnly = TRUE)
OUT_SFX  <- "_signature"   # keep signature outputs separate from the ROI CBPT

datadir      <- file.path(main_dir, "analysis/fmri/spm/fir/signature")
analysis_dir <- file.path(main_dir, "analysis", "mixedeffect_revision", "fir")
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)
save_dir <- analysis_dir

TR_length      <- 42
TR_sec         <- 0.46
roi_list       <- c("signature-fir")   # signatures live in ONE file; the `signature` column splits NPS/NPSpos/SIIPS
run_types      <- c("pain")
exclude        <- "sub-0001"

N_PERMUTATIONS   <- 5000
ALPHA            <- 0.05     # threshold-forming AND cluster-level alpha
MIN_CLUSTER_SIZE <- 2L       # >= 2 consecutive TRs (~0.92 s) to form a cluster
RANDOM_STATE     <- 42L
N_CORES          <- max(1L, min(7L, parallel::detectCores() - 1L))  # ROIs run in parallel

SIXCOND_LEVELS <- c("cueH_stimH", "cueL_stimH", "cueH_stimM",
                    "cueL_stimM", "cueH_stimL", "cueL_stimL")

# ==============================================================================
#   STATISTICAL CORE  — ported verbatim from emotionalappraisal
#   code/code05_clustering/step02b_valence_cbpt.R
# ==============================================================================

# ── Cauchy Combination Test (Liu & Xie 2020) ──────────────────────────────────
# Combines per-timepoint p-values within an epoch into one summary p-value.
CCT <- function(pvals, weights = NULL) {
  if (any(is.na(pvals)))          stop("Cannot have NAs in p-values!")
  if (any(pvals < 0 | pvals > 1)) stop("All p-values must be between 0 and 1!")
  if (any(pvals == 0) && any(pvals == 1)) stop("Cannot have both 0 and 1 p-values!")
  if (any(pvals == 0)) return(0)
  if (any(pvals == 1)) { warning("p-values exactly 1 present!"); return(1) }

  if (is.null(weights)) {
    weights <- rep(1 / length(pvals), length(pvals))
  } else {
    if (length(weights) != length(pvals)) stop("weights and pvals must be same length!")
    if (any(weights < 0))                 stop("All weights must be non-negative!")
    weights <- weights / sum(weights)
  }

  is.small <- pvals < 1e-16
  cct.stat <- if (sum(is.small) == 0) {
    sum(weights * tan((0.5 - pvals) * pi))
  } else {
    sum((weights[is.small] / pvals[is.small]) / pi) +
      sum(weights[!is.small] * tan((0.5 - pvals[!is.small]) * pi))
  }

  if (cct.stat > 1e+15) (1 / cct.stat) / pi else 1 - pcauchy(cct.stat)
}

# ── repeated-measures one-way F across timepoints ─────────────────────────────
# groups : named list of k matrices each (n_subjects, n_tp)
# Returns: F-statistic vector of length n_tp
one_way_rm_f <- function(groups) {
  k    <- length(groups)
  n    <- nrow(groups[[1]])
  n_tp <- ncol(groups[[1]])

  grand_m    <- colMeans(Reduce("+", groups)) / k
  cond_means <- lapply(groups, colMeans)
  subj_means <- Reduce("+", groups) / k
  grand_mat  <- matrix(grand_m, nrow = n, ncol = n_tp, byrow = TRUE)

  SS_bet  <- n * Reduce("+", lapply(cond_means, function(cm) (cm - grand_m)^2))
  SS_subj <- k * colSums((subj_means - grand_mat)^2)
  SS_tot  <- Reduce("+", lapply(groups, function(g) colSums((g - grand_mat)^2)))
  SS_err  <- SS_tot - SS_bet - SS_subj

  MS_bet  <- SS_bet / (k - 1L)
  MS_err  <- SS_err / ((k - 1L) * (n - 1L))

  ifelse(MS_err > 0, MS_bet / MS_err, 0)
}

# ── contiguous supra-threshold cluster finder (mass = sum of F) ───────────────
get_clusters <- function(sig_mask, f_obs, min_size = 1L) {
  clusters <- list()
  n        <- length(sig_mask)
  in_cl    <- FALSE
  start    <- NA_integer_

  for (i in seq_len(n)) {
    if (sig_mask[i] && !in_cl) {
      in_cl <- TRUE; start <- i
    } else if (!sig_mask[i] && in_cl) {
      in_cl <- FALSE
      if ((i - start) >= min_size)
        clusters <- c(clusters, list(list(mass = sum(f_obs[start:(i - 1L)]),
                                          idx  = start:(i - 1L))))
    }
  }
  if (in_cl && (n - start + 1L) >= min_size)
    clusters <- c(clusters, list(list(mass = sum(f_obs[start:n]), idx = start:n)))
  clusters
}

# ── subject-wise CBPT: permute condition labels within each subject ───────────
cbpt_subject_wise <- function(groups,
                              n_permutations   = 5000L,
                              alpha            = 0.05,
                              min_cluster_size = 2L,
                              random_state     = 42L) {
  set.seed(random_state)
  k    <- length(groups)
  n    <- nrow(groups[[1]])
  n_tp <- ncol(groups[[1]])

  F_obs    <- one_way_rm_f(groups)
  F_thresh <- qf(1 - alpha, df1 = k - 1L, df2 = (k - 1L) * (n - 1L))

  cat(sprintf("  F_thresh=%.3f  F_obs_max=%.2f  above thresh: %d/%d tp\n",
              F_thresh, max(F_obs), sum(F_obs > F_thresh), n_tp))

  obs_clusters <- get_clusters(F_obs > F_thresh, F_obs, min_cluster_size)

  if (length(obs_clusters) == 0) {
    cat("  No clusters above threshold.\n")
    return(list(sig_mask = rep(FALSE, n_tp), cluster_p_tps = list(),
                F_obs = F_obs, F_thresh = F_thresh))
  }

  max_null_masses <- numeric(n_permutations)
  for (perm in seq_len(n_permutations)) {
    if (perm %% 1000L == 0L)
      cat(sprintf("  perm %d / %d\n", perm, n_permutations))

    perm_groups <- lapply(seq_len(k), function(ci) matrix(0, nrow = n, ncol = n_tp))
    for (subj in seq_len(n)) {
      ord <- sample.int(k)
      for (ci in seq_len(k))
        perm_groups[[ci]][subj, ] <- groups[[ord[ci]]][subj, ]
    }

    F_perm  <- one_way_rm_f(perm_groups)
    perm_cl <- get_clusters(F_perm > F_thresh, F_perm, min_cluster_size)
    if (length(perm_cl) > 0)
      max_null_masses[perm] <- max(sapply(perm_cl, `[[`, "mass"))
  }

  cat(sprintf("  Null 95th=%.1f  null max=%.1f\n",
              quantile(max_null_masses, 0.95), max(max_null_masses)))

  sig_mask      <- rep(FALSE, n_tp)
  cluster_p_tps <- list()
  for (cl in obs_clusters) {
    p    <- mean(max_null_masses >= cl$mass)
    flag <- if (p < alpha) "sig *" else "ns"
    cat(sprintf("  cluster tp %d-%d  mass=%.1f  p=%.4f  %s\n",
                min(cl$idx), max(cl$idx), cl$mass, p, flag))
    cluster_p_tps <- c(cluster_p_tps, list(list(p = p, idx = cl$idx, mass = cl$mass)))
    if (p < alpha) sig_mask[cl$idx] <- TRUE
  }

  list(sig_mask = sig_mask, cluster_p_tps = cluster_p_tps,
       F_obs = F_obs, F_thresh = F_thresh, k = k, n = n)
}

# ==============================================================================
#   PAIN-FIR ADAPTER
# ==============================================================================

# Build the list of k (n_subjects x n_tp) matrices that the CBPT core expects,
# from a subject-level summary frame (sub, tr_ordered, <condition_var>, mean_per_sub).
# Keeps only subjects with complete data across ALL conditions & TRs.
build_groups <- function(sw_data, condition_var, conditions,
                         value_var = "mean_per_sub",
                         subject_var = "sub", time_var = "tr_ordered") {
  tr_levels <- paste0("tr", seq_len(TR_length))
  sw <- sw_data %>%
    filter(.data[[condition_var]] %in% conditions) %>%
    mutate(!!condition_var := factor(.data[[condition_var]], levels = conditions),
           !!time_var       := factor(as.character(.data[[time_var]]), levels = tr_levels))

  # wide (subject x TR) matrix per condition
  mats <- lapply(conditions, function(cond) {
    w <- sw %>%
      filter(.data[[condition_var]] == cond) %>%
      select(all_of(c(subject_var, time_var, value_var))) %>%
      pivot_wider(names_from = all_of(time_var), values_from = all_of(value_var)) %>%
      arrange(.data[[subject_var]])
    list(sub = w[[subject_var]], mat = as.matrix(w[, tr_levels, drop = FALSE]))
  })

  # common, complete subjects across all conditions
  common <- Reduce(intersect, lapply(mats, function(m) m$sub))
  groups <- lapply(mats, function(m) {
    keep <- match(common, m$sub)
    m$mat[keep, , drop = FALSE]
  })
  complete <- Reduce(`&`, lapply(groups, function(g) stats::complete.cases(g)))
  groups <- lapply(groups, function(g) g[complete, , drop = FALSE])
  names(groups) <- conditions
  attr(groups, "subjects") <- common[complete]
  groups
}

# Run CBPT + CCT for one contrast, return tidy summary rows + per-TR frame.
run_cbpt_contrast <- function(sw_data, condition_var, conditions,
                              contrast_name, roi_label, run_type) {
  groups <- build_groups(sw_data, condition_var, conditions)
  n_sub  <- nrow(groups[[1]]); k <- length(groups)
  message(sprintf("  [%s] %s  k=%d conditions, N=%d subjects",
                  contrast_name, roi_label, k, n_sub))
  if (n_sub < 3) {
    warning(sprintf("Too few complete subjects (%d) for %s / %s", n_sub, contrast_name, roi_label))
    return(NULL)
  }

  res <- cbpt_subject_wise(groups,
                           n_permutations   = N_PERMUTATIONS,
                           alpha            = ALPHA,
                           min_cluster_size = MIN_CLUSTER_SIZE,
                           random_state     = RANDOM_STATE)

  # per-TR F -> p, and CCT epoch-level summary
  df1     <- k - 1L
  df2     <- (k - 1L) * (n_sub - 1L)
  perTR_p <- pmin(pmax(1 - pf(res$F_obs, df1, df2), .Machine$double.eps),
                  1 - .Machine$double.eps)
  cct_p   <- CCT(perTR_p)

  tr_sec  <- (seq_len(TR_length) - 1) * TR_sec
  cl_id   <- rep(NA_integer_, TR_length)
  if (length(res$cluster_p_tps) > 0)
    for (ci in seq_along(res$cluster_p_tps))
      cl_id[res$cluster_p_tps[[ci]]$idx] <- ci

  perTR <- data.frame(
    ROI = roi_label, task = run_type, contrast = contrast_name,
    tr = seq_len(TR_length), tr_sec = tr_sec,
    F_obs = res$F_obs, F_thresh = res$F_thresh,
    p_uncorrected = perTR_p,
    supra_threshold = res$F_obs > res$F_thresh,
    cluster_id = cl_id, cluster_sig = res$sig_mask,
    stringsAsFactors = FALSE
  )

  # cluster-level summary
  if (length(res$cluster_p_tps) == 0) {
    summ <- data.frame(
      ROI = roi_label, task = run_type, contrast = contrast_name,
      k_conditions = k, n_subjects = n_sub, F_thresh = res$F_thresh,
      cluster_id = NA, tr_start = NA, tr_end = NA,
      t_start_sec = NA, t_end_sec = NA, cluster_mass = NA,
      cluster_p = NA, cluster_sig = FALSE, cct_epoch_p = cct_p,
      stringsAsFactors = FALSE
    )
  } else {
    summ <- do.call(rbind, lapply(seq_along(res$cluster_p_tps), function(ci) {
      cl <- res$cluster_p_tps[[ci]]
      data.frame(
        ROI = roi_label, task = run_type, contrast = contrast_name,
        k_conditions = k, n_subjects = n_sub, F_thresh = res$F_thresh,
        cluster_id = ci,
        tr_start = min(cl$idx), tr_end = max(cl$idx),
        t_start_sec = (min(cl$idx) - 1) * TR_sec,
        t_end_sec   = (max(cl$idx) - 1) * TR_sec,
        cluster_mass = cl$mass, cluster_p = cl$p,
        cluster_sig = cl$p < ALPHA, cct_epoch_p = cct_p,
        stringsAsFactors = FALSE
      )
    }))
  }
  list(summary = summ, perTR = perTR)
}

# ==============================================================================
#   MAIN  — load FIR data, then run CBPT per ROI in parallel (mclapply)
# ==============================================================================

# All CBPT for a single ROI (all run_types x 4 contrasts). Returns list(summary, perTR).
# Runs in a forked worker: inherits df, params, and all functions from the parent.
process_one_roi <- function(roi_label, df) {
  roi_summary <- data.frame()
  roi_perTR   <- data.frame()

  for (run_type in run_types) {
    # --- cue epoch: cueH vs cueL -----------------------------------------------
    cue_long <- df[df$condition %in% c("cueH", "cueL") &
                     df$runtype == run_type & df$ROI == roi_label, ] %>%
      pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value    = as.numeric(tr_value),
             tr_ordered  = factor(tr_num, levels = paste0("tr", 1:TR_length)),
             cue_ordered = factor(condition, levels = c("cueH", "cueL")))
    sw_cue <- meanSummary(cue_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
    sw_cue$mean_per_sub <- as.numeric(sw_cue$mean_per_sub)

    # --- stim-epoch prep (cue main effect during stim, collapsed across stim) --
    stim_long <- df[!(df$condition %in% c("rating", "cueH", "cueL")) &
                      df$runtype == run_type & df$ROI == roi_label, ] %>%
      separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE) %>%
      pivot_longer(cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value") %>%
      mutate(tr_value     = as.numeric(tr_value),
             tr_ordered   = factor(tr_num,     levels = paste0("tr", 1:TR_length)),
             cue_ordered  = factor(cue,        levels = c("cueH", "cueL")))
    sw_cue_stim <- meanSummary(stim_long, c("sub", "tr_ordered", "cue_ordered"), "tr_value")
    sw_cue_stim$mean_per_sub <- as.numeric(sw_cue_stim$mean_per_sub)

    # --- contrasts: (frame, condition_var, levels, name) -----------------------
    # Only the two cue contrasts: cueH vs cueL in the cue epoch and in the stim epoch.
    contrasts <- list(
      list(sw_cue,      "cue_ordered", c("cueH", "cueL"), "cue_epoch_cue"),
      list(sw_cue_stim, "cue_ordered", c("cueH", "cueL"), "stim_epoch_cue")
    )
    for (ct in contrasts) {
      out <- run_cbpt_contrast(ct[[1]], ct[[2]], ct[[3]], ct[[4]], roi_label, run_type)
      if (is.null(out)) next
      roi_summary <- rbind(roi_summary, out$summary)
      roi_perTR   <- rbind(roi_perTR, out$perTR)
    }
  }
  list(summary = roi_summary, perTR = roi_perTR)
}

cluster_summary <- data.frame()
perTR_all       <- data.frame()

for (roi_file in roi_list) {
  common_path <- Sys.glob(file.path(datadir, "sub-*",
                                    paste0("sub-*", "*", roi_file, "_tr-42.csv")))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]
  df <- do.call("rbind.fill", lapply(filter_path, function(f) read.table(f, header = TRUE, sep = ",")))
  if (!("ROI" %in% names(df)) && "signature" %in% names(df)) df$ROI <- df$signature   # treat each signature as an "ROI"

  if (FLATTEN) {                               # combine L/R at subject level (avg over hemispheres + runs happens downstream)
    tr_cols <- paste0("tr", 1:TR_length)
    df$ROI  <- sub("_(L|R)$", "", df$ROI)
    df <- df %>%
      group_by(sub, ses, run, runtype, condition, ROI) %>%
      summarise(across(all_of(tr_cols), ~ mean(as.numeric(.x), na.rm = TRUE)), .groups = "drop") %>%
      as.data.frame()
    message(sprintf("FLATTEN: combined hemispheres -> %d regions", length(unique(df$ROI))))
  }

  roi_labels <- sort(unique(df$ROI))
  message(sprintf("Found %d ROIs: %s", length(roi_labels), paste(roi_labels, collapse = ", ")))
  message(sprintf("Running CBPT on %d cores (%d perms, %d contrasts/ROI)...",
                  N_CORES, N_PERMUTATIONS, 2L * length(run_types)))

  roi_results <- mclapply(roi_labels, process_one_roi, df = df,
                          mc.cores = N_CORES, mc.preschedule = FALSE)

  # surface any worker errors instead of silently dropping them
  errs <- vapply(roi_results, function(x) inherits(x, "try-error"), logical(1))
  if (any(errs)) {
    for (i in which(errs))
      message(sprintf("ERROR in ROI %s: %s", roi_labels[i], conditionMessage(attr(roi_results[[i]], "condition"))))
    roi_results <- roi_results[!errs]
  }

  cluster_summary <- rbind(cluster_summary, do.call(rbind, lapply(roi_results, `[[`, "summary")))
  perTR_all       <- rbind(perTR_all,       do.call(rbind, lapply(roi_results, `[[`, "perTR")))
}

# ==============================================================================
#   SAVE
# ==============================================================================
write.csv(cluster_summary, file.path(save_dir, paste0("cbpt_cluster_summary", OUT_SFX, ".csv")), row.names = FALSE)
write.csv(perTR_all,       file.path(save_dir, paste0("cbpt_perTR_Fstats",   OUT_SFX, ".csv")), row.names = FALSE)

message("\n=== Significant clusters (p < ", ALPHA, ") ===")
sig <- cluster_summary[which(cluster_summary$cluster_sig), ]
if (nrow(sig) > 0) {
  print(sig[, c("contrast", "ROI", "t_start_sec", "t_end_sec",
                "cluster_mass", "cluster_p", "cct_epoch_p")])
} else {
  message("None.")
}
message("\nDone. Outputs in: ", save_dir)

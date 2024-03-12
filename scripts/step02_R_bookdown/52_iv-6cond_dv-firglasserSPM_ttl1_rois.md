# [fMRI] FIR ~ task TTL1 {#ch52_timeseries}

---
title: "52_ROI TTL1"
output: html_document
date: "2023-08-14"
---


TODO
* load tsv
* concatenate 
* per time column, calculate mean and variance
* plot




```r
plot_timeseries_onefactor <-  function(df, iv1,  mean, error, xlab, ylab, ggtitle, color) {
    
n_points <- 100  # Number of points for interpolation
    g <- ggplot(
      data = df,
      aes(
        x = .data[[iv1]],
        y = .data[[mean]],
        group = 1,
        color = color
      ),
      cex.lab = 1.5,
      cex.axis = 2,
      cex.main = 1.5,
      cex.sub = 1.5
    ) +

      geom_errorbar(aes(
        ymin = (.data[[mean]] - .data[[error]]),
        ymax = (.data[[mean]] + .data[[error]]),
        color = color
      ), width = .1, alpha=0.8) +

      geom_line() +
      geom_point(color=color) +
      ggtitle(ggtitle) +
      xlab(xlab) +
      ylab(ylab) +

      theme_classic() +
      
      theme(aspect.ratio = .6) +
      expand_limits(x = 3.25) +

      scale_color_manual("",
                         values =  color) +
            # scale_fill_manual("",
                         # values =  color) +
      theme(
        legend.position = c(.99, .99),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6)
      ) +
      theme(legend.key = element_rect(fill = "white", colour = "white")) +
      theme_bw()
    
    return(g)
  }
```



```r
plot_timeseries_bar_SANDBOX <-  function(df, iv1, iv2, mean, error, xlab, ylab, ggtitle, color) {
    
n_points <- 100  # Number of points for interpolation
# interpolated_data <- data.frame(
#   
#   x = rep(seq(min(df[[iv1]]), max(df[[iv1]]), length.out = n_points), each = n_points),
#   y = rep(df[[mean]], each = n_points),
#   ymin = rep(df[[mean]] - df[[error]], each = n_points),
#   ymax = rep(df[[mean]] + df[[error]], each = n_points)
# )

## Removing "tr" from the column values
df[[iv1]] <- as.numeric(sub("tr", "", df[[iv1]]))

    g <- ggplot(
      data = df,
      aes(
        x = .data[[iv1]],
        y = .data[[mean]],
        group = factor(.data[[iv2]]),
        color = factor(.data[[iv2]])
      ),
      cex.lab = 1.5,
      cex.axis = 2,
      cex.main = 1.5,
      cex.sub = 1.5
    ) +

      geom_errorbar(aes(
        ymin = (.data[[mean]] - .data[[error]]),
        ymax = (.data[[mean]] + .data[[error]]),
        fill =  factor(.data[[iv2]])
      ), width = .1, alpha=0.8) +

      geom_line() +
      geom_point() +
      ggtitle(ggtitle) +
      xlab(xlab) +
      ylab(ylab) +

      theme_classic() +
      expand_limits(x = 3.25) +

      scale_color_manual("",
                         values =  color) +
            scale_fill_manual("",
                         values =  color) +
      theme(
        aspect.ratio = .6,
        text = element_text(size = 20),
        axis.title.x = element_text(size = 24),
        axis.title.y = element_text(size = 24),
        legend.position = c(.99, .99),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6)
      ) +
      theme(legend.key = element_rect(fill = "white", colour = "white")) +
      theme_bw()
    
    return(g)
  }
```



## parameters {TODO: ignore}

```r
# parameters
main_dir <- dirname(dirname(getwd()))

datadir <- file.path(main_dir, 'analysis/fmri/nilearn/glm/fir')
analysis_folder  = paste0("model52_iv-6cond_dv-firglasserSPM_ttl1")
analysis_dir <-
  file.path(main_dir,
            "analysis",
            "mixedeffect",
            analysis_folder,
            as.character(Sys.Date())) # nolint
dir.create(analysis_dir,
           showWarnings = FALSE,
           recursive = TRUE)
save_dir <- analysis_dir
```


## taskwise stim effect

```r
roi_list <- c( 'dACC', 'PHG', 'V1', 'SM', 'MT', 'RSC', 'LOC', 'FFC', 'PIT', 'pSTS', 'AIP', 'premotor') # 'rINS', 'TPJ',
run_types <- c("pain", "vicarious", "cognitive")
  plot_list <- list()
  TR_length <- 42
for (ROI in roi_list) {
    main_dir = dirname(dirname(getwd()))
    datadir = file.path(main_dir, "analysis/fmri/spm/fir/ttl1par")
    taskname = 'pain'
exclude <- "sub-0001"
filename <- paste0("sub-*",  "*roi-", ROI, "_tr-42.csv")
  common_path <- Sys.glob(file.path(datadir, "sub-*",  filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

df <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
    read.table(files, header = TRUE, sep = ",")
    }))

for (run_type in run_types) {
  print(run_type)
  filtered_df <- df[!(df$condition == "rating" | df$condition == "cue" | df$runtype != run_type), ]

  parsed_df <- filtered_df %>%
    separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE)
  # --------------------- subset regions based on ROI ----------------------------
  df_long <- pivot_longer(parsed_df, cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value")

  # ----------------------------- clean factor -----------------------------------
  df_long$tr_ordered <- factor(
          df_long$tr_num,
          levels = c(paste0("tr", 1:TR_length))
      )
  # df_long$tr_num <- (
  #         df_long$tr_num,
  #         levels = c( 1:TR_length)
  #     )
  df_long$stim_ordered <- factor(
          df_long$stim,
          levels = c("stimH", "stimM", "stimL")
      )

  # --------------------------- summary statistics -------------------------------
  subjectwise <- meanSummary(df_long,
                                        c("sub","tr_ordered", "stim_ordered"), "tr_value")
  groupwise <- summarySEwithin(
    data = subjectwise,
    measurevar = "mean_per_sub",
    withinvars = c( "stim_ordered", "tr_ordered"),
    idvar = "sub"
  )
  groupwise$task <- run_type
  # https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

  # ... Rest of your data processing code ...
  
  # subset <- groupwise[groupwise$runtype == run_type, ]
  LINEIV1 = "tr_ordered"
  LINEIV2 = "stim_ordered"
  MEAN = "mean_per_sub_norm_mean"
  ERROR = "se"
  dv_keyword = "actual"
  sorted_indices <- order(groupwise$tr_ordered)
  groupwise_sorted <- groupwise[sorted_indices, ]
  p1 <- plot_timeseries_bar_SANDBOX(groupwise_sorted, 
                            LINEIV1, LINEIV2, MEAN, ERROR,  
                            xlab = "TRs", 
                            ylab = paste0(ROI, " activation (A.U.)"), 
                            ggtitle = paste0(ROI, ": ",run_type, " (N = ", length(unique(subjectwise$sub)),") time series, Epoch - stimulus"), 
                            color = c("#5f0f40","#ae2012", "#fcbf49"))
  time_points <- seq(1, 0.46 * TR_length, 0.46)
  p1 <- p1 + annotate("rect", xmin = 0, xmax = 20, ymin = min(df[[MEAN]], na.rm = TRUE)-5, ymax = max(df[[MEAN]], na.rm = TRUE)+5, fill = "grey", alpha = 0.2)
  #p1 <- p1 + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:(7 + TR_length)])) + theme_classic()
  
  plot_list[[run_type]] <- p1 + theme_classic()
}
  
  # --------------------------- plot three tasks -------------------------------
library(gridExtra)
plot_list <- lapply(plot_list, function(plot) {
  plot + theme(plot.margin = margin(5, 5, 5, 5))  # Adjust plot margins if needed
})
combined_plot <- ggpubr::ggarrange(
  plot_list[["pain"]],plot_list[["vicarious"]],plot_list[["cognitive"]],
                  common.legend = TRUE,legend = "bottom", ncol = 3, nrow = 1, 
                  widths = c(3, 3, 3), heights = c(.5,.5,.5), align = "v")
print(combined_plot)
ggsave(file.path(save_dir, paste0("roi-", ROI,"_epoch-stim_desc-highstimGTlowstim.png")), combined_plot, width = 12, height = 4)

}
```

```
## [1] "pain"
```

```
## 
## Attaching package: 'raincloudplots'
```

```
## The following object is masked _by_ '.GlobalEnv':
## 
##     GeomFlatViolin
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## 
## Attaching package: 'gridExtra'
```

```
## The following object is masked from 'package:dplyr':
## 
##     combine
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-1.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-2.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-3.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-4.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-5.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-6.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-7.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-8.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-9.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-10.png" width="672" />

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-11.png" width="672" /><img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-4-12.png" width="672" />



```r
p1 + annotate("rect", xmin = 0, xmax = 10, ymin = min(df[[MEAN]], na.rm = TRUE)-5, ymax = max(df[[MEAN]], na.rm = TRUE)+5, fill = "grey", alpha = 0.2)
```

```
## Warning in min(df[[MEAN]], na.rm = TRUE): no non-missing arguments to min;
## returning Inf
```

```
## Warning in max(df[[MEAN]], na.rm = TRUE): no non-missing arguments to max;
## returning -Inf
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-5-1.png" width="672" />








### PCA subjectwise

```r
# install.packages("ggplot2")    # Install ggplot2 if you haven't already
# install.packages("FactoMineR") # Install FactoMineR if you haven't already
library(ggplot2)
library(FactoMineR)
run_types = c("pain")
for (run_type in run_types) {
  print(run_type)
  filtered_df <- df[!(df$condition == "rating" | df$condition == "cue" | df$runtype != run_type), ]

  parsed_df <- filtered_df %>%
    separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE)
  # --------------------- subset regions based on ROI ----------------------------
  df_long <- pivot_longer(parsed_df, cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value")

  # ----------------------------- clean factor -----------------------------------
  df_long$tr_ordered <- factor(
          df_long$tr_num,
          levels = c(paste0("tr", 1:TR_length))
      )
  df_long$stim_ordered <- factor(
          df_long$stim,
          levels = c("stimH", "stimM", "stimL")
      )

  # --------------------------- summary statistics -------------------------------
  subjectwise <- meanSummary(df_long,
                                        c("sub","tr_ordered", "stim_ordered"), "tr_value")

# Assuming your original dataframe is named 'df'

# Convert the dataframe to wide format
df_wide <- pivot_wider(subjectwise, 
                       id_cols = c("tr_ordered", "stim_ordered"), 
                       names_from = c("sub"), 
                       values_from = "mean_per_sub")

# df_wide <- pivot_wider(subjectwise, 
#                        id_cols = c("sub", "ROIindex","stim_ordered"), 
#                        names_from = "tr_ordered", 
#                        values_from = "mean_per_sub")
stim_high.df <- df_wide[df_wide$stim_ordered == "stimH",]
stim_med.df <- df_wide[df_wide$stim_ordered == "stimM",]
stim_low.df <- df_wide[df_wide$stim_ordered == "stimL",]
# selected_columns <- subset(stim_high.df, select = 2:(ncol(stim_high.df) - 1))
meanhighdf <- data.frame(subset(stim_high.df, select = 3:(ncol(stim_high.df) - 1)))
high.pca_result <- prcomp(meanhighdf)
high.pca_scores <- as.data.frame(high.pca_result$x)
# Access the proportion of variance explained by each principal component
high.variance_explained <- high.pca_result$sdev^2 / sum(high.pca_result$sdev^2)
plot(high.variance_explained)
# Access the standard deviations of each principal component
high.stdev <- high.pca_result$sdev

meanmeddf <- data.frame(subset(stim_med.df, select = 3:(ncol(stim_med.df) - 1)))
med.pca <- prcomp(meanmeddf)
med.pca_scores <- as.data.frame(med.pca$x)

meanlowdf <- data.frame(subset(stim_low.df, select = 3:(ncol(stim_low.df) - 1)))
low.pca <- prcomp(meanlowdf)
low.pca_scores <- as.data.frame(low.pca$x)
library(plotly)  # You can use plotly to create an interactive 3D plot
# plot_ly(high.pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers")
# plot_ly(low.pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers")
combined_pca_scores <- rbind(high.pca_scores, med.pca_scores, low.pca_scores)

# Add a new column to indicate the stim_ordered category (high_stim or low_stim)
combined_pca_scores$stim_ordered <- c(rep("high_stim", nrow(high.pca_scores)), 
                                      rep("med_stim", nrow(med.pca_scores)), 
                                      rep("low_stim", nrow(low.pca_scores)))

# Create the 3D PCA plot
plot_ly(combined_pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers",
        color = ~stim_ordered)
# data_matrix <- groupwise[groupwise$stim_ordered == "high_stim",c("tr_ordered", "mean_per_sub_norm_mean")]
# sorted_indices <- order(data_matrix$tr_ordered)
# df_ordered <- data_matrix[sorted_indices, ]
# pca_result <- PCA(data_matrix$mean_per_sub_norm_mean)
# datapoints <- df$datapoints
}
```

```
## [1] "pain"
```

```
## 
## Attaching package: 'plotly'
```

```
## The following object is masked from 'package:ggplot2':
## 
##     last_plot
```

```
## The following objects are masked from 'package:plyr':
## 
##     arrange, mutate, rename, summarise
```

```
## The following object is masked from 'package:reshape':
## 
##     rename
```

```
## The following object is masked from 'package:stats':
## 
##     filter
```

```
## The following object is masked from 'package:graphics':
## 
##     layout
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-6-1.png" width="672" />

```r
plot_ly(combined_pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers",
        color = ~stim_ordered)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-153cb3369e8076b69ea4" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-153cb3369e8076b69ea4">{"x":{"visdat":{"d2df52be2313":["function () ","plotlyVisDat"]},"cur_data":"d2df52be2313","attrs":{"d2df52be2313":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-2.5490822884318081,-1.224821305534878,-5.8458842657447745,-2.5003841075838578,-0.55085362736218479,2.2230724417057446,4.867818476109611,6.6837420584025722,14.275803714919443,16.915973817148174,27.695843980435715,22.442763940798024,34.384953906597211,39.720592983220904,55.781228495191044,62.507149255664821,72.389659232029416,76.780835381245694,85.914211358286522,85.458629221249453,87.892340015903926,90.192370008461467,89.264824033514657,77.815659543618523,77.55763810389216,70.540017301264569,65.795147839591436,51.368692591764145,30.569878751404058,9.8113126972385789,-14.650090378348629,-31.636969838980946,-63.239747970558533,-79.975308854129338,-98.878624025053739,-114.94027409961701,-125.22648796393935,-137.31867231989517,-146.39921288575681,-147.66355950786379,-143.23225094880016,-143.01793476205685],"y":[-33.263024508666113,-38.367816501153762,-48.217054279941948,-49.080483011803672,-57.121997002001088,-56.745237659764101,-60.250411018061421,-59.985977297766652,-64.437323780153037,-55.752535501820638,-48.285399471000922,-54.858730473750313,-45.65338429989076,-43.688953396500885,-28.444166913996035,-29.369593341146242,-13.008851895054821,-6.4897144627791974,10.693746208553645,16.307427192226928,24.555477185549488,42.047638438297291,41.458389198795345,53.303354884485444,61.72932011785575,71.249503249670099,66.130624961889879,49.139211730952468,50.963619227824161,39.061931382351688,35.904015723644065,33.601394572984724,36.766637576916757,32.327942130947271,35.374455319129488,30.544859047435665,25.599475398277168,16.402416852045778,8.9484128217059506,11.35433976966341,2.1505348835651188,-2.5940730595161368],"z":[-19.966186837600105,-20.756157530945167,-26.067632654882189,-25.992103514923603,-23.745504697010208,-21.464943023786386,-21.270102937654805,-15.508890065498683,-13.446113560923985,-7.9875678296226829,3.2044002572436918,0.20799937005375724,13.5348873769239,20.372623400037565,26.87434714699511,32.889099660116649,33.347869463135147,36.109721054579836,35.381494258789942,26.360798691605186,18.71446013087429,19.584978245703304,14.38665416904165,9.9978129366810187,1.532949086477386,-4.3627125345729887,-17.833272520997117,-33.780208071796039,-31.832711133682579,-34.75685628287011,-38.728367865745426,-35.600387026096328,-29.041088499871265,-18.627270598746843,-2.6595895476733817,1.6496275357414401,10.381190579246331,18.714676068717836,27.381958743283576,26.869750735354796,30.524468257920603,35.405899566376803],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-33.165907587007666,-33.07816047280582,-32.17893439868346,-31.967086819611804,-31.981421215893562,-26.070044994579209,-24.55591995957289,-15.42262688210975,-11.36954977354277,-1.5373212884195808,0.80260122370354314,5.1791084833491903,13.773141748943479,17.815233424509969,26.920705472121089,34.608651063842331,43.177958372253677,48.697347679220599,55.679042882428959,60.750675731413267,56.088698869990729,57.142872735405049,59.95836239915095,53.767537585927791,45.189092889759657,44.766468517728669,42.451766425190293,34.015461822492014,31.618231273672915,27.741366484203617,7.120377603101419,-3.3765666324291774,-15.691785986405012,-31.795188786427087,-36.949978258523579,-55.369809144256486,-55.457043665252634,-61.206070092789666,-63.555398357438435,-67.165748361509202,-68.770553820543313,-66.59958619060815],"y":[-33.699768845449285,-37.538144175523655,-35.277132136734487,-36.85756781137863,-41.505823417539247,-36.994635455497033,-44.057611512370492,-42.157847516157517,-36.25919921759953,-39.26591558873838,-39.638180060701558,-42.40752714706786,-31.96773680599857,-34.899410030543685,-33.967987442298394,-36.651666914109619,-26.597041134282005,-18.630472658394929,-3.439930032467764,3.0712647124330705,12.363866526201628,26.556405992765093,28.653990644582862,26.98555053202162,28.08058759128393,25.864590634126696,24.036930075161802,31.722283267251683,30.428011702551117,30.706074990805039,37.90658717229249,36.398154454963198,34.784148340785833,37.911818385076245,37.655603730074361,35.403264145894731,27.99144836589214,33.226938426101782,28.068641029977176,27.027225778486461,29.096156235537393,17.874055168586271],"z":[12.125799557068078,23.981211091369648,27.334931524826761,29.226255248601092,16.664274472797256,20.382910940394822,10.32106066110093,8.7147235184976228,7.3023789524777269,-0.30274970689682335,-11.470407697623777,-6.6897494510883435,-20.389419043400103,-20.623091238986582,-22.074722377455704,-30.368440012044299,-21.045082561419569,-19.86066204711048,-16.157324471126302,-14.687318443287518,-5.1466483177862266,-6.4857346569490453,3.8214160961970007,9.9816341136969822,19.535860942340218,21.576134234889192,16.503350170684165,22.473363695752838,22.502526355425569,4.6737945563413996,8.0053553505042085,8.9413380003042882,0.71597526459006611,2.4139860337262586,-5.1508466178997221,-4.6930091538838399,-11.714137414763488,-16.889681692018772,-19.161111802742422,-23.774876020222401,-15.901748141736618,-4.6115199131441349],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(252,141,98,1)","line":{"color":"rgba(252,141,98,1)"}},"textfont":{"color":"rgba(252,141,98,1)"},"error_y":{"color":"rgba(252,141,98,1)"},"error_x":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"frame":null},{"x":[-19.002327600916097,-19.339653881253167,-14.659147181720417,-19.170135399646803,-13.095598982618641,-15.894288027183567,-7.6752519282447347,-6.279529873884286,-8.7496622897701926,2.3108507851310702,7.4085686921250504,18.470780669095667,27.591395878623494,40.675610926501115,53.987962041799818,60.181520655069718,66.788905827727575,80.480144451558829,78.475337686728949,83.04019252992039,83.822809432953676,78.953628556994019,68.605806918997985,71.839497182169808,69.653445323717563,59.145627103367652,59.266883605465196,58.064638332708235,38.990478684331421,22.451495315037647,-4.6566595074520469,-20.291657908269325,-48.859346135464094,-69.029209732215534,-93.831115064066296,-92.713092469360348,-100.58132809666482,-111.73236352029301,-119.76134601754718,-119.78881686818885,-116.15114816273724,-108.94390195252812],"y":[-43.879649225752615,-41.480836241356798,-49.13896875272026,-45.094731209500587,-50.172228639854822,-53.530415217557938,-47.344914213689719,-51.708594623260403,-53.363609039192916,-48.922228168207603,-42.391844771210934,-46.941801132702899,-41.710192372262419,-35.547219013461365,-29.465300283983204,-21.14830038935639,-8.2424380085419475,-7.2758092660073475,4.8350120671276811,10.996765883429717,18.684447580617849,26.107969648620298,25.472770067583255,37.599814517486514,38.42667268762235,45.433398876715721,49.302967307721843,43.509529783764158,49.985828375626092,48.733324363268146,48.284405539954349,42.935229692900201,40.245441833418802,35.668801911048945,33.950788614799613,28.016512571182751,25.959423332064201,21.960591252761514,17.993376864186793,8.7198043897484787,8.5645491376164475,5.9716542693544721],"z":[-18.035465678215196,-22.734844629337719,-16.682337664457076,-25.23969877218266,-23.59011836257022,-21.66219544835376,-14.842503284880292,-15.430540639400233,-12.515814779661037,-7.7826960551656201,-3.6268197259213317,5.0603779521977668,13.927248269233559,23.279670455304899,23.117738993661021,23.435729450989985,23.480877057711641,26.747355476122575,23.869556362673098,17.035283029379546,21.970587280094012,26.649067922196256,12.816623980933405,9.2054680417368715,-9.5460040016575132,-16.467526088987917,-21.505388585038101,-21.776476970656141,-25.080255923050441,-24.476326728082228,-29.096296907533485,-21.678363802535891,-23.267391125397623,-15.419084159511124,-5.6562532924247302,-1.6869165971326896,17.630133559172986,19.729865147572635,26.248072035253294,32.990239795316192,26.327448830667535,24.277975581935678],"mode":"markers","type":"scatter3d","name":"med_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```


### PCA groupwise

```r
# install.packages("ggplot2")    # Install ggplot2 if you haven't already
# install.packages("FactoMineR") # Install FactoMineR if you haven't already
library(ggplot2)
library(FactoMineR)



# Assuming your original dataframe is named 'df'

# Convert the dataframe to wide format
df_wide.group <- pivot_wider(subjectwise,
                       id_cols = c("tr_ordered", "stim_ordered"),
                       names_from = "sub",
                       values_from = "mean_per_sub")
# ------
# data_matrix <- groupwise[groupwise$stim_ordered == "high_stim",c("tr_ordered", "mean_per_sub_norm_mean")]
# sorted_indices <- order(data_matrix$tr_ordered)
# df_ordered <- data_matrix[sorted_indices, ]
# datapoints <- df_ordered$mean_per_sub_norm_mean
# data_df <- data.frame(Dim1 = datapoints, Dim2 = datapoints, Dim3 = datapoints)
# pca <- prcomp(data_df)
# pca_scores <- as.data.frame(pca$x)
# plot_ly(pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers")
# -------
stim_high.df <- df_wide[df_wide$stim_ordered == "stimH",]
stim_low.df <- df_wide[df_wide$stim_ordered == "stimL",]
# selected_columns <- subset(stim_high.df, select = 2:(ncol(stim_high.df) - 1))
meanhighdf <- data.frame(subset(stim_high.df, select = 3:(ncol(stim_high.df) - 1)))
high.pca <- prcomp(meanhighdf)
high.pca_scores <- as.data.frame(high.pca$x)

meanlowdf <- data.frame(subset(stim_low.df, select = 3:(ncol(stim_low.df) - 1)))
low.pca <- prcomp(meanlowdf)
low.pca_scores <- as.data.frame(low.pca$x)
library(plotly)  # You can use plotly to create an interactive 3D plot
# plot_ly(high.pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers")
# plot_ly(low.pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers")
combined_pca_scores <- rbind(high.pca_scores, low.pca_scores)

# Add a new column to indicate the stim_ordered category (high_stim or low_stim)
combined_pca_scores$stim_ordered <- c(rep("high_stim", nrow(high.pca_scores)), rep("low_stim", nrow(low.pca_scores)))

# Create the 3D PCA plot
plot_ly(combined_pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers",
        color = ~stim_ordered)
```

```
## Warning in RColorBrewer::brewer.pal(N, "Set2"): minimal value for n is 3, returning requested palette with 3 different levels

## Warning in RColorBrewer::brewer.pal(N, "Set2"): minimal value for n is 3, returning requested palette with 3 different levels
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-3ec04fd1d6e896c7e932" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-3ec04fd1d6e896c7e932">{"x":{"visdat":{"d2df5b59342":["function () ","plotlyVisDat"]},"cur_data":"d2df5b59342","attrs":{"d2df5b59342":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-2.5490822884318081,-1.224821305534878,-5.8458842657447745,-2.5003841075838578,-0.55085362736218479,2.2230724417057446,4.867818476109611,6.6837420584025722,14.275803714919443,16.915973817148174,27.695843980435715,22.442763940798024,34.384953906597211,39.720592983220904,55.781228495191044,62.507149255664821,72.389659232029416,76.780835381245694,85.914211358286522,85.458629221249453,87.892340015903926,90.192370008461467,89.264824033514657,77.815659543618523,77.55763810389216,70.540017301264569,65.795147839591436,51.368692591764145,30.569878751404058,9.8113126972385789,-14.650090378348629,-31.636969838980946,-63.239747970558533,-79.975308854129338,-98.878624025053739,-114.94027409961701,-125.22648796393935,-137.31867231989517,-146.39921288575681,-147.66355950786379,-143.23225094880016,-143.01793476205685],"y":[-33.263024508666113,-38.367816501153762,-48.217054279941948,-49.080483011803672,-57.121997002001088,-56.745237659764101,-60.250411018061421,-59.985977297766652,-64.437323780153037,-55.752535501820638,-48.285399471000922,-54.858730473750313,-45.65338429989076,-43.688953396500885,-28.444166913996035,-29.369593341146242,-13.008851895054821,-6.4897144627791974,10.693746208553645,16.307427192226928,24.555477185549488,42.047638438297291,41.458389198795345,53.303354884485444,61.72932011785575,71.249503249670099,66.130624961889879,49.139211730952468,50.963619227824161,39.061931382351688,35.904015723644065,33.601394572984724,36.766637576916757,32.327942130947271,35.374455319129488,30.544859047435665,25.599475398277168,16.402416852045778,8.9484128217059506,11.35433976966341,2.1505348835651188,-2.5940730595161368],"z":[-19.966186837600105,-20.756157530945167,-26.067632654882189,-25.992103514923603,-23.745504697010208,-21.464943023786386,-21.270102937654805,-15.508890065498683,-13.446113560923985,-7.9875678296226829,3.2044002572436918,0.20799937005375724,13.5348873769239,20.372623400037565,26.87434714699511,32.889099660116649,33.347869463135147,36.109721054579836,35.381494258789942,26.360798691605186,18.71446013087429,19.584978245703304,14.38665416904165,9.9978129366810187,1.532949086477386,-4.3627125345729887,-17.833272520997117,-33.780208071796039,-31.832711133682579,-34.75685628287011,-38.728367865745426,-35.600387026096328,-29.041088499871265,-18.627270598746843,-2.6595895476733817,1.6496275357414401,10.381190579246331,18.714676068717836,27.381958743283576,26.869750735354796,30.524468257920603,35.405899566376803],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-33.165907587007666,-33.07816047280582,-32.17893439868346,-31.967086819611804,-31.981421215893562,-26.070044994579209,-24.55591995957289,-15.42262688210975,-11.36954977354277,-1.5373212884195808,0.80260122370354314,5.1791084833491903,13.773141748943479,17.815233424509969,26.920705472121089,34.608651063842331,43.177958372253677,48.697347679220599,55.679042882428959,60.750675731413267,56.088698869990729,57.142872735405049,59.95836239915095,53.767537585927791,45.189092889759657,44.766468517728669,42.451766425190293,34.015461822492014,31.618231273672915,27.741366484203617,7.120377603101419,-3.3765666324291774,-15.691785986405012,-31.795188786427087,-36.949978258523579,-55.369809144256486,-55.457043665252634,-61.206070092789666,-63.555398357438435,-67.165748361509202,-68.770553820543313,-66.59958619060815],"y":[-33.699768845449285,-37.538144175523655,-35.277132136734487,-36.85756781137863,-41.505823417539247,-36.994635455497033,-44.057611512370492,-42.157847516157517,-36.25919921759953,-39.26591558873838,-39.638180060701558,-42.40752714706786,-31.96773680599857,-34.899410030543685,-33.967987442298394,-36.651666914109619,-26.597041134282005,-18.630472658394929,-3.439930032467764,3.0712647124330705,12.363866526201628,26.556405992765093,28.653990644582862,26.98555053202162,28.08058759128393,25.864590634126696,24.036930075161802,31.722283267251683,30.428011702551117,30.706074990805039,37.90658717229249,36.398154454963198,34.784148340785833,37.911818385076245,37.655603730074361,35.403264145894731,27.99144836589214,33.226938426101782,28.068641029977176,27.027225778486461,29.096156235537393,17.874055168586271],"z":[12.125799557068078,23.981211091369648,27.334931524826761,29.226255248601092,16.664274472797256,20.382910940394822,10.32106066110093,8.7147235184976228,7.3023789524777269,-0.30274970689682335,-11.470407697623777,-6.6897494510883435,-20.389419043400103,-20.623091238986582,-22.074722377455704,-30.368440012044299,-21.045082561419569,-19.86066204711048,-16.157324471126302,-14.687318443287518,-5.1466483177862266,-6.4857346569490453,3.8214160961970007,9.9816341136969822,19.535860942340218,21.576134234889192,16.503350170684165,22.473363695752838,22.502526355425569,4.6737945563413996,8.0053553505042085,8.9413380003042882,0.71597526459006611,2.4139860337262586,-5.1508466178997221,-4.6930091538838399,-11.714137414763488,-16.889681692018772,-19.161111802742422,-23.774876020222401,-15.901748141736618,-4.6115199131441349],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

```r
# data_matrix <- groupwise[groupwise$stim_ordered == "high_stim",c("tr_ordered", "mean_per_sub_norm_mean")]
# sorted_indices <- order(data_matrix$tr_ordered)
# df_ordered <- data_matrix[sorted_indices, ]
# pca_result <- PCA(data_matrix$mean_per_sub_norm_mean)
# datapoints <- df$datapoints

# Assuming you have a dataframe named 'data' containing the 20 data points, 'x' and 'y' values, and corresponding standard deviations 'sd'

# Load the ggplot2 library
# install.packages("ggplot2")
library(ggplot2)

# Create the plot
# y = "mean_per_sub_mean"z
# combined_pca <- combined_pca_scores %>%
  # mutate(group_index = group_indices(., stim_ordered))

combined_pca <- combined_pca_scores %>%
  group_by(stim_ordered) %>%
  mutate(group_index = row_number())
ggplot(combined_pca, aes(x=group_index,y=PC1, group = stim_ordered, colour=stim_ordered)) +
  stat_smooth(method="loess", span=0.25, se=TRUE, aes(color=stim_ordered), alpha=0.3) +
  theme_bw()
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-8-2.png" width="672" />



```r
# Assuming you have a dataframe named 'data' containing the 20 data points, 'x' and 'y' values, and corresponding standard deviations 'sd'

# Load the ggplot2 library
# install.packages("ggplot2")
library(ggplot2)

# Create the plot
# y = "mean_per_sub_mean"z
ggplot(groupwise, aes(x=tr_ordered,y=mean_per_sub_mean, group = stim_ordered, colour=stim_ordered)) +
  stat_smooth(method="loess", span=0.25, se=TRUE, aes(color=stim_ordered), alpha=0.3) +
  theme_bw()
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-9-1.png" width="672" />


```r
# ggplot(data=groupwise, aes(x=tr_ordered, y=mean_per_sub_mean, ymin=se, ymax=se, fill=stim_ordered, linetype=stim_ordered)) + 
#  geom_line() + 
#  geom_ribbon(alpha=0.5)  
# Assuming you have a dataframe named 'data' containing the 20 mean data points and corresponding standard errors
# 'x' represents the x-values (e.g., time points)
# 'mean_y' represents the mean y-values
# 'se_y' represents the standard errors of the mean y-values

# Load the ggplot2 library
# install.packages("ggplot2")
library(ggplot2)
# groupwise$x <- as.numeric(groupwise$x)
# 
# # Sort the dataframe by the 'x' variable (if it's not already sorted)
# data <- data[order(data$x), ]

# Create the plot
# Create the plot with custom span and smoothing method
ggplot(groupwise, aes(x=tr_ordered,y=mean_per_sub_mean)) +
  geom_line() +                                   # Plot the smooth line for the mean
  geom_ribbon(aes(ymin = mean_per_sub_mean - se, ymax = mean_per_sub_mean + se), alpha = 0.3) + # Add the ribbon for standard error
  geom_smooth(method = "loess", span = 0.1, se = FALSE) +       # Add the loess smoothing curve
  labs(x = "X-axis Label", y = "Y-axis Label", title = "Smooth Line with Standard Error Ribbon") +
  theme_minimal()
```

```
## `geom_smooth()` using formula = 'y ~ x'
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-10-1.png" width="672" />




### taskwise cue effect

```r
roi_list <- c( 'dACC', 'PHG', 'V1', 'SM', 'MT', 'RSC', 'LOC', 'FFC', 'PIT', 'pSTS', 'AIP', 'premotor')# 'rINS', 'TPJ',
for (ROI in roi_list) {
    
    datadir = "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/spm/fir/ttl2par"
# taskname = 'pain'
exclude <- "sub-0001"
filename <- paste0("sub-*",  "*roi-", ROI, "_tr-42.csv")
  common_path <- Sys.glob(file.path(datadir, "sub-*",  filename
  ))
  filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

df <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
    read.table(files, header = TRUE, sep = ",")
    }))


run_types <- c("pain", "vicarious", "cognitive")
  plot_list <- list()
  TR_length <- 42
for (run_type in run_types) {
  filtered_df <- df[!(df$condition == "rating" | df$condition == "cue" | df$runtype != run_type), ]

  parsed_df <- filtered_df %>%
    separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE)
  # --------------------- subset regions based on ROI ----------------------------
  df_long <- pivot_longer(parsed_df, cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value")

  # ----------------------------- clean factor -----------------------------------
  df_long$tr_ordered <- factor(
          df_long$tr_num,
          levels = c(paste0("tr", 1:TR_length))
      )
df_long$cue_ordered <- factor(
        df_long$cue,
        levels = c("cueH","cueL")
    )

  # --------------------------- summary statistics -------------------------------
  subjectwise <- meanSummary(df_long,
                                        c("sub","tr_ordered", "cue_ordered"), "tr_value")
  groupwise <- summarySEwithin(
    data = subjectwise,
    measurevar = "mean_per_sub",
    withinvars = c( "cue_ordered", "tr_ordered"),
    idvar = "sub"
  )
  groupwise$task <- run_type
  # https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

  # ... Rest of your data processing code ...
  
  # subset <- groupwise[groupwise$runtype == run_type, ]
  LINEIV1 = "tr_ordered"
  LINEIV2 = "cue_ordered"
  MEAN = "mean_per_sub_norm_mean"
  ERROR = "se"
  dv_keyword = "actual"
  sorted_indices <- order(groupwise$tr_ordered)
  groupwise_sorted <- groupwise[sorted_indices, ]
  p1 <- plot_timeseries_bar(groupwise_sorted, 
                            LINEIV1, LINEIV2, MEAN, ERROR,  
                            xlab = "TRs", 
                            ylab = paste0(ROI, " activation (A.U.)"), 
                            ggtitle = paste0(run_type, " time series, Epoch - stimulus"), 
                            color =c("red", "blue"))
  time_points <- seq(1, 0.46 * TR_length, 0.46)
  #p1 <- p1 + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:(7 + TR_length)])) + theme_classic()
  
  plot_list[[run_type]] <- p1 + theme_classic()
}
  
  # --------------------------- plot three tasks -------------------------------
library(gridExtra)
plot_list <- lapply(plot_list, function(plot) {
  plot + theme(plot.margin = margin(5, 5, 5, 5))  # Adjust plot margins if needed
})
combined_plot <- ggpubr::ggarrange(plot_list[["pain"]],plot_list[["vicarious"]],plot_list[["cognitive"]],
                  common.legend = TRUE,legend = "bottom", ncol = 3, nrow = 1, 
                  widths = c(3, 3, 3), heights = c(.5,.5,.5), align = "v")
combined_plot
ggsave(file.path(save_dir, paste0("roi-", ROI, "_epoch-cue_desc-highcueGTlowcue.png")), combined_plot, width = 12, height = 4)
}
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax = (.data[[mean]] + : Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
```

### epoch: stim, rating




### epoch: 6 cond

```r
# ------------------------------------------------------------------------------
#                       epoch stim, high cue vs low cue
# ------------------------------------------------------------------------------
# --------------------- subset regions based on ROI ----------------------------

# ----------------------------- clean factor -----------------------------------
df_long$tr_ordered <- factor(
        df_long$tr_num,
        levels = c(paste0("tr", 1:TR_length))
    )
df_long$cue_ordered <- factor(
        df_long$cue,
        levels = c("cueH", "cueL")
    )
df_long$stim_ordered <- factor(
        df_long$stim,
        levels = c("stimH", "stimM", "stimL")
    )

df_long$sixcond <- factor(
        df_long$condition,
        levels = c("cueH_stimH", "cueL_stimH", 
                   "cueH_stimM", "cueL_stimM",
                   "cueH_stimL", "cueL_stimL")
) 
# --------------------------- summary statistics -------------------------------
subjectwise <- meanSummary(df_long,
                                      c("sub", "tr_ordered", "sixcond"), "tr_value")
groupwise <- summarySEwithin(
  data = subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c("sixcond", "tr_ordered"),
  idvar = "sub"
)
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

# --------------------------------- plot ---------------------------------------
LINEIV1 = "tr_ordered"
LINEIV2 = "sixcond"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
sorted_indices <- order(groupwise$tr_ordered)
groupwise_sorted <- groupwise[sorted_indices, ]
p3H = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("High intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")" ), color=c("red","#5f0f40","gray", "gray", "gray", "gray"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p3H + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-13-1.png" width="672" />

```r
p3H + theme_classic()
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-13-2.png" width="672" />


```r
p3M = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("Medium intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")"), color=c("#d6d6d6","#d6d6d6","#bc3908", "#f6aa1c", "gray", "gray"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p3M + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-14-1.png" width="672" />

```r
p3M + theme_classic()
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-14-2.png" width="672" />


```r
p3L = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("Low intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")"), color=c("gray","gray","gray", "gray", "#2541b2", "#00a6fb"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p3L + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-15-1.png" width="672" />

```r
p3L + theme_classic()
```

<img src="52_iv-6cond_dv-firglasserSPM_ttl1_rois_files/figure-html/unnamed-chunk-15-2.png" width="672" />



## taskwise 6 cond effect


```r
# ------------------------------------------------------------------------------
#                       epoch stim, high cue vs low cue
# ------------------------------------------------------------------------------
# --------------------- subset regions based on ROI ----------------------------
run_types <- c("pain", "vicarious", "cognitive")
  
  TR_length <- 42
for (run_type in run_types) {
  filtered_df <- df[!(df$condition == "rating" | df$condition == "cue" | df$runtype != run_type), ]
plot_list <- list()

  parsed_df <- filtered_df %>%
    separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE)
  # --------------------- subset regions based on ROI ----------------------------
  df_long <- pivot_longer(parsed_df, cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value")

# ----------------------------- clean factor -----------------------------------
df_long$tr_ordered <- factor(
        df_long$tr_num,
        levels = c(paste0("tr", 1:TR_length))
    )
df_long$cue_ordered <- factor(
        df_long$cue,
        levels = c("cueH", "cueL")
    )
df_long$stim_ordered <- factor(
        df_long$stim,
        levels = c("stimH", "stimM", "stimL")
    )

df_long$sixcond <- factor(
        df_long$condition,
        levels = c("cueH_stimH", "cueL_stimH", 
                   "cueH_stimM", "cueL_stimM",
                   "cueH_stimL", "cueL_stimL")
) 
# --------------------------- summary statistics -------------------------------
subjectwise <- meanSummary(df_long,
                                      c("sub", "tr_ordered", "sixcond"), "tr_value")
groupwise <- summarySEwithin(
  data = subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c("sixcond", "tr_ordered"),
  idvar = "sub"
)
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

# --------------------------------- plot ---------------------------------------
LINEIV1 = "tr_ordered"
LINEIV2 = "sixcond"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
sorted_indices <- order(groupwise$tr_ordered)
groupwise_sorted <- groupwise[sorted_indices, ]
p3H = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("High intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")" ), color=c("red","#5f0f40","gray", "gray", "gray", "gray"))
time_points <- seq(1, 0.46 * TR_length, 0.46)
# p3H + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
p3H + theme_classic()
plot_list[["H"]] <- p3H + theme_classic()

p3M = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("Medium intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")"), color=c("#d6d6d6","#d6d6d6","#bc3908", "#f6aa1c", "gray", "gray"))
time_points <- seq(1, 0.46 * TR_length, 0.46)
# p3M + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
plot_list[["M"]] <- p3M + theme_classic()

p3L = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("Low intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")"), color=c("gray","gray","gray", "gray", "#2541b2", "#00a6fb"))
time_points <- seq(1, 0.46 * TR_length, 0.46)
# p3L + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
plot_list[["L"]] <- p3L + theme_classic()


  # --------------------------- plot three tasks -------------------------------
library(gridExtra)
plot_list <- lapply(plot_list, function(plot) {
  plot + theme(plot.margin = margin(5, 5, 5, 5))  # Adjust plot margins if needed
})
combined_plot <- ggpubr::ggarrange(plot_list[["H"]],plot_list[["M"]],plot_list[["L"]],
                  common.legend = FALSE,legend = "bottom", ncol = 3, nrow = 1, 
                  widths = c(3, 3, 3), heights = c(.5,.5,.5), align = "v")
combined_plot
ggsave(file.path(save_dir, paste0("taskwise-",run_type, "_epoch-stim_desc-stimcuecomparison.png")), combined_plot, width = 12, height = 4)
}
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax = (.data[[mean]] + : Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
```





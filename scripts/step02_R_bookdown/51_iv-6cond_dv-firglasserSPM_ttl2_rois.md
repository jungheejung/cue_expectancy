# [fMRI] FIR ~ task {#ch51_fir_glasserTPJttl2}

---
title: "51_iv-6cond_dv-firglasserSPM_TPJ"
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



## parameters {TODO: ignore}

```r
# parameters
main_dir <- dirname(dirname(getwd()))

datadir <- file.path(main_dir, 'analysis/fmri/nilearn/glm/fir')
analysis_folder  = paste0("model52_iv-6cond_dv-firglasserSPM_ttl2")
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


# taskwise stim effect

```r
roi_list <- c('rINS', 'TPJ', 'dACC', 'PHG', 'V1', 'SM', 'MT', 'RSC', 'LOC', 'FFC', 'PIT', 'pSTS', 'AIP', 'premotor')
run_types <- c("pain", "vicarious", "cognitive")
  plot_list <- list()
  TR_length <- 42
for (ROI in roi_list) {
    
    datadir = "/Users/h/Documents/projects_local/cue_expectancy/analysis/fmri/spm/fir/ttl2par"
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
  p1 <- plot_timeseries_bar(groupwise_sorted, 
                            LINEIV1, LINEIV2, MEAN, ERROR,  
                            xlab = "TRs", 
                            ylab = paste0(ROI, " activation (A.U.)"), 
                            ggtitle = paste0(ROI, ": ",run_type, " (N = ", length(unique(subjectwise$sub)),") time series, Epoch - stimulus"), 
                            color = c("#5f0f40","#ae2012", "#fcbf49"))
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
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
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
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "pain"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "vicarious"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```
## [1] "cognitive"
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```






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

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-4-1.png" width="672" />

```r
plot_ly(combined_pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers",
        color = ~stim_ordered)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-a460182a67044bc23c7a" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-a460182a67044bc23c7a">{"x":{"visdat":{"cf86359f1d04":["function () ","plotlyVisDat"]},"cur_data":"cf86359f1d04","attrs":{"cf86359f1d04":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-3.5788109233784517,-2.0533347388596135,-6.5336218647865048,-2.7083216152222245,-0.82374954470855566,1.0655748176929267,3.583298881895908,5.5563725928507406,12.885062337428804,17.16493147416675,26.318430905717545,22.124327309718296,35.004207885933944,40.558945380024504,58.529141037493488,64.663134539960552,75.574527605961364,80.504681380370556,88.853870004454819,88.474313313103636,90.870391787896637,92.487071169826322,91.578581425689933,80.506727557836768,79.630063963028789,71.48288335823402,66.461675896748019,51.867215718905634,31.162107340353856,10.660676316876522,-15.439539064936193,-31.490238750398674,-63.430947755775989,-80.612034829054494,-100.83536652324536,-116.34121468973696,-128.03202901695414,-140.62301423580092,-150.52905134311825,-151.59358717604789,-145.81099929470389,-147.13235263544215],"y":[-35.799086995982059,-40.762489650462371,-51.943208835590724,-52.218068664860738,-60.020978980190009,-59.713727196356885,-63.765093576372998,-63.012208382804182,-68.154743793542863,-58.743133103019062,-48.55555039825002,-54.690183562411974,-46.069270743051128,-42.045770006073859,-27.797390325514566,-26.995409904715295,-13.916191815317422,-7.4124700487557007,11.42927535570373,17.121117406962199,26.327938273260528,42.321370478232033,42.977995658382333,56.45952541141358,63.498300398301986,71.960100980349381,64.470761099784937,49.352187160396277,51.538679580944581,40.852807250063016,38.356454462271977,36.088401666324643,38.028828530992008,34.601746501051281,36.528602437331365,31.113200797482506,26.389499705204482,18.696845742053483,10.97768301312145,12.863126172777486,1.95686779008995,-2.2963398892234004],"z":[-20.368503983741324,-21.888162194383796,-25.968037199696571,-25.101881294833742,-23.885738856181138,-21.15812147997903,-20.62221799663487,-13.953720977137371,-13.096391751480835,-8.8966820595222611,0.34077690684818041,0.6148599070365105,14.75591274560305,21.629297858872061,27.496511515079217,34.504693974335758,33.136603233913043,38.151524374152331,35.179539959984886,27.822283474719864,20.044042082498937,18.156917899465629,14.268748250323508,11.186305471004001,2.0557724533876072,-7.3188258482323585,-18.236587362937161,-35.52774484672716,-32.70628693228624,-36.624545340348391,-40.854960187380826,-36.401260869286787,-30.051021786625785,-20.49509582617657,-3.3876880999761227,2.4659565243325932,12.892098280121788,19.63470830993057,28.388527367522578,28.101953981149226,30.43701272985826,35.27942759342875],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-27.632028230350592,-25.731525601711798,-25.299975170275157,-25.18680903756054,-23.190695001267944,-18.714852981660158,-16.553426860976515,-5.0427579982985851,-2.5890864976130885,7.1557849615621745,10.083579323217279,15.069773962025451,21.351099134012383,26.730591023250977,37.556582097691958,44.781423778836583,51.198376881716534,52.96024834403034,56.867843328561705,61.166852742695106,55.114354917589516,53.990358400640787,54.749928352466299,49.770357478082367,40.045830219639235,39.35904898942875,38.17304351200886,27.826457484642969,23.868700397697175,18.288836395540105,-2.5735371544541383,-13.433993856144692,-24.054673094068402,-39.580455144127598,-44.622157733759742,-63.459942825754887,-63.510197460095142,-70.010374365201443,-71.899606526203712,-75.272211756018677,-75.798648291621888,-71.95211613817186],"y":[-37.102745040665177,-41.340295373177135,-42.336580300145798,-39.804649201559215,-47.352420897833923,-39.330599410608585,-44.698058781433673,-45.023322435671737,-37.243082738739595,-41.662043127370012,-39.628405295853462,-41.120345561609462,-31.559728676254238,-33.969592054887727,-34.487959627473906,-36.47000429559953,-25.368378853670098,-14.53140691954316,0.70553831635614894,7.4019566042573386,18.441679983069189,31.063225606071398,33.655743143016082,32.744628795618524,33.42748414479702,33.49654443767718,35.889854547859414,42.247560240578551,43.734744530717876,43.994528304917488,47.921283784322668,43.725371341232801,37.14997631635616,34.42959969698726,29.827582968062607,24.05317342528674,18.310636228456719,21.644152022919542,18.352394324321821,15.700065016024615,16.41679376264026,8.6951010505490078],"z":[12.944966892698991,24.228006333311299,22.226845407650231,27.988087566390664,17.796756595861762,20.889840850123207,13.972857024967402,9.0928043277548412,6.6988219346300095,1.2435680706410768,-7.1896146780466745,-3.2260773933458951,-13.272562029074475,-14.122783303383597,-18.187305562670357,-22.555863326985737,-17.918953623211202,-19.312581921894697,-15.538754071029459,-15.253948888685127,-10.052919062076089,-17.038299687496384,-8.8265517205285384,-3.9878522169802277,4.6343921578682359,13.106450940197215,18.530075732600636,25.725376690627179,30.496485197553181,17.043818902974678,18.908667534385426,18.617092806677284,7.3346358511762082,4.8279529169838202,-3.1593484239024257,-4.959260670003415,-13.789468144083285,-23.349364250258628,-22.078398554948819,-29.842803707948587,-20.445587879324226,-12.19920461919561],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(252,141,98,1)","line":{"color":"rgba(252,141,98,1)"}},"textfont":{"color":"rgba(252,141,98,1)"},"error_y":{"color":"rgba(252,141,98,1)"},"error_x":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"frame":null},{"x":[-22.572817516108397,-22.171528797928971,-17.73396264867425,-21.667777499678369,-14.75265783220018,-18.186987462937541,-9.4109152518257098,-7.4817355752711441,-11.412613512158403,0.58843919147861368,5.8333607041740114,17.10472007670808,26.998767315430548,40.357636826826152,53.468859105262531,59.535903257677965,67.626804272407739,80.584641846019423,80.20272061993569,85.096036532619721,87.060030350298845,82.00083927120059,71.533836552662052,73.912659740620398,71.783583044393467,60.863580729147252,61.334492988222621,59.343511875210204,41.881054007010086,24.694885328027393,-3.0284188020669478,-19.907332582962066,-49.106160184095941,-69.25793878856615,-93.783894549422101,-93.021380448889474,-100.04904639031918,-112.66269524071939,-118.91132427851498,-121.2555769609158,-116.42887632593818,-109.00272298614014],"y":[-40.353014848992089,-40.903875118265972,-47.796362915935653,-44.029778049751407,-50.52889418529611,-54.058728268569752,-49.309060132201324,-52.905864331945537,-51.553105222815411,-46.97677224794451,-41.312146478011975,-47.923003665257369,-42.870421753912431,-34.826216184512994,-30.048235203847614,-22.157647455666844,-8.483848927786056,-8.0545911367992495,0.68533110647279849,7.538624140663984,15.328212113987568,24.562984529331651,24.132304725546931,36.805423068875278,36.862356204132901,43.035487897747309,50.17437998196327,44.008096476464786,51.117731966268835,47.776767457461268,51.544021514064887,43.627911216505169,43.925397826766854,40.41504352870615,36.118465086649834,29.608543200591512,25.529470899405233,23.321048514401664,17.936521235668234,6.701063742786693,8.120400457140823,5.2159792359088106],"z":[-22.930393323846054,-25.769046967938177,-23.300906197190482,-28.734337300773653,-27.108961058629951,-26.565628989981306,-18.704874337325382,-17.501344638383312,-12.240090499975661,-4.742777452278613,-0.85187279232867186,6.6360924823896763,16.281255300129015,25.148355523211045,25.662871267643457,26.327945481442242,26.165235527681531,29.485027447616076,26.177069348386077,19.054385220131071,23.037592141643401,25.679860259186345,11.134785059992684,7.6799621536568541,-9.4757232491520398,-15.970738295852826,-23.408235115326658,-23.808293226827914,-27.875232576943208,-26.230153978951545,-29.114105185194759,-21.181092932002517,-23.754048725172705,-13.265289434056601,-3.6556052623843787,2.4878780937361453,21.446309979704385,21.617508744478098,26.838412956964049,33.499003617514262,27.306281743390411,24.522919191619604],"mode":"markers","type":"scatter3d","name":"med_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
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
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-47e2b19eda57c6effad6" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-47e2b19eda57c6effad6">{"x":{"visdat":{"cf86fc2db1a":["function () ","plotlyVisDat"]},"cur_data":"cf86fc2db1a","attrs":{"cf86fc2db1a":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-3.5788109233784517,-2.0533347388596135,-6.5336218647865048,-2.7083216152222245,-0.82374954470855566,1.0655748176929267,3.583298881895908,5.5563725928507406,12.885062337428804,17.16493147416675,26.318430905717545,22.124327309718296,35.004207885933944,40.558945380024504,58.529141037493488,64.663134539960552,75.574527605961364,80.504681380370556,88.853870004454819,88.474313313103636,90.870391787896637,92.487071169826322,91.578581425689933,80.506727557836768,79.630063963028789,71.48288335823402,66.461675896748019,51.867215718905634,31.162107340353856,10.660676316876522,-15.439539064936193,-31.490238750398674,-63.430947755775989,-80.612034829054494,-100.83536652324536,-116.34121468973696,-128.03202901695414,-140.62301423580092,-150.52905134311825,-151.59358717604789,-145.81099929470389,-147.13235263544215],"y":[-35.799086995982059,-40.762489650462371,-51.943208835590724,-52.218068664860738,-60.020978980190009,-59.713727196356885,-63.765093576372998,-63.012208382804182,-68.154743793542863,-58.743133103019062,-48.55555039825002,-54.690183562411974,-46.069270743051128,-42.045770006073859,-27.797390325514566,-26.995409904715295,-13.916191815317422,-7.4124700487557007,11.42927535570373,17.121117406962199,26.327938273260528,42.321370478232033,42.977995658382333,56.45952541141358,63.498300398301986,71.960100980349381,64.470761099784937,49.352187160396277,51.538679580944581,40.852807250063016,38.356454462271977,36.088401666324643,38.028828530992008,34.601746501051281,36.528602437331365,31.113200797482506,26.389499705204482,18.696845742053483,10.97768301312145,12.863126172777486,1.95686779008995,-2.2963398892234004],"z":[-20.368503983741324,-21.888162194383796,-25.968037199696571,-25.101881294833742,-23.885738856181138,-21.15812147997903,-20.62221799663487,-13.953720977137371,-13.096391751480835,-8.8966820595222611,0.34077690684818041,0.6148599070365105,14.75591274560305,21.629297858872061,27.496511515079217,34.504693974335758,33.136603233913043,38.151524374152331,35.179539959984886,27.822283474719864,20.044042082498937,18.156917899465629,14.268748250323508,11.186305471004001,2.0557724533876072,-7.3188258482323585,-18.236587362937161,-35.52774484672716,-32.70628693228624,-36.624545340348391,-40.854960187380826,-36.401260869286787,-30.051021786625785,-20.49509582617657,-3.3876880999761227,2.4659565243325932,12.892098280121788,19.63470830993057,28.388527367522578,28.101953981149226,30.43701272985826,35.27942759342875],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-27.632028230350592,-25.731525601711798,-25.299975170275157,-25.18680903756054,-23.190695001267944,-18.714852981660158,-16.553426860976515,-5.0427579982985851,-2.5890864976130885,7.1557849615621745,10.083579323217279,15.069773962025451,21.351099134012383,26.730591023250977,37.556582097691958,44.781423778836583,51.198376881716534,52.96024834403034,56.867843328561705,61.166852742695106,55.114354917589516,53.990358400640787,54.749928352466299,49.770357478082367,40.045830219639235,39.35904898942875,38.17304351200886,27.826457484642969,23.868700397697175,18.288836395540105,-2.5735371544541383,-13.433993856144692,-24.054673094068402,-39.580455144127598,-44.622157733759742,-63.459942825754887,-63.510197460095142,-70.010374365201443,-71.899606526203712,-75.272211756018677,-75.798648291621888,-71.95211613817186],"y":[-37.102745040665177,-41.340295373177135,-42.336580300145798,-39.804649201559215,-47.352420897833923,-39.330599410608585,-44.698058781433673,-45.023322435671737,-37.243082738739595,-41.662043127370012,-39.628405295853462,-41.120345561609462,-31.559728676254238,-33.969592054887727,-34.487959627473906,-36.47000429559953,-25.368378853670098,-14.53140691954316,0.70553831635614894,7.4019566042573386,18.441679983069189,31.063225606071398,33.655743143016082,32.744628795618524,33.42748414479702,33.49654443767718,35.889854547859414,42.247560240578551,43.734744530717876,43.994528304917488,47.921283784322668,43.725371341232801,37.14997631635616,34.42959969698726,29.827582968062607,24.05317342528674,18.310636228456719,21.644152022919542,18.352394324321821,15.700065016024615,16.41679376264026,8.6951010505490078],"z":[12.944966892698991,24.228006333311299,22.226845407650231,27.988087566390664,17.796756595861762,20.889840850123207,13.972857024967402,9.0928043277548412,6.6988219346300095,1.2435680706410768,-7.1896146780466745,-3.2260773933458951,-13.272562029074475,-14.122783303383597,-18.187305562670357,-22.555863326985737,-17.918953623211202,-19.312581921894697,-15.538754071029459,-15.253948888685127,-10.052919062076089,-17.038299687496384,-8.8265517205285384,-3.9878522169802277,4.6343921578682359,13.106450940197215,18.530075732600636,25.725376690627179,30.496485197553181,17.043818902974678,18.908667534385426,18.617092806677284,7.3346358511762082,4.8279529169838202,-3.1593484239024257,-4.959260670003415,-13.789468144083285,-23.349364250258628,-22.078398554948819,-29.842803707948587,-20.445587879324226,-12.19920461919561],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
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

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-6-2.png" width="672" />



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

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-7-1.png" width="672" />

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

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-8-1.png" width="672" />



## DEP: epoch: stim, high cue vs low cue


```r
# filtered_df <- subset(df, condition != "rating")
filtered_df <- df[!(df$condition == "rating" | df$condition == "cue"), ]

parsed_df <- filtered_df %>%
  separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE)

TR_length <- 42
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
                                      c("sub", "tr_ordered", "cue_ordered"), "tr_value")
groupwise <- summarySEwithin(
  data = subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c("cue_ordered", "tr_ordered"),
  idvar = "sub"
)
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

# --------------------------------- plot ---------------------------------------
LINEIV1 = "tr_ordered"
LINEIV2 = "cue_ordered"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
sorted_indices <- order(groupwise$tr_ordered)
groupwise_sorted <- groupwise[sorted_indices, ]
p1 = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle="time_series", color=c("red", "blue"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p1 + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-9-1.png" width="672" />

## taskwise cue effect

```r
roi_list <- c('rINS', 'TPJ', 'dACC', 'PHG', 'V1', 'SM', 'MT', 'RSC', 'LOC', 'FFC', 'PIT', 'pSTS', 'AIP', 'premotor')
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
ggsave(file.path(save_dir, paste0("roi-", ROI, "_epoch-stim_desc-highcueGTlowcue.png")), combined_plot, width = 12, height = 4)
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
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
```

## epoch: stim, rating




## epoch: 6 cond

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

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-12-1.png" width="672" />

```r
p3H + theme_classic()
```

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-12-2.png" width="672" />


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

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-13-1.png" width="672" />

```r
p3M + theme_classic()
```

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-13-2.png" width="672" />


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

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-14-1.png" width="672" />

```r
p3L + theme_classic()
```

<img src="51_iv-6cond_dv-firglasserSPM_ttl2_rois_files/figure-html/unnamed-chunk-14-2.png" width="672" />



# taskwise 6 cond effect


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








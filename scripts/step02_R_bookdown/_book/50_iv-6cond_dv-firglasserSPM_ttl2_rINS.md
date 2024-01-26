# [fMRI] FIR ~ task {#ch50_fir_glasser}

---
title: "50_iv-6cond_dv-firglasserSPM_ttl2_rINS"
output: html_document
date: "2023-08-14"
---


TODO
* load tsv
* concatenate 
* per time column, calculate mean and variance
* plot



## parameters {TODO: ignore}

```r
# parameters
main_dir <- dirname(dirname(getwd()))
ROI <- "rINS"
datadir <- file.path(main_dir, 'analysis/fmri/nilearn/glm/fir')
analysis_folder  = paste0("model50_iv-6cond_dv-firglasserSPM_ttl2_", ROI)
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

## load dataframe

```r
# ------------------------------------------------------------------------------
#                       epoch stim, high stim vs low stim
# ------------------------------------------------------------------------------
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
```

## taskwise stim effect

```r
run_types <- c("pain", "vicarious", "cognitive")
  plot_list <- list()
  TR_length <- 42
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
  # TODO: count number of participants and add number
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
                            ggtitle = paste0(run_type, " (N = ", length(unique(subjectwise$sub)),") time series, Epoch - stimulus"),
                            color = c("#5f0f40","#ae2012", "#fcbf49"))
  time_points <- seq(1, 0.46 * TR_length, 0.46)
  #p1 <- p1 + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:(7 + TR_length)])) + theme_classic()
  
  plot_list[[run_type]] <- p1 + theme_classic()
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

```r
  # --------------------------- plot three tasks -------------------------------
library(gridExtra)
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

```r
plot_list <- lapply(plot_list, function(plot) {
  plot + theme(plot.margin = margin(5, 5, 5, 5))  # Adjust plot margins if needed
})
combined_plot <- ggpubr::ggarrange(plot_list[["pain"]],plot_list[["vicarious"]],plot_list[["cognitive"]],
                  common.legend = TRUE,legend = "bottom", ncol = 3, nrow = 1, 
                  widths = c(3, 3, 3), heights = c(.5,.5,.5), align = "v")
combined_plot
```

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-4-1.png" width="672" />

```r
ggsave(file.path(save_dir, "taskwise_epoch-stim_desc-highcueGTlowcue.png"), combined_plot, width = 12, height = 4)
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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-5-1.png" width="672" />

```r
plot_ly(combined_pca_scores, x = ~PC1, y = ~PC2, z = ~PC3, type = "scatter3d", mode = "markers",
        color = ~stim_ordered)
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-0f0501da361e43fe0b0f" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-0f0501da361e43fe0b0f">{"x":{"visdat":{"a6b25ce3f347":["function () ","plotlyVisDat"]},"cur_data":"a6b25ce3f347","attrs":{"a6b25ce3f347":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-108.77076486001364,-104.71646387442763,-111.58460688145847,-110.47682825786828,-110.46368465327032,-108.16373179917491,-104.14147977674595,-100.59210001588114,-92.142085518682705,-87.813072744695035,-74.50360409989743,-70.971234626279383,-53.780604716959246,-29.604131079687271,1.5146654719951467,27.577029761693574,57.771653115301262,79.185033627509085,109.3081510494796,127.12235633554464,148.5206719947993,165.8009597273506,172.28776399160924,171.39468928689877,172.91354105094732,174.72473099136104,164.59619579035987,162.27019765653282,149.01640097316559,128.12118685819564,98.476812142079538,77.238221150946785,38.627940717696966,2.5801012856417782,-34.013589832838285,-68.941280868024776,-103.99836697356388,-120.95930640290283,-146.24607259755857,-154.01801499090803,-162.01381345224362,-171.13346495602704],"y":[-34.119040143776282,-29.582834896674719,-32.519823024483657,-38.797886857952783,-50.974853725492544,-47.939561189041235,-67.30218293215394,-56.156953745152855,-60.818659792519007,-65.882237709363963,-60.883380069643394,-57.939821500034775,-56.423367485574332,-55.011328520655503,-51.399572589020693,-59.908982808810059,-56.441524331317261,-59.521450659419337,-42.005067136040999,-38.818548352253949,-29.399777472819856,-19.514342480950628,-25.662334295525334,-3.8083996220046945,8.3079259652662643,15.504578714730018,22.545608193928143,27.932773442609694,49.033606480887386,52.537332347190038,67.102369888336312,62.574040401694809,76.90920059888451,84.277449134855061,92.693549045156558,98.076887000730267,83.95835322294613,85.82877861189742,79.814774579012308,73.802367335924203,59.514940608423004,60.417395768209651],"z":[-18.306930465346941,-24.426138629846186,-28.139683704834724,-33.88771137386972,-36.90750778792399,-31.526462265551739,-47.308783768776593,-31.487320106662139,-26.561350859657068,-15.414942663347697,-2.5209230631144743,7.5224884205753764,13.386677775236816,26.458149374816852,34.327401732356861,38.713758857404564,37.302818394862385,35.698438501670203,37.412252950794333,33.541180008980966,28.622170482012404,19.176434177299392,17.840747712524823,8.9194845541819081,15.540283209180329,-10.733244384921965,-21.421675475804815,-39.19215409669787,-29.227108578051254,-31.576715433530673,-37.988448503696162,-39.346163061188399,-28.292718677615408,-22.3823935432968,-4.5980733432956846,1.117866966494812,24.917005793922662,30.935942191993771,38.063177589559444,32.111694579899712,38.074234330625309,41.564242182637535],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-84.534868192994281,-84.590932375650397,-76.434796710677233,-77.819912596654191,-81.111213330730394,-79.659402273631088,-78.909628018186496,-70.430749042876968,-66.880556316369379,-54.837661275189539,-42.453594911488082,-36.530667950808251,-27.170381938614138,-6.1023049825565092,13.181948358954072,26.040764215534125,48.38385054059318,62.581383175458782,89.539568879069222,95.086471713661027,104.42435896391137,103.71534414602309,108.86735841082131,114.93938130296313,111.04444878977215,116.13015250973581,122.80941171751721,113.08436468302787,109.92901817158979,93.044673577940131,75.849376028868306,53.813025127303582,25.520907119883908,-11.176974890442089,-30.631319754293532,-57.704238742657608,-73.200660405065804,-93.32931307569109,-105.53163668034811,-115.43270474031918,-114.62389537343741,-118.88839385394618],"y":[-25.553964844544364,-20.048987953408528,-11.425826257674446,-19.486483537471152,-20.10962708003926,-17.022075871267695,-28.530539011999888,-32.47785464128448,-32.325135002879904,-44.222108372342447,-46.824141379264653,-46.370509793454147,-46.83924999168854,-51.959281515354839,-52.843841035809128,-56.37551025847943,-57.612486252918544,-51.633437620584196,-40.162851166648345,-34.952675916336489,-23.284501192419388,-9.8239108000794602,-8.8897591947452135,-5.2198663883084926,11.486255953390298,1.7778717780082562,16.096362438318639,35.427468680521656,40.582476422727957,50.420036921733946,59.013399718664935,74.393281129716726,63.39659789470462,73.194222502881644,58.409885154441284,63.603113028273981,47.371368531487981,46.605771758228151,38.585874203886945,35.249471757679736,33.184586389550482,35.196580814785811],"z":[-31.311178516355241,-43.876284427365057,-39.555103397089695,-46.634090506847166,-32.689733956955898,-33.848525223745234,-15.067595685338642,-12.021023245801985,-5.1960678911191174,4.0705578562308204,8.062936289378781,18.051669200368927,14.290119519235059,23.814592153094445,19.495696880875009,24.899256352443906,29.005410508441905,18.57344581646765,9.7769250516552066,1.946641555271706,2.6289016154494198,7.9263532991043864,-2.6611226139750301,0.55587268222926922,-0.93493057042109773,-8.0632472383014147,-14.0135932190249,-13.699075032790903,-14.226651223808627,-10.877101998452417,-12.250031352915514,-11.839018533221839,-6.6917644979668953,3.2663921919153038,11.375249075342174,14.325495988046804,25.11709378450831,29.470824297890207,31.612109579176199,25.527497510211347,20.034127834769912,11.628970089390023],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(252,141,98,1)","line":{"color":"rgba(252,141,98,1)"}},"textfont":{"color":"rgba(252,141,98,1)"},"error_y":{"color":"rgba(252,141,98,1)"},"error_x":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"frame":null},{"x":[-111.26539018406078,-104.91497704668963,-100.50841871612617,-92.295578531300265,-96.350915773974833,-90.744184956481902,-97.502417696100011,-91.303756617613516,-84.286372738725277,-87.639696426232135,-67.280170068012794,-60.679805811287906,-40.491591414835995,-19.293555924194013,4.2391507246281366,33.458996308492551,54.362805988627436,81.404905763452803,96.871839237069764,118.68356042416606,131.24644793811294,134.40023764565947,136.87292611161743,147.95530672485154,151.03068387959237,156.24448939639731,160.10492148144687,155.22176842890261,138.63752205505884,124.74160895759455,103.60558693060513,68.183497118804169,35.165244462326633,-8.0432846724531224,-41.910483177816353,-63.423354917767888,-91.197344315759523,-108.64241638810458,-132.38500033195723,-136.53885660040837,-151.7778654346931,-153.95606183281163],"y":[-22.606993430686838,-24.611347252592793,-22.315217986221207,-28.418864257170405,-27.19272414433998,-32.749926580878963,-33.961876801563974,-36.412447668611854,-33.165907291771013,-40.840871113865319,-41.45629155747352,-45.819596883657951,-51.591555231538429,-52.838407703482851,-55.105920510055036,-52.430689690851743,-46.896893445344446,-53.250775720584684,-38.701865720378791,-40.486566864379029,-31.174809992395414,-17.886246944290477,-14.602371726058911,-3.302160896402933,-0.51348149431290313,8.2922108516756499,16.084487822029708,23.961433533265147,33.942085941902384,45.006799855964971,62.20750267532582,73.505840777082753,78.060011638001868,77.948771676411027,80.270970099261007,70.933696973243258,62.818095777730399,56.131811796930236,49.480839317481703,46.779911922249163,32.659875950124537,30.249464300229963],"z":[-29.642668829596335,-35.659967255173981,-37.21083253072154,-37.516055699276791,-37.137884420997736,-28.405006561999457,-28.135497707412686,-23.470018424973411,-14.618954506216081,-10.460683941816692,-9.9897898004990484,-6.5551186771067025,9.7608286918365668,27.23867798369664,34.822109136163519,35.712426721055721,38.719577956568607,33.924360462640067,27.498233841657239,18.819755374841627,15.031769726759704,33.940333968917002,3.4516065220010019,5.334113421335072,-12.796557086125208,-21.520737005042541,-28.799484756071404,-25.756464249513648,-20.998074073699684,-22.086348408354656,-23.644683950904525,-12.647651392727978,-14.508727184403231,4.3779840946071751,14.957027644624491,8.8563725949143226,27.672535575387286,27.356548527732315,31.109326521659277,26.331468434357248,28.512127965084762,28.134021296793559],"mode":"markers","type":"scatter3d","name":"med_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
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
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-21757a29966a5c959415" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-21757a29966a5c959415">{"x":{"visdat":{"a6b271481220":["function () ","plotlyVisDat"]},"cur_data":"a6b271481220","attrs":{"a6b271481220":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-108.77076486001364,-104.71646387442763,-111.58460688145847,-110.47682825786828,-110.46368465327032,-108.16373179917491,-104.14147977674595,-100.59210001588114,-92.142085518682705,-87.813072744695035,-74.50360409989743,-70.971234626279383,-53.780604716959246,-29.604131079687271,1.5146654719951467,27.577029761693574,57.771653115301262,79.185033627509085,109.3081510494796,127.12235633554464,148.5206719947993,165.8009597273506,172.28776399160924,171.39468928689877,172.91354105094732,174.72473099136104,164.59619579035987,162.27019765653282,149.01640097316559,128.12118685819564,98.476812142079538,77.238221150946785,38.627940717696966,2.5801012856417782,-34.013589832838285,-68.941280868024776,-103.99836697356388,-120.95930640290283,-146.24607259755857,-154.01801499090803,-162.01381345224362,-171.13346495602704],"y":[-34.119040143776282,-29.582834896674719,-32.519823024483657,-38.797886857952783,-50.974853725492544,-47.939561189041235,-67.30218293215394,-56.156953745152855,-60.818659792519007,-65.882237709363963,-60.883380069643394,-57.939821500034775,-56.423367485574332,-55.011328520655503,-51.399572589020693,-59.908982808810059,-56.441524331317261,-59.521450659419337,-42.005067136040999,-38.818548352253949,-29.399777472819856,-19.514342480950628,-25.662334295525334,-3.8083996220046945,8.3079259652662643,15.504578714730018,22.545608193928143,27.932773442609694,49.033606480887386,52.537332347190038,67.102369888336312,62.574040401694809,76.90920059888451,84.277449134855061,92.693549045156558,98.076887000730267,83.95835322294613,85.82877861189742,79.814774579012308,73.802367335924203,59.514940608423004,60.417395768209651],"z":[-18.306930465346941,-24.426138629846186,-28.139683704834724,-33.88771137386972,-36.90750778792399,-31.526462265551739,-47.308783768776593,-31.487320106662139,-26.561350859657068,-15.414942663347697,-2.5209230631144743,7.5224884205753764,13.386677775236816,26.458149374816852,34.327401732356861,38.713758857404564,37.302818394862385,35.698438501670203,37.412252950794333,33.541180008980966,28.622170482012404,19.176434177299392,17.840747712524823,8.9194845541819081,15.540283209180329,-10.733244384921965,-21.421675475804815,-39.19215409669787,-29.227108578051254,-31.576715433530673,-37.988448503696162,-39.346163061188399,-28.292718677615408,-22.3823935432968,-4.5980733432956846,1.117866966494812,24.917005793922662,30.935942191993771,38.063177589559444,32.111694579899712,38.074234330625309,41.564242182637535],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-84.534868192994281,-84.590932375650397,-76.434796710677233,-77.819912596654191,-81.111213330730394,-79.659402273631088,-78.909628018186496,-70.430749042876968,-66.880556316369379,-54.837661275189539,-42.453594911488082,-36.530667950808251,-27.170381938614138,-6.1023049825565092,13.181948358954072,26.040764215534125,48.38385054059318,62.581383175458782,89.539568879069222,95.086471713661027,104.42435896391137,103.71534414602309,108.86735841082131,114.93938130296313,111.04444878977215,116.13015250973581,122.80941171751721,113.08436468302787,109.92901817158979,93.044673577940131,75.849376028868306,53.813025127303582,25.520907119883908,-11.176974890442089,-30.631319754293532,-57.704238742657608,-73.200660405065804,-93.32931307569109,-105.53163668034811,-115.43270474031918,-114.62389537343741,-118.88839385394618],"y":[-25.553964844544364,-20.048987953408528,-11.425826257674446,-19.486483537471152,-20.10962708003926,-17.022075871267695,-28.530539011999888,-32.47785464128448,-32.325135002879904,-44.222108372342447,-46.824141379264653,-46.370509793454147,-46.83924999168854,-51.959281515354839,-52.843841035809128,-56.37551025847943,-57.612486252918544,-51.633437620584196,-40.162851166648345,-34.952675916336489,-23.284501192419388,-9.8239108000794602,-8.8897591947452135,-5.2198663883084926,11.486255953390298,1.7778717780082562,16.096362438318639,35.427468680521656,40.582476422727957,50.420036921733946,59.013399718664935,74.393281129716726,63.39659789470462,73.194222502881644,58.409885154441284,63.603113028273981,47.371368531487981,46.605771758228151,38.585874203886945,35.249471757679736,33.184586389550482,35.196580814785811],"z":[-31.311178516355241,-43.876284427365057,-39.555103397089695,-46.634090506847166,-32.689733956955898,-33.848525223745234,-15.067595685338642,-12.021023245801985,-5.1960678911191174,4.0705578562308204,8.062936289378781,18.051669200368927,14.290119519235059,23.814592153094445,19.495696880875009,24.899256352443906,29.005410508441905,18.57344581646765,9.7769250516552066,1.946641555271706,2.6289016154494198,7.9263532991043864,-2.6611226139750301,0.55587268222926922,-0.93493057042109773,-8.0632472383014147,-14.0135932190249,-13.699075032790903,-14.226651223808627,-10.877101998452417,-12.250031352915514,-11.839018533221839,-6.6917644979668953,3.2663921919153038,11.375249075342174,14.325495988046804,25.11709378450831,29.470824297890207,31.612109579176199,25.527497510211347,20.034127834769912,11.628970089390023],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-7-2.png" width="672" />



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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-8-1.png" width="672" />

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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-9-1.png" width="672" />



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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-10-1.png" width="672" />

## taskwise cue effect

```r
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
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax = (.data[[mean]] + : Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
## Ignoring unknown aesthetics: fill
```

```r
  # --------------------------- plot three tasks -------------------------------
library(gridExtra)
plot_list <- lapply(plot_list, function(plot) {
  plot + theme(plot.margin = margin(5, 5, 5, 5))  # Adjust plot margins if needed
})
combined_plot <- ggpubr::ggarrange(plot_list[["pain"]],plot_list[["vicarious"]],plot_list[["cognitive"]],
                  common.legend = TRUE,legend = "bottom", ncol = 3, nrow = 1, 
                  widths = c(3, 3, 3), heights = c(.5,.5,.5), align = "v")
combined_plot
```

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-11-1.png" width="672" />

```r
ggsave(file.path(save_dir, "taskwise_epoch-stim_desc-highcueGTlowcue.png"), combined_plot, width = 12, height = 4)
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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-13-1.png" width="672" />

```r
p3H + theme_classic()
```

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-13-2.png" width="672" />


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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-14-1.png" width="672" />

```r
p3M + theme_classic()
```

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-14-2.png" width="672" />


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

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-15-1.png" width="672" />

```r
p3L + theme_classic()
```

<img src="50_iv-6cond_dv-firglasserSPM_ttl2_rINS_files/figure-html/unnamed-chunk-15-2.png" width="672" />



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






# 48_iv-cue-stim_dv-firglasserSPM_ttl2 {#ch48_timeseries}

<!-- title: "48_iv-cue-stim_dv-firglasserSPM_ttl2" -->
<!-- output: html_document -->
<!-- date: "2023-08-13" -->



## load tsv
## concatenate 
## per time column, calculate mean and variance
## plot




## function

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
      theme(
        legend.position = c(.99, .99),
        legend.justification = c("right", "top"),
        legend.box.just = "right",
        legend.margin = margin(6, 6, 6, 6),
        legend.key = element_rect(fill = "white", colour = "white")
      ) 
    
    return(g)
  }
```

## parameters {TODO: ignore}

```r
# parameters
main_dir <- dirname(dirname(getwd()))
datadir <- file.path(main_dir, 'analysis/fmri/spm/fir/ttl2')
analysis_folder  = paste0("model48_iv-cue-stim_dv-firglasserSPM_ttl2")
analysis_dir <-
  file.path(main_dir,
            "analysis",
            "mixedeffect",
            analysis_folder,
            as.character(Sys.Date())) # nolint
dir.create(analysis_dir,
           showWarnings = FALSE,
           recursive = TRUE)
savedir <- analysis_dir
```


## epoch: stim, high stim vs low stim

```r
# ------------------------------------------------------------------------------
#                       epoch stim, high stim vs low stim
# ------------------------------------------------------------------------------
datadir = "/Volumes/spacetop_projects_cue/analysis/fmri/spm/fir/ttl2"
taskname = "pain"
exclude <- "sub-0001"
filename <- paste0("sub-*_runtype-", taskname, "*roi-MT_tr-42.csv")
common_path <- Sys.glob(file.path(datadir, "sub-*",  filename  ))
filter_path <- common_path[!str_detect(common_path, pattern = exclude)]

df <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
    read.table(files, header = TRUE, sep = ",")
    }))
```



```r
# filtered_df <- subset(df, condition != "rating")
filtered_df <- df[!(df$condition == "rating" | df$condition == "cue"), ]

parsed_df <- filtered_df %>%
  separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE)
```



```r
TR_length <- 42
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
                                      c("sub", "tr_ordered", "stim_ordered"), "tr_value")
groupwise <- summarySEwithin(
  data = subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c("stim_ordered", "tr_ordered"),
  idvar = "sub"
)
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

```r
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402

# --------------------------------- plot ---------------------------------------
LINEIV1 = "tr_ordered"
LINEIV2 = "stim_ordered"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
sorted_indices <- order(groupwise$tr_ordered)
groupwise_sorted <- groupwise[sorted_indices, ]
p1 = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High stim vs. Low stim", ggtitle="time_series", color=c("#5f0f40","#ae2012", "#fcbf49"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p1 + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-5-1.png" width="672" />







### PCA subjectwise

```r
# install.packages("ggplot2")    # Install ggplot2 if you haven't already
# install.packages("FactoMineR") # Install FactoMineR if you haven't already
library(ggplot2)
library(FactoMineR)



# Assuming your original dataframe is named 'df'

# Convert the dataframe to wide format
df_wide <- pivot_wider(subjectwise, 
                       id_cols = c("tr_ordered", "stim_ordered"), 
                       names_from = "sub", 
                       values_from = "mean_per_sub")

df_wide <- pivot_wider(subjectwise, 
                       id_cols = c("sub", "stim_ordered"), 
                       names_from = "tr_ordered", 
                       values_from = "mean_per_sub")
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
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-6-1.png" width="672" />

```r
# Access the standard deviations of each principal component
high.stdev <- high.pca_result$sdev

meanlowdf <- data.frame(subset(stim_low.df, select = 3:(ncol(stim_low.df) - 1)))
low.pca <- prcomp(meanlowdf)
low.pca_scores <- as.data.frame(low.pca$x)
library(plotly)  # You can use plotly to create an interactive 3D plot
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

```r
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
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-09379bcdc9a161031529" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-09379bcdc9a161031529">{"x":{"visdat":{"7e9a2ad13eee":["function () ","plotlyVisDat"]},"cur_data":"7e9a2ad13eee","attrs":{"7e9a2ad13eee":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[68.542627053624969,-66.612485700276352,66.722434567546586,-37.575867824107775,33.066910825189531,35.706202717665619,21.622089825739767,38.779111991850364,89.717712630988814,17.231195927731683,19.810635455600138,26.237241765625011,-7.2277429833612326,-3.5205859094012646,-33.861484339167227,-49.89654509636393,-36.122156186878264,4.4905149134325786,20.197606122998867,-34.415106065646256,-174.02496857510963,17.854650944154905,-74.082802217338838,-20.36942697090991,5.1149406540875306,79.045646609225486,-2.8245390259252381,-51.625443008697481,48.019631897721588],"y":[-7.7781063409438405,-43.482841633901984,6.5155475461756112,3.4630621047367875,-57.846840632297976,20.640562806149969,37.443405566247378,-17.333305084976001,-13.53977502946417,-18.265864079989655,19.924968001659373,17.958336065916622,16.658291030224071,-22.170535911506711,11.265319819340768,-16.76172727535382,43.211722884926161,-37.471859281110774,-14.135032123954183,-0.23733943833531271,4.8785755313155432,49.401254180497411,17.712630204799027,-32.660770299715224,13.436580164886186,13.399177466579944,1.3065147039905194,0.9725136038570027,3.4955354502472242],"z":[-21.660375233808242,-4.2269391723997423,4.1450946558817021,39.949986712355631,-14.177755884524409,0.47054135558255944,4.6205149073123115,14.938180166378725,4.468829121184994,23.044501402066171,4.8019253709578908,2.3977874926525757,24.254731585624761,4.8744735634862435,0.98792132370391106,5.4663218782996372,21.644986788321837,-31.460967822117382,-6.7398857018142007,0.67398505900715977,-36.200699566590039,-55.299572545175359,3.5088507841757517,15.202677869167909,12.130683614522008,-9.080887676252944,-10.782326920484081,13.952492646208501,-11.905075773723851],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[43.6574481363891,-111.4783178970458,36.208797174082605,-74.640821214501429,33.500471069937767,75.271783219310009,-33.846599291226873,85.061170970535613,32.187726951800798,45.331663915658119,4.1782788678214642,6.1021984654389749,30.650743462254766,-2.5822213699033552,-1.3196503615874455,28.007585413825769,11.991411310790598,28.965515265739665,26.558921508011849,-24.138599629255353,-174.66457029693967,-26.185100825680639,-51.300783847538817,29.490935860879045,-6.75080205753817,27.038197255478867,-30.581499737676999,-25.416310571140581,18.702428252080114],"y":[-44.367144318897715,-37.046506029744684,-7.4567201617254417,10.309614872009963,-30.171427233680188,12.395362780966581,-14.007555607634943,17.571373061559353,-20.347735502706122,0.27399611886685044,-2.9568949071771757,-1.920558716491005,-6.5159093724361634,24.638679152089441,-19.114803303656561,-3.7654383956231516,1.9706248445502175,-2.5618312758382085,-2.1326114325043961,17.975276664064662,10.32389011472825,-35.4793862974444,29.735743516255667,54.301807847165534,-25.195379045261507,42.9056628549097,49.100569987676458,4.0392275127483135,-22.501927726769352],"z":[-19.308719059795084,26.048688180542957,30.134103361484584,-22.729914157340104,-14.578778553666581,-3.8212628869807541,22.818921287494021,-6.9526025167740677,9.5890960629558375,28.573577390853053,3.1500214628611971,0.27942785965050349,1.1449227425842261,-9.8900772073530536,-5.3526806671646758,-16.361762370486854,6.1517276634910365,-39.602151136669399,-15.717376694330266,12.758511033919435,-24.213750544540101,-7.595762090604353,3.0426843356592714,34.157578609451441,15.052207134867587,-35.848899406377512,11.439165100219242,11.765618384985563,5.8674866810628572],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

```r
# data_matrix <- groupwise[groupwise$stim_ordered == "high_stim",c("tr_ordered", "mean_per_sub_norm_mean")]
# sorted_indices <- order(data_matrix$tr_ordered)
# df_ordered <- data_matrix[sorted_indices, ]
# pca_result <- PCA(data_matrix$mean_per_sub_norm_mean)
# datapoints <- df$datapoints
```

### PCA subjectwise try 2

```r
# Load necessary library for PCA
# library(prcomp)

# __________________________________ high stim PCA _____________________________
# Assuming your data is stored in the 'stim_high.df' dataframe
# Extract the relevant columns for PCA
column_names <- paste0("tr", 1:42)
highdf.pca <- stim_high.df[, c(column_names)]
# Perform PCA
high.pca_result <- prcomp(highdf.pca, scale. = TRUE)  # 'scale.' parameter scales the data
high.pca_scores <- as.data.frame(high.pca_result$x)
# Access the proportion of variance explained by each principal component
high.variance_explained <- high.pca_result$sdev^2 / sum(high.pca_result$sdev^2)
plot(high.variance_explained)
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-7-1.png" width="672" />

```r
# Extract the top PCs and their loadings
N = 3
high.top_pcs <- high.pca_result$rotation[, 1:N]  # N is the number of top PCs you want to keep

# Extract the data points for subjects (sub) - assuming it's numeric data
subject_data <- stim_high.df$sub
# Perform subspace mapping for each data point
high.subspace_mapped_data <- matrix(NA, nrow = length(subject_data), ncol = N)  # N is the number of top PCs
for (i in 1:length(subject_data)) {
  pc_loadings <- highdf.pca[i, ]  # PC loadings for this subject
  mapped_point <- as.numeric(pc_loadings) %*% high.top_pcs  # Perform matrix multiplication for mapping
  high.subspace_mapped_data[i, ] <- mapped_point
}
high.subspace <- as.data.frame(high.subspace_mapped_data)
high.subspace$stim <- "high_stim"
# high.top_pcs$stim <- "high"
# You can now use 'subspace_mapped_data' for further analysis or visualization



# __________________________________ med stim PCA _____________________________
# Assuming your data is stored in the 'stim_high.df' dataframe
# Extract the relevant columns for PCA
column_names <- paste0("tr", 1:42)
meddf.pca <- stim_med.df[, c(column_names)]
# Perform PCA
med.pca_result <- prcomp(meddf.pca, scale. = TRUE)  # 'scale.' parameter scales the data
med.pca_scores <- as.data.frame(med.pca_result$x)
# Access the proportion of variance explained by each principal component
med.variance_explained <- med.pca_result$sdev^2 / sum(med.pca_result$sdev^2)
plot(med.variance_explained)
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-7-2.png" width="672" />

```r
# Extract the top PCs and their loadings
N = 3
med.top_pcs <- med.pca_result$rotation[, 1:N]  # N is the number of top PCs you want to keep

# Extract the data points for subjects (sub) - assuming it's numeric data
subject_data <- stim_med.df$sub
# Perform subspace mapping for each data point
med.subspace_mapped_data <- matrix(NA, nrow = length(subject_data), ncol = N)  # N is the number of top PCs
for (i in 1:length(subject_data)) {
  pc_loadings <- meddf.pca[i, ]  # PC loadings for this subject
  mapped_point <- as.numeric(pc_loadings) %*% med.top_pcs  # Perform matrix multiplication for mapping
  med.subspace_mapped_data[i, ] <- mapped_point
}
med.subspace <- as.data.frame(med.subspace_mapped_data)
med.subspace$stim <- "med_stim"


# __________________________________ low stim PCA _____________________________
# Assuming your data is stored in the 'stim_high.df' dataframe
# Extract the relevant columns for PCA
column_names <- paste0("tr", 1:42)
lowdf.pca <- stim_low.df[, c(column_names)]
# Perform PCA
low.pca_result <- prcomp(lowdf.pca, scale. = TRUE)  # 'scale.' parameter scales the data
low.pca_scores <- as.data.frame(low.pca_result$x)
# Access the proportion of variance explained by each principal component
low.variance_explained <- low.pca_result$sdev^2 / sum(low.pca_result$sdev^2)
plot(low.variance_explained)
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-7-3.png" width="672" />

```r
# Extract the top PCs and their loadings
N = 3
low.top_pcs <- low.pca_result$rotation[, 1:N]  # N is the number of top PCs you want to keep

# Extract the data points for subjects (sub) - assuming it's numeric data
subject_data <- stim_low.df$sub
# Perform subspace mapping for each data point
low.subspace_mapped_data <- matrix(NA, nrow = length(subject_data), ncol = N)  # N is the number of top PCs
for (i in 1:length(subject_data)) {
  pc_loadings <- lowdf.pca[i, ]  # PC loadings for this subject
  mapped_point <- as.numeric(pc_loadings) %*% low.top_pcs  # Perform matrix multiplication for mapping
  low.subspace_mapped_data[i, ] <- mapped_point
}
low.subspace <- as.data.frame(low.subspace_mapped_data)
low.subspace$stim <- "low_stim"



high <- as.data.frame(high.top_pcs)
med <- as.data.frame(med.top_pcs)
low <- as.data.frame(low.top_pcs)
high <- rownames_to_column(high, var = "tr")
med <- rownames_to_column(med, var = "tr")
low <- rownames_to_column(low, var = "tr")

high$stim <- "high"
med$stim <- "med"
low$stim <- "low"
subspace <- rbind(high.subspace, med.subspace, low.subspace)

top_pcs <- rbind(low, med, high)
```

```r
# Load necessary library for interactive plotting
library(plotly)

# Assuming you have already calculated the subspace_mapped_data

# Create an interactive 3D scatter plot using plot_ly
plot_ly(data = as.data.frame(subspace), 
        x = ~V1, y = ~V2, z = ~V3, 
        type = "scatter3d", mode = "markers",
        #color = ~stim_ordered,
        marker = list(size = 5)) %>%
        # text = ~paste("Subject: ", stim_high.df$sub, "<br>Stim Ordered: ", stim_ordered)) %>%
  layout(scene = list(
    xaxis = list(title = "PC1"),
    yaxis = list(title = "PC2"),
    zaxis = list(title = "PC3")
  ))
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-c9e29e95111856132c98" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-c9e29e95111856132c98">{"x":{"visdat":{"7e9a3e229fea":["function () ","plotlyVisDat"]},"cur_data":"7e9a3e229fea","attrs":{"7e9a3e229fea":{"x":{},"y":{},"z":{},"mode":"markers","marker":{"size":5},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":false},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[50.100666281082383,-67.715337461759333,38.073274100315395,-65.265669570872717,30.124291725022815,7.8625204911148474,-15.772535358829758,18.031697233393636,65.011919639749763,-3.2295736775751633,-8.2051650306536548,-1.2172956256501994,-36.233483010715062,-16.86601390722468,-55.619091894861526,-62.819914115018641,-69.873949273987847,-0.80572836338257603,3.3598949052569194,-52.227135309385879,-174.08819671828576,-5.8727990832884247,-93.939250060091382,-36.448256293163517,-23.738596607265784,49.118428905315774,-19.923285356860852,-73.374229212421653,26.661962921564406,-12.726797477785354,-82.986963018017278,12.489772613340305,-137.2870690735956,-5.4480772325109657,25.778925329331166,8.2168839225123023,32.609444839405064,2.8773892136069832,7.9133188016032801,-0.24309005007726076,1.5492029821283972,-1.1729917803770307,-4.5595185037344654,-23.533843890291525,-50.687278461275277,-43.339460846133726,17.051382790352381,16.225608102912357,-58.184931056467583,-194.15951756839863,23.363903825525917,-63.314483741948955,-10.59472518508551,-45.634207386662453,56.171112931078909,-84.25380461379153,-22.776132581980018,29.512633609991454,44.251602138507131,-117.92231438456359,23.12487365096969,-68.798641920361135,30.574710310051845,66.619409325004298,-46.335335138230811,78.313519316476587,23.385135753491575,32.59521776896343,-2.3289183665068238,0.57762463597827562,24.16137084439378,-5.962619088894872,-2.9464362999425755,29.565986051120252,6.0483031301730783,29.724617250055225,26.098019693065474,-31.559913495890722,-164.86120190691818,-27.740928048302024,-54.365573045350921,15.385418728187043,-15.033461536282161,26.699021816769978,-39.630677680728432,-33.470124375634207,12.716891552049615],"y":[-24.129546133672527,-87.34487800543306,-6.5349524454833077,-42.021924908053336,-71.135053341970007,6.543256755164256,-1.2999971027046264,-34.315212749488389,-23.065080388250877,-43.702610572305893,-2.9245352935326463,-3.5980920048743861,-14.793461446943336,-46.047186370967694,-27.100789697333674,-54.826089446446709,0.61856060745626895,-57.870974607231176,-40.085163132431916,-40.249698242244257,-61.557340519528957,28.70098690108145,-27.472672295369158,-78.805207892252355,-17.379194282480068,3.4971421977907142,-27.340226234268755,-54.081509608308046,-8.3584162203239565,4.0152748731898793,45.738690530170942,12.922945264851032,23.879060915467786,8.6414395025259036,-13.913595855874334,-8.7597141410707149,42.195408605356647,-7.9150945857123478,12.465711161631924,-4.8258868170825417,4.6059498867676085,-0.13857791455294816,-6.4976319204096402,24.682447808708886,24.920803479491113,-20.554856146069383,-7.8163594695674048,27.766415451691181,25.745930531797768,59.208902210325839,8.8948350992806429,20.254759729292847,13.882407824015184,-62.056643785251936,9.9366248312532672,25.684812168427655,13.312487057015005,-14.819299471150758,-39.792561684468929,-34.930047928219693,-17.72799652197536,-2.4599856610090662,-27.260935858896179,16.080522784566117,-4.03389188383297,15.788021214434783,-19.355265997384411,-15.869653781798432,0.34511763151391039,0.82515774661239349,-6.5092425547503741,23.33959637351813,-23.868501233069434,-12.51261769563793,-13.027395526448785,17.274053810244975,-3.3140064366015634,10.222788952792794,4.224841102054997,-27.928348159166937,14.593001754250263,30.284115817067455,-26.379708585859284,55.647765802701535,45.348713203672126,4.5492374184764213,-22.643863473350198],"z":[-10.119653755248871,35.283919191749632,-7.7436170726299078,-22.0118204439237,17.258718892914167,20.395210767814632,-19.292828313884101,-1.842077623809049,-16.917421842101724,-4.153232464746142,3.8292082894292623,2.8823818630627018,-6.9364591231874622,15.762562820065794,11.406649891074466,22.968454624011425,7.3434202776283328,48.33266715015872,7.6525489100604824,14.951592658685261,80.613591545135577,29.213401536166394,27.214385109557728,-12.685199607899548,-16.721209952655141,-3.8594846886102343,20.222602999844515,-1.6039830090140728,9.6169216466645953,-16.975989373299715,3.9373929699544985,-3.6425070226243612,-2.3497859727949004,-17.546401693658176,11.102013549537174,-13.76262776312209,-0.48762206686197546,7.028838486222905,-36.721657492586701,3.2364921635250816,0.27266021592829442,-22.300827602597035,1.5365789965035637,-37.7479761345041,-2.4009640572126845,-15.753577879841998,20.589181498235824,-9.8975389818835229,-39.10157499171585,-10.131769002824251,-22.103715454755157,22.336548716683151,-47.87263478017676,-6.8823997764144567,25.854727080343739,7.3378325553781849,-27.741356227279585,-24.517476672517628,16.504252123893522,12.576423084658252,-32.221072423279821,43.282039442456494,21.167422203121038,-14.120163955697373,-7.7048297029160162,-16.482830535771171,-9.6679186374568093,-35.714562199610349,-1.8458092113418236,-0.26274682730184001,-5.6509705271011104,5.4887006382192176,10.166566750974217,10.61810740754977,-1.1106056172771439,35.568572635330078,9.6208656826926227,-6.1204831732622651,63.454480610165639,21.403171721039001,8.0471935407375028,-43.246913586745322,-4.265039689736982,17.159920106974685,-12.908547299327539,-5.8222417255137326,-3.0902267048663106],"mode":"markers","marker":{"color":"rgba(31,119,180,1)","size":5,"line":{"color":"rgba(31,119,180,1)"}},"type":"scatter3d","error_y":{"color":"rgba(31,119,180,1)"},"error_x":{"color":"rgba(31,119,180,1)"},"line":{"color":"rgba(31,119,180,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```

```r
sorted_top_pcs <- top_pcs[order(top_pcs$tr), ]

scatter_plot <- plot_ly(data = as.data.frame(sorted_top_pcs), 
        x = ~PC1, y = ~PC2, z = ~PC3, 
        type = "scatter3d", mode = "markers",
        color = ~stim,
        marker = list(size = 5)) 
        # text = ~paste("Subject: ", stim_high.df$sub, "<br>Stim Ordered: ", stim_ordered)) %>%
lines_x <- c(sorted_top_pcs$PC1, NA)
lines_y <- c(sorted_top_pcs$PC2, NA)
lines_z <- c(sorted_top_pcs$PC3, NA)
line_trace <- add_trace(scatter_plot, 
                        x = lines_x, y = lines_y, z = lines_z,
                        type = "scatter3d", mode = "lines",
                        line = list(color = "black"))

# Customize the layout
scatter_plot <- scatter_plot %>% layout(scene = list(
  xaxis = list(title = "PC1"),
  yaxis = list(title = "PC2"),
  zaxis = list(title = "PC3")
))

scatter_plot
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-2e654b90a1cbc34848ba" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-2e654b90a1cbc34848ba">{"x":{"visdat":{"7e9a5330db84":["function () ","plotlyVisDat"]},"cur_data":"7e9a5330db84","attrs":{"7e9a5330db84":{"x":{},"y":{},"z":{},"mode":"markers","marker":{"size":5},"color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-0.062128584236106711,-0.17358961865924005,-0.1777127677019823,-0.17456744984369432,-0.17188877643901637,-0.18302651489163893,-0.18856255330778307,-0.18670557740758142,-0.19670593279339635,-0.19347504499309684,-0.19149067831797273,-0.11252916050557731,-0.18466599332524958,-0.18070596604287967,-0.18257685556141007,-0.17902828902053361,-0.1868716027406008,-0.18111723707018978,-0.18554954410145183,-0.18736476283588183,-0.19111488374076205,-0.18812145736031605,-0.10900809114423425,-0.18324688205936795,-0.16469779833582515,-0.16169565887325574,-0.1513570759977077,-0.13850033674549569,-0.099707846968343269,-0.06571996584536878,-0.042880439190177394,-0.014158909256828918,0.011603137575360004,-0.15380379068802866,0.01379237470743732,0.042506538291141018,0.070742620774720572,-0.15293326298935722,-0.13846004723786409,-0.14478968753809954,-0.17037154374959562,-0.15249020109676056],"y":[0.024529735776120224,0.14263839480353113,0.15141866418538208,0.1464271446758198,0.16481751394353769,0.10444591735859091,0.089380631062243185,0.077480300940620236,-0.00025154790393757087,-0.0085831334748071222,-0.035264571108235672,0.022822642808693467,-0.069397468596995568,-0.087736257504240786,-0.097025377084284201,-0.12312379413675043,-0.1144187853025745,-0.13473652832288552,-0.13196192336053209,-0.13859079733990085,-0.12455759668734138,-0.13990526163418332,0.048594567394789803,-0.12976257079537665,-0.12636967546816458,-0.063114528146051577,0.011774885578182863,0.09346694291147549,0.18725015399593134,0.2331388838491236,0.27582046413396311,0.29419312051849722,0.30004553235838893,0.045071864310736648,0.31280269968153374,0.31607226069429045,0.29426933553395002,0.066530865029175115,0.084861831271565699,0.12278218543734525,0.11465172383306281,0.15626588754607504],"z":[-0.2463312879937776,-0.09339699929272087,-0.097521309506760107,-0.12315568608897369,-0.083753663187434324,-0.056328649792357244,0.0094052361844861026,0.072342996402746801,0.058652882545624098,0.082802155507321534,0.10959800187616776,-0.21729961669037404,0.12173165778613745,0.15135329934421995,0.1461234839747261,0.14184418679132899,0.12966134272407229,0.1482406603999861,0.098761896921322923,0.081867696174457716,0.088569299147640543,0.084556903318224408,-0.29208132623871275,0.072730632475277363,0.06202879860711201,0.03334728452889716,0.0530861987071592,0.08261752713499089,0.15920330515360959,0.22494387087840137,0.20976715796056836,0.22044340737797841,0.17583297735031017,-0.25302808372279689,0.15498108379828585,0.10075571136442331,0.090943299089724428,-0.25385365102398527,-0.26460122466404368,-0.24843786881501317,-0.1899324827358802,-0.16753005881828953],"mode":"markers","marker":{"color":"rgba(102,194,165,1)","size":5,"line":{"color":"rgba(102,194,165,1)"}},"type":"scatter3d","name":"high","textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-0.14202690445231619,-0.17049965554016178,-0.15844030073671464,-0.15884196714718385,-0.1575491344472579,-0.15414534132456345,-0.18474302220378466,-0.18814477657263498,-0.19458549328377261,-0.19259578099966032,-0.19489066331716368,-0.1450723860480759,-0.19365766156726794,-0.1948189750467659,-0.19313873816580726,-0.1941312071771224,-0.19739415449562869,-0.18510075549604663,-0.19315017326391293,-0.18407561539636186,-0.17864378353288338,-0.16119238147479925,-0.15777563102924683,-0.15655095657578894,-0.13408180758643184,-0.14221163118753641,-0.11104927192253398,-0.118418992743445,-0.11957719863268008,-0.085085986012343767,-0.098393463849679411,-0.067930513358168867,-0.029975136324088953,-0.15519586745677813,-0.0067625568301788808,0.011063265086556997,0.019562501658189936,-0.14447820393966634,-0.14045693874540308,-0.15826830421839788,-0.1646565179064042,-0.16576000680794808],"y":[-0.052572604503873792,-0.16813927753586627,-0.18705237004971881,-0.15770166653208581,-0.16092568795708986,-0.14886853825241186,-0.1219771365333851,-0.092978427777282338,-0.082737384832637775,-0.051901503911091863,-0.027618867344371151,-0.078523554996671227,-0.031650721005668202,0.00028048825923970676,-0.023680452891097242,-0.00054560525928194954,0.043331093254750173,0.083296682897590124,0.06345099446113199,0.11034425088536225,0.10059940134299704,0.14356409230979278,-0.030936214773262329,0.12379378444107808,0.15551255955511237,0.18477301981561936,0.23522295837732324,0.27219879707221062,0.26075132448136862,0.28650839551753071,0.26986423055245118,0.27920206807899095,0.22850012011590479,-0.034663873064121255,0.20280970566270762,0.23342232541772473,0.2195394518804408,-0.066976259695359211,-0.079420533953532213,-0.071876836929097951,-0.13517952307829084,-0.16551291505485785],"z":[-0.27668014178930417,-0.064787027332474947,0.041906553348114724,0.12782721027725141,0.14698084771017553,0.17477980859201619,0.11147705971535923,0.16054970012398895,0.13106906989124018,0.1744828132337298,0.15906196804155859,-0.28081999687485354,0.18178825908043714,0.17631252129846187,0.18004166792727097,0.16438193501720944,0.12799373255473734,0.13122928036507756,0.061703593884803912,0.029353826538098177,-0.039678591657049893,-0.021880788374607947,-0.24429838333405923,-0.055787326735467727,-0.10115291451260834,-0.1240527996912946,-0.10771556118310235,-0.066324882042640823,-0.059506209515381006,-0.016995025740497424,0.043299705453647648,0.053586422929675283,0.035270793088643927,-0.26007857018036951,0.061509984070627965,0.010981321250362223,0.046664108661829372,-0.29343407352464534,-0.30065485260921343,-0.28040040253377885,-0.19716384616856555,-0.11474703713392936],"mode":"markers","marker":{"color":"rgba(252,141,98,1)","size":5,"line":{"color":"rgba(252,141,98,1)"}},"type":"scatter3d","name":"low","textfont":{"color":"rgba(252,141,98,1)"},"error_y":{"color":"rgba(252,141,98,1)"},"error_x":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"frame":null},{"x":[-0.0049633258663321148,-0.1202496811455072,-0.15417967928958221,-0.17680143492640024,-0.1871949863023224,-0.19452975752973667,-0.20491785750137098,-0.20284973261214084,-0.2084733427831387,-0.20137839094963467,-0.20565642731221551,-0.0019419504472935596,-0.20845830136884264,-0.20569302581539795,-0.20850879035272296,-0.21175363072597886,-0.2126719836784248,-0.2075820685857255,-0.20615886080774129,-0.20694124188789553,-0.20329695198052555,-0.19828648723986919,0.018791271791885781,-0.18888611531396782,-0.18268985010609071,-0.17810578953252748,-0.1692426218361516,-0.14475714295529321,-0.05725638903100231,-0.048978615901580043,-0.032787311580629502,0.003249172316382872,0.0091081883606554687,-0.070434398667219206,0.027843474185847077,0.060371847215590718,0.066557034063879639,-0.055100988037749342,-0.080228358938716007,-0.094059671278323084,-0.11961910490893254,-0.12555916656540761],"y":[-0.20804321820586583,-0.23778754717318742,-0.18870312325528846,-0.18033484474584349,-0.1283275121117731,-0.077794430152156896,-0.02230119815998605,0.015772176210798055,0.049039687280718669,0.071364626642153914,0.087619908950862635,-0.28336858310311097,0.088796939520606938,0.090396963800790667,0.092046029262140852,0.09326871058586203,0.078028365328129068,0.09542648386140315,0.098618012483976586,0.097106145532933938,0.098624123790891832,0.083209838956224719,-0.26500074724682848,0.051213519830375115,0.052394379091660823,0.049929421882014761,0.025022436383142149,-0.0011258365073442678,-0.027714754981745086,-0.033252918565840409,-0.05492962433515116,-0.078261977957165829,-0.12401678981993408,-0.28010232481130487,-0.13622594684704481,-0.11215952561006545,-0.11146236540914646,-0.29475102218602961,-0.31224488056858724,-0.28177716975255207,-0.27013121424276892,-0.25535404675605927],"z":[-0.058692626659478539,-0.012777778028411291,-0.015382570807490387,-0.034668815045677988,-0.0091133824117790897,0.012960383138611177,0.012606706606551527,-0.0091503581331186922,-0.0080304726547701082,-0.00056748914534807105,0.0018358209742120181,-0.098144219437308958,-0.00065816926304147999,-0.013138821983418598,-0.0064379222495466312,0.010481751230236522,0.013013387697832382,0.001578709922857639,0.01049817677010516,-0.027356053133620557,-0.023990012586678097,-0.015310994818337724,-0.11677024160741999,-0.00026798481896426985,0.020155503844816465,0.063785092401632271,0.10900286950778446,0.21545291586756044,0.30762829967212829,0.34572289698997294,0.35936792133967588,0.34728731588093542,0.33578702365092572,-0.09101631463906916,0.32278813797585459,0.32653913475456409,0.27945296266073644,-0.1093027904867476,-0.066396869381519855,-0.09631548853784766,-0.057075100407615868,-0.058555473774757123],"mode":"markers","marker":{"color":"rgba(141,160,203,1)","size":5,"line":{"color":"rgba(141,160,203,1)"}},"type":"scatter3d","name":"med","textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```


```r
# Assuming 'top_pcs' contains the data for the scatter plot

# Sort the top_pcs dataframe based on the "tr" column
sorted_top_pcs <- top_pcs %>% arrange(tr, stim)

# Create a scatter3d plot for the points
scatter_plot <- plot_ly(data = as.data.frame(sorted_top_pcs), 
                        x = ~PC1, y = ~PC2, z = ~PC3, 
                        type = "scatter3d", mode = "markers",
                        color = ~stim,
                        marker = list(size = 5))

# # Create traces for connecting the dots
# line_traces <- list()
# for (i in 1:(nrow(sorted_top_pcs) - 1)) {
#   x_vals <- c(sorted_top_pcs$PC1[i], sorted_top_pcs$PC1[i + 1], NA)
#   y_vals <- c(sorted_top_pcs$PC2[i], sorted_top_pcs$PC2[i + 1], NA)
#   z_vals <- c(sorted_top_pcs$PC3[i], sorted_top_pcs$PC3[i + 1], NA)
#   line_trace <- add_trace(scatter_plot,
#                           x = x_vals, y = y_vals, z = z_vals,
#                           type = "scatter3d", mode = "lines",
#                           line = list(color = "black"))
#   line_traces <- append(line_traces, list(line_trace))
# }
# 
# # Print the scatter plot with lines connecting the dots
# scatter_plot <- scatter_plot %>% add_trace(data = line_traces)
scatter_plot
```

```{=html}
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-1a3e82b5e798a17d44fe" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-1a3e82b5e798a17d44fe">{"x":{"visdat":{"7e9a2e03e6b2":["function () ","plotlyVisDat"]},"cur_data":"7e9a2e03e6b2","attrs":{"7e9a2e03e6b2":{"x":{},"y":{},"z":{},"mode":"markers","marker":{"size":5},"color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-0.062128584236106711,-0.17358961865924005,-0.1777127677019823,-0.17456744984369432,-0.17188877643901637,-0.18302651489163893,-0.18856255330778307,-0.18670557740758142,-0.19670593279339635,-0.19347504499309684,-0.19149067831797273,-0.11252916050557731,-0.18466599332524958,-0.18070596604287967,-0.18257685556141007,-0.17902828902053361,-0.1868716027406008,-0.18111723707018978,-0.18554954410145183,-0.18736476283588183,-0.19111488374076205,-0.18812145736031605,-0.10900809114423425,-0.18324688205936795,-0.16469779833582515,-0.16169565887325574,-0.1513570759977077,-0.13850033674549569,-0.099707846968343269,-0.06571996584536878,-0.042880439190177394,-0.014158909256828918,0.011603137575360004,-0.15380379068802866,0.01379237470743732,0.042506538291141018,0.070742620774720572,-0.15293326298935722,-0.13846004723786409,-0.14478968753809954,-0.17037154374959562,-0.15249020109676056],"y":[0.024529735776120224,0.14263839480353113,0.15141866418538208,0.1464271446758198,0.16481751394353769,0.10444591735859091,0.089380631062243185,0.077480300940620236,-0.00025154790393757087,-0.0085831334748071222,-0.035264571108235672,0.022822642808693467,-0.069397468596995568,-0.087736257504240786,-0.097025377084284201,-0.12312379413675043,-0.1144187853025745,-0.13473652832288552,-0.13196192336053209,-0.13859079733990085,-0.12455759668734138,-0.13990526163418332,0.048594567394789803,-0.12976257079537665,-0.12636967546816458,-0.063114528146051577,0.011774885578182863,0.09346694291147549,0.18725015399593134,0.2331388838491236,0.27582046413396311,0.29419312051849722,0.30004553235838893,0.045071864310736648,0.31280269968153374,0.31607226069429045,0.29426933553395002,0.066530865029175115,0.084861831271565699,0.12278218543734525,0.11465172383306281,0.15626588754607504],"z":[-0.2463312879937776,-0.09339699929272087,-0.097521309506760107,-0.12315568608897369,-0.083753663187434324,-0.056328649792357244,0.0094052361844861026,0.072342996402746801,0.058652882545624098,0.082802155507321534,0.10959800187616776,-0.21729961669037404,0.12173165778613745,0.15135329934421995,0.1461234839747261,0.14184418679132899,0.12966134272407229,0.1482406603999861,0.098761896921322923,0.081867696174457716,0.088569299147640543,0.084556903318224408,-0.29208132623871275,0.072730632475277363,0.06202879860711201,0.03334728452889716,0.0530861987071592,0.08261752713499089,0.15920330515360959,0.22494387087840137,0.20976715796056836,0.22044340737797841,0.17583297735031017,-0.25302808372279689,0.15498108379828585,0.10075571136442331,0.090943299089724428,-0.25385365102398527,-0.26460122466404368,-0.24843786881501317,-0.1899324827358802,-0.16753005881828953],"mode":"markers","marker":{"color":"rgba(102,194,165,1)","size":5,"line":{"color":"rgba(102,194,165,1)"}},"type":"scatter3d","name":"high","textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[-0.14202690445231619,-0.17049965554016178,-0.15844030073671464,-0.15884196714718385,-0.1575491344472579,-0.15414534132456345,-0.18474302220378466,-0.18814477657263498,-0.19458549328377261,-0.19259578099966032,-0.19489066331716368,-0.1450723860480759,-0.19365766156726794,-0.1948189750467659,-0.19313873816580726,-0.1941312071771224,-0.19739415449562869,-0.18510075549604663,-0.19315017326391293,-0.18407561539636186,-0.17864378353288338,-0.16119238147479925,-0.15777563102924683,-0.15655095657578894,-0.13408180758643184,-0.14221163118753641,-0.11104927192253398,-0.118418992743445,-0.11957719863268008,-0.085085986012343767,-0.098393463849679411,-0.067930513358168867,-0.029975136324088953,-0.15519586745677813,-0.0067625568301788808,0.011063265086556997,0.019562501658189936,-0.14447820393966634,-0.14045693874540308,-0.15826830421839788,-0.1646565179064042,-0.16576000680794808],"y":[-0.052572604503873792,-0.16813927753586627,-0.18705237004971881,-0.15770166653208581,-0.16092568795708986,-0.14886853825241186,-0.1219771365333851,-0.092978427777282338,-0.082737384832637775,-0.051901503911091863,-0.027618867344371151,-0.078523554996671227,-0.031650721005668202,0.00028048825923970676,-0.023680452891097242,-0.00054560525928194954,0.043331093254750173,0.083296682897590124,0.06345099446113199,0.11034425088536225,0.10059940134299704,0.14356409230979278,-0.030936214773262329,0.12379378444107808,0.15551255955511237,0.18477301981561936,0.23522295837732324,0.27219879707221062,0.26075132448136862,0.28650839551753071,0.26986423055245118,0.27920206807899095,0.22850012011590479,-0.034663873064121255,0.20280970566270762,0.23342232541772473,0.2195394518804408,-0.066976259695359211,-0.079420533953532213,-0.071876836929097951,-0.13517952307829084,-0.16551291505485785],"z":[-0.27668014178930417,-0.064787027332474947,0.041906553348114724,0.12782721027725141,0.14698084771017553,0.17477980859201619,0.11147705971535923,0.16054970012398895,0.13106906989124018,0.1744828132337298,0.15906196804155859,-0.28081999687485354,0.18178825908043714,0.17631252129846187,0.18004166792727097,0.16438193501720944,0.12799373255473734,0.13122928036507756,0.061703593884803912,0.029353826538098177,-0.039678591657049893,-0.021880788374607947,-0.24429838333405923,-0.055787326735467727,-0.10115291451260834,-0.1240527996912946,-0.10771556118310235,-0.066324882042640823,-0.059506209515381006,-0.016995025740497424,0.043299705453647648,0.053586422929675283,0.035270793088643927,-0.26007857018036951,0.061509984070627965,0.010981321250362223,0.046664108661829372,-0.29343407352464534,-0.30065485260921343,-0.28040040253377885,-0.19716384616856555,-0.11474703713392936],"mode":"markers","marker":{"color":"rgba(252,141,98,1)","size":5,"line":{"color":"rgba(252,141,98,1)"}},"type":"scatter3d","name":"low","textfont":{"color":"rgba(252,141,98,1)"},"error_y":{"color":"rgba(252,141,98,1)"},"error_x":{"color":"rgba(252,141,98,1)"},"line":{"color":"rgba(252,141,98,1)"},"frame":null},{"x":[-0.0049633258663321148,-0.1202496811455072,-0.15417967928958221,-0.17680143492640024,-0.1871949863023224,-0.19452975752973667,-0.20491785750137098,-0.20284973261214084,-0.2084733427831387,-0.20137839094963467,-0.20565642731221551,-0.0019419504472935596,-0.20845830136884264,-0.20569302581539795,-0.20850879035272296,-0.21175363072597886,-0.2126719836784248,-0.2075820685857255,-0.20615886080774129,-0.20694124188789553,-0.20329695198052555,-0.19828648723986919,0.018791271791885781,-0.18888611531396782,-0.18268985010609071,-0.17810578953252748,-0.1692426218361516,-0.14475714295529321,-0.05725638903100231,-0.048978615901580043,-0.032787311580629502,0.003249172316382872,0.0091081883606554687,-0.070434398667219206,0.027843474185847077,0.060371847215590718,0.066557034063879639,-0.055100988037749342,-0.080228358938716007,-0.094059671278323084,-0.11961910490893254,-0.12555916656540761],"y":[-0.20804321820586583,-0.23778754717318742,-0.18870312325528846,-0.18033484474584349,-0.1283275121117731,-0.077794430152156896,-0.02230119815998605,0.015772176210798055,0.049039687280718669,0.071364626642153914,0.087619908950862635,-0.28336858310311097,0.088796939520606938,0.090396963800790667,0.092046029262140852,0.09326871058586203,0.078028365328129068,0.09542648386140315,0.098618012483976586,0.097106145532933938,0.098624123790891832,0.083209838956224719,-0.26500074724682848,0.051213519830375115,0.052394379091660823,0.049929421882014761,0.025022436383142149,-0.0011258365073442678,-0.027714754981745086,-0.033252918565840409,-0.05492962433515116,-0.078261977957165829,-0.12401678981993408,-0.28010232481130487,-0.13622594684704481,-0.11215952561006545,-0.11146236540914646,-0.29475102218602961,-0.31224488056858724,-0.28177716975255207,-0.27013121424276892,-0.25535404675605927],"z":[-0.058692626659478539,-0.012777778028411291,-0.015382570807490387,-0.034668815045677988,-0.0091133824117790897,0.012960383138611177,0.012606706606551527,-0.0091503581331186922,-0.0080304726547701082,-0.00056748914534807105,0.0018358209742120181,-0.098144219437308958,-0.00065816926304147999,-0.013138821983418598,-0.0064379222495466312,0.010481751230236522,0.013013387697832382,0.001578709922857639,0.01049817677010516,-0.027356053133620557,-0.023990012586678097,-0.015310994818337724,-0.11677024160741999,-0.00026798481896426985,0.020155503844816465,0.063785092401632271,0.10900286950778446,0.21545291586756044,0.30762829967212829,0.34572289698997294,0.35936792133967588,0.34728731588093542,0.33578702365092572,-0.09101631463906916,0.32278813797585459,0.32653913475456409,0.27945296266073644,-0.1093027904867476,-0.066396869381519855,-0.09631548853784766,-0.057075100407615868,-0.058555473774757123],"mode":"markers","marker":{"color":"rgba(141,160,203,1)","size":5,"line":{"color":"rgba(141,160,203,1)"}},"type":"scatter3d","name":"med","textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
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
<div class="plotly html-widget html-fill-item-overflow-hidden html-fill-item" id="htmlwidget-c1bcc8e8dbe80649dbdc" style="width:672px;height:480px;"></div>
<script type="application/json" data-for="htmlwidget-c1bcc8e8dbe80649dbdc">{"x":{"visdat":{"7e9a32ca021e":["function () ","plotlyVisDat"]},"cur_data":"7e9a32ca021e","attrs":{"7e9a32ca021e":{"x":{},"y":{},"z":{},"mode":"markers","color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter3d"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"scene":{"xaxis":{"title":"PC1"},"yaxis":{"title":"PC2"},"zaxis":{"title":"PC3"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[68.542627053624969,-66.612485700276352,66.722434567546586,-37.575867824107775,33.066910825189531,35.706202717665619,21.622089825739767,38.779111991850364,89.717712630988814,17.231195927731683,19.810635455600138,26.237241765625011,-7.2277429833612326,-3.5205859094012646,-33.861484339167227,-49.89654509636393,-36.122156186878264,4.4905149134325786,20.197606122998867,-34.415106065646256,-174.02496857510963,17.854650944154905,-74.082802217338838,-20.36942697090991,5.1149406540875306,79.045646609225486,-2.8245390259252381,-51.625443008697481,48.019631897721588],"y":[-7.7781063409438405,-43.482841633901984,6.5155475461756112,3.4630621047367875,-57.846840632297976,20.640562806149969,37.443405566247378,-17.333305084976001,-13.53977502946417,-18.265864079989655,19.924968001659373,17.958336065916622,16.658291030224071,-22.170535911506711,11.265319819340768,-16.76172727535382,43.211722884926161,-37.471859281110774,-14.135032123954183,-0.23733943833531271,4.8785755313155432,49.401254180497411,17.712630204799027,-32.660770299715224,13.436580164886186,13.399177466579944,1.3065147039905194,0.9725136038570027,3.4955354502472242],"z":[-21.660375233808242,-4.2269391723997423,4.1450946558817021,39.949986712355631,-14.177755884524409,0.47054135558255944,4.6205149073123115,14.938180166378725,4.468829121184994,23.044501402066171,4.8019253709578908,2.3977874926525757,24.254731585624761,4.8744735634862435,0.98792132370391106,5.4663218782996372,21.644986788321837,-31.460967822117382,-6.7398857018142007,0.67398505900715977,-36.200699566590039,-55.299572545175359,3.5088507841757517,15.202677869167909,12.130683614522008,-9.080887676252944,-10.782326920484081,13.952492646208501,-11.905075773723851],"mode":"markers","type":"scatter3d","name":"high_stim","marker":{"color":"rgba(102,194,165,1)","line":{"color":"rgba(102,194,165,1)"}},"textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"frame":null},{"x":[43.6574481363891,-111.4783178970458,36.208797174082605,-74.640821214501429,33.500471069937767,75.271783219310009,-33.846599291226873,85.061170970535613,32.187726951800798,45.331663915658119,4.1782788678214642,6.1021984654389749,30.650743462254766,-2.5822213699033552,-1.3196503615874455,28.007585413825769,11.991411310790598,28.965515265739665,26.558921508011849,-24.138599629255353,-174.66457029693967,-26.185100825680639,-51.300783847538817,29.490935860879045,-6.75080205753817,27.038197255478867,-30.581499737676999,-25.416310571140581,18.702428252080114],"y":[-44.367144318897715,-37.046506029744684,-7.4567201617254417,10.309614872009963,-30.171427233680188,12.395362780966581,-14.007555607634943,17.571373061559353,-20.347735502706122,0.27399611886685044,-2.9568949071771757,-1.920558716491005,-6.5159093724361634,24.638679152089441,-19.114803303656561,-3.7654383956231516,1.9706248445502175,-2.5618312758382085,-2.1326114325043961,17.975276664064662,10.32389011472825,-35.4793862974444,29.735743516255667,54.301807847165534,-25.195379045261507,42.9056628549097,49.100569987676458,4.0392275127483135,-22.501927726769352],"z":[-19.308719059795084,26.048688180542957,30.134103361484584,-22.729914157340104,-14.578778553666581,-3.8212628869807541,22.818921287494021,-6.9526025167740677,9.5890960629558375,28.573577390853053,3.1500214628611971,0.27942785965050349,1.1449227425842261,-9.8900772073530536,-5.3526806671646758,-16.361762370486854,6.1517276634910365,-39.602151136669399,-15.717376694330266,12.758511033919435,-24.213750544540101,-7.595762090604353,3.0426843356592714,34.157578609451441,15.052207134867587,-35.848899406377512,11.439165100219242,11.765618384985563,5.8674866810628572],"mode":"markers","type":"scatter3d","name":"low_stim","marker":{"color":"rgba(141,160,203,1)","line":{"color":"rgba(141,160,203,1)"}},"textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
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

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-10-2.png" width="672" />



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

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-11-1.png" width="672" />

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

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-12-1.png" width="672" />



## epoch: stim, high cue vs low cue


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

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-13-1.png" width="672" />

## rating

```r
# ------------------------------------------------------------------------------
#                       epoch stim, high cue vs low cue
# ------------------------------------------------------------------------------
# --------------------- subset regions based on ROI ----------------------------

# datadir = "/Volumes/spacetop_projects_cue/analysis/fmri/spm/fir/ttl1"
# taskname = "pain"
# exclude <- "sub-0001"
# filename <- paste0("sub-*_runtype-", taskname, "*roi-MT_tr-42.csv")
#   common_path <- Sys.glob(file.path(datadir, "sub-*",  filename
#   ))
#   filter_path <- common_path[!str_detect(common_path, pattern = exclude)]
# 
# df <- do.call("rbind.fill", lapply(filter_path, FUN = function(files) {
#     read.table(files, header = TRUE, sep = ",")
#     }))
parsed_df <- df[(df$condition == "rating"), ]

# parsed_df <- df %>%
#   separate(condition, into = c("cue", "stim"), sep = "_", remove = FALSE)

TR_length <- 42

df_rating <- pivot_longer(parsed_df, cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value")

# ----------------------------- clean factor -----------------------------------
df_rating$tr_ordered <- factor(
        df_rating$tr_num,
        levels = c(paste0("tr", 1:TR_length))
    )
# df_long$cue_ordered <- factor(
#         df_long$cue,
#         levels = c("cueH", "cueL")
#     )

# --------------------------- summary statistics -------------------------------
subjectwise <- meanSummary(df_rating,
                                      c("sub", "tr_ordered"), "tr_value")
groupwise <- summarySEwithin(
  data = subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c( "tr_ordered"),
  idvar = "sub"
)
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402




# Assuming your data frame is named "time_series_data"

# Create the ggplot
gg <- ggplot(groupwise, aes(x = tr_ordered, y = mean_per_sub_norm_mean, group = 1)) +
  geom_line() +
  geom_point() +
  geom_errorbar(aes(ymin = mean_per_sub_norm_mean - se, ymax = mean_per_sub_norm_mean + se), width = 0.2) +
  labs(x = "Time", y = "Amplitude", title = "Time Series Data with Error Bars")
gg <- gg + theme_classic() +       theme(legend.key = element_rect(fill = "white", colour = "white")) +
      theme_bw() 
# Print the ggplot
print(gg)
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-14-1.png" width="672" />


```r
# --------------------------------- plot ---------------------------------------
LINEIV1 = "tr_ordered"
# LINEIV2 = "cue_ordered"
MEAN = "mean_per_sub_norm_mean"
ERROR = "se"
dv_keyword = "actual"
sorted_indices <- order(groupwise$tr_ordered)
groupwise_sorted <- groupwise[sorted_indices, ]
p2 = plot_timeseries_onefactor(groupwise_sorted, 
               LINEIV1,MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle="button presses rating", color="black")
time_points <- seq(1, 0.46 * TR_length, 0.46)
p2 + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-15-1.png" width="672" />

```r
p2 + theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-15-2.png" width="672" />



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
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("High intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")"), color=c("red","#5f0f40","gray", "gray", "gray", "gray"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p3H + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-16-1.png" width="672" />

```r
p3H + theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-16-2.png" width="672" />


```r
p3M = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("High intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")"), color=c("#d6d6d6","#d6d6d6","#bc3908", "#f6aa1c", "gray", "gray"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p3M + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-17-1.png" width="672" />

```r
p3M + theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-17-2.png" width="672" />


```r
p3L = plot_timeseries_bar(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle=paste0("High intensity - Low cue vs. High cue (N = ", unique(groupwise$N), ")"), color=c("#E6E5E3","#E6E5E3","#E6E5E3", "#E6E5E3", "#2541b2", "#00a6fb"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p3L + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-18-1.png" width="672" />

```r
p3L + theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-18-2.png" width="672" />

## test

```r
p3M = plot_timeseries_bar_grayarrange(groupwise, 
               LINEIV1, LINEIV2, MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle="time_series", color=c("#E6E5E3","#E6E5E3","#bc3908", "#f6aa1c", "#E6E5E3", "#E6E5E3"))
```

```
## Warning in geom_errorbar(aes(ymin = (.data[[mean]] - .data[[error]]), ymax =
## (.data[[mean]] + : Ignoring unknown aesthetics: fill
```

```r
time_points <- seq(1, 0.46 * TR_length, 0.46)
p3M + scale_x_discrete(labels = setNames(time_points, colnames(df_long)[7:7+TR_length]))+ theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-19-1.png" width="672" />

```r
p3M + theme_classic()
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-19-2.png" width="672" />



## epoch: cue, high cue vs low cue

```r
# ------------------------------------------------------------------------------
#                       epoch stim, high cue vs low cue
# ------------------------------------------------------------------------------
# --------------------- subset regions based on ROI ----------------------------

parsed_df <- df[(df$condition == "cue"), ]
TR_length <- 42

df_rating <- pivot_longer(parsed_df, cols = starts_with("tr"), names_to = "tr_num", values_to = "tr_value")

# ----------------------------- clean factor -----------------------------------
df_rating$tr_ordered <- factor(
        df_rating$tr_num,
        levels = c(paste0("tr", 1:TR_length))
    )


# --------------------------- summary statistics -------------------------------
subjectwise <- meanSummary(df_rating,
                                      c("sub", "tr_ordered"), "tr_value")
groupwise <- summarySEwithin(
  data = subjectwise,
  measurevar = "mean_per_sub",
  withinvars = c( "tr_ordered"),
  idvar = "sub"
)
groupwise$task <- taskname
# https://stackoverflow.com/questions/29402528/append-data-frames-together-in-a-for-loop/29419402


# Assuming your data frame is named "time_series_data"

# Create the ggplot
# gg <- ggplot(groupwise, aes(x = tr_ordered, y = mean_per_sub_norm_mean, group = 1)) +
#   geom_line() +
#   geom_point() +
#   geom_errorbar(aes(ymin = mean_per_sub_norm_mean - se, ymax = mean_per_sub_norm_mean + se), width = 0.2) +
#   labs(x = "Time", y = "Amplitude", title = "Epoch cue")
# gg <- gg + theme_classic() +       theme(legend.key = element_rect(fill = "white", colour = "white")) +
#       theme_bw() 
# # Print the ggplot
# print(gg)

p3M <- plot_timeseries_onefactor(groupwise, 
               "tr_ordered",  MEAN, ERROR,  xlab = "Runs" , ylab= "Epoch: stimulus, High cue vs. Low cue", ggtitle="time_series", color=c("black"))
p3M
```

<img src="48_iv-6cond_dv-firglasserSPM_ttl2_files/figure-html/unnamed-chunk-20-1.png" width="672" />









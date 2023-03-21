# signature extraction ~ single trial {#singletrial_signature}

```
author: "Heejung Jung"
date: "2023-03-04"
```




## Function {.unlisted .unnumbered}






## Step 1: Common parameters {.unlisted .unnumbered}

```r
# step 1: load data
for (signature_key in c("NPS", "NPSpos", "NPSneg", "VPS", #"VPSnooccip", "ThermalPain", "MechPain", "GeneralAversive", "AversiveVisual"
                        "ZhouVPS", "PINES",  "GSR", "GeuterPaincPDM")) {
  dv_keyword = signature_key
  signature_name = signature_key
  # step 1: common parameters _______
  main_dir <- dirname(dirname(getwd()))
  #signature_key = "NPSpos"
  analysis_folder  = paste0("model35_iv-task-stim_dv-signature")

  sig_name <-
    Sys.glob(file.path(
      main_dir,
      "analysis/fmri/nilearn/signature_extract",
      paste0(
        "signature-",
        signature_key,
        "_sub-all_runtype-pvc_event-stimulus.tsv"
      )
    )) # nolint
  print(sig_name)
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
  
  # step 2: load data
  df = read.csv(sig_name)
  sig_df = df %>% separate(
    singletrial_fname,
    sep = "_",
    c(
      "sub",
      "ses",
      "run",
      "runtype",
      "event",
      "trial",
      "cuetype",
      "stimintensity"
    )
  )
  sig_df = sig_df %>% separate(
    stimintensity,
    into = c(NA, "stimintensity"),
    extra = "drop",
    fill = "left"
  )
  pvc <- simple_contrasts_singletrial(sig_df)
  pvc$task[pvc$runtype == "runtype-pain"] <- "pain"
  pvc$task[pvc$runtype == "runtype-vicarious"] <- "vicarious"
  pvc$task[pvc$runtype == "runtype-cognitive"] <- "cognitive"
  pvc$task <- factor(pvc$task)
  
  
  # step 3: parameters
  
  taskname = "all"
  plot_keyword = "stimulusintensity"
  ggtitle_phrase =  "(3 tasks x 3 stimulus intensity)"
  
  pvc$task = factor(pvc$task)
  plot_keys <- list(
    sub_mean = "mean_per_sub",
    group_mean = "mean_per_sub_norm_mean",
    legend_keyword = "stimulus intensity",
    se = "se",
    subject = "sub",
    ggtitle = paste0(
      str_to_title(signature_key),
      " dot product: ",
      str_to_title(taskname),
      ' ',
      ggtitle_phrase,
      " (N = ",
      length(unique(pvc$sub)),
      ")"
    ),
    title = paste0(
      str_to_title(signature_key),
      " - ",
      str_to_title(plot_keyword)
    ),
    xlab = "",
    ylab = paste(signature_key, " (dot product)"),
    ylim = c(-250, 500)
  )
  
  # step 4: within between summary
  groupwise <- data.frame()
  subjectwise <- data.frame()
  summary <- summary_for_plots_PVC(
    df = pvc,
    # taskname = taskname,
    groupwise_measurevar = plot_keys$sub_mean,
    # "mean_per_sub",
    subject_keyword = plot_keys$subject,
    # "sub",
    model_iv1 =  "task",
    model_iv2 =  "stim_ordered",
    dv = signature_key #"NPSpos"
  )
  subjectwise <<- as.data.frame(summary[[1]])
  groupwise <<- as.data.frame(summary[[2]])
  if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
    plot_keys$color <- c("#1B9E77", "#D95F02", "#D95F02")
  } else {
    plot_keys$color <- c("#4575B4", "#FFA500", "#D73027")
  }
  
  # step 5: plot
  
  iv2 = "stim_ordered"
  iv1 = "task"
  taskname = "all"
  if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
    color <- c("#1B9E77", "#D95F02", "#D95F02")
  } else {
    color <- c("#4575B4", "#FFA500", "#D73027")
  }
  subject_mean <- "mean_per_sub"
  sub_mean = subject_mean
  group_mean <- "mean_per_sub_norm_mean"
  se <- "se"
  ylim <- c(-25, 26)
  subject <- "sub"
  ggtitle_phrase <-  "(3 tasks x 3 stimulus intensity)"
  ggtitle <-
    paste0(
      str_to_title(signature_name),
      " dot product: ",
      str_to_title(taskname),
      ' ',
      ggtitle_phrase,
      " (N = ",
      length(unique(pvc$sub)),
      ")"
    )
  
  title <-
    paste0(str_to_title(dv_keyword),
           " - ",
           str_to_title(plot_keys$legend_keyword))
  xlab <- ""
  plot_keyword = "stimintensity"
  ylab <- paste(signature_name, " (dot product)")
  plot2_savefname <- file.path(
    analysis_dir,
    paste(
      "signature_task-",
      taskname,
      "_event-",
      plot_keyword,
      "_dv-",
      signature_key,
      "_",
      as.character(Sys.Date()),
      ".png",
      sep = ""
    )
  )
  p <- plot_halfrainclouds_twofactor(
    subjectwise,
    groupwise,
    iv1,
    iv2,
    subject_mean,
    group_mean,
    se,
    subject,
    ggtitle,
    title,
    xlab,
    ylab,
    taskname,
    ylim,
    w = 10,
    h = 6,
    dv_keyword,
    color,
    plot2_savefname
  )
  p
}
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-NPS_sub-all_runtype-pvc_event-stimulus.tsv"
```

```
## Warning: Removed 4 rows containing non-finite values (`stat_half_ydensity()`).
```

```
## Warning: Removed 4 rows containing non-finite values (`stat_boxplot()`).
```

```
## Warning: Removed 138 rows containing missing values (`geom_half_violin()`).
```

```
## Warning: Removed 2 rows containing missing values (`geom_line()`).
```

```
## Warning: Removed 4 rows containing missing values (`geom_point()`).
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-NPSpos_sub-all_runtype-pvc_event-stimulus.tsv"
```

```
## Warning: Removed 3 rows containing non-finite values (`stat_half_ydensity()`).
```

```
## Warning: Removed 3 rows containing non-finite values (`stat_boxplot()`).
```

```
## Warning: Removed 109 rows containing missing values (`geom_half_violin()`).
```

```
## Warning: Removed 3 rows containing missing values (`geom_point()`).
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-NPSneg_sub-all_runtype-pvc_event-stimulus.tsv"
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-VPS_sub-all_runtype-pvc_event-stimulus.tsv"
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_half_ydensity()`).
```

```
## Warning: Removed 1 rows containing non-finite values (`stat_boxplot()`).
```

```
## Warning: Removed 119 rows containing missing values (`geom_half_violin()`).
```

```
## Warning: Removed 1 rows containing missing values (`geom_point()`).
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-ZhouVPS_sub-all_runtype-pvc_event-stimulus.tsv"
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-PINES_sub-all_runtype-pvc_event-stimulus.tsv"
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-GSR_sub-all_runtype-pvc_event-stimulus.tsv"
```

```
## [1] "/Users/h/Dropbox (Dartmouth College)/projects_dropbox/social_influence_analysis/analysis/fmri/nilearn/signature_extract/signature-GeuterPaincPDM_sub-all_runtype-pvc_event-stimulus.tsv"
```

<!-- ## Step 2: load data {.unlisted .unnumbered} -->
<!-- ```{r} -->
<!-- df = read.csv(sig_name) -->
<!-- sig_df = df %>%separate(singletrial_fname,sep = "_", c("sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity")) -->
<!-- sig_df = sig_df %>% separate(stimintensity, into = c(NA, "stimintensity"), extra = "drop", fill = "left") -->
<!-- pvc <- simple_contrasts_singletrial(sig_df) -->
<!-- pvc$task[pvc$runtype == "runtype-pain"] <- "pain" -->
<!-- pvc$task[pvc$runtype == "runtype-vicarious"] <- "vicarious" -->
<!-- pvc$task[pvc$runtype == "runtype-cognitive"] <- "cognitive" -->
<!-- pvc$task <- factor(pvc$task) -->
<!-- ``` -->

<!-- ## Step 3: plot key paramters {.unlisted .unnumbered} -->
<!-- ```{r} -->
<!-- signature_key = "NPSpos" -->
<!-- taskname = "all"; plot_keyword = "stimulusintensity"; ggtitle_phrase =  "(3 tasks x 3 stimulus intensity)"; -->
<!-- pvc$task = factor(pvc$task) -->
<!-- plot_keys <- list( -->
<!--     iv1 = "task", -->
<!--     iv2 = "stim_ordered", -->
<!--     plot_keyword = "stimulusintensity", -->
<!--     dv = signature_key, -->
<!--     dv_keyword = signature_key, -->
<!--     taskname = taskname, -->
<!--     sub_mean = "mean_per_sub", -->
<!--     group_mean = "mean_per_sub_norm_mean", -->
<!--     legend_keyword = "stimulus intensity", -->
<!--     se = "se", -->
<!--     subject = "sub", -->
<!--     ggtitle = paste0( -->
<!--       str_to_title(signature_key),  -->
<!--       " dot product: ", str_to_title(taskname),' ', ggtitle_phrase," (N = ", length(unique(pvc$sub)), ")"), -->
<!--     title = paste0(str_to_title(signature_key), " - ", str_to_title(plot_keyword)), -->
<!--     xlab = "", -->
<!--     ylab = paste(signature_key," (dot product)"), -->
<!--     ylim = c(-250, 500), -->
<!--     w = 10, -->
<!--     h = 6, -->
<!--     plot_savefname = file.path( -->
<!--         analysis_dir, -->
<!--         paste("signature_task-", taskname, "_event-", plot_keyword, -->
<!--             "_dv-", signature_key, -->
<!--             "_", as.character(Sys.Date()), ".png", -->
<!--             sep = "" -->
<!--         ) -->
<!--     ) -->
<!--     #model_iv1 = "stim_ordered", -->
<!--     #model_iv2 = "cue_ordered" -->
<!-- ) -->
<!-- ``` -->

<!-- ```{r eval=FALSE, include=FALSE} -->
<!-- groupwise <- data.frame() -->
<!-- subjectwise <- data.frame() -->
<!-- summary <- summary_for_plots_PVC( -->
<!--         df = pvc, -->
<!--         # taskname = taskname, -->
<!--         groupwise_measurevar = "mean_per_sub", -->
<!--         subject_keyword =  "sub", -->
<!--         model_iv1 =  "task", -->
<!--         model_iv2 =  "stim_ordered", -->
<!--         dv = "NPSpos" -->
<!--     ) -->
<!-- subjectwise <<- as.data.frame(summary[[1]]) -->
<!-- groupwise <<- as.data.frame(summary[[2]]) -->
<!--     if (any(startsWith("NPSpos", c("expect", "Expect")))) { -->
<!--         plot_keys$color <- c("#1B9E77", "#D95F02", "#D95F02") -->
<!--     } else { -->
<!--         plot_keys$color <- c("#4575B4", "#FFA500", "#D73027") -->
<!--     } -->
<!-- ``` -->

<!-- ```{r} -->
<!-- p <- plot_halfrainclouds_twofactor_35( -->
<!--         subjectwise, groupwise, iv1 = "task", iv2 = "stim_ordered", -->
<!--         sub_mean = "mean_per_sub", group_mean = plot_keys$group_mean, se = plot_keys$se, subject = plot_keys$sub, -->
<!--         ggtitle = plot_keys$ggtitle, title = plot_keys$title, xlab = plot_keys$xlab, ylab = plot_keys$ylab, task_name = plot_keys$taskname, ylim = plot_keys$ylim, -->
<!--         w = plot_keys$w, h = plot_keys$h, dv_keyword = plot_keys$dv_keyword, color = plot_keys$color, save_fname = plot_keys$plot_savefname -->
<!--     ) -->
<!-- p -->
<!-- ``` -->

<!-- ## Plot test function -->
<!-- plot_signature_twofactor <- function(signature_key, analysis_dir, plot_keys, df)  -->
<!-- ```{r} -->
<!-- p <- plot_signature_twofactor(signature_key = "NPSpos",  -->
<!--                               plot_keys, df = data.frame(pvc)) -->
<!-- p -->
<!-- ``` -->





<!-- ```{r} -->
<!-- hist(pvc$NPS) -->
<!-- ``` -->
<!-- ```{r} -->
<!-- model.nps = lmer(NPSpos ~ task + stimintensity + (1 | sub) , data = pvc) -->
<!-- summary(model.nps) -->
<!-- ``` -->

<!-- ```{r pvc_summary, include=FALSE} -->
<!-- subject_varkey <- "sub" -->
<!-- iv1 <- "task" -->
<!-- iv2 <-  "stim_ordered" -->
<!-- dv <- "NPSpos" -->
<!-- taskname = "all" -->
<!-- dv_keyword <- "NPSpos" -->
<!-- subject <- "subject" -->
<!-- xlab <- "" -->
<!-- ylab <- "NPS positive (dot product)" -->
<!-- ylim <- c(-20,20) -->
<!-- title <- "stim" -->
<!-- #taskname <- "all tasks" -->
<!-- exclude <- "sub-0001|sub-0003|sub-0004|sub-0005|sub-0025|sub-0999" -->
<!-- ``` -->

<!-- ```{r plotting_parameters_34, include=FALSE} -->

<!-- plot_keys <- list(sub_mean = "mean_per_sub",group_mean = "mean_per_sub_norm_mean", se = "se", -->
<!--     subject = "sub", taskname = taskname, -->
<!--     ggtitle = paste(taskname, " - NPS (dot prodcut) Cooksd removed"), -->
<!--     title = paste(taskname, " - Actual"), -->
<!--     xlab = "", -->
<!--     ylab = "ratings (degree)", -->
<!--     ylim = c(-250,500), -->
<!--     dv_keyword = "NPS", -->
<!--     w = 10, -->
<!--     h = 6, -->
<!--     plot_savefname = file.path( -->
<!--         analysis_dir, -->
<!--         paste("raincloud_task-", taskname, -->
<!--             "_rating-", dv_keyword, -->
<!--             "_", as.character(Sys.Date()), "_cooksd.png", -->
<!--             sep = "" -->
<!--         ) -->
<!--     ), -->
<!--     model_iv1 ="stim_ordered", -->
<!--     model_iv2 = "cue_ordered",  -->
<!--     legend_keyword = "stimulus intensity") -->
<!-- ``` -->


<!-- ```{r summary_pvc, message=FALSE, warning=FALSE, include=FALSE, paged.print=FALSE} -->
<!-- groupwise = data.frame() -->
<!-- subjectwise = data.frame() -->
<!-- summary <- summary_for_plots_PVC(df = pvc,  -->
<!--                              # taskname = taskname,  -->
<!--                              groupwise_measurevar = "mean_per_sub", -->
<!--                              subject_keyword = "sub", -->
<!--                              model_iv1 = "task", -->
<!--                              model_iv2 = "stim_ordered", -->
<!--                              dv = "NPSpos") -->
<!-- subjectwise <- as.data.frame(summary[[1]]) -->
<!-- groupwise <-as.data.frame(summary[[2]]) -->
<!--     if (any(startsWith(plot_keys$dv_keyword, c("expect", "Expect")))) { -->
<!--         color <- c("#1B9E77", "#D95F02") -->
<!--     } else { -->
<!--         color <- c("#4575B4", "#D73027") -->
<!--     }  -->
<!-- ``` -->

<!-- ## Raincloud plots -->
<!-- ```{r plot_PVC, echo=FALSE, message=FALSE, warning=TRUE, paged.print=FALSE} -->
<!-- dv_keyword = "NPSpos" -->
<!-- signature_name = "NPSpos" -->
<!-- iv2 = "stim_ordered" -->
<!-- iv1 = "task" -->
<!--     if (any(startsWith(dv_keyword, c("expect", "Expect")))) { -->
<!--         color <- c("#1B9E77", "#D95F02", "#D95F02") -->
<!--     } else { -->
<!--         color <- c("#4575B4", "#FFA500", "#D73027") -->
<!--     } -->
<!--     subject_mean <- "mean_per_sub" -->
<!--     group_mean <- "mean_per_sub_norm_mean" -->
<!--     se <- "se" -->
<!--     ylim <- c(-25,26) -->
<!--     subject <- "sub" -->
<!--     ggtitle_phrase <-  "(3 tasks x 3 stimulus intensity)" -->
<!--     # ggtitle <- paste(taskname, " (3 tasks x 3 stimulus intensity) - ", signature_name, "dot product") -->
<!--     ggtitle <- paste0(str_to_title(signature_name), " dot product: ", str_to_title(taskname),' ', ggtitle_phrase,  " (N = ", length(unique(pvc$sub)), ")");  -->
<!--     # title <- paste(taskname, " (3 tasks x 3 stimulus intensity) - ", signature_name, "dot product") -->
<!--     title <- paste0(str_to_title(dv_keyword), " - ", str_to_title(plot_keys$legend_keyword)) -->
<!--     xlab <- "" -->
<!--     ylab <- paste(signature_name," (dot product)") -->
<!--     plot2_savefname <- file.path( -->
<!--         analysis_dir, -->
<!--         paste("raincloudplots_task-", taskname,"_event-",iv2, -->
<!--             "_rating-", dv_keyword, -->
<!--             "_", as.character(Sys.Date()), ".png", -->
<!--             sep = "" -->
<!--         ) -->
<!--     ) -->
<!-- p <- plot_halfrainclouds_twofactor( -->
<!--       subjectwise, groupwise, iv1, iv2,  -->
<!--       subject_mean, group_mean, se, subject,  -->
<!--       ggtitle, title, xlab, ylab, taskname, ylim, -->
<!--       w = plot_keys$w, h = plot_keys$h, dv_keyword, color, plot2_savefname) -->
<!-- p -->
<!-- ``` -->

<!-- ## Line plots -->
<!-- ```{r lineplot_PVC, echo=FALSE, message=FALSE, warning=FALSE, paged.print=FALSE} -->
<!-- ggtitle <- paste(str_to_title(signature_name), "dot product:", str_to_title(taskname), ggtitle_phrase,  " (N = ", length(unique(pvc$sub)), ")");  -->
<!-- g<-two_factor_lineplot(df = groupwise,  iv1 = "stim_ordered",iv2 = "task", mean = "mean_per_sub_norm_mean", error = "se", -->
<!--                        xlab = "stimulus intensity", -->
<!--                        ylab = dv) -->
<!-- g -->
<!-- ``` -->




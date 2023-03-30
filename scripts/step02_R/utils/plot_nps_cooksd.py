# nps_dummy ~ stim

```{r nps_dummy_common parameters}
main_dir = dirname(dirname(getwd()))
datadir = file.path(main_dir, 'data', 'beh', 'beh02_preproc')
analysis_dir = file.path(main_dir,'analysis','mixedeffect','model13_iv-stim_dv-nps-dummy',as.character(Sys.Date())  )
dir.create(analysis_dir, showWarnings = FALSE, recursive = TRUE)
savedir <- analysis_dir

npsdir = file.path(main_dir,'analysis','fmri','spm','univariate','model01_6cond','extract_nps')
model = 'nps'; model_keyword = "nps"
subjectwise_mean = "mean_per_sub"; group_mean = "mean_per_sub_norm_mean"; se = "se"
# iv = "contrast"; subject = "subject"
# dv = "nps"; dv_keyword = "nps_dot_product"
ylim = c(-800, 800)
xlab = "contrasts "; ylab = "NPS dotproduct"
ggtitle = paste0(model_keyword,
                   " :: extracted NPS value for stimulus intensity wise contrast")
legend_title = "Contrasts"
color_scheme <- c("Pain > VC" = "#941100",
         "Vicarious > PC" = "#008F51",
         "Cog > PV" = "#011891")

```

## Pain
* from con_0032 ~ con_0037
```{r v_stack}
contrast_name = 'P_simple'
taskname = 'pain'
con_list = c(32, 33, 34, 35, 36, 37)
stack_nps <- function(contrast_name, taskname, con_list) {
    df = data.frame()
    contrast_df = data.frame()
    groupwise = data.frame()
    subjectwise = data.frame()

    for (conname in con_list) {
  contrast_df = data.frame()
  fpath = Sys.glob(file.path(
    npsdir,paste0('extract-nps_model01-6cond_',sprintf("con_%04d", conname),'*',contrast_name,'*.csv'
    )
  ))
  fname = basename(fpath)
  contrast_df = read.csv(fpath)
  pattern <- paste0(contrast_name, "_\\s*(.*?)\\s*", ".csv")
  conname <- regmatches(fname, regexec(pattern, fname))[[1]][2]
  cuelevel <- strsplit(conname, "_")[[1]][1]
  stimlevel <- strsplit(conname, "_")[[1]][2]
  contrast_df$conname = conname
  contrast_df$cue = cuelevel
  contrast_df$stim = stimlevel
  df = rbind(df, contrast_df)
}
}




```

```{r P_simple_contrasts}
# [ CONTRASTS ]  ________________________________________________________________________________ # nolint
# contrast code ________________________________________
df$stim_factor <- factor(df$stim)

# contrast code 1 linear
df$stim_con_linear[df$stim == "lowstim"] <-  -0.5
df$stim_con_linear[df$stim == "medstim"] <-  0
df$stim_con_linear[df$stim == "highstim"] <-  0.5

# contrast code 2 quadratic
df$stim_con_quad[df$stim == "lowstim"] <-  -0.33
df$stim_con_quad[df$stim == "medstim"] <-  0.66
df$stim_con_quad[df$stim == "highstim"] <-  -0.33

# social cude contrast
df$cue_con[df$cue == "lowcue"] <-  -0.5 # social influence task
df$cue_con[df$cue == "highcue"] <-  0.5 # no influence task


stim_con1 <- "stim_con_linear"
stim_con2 <- "stim_con_quad"
iv1 <- "cue_con"
dv <- "npspos"
dv_keyword = "npspos"
subject_keyword = "subject"
```

```{r P_simple_run_model}
model_savefname <- file.path(
  analysis_dir,
  paste0("lmer_task-",taskname,"_rating-",dv_keyword,"_",as.character(Sys.Date()),"_cooksd.txt"
  )
)

cooksd <- lmer_twofactor_cooksd_fix(
  df,  taskname,  iv1,  stim_con1,  stim_con2,  dv,  subject_keyword = "subject",  dv_keyword,  model_savefname,
  effects = 'random_intercept', print_lmer_output = "TRUE")
influential <- as.numeric(names(cooksd)[(cooksd > (4 / as.numeric(length(
  unique(df$subject)
))))])
data_screen <- df[-influential,]
```

```{r rendering for plots }
    data_screen$cue_name[data_screen$cue == "highcue"] <- "high cue"
    data_screen$cue_name[data_screen$cue == "lowcue"] <- "low cue"

    data_screen$stim_name[data_screen$stim == "highstim"] <- "high"
    data_screen$stim_name[data_screen$stim == "medstim"] <- "med"
    data_screen$stim_name[data_screen$stim == "lowstim"] <- "low"

    data_screen$stim_ordered <- factor(
        data_screen$stim_name,
        levels = c("low", "med", "high")
    )
    data_screen$cue_ordered <- factor(
        data_screen$cue_name,
        levels = c("low cue", "high cue")
    )
    model_iv1 <- "stim_ordered"
    model_iv2 <- "cue_ordered"

    #  [ PLOT ] calculate mean and se  _________________________
    actual_subjectwise <- meanSummary(
        data_screen,
        c(subject_keyword, model_iv1, model_iv2), dv
    )
    actual_groupwise <- summarySEwithin(
        data = actual_subjectwise,
        measurevar = "mean_per_sub",
        withinvars = c(model_iv1, model_iv2), idvar = subject_keyword
    )
    nps_groupwise <- summarySEwithin(
        data = data_screen,
        measurevar = "nps",
        withinvars = c(model_iv1, model_iv2), idvar = subject_keyword
    )
    actual_groupwise$task <- taskname
```

```{r ggplot }
    sub_mean <- "mean_per_sub"
    group_mean <- "mean_per_sub_norm_mean"
    se <- "se"
    subject <- "subject"
    ggtitle <- paste(taskname, " - NPS (dot prodcut) Cooksd removed")
    title <- paste(taskname, " - Actual")
    xlab <- ""
    ylab <- "ratings (degree)"
    ylim <- c(-250,500) #NULL
    dv_keyword <- "actual"
    if (any(startsWith(dv_keyword, c("expect", "Expect")))) {
        color <- c("#1B9E77", "#D95F02")
    } else {
        color <- c("#4575B4", "#D73027")
    } # if keyword starts with
        w <- 10
    h <- 6
    plot_savefname <- file.path(
        analysis_dir,
        paste("raincloud_task-", taskname,
            "_rating-", dv_keyword,
            "_", as.character(Sys.Date()), "_cooksd.png",
            sep = ""
        )
    )
    g <- plot_halfrainclouds_twofactor(
        actual_subjectwise, actual_groupwise, model_iv1, model_iv2,
        sub_mean, group_mean, se, subject = subject_keyword,
        ggtitle, title, xlab, ylab, taskname,ylim,
        w, h, dv_keyword, color, plot_savefname
    )

g
```
```{r}
    g <- plot_rainclouds_twofactor(
        actual_subjectwise, actual_groupwise, model_iv1, model_iv2,
        sub_mean, group_mean, se, subject = subject_keyword,
        ggtitle, title, xlab, ylab, taskname,ylim,
        w, h, dv_keyword, color, plot_savefname
    )

g
```


```{r}
# classwise <- meanSummary(merge_df,
#                          c(subject_keyword, iv), dv)
# groupwise <- summarySEwithin(data = classwise,
#                              measurevar = subjectwise_mean,
#                              withinvars = c(iv))
# 
# subjectwise = subset(classwise, select = -c(sd))
```


## Vicarious
* from con_0038 ~ con_0043

## Cognitivee
* from con_0044 ~ con_0049
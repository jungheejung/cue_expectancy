#' Plot Within subject and Between subject effects
#'
#' This function generates various types of plots for a given task, including demean and cluster-wise means plots.
#' It allows customization of color gradients for the plots. The function assumes specific column names in the data
#' and uses custom ggplot formatting functions.
#'
#' @param data A dataframe containing the data to be plotted with columns like 'OUTCOME', 'EXPECT_demean', etc.
#' @param taskname A character string specifying the task name, used for filtering data and generating plot titles.
#' @param color_low The lower end color for gradient (default is "gray").
#' @param color_high The higher end color for gradient (default is "black").
#'
#' @return The function does not return a value but produces a grid of plots as a side effect.
#' @importFrom ggplot2 ggplot aes geom_smooth theme_classic scale_colour_gradient coord_fixed
#' @importFrom gridExtra grid.arrange
#' @importFrom grid textGrob
#' @importFrom ggpubr ggarrange annotate_figure
#' @examples
#' # Example usage:
#' plot_endertofighi(df.PVC_center[df.PVC_center$runtype == "runtype-pain", ], "pain", color_low = "red", color_high = "darkred")
#' # This assumes you already tidied the dataframe in the right format.
#' # Here's a pipeline:
#' # 1. First, load the data
#' #    dataPVC <- cueR::df_load_pvc_beh(datadir,
#' #                          subject_varkey = subject_varkey,
#' #                          iv = iv,
#' #                          exclude = exclude)
#' # 2. ESSENTIAL: Next, compute within subject and between subject effects
#' #    df.PVC_center <- cueR::compute_enderstofighi(dataPVC, sub="sub",
#' #                                   outcome = "event04_actual_angle",expect= "event02_expect_angle",
#' #                                   ses = "ses", run = "run")
#' # 3. then `plot_endertofighi`
#' @export

plot_endertofighi <- function(data, taskname, color_low="gray", color_high="black") {
  runtype_filter <- paste0("runtype-", taskname)
  data$sub_numeric <- as.numeric(as.factor(data$sub))
  # Plot for demean ____________________________________________________________
  g.Odemean <- ggplot(data,
                     aes(y = OUTCOME_demean, x = EXPECT_demean, colour = sub_numeric, group = sub), size = .3, color = 'gray') +
    #geom_point(size = .1) +
    geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .3) +
    theme_classic() +
    scale_colour_gradient(low = color_low, high = color_high) +
    # theme(legend.position = "none") +
        theme(legend.position = "none",
          plot.margin = margin(t = .3, r = .1, b = .1, l = .1, unit = "pt")) +
    coord_fixed(ratio = 1)
    # ylim(0,200)
  g.Odemean <- ggplot_largetext(g.Odemean)  # Assuming ggplot_largetext is a defined function


  # Plot for demean ____________________________________________________________
  g.demean <- ggplot(data,
                     aes(y = OUTCOME, x = EXPECT_demean, colour = sub_numeric, group = sub), size = .3, color = 'gray') +
    geom_point(size = .1, alpha = .1) +
    geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .3) +
    theme_classic() +
    scale_colour_gradient(low = color_low, high = color_high) +
    # theme(legend.position = "none") +
        theme(legend.position = "none",
          plot.margin = margin(t = .3, r = .1, b = .1, l = .1, unit = "pt")) +
    coord_fixed(ratio = 1) +
    ylim(0,200)
  g.demean <- ggplot_largetext(g.demean)  # Assuming ggplot_largetext is a defined function

    # Plot for Cluster-wise means ________________________________________________
  g.Ocm <- ggplot(data,
                 aes(y = OUTCOME, x = EXPECT_cm, colour = sub_numeric, group = sub), size = .3, color = 'gray') +
    geom_point(size = .1, alpha = .1) +
          stat_summary(
    fun.y = mean, geom = "point",
    aes(group =sub_numeric), #EXPECT_cm),
    size = 1
  ) +
    scale_colour_gradient(low = color_low, high = color_high) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = color_low) +  # Add the identity line
    geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = 1) + #size = .3) +
    theme_classic() +
        theme(legend.position = "none",
              plot.margin = margin(t = .3, r = .1, b = .1, l = .1, unit = "pt")) +
    coord_fixed(ratio = 1) +
    ylim(0,200)
  g.Ocm <- ggplot_largetext(g.Ocm)  # Assuming ggplot_largetext is a defined function


  # Plot for Cluster-wise means ________________________________________________
  g.cm <- ggplot(data,
                 aes(y = OUTCOME_cm, x = EXPECT_cm, colour = sub_numeric, group = sub), size = .3, color = 'gray') +
      stat_summary(
    fun.y = mean, geom = "point",
    aes(group =sub_numeric), #EXPECT_cm),
    size = 1
  ) +
   geom_point(size = .1, alpha = .1) +
    scale_colour_gradient(low = color_low, high = color_high) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = color_low) +  # Add the identity line
    geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = 1) + #size = .3) +
    theme_classic() +
        theme(legend.position = "none",
              plot.margin = margin(t = .3, r = .1, b = .1, l = .1, unit = "pt")) +
    coord_fixed(ratio = 1) +
    ylim(-10,200)
  g.cm <- ggplot_largetext(g.cm)  # Assuming ggplot_largetext is a defined function


  # Plot for Zscore ____________________________________________________________
  g.z <- ggplot(data,
                 aes(y = OUTCOME, x = EXPECT_zscore, colour = sub_numeric, group = sub), size = .3, color = 'gray') +
    #geom_point(size = .1) +
    scale_colour_gradient(low = color_low, high = color_high) +
    geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .3) +
    theme_classic() +
        theme(legend.position = "none", plot.margin = margin(t = .3, r = .1, b = .1, l = .1, unit = "pt")) +

    coord_fixed(ratio = 1)
  g.z <- ggplot_largetext(g.z)  # Assuming ggplot_largetext is a defined function


    # Plot for Zscore ____________________________________________________________
  g.z2 <- ggplot(data,
                 aes(y = OUTCOME_zscore, x = EXPECT_zscore, colour = sub_numeric, group = sub), size = .3, color = 'gray') +
    #geom_point(size = .1) +
    scale_colour_gradient(low = color_low, high = color_high) +
    geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .3) +
    theme_classic() +
        theme(legend.position = "none", plot.margin = margin(t = .3, r = .1, b = .1, l = .1, unit = "pt")) +

    coord_fixed(ratio = 1)
  g.z2 <- ggplot_largetext(g.z2)  # Assuming ggplot_largetext is a defined function

  # Combine plots
  title_text <- paste(tools::toTitleCase(taskname), "task: within-subject centered vs. subject-cluster means\n")
  title_grob <- grid::textGrob(title_text, gp = gpar(fontsize = 18), vjust = 1)

  # grid.draw(gridExtra::grid.arrange(g.demean, g.cm, g.z, ncol = 3,
  #                         widths = c(1,  1, 1), heights = c(1, 1, 1),
  #                         top = title_grob
  # ))
  arranged_plots <- (ggpubr::ggarrange(
        g.demean, g.Ocm, g.cm, g.z, g.z2, g.Odemean,
        common.legend = FALSE,
        legend = "none",
        ncol = 3,
        nrow = 2,
        widths = c(1,1,1),
        heights = c(1,1),
        align = "v"
      ))
  #return(wbeffect)

  annotated_plots <- ggpubr::annotate_figure(arranged_plots,
                                   top = title_grob)
  grid.draw(annotated_plots)


}

# library(ggplot2)
# library(gridExtra)
# library(grid)

# create_task_plots <- function(data, taskname) {
#   runtype_filter <- paste0("runtype-", taskname)

#   # Plot for demean
#   g.demean <- ggplot(data,
#                      aes(y = OUTCOME, x = EXPECT_demean, colour = subject, group = subject)) +
#     # geom_point(size = .1) +
#     geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .3) +
#     theme_classic() +
#     theme(legend.position = "none") +
#     coord_fixed(ratio = 1)
#   g.demean <- ggplot_largetext(g.demean)  # Assuming ggplot_largetext is a defined function

#   # Plot for cm
#   g.cm <- ggplot(data,
#                  aes(y = OUTCOME_cm, x = EXPECT_cm, colour = subject, group = subject)) +
#     geom_point(size = .1) +
#     geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, size = .3) +
#     theme_classic() +
#     coord_fixed(ratio = 1)
#   g.cm <- ggplot_largetext(g.cm)  # Assuming ggplot_largetext is a defined function

#   # Combine plots
#   title_text <- paste(taskname, "task: within-subject centered vs. subject-cluster means\n")
#   title_grob <- grid::grid.text(title_text, gp = gpar(fontsize = 18))

#   gridExtra::grid.arrange(g.demean, g.cm, ncol = 2,
#                           widths = c(1, 1.3), heights = c(1, 1),
#                           top = title_grob
#   )
# }

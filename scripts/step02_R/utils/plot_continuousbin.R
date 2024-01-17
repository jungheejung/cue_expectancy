#' Plot Binned Ratings
#'
#' This function generates plots for binned ratings in a specified task, with options for customizing
#' color gradients and labels. It supports different task types with distinct color palettes. The function
#' assumes specific column names in the data and uses custom ggplot formatting functions.
#'
#' @param df A dataframe containing the data to be plotted.
#' @param taskname A character string specifying the task name, used for filtering data and generating plot titles.
#' @param iv1 The name of the first independent variable column in `df`.
#' @param iv2 The name of the second independent variable column in `df`.
#' @param subject The name of the subject identifier column in `df` (default is "src_subject_id").
#' @param xlab The label for the x-axis (default is "expectation ratings").
#' @param ylab The label for the y-axis (default is "outcome ratings").
#' @param levels The number of levels for binning the independent variable (default is 10).
#'
#' @return A ggplot object representing the binned rating plot.
#'
#' @examples
#' # Example usage
#' plot_binned_rating(df, "pain", "event02_expect_angle", "event04_actual_angle",
#'                    "src_subject_id", "expectation ratings", "outcome ratings", 10)
#' # Note: `df` should be a properly formatted dataframe as required by the function.
#' #### [Example](https://github.com/jungheejung/cueR/blob/main/man/figures/example_plot_binned_rating.png)
#' @export
plot_binned_rating <- function(df, taskname, iv1, iv2, subject = "src_subject_id",
                               xlab = "expectation ratings", ylab = "outcome ratings", levels = 10) {

    if (any(startsWith(taskname, c("pain", "Expect")))) {
        color_palette <- c("#941100", "#000000")
    } else if (any(startsWith(taskname, c("vicarious")))) {
        color_palette <- c("#008F51", "#000000")
    } else if (any(startsWith(taskname, c("cognitive")))) {
        color_palette <- c("#011891", "#000000")
    }

    df_dropna <- df[!is.na(df[, iv1]) & !is.na(df[, iv2]), ]
    # 1. If a participant has less than 5 trials, then drop participant ________
    k <- df_dropna %>%
        dplyr::group_by(.data[["src_subject_id"]]) %>%
        filter(n() >= 5) %>%
        ungroup()

    # 2. demean and discretize data ____________________________________________
    df_discrete <- k %>%
        dplyr::group_by(.data[["src_subject_id"]]) %>%
        select(everything())  %>%
        mutate(
            iv2_demean = .data[[iv2]] - mean(.data[[iv2]]),
            iv1_demean = .data[[iv1]] - mean(.data[[iv1]])
        ) %>%
        mutate(
            bin = ggplot2::cut_interval(.data[["iv1_demean"]], n = levels),
            expectlevels = as.numeric(ggplot2::cut_interval(.data[["iv1_demean"]], n = levels))
        )

    discrete_df <- df_discrete[df_discrete$param_task_name == taskname, ]
    discrete_df$expectlevels_newlev <- discrete_df$expectlevels - (levels/2)

    subjectwise_bin_demean_cue <- meanSummary(discrete_df, c(
        "subject", "param_task_name", "expectlevels", "param_cue_type"
    ), "iv2_demean")
    subjectwise_bin_demean_naomit <- na.omit(subjectwise_bin_demean_cue)
    groupwise_bin_demean <- summarySEwithin(
        data = subjectwise_bin_demean_naomit,
        measurevar = "mean_per_sub", # variable created from above
        withinvars = c("expectlevels", "param_cue_type"), # iv
        idvar = "subject"
    )
    subjectwise_bin_demean_naomit$expectlevels_newlev <- as.numeric(subjectwise_bin_demean_naomit$expectlevels) - (levels/2)
    groupwise_bin_demean$expectlevels_newlev <- as.numeric(groupwise_bin_demean$expectlevels) - (levels/2)
    discrete_df$expectlevels_newlev <- as.factor(discrete_df$expectlevels_newlev)
    g <-
        plot_errorbar(
            subjectwise_bin_demean_naomit,
            groupwise_bin_demean,
            iv = "expectlevels_newlev",
            sub_iv = "expectlevels",
            group_by = "param_cue_type",
            subjectwise_mean = "mean_per_sub",
            group_mean = "mean_per_sub_norm_mean",
            se = "se",
            subject = "subject",
            ggtitle = paste0("Do we see a sigmoidal pattern in the pain task?\ntask-", taskname, ": expectation predict outcome ratings"),
            title = "levels of expectation ratings",
            xlab = xlab,
            ylab = ylab,
            taskname = taskname,
            ylim = c(-40, 40),
            w = 3,
            h = 5,
            dv_keyword = "sigmoidal",
            color = color_palette,
            level_num = levels,
            save_fname = "~/Download/TEST.png"
        )
    return(g)
}

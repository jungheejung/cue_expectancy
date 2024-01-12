#' Apply Simple Contrasts to Single Trial Data
#'
#' This function applies simple linear and quadratic contrasts to single trial data based on stimulus intensity and cue type. It modifies the input dataframe by adding several new columns representing these contrasts.
#'
#' @param df A data frame containing the single trial data. 
#'           It must have columns 'stimintensity' and 'cuetype'.
#'
#' @return The modified data frame with added columns for contrasts:
#'         - `STIM` as a factor based on 'stim'.
#'         - `STIM_linear` for linear contrast coding based on 'stimintensity'.
#'         - `STIM_quadratic` for quadratic contrast coding based on 'stimintensity'.
#'         - `CUE_high_gt_low` for cue contrast between high and low cue types.
#'         - `stim_ordered` as an ordered factor for 'stimintensity'.
#'         - `cue_name` and `cue_ordered` as factors for 'cuetype'.
#'
#' @examples
#' df <- data.frame(
#'     stim = c("A", "B", "C"),
#'     stimintensity = c("low", "med", "high"),
#'     cuetype = c("cuetype-low", "cuetype-med", "cuetype-high")
#' )
#' df <- simple_contrast_singletrial(df)
#'
#' @export

simple_contrast_singletrial <- function(df) {

df$STIM <- factor(df$stim)

# contrast code 1 linear
df$STIM_linear[df$stimintensity == "low"] <-  -0.5
df$STIM_linear[df$stimintensity == "med"] <-  0
df$STIM_linear[df$stimintensity == "high"] <-  0.5

# contrast code 2 quadratic
df$STIM_quadratic[df$stimintensity == "low"] <-  -0.33
df$STIM_quadratic[df$stimintensity == "med"] <-  0.66
df$STIM_quadratic[df$stimintensity == "high"] <-  -0.33

# cue contrast
df$CUE_high_gt_low[df$cuetype == "cuetype-low"] <-  -0.5 # social influence task
df$CUE_high_gt_low[df$cuetype == "cuetype-high"] <-  0.5 # no influence task

df$stim_ordered <- factor(
        df$stimintensity,
        levels = c("low", "med", "high")
    )

df$cue_name[df$cuetype == "cuetype-low"] <- "low"
df$cue_name[df$cuetype == "cuetype-high"] <- "high"

df$cue_ordered <- factor(
        df$cue_name,
        levels = c("low", "high")
    )
return(df)
}
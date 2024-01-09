#' Load data frame that has signature extractions. 
#' 
#' Signature extractions are computed via the following code. 
#' Here, we load the derivatives.
#' https://github.com/jungheejung/cue_expectancy/tree/main/scripts/step08_applyNPS
#' https://github.com/jungheejung/cue_expectancy/blob/main/scripts/step10_nilearn/singletrialLSS/step02_apply_signature.py
#'
#' load .tsv or .csv file that list signature extracted dot products
#' Note that the filenames have the metadata, thereby, we extract the metadata and include it as new columns.
#' @param fname str: filename glob pattern that comes after the signature_key (e.g. "_sub-all_runtype-pvc_event-stimulus.tsv")
#'
#' @return dataframe with signature-extracted dot products, filenames are split into informative columns
#' @export
#'
#' @examples
#' df_load_signature(fname)
df_load_signature <- function(fname) {
    library(tidyr)
    df <- read.csv(fname)
    sig_df <- df %>% separate(
    singletrial_fname,
    sep = "_",
    c(
      "sub", "ses", "run", "runtype", "event", "trial", "cuetype", "stimintensity"
    )
  )
    sig_df <- sig_df %>% separate(
    stimintensity,
    into = c(NA, "stimintensity"),
    extra = "drop",
    fill = "left"
  )

sig_df <- sig_df %>% separate(
    runtype,
    remove = FALSE,
    into = c(NA, "task"),
    extra = "drop",
    fill = "left"
  )
    return(sig_df)
}
#' load_signature_extraction
#'
#' load .tsv or .csv file that list signature extracted dot products
#' @param fname str: filename glob pattern that comes after the signature_key (e.g. "_sub-all_runtype-pvc_event-stimulus.tsv")
#'
#' @return dataframe with signature-extracted dot products, filenames are split into informative columns
#' @export
#'
#' @examples
#' load_signature_extraction(fname)
load_extraction <- function(fname) {
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
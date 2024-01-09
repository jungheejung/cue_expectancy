#' Compute Intraclass Correlation Coefficient (ICC) from a Linear Mixed Model
#'
#' This function calculates the Intraclass Correlation Coefficient (ICC) from 
#' a fitted linear mixed-effects model object (from the `lme4` package). The ICC 
#' is a measure of the proportion of the total variance that is attributable to 
#' the grouping structure in the data.
#'
#' @param lmer_object A linear mixed-effects model object, typically created 
#'   using `lmer()` function from the `lme4` package.
#'
#' @return A numeric value representing the ICC of the fitted model.
#'
#' @examples
#' # Example usage:
#' # model <- lmer(response ~ predictor + (1|group), data = dataset)
#' # icc_value <- compute_icc(model)
#'
#' @export
compute_icc <- function(lmer_object) {
  # Extract variance components from the model
  var_dat <- lmer_object %>% VarCorr() %>% as.data.frame()
  
  # Calculate ICC: variance due to groups / total variance
  icc <- var_dat$vcov[1] / (var_dat$vcov[1] + var_dat$vcov[2])
  
  return(icc)
}

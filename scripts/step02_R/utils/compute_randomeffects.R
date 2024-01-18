#' Compute Random and Fixed Effects from a Linear Mixed Effects Model
#'
#' This function takes a linear mixed effects model object, extracts the fixed effects and random effects,
#' processes them, combines them into a single data frame, and optionally saves the result to a file.
#'
#' @param lmer_model A linear mixed effects model object from which to extract effects.
#' @param rand_savefname The file path where the combined random and fixed effects data frame should be saved.
#'        If NULL, the file is not saved.
#' @param taskname The name of the task associated with the model, to be added as a new column in the output.
#' @param new_rand_names A character vector specifying new names for the random effects terms.
#' @param new_fix_names A character vector specifying new names for the fixed effects terms.
#'
#' @return An invisible data frame combining the processed random and fixed effects, along with the task name.
#'
#' @export
#' @examples
#' # Assuming `model` is a lmer model object and `task_name` is the associated task
#' result_df <- compute_randomeffects(model, "path/to/savefile.csv", task_name)
#'
#' # If you do not wish to save the result to a file, use NULL for `rand_savefname`
#' result_df <- compute_randomeffects(model, NULL, task_name)
#'
#' @importFrom dplyr select rename
#' @importFrom tidyr spread
#' @importFrom broom
#' @importFrom lme4 ranef fixef
compute_randomeffects <- function(lmer_model, rand_savefname, taskname,
                                  new_rand_names = c("rand_intercept", "rand_cue"),
                                  new_fix_names = c("fix_intercept", "fix_cue")) {

  # Extract fixed effects and random effects _________________________________
  fixEffect <- as.data.frame(fixef(lmer_model))
  randEffect <- as.data.frame(ranef(lmer_model))


  # New mapping of fix effect terms _______________________________________
  fix_names <- rownames(fixEffect)
  fix_mapping <- setNames(new_fix_names, fix_names)
  rownames(fixEffect) <- fix_mapping[rownames(fixEffect)]


  # New mapping of random effect terms _______________________________________
  unique_terms <- levels(randEffect$term)
  mapping <- setNames(new_rand_names, unique_terms)
  randEffect$newcoef <- mapping[randEffect$term]


  # Processing the random effects ____________________________________________
  rand_subset <- subset(randEffect, select = -c(grpvar, term, condsd))
  wide_rand <- spread(rand_subset, key = newcoef, value = condval)


  # Processing the fixed effects _____________________________________________
  wide_fix <- do.call(
    "rbind",
    replicate(nrow(wide_rand),
              as.data.frame(t(as.matrix(fixEffect))),
              simplify = FALSE
    )
  )

  # Combining and finalizing the dataframe ___________________________________
  total <- cbind(wide_rand, wide_fix)
  total$task <- taskname
  rownames(total) <- NULL
  new_total <- total %>% dplyr::select(task, everything())
  new_total <- dplyr::rename(total, subj = grp)


  # Saving the file
  #write.csv(new_total, rand_savefname, row.names = FALSE)
  return(invisible(new_total))

}

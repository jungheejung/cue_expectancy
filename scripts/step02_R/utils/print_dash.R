#' Print a title surrounded by dashes for emphasis.
#'
#' This function prints a title surrounded by dashes to create a visual separation
#' and emphasis for the printed output.
#'
#' @param title The title to be printed.
#'
#' @return This function does not return a value; it prints the title with dashes.
#'
#' @examples
#' \dontrun{
#'   print_dash("model with Z scores")
#' }
#'
#' @export
print_dash <- function(title) {
  dash_line <- paste0(rep("-", 40), collapse = "") # Create a single string of 40 dashes
  cat("\n\n", dash_line, "\n", sep = "")
  cat(title, "\n", sep = "")
  cat(dash_line, "\n", sep = "")
}

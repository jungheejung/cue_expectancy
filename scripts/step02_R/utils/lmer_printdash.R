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
  cat(rep("-", 40), "\n")
  cat(title, "\n")
  cat(rep("-", 40), "\n")
}

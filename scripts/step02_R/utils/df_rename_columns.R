#' Rename DataFrame Columns Based on Mapping
#'
#' This function creates new columns in a DataFrame with the same old names but renamed values based on a mapping of old names to new names.
#'
#' @param data A DataFrame.
#' @param column_mapping A named character vector where names represent old column names and values represent new column names.
#'
#' @return A modified DataFrame with new columns having the same old names but renamed values if applicable.
#'
#' @examples
#' df <- data.frame(
#'   event04_actual_angle = c(45, 60, 30),
#'   event02_expect_angle = c(1, 2, 3),
#'   other_column = c("A", "B", "C")
#' )
#' column_mapping <- c("event04_actual_angle" = "OUTCOME", "event02_expect_angle" = "EXPECT")
#' df_with_renamed_columns <- df_rename_columns(df, column_mapping)
#'
#' @export
df_rename_columns <- function(data, column_mapping) {
  new_data <- data
  for (old_name in names(column_mapping)) {
    new_name <- column_mapping[old_name]
    if (old_name %in% colnames(data)) {
      new_data[[new_name]] <- data[[old_name]]
    }
  }
  return(new_data)
}

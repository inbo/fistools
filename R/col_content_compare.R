#' Compare column contents of two dataframes
#'
#' @description
#' Compares the content of 2 similar columns of two data frames.
#' The function prints a list of values missing from the first column,
#' missing from the second column, and the values that are in both columns.
#'
#' @param df1 A data frame
#' @param col1 A column name of df1
#' @param df2 A data frame
#' @param col2 A column name of df2
#'
#' @family column comparison
#'
#' @return A list of values missing from the first column, missing from the second column,
#' and the values that are in both columns.
#'
#' @examples
#'  \dontrun{
#' dataset1 <- data.frame(a = c(1, 2, 3, 4, 5), b = c("a", "b", "c", "d", "e"))
#' dataset2 <- data.frame(c = c(1, 2, 3, 4, 5), d = c("a", "b", "f", "d", "e"))
#' col_content_compare(df1 = dataset1, "b", df2 = dataset2, "d")
#' }
#'
#' @export
#' @family column comparison
#'
#' @author Sander Devisscher

col_content_compare <- function(df1, col1, df2, col2) {

  # Check if dataframes are in the environment
  if (!exists(deparse(substitute(df1))) | !exists(deparse(substitute(df2)))) {
    stop("Data frames must be in the environment")
  }

  # Check if the arguments are data frames
  if (!is.data.frame(df1) | !is.data.frame(df2)) {
    stop("df1 & df2 must be data frames")
  }

  # Check if the columns are present in the data frames
  if (!col1 %in% names(df1)) {
    stop(paste("Column", col1, "not found in df1"))
  }
  if (!col2 %in% names(df2)) {
    stop(paste("Column", col2, "not found in df2"))
  }

  # Check if the columns have the same type
  if (class(df1[[col1]]) != class(df2[[col2]])) {
    warning(paste("Columns", col1, "and", col2, "have different types >> may result
                  in unexpected behavior"))
  }

  # Get the names of the data frames
  df1_name <- deparse(substitute(df1))
  df2_name <- deparse(substitute(df2))

  # Get the unique values of the columns
  col1_unique <- unique(df1[[col1]])
  col2_unique <- unique(df2[[col2]])

  # Get the values that are in both columns
  in_both <- intersect(col1_unique, col2_unique)

  # Get the values that are in col1 but not in col2
  missing_from_col2 <- setdiff(col1_unique, col2_unique)

  # Get the values that are in col2 but not in col1
  missing_from_col1 <- setdiff(col2_unique, col1_unique)

  # Print the results
  print(paste0("Values missing from ", df2_name, "$", col2, " but in ", df1_name, "$", col1, ":"))
  print(missing_from_col2)

  print(paste0("Values missing from ", df1_name, "$", col1, " but in ", df2_name, "$", col2, ":"))
  print(missing_from_col1)

  print("Values in both columns:")
  print(in_both)

  # Return the results as a list
  return(list(missing_from_col2 = missing_from_col2,
              missing_from_col1 = missing_from_col1,
              in_both = in_both))
}

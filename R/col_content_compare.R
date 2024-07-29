#' Compare column contents of two dataframes

#' Compares the content of 2 similar columns of two data frames.
#' The function prints a list of values missing from the first column,
#' missing from the second column, and the values that are in both columns.
#'
#' @param df1 A data frame
#' @param col1 A column name of df1
#' @param df2 A data frame
#' @param col2 A column name of df2
#'
#' @return A list of values missing from the first column, missing from the second column,
#' and the values that are in both columns.
#'
#' @examples
#'  \dontrun{
#' df1 <- data.frame(a = c(1, 2, 3, 4, 5), b = c("a", "b", "c", "d", "e"))
#' df2 <- data.frame(a = c(1, 2, 3, 4, 5), b = c("a", "b", "f", "d", "e"))
#' col_content_compare(df1, "b", df2, "b")
#' }
#'
#' @export
#' @family column comparison
#'
#' @author Sander Devisscher

col_content_compare <- function(df1, col1, df2, col2) {

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
  print(paste("Values missing from", col1, "but in", col2, ":"))
  print(missing_from_col2)

  print(paste("Values missing from", col2, "but in", col1, ":"))
  print(missing_from_col1)

  print("Values in both columns:")
  print(in_both)

  # Return the results as a list
  return(list(missing_from_col2 = missing_from_col2,
              missing_from_col1 = missing_from_col1,
              in_both = in_both))
}

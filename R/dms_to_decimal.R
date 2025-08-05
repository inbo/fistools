#' @title dms_to_decimal
#'
#' @description
#' Convert degrees, minutes, and seconds to decimal degrees.
#'
#' @param deg Degrees (numeric or character).
#' @param min Minutes (numeric or character).
#' @param sec Seconds (numeric or character).
#' @param direction Direction (character, optional, e.g., 'N', 'S', 'E', 'W').
#'
#' @return Decimal degrees (numeric).
#' @family spatial
#' @export
#'
#' @author Sander Devisscher
#'
#' @examples
#' \dontrun{
#' # Convert 30\u00B0 15'50"N or 30 degrees, 15 minutes, and 50 seconds north to decimal degrees
#' dms_to_decimal(30, 15, 50, 'N')
#' # Returns 30.26389
#' }
dms_to_decimal <- function(deg, min, sec, direction = NULL) {
  dec <- as.numeric(deg) + as.numeric(min)/60 + as.numeric(sec)/3600
  if (!is.null(direction)) {
    if (direction %in% c('S', 'W')) dec <- -dec
  }
  return(dec)
}

#' @title dms column_to_decimal
#'
#' @description
#' Convert a data frame column with degrees, minutes as well as seconds to decimal degrees.
#'
#' @param df Data frame containing the DMS columns.
#' @param coord_col Name of the column with coordinates in degrees.
#'
#' @return Data frame with a new column containing decimal degrees.
#' @export
#'
#' @author Sander Devisscher
#' @family spatial
#'
#' @examples
#' \dontrun{
#' # Example data frame
#' df <- data.frame(
#'  lat_Y = c("50\u00B045'38.7\"N", "50\u00B046'04.9\"N", "50\u00B045'19.7\"N",
#'  "50\u00B045'18.0\"N", "50\u00B046'24.4\"N", "50\u00B045'29.2\"N"),
#'  long_X = c("3\u00B010'26.0\"E", "3\u00B010'28.0\"E", "3\u00B010'25.0\"E",
#'  "3\u00B010'24.0\"E", "3\u00B010'30.0\"E", "3\u00B010'27.0\"E"))
#'
#' # Convert the lat_Y and long_X columns to decimal degrees
#' df <- dms_column_to_decimal(df, c("lat_Y", "long_X"))
#' # View the updated data frame
#' print(df)
#' }

dms_column_to_decimal <- function(df, coord_col) {
  for (col in coord_col) {
    if (!col %in% names(df)) {
      stop(paste("Column", col, "not found in the data frame."))
    }

    # Extract degrees, minutes, seconds, and direction
    dms <- strsplit(as.character(df[[col]]), "[\u00B0 '\" ]")
    df[[paste0(col, "_decimal")]] <- sapply(dms, function(x) {

      if (length(x) < 3) {
        stop(paste("Column", col, "does not contain enough components for DMS format."))
      }

      if (length(x) == 3) {
        warning(paste("Column", col, "does not contain a direction. Assuming 'N' for latitude and 'E' for longitude."))
        x <- c(x, NA)  # If no direction is provided, set it to NA
      }
      if (length(x) > 4) {
        stop(paste("Column", col, "contains too many components for DMS format."))
      }
      # Ensure the components are in the correct order
      if (length(x) == 4 && !is.na(x[4]) && !x[4] %in% c('N', 'S', 'E', 'W')) {
        stop(paste("Column", col, "contains an invalid direction:", x[4]))
      }

      # Convert to numeric and handle direction
      deg <- as.numeric(x[1])
      min <- as.numeric(x[2])
      sec <- as.numeric(x[3])
      direction <- x[4]

      dms_to_decimal(deg, min, sec, direction)
    })
  }
  return(df)
}

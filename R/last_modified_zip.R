#' get last modified zip
#'
#' @description
#' A helper function to retrieve the id of last modified zip file from a specified
#' Google Drive folder.
#'
#'
#' @param folder_id The ID of the googledrive folder to check for the last
#' modified zip file.
#'
#' @return The name of the last modified zip file in the specified folder.
#'
#' @family download
#'
#' @examples
#'  \dontrun{
#'  get_last_modified_zip(folder_id = "17p2MZt9LIuhIU72u_JjDBbO7D1IPTv7-")
#' }
#'
#' @export
#'
#' @author Sander Devisscher, Martijn Bollen
#'
get_last_modified_zip <- function(folder_id) {

  x <- googledrive::drive_ls(googledrive::as_id(folder_id))
  x <- x[grepl("*.zip", x$name),]
  last <- which.max(as.POSIXct(sapply(x$drive_resource, function(x) x$modifiedTime)))

  if (length(last) == 0) {
    stop("No zip files found in the specified folder.")
  } else {
    return(x$id[last])
  }
}

#' Unzip last modified zip
#'
#' @description
#' A function to download and unzip the last modified zip file from a specified
#' Google Drive folder.
#'
#' @param folder_id The ID of the googledrive folder to check for the last modified zip file.
#' @param exdir The directory where the zip file should be extracted. Defaults to `tempdir()`.
#'
#' @return The path to the datapackage.json of the last modified zip file in the specified folder.
#'
#' @family download
#'
#' @examples
#' \dontrun{
#' datapackage <- unzip_last_modified_zip(folder_id = "17p2MZt9LIuhIU72u_JjDBbO7D1IPTv7-") |>
#' camtraptor::read_camtrap_dp()
#' }
#'
#' @export
#'
unzip_last_modified_zip <- function(folder_id,
                                    exdir = tempdir()){

  zip_id <- get_last_modified_zip(folder_id)

  zip_path <- file.path(exdir, "last_modified.zip")

  zip_id |>
    download_gdrive_if_missing(zip_path, update_always = TRUE)

  if (!file.exists(zip_path)) {
    stop("Failed to download the zip file.")
  }

  # Unzip the file
  unzip(zip_path, exdir = exdir)
  return(file.path(exdir, "datapackage.json"))
}

#' Download files from a Google Drive folder to a local directory
#'
#' @author Sander Devisscher
#'
#' @description
#' This function allows the user to download all files from a specified Google Drive folder to a local directory. The user can filter the files by type and specify the output folder.
#'
#' @param drive_folder character string, URL or ID of the Google Drive folder to download from.
#' @param output_folder character string, path to the local directory where the files will be downloaded. If NULL, the current working directory will be used.
#' @param filetypes character vector, types of files to download. Default is "all", which means all files will be downloaded. You can specify file types by using regular expressions, for example c("csv", "txt") to download only csv and txt files.
#' @param email character string, the email address to use for authentication with Google Drive. Default is the value of the "email" environment variable.
#'
#' @details
#' You can find the ID of a Google Drive folder by right-clicking on the folder, selecting "Get link", and copying the part of the URL that comes after "folders/". For example, if the URL is "https://drive.google.com/drive/folders/1a2b3c4d5e6f7g8h9i0j", then the ID of the folder is "1a2b3c4d5e6f7g8h9i0j".
#'
#' If you specify file types using regular expressions, make sure to include the appropriate syntax. For example, to download only csv files, you can use "csv" or "\\.csv$". To download multiple file types, you can use c("csv", "txt") or c("\\.csv$", "\\.txt$").
#'
#' @examples
#' \dontrun{
#' #' # download all files from a Google Drive folder to the current working directory
#'
#' drive_to_folder(drive_folder = "1a2b3c4d5e6f7g8h9i0j")
#'
#' # download only wav files from a Google Drive folder to a specified output folder
#' drive_to_folder(drive_folder = "1a2b3c4d5e6f7g8h9i0j",
#'                 output_folder = "path/to/output/folder",
#'                 filetypes = "wav")
#'}
#'
#' @family download
#'
#' @returns The specified files are downloaded from the Google Drive folder to the local directory.
#' @export

drive_to_folder <- function(drive_folder = NULL,
                            output_folder = NULL,
                            filetypes = "all",
                            email = Sys.getenv("email")){

  # 0. authenticate ####
  googledrive::drive_auth(email)

  # 1. checks & preparation ####
  if(is.null(output_folder)){
    warning("No output folder provided. Using current working directory.")
    output_folder <- getwd()
  }

  if(is.null(drive_folder)){
    stop("No drive folder provided. Please provide a valid Google Drive folder URL or ID.")
  }

  # 2. get drive folder info ####
  files_on_drive <- tryCatch({
    googledrive::drive_ls(googledrive::as_id(drive_folder))
  }, error = function(e){
    stop("Error retrieving drive folder information. Please check the provided URL or ID.")
  })

  # 3. filter files by type if needed ####
  if("all" %in% filetypes){
    if(length(filetypes) == 1){
      filetypes[i] <- paste0("\\.", filetypes, "$")
      files_on_drive <- files_on_drive |>
        dplyr::filter(grepl(filetypes, name))
    }else{
      for(i in seq_along(filetypes)){
        filetypes[i] <- paste0("\\.", filetypes[i], "$")

        files_on_drive <- files_on_drive |>
          dplyr::filter(grepl(filetypes[i], name))
      }
    }
  }

  if(nrow(files_on_drive) == 0){
    stop("No files found in the specified drive folder with the given file types.")
  }

  # 4. download files ####
  for(i in 1:nrow(files_on_drive)){
    tryCatch({
      googledrive::drive_download(file = files_on_drive$id[i],
                                  path = file.path(output_folder, files_on_drive$name[i]),
                                  overwrite = TRUE)
    }, error = function(e){
      warning(paste0("Error downloading file: ", files_on_drive$name[i], ". Skipping this file."))
    })
  }
}

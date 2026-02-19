#' Upload a folder to Google Drive
#'
#' @description
#' This function allows you to upload a folder to Google Drive. You can choose to zip the folder before uploading, and to clean up the local files after uploading.
#'
#' @param input_folder character string, path to the folder you want to upload
#' @param drive_folder character string, id to the folder in Google Drive where you want to upload the files.
#' @param zipfiles boolean, whether to zip the files before uploading. Default is FALSE.
#' @param cleanup boolean, whether to delete the local files after uploading. Default is FALSE.
#' @param filetype character string, the type of files to upload. Default is "all". You can specify a filetype by using a regular expression, for example "csv" to upload only csv files.
#' @param recursive boolean, whether to include files in subfolders of the input folder. Default is FALSE.
#' @param email character string, the email address to use for authentication with Google Drive. Default is the value of the "email" environment variable.
#'
#' @details
#' You can find the id of a folder in Google Drive by right-clicking on the folder, selecting "Get link", and copying the part of the URL that comes after "folders/". For example, if the URL is "https://drive.google.com/drive/folders/1a2b3c4d5e6f7g8h9i0j", then the id of the folder is "1a2b3c4d5e6f7g8h9i0j".
#' If you choose to zip the folder, only the zip file will be uploaded to Google Drive. If you choose to clean up the local files, all files in the input folder will be deleted after uploading.
#'
#' @family download
#'
#' @returns The specified files are uploaded to Google Drive, and optionally the local files are deleted.
#' @export
#' @author Sander Devisscher
#'
#' @examples
#' \dontrun{
#' # upload a folder to Google Drive without zipping and without cleaning up local files
#' folder_to_drive(input_folder = "path/to/your/folder",
#'                 drive_folder = "1a2b3c4d5e6f7g8h9i0j",
#'                 zipfiles = FALSE,
#'                 cleanup = FALSE,
#'                 filetype = "all",
#'                 recursive = FALSE,
#'                 email = Sys.getenv("email"))
#'
#' # upload a folder to Google Drive with zipping and cleaning up local files, only for csv files
#' folder_to_drive(input_folder = "path/to/your/folder",
#'                drive_folder = "1a2b3c4d5e6f7g8h9i0j",
#'                zipfiles = TRUE,
#'                cleanup = TRUE,
#'                filetype = "csv",
#'                recursive = TRUE,
#'                email = Sys.getenv("email"))
#' }
#'
folder_to_drive <- function(input_folder = NULL,
                            drive_folder = NULL,
                            zipfiles = FALSE,
                            cleanup = FALSE,
                            filetype = "all",
                            recursive = FALSE,
                            email = Sys.getenv("email")){
  # 0. authenticate ####
  googledrive::drive_auth(email)

  # 1. Checks & Preparation ####
  if(is.null(input_folder)|!dir.exists(input_folder)){
    stop("input_folder is missing or doesn't exist")
  }

  if(is.null(drive_folder)){
    stop("no drive_folder was provided")
  }

  # 2. list files input ####
  if(filetype == "all"){
    filelist <- list.files(input_folder,
                           full.names = TRUE,
                           recursive = recursive)
  }else{
    filelist <- list.files(input_folder,
                           full.names = TRUE,
                           recursive = recursive,
                           pattern = filetype)
  }

  filelist <- filelist |>
    as.data.frame() |>
    dplyr::mutate(filename = basename(filelist))

  if(nrow(filelist) == 0){
    stop("no files remain to upload, try to widen the filetypes or select another input folder")
  }

  # 3. zip ####
  if(zipfiles){
    zipfile <- paste0(basename(input_folder),"_", filetype, ".zip")
    zipfile_path <- paste0(input_folder, zipfile)

    zip(zipfile = zipfile,
        files = filelist$filelist)

    file.copy(from = zipfile,
              to = zipfile_path)

    file.remove(zipfile)

    filelist <- filelist |>
      dplyr::add_row(filelist = zipfile_path,
              filename = zipfile) |>
      dplyr::filter(filename == zipfile)
  }

  # 4. drive put ####
  if(nrow(filelist) == 1){
    googledrive::drive_put(media = filelist$filelist,
                           path = googledrive::as_id(drive_folder),
                           name = filelist$filename)
  }else{
    for(i in 1:nrow(filelist)){
      googledrive::drive_put(media = filelist$filelist[i],
                             path = googledrive::as_id(drive_folder),
                             name = filelist$filename[i])
    }
  }

  # 5. check upload ####
  uploaded_files <- googledrive::drive_ls(googledrive::as_id(drive_folder))

  testthat::test_that("Not all files are uploaded",
                      testthat::expect_equal(nrow(filelist), nrow(uploaded_files)))

  # 6. cleanup ####
  if(cleanup){
    file.remove(filelist$filelist)
  }
}

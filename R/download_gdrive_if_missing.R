#' Download gdrive if missing
#'
#' @author Sander Devisscher
#'
#' @description This function downloads the specified file from google drive if the destination
#' file does not exist. If it does exist the user will be prompted to download
#' it again.
#'
#' @param gfileID character google file token
#' @param destfile character destination filename with extention
#' @param update_always optional boolean to trigger a download everytime the
#' function is run. default is FALSE.
#' @param email optional character specifying the users email used to access the
#' googledrive file.
#'
#' @details
#' Its best practice to provide the email in encrypted form. This can be easily
#' achieved by adding email as an item in a .renviron file or even beter by using
#' more robust encryption methods.
#'
#' @returns If the destination file was missing it is now downloaded from the
#' googledrive.
#'
#' @examples
#' #' \dontrun{
#' # download newest version of the team charter
#' download_gdrive_if_missing(gfileID = "1gtqcZojPnbLhEgpul3r9sy2zK3UyyCVG",
#'                            destfile = "../../Teamcharters/Teamcharter_FIS.pdf",
#'                            email = Sys.getenv("email")
#'                            update_always = TRUE)
#' }
#'
#' @export

download_gdrive_if_missing <- function(gfileID,
                                       destfile,
                                       update_always = FALSE,
                                       email){
  # Authentication ####
  ## email uit system variables
  if (check(email) == 0) {
    email <- Sys.getenv("email")
    print("extracting email from System variables")
  }

  ## email dmv popup
  if (email == "") {
    email <- svDialogs::dlg_input("je email adres:")
    email <- email$res
  }

  ## Authenticate
  googledrive::drive_auth(email)

  # Check whether file exists locally ####
  ## Check whether destpath exists locally ####
  destpath <- dirname(destfile)

  if(!dir.exists(destpath)){
    # destpath doesn't exist => create ?
    q_create_dir <- askYesNo(msg = paste0(destpath, " aanmaken?"))

    if(q_create_dir == TRUE | update_always == TRUE){
      dir.create(destpath,
                 recursive = TRUE)
    }
  }

  if(update_always == FALSE){
    # update only when file doesn't exist or when user asks for it
    if(file.exists(destfile)){
      # destfile bestaat => update ?
      q_update_destfile <- askYesNo(paste0("update ", gsub(pattern = destpath,
                                                           replacement = "",
                                                           destfile), "?"))
      if(q_update_destfile == TRUE){
        download <- TRUE
      }else{
        download <- FALSE
      }
    }else{
      # destfile bestaat niet => download!
      download <- TRUE
    }
  }else{
    # update everytime
    download <- TRUE
  }

  # Download ####
  if(download == TRUE){
    googledrive::drive_download(googledrive::as_id(gfileID),
                                path = destfile,
                                overwrite = TRUE)
  }
}

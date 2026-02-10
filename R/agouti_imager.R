#' Open sequences in Agouti for imaging
#'
#' @author Lynn Pallemaerts
#' @author Sander Devisscher
#'
#' @description
#' The `agouti_imager` function opens specified sequences in Agouti for editing and tracks which sequences have been processed.
#'
#' @details
#' This function requires the Agouti project ID, project name, and a vector of sequence IDs. It opens each sequence in the default web browser for editing in Agouti. After processing each sequence, the user is prompted to confirm if the sequence is complete. If confirmed, the sequence ID is appended to a tracking file to avoid reprocessing in future runs.
#' To use this function effectively, ensure that you have the Agouti project ID and the sequence IDs you wish to process. The Agouti project ID can typically be found in the URL of your Agouti project.
#' Create a Agouti export or use an existing one to obtain the sequence IDs. A mismatch between the provided Agouti project ID and the sequence IDs may lead to errors.
#' The function uses Google Sheets to maintain the tracking file, requiring authentication via an email address. If the email is not provided, it attempts to retrieve it from system environment variables or prompts the user for input.
#' Make sure to have the `googlesheets4` and `svDialogs` packages installed and properly configured for Google Sheets authentication.
#'
#' Note: Ensure that you have the necessary permissions to access and modify the specified Google Sheet.
#' Note: if a `PERMISSION_DENIED` or `FORBIDDEN` error occurs when you have the correct access to the specified Google Sheet, try the following: `googlesheets4::gs4_deauth()` -> `googlesheets4::gs4_auth()` and select option **1**. After going through the authentication steps, try this function again.
#'
#' @export
#'
#' @param agouti_prj_id The Agouti project ID.
#' @param seqID A vector of sequence IDs to be processed.
#' @param email Optional. The email address used for Google Sheets authentication.
#' Defaults to the "email" system environment variable.
#' @param sheet_id Optional. The Google Sheets ID for tracking processed sequences.
#' Defaults to a predefined sheet ID.
#'
#' @return None. The function opens URLs in the default web browser and updates a tracking file.
#'
#' @family agouti
#'
#' @examples
#' \dontrun{
#'
#' seqID <- c("f9cfa2ac-36a5-45e0-bd84-2b3a5a234ee6",
#' "793b5057-90b3-47db-b400-96b2b31c9b59",
#' "53075b53-dd7b-41b0-b778-394f28e16268",
#'  "560c8d87-ec9a-43f2-adb9-d96a09f589ef",
#'   "7b2d6285-34af-4bd3-b9f9-40022a267ad8")
#'
#' agouti_imager(agouti_prj_id = "e10e6b2b-78fc-44ad-9d66-c4d0b1dd889e",
#' seqID)
#' }

agouti_imager <- function(agouti_prj_id,
                          seqID,
                          email = Sys.getenv("email"),
                          sheet_id = "1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8"){

  #### Checks ####
  if (is.null(agouti_prj_id)) {
    stop("Please provide agouti_prj_id and seqID")
  }

  if(length(seqID) == 0){
    stop("Please provide at least one seqID")
  }

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
  googlesheets4::gs4_auth(email)

  seq_done <- googlesheets4::read_sheet(
    ss = sheet_id,
    sheet = "tracking_seq_done"
  )
  seq_done <- c(seq_done$sequenceID)

  seqID <- seqID[!seqID %in% seq_done]

  # 6 Open sequences in Agouti

  for (i in 1:length(seqID)) {
    # Open URL
    browseURL(url = paste0("https://www.agouti.eu/project/", agouti_prj_id,
                           "/observations/edit-sequence/",
                           seqID[i]))
    # append seqID to done file to skip next time

    # Naar de volgende reeks of niet?
    if (askYesNo("Is de reeks klaar met bewerken in Agouti?")) {
      googlesheets4::sheet_append(
        ss = sheet_id,
        data = data.frame(sequenceID = seqID[i]),
        sheet = "tracking_seq_done"
      )

    }else{
      break
    }
  }
}

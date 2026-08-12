#' Populate agouti_imager_seq_done
#'
#' A script to retrieve locally available seq_done files upload the sequences
#' to the [agouti_imager_seq_done](https://docs.google.com/spreadsheets/d/1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8/edit?gid=0#gid=0) googlesheet.
#'
#' @param dir a character string specifying the directory to look for `seq_done.csv`
#' @param seqID a character list of sequences to add
#' @param email a character specifying your email used to authenticate googlesheet
#' @param sheet_id the character string of the [agouti_imager_seq_done](https://docs.google.com/spreadsheets/d/1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8/edit?gid=0#gid=0) googlesheet
#'
#' @details
#' If both dir and seqID are provided the function will only add the seqIDs.
#'
#' @export
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
#'populate_agouti_imager_seq_done(seqID = seqID)
#' }

populate_agouti_imager_seq_done <- function(dir = NULL,
                                            seqID = NULL,
                                            email = Sys.getenv("email"),
                                            sheet_id = "1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8"){

  googlesheets4::gs4_auth(email = email)

  if(is.null(dir) && is.null(seqID)){
    stop("Provide a dir or a seqID value")
  }

  if(!is.null(seqID) && is.character(seqID)){
    if(!is.null(dir)){
      warning("Both dir & seqID are provided => using seqID")
    }

    googlesheets4::sheet_append(
      ss = sheet_id,
      data = data.frame(sequenceID = seqID),
      sheet = "tracking_seq_done")

  }else{
    if(dir.exists(dir)){
      seq_done_files <- dir(path = dir,
                            pattern = "seq_done.csv",
                            full.names = TRUE,
                            recursive = TRUE)

      seq_done_files_local <- data.frame()

      for(f in seq_done_files){
        temp <- readr::read_csv(f)

        seq_done_files_local <- dplyr::bind_rows()
      }
    }else{
      stop(paste0(dir, " is not found, check for typos"))
    }
  }
}

#' Depopulate agouti_imager_seq_done
#'
#' A script to retrieve locally available seq_done files & remove these
#' sequences from the [agouti_imager_seq_done](https://docs.google.com/spreadsheets/d/1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8/edit?gid=0#gid=0) googlesheet.
#'

depopulate_agouti_imager_seq_done <- function(dir = "./",
                                              seqID,
                                              email = Sys.getenv("email"),
                                              sheet_id = "1PcqJziXm-ZNbCi2JJliQH_FQY8YMPXNEGgYwiiP2Ws8"){

}

#' Download sequence media
#'
#' @author Lynn Pallemaerts
#' @author Emma Cartuyvels
#' @author Sander Devisscher
#' @author Soria Delva
#'
#' @description
#' This function allows the user to download all media related to a Agouti -
#' sequence which matches the given parameters.
#'
#' @param dataset character string, path to the folder where a camptraptor datapackage has been unzipped.
#' @param seqID character string, ID of the sequence to download media from
#' @param favorite boolean, do you only want the pretty pictures?
#' @param outputfolder character string, path where the function should download the media into
#'
#' @details
#' If you are getting an Authorization Error (#403), this probably means your Agouti project has Restrict Images on. This needs to be turned off.
#'
#' @family download
#'
#' @returns Downloads the specified media files into the outputfolder
#'
#' @examples
#' \dontrun{
#' drg <- fistools::drg_example
#'
#' # Situation 1: download whole sequence
#' download_seq_media(dataset = drg,
#'                     seqID = "f4c049d2-d42f-4cd3-a951-fd485ed0279a")
#'
#' # Situation 2: download only favorited species media within sequence
#' download_seq_media(dataset = drg,
#'                     seqID = "f4c049d2-d42f-4cd3-a951-fd485ed0279a",
#'                     favorite = TRUE)
#' }
#'
#' @export
#' @importFrom magrittr %>%

download_seq_media <- function(dataset,
                               seqID,
                               favorite = FALSE,
                               outputfolder = NULL) {

  if (length(seqID) > 1) {
    stop("function can only download one sequence at the time. if you want to download different sequences, use a for-loop")
  }

  if (is.null(outputfolder))  {
    if (dir.exists("../../Mijn afbeeldingen")) {
      output_folder <- paste0("../../Mijn afbeeldingen/", seqID)
    } else {
      stop("output folder is not specified and default does not exist. please specify an output folder !!!")
    }
  } else {
    output_folder <- paste0(outputfolder, "/", seqID)
  }
  if (!dir.exists(output_folder)) {
    dir.create(output_folder)
  }

  med <- dataset$data$media

  if (favorite == TRUE) {
    med <- med %>%
      dplyr::filter(favourite == TRUE)
  }

  med <- med %>%
    dplyr::filter(sequenceID %in% seqID)

  if (nrow(med) > 100 & nrow(med) < 1000) {
    warning("you are trying to download between 100 and 1000 images. this may take a while")
  }
  if (nrow(med) > 1000) {
    continue <-  askYesNo("You are trying to download more than 1000 images. This might take a long time to complete. Are you sure you want to continue?")
    if (continue == FALSE) {
      stop()
    }
  }

  print(paste0("you are downloading ", nrow(med), " images"))

  pb <- progress::progress_bar$new(format = "  [:bar] :percent ETA: :eta",
                                   total = nrow(med),
                                   clear = FALSE,
                                   width = 60)

  for (i in 1:nrow(med)) {
    pb$tick()
    filename <- paste0(stringr::str_sub(med$fileName[i], end = -5),
                       ".jpeg")
    httr::GET(url = med$filePath[i],
              httr::write_disk(path = paste0(output_folder,
                                             "/",
                                             filename),
                               overwrite = TRUE))
  }
}

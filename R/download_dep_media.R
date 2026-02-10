#' Download deployment media
#'
#' @author Lynn Pallemaerts
#' @author Emma Cartuyvels
#' @author Sander Devisscher
#' @author Soria Delva
#'
#' @description
#' This function allows the user to download all media related to a Agouti -
#' dataset which matches the given parameters.
#'
#' @param dataset character string, path to the folder where a camptraptor datapackage has been unzipped.
#' @param depID character string, ID of the deployment to download media from.
#' @param favorite boolean, do you only want the pretty pictures?
#' @param species character string, latin name of the species to download
#' @param outputfolder character string, path where the function should download the media into
#'
#' @details
#' If you are getting an Authorization Error (#403), this probably means your Agouti project has Restrict Images on. This needs to be turned off.
#' If depID = "all" and favorite = TRUE, the function will download all favorited pictures in the whole dataset.
#'
#' @family download
#' @family agouti
#'
#' @returns Downloads the specified media files into the outputfolder
#'
#' @examples
#' \dontrun{
#' drg <- fistools::drg_example
#'
#' # Situation 1: download whole deployment
#' download_dep_media(dataset = drg,
#'                     depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f")
#'
#' # Situation 2: download only wanted species
#' download_dep_media(dataset = drg,
#'                     depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f",
#'                     species = "Dama dama")
#'
#' # Situation 3: download only favorited species media
#' download_dep_media(dataset = drg,
#'                     depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f",
#'                     species = "Dama dama",
#'                     favorite = TRUE)
#'
#' # Situation 4: download only favorited species media
#' download_dep_media(dataset = drg,
#'                     depID = "all",
#'                     favorite = TRUE)

#' }
#'
#' @export
#' @importFrom magrittr %>%

download_dep_media <- function(dataset,
                               depID,
                               species = NULL,   # ONLY LATIN NAMES FOR NOW
                               favorite = FALSE,
                               outputfolder = NULL) {

  if (length(depID) > 1) {
    stop("function can only download one deployment at the time. if you want to download different deployments, use a for-loop")
  }

  if (is.null(outputfolder))  {
    if (dir.exists("../../Mijn afbeeldingen")) {
      output_folder <- paste0("../../Mijn afbeeldingen/", depID)
    } else {
      stop("output folder is not specified and default does not exist. please specify an output folder !!!")
    }
  } else {
    output_folder <- paste0(outputfolder, "/", depID)
  }
  if (!dir.exists(output_folder)) {
    dir.create(output_folder)
  }

  med <- dataset$data$media

  if (depID == "all" & favorite == TRUE) {
    med <- med %>%
      dplyr::filter(favourite == TRUE)

    depID <- unique(med$deploymentID)
  }

  if (!is.null(species)) {
    obs <- dataset$data$observations %>%
      dplyr::filter(scientificName == species)
    med <- med %>%
      dplyr::filter(sequenceID %in% obs$sequenceID)
  }
  if (favorite == TRUE) {
    med <- med %>%
      dplyr::filter(favourite == TRUE)
  }

  med <- med %>%
    dplyr::filter(deploymentID %in% depID)

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

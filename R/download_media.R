#' @author Lynn Pallemaerts
#' @author Emma Cartuyvels
#' @author Sander Devisscher
#'
#' @description
#' This function allows the user to download all media related to a Agouti -
#' dataset which matches the given parameters.
#'
#' @param dataset character string, path to the folder where a camptraptor datapackage has been unzipped.
#' @param location character string, ID of the cameralocation to download media from
#' @param start optional date, startdate of the download
#' @param end  optional data, enddate of the download
#' @param outputfolder character string, path where the function should download the media into
#'
#' @details
#' If you are getting an Authorization Error (#403), this probably means you
#  Agouti project has Restrict Images on. This needs to be turned off.
#'
#'
#' @returns Downloads the specified media files into the outputfolder
#'
#' @examples
#' # unzip camtraptor data package
#' library(camtraptor)
#' unzip("./Grofwild/Drongengoed/Input/Agouti/drongengoed_230601.zip",
#'      exdir = "./Grofwild/Drongengoed/Input/Agouti/drongengoed")
#' drg <- camtraptor::read_camtrap_dp(file = "./Grofwild/Drongengoed/Input/Agouti/drongengoed")
#'
#' # Situation 1: download whole deployment
#' download_media(dataset = drg,
#'                location = "D98_427",
#'                start = "16/12/2022",
#'                outputfolder = "C:/Users/lynn_pallemaerts/Pictures") # If somebody else is testing this: change to your user name
#'
#' # Situation 2: download only wanted species
#' download_media(dataset = drg,
#'                location = "D121_423",
#'                start = "25/03/2023",
#'                species = "Capreolus capreolus",
#'                outputfolder = "C:/Users/lynn_pallemaerts/Pictures") # If somebody else is testing this: change to your user name
#'
#' download_media(dataset = drg,
#'                location = "D55_340",
#'                end = "27/05/2023",
#'                species = "Lepus europaeus",
#'                outputfolder = "C:/Users/lynn_pallemaerts/Pictures") # If somebody else is testing this: change to your user name
#'
#' # Situation 3: Try to download species that is not present
#' download_media(dataset = drg,
#'                location = "D55_340",
#'                end = "27/05/2023",
#'                species = "Dama dama",
#'                outputfolder = "C:/Users/lynn_pallemaerts/Pictures") # If somebody else is testing this: change to your user name
#'
#' # cleanup after use
#' remove(drg)
#' unlink("./Grofwild/Drongengoed/Input/Agouti/drongengoed", recursive = TRUE)

download_media <- function(dataset,
                           location,
                           start = NULL, # AS DD/MM/YYYY
                           end = NULL, # AS DD/MM/YYYY
                           species = NULL,   # ONLY LATIN NAMES FOR NOW
                           outputfolder) {

  #Step 1: parse potential start or end dates
  if (!is.null(start)) {
    start <- lubridate::dmy(start)
  }
  if (!is.null(end)) {
    end <- lubridate::dmy(end)
  }

  #Step 2: create output directory
  if (!is.null(start)) {
    output_folder <- paste0(outputfolder, "/", location, "_S_", start)
    # if there's a start date add it to folder name for convenience
  } else {
    if (!is.null(end)) {
      output_folder <- paste0(outputfolder, "/", location, "_E_", end)
      # if there's a end date add it to folder name for convenience
    } else {
      output_folder <- paste0(outputfolder, "/", location)
      # if there's no date given just use location name
    }
  }
  if (!dir.exists(output_folder)) {
    dir.create(output_folder)
  }

  #Step 3: filter on location
  dep <- dataset$data$deployments %>%
    dplyr::filter(locationName == location)

  if (nrow(dep) == 0) {
    stop("This location name does not exist.")
  }

  #Step 4: filter on given start/end date
  if (!is.null(start)) {
    dep$startdate <- lubridate::date(dep$start)
    # dep <- dep %>%
    #   dplyr::filter(startdate == start)

    #Als filter niet meewerkt moet je gaan for loopen :-p
    dep_sub <- data.frame()
    for (i in 1:nrow(dep)) {
      temp <- dep[i,]

      if (temp$startdate == start) {
        if (nrow(dep_sub) == 0) {
          dep_sub <- temp
        } else {
          dep_sub <- rbind(dep_sub, temp)
        }
        remove(temp)
      }
    }
    dep <- dep_sub
  }

  if (!is.null(end)) {
    dep$enddate <- lubridate::date(dep$end)
    # dep <- dep %>%
    #   dplyr::filter(enddate == end)

    #Als filter niet meewerkt moet je gaan for loopen :-p
    dep_sub <- data.frame()
    for (i in 1:nrow(dep)) {
      temp <- dep[i,]

      if (temp$enddate == end) {
        if (nrow(dep_sub) == 0) {
          dep_sub <- temp
        } else {
          dep_sub <- rbind(dep_sub, temp)
        }
        remove(temp)
      }
    }
    dep <- dep_sub
  }

  #Step 5: check that you are only looking at one deployment to download
  if (nrow(dep) > 1) {
    stop("This location name is not unique. Provide a start or end date.")
  }

  #Step 6: get deployment ID to filter out the required media
  depID <- dep$deploymentID
  med <- dataset$data$media %>%
    dplyr::filter(deploymentID == depID)   # This is the whole deployment

  #Step 7: search the deployment for the wanted observations
  if (!is.null(species)) {
    seq <- dataset$data$observations %>%
      dplyr::filter(deploymentID == depID) %>%
      dplyr::filter(scientificName == species)
    if (nrow(seq) == 0) {
      stop("There are no observations of this species in this deployment.")
    }
    seqID <- c(seq$sequenceID)
    med <- med %>%
      dplyr::filter(sequenceID %in% seqID)
  }

  #Step 7: download the media
  for (i in 1:nrow(med)) {
    filename <- paste0(stringr::str_sub(med$fileName[i], end = -5),
                       ".jpeg")
    httr::GET(url = med$filePath[i],
        httr::write_disk(path = paste0(output_folder,
                                 "/",
                                 filename),
                   overwrite = TRUE))
  }
}

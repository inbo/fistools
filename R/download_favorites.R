#' Download all favorited camera trap pictures from an Agouti export
#'
#' @author Lynn Pallemaerts
#'
#' @description
#' A simple function to list download all the pictures that were favorited in an Agouti project.
#'
#' @param dataset Agouti export
#'
#' @return
#' a folder in the user's Pictures folder containing all the individual photographs.
#'
#' @examples
#' \dontrun{
#' # read example export
#' unzip("./data_raw/drongengoed.zip",
#'       exdir = "./data_raw/drongengoed_files")
#' drg <- camtraptor::read_camtrap_dp("./data_raw/drongengoed_files")
#' download_favorites(drg)
#' unlink(./data_raw/drongengoed_files)
#' remove(drg)
#' }
#'
#' @export
#' @importFrom magrittr %>%
#'
download_favorites <- function(dataset) {

  # Setup
  devtools::install_github("inbo/camtraptor")
  require(camtraptor)
  require(httr)
  require(tidyverse)
  conflicted::conflicts_prefer(dplyr::filter)

  # Set output folder
  output_folder <- paste0("C:/Users/lynn_pallemaerts/Pictures/", # HOE PAS IK DIT AAN OM DE HUIDIGE USER TE HEBBEN?
                          dataset,
                          "_favorites")

  # Subset for favorites
  med <- dataset$data$media
  fav <- med %>%
    filter(favourite == TRUE)

  # Download
  for (i in 1:nrow(fav)) {
    filename <- paste0(str_sub(fav$fileName[i], end = -5),
                       ".jpeg")
    httr::GET(url = fav$filePath[i],
              write_disk(path = paste0(output_folder,
                                       "/",
                                       filename),
                         overwrite = T))
  }

}


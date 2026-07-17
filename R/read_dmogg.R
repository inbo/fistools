#' Read "dieren met onderkaakgegevens georef"
#'
#' This function reads the most up to date version of the
#' dieren met onderkaakgegevens georef (DMOGG) file from the backoffice wild
#' analyse.
#'
#' @param type "short" or "long" indicating which version you want to import.
#' The default is "short". See details for more info.
#' @param email email used to authenticate the google drive
#'
#' @details
#' This function can import two versions of the DMOGG dataset:
#'
#' - The *"Short"* version: Contains data collected via the e-loket and, later,
#'   the ANB's WIZ-app, enriched with data from the autopsiedb. Its temporal
#'   range spans from 2014 to the present. This dataset is more comprehensive
#'   and includes spatial data for WBEs and FBZs. It also contains data on
#'   causes of death other than culling (mainly "valwild") and exotic species
#'   (such as raccoon, muntjac, and sika deer).
#'
#' - The *"Long"* version: Combines older data collected by INBO via e-loket
#'   predecessors (e.g., zwijntje) with the subset of the "Short" version
#'   that specifically concerns culling (`doodsoorzaak == "afschot"`) and a
#'   select group of species (e.g., roe deer, wild boar, red deer, and fallow
#'   deer). This dataset is less comprehensive because the early data
#'   (pre-2014) lacks almost all spatial information.
#'
#' This function uses `fistools::download_gdrive_if_missing()` under the hood to
#' download the file from the google drive.
#'
#' @returns a dataframe containing the most recent DMOGG data.
#'
#' @family download
#' @export
#'
#' @author Sander Devisscher
#' @examples
#' \dontrun{
#' # read the most recent short DMOGG data
#' dmogg <- read_dmogg()
#' }
#'

read_dmogg <- function(type = "short",
                       email = Sys.getenv("email")){

  # Checks ####
  ## Type ####
  type <- tolower(type)

  if(!type %in% c("short", "long")){
    stop(paste("Type is not valid, it should be short or long not ", type))
  }

  ## Email ####
  if(email == ""){
    email = svDialogs::dlg_input("je email adres:")
    email <- email$res
  }

  # Download file ####

  dest_file <- paste0(tempdir(), "/temp_dmogg.csv")

  ## Short ####
  if(type == "short"){
    #"1IfezXM56qAJijb-qV9TmzimR8oXPtIcy"
    fistools::download_gdrive_if_missing(gfileID = "1IfezXM56qAJijb-qV9TmzimR8oXPtIcy",
                                         destfile = dest_file,
                                         update_always = TRUE,
                                         email = email)
  }

  ## Long ####
  if(type == "long"){
    #"1VUUkwtZYWdzJRpM725D7-9Z5HOYN2cO-"
    fistools::download_gdrive_if_missing(gfileID = "1VUUkwtZYWdzJRpM725D7-9Z5HOYN2cO-",
                                         destfile = dest_file,
                                         update_always = TRUE,
                                         email = email)
  }

  # Read file ####
  temp_Backoffice_all <- readr::read_delim(dest_file, delim = ";",
                                           col_types = readr::cols(afschot_datum2 = readr::col_date(format = "%Y-%m-%d"),
                                                            afschot_tijdstip = readr::col_time("%H:%M:%S"),
                                                            PuntLocatieTypeID = readr::col_integer(),
                                                            Xcoordinaat.x = readr::col_double(),
                                                            Ycoordinaat.y = readr::col_double(),
                                                            aantal_embryos_labo = readr::col_character(),
                                                            opmerkingen.x = readr::col_character(),
                                                            opmerkingen.y = readr::col_character(),
                                                            opmerkingen_laboratorium = readr::col_character(),
                                                            retournering = readr::col_character(),
                                                            leeftijdcategorie_onderkaak_gs = readr::col_character(),
                                                            hulpmiddel_comp = readr::col_character()))

  # Cleanup ####
  file.remove(dest_file)

  # Return ####
  return(temp_Backoffice_all)
}

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
#' Two versions of the DMOGG dataset can be imported by this function, namely:
#' - The "Short" version containing only data collected via the e-loket and later
#' WIZ-app from ANB enriched with data from the autopsiedb.
#' The temporal range of this dataset is 2014 - today.
#' This dataset is more complete and contains spatial data concerning wbe's & fbz's.
#' - The "Long" version containing the data from the "Short" dataset plus data
#' collected via the predecessors of the e-loket (ao zwijntje) by INBO.
#' This dataset is less complete because early data (<2014) misses almost all spatial info.
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

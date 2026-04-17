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
                                           col_types = cols(afschot_datum2 = col_date(format = "%Y-%m-%d"),
                                                            afschot_tijdstip = col_time("%H:%M:%S"),
                                                            PuntLocatieTypeID = col_integer(),
                                                            Xcoordinaat.x = col_double(),
                                                            Ycoordinaat.y = col_double(),
                                                            aantal_embryos_labo = col_character(),
                                                            opmerkingen.x = col_character(),
                                                            opmerkingen.y = col_character(),
                                                            opmerkingen_laboratorium = col_character(),
                                                            retournering = col_character(),
                                                            leeftijdcategorie_onderkaak_gs = col_character(),
                                                            hulpmiddel_comp = col_character()))

  # Cleanup ####
  file.remove(dest_file)

  # Return ####
  return(temp_Backoffice_all)
}

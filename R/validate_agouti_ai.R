validate_agouti_ai <- function(gfileID,
                               ai_model = "Europe",
                               agouti_prj_id,
                               species = NULL,
                               email){

  # Check for required parameters ####
  ## gfileID
  if(is.null(gfileID)){
    stop("gfileID is required")
  }

  ## email
  if (fistools::check(email) == 0 ) {
    email <- Sys.getenv("email")
    print("extracting email from System variables")
  }

  if(email == ""){
    email <- svDialogs::dlg_input("je email adres:")
    email <- email$res
  }

  # Download the file from Google Drive using download_gdrive_if_missing ####
  fistools::download_gdrive_if_missing(gfileID = gfileID,
                                       email = email,
                                       destfile = paste0(tempdir(),
                                                         "/datapack.zip"),
                                       update_always = TRUE)

  exdir <- file.path(tempdir(), "/Files")
  unzip(paste0(tempdir(), "/datapack.zip"),
        exdir = exdir)

  # Read datapackage using camtraptor ####
  datapack <- camtraptor::read_camtrap_dp(file = exdir)

  data <- datapack$data$observations %>%
    dplyr::filter(grepl(pattern = ai_model,
                        "classifiedBy"))

  if(nrow(data) == 0){
    stop(paste0("no observations found classified by ", ai_model))
  }

  if(fistools::check(species) == 0){
    q_species <- svDialogs::dlg_list("Welke soort wil je controleren? (gebruik de wetenschappelijke naam, bijv. 'Lynx lynx')",
                                     choices = unique(data$scientificName),
                                     multiple = TRUE)

    species <- q_species$res
  }

  if(length(species) == 0){
    stop("Please select at least one species to validate")
  }

  species_data <- data %>%
    dplyr::filter(scientificName %in% species)

  if(nrow(species_data) == 0){
    stop("No observations found for the selected species")
  }

  print(paste0("Found ", nrow(species_data), " observations for the selected species classified by ", ai_model))

  # Extract sequence IDs and open in Agouti using agouti_imager ####
  seqIDs <- unique(species_data$sequenceID)

  fistools::agouti_imager(agouti_prj_id = agouti_prj_id,
                          seqID = seqIDs,
                          email = email,
                          skip_tracking = TRUE)
}

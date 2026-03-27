#' Validate AI classifications in Agouti
#'
#' @description
#' This function allows you to validate AI classifications in Agouti by
#' downloading a datapackage from Google Drive, filtering observations based on
#' the specified AI model and species, and opening the relevant sequence IDs in
#' Agouti for manual validation.
#'
#' @param gfileID The Google Drive file ID of the datapackage to be downloaded.
#' @param ai_model The name of the AI model used for classification (e.g., "Europe"). Default is "Europe".
#' @param agouti_prj_id The Agouti project ID where the sequences will be opened for validation.
#' @param species Optional. A vector of species (scientific names) to filter the
#' observations for validation. If NULL, the user will be prompted to select species
#' from the available options.
#' @param email Optional. The email address used for authentication when downloading the
#' datapackage from Google Drive. If not provided, the function will attempt to
#' retrieve it from system environment variables or prompt the user for input.
#'
#' @details
#' The function performs the following steps:
#' 1. Checks for the required parameters and prompts the user if necessary.
#' 2. Downloads the specified datapackage from Google Drive using the provided file ID.
#' 3. Unzips the downloaded datapackage and reads it using the `camtraptor` package.
#' 4. Filters the observations based on the specified AI model and species.
#' 5. Extracts the unique sequence IDs from the filtered observations and opens them in Agouti for manual validation using the `agouti_imager` function.
#' 6. The user can validate the classifications in Agouti
#' *NOTE:* This function doesn't track which sequences have been validated!
#'
#' @family agouti
#' @author Sander Devisscher
#' @returns None. The function opens URLs in the default web browser for validation.
#' @export
#'
#' @examples
#' \dontrun{
#' validate_agouti_ai(gfileID = "your_google_drive_file_id",
#'                    ai_model = "Europe",
#'                    agouti_prj_id = "your_agouti_project_id",
#'                    species = c("Lynx lynx", "Canis lupus"))
#' }
#'
#'
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

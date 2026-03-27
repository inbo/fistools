validate_agouti_ai <- function(gfileID,
                               ai_model = "Europe",
                               species = NULL,
                               email = Sys.getenv("email")){

  # Check for required parameters ####
  if(is.null(gfileID)){
    stop("gfileID is required")
  }

  # Download the file from Google Drive using download_gdrive_if_missing ####

  # Read datapackage




  if(is.null(species)){
    species <- svDialogs::
  }

}

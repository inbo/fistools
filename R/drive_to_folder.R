drive_to_folder <- function(drive_folder = NULL,
                            output_folder = NULL,
                            filetypes = "all",
                            email = Sys.getenv("email")){

  # 0. authenticate ####
  googledrive::drive_auth(email)

  # 1. checks & preparation ####
  if(is.null(output_folder)){
    warning("No output folder provided. Using current working directory.")
    output_folder <- getwd()
  }

  if(is.null(drive_folder)){
    stop("No drive folder provided. Please provide a valid Google Drive folder URL or ID.")
  }

  # 2. get drive folder info ####
  files_on_drive <- tryCatch({
    googledrive::drive_ls(googledrive::as_id(drive_folder))
  }, error = function(e){
    stop("Error retrieving drive folder information. Please check the provided URL or ID.")
  })

  # 3. filter files by type if needed ####
  if("all" %in% filetypes){
    if(length(filetypes) == 1){
      filetypes[i] <- paste0("\\.", filetypes, "$")
      files_on_drive <- files_on_drive |>
        dplyr::filter(grepl(filetypes, name))
    }else{
      for(i in seq_along(filetypes)){
        filetypes[i] <- paste0("\\.", filetypes[i], "$")

        files_on_drive <- files_on_drive |>
          dplyr::filter(grepl(filetypes[i], name))
      }
    }
  }

  if(nrow(files_on_drive) == 0){
    stop("No files found in the specified drive folder with the given file types.")
  }

  # 4. download files ####
  for(i in 1:nrow(files_on_drive)){
    tryCatch({
      googledrive::drive_download(file = files_on_drive$id[i],
                                  path = file.path(output_folder, files_on_drive$name[i]),
                                  overwrite = TRUE)
    }, error = function(e){
      warning(paste0("Error downloading file: ", files_on_drive$name[i], ". Skipping this file."))
    })
  }
}

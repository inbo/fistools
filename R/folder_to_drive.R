folder_to_drive <- function(input_folder = NULL,
                            drive_folder,
                            zipfiles = FALSE,
                            cleanup = TRUE,
                            filetype = "all",
                            recursive = FALSE,
                            email = Sys.getenv("email")){
  # 0. authenticate ####
  googledrive::drive_auth(email)

  # 1. Checks & Preparation ####
  if(is.null(input_folder)|!dir.exists(input_folder)){
    stop("input_folder is missing or doesn't exist")
  }

  if(is.null(drive_folder)){
    stop("no drive_folder was provided")
  }

  # 2. list files input ####
  if(filetype == "all"){
    filelist <- list.files(input_folder,
                           full.names = TRUE,
                           recursive = recursive)
  }else{
    filelist <- list.files(input_folder,
                           full.names = TRUE,
                           recursive = recursive,
                           pattern = filetype)
  }

  filelist <- filelist |>
    as.data.frame() |>
    dplyr::mutate(filename = basename(filelist))

  if(nrow(filelist) == 0){
    stop("no files remain to upload, try to widen the filetypes or select another input folder")
  }

  # 3. zip ####
  if(zipfiles){
    zipfile <- paste0(basename(input_folder),"_", filetype, ".zip")
    zipfile_path <- paste0(input_folder, zipfile)

    zip(zipfile = zipfile,
        files = filelist$filelist)

    file.copy(from = zipfile,
              to = zipfile_path)

    file.remove(zipfile)

    filelist <- filelist |>
      dplyr::add_row(filelist = zipfile_path,
              filename = zipfile) |>
      dplyr::filter(filename == zipfile)
  }

  # 4. drive put ####
  if(nrow(filelist) == 1){
    googledrive::drive_put(media = filelist$filelist,
                           path = googledrive::as_id(drive_folder),
                           name = filelist$filename)
  }else{
    for(i in 1:nrow(filelist)){
      googledrive::drive_put(media = filelist$filelist[i],
                             path = googledrive::as_id(drive_folder),
                             name = filelist$filename[i])
    }
  }

  # 5. check upload ####
  uploaded_files <- googledrive::drive_ls(googledrive::as_id(drive_folder))

  testthat::test_that("Not all files are uploaded",
                      testthat::expect_equal(nrow(filelist), nrow(uploaded_files)))

  # 6. cleanup ####
  if(cleanup){
    file.remove(filelist$filelist)
  }
}

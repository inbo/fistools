#' Rename camera trap files for upload in Agouti
#'
#' @author: Lynn Pallemaerts and Someone Before Her
#'
#' @description Function that rename camera trap files (i.e. photos) by
#' appending folder name (e.g. 1000RECX) to file name (e.g. IMG0001) to create
#' all unique file names across a deployment. Needed for deployments with more
#' than 9999 pictures, so they can be uploaded in Agouti. This is a copy of the
#' old `rename_file_names()` in the old `fis-projecten` (archived).
#'
#' @param foldername DCIM folder to be treated
#' @param extensions file extensions to be rename. Default is jpg, jpeg, bmp and png
#' @param compile logical. If TRUE, all files will be compiled in a single folder
#'
#' @details
#' This function will rename all files in the subfolders of the folder specified
#' by foldername. If no foldername is provided, the user will be prompted to
#' select a folder. The function will rename all files with the extensions
#' specified in the extensions argument. The function will also compile all files
#' in a single folder if compile is set to TRUE.
#'
#' @returns renamed picture files in the original folder
#'
#' @examples
#' \dontrun{
#' tempzip <- tempfile(fileext = ".zip")
#' fistools::download_gdrive_if_missing(gfileID = "1-84hbKouLKGwnLgBSRaQO1BnfogoFZWz",
#'                                      destfile = tempzip,
#'                                      email = Sys.getenv("email"),
#'                                      update_always = TRUE)
#'
#' foldername <- paste0(tempdir(), "/test_case_renaming")
#' unzip(tempzip,
#'       exdir = tempdir())
#' rename_ct_files(foldername)
#' browseURL(foldername)
#' unlink(foldername,
#'        recursive = TRUE)
#'
#' # The function also works when no foldername is provided
#' rename_ct_files()
#'
#' # The function can also compile all files in a single folder
#' rename_ct_files(foldername, compile = TRUE)
#' browseURL(foldername)
#' unlink(foldername,
#'        recursive = TRUE)
#'}
#'
#' @export

rename_ct_files <- function(foldername,
                            extensions = c("jpg", "png", "jpeg", "bmp"),
                            compile = FALSE) {

  # test whether foldername is missing & prompt a browser when it is
  if (rlang::is_missing(foldername)) {
    foldername <- tcltk::tclvalue(tcltk::tkchooseDirectory())
  }

  # test whether foldername is a folder & exists
  if (!dir.exists(foldername)) {
    stop("Folder does not exist")
  }

  # list all the files in the subfolders and prepare new file names
  images <- dir(foldername, recursive = TRUE,  full.names = FALSE) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    dplyr::select(filename = ".") %>%
    dplyr::filter(grepl(paste0(extensions, collapse = "|"), tolower(filename))) %>%
    dplyr::mutate(subfolder = dirname(filename)) %>%
    dplyr::mutate(foldername = foldername) %>%
    dplyr::mutate(new_filename = gsub("/", "_", filename)) %>%
    dplyr::mutate(full_filename = as.character(file.path(foldername, filename))) %>%
    dplyr::mutate(full_new_filename = as.character(file.path(foldername, subfolder, new_filename)))

  # execute file renaming
  file.rename(images$full_filename, images$full_new_filename)

  # compile all files in a single folder
  if (compile) {
    images_compile <- images %>%
      dplyr::mutate(full_new_filename_compiled = paste0(foldername, "/compiled/", new_filename))

    dir.create(paste0(foldername, "/compiled"))

    file.copy(images_compile$full_new_filename, images_compile$full_new_filename_compiled)
  }
}

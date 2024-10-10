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
#'
#' @returns renamed picture files in the original folder
#'
#' @examples
#' \dontrun{
#' foldername <- "./data/test_case_renaming/"
#' rename_file_names(foldername)
#'
#' #'@export

rename_file_names <- function(foldername,
                              extensions = c("jpg", "png", "jpeg", "bmp")) {

  require(dplyr)
  require(stringr)

  # list all the files in the subfolders and prepare new file names
  images <- dir(foldername, recursive = TRUE,  full.names = FALSE) %>%
    as.data.frame(stringsAsFactors = FALSE) %>%
    select(filename = ".") %>%
    filter(grepl(paste0(extensions, collapse = "|"), str_to_lower(filename))) %>%
    mutate(subfolder = dirname(filename)) %>%
    mutate(foldername = foldername) %>%
    mutate(new_filename = gsub("/", "_", filename)) %>%
    mutate(full_filename = as.character(file.path(foldername, filename))) %>%
    mutate(full_new_filename = as.character(file.path(foldername, subfolder, new_filename)))

  # execute file renaming
  file.rename(images$full_filename, images$full_new_filename)

})

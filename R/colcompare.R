#' Columnname comparison
#'
#' @author Sander Devisscher
#'
#' @description
#' A simple function to list the difference in column names in 2 datasets.
#'
#' @param x dataframe 1
#' @param y dataframe 2
#'
#' @return
#' a list of columns present in x but not in y and a list of columns
#' present in y and not in x.
#'
#' @family column comparison
#'
#' @examples
#' \dontrun{
#' # create example dataframes
#' super_sleepers <- data.frame(rating=1:4,
#' animal=c('koala', 'hedgehog', 'sloth', 'panda'),
#' country=c('Australia', 'Italy', 'Peru', 'China'),
#' avg_sleep_hours=c(21, 18, 17, 10))
#'
#' super_actives <- data.frame(rating=1:4,
#' animal=c('kangeroo', 'wolf', 'jaguar', 'tiger'),
#' country=c('Australia', 'Italy', 'Peru', 'China'),
#' avg_active_hours=c(16, 15, 8, 10))
#'
#' colcompare(super_sleepers, super_actives)
#' }
#'
#' @export
#' @importFrom magrittr %>%

colcompare <- function(x, y){

  test_xiny <- subset(colnames(x), !colnames(x) %in% colnames(y))
  test_xiny <- as.data.frame(test_xiny) %>%
    dplyr::mutate(lower = tolower(test_xiny))
  test_yinx <- subset(colnames(y), !colnames(y) %in% colnames(x))
  test_yinx <- as.data.frame(test_yinx) %>%
    dplyr::mutate(lower = tolower(test_yinx))

  combined <- test_xiny %>%
    dplyr::full_join(test_yinx, by = "lower")

  # Typos (x en y) ####
  test_xANDy <- combined %>%
    dplyr::filter(!is.na(test_xiny) & !is.na(test_yinx)) %>%
    dplyr::mutate(test_xANDy = paste0("X: ", test_xiny, " <==> ", test_yinx, " :Y \n"))
  test_xANDy <- test_xANDy$test_xANDy

  if(check(test_xANDy) == 1){
    if(!rlang::is_empty(test_xANDy)){
      error <- paste0("Kolommen met verschillende schrijfwijze: \n",
                     test_xANDy)
      writeLines(error)
      print("=====================================================================")
    }
  }
  # Only X ####
  test_xiny <- combined %>%
    dplyr::filter(is.na(test_yinx))
  test_xiny <- test_xiny$test_xiny

  if(check(test_xiny)==1){
    if(!rlang::is_empty(test_xiny)){
      test_xiny <- paste(test_xiny, collapse = ", \n")
      error <- paste0("Kolommen uit x die niet in y voorkomen: \n", test_xiny)
      writeLines(error)
      print("=====================================================================")
    }
  }

  # Only y ####
  test_yinx <- combined %>%
    dplyr::filter(is.na(test_xiny))
  test_yinx <- test_yinx$test_yinx

  if(check(test_yinx)==1){
    if(!rlang::is_empty(test_yinx)){
      test_yinx <- paste(test_yinx, collapse = ", \n")
      error <- paste0("Kolommen uit y die niet in x voorkomen: ", test_yinx)
      writeLines(error)
    }
  }
}

#' cleanup sqlite
#'
#' @param db name of the temporary .sqlite db to be removed
#'
#' @description
#' A helper script to cleanup after use of apply_gtrsdb.
#'
#' @export

cleanup_sqlite <- function(db="grts.sqlite"){
  unlink(db,
         recursive = TRUE,
         force = TRUE)

  file.remove(db)
}

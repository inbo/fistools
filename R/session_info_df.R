#' Export sessionInfo as data.frames for easy sharing & comparison
#'
#' @description
#' A function to export sessionInfo as data.frames to allow easy sharing
#' and comparison between users.
#'
#' @param x A `sessionInfo()`-like list. Default is the current session info.
#'
#' @return A list with three data.frames: `r_info`, `rstudio`, and `packages`.
#'
#' @examples
#' \dontrun{
#' # Get user 1 session info as data.frames & export to CSV files
#' user1_sessioninfo_df <- session_info_df()
#'
#' write.csv(user1_sessioninfo_df$packages, "user1_packages.csv", row.names = FALSE)
#' write.csv(user1_sessioninfo_df$r_info,    "r_info.csv",        row.names = FALSE)
#'
#' # rstudio element may be NULL if not running in RStudio
#' if (!is.null(user1_sessioninfo_df$rstudio)) {
#'   write.csv(user1_sessioninfo_df$rstudio, "rstudio_info.csv", row.names = FALSE)
#' }
#'
#' # Get user 2 session info and compare with user 1
#' user2_sessioninfo_df <- session_info_df()
#' user1_packages <- read.csv("user1_packages.csv", stringsAsFactors = FALSE)
#'
#' # Compare packages by package name
#' merged_pkgs <- merge(
#'   user1_packages,
#'   user2_sessioninfo_df$packages,
#'   by = "package",
#'   suffixes = c("_user1", "_user2"),
#'   all = TRUE
#' )
#'
#' # Find packages that differ in version or are missing in one of the users
#' differing_pkgs <- merged_pkgs[
#'   merged_pkgs$version_user1 != merged_pkgs$version_user2 |
#'     is.na(merged_pkgs$version_user1) |
#'     is.na(merged_pkgs$version_user2),
#' ]
#'
#' differing_pkgs
#' }
#'
#' @export
#' @author Sander Devisscher
#' @seealso \code{\link[utils]{sessionInfo}}
session_info_df <- function(x = utils::sessionInfo()) {
  `%||%` <- function(a, b) if (is.null(a)) b else a

  # ---- R / OS / locale ----
  r_info <- data.frame(
    key   = c("R.version", "platform", "running", "locale", "timezone"),
    value = c(
      R.version.string,
      x$platform,
      x$running,
      paste(x$locale, collapse = "; "),
      as.character(Sys.timezone())
    ),
    stringsAsFactors = FALSE
  )

  # ---- RStudio info (if available) ----
  rs_info <- tryCatch({
    if (requireNamespace("rstudioapi", quietly = TRUE) &&
        rstudioapi::isAvailable()) {
      v <- tryCatch(rstudioapi::versionInfo(), error = function(e) NULL)
      if (!is.null(v)) {
        data.frame(
          key   = c("RStudio.mode", "RStudio.version", "RStudio.release_name"),
          value = c(v$long_version),
          stringsAsFactors = FALSE
        )
      } else NULL
    } else NULL
  }, error = function(e) NULL)

  # ---- package info ----
  pkg_list_to_df <- function(pkgs, type) {
    if (length(pkgs) == 0L) return(NULL)
    as.data.frame(
      do.call(
        rbind,
        lapply(pkgs, function(p) {
          data.frame(
            package   = p$Package,
            version   = p$Version,
            priority  = `%||%`(p$Priority, NA_character_),
            is_base   = identical(type, "base"),
            loaded_as = type,
            stringsAsFactors = FALSE
          )
        })
      ),
      stringsAsFactors = FALSE
    )
  }

  base_df <- if (!is.null(x$basePkgs)) {
    data.frame(
      package   = x$basePkgs,
      version   = NA_character_,
      priority  = NA_character_,
      is_base   = TRUE,
      loaded_as = "base",
      stringsAsFactors = FALSE
    )
  } else NULL

  attached_df <- pkg_list_to_df(x$otherPkgs, "attached")
  loaded_df   <- pkg_list_to_df(x$loadedOnly, "loaded")

  pkgs_df <- do.call(
    rbind,
    Filter(Negate(is.null), list(base_df, attached_df, loaded_df))
  )
  rownames(pkgs_df) <- NULL

  list(
    r_info   = r_info,
    rstudio  = rs_info,
    packages = pkgs_df
  )
}

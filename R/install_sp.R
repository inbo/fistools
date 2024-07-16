#' install sp
#'
#' Helper function that installs sp when missing, from a tarball.
#'
#' @details
#' The "sp" package should be unloaded from the namespace when it is not needed anymore.
#' Every function that uses "sp" should start with a call to this function.
#' And end with a call to `unloadNamespace("sp")`.#'
#'
#' @importFrom utils install.packages
#'
#' @export
#'
#' @author Sander Devisscher

install_sp <- function() {
  if (!requireNamespace("sp", quietly = TRUE)) {
    install.packages(, dependencies = TRUE)
  }
}

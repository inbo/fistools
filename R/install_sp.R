#' install sp
#'
#' Helper function that installs sp when missing, from a tarball.
#'
#' @details
#' The "sp" package should be unloaded from the namespace when it is not needed anymore.
#' Every function that uses "sp" should start with a call to this function.
#' And end with a call to `unloadNamespace("sp")`.
#' This is because the "sp" package is known to cause conflicts with other packages.
#'
#' @param force A logical indicating whether the installation should be forced
#'
#' @importFrom utils install.packages
#'
#' @export
#' @family other
#'
#' @author Sander Devisscher

install_sp <- function(force = FALSE) {
  if (!rlang::is_installed("sp")) {
    print("sp is not installed, installing it now")
    # download the tarball from CRAN https://cran.r-project.org/src/contrib/Archive/sp/sp_2.1-3.tar.gz
    # and place it in a temporary directory
    tempfile <- tempfile()
    download.file("https://cran.r-project.org/src/contrib/Archive/sp/sp_2.1-3.tar.gz", destfile = tempfile)

    # install the tarball
    install.packages(tempfile, repos = NULL, type = "source", force = force)
  }
  print("sp is installed \U0001F389")
}

#' install depricated package
#'
#' Helper function that installs depricated package when missing, from a tarball.
#'
#' @param package_name A character string indicating the name of the package to be installed
#' @param version A character string indicating the version of the package to be installed
#' @param force A logical indicating whether the installation should be forced
#'
#' @details
#' Sometimes a package is depricated and no longer available on CRAN.
#' This function allows you to install a depricated package from a tarball.
#' It is recommended to use this function only when necessary.
#' In first instance try to find an alternative package.
#' Using depricated packages may cause conflicts and unexpected behaviour.
#'
#' @importFrom utils install.packages
#'
#' @export
#' @family other
#' @examples
#' \dontrun{
#' # install latest version of sp package instead of install_sp()
#' install_depricated("sp", "2.1-3")
#' # trying to install a wrong version of maptools
#' install_depricated("maptools", "2.1-3", force = TRUE)
#'
#' }
#'
#' @author Sander Devisscher

install_depricated <- function(package_name,
                               version,
                               force = FALSE) {
  if (!rlang::is_installed(package_name)) {
    message(paste0(package_name, " is not installed, installing it now"))
    # download the tarball from CRAN https://cran.r-project.org/src/contrib/Archive/sp/sp_2.1-3.tar.gz
    # and place it in a temporary directory
    # create url
    version_url <- paste0("https://cran.r-project.org/src/contrib/Archive/", package_name, "/", package_name, "_", version, ".tar.gz")

    # test url
    test_version_url <- RCurl::url.exists(version_url)

    # create tempfile
    tempfile <- tempfile()

    # download the tarball if url exists
    if(test_version_url == FALSE){
      warning(paste0(package_name, " version ", version, " is not available on CRAN"))
      package_url <- paste0("https://cran.r-project.org/src/contrib/Archive/", package_name)
      test_package_url <- RCurl::url.exists(package_url)

      if(test_package_url == TRUE ){
        if(askYesNo("You are trying to install a non existing version of the package. Do you want to browse the CRAN Archive to look up a usable version?") == TRUE){
          browseURL(paste0("https://cran.r-project.org/src/contrib/Archive/", package_name))
        }
      } else {
        stop("The package is not available on the CRAN archive")
      }
    } else {
      download.file(version_url, destfile = tempfile)
    }

    # install the tarball
    install.packages(tempfile, repos = NULL, type = "source", force = force)
  }
  if(rlang::is_installed(package_name) == TRUE){
    print(paste0(package_name, " is installed \U0001F389"))
  }
}

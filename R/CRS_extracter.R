#' CRS_extracter
#'
#' Extracts a coordinate reference system (CRS) from a library of commonly used CRS codes
#'
#' @param CRS A character string with the name of the CRS
#' @param EPSG A logical indicating whether the output should be in EPSG format
#'
#' @return A CRS object
#'
#' @examples
#' \dontrun{
#' crs_wgs <- CRS_extracter("WGS", EPSG = FALSE)
#' crs_bel72 <- CRS_extracter("BEL72", EPSG = FALSE)
#'
#' epsg_wgs <- CRS_extracter("WGS", EPSG = TRUE)
#' }
#'
#'
#' @export
#' @author Sander Devisscher

CRS_extracter <- function(CRS, EPSG = TRUE){

  Lib_CRS <- lib_crs

  if(grepl("wgs", CRS, ignore.case = TRUE)){
    CRS <- "WGS"
  }

  if(grepl("bel", CRS, ignore.case = TRUE)){
    CRS <- "BEL72"
  }

  if(EPSG == TRUE){
    CRS_output <- sp::CRS(Lib_CRS$EPSG[CRS == Lib_CRS$CRS_Naam])
  }else{
    CRS_output <- sp::CRS(Lib_CRS$Proj4s[CRS == Lib_CRS$CRS_Naam])
  }

  return(CRS_output)
}

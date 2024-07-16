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
#' }
#'
#'
#' @export
#' @author Sander Devisscher

CRS_extracter <- function(CRS, EPSG = TRUE){

  Lib_CRS <- "lib_crs"

  if(grepl("wgs", CRS, ignore.case = TRUE)){
    CRS <- "WGS"
  }

  if(grepl("bel", CRS, ignore.case = TRUE)){
    CRS <- "BEL72"
  }

  if(WKT == TRUE){
    CRS_output <- CRS(Lib_CRS$WKT[CRS == Lib_CRS$CRS_Naam])
  }else{
    CRS_output <- CRS(Lib_CRS$Proj4s[CRS == Lib_CRS$CRS_Naam])
  }
 return(CRS_output)
}

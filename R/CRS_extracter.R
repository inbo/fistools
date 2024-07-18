#' CRS_extracter
#'
#' Extracts a coordinate reference system (CRS) from a library of commonly used CRS codes
#' This also fixes issues with the belge lambert 72 we use.
#' The EPSG code is 31370, but the proj4string is not the same as the one in the EPSG database.
#'
#' @param CRS A character string with the name of the CRS
#' @param EPSG A logical indicating whether the output should be in EPSG format
#'
#' @return A CRS object
#'
#' @examples
#' \dontrun{
#' # Example of how to use the CRS_extracter function
#' crs_wgs <- CRS_extracter("WGS", EPSG = FALSE)
#' crs_bel <- CRS_extracter("BEL72", EPSG = FALSE)
#'
#' epsg_wgs <- CRS_extracter("WGS", EPSG = TRUE)
#'
#' # Example of how to use the CRS_extracter function in combination with the sf & leaflet packages
#' library(sf)
#' library(tidyverse)
#' library(leaflet)
#' boswachterijen_df <- boswachterijen$boswachterijen_2024 %>%
#'   st_transform(crs_bel) %>%
#'   mutate(centroid = st_centroid(geometry)) %>%
#'   st_drop_geometry() %>%
#'   st_as_sf(sf_column_name = "centroid",
#'            crs = crs_bel) %>%
#'   st_transform(crs_wgs)
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addPolylines(data = boswachterijen$boswachterijen_2024) %>%
#'   addCircles(data = boswachterijen_df, color = "red", radius = 1000)
#' }
#'
#' @importFrom sp CRS
#' @importClassesFrom sp CRS
#' @export
#' @author Sander Devisscher

CRS_extracter <- function(CRS,
                          EPSG = TRUE){

  install_sp()

  Lib_CRS <- lib_crs

  if(grepl("wgs", CRS, ignore.case = TRUE)){
    CRS <- "WGS"
  }

  if(grepl("bel", CRS, ignore.case = TRUE)){
    CRS <- "BEL72"
  }

  if(EPSG == TRUE){
    CRS_output <- CRS(Lib_CRS$EPSG[CRS == Lib_CRS$CRS_Naam])
  }else{
    CRS_output <- CRS(Lib_CRS$Proj4s[CRS == Lib_CRS$CRS_Naam])
  }

  return(CRS_output)
}

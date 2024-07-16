CRS_extracter <- function(CRS, WKT = TRUE){

  require(sp)
  require(readr)

  Lib_CRS <- read_delim("../backoffice-wild-analyse/Data/Libraries/Lib_CRS.csv",
                        ";", escape_double = FALSE, trim_ws = TRUE)

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

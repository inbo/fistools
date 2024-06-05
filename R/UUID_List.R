#' UUID list generator
#'
#' @description
#' A helper script to generate a list of UUIDs
#'
#' @param temp_input a data.frame to which UUIDs should be appended
#'
#' @export
#'

UUID_List <- function(temp_input){
  require(uuid)
  lijst <- vector(mode="logical", nrow(temp_input))
  for(i in 1:nrow(temp_input)){
    UUID <- UUIDgenerate()
    lijst[i] <- UUID
  }
  return(lijst)
}

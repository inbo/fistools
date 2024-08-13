#' @param StartDate Date in %y-%m-%d format indicating startdate of dataframe. Defaults to today
#' @param EndDate Date in %y-%m-%d format indicating enddate of dataframe. Defaults to today
#' @param lat Numeric indicating the latitude. Defaults to Herman Teirlinck building in Brussels
#' @param lng Numeric indicating the longitude. Defaults to Herman Teirlinck building in Brussels
#' 
#' @return dataframe containing the dates between the startdate and enddate, the corresponding sunrise time and sunset time.

SunSetter <- function(StartDate = Sys.Date(), EndDate = Sys.Date(), lat = 50.866572, lng = 4.350309){
  require(httr)
  require(jsonlite)
  require(tidyverse)
  
  if(is.character(StartDate)){
    StartDate <- as.Date.character(StartDate, origin = "1970-01-01")
  }
  
  if(is.character(EndDate)){
    EndDate <- as.Date.character(EndDate, origin = "1970-01-01")
  }
  
  #Create blank dataframe
  temp_data2 <- data.frame(matrix(ncol = 12))
  names(temp_data2) <- c( "Datum", "results.sunrise", "results.sunset", "results.solar_noon" , "results.day_length", "results.civil_twilight_begin",
                           "results.civil_twilight_end" , "results.nautical_twilight_begin", "results.nautical_twilight_end", "results.astronomical_twilight_begin", 
                           "results.astronomical_twilight_end", "status")
  
  for(i in StartDate:EndDate){
    temp_data <- data.frame()
    url <- paste0("https://api.sunrise-sunset.org/json?lat=", lat, "&lng=", lng, "&date=", as.Date(i, origin = "1970-01-01"))
    con <- GET(url)
    temp_data <- as.data.frame(content(con))
    temp_data$Datum <-  as.character(as.Date(i, origin = "1970-01-01"))
    temp_data2 <- rbind(temp_data2, temp_data)
  }
  
  temp_data_final <-
    temp_data2 %>% 
    filter(!is.na(Datum)) %>% 
    mutate(Zonsopgang = format(as.POSIXct(results.sunrise , format = "%I:%M:%S %p", tz = "UTC"), "%H:%M:%S", tz = Sys.timezone()),
           Zonsondergang = format(as.POSIXct(results.sunset, format = "%I:%M:%S %p", tz = "UTC"), "%H:%M:%S", tz = Sys.timezone())) %>% 
    dplyr::select(Datum, Zonsopgang, Zonsondergang)
    
  return(temp_data_final)
}

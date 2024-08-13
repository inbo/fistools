#' Calculate the sunrise and sunset times for a given date and location
#'
#' @param StartDate Date in %y-%m-%d format indicating startdate of dataframe. Defaults to today
#' @param EndDate Date in %y-%m-%d format indicating enddate of dataframe. Defaults to today
#' @param lat Numeric indicating the latitude. Defaults to Herman Teirlinck building in Brussels
#' @param lng Numeric indicating the longitude. Defaults to Herman Teirlinck building in Brussels
#'
#' @details
#' This function uses the sunrise-sunset API to calculate the sunrise and sunset times for a given date and location.
#'
#' @examples
#' \dontrun{
#' # Example of how to use the sunsetter function
#' sunsetter(StartDate = "2021-01-01", EndDate = "2021-01-10", lat = 50.866572, lng = 4.350309)
#' }
#'
#' @family temporal
#' @export
#' @author Sander Devisscher
#'
#' @return dataframe containing the dates between the startdate and enddate, the corresponding sunrise time and sunset time.

sunsetter <- function(StartDate = Sys.Date(), EndDate = Sys.Date(), lat = 50.866572, lng = 4.350309){
  # check if StartDate is character
  if(is.character(StartDate)){
    StartDate <- as.Date.character(StartDate, origin = "1970-01-01")
  }

  # check if EndDate is character
  if(is.character(EndDate)){
    EndDate <- as.Date.character(EndDate, origin = "1970-01-01")
  }

  # check if lat is numeric
  if(!is.numeric(lat)){
    lat <- as.numeric(lat)
  }

  # check if lat is not NA
  if(is.na(lat)){
    stop("Latitude is NA")
  }

  # check if lng is numeric
  if(!is.numeric(lng)){
    lng <- as.numeric(lng)
  }

  # check if lng is not NA
  if(is.na(lng)){
    stop("Longitude is NA")
  }

  #Create blank dataframe
  temp_data2 <- data.frame(matrix(ncol = 12))
  names(temp_data2) <- c( "Datum",
                          "results.sunrise",
                          "results.sunset",
                          "results.solar_noon",
                          "results.day_length",
                          "results.civil_twilight_begin",
                           "results.civil_twilight_end",
                          "results.nautical_twilight_begin",
                          "results.nautical_twilight_end",
                          "results.astronomical_twilight_begin",
                           "results.astronomical_twilight_end",
                          "status")

  for(i in StartDate:EndDate){
    temp_data <- data.frame()
    url <- paste0("https://api.sunrise-sunset.org/json?lat=", lat, "&lng=", lng, "&date=", as.Date(i, origin = "1970-01-01"))
    con <- httr::GET(url)
    temp_data <- as.data.frame(httr::content(con))
    temp_data$Datum <-  as.character(as.Date(i, origin = "1970-01-01"))
    temp_data2 <- rbind(temp_data2, temp_data)
  }

  temp_data_final <-
    temp_data2 %>%
    dplyr::filter(!is.na(Datum)) %>%
    dplyr::mutate(Zonsopgang = format(as.POSIXct(results.sunrise , format = "%I:%M:%S %p", tz = "UTC"), "%H:%M:%S", tz = Sys.timezone()),
           Zonsondergang = format(as.POSIXct(results.sunset, format = "%I:%M:%S %p", tz = "UTC"), "%H:%M:%S", tz = Sys.timezone())) %>%
    dplyr::select(Datum, Zonsopgang, Zonsondergang)

  return(temp_data_final)
}

#' @title sunsetter
#' Calculate the sunrise and sunset times for a given range of dates and location
#'
#' @param StartDate Date in %y-%m-%d format indicating startdate of dataframe. Defaults to today
#' @param EndDate Date in %y-%m-%d format indicating enddate of dataframe. Defaults to today
#' @param lat Numeric indicating the latitude. Defaults to Herman Teirlinck building in Brussels
#' @param lng Numeric indicating the longitude. Defaults to Herman Teirlinck building in Brussels
#'
#' @details
#' This function uses the sunrise-sunset API to calculate the sunrise and sunset
#' times for a given range of dates and fixed location.
#' The default location is the Herman Teirlinck building in Brussels.
#'
#' if StartDate and EndDate are not specified, the function will return the sunrise
#' and sunset times for today.
#'
#'
#'
#' @examples
#' \dontrun{
#' # sunrise and sunset times for the first 10 days of 2021 in Brussels
#' sunsetter(StartDate = "2021-01-01", EndDate = "2021-01-10", lat = 50.866572, lng = 4.350309)
#'
#' # sunrise and sunset times for today in Brussels
#' sunsetter()
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
  temp_data2 <- data.frame(matrix(ncol = 13))
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
                          "status",
                          "tzid")

  # initiate progress bar
  pb <- progress::progress_bar$new(format = "  [:bar] :percent ETA: :eta",
                                   total = length(StartDate:EndDate),
                                   clear = FALSE,
                                   width = 60)
  # loop over dates
  for(i in StartDate:EndDate){
    pb$tick()
    temp_data <- data.frame()
    url <- paste0("https://api.sunrise-sunset.org/json?lat=", lat, "&lng=",
                  lng, "&date=", as.Date(i, origin = "1970-01-01"))
    con <- httr::GET(url)
    temp_data <- as.data.frame(httr::content(con))
    temp_data$Datum <-  as.character(as.Date(i, origin = "1970-01-01"))
    temp_data2 <- rbind(temp_data2, temp_data)
  }

  temp_data_final <-
    temp_data2 %>%
    dplyr::filter(!is.na(Datum)) %>%
    dplyr::mutate(Zonsopgang = format(as.POSIXct(results.sunrise ,
                                                 format = "%I:%M:%S %p",
                                                 tz = "UTC"), "%H:%M:%S",
                                      tz = Sys.timezone()),
                  Zonsondergang = format(as.POSIXct(results.sunset,
                                                    format = "%I:%M:%S %p",
                                                    tz = "UTC"), "%H:%M:%S",
                                         tz = Sys.timezone())) %>%
    dplyr::select(Datum, Zonsopgang, Zonsondergang)

  return(temp_data_final)
}

#' @title sunsetter2
#'
#' @description
#' Calculate the sunrise and sunset times for a given set of date and location combinations
#'
#' @param df A dataframe containing the dates, latitudes and longitudes
#' @param dates A vector of dates contained in the dataframe
#' @param lat A vector of latitudes contained in the dataframe
#' @param lng A vector of longitudes contained in the dataframe
#'
#' @details
#' This function uses the sunrise-sunset API to calculate the sunrise and sunset
#' times for a given set of date and location combinations.
#'
#' @examples
#' \dontrun{
#' # create a dataframe with dates, latitudes and longitudes
#' df <- data.frame(dates = c("2021-01-01", "2021-01-01", "2020-12-25"),
#'                  location = c("Brussels", "Amsterdam", "Brussels"),
#'                  lat = c(50.866572, 52.367573, 50.866572),
#'                  lng = c(4.350309, 4.904138, 4.350309),
#'                  remarks = c("New Year's Day", "New Year's Day", "Christmas Day"))
#'
#' # calculate the sunrise and sunset times for the dataframe
#' sunsets <- sunsetter2(df)
#'
#' # add the sunrise and sunset times to the dataframe
#' df <- dplyr::bind_cols(df, sunsets %>% dplyr::select(-dates))
#' df
#' }
#'
#' @family temporal
#' @export
#' @author Sander Devisscher
#'
#' @return dataframe containing the dates, latitudes, longitudes, sunrise time and sunset time.

sunsetter2 <- function(df,
                       dates,
                       lat,
                       lng){
  # check if df is a dataframe
  if(!is.data.frame(df)){
    stop("df is not a dataframe")
  }

  # check if dates is a column in df
  if(!"dates" %in% colnames(df)){
    stop("dates is not a column in df")
  }

  # check if lat is a column in df
  if(!"lat" %in% colnames(df)){
    stop("lat is not a column in df")
  }

  # check if lng is a column in df
  if(!"lng" %in% colnames(df)){
    stop("lng is not a column in df")
  }

  # create a empty dataframe
  temp_data2 <- data.frame(matrix(ncol = 13))
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
                          "status",
                          "tzid")

  # initiate progress bar
  pb <- progress::progress_bar$new(format = "  [:bar] :percent ETA: :eta",
                                   total = nrow(df),
                                   clear = FALSE,
                                   width = 60)

  # loop over rows in df
  for(i in 1:nrow(df)){
    pb$tick()
    temp_data <- data.frame()
    url <- paste0("https://api.sunrise-sunset.org/json?lat=", df$lat[i], "&lng=",
                  df$lng[i], "&date=", as.Date(df$dates[i], origin = "1970-01-01"))
    con <- httr::GET(url)
    temp_data <- as.data.frame(httr::content(con))
    temp_data$Datum <-  as.character(as.Date(df$dates[i], origin = "1970-01-01"))
    temp_data2 <- rbind(temp_data2, temp_data)
  }

  temp_data_final <-
    temp_data2 %>%
    dplyr::filter(!is.na(Datum)) %>%
    dplyr::mutate(Zonsopgang = format(as.POSIXct(results.sunrise ,
                                                 format = "%I:%M:%S %p",
                                                 tz = "UTC"), "%H:%M:%S",
                                      tz = Sys.timezone()),
                  Zonsondergang = format(as.POSIXct(results.sunset,
                                                    format = "%I:%M:%S %p",
                                                    tz = "UTC"), "%H:%M:%S",
                                         tz = Sys.timezone())) %>%
    dplyr::select(dates = Datum, Zonsopgang, Zonsondergang)

  return(temp_data_final)
}

#' @title Extract values from web feature service (wfs)
#'
#' @description This function extracts values from a web feature service (wfs)
#'
#' @param df A `data.frame` with x and y coordinates in the Belgian Lambert 72 (EPSG:31370)
#' @param x_lam A character string with the column name of the X coordinate
#' @param y_lam A character string with the column name of the Y coordinate
#' @param url A character string with the url of the wfs
#' @param layer A character string with the name of the layer in the wfs
#' @param crs A character string with the coordinate reference system of the wfs
#' @param debug A logical value to print debug information
#'
#' @details This function extracts values from a web feature service (wfs) based on the x and y coordinates in the df. The function loops through the df and makes a request to the wfs for each point. The function returns a data.frame with the values of the wfs appended to the list of points.
#'
#' the functions is mainly build to work with
#'
#' @return A `data.frame` with the values of the wfs appended to the list of points
#'
#' @export
#' @family spatial_functions
#'
#' @examples
#' \dontrun{
#' }
wfs_intersect <- function(df,
                          x_lam,
                          y_lam,
                          url,
                          layer,
                          crs = 31370,
                          debug = FALSE) {

  # check if x_lam & y_lam are in the df ####
  if (!all(c(x_lam, y_lam) %in% names(df))) {
    stop("x_lam and y_lam should be columns in the df")
  }

  # add x_lam & y_lam to the df ####
  df$x_lam <- df[[x_lam]]
  df$y_lam <- df[[y_lam]]

  # check if x_lam & y_lam are numeric ####
  # if (!all(sapply(df[, c(x_lam, y_lam)], is.numeric))) {
  #   warning("x_lam and y_lam should be numeric >> converting to numeric")
  #   df$x_lam <- as.numeric(df[[x_lam]])
  #   df$y_lam <- as.numeric(df[[y_lam]])
  # }

  # check if geometry is in the df ####
  if ("sf" %in% class(df)) {
    print("sf object detected >> testing crs & dropping geometry")

    ## check if crs is provided ####
    if (is.null(sf::st_crs(df))) {
      warning("crs is not provided in the sf object >> skipping crs test")
    } else {
      ### check if crs is the same as the provided crs ####
      if (sf::st_crs(df) != crs) {
        warning("crs of the sf object is not the same as the provided crs >> converting to the provided crs &
                recalculating points")
        df <- sf::st_transform(df, crs) %>%
          dplyr::mutate(x_lam := sf::st_coordinates(.)[,1],
                        y_lam := sf::st_coordinates(.)[,2])
      }
    }
    ## drop the geometry ####
    df <- df %>%
      sf::st_drop_geometry()
  }

  # check if x_lam & y_lam are provided ##
  ## filter missing x_lam & y_lam values ####
  missing_x_y <- df %>%
    dplyr::filter(is.na(x_lam) |
                    is.na(y_lam))

  if (nrow(missing_x_y) > 0) {
    warning(paste(nrow(missing_x_y), "rows with missing x_lam & y_lam values"))
  }

  df <- df %>%
    dplyr::filter(!is.na(x_lam) ,
                  !is.na(y_lam))

  ### check if there are still rows left in the df ####
  if (nrow(df) == 0) {
    stop("No rows left in the df after filtering missing x_lam & y_lam values")
  }

  # check if url is a character string ####
  if (!is.character(url)) {
    warning("url should be a character string >> converting to character string")
    url <- as.character(url)
  }

  # check if the layer is in the wfs ####
  wfs_layers <- get_wfs_layers(url)

  if (!layer %in% wfs_layers) {
    stop(paste(
      layer,
      "is not available in the wfs. The available layers are:",
      paste(wfs_layers, collapse = ", ")
    ))
  }

  # check if crs is a character string ####
  if (!is.character(crs)) {
    warning("crs should be a character string >> converting to character string")
    crs <- as.character(crs)
  }

  # loop through the df and get the values from the wfs ####
  ## create a progress bar ####
  pb <- progress::progress_bar$new(format = "  [:bar] :percent ETA: :eta",
                                   total = nrow(df),
                                   clear = FALSE,
                                   width = 60)
  ## loop through the df ####
  for(i in 1:nrow(df)) {
    ### update the progress bar ####
    pb$tick()

    ### make the query ####
    par_url <- httr::parse_url(url)
    par_url$query <- list(
      service = "WFS",
      version = "2.0.0",
      request = "GetFeature",
      typeName = layer,
      crs = crs,
      CQL_FILTER = sprintf(
        "INTERSECTS(geom,POINT(%s %s))",
        df$x_lam[i], df$y_lam[i]
      ),
      resultType = "results",
      maxFeatures = 1,
      uniqueParam = as.numeric(Sys.time())  # Adding a unique parameter to bypass cache
    )

    response <- httr::GET(httr::build_url(par_url))

    ### Check if the request was successful ####
    if (httr::status_code(response) != 200) {
      stop("Failed to get data from WFS. Status code: ", httr::status_code(response))
    }

    ### Check if the response content is of a allowed type ####
    allowed_content_types <- c("text/csv", "text/plain", "application/xml")

    if (!httr::http_type(response) %in% allowed_content_types) {
      stop("Failed to get data from WFS. Status code: ", httr::status_code(response),
           "http_type: ", httr::http_type(response), " expects ",
           paste(allowed_content_types, colapse = ", "), " response.
           >> check wfs metadata if output is supported")
    }

    ### Parse the result ####
    # response is a csv file or a text file
    if(httr::http_type(response) == "text/csv" | httr::http_type(response) == "text/plain") {
      wfs_info <- read.csv(textConnection(httr::content(response, "text"))) %>%
        as.data.frame()
    }

    # response is a xml file
    if(httr::http_type(response) == "application/xml") {
      wfs_info <- xml2::read_xml(httr::content(response, "text")) %>%
        xml2::as_list()
    }

    ### recombine the data ####

    if (is.null(wfs_info)) {
      next
      warning("No data found for point ", i, " in the wfs")
    } else {
      wfs_info <- as.data.frame(wfs_info)
    }

    if (i == 1) {
      wfs_info_df <- wfs_info
    } else {
      wfs_info_df <- rbind(wfs_info_df, wfs_info)
    }

    ### Print debug information ####
    if (debug){
      cat(sprintf("Processing point %d: (%s, %s)\n", i, df$x_lam[i], df$y_lam[i]))
      print(query)
      cat("Raw response content:\n", httr::content(response, "text"), "\n")
      print(wfs_info)
      print(wfs_info_df)
      # Construct the full URL with query parameters
      url_with_query <- modify_url(url, query = query)

      # Print the full URL for debugging
      cat("Full URL:\n", url_with_query, "\n")

    }

    ### cleanup after run ####
    rm(wfs_info)
    rm(response)
  }

  ### add the wfs_info_df to the df ####
  wfs_info_df <- cbind(df, wfs_info_df)

  return(wfs_info_df)
}

#' Function to get the available layers in a wfs
#'
#' @param url A character string with the url of the wfs
#'
#' @return A character vector with the available layers in the wfs
#'
#' @import ows4R
#' @export
#' @family spatial_functions
#'
get_wfs_layers <- function(url) {
  client <- ows4R::WFSClient$new(url,
                                 serviceVersion = "2.0.0")

  list <- client$getFeatureTypes(pretty = TRUE)

  return(list$name)
}

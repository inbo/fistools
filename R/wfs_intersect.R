#' @title Extract values from web feature service (wfs)
#'
#' @description This function extracts values from a web feature service (wfs)
#'
#' @param df A `data.frame` with x and y coordinates in the Belgian Lambert 72 (EPSG:31370)
#' @param x_lam A character string with the column name of the X coordinate
#' @param y_lam A character string with the column name of the Y coordinate
#' @param url A character string with the url of the wfs
#' @param layer A character string with the name of the layer in the wfs
#'
#' @return A `data.frame` with the values of the wfs appended to the list of points
#'
#' @export
#' @family wfs_functions
#'
#' @examples
#' \dontrun{
#' }
wfs_intersect <- function(df,
                          x_lam,
                          y_lam,
                          url,
                          layer
) {

  # check if x_lam & y_lam are in the df ####
  if (!all(c(x_lam, y_lam) %in% names(df))) {
    stop("x_lam and y_lam should be columns in the df")
  }

  # check if x_lam & y_lam are numeric ####
  if (!all(sapply(df[, c(x_lam, y_lam)], is.numeric))) {
    warning("x_lam and y_lam should be numeric >> converting to numeric")
    df[[x_lam]] <- as.numeric(df[[x_lam]])
    df[[y_lam]] <- as.numeric(df[[y_lam]])
  }

  # check if x_lam & y_lam are provided ##
  ## filter missing x_lam & y_lam values ####
  missing_x_y <- df %>%
    filter(is.na(!!sym(x_lam)) | is.na(!!sym(y_lam)))

  if (nrow(missing_x_y) > 0) {
    warning(paste(nrow(missing_x_y), "rows with missing x_lam & y_lam values"))
  }

  df <- df %>%
    filter(!is.na(!!sym(x_lam)) & !is.na(!!sym(y_lam)))

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

  # loop through the df and get the values from the wfs ####
  ## create a progress bar ####
  pb <- progress::progress_bar$new(format = "  [:bar] :percent ETA: :eta",
                                   total = nrow(sf_df),
                                   clear = FALSE,
                                   width = 60)
  ## loop through the df ####
  for(i in 1:nrow(df)) {
    ### update the progress bar ####
    pb$tick()

    ### make the query ####
    query <- list(
      service = "WFS",
      request = "GetFeature",
      version = "1.1.0",
      typeName = layer,
      outputFormat = "json",
      CRS = "EPSG:31370",
      CQL_FILTER = sprintf(
        "INTERSECTS(geom,POINT(%s %s))",
        df[[x_lam]][i], df[[y_lam]][i]
      )
    )

    ### get the data from the wfs ####
    result <- httr::GET(url, query = query)

    ### parse the result ####
    parsed <- jsonlite::fromJSON(httr::content(result, "text"))
    wfs_info <- parsed$features$properties

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
  }
}

#' Function to get the available layers in a wfs
#'
#' @param url A character string with the url of the wfs
#'
#' @return A character vector with the available layers in the wfs
#'
#' @import ows4R
#' @export
get_wfs_layers <- function(url) {
  client <- ows4R::WFSClient$new(url,
                                 serviceVersion = "2.0.0")

  list <- client$getFeatureTypes(pretty = TRUE)

  return(list$name)
}

#' Calculate the centroid of a polygon
#'
#' This function calculates the centroid of a polygon and returns the latitude, longitude and uncertainty of the centroid.
#'
#' @param sf_df A sf object with polygons
#' @param id A character string with the name of the column containing the unique identifier
#'
#' @return A data frame with the unique identifier, latitude, longitude and uncertainty of the centroid
#'
#' @examples
#' \dontrun{
#' # Example of how to use the calculate_polygon_centroid function
#' centroids_data_final <- calculate_polygon_centroid(sf_df = boswachterijen$boswachterijen_2024, id = "UUID")
#' }
#'
#' @export
#' @author Sander Devisscher

calculate_polygon_centroid <- function(sf_df, id){
  # Checks ####
  ## Check if the input is an sf object ####
  if(!inherits(sf_df, "sf")){
    stop("The input should be an sf object")
  }

  ## Check if the id is a character string ####
  if(!is.character(id)){
    id <- as.character(id)
  }

  ## Check if the id is in the sf object ####
  if(!(id %in% names(sf_df))){
    stop("The id is not in the sf object")
  }

  ## Check if the id is unique ####
  if(length(unique(sf_df[[id]])) != nrow(sf_df)){
    warning("The id is not unique >> the function will continue but the output will be incorrect >> try to add a unique identifier to the sf object")
  }

  # prepare data ####
  ## Rename the id column to "id" ####
  id_col <- id
  names(sf_df)[names(sf_df) == id_col] <- "id"

  ## Extract the CRS ####
  crs_wgs <- CRS_extracter("wgs")
  crs_bel <- CRS_extracter("bel")

  ## Calculate the number of vertices ####
  sf_df <- sf_df %>%
    sf::st_make_valid() %>%
    dplyr::mutate(NbrVertex = mapview::npts(sf_df, by_feature = TRUE))

  # Create Centroids ####
  ## Calculate centroids from sp_df ####
  centroids <- sf_df %>%
    sf::st_centroid()

  ## Create output ####
  centroids_data_final <- data.frame()

  UUIDS <- unique(sf_df$id)
  ## Calculate the distance between the centroid and the polygon ####
  for(u in UUIDS){
    sf_df_sub <- sf_df %>%
      dplyr::filter(id == u)
    ### Check if the polygon is valid ####
    if(nrow(sf_df_sub) == 0){
      next
      warning(paste0("no fortified shape for ", u))
    }
    centroids_sub <- centroids %>%
      dplyr::filter(id == u)

    ### Check if the centroid is valid ####
    if(nrow(centroids_sub)==0){
      next
      warning(paste0("no centroid for ", u))
    }
    ### Calculate the distance ####
    distance <- st_distance(sf_df_sub, centroids_sub) %>%
      units::drop_units()

    ### Calculate the maximum distance ####
    maxDistance <- round(max(distance, na.rm = TRUE))

    ### Set the maximum distance to 4 if it is smaller than 4 ####
    if(maxDistance < 4){
      maxDistance <- 4 # reasonable accuracy of handheld GPS devices
    }

    ### Add the maximum distance to the centroid data ####
    centroids_sub$centroidUncertainty <- maxDistance
    centroids_data_final <- rbind(centroids_data_final, centroids_sub)
  }

  ## Transform the data to a data frame ####
  centroids_data_final <- centroids_data_final %>%
    dplyr::mutate(centroidLatitude = sf::st_coordinates(geometry)[, 2],
                  centroidLongitude = sf::st_coordinates(geometry)[, 1]) %>%
    dplyr::select(id,
                  verbatimCentroidLatitude,
                  verbatimCentroidLongitude,
                  verbatimCentroidUncertainty) %>%
    sf::st_drop_geometry()

  ## Rename the id column to the original name ####
  names(centroids_data_final)[names(centroids_data_final) == "id"] <- id_col

  ## Return the data ####
  return(centroids_data_final)
}

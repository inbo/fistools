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
#' # Load the necessary data
#' boswachterijen <- boswachterijen$boswachterijen_2024
#'
#' # add a unique identifier to the sf object
#' boswachterijen <- boswachterijen %>%
#' dplyr::mutate(UUID = as.character(row_number()))
#'
#' # Calculate the centroid of the polygons
#' centroids_data_final <- calculate_polygon_centroid(sf_df = boswachterijen, id = "UUID")
#'
#' # Plot the polygons and the centroids
#' library(leaflet)
#'
#' # Sample 1 polygon and 1 centroid to plot using id
#' sample_id <- sample(centroids_data_final$UUID, 1)
#'
#' leaflet() %>%
#'   addProviderTiles("CartoDB.Positron") %>%
#'   addPolygons(data = boswachterijen %>% dplyr::filter(UUID == sample_id),
#'               weight = 1, color = "black", fillOpacity = 0.5) %>%
#'   addCircles(data = centroids_data_final %>% dplyr::filter(UUID == sample_id),
#'              lat = ~centroidLatitude, lng = ~centroidLongitude, radius = 5,
#'              color = "black") %>%
#'   addCircles(data = centroids_data_final %>% dplyr::filter(UUID == sample_id),
#'              lat = ~centroidLatitude, lng = ~centroidLongitude, radius = ~centroidUncertainty,
#'              color = "red", weight = 1)
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
  ## Check if col name "id" is already present in the sf object ####
  if("id" %in% names(sf_df) & id != "id"){
    warning("The column name 'id' is already present in the sf object >> this column will be overwritten by the specified id")
    sf_df <- sf_df %>%
      dplyr::select(-id)
  }

  ## Rename the id column to "id" ####
  id_col <- id
  names(sf_df)[names(sf_df) == id_col] <- "id"

  ## Extract the CRS ####
  crs_wgs <- CRS_extracter("wgs")

  ## Transform the data to the correct CRS ####
  sf_df <- sf_df %>%
    sf::st_transform(crs_wgs)

  ## Calculate the number of vertices ####
  sf_df <- sf_df %>%
    sf::st_make_valid() %>%
    dplyr::mutate(NbrVertex = mapview::npts(sf_df, by_feature = TRUE))

  # Caculate Centroids ####
  ## Calculate centroids from sp_df ####
  centroids <- sf_df %>%
    sf::st_centroid()

  ## Create output ####
  centroids_data_final <- data.frame()

  UUIDS <- unique(sf_df$id)

  ## Create a progress bar ####
  pb <- progress::progress_bar$new(format = "  [:bar] :percent ETA: :eta",
                                   total = nrow(sf_df),
                                   clear = FALSE,
                                   width = 60)

  ## Calculate the distance between the centroid and the polygon ####
  for(u in UUIDS){
    ### Update the progress bar ####
    pb$tick()
    ### Filter the sf data ####
    sf_df_sub <- sf_df %>%
      dplyr::filter(id == u)
    ### Check if the polygon is valid ####
    if(nrow(sf_df_sub) == 0){
      next
      warning(paste0("no fortified shape for ", u))
    }else{
      ### split the polygons into vertrex points ####
      sf_df_sub <- sf_df_sub  %>%
        sf::st_cast("MULTIPOINT") %>%
        sf::st_cast("POINT", do_split = TRUE)

      ### Check if the number of points is equal to the number of vertices ####
      if(nrow(sf_df_sub) != unique(sf_df_sub$NbrVertex)){
        warning(paste0("The number of points is not equal to the number of vertices for ", u))
      }
    }

    ### Filter the centroid data ####
    centroids_sub <- centroids %>%
      dplyr::filter(id == u)

    ### Check if the centroid is valid ####
    if(nrow(centroids_sub)==0){
      next
      warning(paste0("no centroid for ", u))
    }
    ### Calculate the distance ####
    distance <- sf::st_distance(sf_df_sub, centroids_sub) %>%
      units::drop_units()

    ### Calculate the maximum distance ####
    maxDistance <- round(max(distance, na.rm = TRUE))

    ### Set the maximum distance to 4 if it is smaller than 4 ####
    if(maxDistance < 4){
      warning(paste0("The maximum distance is smaller than 4 for ", u, " >> setting the maximum distance to 4"))
      maxDistance <- 4 # reasonable accuracy of handheld GPS devices
    }

    ### Add the maximum distance to the centroid data ####
    centroids_sub$centroidUncertainty <- maxDistance
    centroids_data_final <- rbind(centroids_data_final, centroids_sub)
  }

  ## Transform the data to a data frame ####
  input_crs <- sf::st_crs(sf_df)

  centroids_data_final <- centroids_data_final %>%
      dplyr::mutate(centroidLatitude = sf::st_coordinates(geometry)[, 2],
                    centroidLongitude = sf::st_coordinates(geometry)[, 1])

    centroids_data_final_2 <- centroids_data_final %>%
      sf::st_transform(input_crs) %>%
      dplyr::mutate(centroidX = sf::st_coordinates(geometry)[, 1],
                    centroidY = sf::st_coordinates(geometry)[, 2]) %>%
      sf::st_transform(crs_wgs)

    centroids_data_final <- cbind(centroids_data_final, centroids_data_final_2)  %>%
      dplyr::select(id,
                    centroidLatitude,
                    centroidLongitude,
                    centroidX,
                    centroidY,
                    centroidUncertainty) %>%
      sf::st_drop_geometry()

    ## Remove the centroidX and centroidY columns if they are equal to the centroidLatitude and centroidLongitude columns ####
    if(all(centroids_data_final$centroidLatitude == centroids_data_final$centroidY) &
       all(centroids_data_final$centroidLongitude == centroids_data_final$centroidX)){
      centroids_data_final <- centroids_data_final %>%
        dplyr::select(-centroidX, -centroidY)
    }


  ## Rename the id column to the original name ####
  names(centroids_data_final)[names(centroids_data_final) == "id"] <- id_col

  ## Return the data ####
  return(centroids_data_final)
}

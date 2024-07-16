calculate_polygon_centroid <- function(sf_df, id){
  id_col <- id
  names(sf_df)[names(sf_df) == id_col] <- "id"

  source("./Functies/CRS_extracter.R")

  crs_wgs <- CRS_extracter("wgs")
  crs_bel <- CRS_extracter("bel")

  sf_df <- sf_df %>%
    st_make_valid() %>%
    mutate(NbrVertex = mapview::npts(sf_df, by_feature = TRUE))

  # Create Centroids ####
  ## Calculate centroids from sp_df ####
  centroids <- sf_df %>%
    st_centroid()

  ## Create output ####
  centroids_data_final <- data.frame()

  UUIDS <- unique(sf_df$id)

  for(u in UUIDS){
    sf_df_sub <- sf_df %>%
      filter(id == u)
    if(nrow(sf_df_sub) == 0){
      next
      warning(paste0("no fortified shape for ", u))
    }
    centroids_sub <- centroids %>%
      filter(id == u)
    if(nrow(centroids_sub)==0){
      next
      warning(paste0("no centroid for ", u))
    }

    distance <- st_distance(sf_df_sub, centroids_sub) %>%
      units::drop_units()

    maxDistance <- round(max(distance, na.rm = TRUE))

    if(maxDistance < 4){
      maxDistance <- 4 # reasonable accuracy of handheld GPS devices
    }

    centroids_sub$verbatimCentroidUncertainty  <- maxDistance
    centroids_data_final <- rbind(centroids_data_final, centroids_sub)
  }

  centroids_data_final <- centroids_data_final %>%
    mutate(verbatimCentroidLatitude = st_coordinates(geometry)[, 2],
           verbatimCentroidLongitude = st_coordinates(geometry)[, 1]) %>%
    select(id,
           verbatimCentroidLatitude,
           verbatimCentroidLongitude,
           verbatimCentroidUncertainty) %>%
    st_drop_geometry()

  names(centroids_data_final)[names(centroids_data_final) == "id"] <- id_col

  return(centroids_data_final)
}

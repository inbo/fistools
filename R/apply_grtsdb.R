#' apply grtsdb
#'
#' A function to apply grtsdb to a custom perimeter
#'
#' @author Sander Devisscher
#'
#' @description
#' Applies grtsdb from inbo/GRTSdb to a custom perimeter. This function installs
#' GRTSdb if it is missing from your machine.
#'
#' @param perimeter a simple features (sf) object
#' @param cellsize an optional integer. The size of each cell. Either a single value or one value for each dimension. Passed onto extract_sample from GRTSdb. Default is 100.
#' @param n an optional integer. the sample size. Passed onto extract_sample from GRTSdb. Default is 20
#' @param seed a optional character. Allowing to rerun a previous use.

apply_grtsdb <- function(perimeter,
                         cellsize = 100,
                         n = 20,
                         seed){
  # Setup ####
  ## Libraries ####
  library(RSQLite)
  tryCatch(library(grtsdb), finally = devtools::install_github("inbo/GRTSdb"))
  library(rgeos)
  library(sp)
  library(tidyverse)

  crs_bel <- CRS("+proj=lcc +lat_1=51.16666723333333 +lat_2=49.8333339 +lat_0=90 +lon_0=4.367486666666666 +x_0=150000.013 +y_0=5400088.438 +ellps=intl +towgs84=-106.869,52.2978,-103.724,0.3366,-0.457,1.8422,-1.2747 +units=m +no_defs")
  crs_wgs <- CRS("+init=epsg:4326")
  source("../backoffice-wild-analyse/Functies/UUID_List.R")
  source("./Functions/cleanup_sqlite.R")

  ## Checks ####
  ### Perimeter ####
  if(missing(perimeter)){
    stop("perimeter does not exist in global environment")
  }
  if(class(perimeter) != "SpatialPolygonsDataFrame"){
    stop(paste0("perimeter is ",
                class(perimeter),
                ", not SpatialPolygonsDataFrame"))
  }

  projectie <- proj4string(perimeter)

  if(is.na(projectie)){
    stop("De perimeter is niet geprojecteerd, voorzie een projectie. proj4string(perimeter) <- CRS")
  }
  if(projectie != crs_bel@projargs){
    warning("De perimeter wordt getransfromeerd naar bel_72")
    perimeter <- spTransform(perimeter, crs_bel)
  }

  ### n ####
  if(!is.integer(n)){
    n <- as.integer(n)
    points_in_perimeter <- 0
  }

  ## Apply GTRSDB ####
  ### Calculate bbox ####
  bbox <- as.matrix(perimeter@bbox)

  ### No seed ####
  if(missing(seed)){
    #### Calculate new seed ####
    seed <- paste(sample(c(letters[1:6],0:9),5,replace=TRUE),collapse="")
    i <- 1

    if(!dir.exists(paste0("./Data/GRTS/", seed))){
      dir.create(paste0("./Data/GRTS/", seed))
    }
    #### Check for old db ####
    if(file.exists("grts.sqlite")){
      cleanup_sqlite("grts.sqlite")
    }

    #### generate new grts.sqlite ####
    db_name <- paste0("./Data/GRTS/", seed, "/grts.sqlite")

    extract_sample(samplesize = n,
                   bbox = bbox,
                   cellsize = cellsize)

    #### Move db ####
    file.copy(from = "grts.sqlite",
              to = db_name)

    cleanup_sqlite("grts.sqlite")

  }else{
    db_name <- paste0("./Data/GRTS/", seed, "/grts.sqlite")
  }

  ### Calculate samplesize of bbox ####
  # Deze waarde is groter dan de maximale samplesize => resulteert in alle
  # Samplepunten binnen de bbox
  bbox_samplesize <- as.integer(gArea(perimeter)/cellsize)

  ### Connect to db ####
  con <- connect_db(db_name)

  ### Extract complete sample ####
  sample <- extract_sample(grtsdb = con,
                           samplesize = bbox_samplesize,
                           bbox = bbox,
                           cellsize = cellsize)

  ### Convert sample to sptsdf ####
  coords <- sample %>%
    dplyr::select(x1c, x2c)

  all_sample_pts <- SpatialPointsDataFrame(coords,
                                           sample)

  all_sample_pts$ID_list <- UUID_List(all_sample_pts)

  proj4string(all_sample_pts) <- crs_bel

  ### Convert sptsdf to GRID ####
  sample_grid <- SpatialGridDataFrame(points2grid(all_sample_pts),
                                      all_sample_pts@data)

  sample_grid <-  as(sample_grid, "SpatialPolygonsDataFrame")

  proj4string(sample_grid) <- crs_bel

  perimeter_dis <- gUnaryUnion(perimeter)

  ### Select gridcells inside perimeter ####
  sample_grid_over <- over(sample_grid, perimeter_dis)
  sample_grid_intersected <- bind_cols(sample_grid_over, sample_grid@data)

  sample_grid_intersected$intersect <- sample_grid_intersected[,1]

  sample_grid_intersected <- sample_grid_intersected %>%
    filter(!is.na(intersect))

  intersect_ids <- unique(sample_grid_intersected$ID_list)

  sample_grid_intersect <- subset(sample_grid, sample_grid$ID_list %in% intersect_ids)

  ### Select points inside perimeter ####
  # obv de IDs van de geselecteerde gridcells
  sample_pts_intersect <- raster::intersect(all_sample_pts, as(sample_grid_intersect, "SpatialPolygons"))

  ### Transform spatial objects ####
  all_sample_pts <- spTransform(all_sample_pts, crs_wgs)
  sample_grid_intersect <- spTransform(sample_grid_intersect, crs_wgs)
  perimeter <- spTransform(perimeter, crs_wgs)
  sample_pts_intersect <- spTransform(sample_pts_intersect, crs_wgs)


  ## Resample ####
  final_sample_ranking <- head(sample_pts_intersect$ranking, n)

  final_samples <- subset(sample_pts_intersect, sample_pts_intersect$ranking %in% final_sample_ranking)

  ### test results (disabled) ####
#  leaflet(all_sample_pts) %>%
#    addTiles() %>%
#    addPolygons(data = sample_grid_intersect) %>%
#    addPolygons(data = spTransform(perimeter, crs_wgs),
#                color = "black")  %>%
#    addPolygons(data = perimeter,
#                color = "grey") %>%
#    addCircles(data = sample_pts_intersect,
#               color = "green") %>%
#    addMarkers(data = final_samples)

  ## Return ####
  return(list(seed = seed,
              points_in_perimeter = sample_pts_intersect,
              grid = sample_grid_intersect,
              samples = final_samples))
}

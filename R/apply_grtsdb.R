#' apply grtsdb
#'
#' A function to apply grtsdb to a custom perimeter
#'
#' @author Sander Devisscher
#'
#' @description
#' Applies `grtsdb::extract_sample` from inbo/GRTSdb to a custom perimeter. This function installs
#' GRTSdb if it is missing from your machine.
#'
#' @param perimeter a simple features (sf) object
#' @param cellsize an optional integer. The size of each cell. Either a single value or one value for each dimension. Passed onto extract_sample from GRTSdb. Default is 100.
#' @param n an optional integer. the sample size. Passed onto extract_sample from GRTSdb. Default is 20
#' @param export_path an optional character string pointing to the path where the GRTSdb.sqlite is created. Default is "."
#' @param seed a optional character. Allowing to rerun a previous use.
#'
#' @details
#' GRTSdb is automatically installed when missing from your system.
#'
#' @export
#'
#' @family spatial
#'
#' @examples
#' \dontrun{
#' # Preparation
#' perimeter <- sf::st_as_sf(boswachterijen$boswachterijen_2024) %>%
#'   dplyr::filter(Regio == "Taxandria",
#'                 Naam == "vacant 4")
#'
#' # A new sample
#' sample <- apply_grtsdb(perimeter,
#'                        cellsize = 1000,
#'                        n = 20,
#'                        export_path = ".")
#'
#' leaflet::leaflet() %>%
#'  leaflet::addTiles() %>%
#'  leaflet::addCircles(data = sample$samples,
#'                      color = "red") %>%
#'  leaflet::addPolylines(data = sample$grid,
#'                        color = "blue") %>%
#'  leaflet::addPolylines(data = perimeter,
#'                        color = "black")
#' # Reuse a old sample
#' seed <- sample$seed
#'
#' sample <- apply_grtsdb(perimeter,
#'                        cellsize = 1000,
#'                        n = 20,
#'                        export_path = ".",
#'                        seed = seed)
#'
#'  leaflet::leaflet() %>%
#'  leaflet::addTiles() %>%
#'  leaflet::addCircles(data = sample$samples,
#'                      color = "red") %>%
#'  leaflet::addPolylines(data = sample$grid,
#'                        color = "blue") %>%
#'  leaflet::addPolylines(data = perimeter,
#'                        color = "black")
#' }

apply_grtsdb <- function(perimeter,
                         cellsize = 100,
                         n = 20,
                         export_path = ".",
                         seed){
  # Setup ####
  ## Libraries ####
  if(!rlang::is_installed("grtsdb")){
    devtools::install_github("inbo/GRTSdb")
  }

  crs_bel <- "EPSG:31370"
  crs_wgs <- 4326

  ## Checks ####
  ### Perimeter ####
  if(missing(perimeter)){
    stop("perimeter does not exist in global environment")
  }

  if("SpatialPolygonsDataFrame" %in% class(perimeter)){
    warning("perimeter is class SpatialPolygonsDataFrame >> converting into sf")

    perimeter <- perimeter %>%
      sf::st_as_sf()
  }

  projectie <- sf::st_crs(perimeter)

  if(is.na(projectie)){
    stop("De perimeter is niet geprojecteerd, voorzie een projectie. Probeer: sf::st_set_crs(perimeter, CRS)")
  }

  if(projectie$input != crs_bel){
    warning("De perimeter wordt getransfromeerd naar bel_72")
    perimeter <- perimeter %>%
      sf::st_transform(crs_bel)
  }

  if(nrow(perimeter) > 1){
    stop("Meer dan 1 polygoon gedetecteerd >> probeer de polygonen te dissolven")
  }

  ### n ####
  if(!is.integer(n)){
    n <- as.integer(n)
    points_in_perimeter <- 0
  }

  ## Apply GTRSDB ####
  ### Calculate bbox ####
  temp_bbox <- sf::st_bbox(perimeter) %>%
    as.data.frame()

  bbox <- matrix(nrow = 2, ncol = 2)

  bbox[1,1] <- temp_bbox$x[1]
  bbox[2,1] <- temp_bbox$x[2]
  bbox[1,2] <- temp_bbox$x[3]
  bbox[2,2] <- temp_bbox$x[4]

  ### No seed ####
  if(missing(seed)){
    #### Calculate new seed ####
    seed <- paste(sample(c(letters[1:6],0:9),5,replace=TRUE),collapse="")
    i <- 1

    export_path <- paste0(export_path, "/", seed)

    if(!dir.exists(export_path)){
      warning(paste0("Export path is missing >> creating ", export_path))
      dir.create(export_path)
    }
    #### Check for old db ####
    if(file.exists(paste0(export_path, "/grts.sqlite"))){
      cleanup_sqlite(paste0(export_path, "/grts.sqlite"))
    }

    #### generate new grts.sqlite ####
    db_name <- paste0(export_path, "/grts.sqlite")

    grtsdb::extract_sample(samplesize = n,
                   bbox = bbox,
                   cellsize = cellsize)

    DBI::dbDisconnect(connect_db("grts.sqlite"))

    #### Move db ####
    file.copy(from = "grts.sqlite",
              to = db_name)

    unlink("grts.sqlite")

    cleanup_sqlite("grts.sqlite")

  }else{
    db_name <- paste0(export_path, "/grts.sqlite")
  }

  ### Calculate samplesize of bbox ####
  # Deze waarde is groter dan de maximale samplesize => resulteert in alle
  # Samplepunten binnen de bbox
  bbox_samplesize <- as.integer(sf::st_area(perimeter)/cellsize^2)

  ### Connect to db ####
  con <- grtsdb::connect_db(db_name)

  ### Extract complete sample ####
  sample <- grtsdb::extract_sample(grtsdb = con,
                           samplesize = bbox_samplesize,
                           bbox = bbox,
                           cellsize = cellsize)

  ### Convert sample to sf ####
  all_sample_pts <- sample %>%
    sf::st_as_sf(coords = c("x1c", "x2c"),
                 crs = sf::st_crs(crs_bel))

  ### Convert sptsdf to GRID ####
  # 1.adjust the bbox: this ensures the sample points are contained within the cell
  adjusted_bbox <- sf::st_bbox(all_sample_pts) + c(-cellsize / 2, -cellsize / 2, cellsize / 2, cellsize / 2)

  # 2. create a grid
  sample_grid <- sf::st_make_grid(all_sample_pts,
                                  cellsize = cellsize,
                                  offset = c(adjusted_bbox[1], adjusted_bbox[2]))

  # 3. convert grid to sf
  sample_grid <- sf::st_sf(geometry = sample_grid)

  # 4. add ID
  sample_grid$ID_list = UUID_List(sample_grid)

  # 5. subset gridcells with a sample
  sample_grid_sub <- sf::st_intersection(sample_grid, all_sample_pts) %>%
    sf::st_drop_geometry() %>%
    dplyr::left_join(sample_grid, by = "ID_list") %>%
    sf::st_as_sf()

  ### Select gridcells inside perimeter ####
  sample_grid_intersect <- sf::st_intersection(perimeter,sample_grid)

  ### Select points inside perimeter ####
  # obv de IDs van de geselecteerde gridcells
  sample_pts_intersect <- sf::st_intersection(all_sample_pts, sample_grid_intersect)

  ### Transform spatial objects ####
  all_sample_pts <- sf::st_transform(all_sample_pts, crs_wgs)
  sample_grid_intersect <- sf::st_transform(sample_grid_intersect, crs_wgs) %>%
    dplyr::select(ID_list)
  perimeter <- sf::st_transform(perimeter, crs_wgs)
  sample_pts_intersect <- sf::st_transform(sample_pts_intersect, crs_wgs) %>%
    dplyr::select(ID_list, ranking)


  ## Resample ####
  final_sample_ranking <- head(sort(sample_pts_intersect$ranking), n)

  final_samples <- sample_pts_intersect %>%
    dplyr::filter(ranking %in% final_sample_ranking)

  ## Return ####
  return(list(seed = seed,
              points_in_perimeter = sample_pts_intersect,
              grid = sample_grid_intersect,
              samples = final_samples))
}

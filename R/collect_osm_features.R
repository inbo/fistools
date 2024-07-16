#' collect OpenStreetMaps features
#'
#' A function to collect custom osm features for a project
#'
#' @author Martijn Bollen
#'
#' @description
#' Extracts spatial features from the OpenStreetMaps server:
#' features that are extracted are re-classified into broad categories:
#' - osm_polygons: urban, agriculture, open, forest, water
#' - osm_lines: roads, waterways
#' - osm_points: city names
#'
#' @param proj_bbox A bbox. The bounding box for the project/ study area for which
#' to extract osm features.
#'
#' @param download_features A character. "all" download all features. "polygons",
#'  "lines" and "points" to download only polygon, line or point features respectively.
#'  Combinations are also possible (e.g. c("polygons", "points")). Default is "all".
#'
#' @param landuse_elements A character. "all" to download all landuse classes. "urban",
#' "agriculture", "open", "forest" and "water" to download only landuse classes
#' of interest. Combinations are also possible (e.g. c("urban", "forest", "water"))
#' Default is "all".
#'
#' @param line_elements A character. "all" to download all line elements. "road",
#' "water" to download only roads and rivers, streams etc. respectively.
#' Default is "all"
#'
#' @returns a named list of 3 sf data frames:
#' osm_polygons, osm_lines, osm_points. Each sf data frame contains the
#' corresponding geometry types.
#'
#' @details
#' dplyr and osmdata are automatically installed when missing from your system.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#'# extract the bounding box (WGS84) for the Project
#'proj_sf <- st_sfc(st_polygon(list(drg_example$spatial$coordinates[1,,])), crs = 4326)
#'proj_bbox <- st_bbox(proj_sf)
#'class(proj_bbox)

#'# extract selected OSM features
#'osm <- collect_osm_features(proj_bbox)
#'# extract only polygon OSM features
#'osm_polygons <- collect_osm_features(proj_bbox, download_features = "polygons")
# extract only line OSM features
#'osm_lines <- collect_osm_features(proj_bbox, download_features = "lines")
# extract only point OSM features
#'osm_points <- collect_osm_features(proj_bbox, download_features = "points")
# extract combination of OSM features, subset landuse elements
#'osm_forest_water <-
#'  collect_osm_features(proj_bbox, download_features = c("polygons", "points"),
#'                       landuse_elements = c("forest", "water"))
#'# extract combination of OSM features, subset line elements
#'osm_polygons_roads <-
#'  collect_osm_features(proj_bbox, download_features = c("polygons", "lines"),
#'                       line_elements = "road")
#'
#'# calculate the area of each landuse class within the bbox
#'landuse <- osm_polygons$osm_polygons %>%
#'  st_make_valid() %>%
#'  mutate(area = set_units(st_area(.), "km^2")) %>%
#'  group_by(landuse) %>%
#'  summarise(area = sum(area))
#'
#'# plot
#'## polygons
#'(p1 <- ggplot(osm_polygons$osm_polygons %>% filter(!is.na(landuse)) %>% arrange(landuse)) +
#'    geom_sf(aes(fill = landuse), col = NA) +
#'    scale_fill_manual(values = unique(arrange(osm$osm_polygons, landuse)$osm_fill)) +
#'    theme_void() + theme(legend.position = "right"))
#'
#'## lines
#'(p2 <- ggplot(osm_lines$osm_lines) +
#'    geom_sf(aes(col = line_element)) +
#'    scale_color_manual(values = c("grey50", "#0092da")) +
#'    theme_void() + theme(legend.position = "right"))
#'
#'## points
#'(p3 <- ggplot(osm_points$osm_points) + geom_sf_label(aes(label = name)))
#'
#'## combine features
#'p1 + geom_sf(data = osm$osm_lines, aes(col = line_element)) +
#'  geom_sf_label(data = osm$osm_points, aes(label = name)) +
#'  scale_color_manual(values = c("grey20", "#0092da")) +
#'  coord_sf(xlim = proj_bbox[c("xmin", "xmax")],
#'           ylim = proj_bbox[c("ymin", "ymax")])
#' }

collect_osm_features <- function(
    proj_bbox,
    download_features = "all",
    landuse_elements = "all",
    line_elements = "all") {

  # Transform "all" arguments
  if (length(download_features) == 1) {
    if (download_features == "all") {
      download_features <- c("polygons", "lines", "points")
    }
  }
  all_landuse <- F
  if (length(landuse_elements) == 1) {
    if (landuse_elements == "all") {
      all_landuse <- T
      landuse_elements <- c("urban", "agriculture", "open", "forest", "water")
    }
  }
  if (length(line_elements) == 1) {
    if (line_elements == "all") {
      line_elements <- c("road", "water")
    }
  }

  # Classification of landuse classes
  if ("polygons" %in% download_features) {
    urban_vals <-
      c("residential", "commercial", "industrial",
        "retail", "construction", "brownfield",
        "greenfield", "quarry", "landfill", "railway",
        "religious", "cemetery", "village_green",
        "military", "recreation_ground", "quarry")
    names(urban_vals) <- rep("urban", length(urban_vals))

    agriculture_vals <-
      c("animal_keeping", "farmland", "farmyard",
        "greenhouse_horticulture", "orchard",
        "vineyard", "plant_nursery", "allotments",
        "agricultural")
    names(agriculture_vals) <- rep("agriculture", length(agriculture_vals))

    open_vals <-
      c("grass", "grassland", "heath", "scrub", "wetland", "wood",
        "flowerbed", "meadow", "fell", "sand", "bare_rock", "mud")
    names(open_vals) <- rep("open", length(open_vals))

    forest_vals <- c("forest")
    names(forest_vals) <- rep("forest", length(forest_vals))

    water_vals <- c("water", "basin")
    names(water_vals) <- rep("water", length(water_vals))

    all_vals <- c(urban_vals, agriculture_vals, open_vals, forest_vals, water_vals)
  }

  # Retrieve raw osm feature sets
  if ("polygons" %in% download_features) {
    if (all_landuse) {
      osm_landuse <- osmdata::opq(bbox = proj_bbox) %>%
        osmdata::add_osm_feature(key = 'landuse') %>%
        osmdata::osmdata_sf()
    } else {
      selected_vals <- all_vals[names(all_vals) %in% landuse_elements]
      osm_landuse <- osmdata::opq(bbox = proj_bbox) %>%
        osmdata::add_osm_feature(key = 'landuse', value = selected_vals) %>%
        osmdata::osmdata_sf()
    }

    if ("water" %in% landuse_elements) {
      osm_waterbodies <- osmdata::opq(bbox = proj_bbox) %>%
        osmdata::add_osm_feature(key = 'natural', value = 'water') %>%
        osmdata::osmdata_sf()
    }
  }

  if ("lines" %in% download_features) {
    if ("road" %in% line_elements) {
      osm_roads <- osmdata::opq(bbox = proj_bbox) %>%
        osmdata::add_osm_feature(key = 'highway') %>%
        osmdata::osmdata_sf()
    }

    if ("water" %in% line_elements) {
      osm_waterways <- osmdata::opq(bbox = proj_bbox) %>%
        osmdata::add_osm_feature(key = 'waterway') %>%
        osmdata::osmdata_sf()
    }
  }

  if ("points" %in% download_features) {
    osm_cities <- osmdata::opq(bbox = proj_bbox) %>%
      osmdata::add_osm_feature(key = 'place', value = c('city', 'town', 'village')) %>%
      osmdata::osmdata_sf()
  }

  # Initialize sf data.frames
  polygons_sf <- lines_sf <- points_sf <- NULL

  # Process and store selected osm features
  if ("polygons" %in% download_features) {
    # Polygon features
    ## polygons
    polygons_sf1 <- osm_landuse$osm_polygons
    polygons_sf1 <- polygons_sf1 %>% dplyr::mutate(
      osm_id = rownames(.),
      landuse = dplyr::case_when(
        landuse %in% urban_vals ~ "urban",
        landuse %in% agriculture_vals ~ "agriculture",
        landuse %in% open_vals | natural %in% open_vals ~ "open",
        landuse %in% forest_vals ~ "forest",
        landuse %in% water_vals | natural %in% water_vals ~ "water")) %>%
      dplyr::select(osm_id, landuse)

    ## multipolygons
    polygons_sf2 <- osm_landuse$osm_multipolygons
    polygons_sf2 <- polygons_sf2 %>% dplyr::mutate(
      osm_id = rownames(.),
      landuse = dplyr::case_when(
        landuse %in% urban_vals ~ "urban",
        landuse %in% agriculture_vals ~ "agriculture",
        landuse %in% open_vals ~ "open",
        landuse %in% forest_vals ~ "forest",
        landuse %in% water_vals ~ "water")) %>%
      dplyr::select(osm_id, landuse)


    if ("water" %in% landuse_elements) {
      polygons_sf3 <- osm_waterbodies$osm_polygons
      polygons_sf3 <- polygons_sf3 %>%
        dplyr::mutate(osm_id = rownames(.), landuse = "water") %>%
        dplyr::select(osm_id, landuse)
    }

    polygons_sf <-
      do.call("rbind", mget(intersect(ls(), paste0("polygons_sf", 1:3)))) %>%
      dplyr::mutate(
        osm_fill = dplyr::case_when(
          landuse == "urban" ~ "grey90",
          landuse == "agriculture" ~ "#FDEBA6",
          landuse == "open" ~ "#7CFC00",
          landuse == "forest" ~ "#228B22",
          landuse == "water" ~ "#0092da"
        )
      )
  }

  if ("lines" %in% download_features) {
    # Line features
    if ("road" %in% line_elements) {
      lines_sf1 <- osm_roads$osm_lines
      lines_sf1 <- lines_sf1 %>%
        dplyr::mutate(line_element = "road", type = highway) %>%
        dplyr::select(osm_id, line_element, type)
    }

    if ("water" %in% line_elements) {
      lines_sf2 <- osm_waterways$osm_lines
      lines_sf2 <- lines_sf2 %>%
        dplyr::mutate(line_element = "water", type = waterway) %>%
        dplyr::select(osm_id, line_element, type)
    }

    lines_sf <- do.call("rbind", mget(intersect(ls(), paste0("lines_sf", 1:2))))
  }

  if ("points" %in% download_features) {
    # Point features
    points_sf <- osm_cities$osm_points
  }

  # Return selected osm features
  out <- list(osm_polygons = polygons_sf,
              osm_lines = lines_sf,
              osm_points = points_sf)
  out <- out[!sapply(out, is.null)]
  return(out)
}

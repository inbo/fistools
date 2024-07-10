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
#' @param proj_bbox a bbox. The bounding box for the project/ study area for which
#' to extract osm features.
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
#'
#'# plot
#'## polygons
#'(p1 <- ggplot(osm$osm_polygons %>% filter(!is.na(landuse)) %>% arrange(landuse)) +
#'    geom_sf(aes(fill = landuse), col = NA) +
#'    scale_fill_manual(values = unique(arrange(osm$osm_polygons, landuse)$osm_fill)) +
#'    theme_void() + theme(legend.position = "right"))
#'
#'## lines
#'(p2 <- ggplot(osm$osm_lines) +
#'    geom_sf(aes(col = landuse)) +
#'    scale_color_manual(values = c("grey50", "#0092da")) +
#'    theme_void() + theme(legend.position = "right"))
#'
#'## points
#'(p3 <- ggplot(osm$osm_points) + geom_sf_label(aes(label = name)))
#'
#'## combine features
#'p1 + geom_sf(data = osm$osm_lines, aes(col = landuse)) +
#'  geom_sf_label(data = osm$osm_points, aes(label = name)) +
#'  scale_color_manual(values = c("grey20", "#0092da")) +
#'  coord_sf(xlim = proj_bbox[c("xmin", "xmax")],
#'           ylim = proj_bbox[c("ymin", "ymax")])
#' }

collect_osm_features <- function(proj_bbox) {

  # classification of landuse classes
  urban_vals <-
    c("residential", "commercial", "industrial",
      "retail", "construction", "brownfield",
      "greenfield", "quarry", "landfill", "railway",
      "religious", "cemetery", "village_green",
      "military", "recreation_ground", "quarry")

  agriculture_vals <-
    c("animal_keeping", "farmland", "farmyard",
      "greenhouse_horticulture", "orchard",
      "vineyard", "plant_nursery", "allotments",
      "agricultural")

  open_vals <-
    c("grass", "grassland", "heath", "scrub", "wetland", "wood",
      "flowerbed", "meadow", "fell", "sand", "bare_rock", "mud")

  # Retrieve raw osm feature sets
  osm_landuse <- osmdata::opq(bbox = proj_bbox) %>%
    osmdata::add_osm_feature(key = 'landuse') %>%
    osmdata::osmdata_sf()

  osm_roads <- osmdata::opq(bbox = proj_bbox) %>%
    osmdata::add_osm_feature(key = 'highway') %>%
    osmdata::osmdata_sf()

  osm_waterways <- osmdata::opq(bbox = proj_bbox) %>%
    osmdata::add_osm_feature(key = 'waterway') %>%
    osmdata::osmdata_sf()

  osm_waterbodies <- osmdata::opq(bbox = proj_bbox) %>%
    osmdata::add_osm_feature(key = 'natural', value = 'water') %>%
    osmdata::osmdata_sf()

  osm_cities <- osmdata::opq(bbox = proj_bbox) %>%
    osmdata::add_osm_feature(key = 'place', value = c('city', 'town', 'village')) %>%
    osmdata::osmdata_sf()

  # Polygon features
  ## polygons
  landuse_polygons1 <- osm_landuse$osm_polygons
  landuse_polygons1 <- landuse_polygons1 %>% dplyr::mutate(
    landuse = dplyr::case_when(
      landuse %in% urban_vals ~ "urban",
      landuse %in% agriculture_vals ~ "agriculture",
      landuse %in% open_vals | natural %in% open_vals ~ "open",
      landuse == "forest" ~ "forest",
      landuse %in% c("basin") | natural == "water" ~ "water"))

  ## multipolygons
  landuse_polygons2 <- osm_landuse$osm_multipolygons
  landuse_polygons2 <- landuse_polygons2 %>% dplyr::mutate(
    landuse = dplyr::case_when(
      landuse %in% urban_vals ~ "urban",
      landuse %in% agriculture_vals ~ "agriculture",
      landuse %in% open_vals %in% open_vals ~ "open",
      landuse == "forest" ~ "forest",
      landuse %in% c("basin") ~ "water"))

  landuse_polygons3 <- osm_waterbodies$osm_polygons
  landuse_polygons3 <- landuse_polygons3 %>%
    dplyr::mutate(landuse = "water") %>%
    dplyr::select(osm_id, landuse)

  landuse_polygons <-
    dplyr::bind_rows(
      landuse_polygons1,
      landuse_polygons2,
      landuse_polygons3
    ) %>% dplyr::mutate(
      osm_fill = dplyr::case_when(
        landuse == "urban" ~ "grey90",
        landuse == "agriculture" ~ "#FDEBA6",
        landuse == "open" ~ "#7CFC00",
        landuse == "forest" ~ "#228B22",
        landuse == "water" ~ "#0092da"
      )
    )

  # Line features
  landuse_lines1 <- osm_roads$osm_lines
  landuse_lines1 <- landuse_lines1 %>%
    dplyr::mutate(landuse = "road", type = highway) %>%
    dplyr::select(osm_id, landuse, type)

  landuse_lines2 <- osm_waterways$osm_lines
  landuse_lines2 <- landuse_lines2 %>%
    dplyr::mutate(landuse = "water", type = waterway) %>%
    dplyr::select(osm_id, landuse, type)

  landuse_lines <-
    dplyr::bind_rows(
      landuse_lines1,
      landuse_lines2
    )

  # Point features
  landuse_points <- osm_cities$osm_points

  return(
    list(osm_polygons = landuse_polygons,
         osm_lines = landuse_lines,
         osm_points = landuse_points)
  )
}

#' Add habitat information to spatial features
#'
#' This function calculates habitat areas and related statistics for given spatial features
#'
#' @author Sander Devisscher
#'
#' @param sf_data An sf object containing the spatial features (polygons or multipolygons)
#' @param id_column A character string specifying the column name in sf_data that contains unique identifiers for each feature
#'
#' @details
#' The function performs the following steps:
#' 1. Validates the input sf object and checks for the presence of the specified id column.
#' 2. Loads the CORINE Land Cover 2018 data for Belgium (CLC18_BE) from the fistools package.
#' 3. Calculates the area of each feature in square meters, hectares, and square kilometers.
#' 4. Computes the intersection between the input features and the CLC18_BE habitat data.
#' 5. Calculates the area of each habitat type within each feature.
#' 6. Computes additional statistics for forest habitats (bos), including density, average area, and perimeter.
#' 7. Merges the habitat information back to the original sf_data and calculates habitat percentages.
#' 8. Ensures that the total habitat area does not differ from the total area by more than 1%.
#' 9. Returns a data frame with habitat areas and statistics for each feature.
#'
#' @returns A data frame with habitat areas and statistics for each feature
#'
#' @examples
#' \dontrun{
#' library(sf)
#'
#' # Load example spatial data (replace with actual data)
#' example_sf <- st_read("path_to_your_spatial_data.shp")
#'
#' # Add habitat information
#' habitat_info <- add_habitats(example_sf, id_column = "unique_id")
#' }
#'
#' @export
#'
#' @family spatial

add_habitats <- function(sf_data,
                         id_column){
  # Checks ####
  # Is sf_data an sf object?
  if(!inherits(sf_data, "sf")){
    stop("sf_data must be an sf object")
  }

  # Is sf_data geometry a valid geometry?
  # valid geometry is polygon or multipolygon
  if(!all(sf::st_geometry_type(sf_data) %in% c("POLYGON", "MULTIPOLYGON"))){
    stop("sf_data must have polygon or multipolygon geometry")
  }

  # Ensure id_column exists in sf_data
  if(!(id_column %in% colnames(sf_data))){
    stop(paste0("id_column '", id_column, "' not found in sf_data"))
  }

  # Calculate area of sf_data ####
  sf_data$Area_m2 <- as.numeric(sf::st_area(sf_data))

  sf_data <- sf_data |>
    dplyr::mutate(Area_ha = Area_m2 / 10000,
                  Area_km2 = Area_m2 / 1e6)

  # Calculate intersection ####
  # Reproject habitat data to sf_data CRS
  sf_data <- sf::st_transform(sf_data, sf::st_crs(fistools::CLC18_BE))

  # Calculate intersection
  intersection <- sf::st_intersection(sf::st_make_valid(sf_data),
                                      sf::st_make_valid(fistools::CLC18_BE))

  # Calculate area of intersection ####
  intersection$Area_hab_m2 <- as.numeric(sf::st_area(intersection))

  intersection <- intersection |>
    dplyr::mutate(Area_hab_ha = Area_hab_m2 / 10000,
                  Area_hab_km2 = Area_hab_m2 / 1e6)

  # Calculate the total habitat area per id ####
  habitat_data <- intersection |>
    as.data.frame() |>
    dplyr::group_by(.data[[id_column]], LABEL_Grouped) |>
    dplyr::summarise(Area_hab_m2 = sum(Area_hab_m2, na.rm = TRUE),
                     Area_hab_ha = sum(Area_hab_ha, na.rm = TRUE),
                     Area_hab_km2 = sum(Area_hab_km2, na.rm = TRUE)) |>
    dplyr::ungroup() |>
    tidyr::pivot_wider(id_cols = !!id_column,
                       names_from = LABEL_Grouped,
                       values_from = c(Area_hab_m2,
                                       Area_hab_ha,
                                       Area_hab_km2),
                       values_fill = 0)

  # Calculate bos parameters ####
  bos_data <- intersection |>
    dplyr::filter(LABEL_Grouped == "bos") |>
    dplyr::mutate(perimeter_m = as.numeric(sf::st_perimeter(geometry))) |>
    as.data.frame() |>
    dplyr::group_by(.data[[id_column]]) |>
    dplyr::summarize(densiteit_bos = dplyr::n(),
                     gem_opp_bos_m2 = mean(Area_hab_m2, na.rm = TRUE),
                     perimeter_bos_m = sum(perimeter_m, na.rm = TRUE)) |>
    dplyr::mutate(gem_opp_bos_ha = gem_opp_bos_m2 / 10000,
                  gem_opp_bos_km2 = gem_opp_bos_m2 / 1e6) |>
    dplyr::ungroup()

  # Merge habitats back to sf_data ####
  # and caclulate habitat percentages
  habitat_list <- sf_data |>
    as.data.frame() |>
    dplyr::select(.data[[id_column]], Area_m2, Area_ha, Area_km2) |>
    dplyr::left_join(habitat_data, by = id_column) |>
    dplyr::left_join(bos_data, by = id_column)

  # Final checks ####
  # Replace NA with 0 for habitat areas and percentages
  habitat_list <- habitat_list |>
    dplyr::mutate(dplyr::across(dplyr::starts_with("Area_hab_"),
                                ~ ifelse(is.na(.x), 0, .x)),
                  dplyr::across(dplyr::starts_with("perc_Area_hab_"),
                                ~ ifelse(is.na(.x), 0, .x)))

  # Recalculate andere
  habitat_list <- habitat_list |>
    dplyr::mutate(Area_hab_m2_andere = Area_m2
                  - Area_hab_m2_bos
                  - Area_hab_m2_water
                  - Area_hab_m2_landbouw
                  - Area_hab_m2_grasland
                  - Area_hab_m2_bebouwd,
                  Area_hab_m2_andere = dplyr::case_when(Area_hab_m2_andere < 0 ~ 0,
                                                        TRUE ~ Area_hab_m2_andere),
                  Area_hab_ha_andere = Area_hab_m2_andere / 10000 ,
                  Area_hab_km2_andere = Area_hab_m2_andere / 1e6)  |>
    dplyr::mutate(dplyr::across(dplyr::starts_with("Area_hab_"),
                                ~ .x / Area_m2 * 100,
                                .names = "perc_{.col}"))

  # Check if total of habitats does not exceed total area by more than 1% ####
  area_test <- habitat_list |>
    dplyr::select(.data[[id_column]], dplyr::contains("m2")) |>
    dplyr::select(-dplyr::contains("km2"),
                  -dplyr::contains("perc"),
                  -dplyr::contains("gem")) |>
    dplyr::group_by(.data[[id_column]]) |>
    dplyr::summarise(total_hab_area = sum(dplyr::across(dplyr::starts_with("Area_hab_")), na.rm = TRUE),
                     Area_m2 = unique(Area_m2)) |>
    dplyr::mutate(diff = Area_m2 - total_hab_area,
                  diff_prec = (abs(diff)/Area_m2)*100) |>
    dplyr::filter(diff_prec > 1)

  if(nrow(area_test) > 0){
    stop("Some geometries have habitat areas differing the total area by more than 1%. Please check the data.")
  }

  # Export habitat data ####
  return(habitat_list)
}

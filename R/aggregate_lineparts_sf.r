#' Connect separate line parts into 1 line
#'
#' @description
#' This function takes a sf object with separate line parts and connects them into 1 line.
#' The function is based on the st_union function from the sf package.
#' The function is designed to work with sf objects that have a column with unique
#' identifiers for the separate line parts.
#' The function will connect the line parts based on the unique identifier.
#'
#' @param sf_data A sf object with separate line parts
#' @param sf_id A character string with the name of the column with unique identifiers
#'
#' @return A sf object with connected line parts
#'
#' @family spatial
#' @export
#' @author Sander Devisscher
#'
#' @examples
#' \dontrun{
#' # create a sf object containing 2 seperate linstrings with wgs84 coordinates that lay within belgium
#' # add a column with the same id for both linestrings & a unique label for each line
#' sf_data <- sf::st_sfc(sf::st_linestring(matrix(c(5.5, 5.0, 50.0, 50.6), ncol = 2)),
#'                      sf::st_linestring(matrix(c(4.7, 4.8, 50.8, 50.8), ncol = 2))) %>%
#'  sf::st_sf(id = c("a", "a")) %>%
#'  dplyr::mutate(label = as.factor(dplyr::row_number()))
#'
#' # plot sf_data using leaflet
#' # create a palette for label
#' pal <- leaflet::colorFactor(palette = "RdBu", levels = sf_data$label)
#'
#' plot <- leaflet::leaflet() %>%
#'   leaflet::addTiles() %>%
#'   leaflet::addPolylines(data = sf_data, color = ~pal(label), weight = 5, opacity = 1)
#'
#' # connect the line parts
#' sf_data_connected <- aggregate_lineparts_sf(sf_data, "id")
#'
#' # add sf_data_connected to plot
#' plot <- plot %>%
#'   leaflet::addPolylines(data = sf_data_connected, color = "black", weight = 2, opacity = 0.5)
#'
#' plot
#' }

aggregate_lineparts_sf <- function(sf_data, sf_id) {

  utils::globalVariables(c(".data", ".", "lon", "lat", "distance", "geometry"))

  # Check if sf_data is a sf object
  if (!inherits(sf_data, "sf")) {
    stop("sf_data is not a sf object")
  }

  # Check if sf_id is a character string
  if (!is.character(sf_id)) {
    warning("sf_id is not a character string >> converting to character string")
    sf_id <- as.character(sf_id)
  }

  # Check if sf_id is a column in sf_data
  if (!(sf_id %in% names(sf_data))) {
    stop("sf_id is not a column in sf_data")
  } else {
    # If the column is not already called 'sf_id', create it
    if (sf_id != "sf_id") {
      sf_data <- sf_data %>%
        dplyr::mutate(sf_id = as.character(.data[[sf_id]]))
    }
  }

  # Ensure geometry column is present
  if (!"geometry" %in% names(sf_data)) {
    sf_data <- sf_data %>%
      dplyr::mutate(geometry = sf::st_geometry(.))
  }

  # Get unique sf_ids
  sf_ids <- unique(sf_data$sf_id)
  output <- data.frame()

  for (i in sf_ids) {
    # Get line parts with the same sf_id
    sf_unit <- sf_data %>%
      dplyr::filter(sf_id == i) %>%
      sf::st_union(by_feature = FALSE) %>%
      sf::st_cast("LINESTRING")

    # Create empty data frame to store points
    temp <- data.frame() %>%
      dplyr::mutate(lon = NA_real_, lat = NA_real_)

    # Loop over line parts to convert them to points
    for (n in 1:length(sf_unit)) {
      temp <- temp %>%
        dplyr::add_row(
          lon = sf_unit[[n]][, 1],
          lat = sf_unit[[n]][, 2]
        ) %>%
        dplyr::distinct(lon, lat) %>%
        dplyr::arrange(lat, lon)

      sf_point <- temp %>%
        sf::st_as_sf(coords = c("lon", "lat"))

      # Order points
      sf_point_ordered <- data.frame()
      a <- 1

      # Progress bar (optional, can be removed if not needed)
      pb <- progress::progress_bar$new(
        format = "  [:bar] :percent ETA: :eta",
        total = nrow(sf_point),
        clear = FALSE,
        width = 60
      )

      while (a <= nrow(sf_point)) {
        pb$tick()

        if (a == 1) {
          # Get first point
          sf_point_ref <- sf_point[a, ]
          # Select the other points of the linepart
          outside <- as.vector(sapply(
            sf::st_intersects(sf_point, sf_point_ref),
            function(x) length(x) == 0
          ))
          sf_point_comp <- sf_point[outside, ]
          # Calculate distance between points
          sf_point_comp$distance <- as.vector(sf::st_distance(sf_point_comp, sf_point_ref))

          # Check if there are points to compare
          if (nrow(sf_point_comp) > 0 && any(!is.na(sf_point_comp$distance))) {
            min_dist <- min(sf_point_comp$distance, na.rm = TRUE)
            sf_point_new_ref <- sf_point_comp %>%
              dplyr::filter(distance == min_dist) %>%
              dplyr::select(geometry)
          } else {
            break
          }

          # Add the new point to the ordered points
          sf_point_ordered <- rbind(sf_point_ref, sf_point_new_ref)
          a <- a + 1

        } else {
          # Get the other points of the linepart
          sf_point_ref <- sf_point_new_ref
          # Select the other points of the linepart
          outside <- as.vector(sapply(
            sf::st_intersects(sf_point, sf_point_ordered),
            function(x) length(x) == 0
          ))
          sf_point_comp <- sf_point[outside, ]
          # Calculate distance between points
          sf_point_comp$distance <- as.vector(sf::st_distance(sf_point_comp, sf_point_ref))

          # Check if there are points to compare
          if (nrow(sf_point_comp) > 0 && any(!is.na(sf_point_comp$distance))) {
            min_dist <- min(sf_point_comp$distance, na.rm = TRUE)
            sf_point_new_ref <- sf_point_comp %>%
              dplyr::filter(distance == min_dist) %>%
              dplyr::select(geometry)
          } else {
            break
          }

          # Add the new point to the ordered points
          sf_point_ordered <- rbind(sf_point_ordered, sf_point_new_ref)
          a <- a + 1
        }
      }

      # Convert ordered points to linestring
      test_sf <- sf_point_ordered %>%
        sf::st_coordinates() %>%
        sf::st_linestring() %>%
        sf::st_geometry()
    }

    # Add sf_id to the linestring
    test_sf2 <- as.data.frame(test_sf) %>%
      dplyr::mutate(sf_id = i)

    # Add linestring to output
    if (nrow(output) == 0) {
      output <- test_sf2
    } else {
      output <- rbind(output, test_sf2)
    }
  }

  # Convert output to sf object
  output <- output %>%
    sf::st_as_sf()

  return(output)
}


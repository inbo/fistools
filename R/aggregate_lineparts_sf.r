#' Connect seperate line parts to one line
#'
#' This function takes a sf object with seperate line parts and connects them to one line.
#' The function is based on the st_union function from the sf package.
#' The function is designed to work with sf objects that have a column with unique
#' identifiers for the seperate line parts.
#' The function will connect the line parts based on the unique identifier.
#'
#' @param sf_data A sf object with seperate line parts
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
#' # create a sf object with 2 line parts with the same id with wgs84 as crs
#' sf_data <- st_sfc(st_linestring(matrix(c(0,0,1,1), ncol = 2)),
#'                  st_linestring(matrix(c(1,1,2,2), ncol = 2))) %>%
#'                  st_sf(sf_id = c("a", "a"))
#'
#' # connect the line parts
#' sf_data_connected <- aggregate_lineparts_sf(sf_data, "sf_id")
#'
#' # plot the connected line parts & the seperate line parts
#' plot(sf_data)
#' plot(sf_data_connected)
#' }

aggregate_lineparts_sf <- function(sf_data,
                                   sf_id){

  # check if sf_data is a sf object
  if(!inherits(sf_data, "sf")){
    stop("sf_data is not a sf object")
  }

  # check if sf_id is a character string
  if(!is.character(sf_id)){
    warning("sf_id is not a character string >> converting to character string")
    sf_id <- as.character(sf_id)
  }

  # check if sf_id is a column in sf_data
  if(!(sf_id %in% names(sf_data))){
    stop("sf_id is not a column in sf_data")
  } else {
    sf_data <- sf_data %>%
      dplyr::mutate(sf_id = as.character(sf_data[[sf_id]]))
  }

  # check if geometry is present
  if(!"geometry" %in% names(sf_data)){
    sf_data <- sf_data %>%
      dplyr::mutate(geometry = sf::st_geometry(.))
  }

  # get unique sf_ids
  sf_ids <- unique(sf_data$sf_id)

  output <- data.frame()

  for(i in sf_ids){
    # get line parts with the same sf_id
    sf_unit <- sf_data %>%
      dplyr::filter(sf_id == i) %>%
      sf::st_union(by_feature = FALSE) %>%
      sf::st_cast("LINESTRING")

    # create empty data frame to store points
    temp <- data.frame() %>%
      dplyr::mutate(lon = NA_integer_,
             lat = NA_integer_)

    # loop over line parts to convert them to points
    for(n in 1:length(sf_unit)){
      temp <- temp %>%
        dplyr::add_row(lon = sf_unit[[n]][,1],
                lat = sf_unit[[n]][,2]) %>%
        dplyr::distinct(lon, lat) %>%
        dplyr::arrange(lat, lon)

      sf_point <- temp %>%
        sf::st_as_sf(coords = c("lon", "lat"))

      # order points
      sf_point_ordered <- data.frame()

      a <- 1

      while(a <= nrow(sf_point)){
        print(a)
        if(a == 1){
          # get first point
          sf_point_ref <- sf_point[a,]
          # select the other points of the linepart
          outside <- sapply(sf::st_intersects(sf_point, sf_point_ref),function(x){length(x)==0})
          sf_point_comp <- sf_point[outside, ]

          # calculate distance between points
          sf_point_comp$distance <- sf::st_distance(sf_point_comp, sf_point_ref)

          # get the point with the smallest distance
          sf_point_new_ref <- as.data.frame(sf_point_comp) %>%
            sf::st_as_sf() %>%
            dplyr::mutate(min = min(distance, na.rm = TRUE)) %>%
            dplyr::filter(distance == min) %>%
            dplyr::select(geometry)

          # add the new point to the ordered points
          sf_point_ordered <- rbind(sf_point_ref, sf_point_new_ref)

          a <- a + 1

        }else{
          # get the other points of the linepart
          sf_point_ref <- sf_point_new_ref
          # select the other points of the linepart
          outside <- sapply(sf::st_intersects(sf_point, sf_point_ordered),function(x){length(x)==0})
          # calculate distance between points
          sf_point_comp <- sf_point[outside, ]
          # calculate distance between points
          sf_point_comp$distance <- sf::st_distance(sf_point_comp, sf_point_ref)
          # get the point with the smallest distance
          sf_point_new_ref <- as.data.frame(sf_point_comp) %>%
            sf::st_as_sf() %>%
            dplyr::mutate(min = min(distance, na.rm = TRUE)) %>%
            dplyr::filter(distance == min) %>%
            dplyr::select(geometry)
          # add the new point to the ordered points
          sf_point_ordered <- rbind(sf_point_ordered, sf_point_new_ref)

          a <- a + 1
        }
      }

      # convert ordered points to linestring
      test_sf <- sf_point_ordered %>%
        sf::st_coordinates() %>%
        sf::st_linestring() %>%
        sf::st_geometry()
    }

    # add sf_id to the linestring
    test_sf2 <- as.data.frame(test_sf) %>%
      dplyr::mutate(sf_id = i)

    # add linestring to output
    if(nrow(output) == 0){
      output <- test_sf2
    }else{
      output <- rbind(output, test_sf2)
    }
  }

  # convert output to sf object
  output <- output %>%
    sf::st_as_sf()

  return(output)
}

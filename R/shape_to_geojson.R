#' Convert shapefiles to geojson
#' Deze functie zet alle shapes in een specifieke map, één bestand of een lijst van bestanden
#' van .shp om naar .geojson.
#' Daarnaast wordt de projectie getransformeerd naar wgs84 of een andere projectie.
#'
#' @param input een character string, een map, een bestand of een lijst van bestanden
#' @param output een character string, de map waar de geojson bestanden worden
#' opgeslagen, default is de input map
#' @param output_crs een integer, de projectie van de output, default is wgs84
#' @param overwrite een boolean of character string, Vraag of de bestanden mogen
#' overschreven worden, default is "ask"
#'
#' @details
#' De functie checkt of de input een map is, als dit het geval is worden alle .shp
#' bestanden in de map omgezet naar .geojson. Als de input geen map is, wordt de
#' input als bestand beschouwd en wordt deze omgezet naar .geojson.
#'
#' Als de output niet is gespecificeerd, wordt de output gelijkgesteld aan de input.
#'
#' @family spatial
#' @export
#' @author Sander Devisscher
#'
#' @returns een .geojson bestand of meerdere .geojson bestanden
#'
#' @examples
#' \dontrun{
#' # Voorbeeld van hoe de shape_to_geojson functie te gebruiken
#' # Sla boswachterijen_2024 op als .shp bestand in een tempdir
#' boswachterijen_2024 <- fistools::boswachterijen$boswachterijen_2024
#' tempdir <- tempdir()
#' sf::st_write(boswachterijen_2024, paste0(tempdir, "/boswachterijen_2024.shp"))
#'
#' # controleer of de shp goed opgeslagen werd
#' browseURL(tempdir)
#'
#' # Zet de shp om naar geojson
#' shape_to_geojson(input = tempdir)
#'
#' # Read and plot the geojson
#' boswachterijen_2024_geojson <- sf::st_read(paste0(tempdir, "/boswachterijen_2024.geojson"))
#' leaflet::leaflet() %>%
#'  leaflet::addTiles() %>%
#'  leaflet::addPolygons(data = boswachterijen_2024_geojson)
#'  }

shape_to_geojson <- function(input,
                             output,
                             output_crs = 4326,
                             overwrite = "ask"){

  ## Check if the input is a directory ####
  if(dir.exists(input)){
    filelist <- dir(path = input, pattern = ".shp", recursive = TRUE)
    ## Overwrite output with input if not specified
    if(missing(output)){
      cat("Output folder is not specified, using input folder as output folder")
      output <- input
    }
  }else{
    filelist <- list(input)

    ## Extract input folder ####
    input <- dirname(input)

    ## Output is not specified, but needed
    if(missing(output)){
      stop("The output folder is not specified, but needed >> specify output folder")
    }
  }

  ## Check if the output folder exists ####
  if(!dir.exists(output)){
    dir.create(output)
  }

  ## Check if the output crs is an integer ####
  output_crs <- as.integer(output_crs)

  if(is.na(output_crs)){
    stop("The output crs should be an integer")
  }

  ## Check if the overwrite is a boolean or character string ####
  if(!is.logical(overwrite) & !is.character(overwrite)){
    stop("The overwrite should be a boolean or character string")
  }

  ## omit .shp.xml extention files
  filelist <- gsub(pattern = ".xml", replacement = "", filelist)
  filelist <- gsub(pattern = ".shp", replacement = "", filelist)
  filelist <- unique(filelist)

  ## Loop over the filelist ####
  for(f in filelist){
    output_fn <- paste0(f, ".geojson")

    ## Check if the output file exists ####
    if(file.exists(here::here(output, output_fn))){
      if(overwrite == "ask"){
        q_overwrite <- utils::askYesNo(paste0(output_fn, " already exists, overwrite?"))
      }else{
        q_overwrite <- overwrite
      }
    }else{
      q_overwrite <- overwrite
    }

    shape <- sf::st_read(here::here(input, paste0(f, ".shp")))

    ## Check if the shape has a crs ####
    if(is.na(sf::st_crs(shape))){
      cat(paste0(f, " has no crs, please provide a crs & retry >> skipping"))
      next()
    }

    ## Check if the crs is not wgs84 ####
    if(sf::st_crs(shape)$input != output_crs){
      cat(paste0(f, " is not output crs >> transforming"))
      shape <- sf::st_transform(shape, output_crs)
    }

    ## Write the shape to geojson ####
    sf::st_write(shape, here::here(output, output_fn),
                 driver = "GeoJSON",
                 overwrite = q_overwrite)
  }
}







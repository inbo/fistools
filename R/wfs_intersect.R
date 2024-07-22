#' @title Extract values from web feature service (wfs)
#'
#' @description This function extracts values from a web feature service (wfs)
#'
#' @param df A `data.frame` with x and y coordinates in the Belgian Lambert 72 (EPSG:31370)
#' @param x_lam A character string with the column name of the X coordinate
#' @param y_lam A character string with the column name of the Y coordinate
#' @param url A character string with the url of the wfs
#' @param layer A character string with the name of the layer in the wfs
#'
#' @return A `data.frame` with the values of the wfs appended to the list of points
#'
#' @export
#' @family download_functions
#'
#' @examples
#' \dontrun{
#' }
extract_soil_map_data <- function(df,
                                  x_lam,
                                  y_lam,
                                  url,
                                  layer
                                  ) {

  # check if x_lam & y_lam are in the df
  if (!all(c(x_lam, y_lam) %in% names(df))) {
    stop("x_lam and y_lam should be columns in the df")
  }

  # check if the layer is in the wfs
  wfs_layers <- get_wfs_layers(url)

  if (!layer %in% wfs_layers) {
    stop(paste(
      layer,
      "is not available in the wfs. The available layers are:",
      paste(wfs_layers, collapse = ", ")
    ))
  }

  # dealing with point data inside a certain polygon of the soil map:
  query <- list(
    service = "WFS",
    request = "GetFeature",
    version = "1.1.0",
    typeName = layer,
    outputFormat = "json",
    CRS = "EPSG:31370",
    CQL_FILTER = sprintf(
      "INTERSECTS(geom,POINT(%s %s))",
      x_lam, y_lam
    )
  )

  result <- GET(wfs_bodemtypes, query = query)
  if (grepl("ExceptionText", content(result, "text"))) {
    stop(paste(
      paste(properties_of_interest, collapse = ", "),
      "is not available for bodemkaart:bodemtypes.",
      "The possible propertyName values are: [gid, id_kaartvlak, geom, Bodemtype
      , Unibodemtype, Bodemserie, Beknopte_omschrijving_bodemserie,
      Substraat_legende, Gegeneraliseerde_legende, Substraat_code,
      Substraat_Vlaanderen, Textuurklasse_code, Textuurklasse,
      Drainageklasse_code, Drainageklasse, Profielontwikkelingsgroep_code,
      Profielontwikkelingsgroep, Fase_code, Fase,
      Variante_van_het_moedermateriaal_code, Variante_van_het_moedermateriaal,
      Variante_van_de_profielontwikkeling_code,
      Variante_van_de_profielontwikkeling, Substraat_code_zeepolders,
      Substraat_zeepolders, Streek_code, Streek, Serie_code, Serie,
      Subserie_code, Subserie, Type_code, Type, Subtype_code, Subtype,
      Eenduidige_legende_titel, Eenduidige_legende, Scan_analoge_bodemkaarblad,
      Scan_toelichtingsboekje, Scan_bodemkaart5000, Scan_stippenkaart5000,
      Type_classificatie, Bodemtype_per_streek, Kaartbladnr, codeid]"
    ))
  }
  parsed <- fromJSON(content(result, "text"))
  soil_info_df <- parsed$features$properties
  # if else to catch cases where a point falls outside the map
  if (is.null(soil_info_df)) {
    as.data.frame(
      matrix(rep(NA, length(properties_of_interest)),
             nrow = 1,
             dimnames = list(NULL, properties_of_interest)
      )
    )
  } else {
    soil_info_df
  }
}

#' Function to get the available layers in a wfs
#'
#' @param url A character string with the url of the wfs
#'
#' @return A character vector with the available layers in the wfs
#'
#' @export
get_wfs_layers <- function(url) {
  result <- GET(url)
  parsed <- fromJSON(content(result, "text"))
  wfs_layers <- parsed$operations$GetFeature$parameters$type$allowedValues$value
  wfs_layers
}

#' Get Wekeo data using Earthkit
#'
#' @author Martijn Bollen & Sander Devisscher
#'
#' This function retrieves data from the Wekeo service using the Earthkit library.
#'
#' @param dataset_id The dataset identifier.
#' @param api_request The API request in JSON format.
#' @param bbox A bounding box for the data request (optional).
#' @param productType The type of product to request (optional).
#' @param resolution The resolution of the data (optional).
#' @param startdate The start date for the data request (optional).
#' @param enddate The end date for the data request (optional).
#' @param itemsPerPage The number of items per page (default is 200).
#' @param startIndex The starting index for pagination (default is 0).
#'
#' @details
#' This function retrieves data from the [Wekeo service](https://wekeo.copernicus.eu/) using the Earthkit library.
#' It constructs an API request based on the provided parameters and downloads the data.
#' This function is a wrapper around the `earthkit_download` from python function.
#' To get this function to work, you need to have the `earthkit` python package installed
#' which depends on the `Microsoft C++ Build Tools`.
#' This toolkit is required to compile the `earthkit` package.
#' To install the toolkit please place ict helpdesk call at `ict.helpdesk@inbo.be`
#'
#' When no API request is provided the function constructs a custom API request.
#' When the API request is provided, it will be used directly, ignoring the other parameters (except dataset_id).
#'
#' @return A terra SpatRaster object containing the requested data.
#' @export
#'
#' @family download
#'
#' @examples
#' \dontrun{
#'
#' # Example usage with a custom API request
#' api_request <- '{
#' "dataset_id": "EO:CLMS:DAT:CLMS_GLOBAL_NDVI_300M_V1_10DAILY_NETCDF",
#' "productType": "NDVI300",
#' "resolution": "300",
#' "startdate": "2021-01-01T00:00:00.000Z",
#' "enddate": "2021-01-29T23:59:59.999Z",
#' "itemsPerPage": 200,
#' "startIndex": 0
#' }'
#'
#' Call the function with the custom API request
#' data <- get_wekeo_data(
#'   dataset_id = "EO:CLMS:DAT:CLMS_GLOBAL_NDVI_300M_V1_10DAILY_NETCDF",
#'   api_request = api_request
#'   )
#' }


get_wekeo_data <- function(dataset_id,
                           api_request,
                           bbox = NULL,
                           productType,
                           resolution,
                           startdate,
                           enddate,
                           itemsPerPage = 200,
                           startIndex = 0){

  # Check if dataset_id is provided
  if(missing(dataset_id)) {
    stop("dataset_id is required")
  }

  # Check if api_request is provided or construct it
  if(!missing(api_request)){
    cat(paste0("Using provided API request:\n", api_request, "\n"))
  }else{
    cat("No API request provided, constructing default request.\n")

    # Construct the API request
    # dataset_id is mandatory
    # productType, resolution, startdate, enddate and bbox are optional
    # itemsPerPage and startIndex are used for pagination
    # The base API request exists of dataset_id
    api_request <- paste0('{
  "dataset_id": "', dataset_id, '"')

    # Add optional parameters to the API request
    if(!missing(productType)) {
      api_request <- paste0(api_request, ', "productType": "', productType, '"')
    }

    if(!missing(resolution)) {
      api_request <- paste0(api_request, ', "resolution": "', resolution, '"')
    }

    if(!missing(startdate)) {
      api_request <- paste0(api_request, ', "startdate": "', startdate, '"')
    }

    if(!missing(enddate)) {
      api_request <- paste0(api_request, ', "enddate": "', enddate, '"')
    }

    if(!missing(bbox)) {
      bbox_str <- paste(bbox, collapse = ",")
      api_request <- paste0(api_request, ', "bbox": [', bbox_str, ']')
    }

    # Add pagination parameters
    # These should allways be added to the API request
    api_request <- paste0(api_request, ',
  "itemsPerPage": ', itemsPerPage, ',
  "startIndex": ', startIndex, '
    }')
  }

  # Download the data using the earthkit_download function
  r <- earthkit_download(
    dataset_id = dataset_id,
    api_request = api_request
  ) |> terra::rast()
}


#' Wrapper function for ekd.from_source
#' @param source The data source, e.g., "wekeo".
#' @param dataset_id The dataset identifier.
#' @param api_request The API request in JSON format.
#' @param cache_dir Directory to store cached files.
#' @return The path to the downloaded file.

earthkit_download <- function(
    source = "wekeo",
    dataset_id,
    api_request,
    cache_dir = file.path(Sys.getenv("USERPROFILE"), ".earthkit_cache")
) {
  #create the cache directory if it doesn't exist
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  # Create a temporary variable name to capture the path
  reticulate::py_run_string("ekd_path_out = None")

  python_code <- paste(
    "import earthkit.data as ekd",
    "import warnings",
    "warnings.filterwarnings('ignore')",
    sprintf("ekd.settings.set({'cache-policy': 'user', 'user-cache-directory': r'%s'})", cache_dir),
    "print('Using Earthkit cache at:', ekd.cache.directory())",
    sprintf("request = %s", api_request),
    sprintf("ds = ekd.from_source('%s', '%s', request=request)", source, dataset_id),
    "path = ds.path",  # cached file path (usually a .nc or .grib file)
    "ekd_path_out = path",
    sep = "\n"
  )

  reticulate::py_run_string(python_code)

  # Return the cached file path back to R
  return(py$ekd_path_out)
}

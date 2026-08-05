#' Redo non-tracked sequences
#'
#' Sometimes, previously reviewed animal tracking sequences need to be redone.
#' This occurs when animal speeds cannot be calculated due to an insufficient
#' number of logged positions, when additional species need to be tracked,
#' or when REM results indicate a potential issue.
#'
#' @param track_data a camtrapdb datapackage
#' @param seq_done_in a character list with viewed sequences
#' @param redo_toofew_positions a boolean to hardcode redoing too few positions
#' (default = NULL)
#' @param redo_non_tracked a boolean to hardcode redoing non-tracked
#' (default = NULL)
#'
#' @details
#' This function detects non-tracked sequences in `seq_done_in` and removes them
#' from the list if `redo_non_tracked == TRUE`. The modified list is then
#' exported as `seq_done_out`. If `redo_non_tracked == NULL` (the default), the user
#' is prompted whether they want to perform the rerun.
#'
#' Sequences with issues calculating animal speed are exported as separate
#' dataframes. If there are sequences lacking positions, they are removed from
#' `seq_done_out` if `redo_toofew_positions == TRUE`. If
#' `redo_toofew_positions == NULL` (the default), the user is prompted whether
#' to perform the rerun. Regardless of the `redo_toofew_positions` value,
#' these cases are always exported as a separate dataframe.
#'
#' Currently, the function flags the following issues:
#'  - Parsing errors
#'  - Calibration with too few poles
#'  - Sequences with too few positions
#'
#' Other issues are also exported in the `non_tracked_other_issues` dataframe.
#'
#' @return A list containing the following exports:
#' \itemize{
#'   \item \code{seq_done_out}: A character vector of sequence IDs to be tracked.
#'   \item \code{non_tracked_parsing_error}: A dataframe of sequences with
#'   parsing errors.
#'   \item \code{non_tracked_toofew_poles}: A dataframe of sequences with a
#'   calibration lacking poles.
#'   \item \code{non_tracked_toofew_positions}: A dataframe of sequences with
#'   too few positions.
#'   \item \code{non_tracked_other_issues}: A dataframe of sequences with other
#'   remarks.
#' }
#'
#' @family agouti
#' @export
#'
#' @author Sander Devisscher
#'
#' @examples
#' \dontrun{
#' zip_dir <- tempdir()
#' files_dir <- paste0(zip_dir, "\\Files\\")
#'
#' download_gdrive_if_missing(gfileID = "1U7cSwhUZRJlR_zpJvYyhsi24J2QV8U8q",
#'                            destfile = file.path(zip_dir, "gmu8.zip"),
#'                            update_always = TRUE,
#'                            email = Sys.getenv("email"))
#'
#' unzip(paste0(zip_dir, "/gmu8.zip"),
#'       exdir = file.path(files_dir))
#'
#' gmu8 <- camtrapdp::read_camtrapdp(paste0(files_dir, "/datapackage.json"))
#'
#' calibration_deps <- gmu8 %>%
#'   camtrapdp::filter_observations(cameraSetupType == "calibration")
#'
#' obs_list <- calibration_deps$data$observations
#' dep_list <- unique(obs_list$deploymentID)
#'
#' data <- gmu8 |>
#'   camtrapdp::filter_deployments(deploymentID %in% dep_list)
#'
#' track_data <- data %>%
#'   camtrapdp::filter_observations(scientificName %in% "Sus scrofa")
#'
#' file_path <- "../fis-rem-tracking/GMU8/Input/tracking_seq_done.csv"
#'
#' seq_done <- tryCatch({
#'   # Attempt to read the CSV file
#'   read.csv(file_path)
#' }, error = function(e) {
#'   # If an error occurs (e.g., file not found), create the dummy data frame
#'   data.frame(sequenceID = character())
#' })
#'
#' seq_done <- c(seq_done$sequenceID)
#'
#' redo_non_tracked <- redo_non_tracked(track_data = track_data,
#'                                      seq_done_in = seq_done)
#'
#' seq_done_out <- redo_non_tracked$seq_done_out
#' parsing_issues <- redo_non_tracked$non_tracked_parsing_error
#' toofew_poles <- redo_non_tracked$non_tracked_toofew_poles
#' toofew_positions <- redo_non_tracked$non_tracked_toofew_positions
#' other_issues <- redo_non_tracked$non_tracked_other_issues
#' }

redo_non_tracked <- function(track_data,
                             seq_done_in,
                             redo_toofew_positions = NULL,
                             redo_non_tracked = NULL){

  seq_done_out <- seq_done_in

  # Filter non tracked sequences
  non_tracked <- track_data |>
    camtrapdp::filter_observations(is.na(individualSpeed) & observationLevel == "event")

  # Filter tracked data
  tracked <- track_data |>
    camtrapdp::filter_observations(!is.na(individualSpeed) & observationLevel == "event")

  # Extract sequenceIDs
  non_tracked_seq <- unique(non_tracked$data$observations$eventID)
  tracked_seq <- unique(tracked$data$observations$eventID)

  # Omit sequences with multiple observations of which at least 1 observation has
  # been tracked
  non_tracked_seq <- non_tracked_seq[!non_tracked_seq %in%
                                       tracked_seq]

  # Sometimes the sequence is tracked but the speed could not be calculated
  # This occurs in 3 known cases, namely:
  # 1. An error occured while parsing the data => These should be reported to Yorick
  non_tracked_parsing_error <- non_tracked$data$observations |>
    dplyr::filter(grepl(pattern = "Error parsing all data",
                 x = observationComments))

  non_tracked_seq <- non_tracked_seq[!non_tracked_seq %in%
                                       non_tracked_parsing_error$eventID]

  # 2. Not enough poles were available to do the calibration. These should be
  # revisited via another way.
  non_tracked_toofew_poles <- non_tracked$data$observations |>
    dplyr::filter(grepl(pattern = "Not enough poles calibrated, minimum is 6",
                 x = observationComments))

  non_tracked_seq <- non_tracked_seq[!non_tracked_seq %in%
                                       non_tracked_toofew_poles$eventID]

  # 3. Not enough positions were logged to calculate the speed => These should be
  # revisited via this script.
  non_tracked_toofew_positions <- non_tracked$data$observations |>
    dplyr::filter(grepl(pattern = "Not enough positions for speed and distance",
                 x = observationComments))

  if(nrow(non_tracked_toofew_positions) > 0){
    if(is.null(redo_toofew_positions)){
      redo_toofew_positions <- askYesNo(msg = paste(nrow(non_tracked_toofew_positions),
                                                    "sequenties with too few positions detected, redo?"))
    }
    if(!redo_toofew_positions){
      non_tracked_seq <- non_tracked_seq[!non_tracked_seq %in%
                                           non_tracked_toofew_positions$eventID]
    }
  }

  # x. Other issues. These are not omited from the non-tracked sequences
  non_tracked_other_issues <- non_tracked$data$observations |>
    dplyr::filter(!eventID %in% c(non_tracked_parsing_error$eventID,
                                  non_tracked_toofew_poles$eventID,
                                  non_tracked_toofew_positions$eventID)) |>
    dplyr::filter(!is.na(observationComments))

  non_tracked_done <- unique(seq_done_out[seq_done_out %in% non_tracked_seq])

  if(length(non_tracked_done) > 0){
    cat(length(non_tracked_done), "Non-tracked sequences detected on the sequences
      done list => asking rerun")
    if(is.null(redo_non_tracked)){
      redo_non_tracked <- askYesNo("Do you want to redo the non-tracked sequences ?")
    }

    if(redo_non_tracked){

      seq_done_out <- seq_done_out[!seq_done_out %in% non_tracked_seq]

    }
  }

  return(list(
    seq_done_out = seq_done_out,
    non_tracked_parsing_error = non_tracked_parsing_error,
    non_tracked_toofew_poles = non_tracked_toofew_poles,
    non_tracked_toofew_positions = non_tracked_toofew_positions,
    non_tracked_other_issues = non_tracked_other_issues
  ))
}

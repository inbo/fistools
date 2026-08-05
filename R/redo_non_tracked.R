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
#'
#' @author Sander Devisscher
#'
#' @examples
#' \dontrun{
#' }

redo_non_tracked <- function(track_data,
                             seq_done_in,
                             redo_toofew_positions = NULL,
                             redo_non_tracked = NULL){

}

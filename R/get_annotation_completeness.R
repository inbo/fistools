#' get_annotation_completeness
#'
#' @author Martijn Bollen
#'
#' @description Screen Data Package for Demographic Annotation Coverage.
#' Identifies time periods and deployment windows where demographic attributes
#' (`lifeStage`, `sex`, or custom fields) are actively annotated (non-NA).
#'
#' @param package Camera trap data package object (as returned by `read_camtrap_dp()`).
#' @param fields Character vector of column names in `package$data$observations` to evaluate.
#'   Defaults to `c("lifeStage", "sex")`.
#' @param mode Character string (`"any"` or `"all"`). `"any"` flags observations where at least
#'   one field is annotated; `"all"` requires all specified fields to be non-NA. Defaults to `"any"`.
#' @param species Scientific or vernacular species name(s) to filter on. Defaults to `"all"`.
#' @param by Character vector of column name(s) in `package$data$deployments` to group by
#'   (e.g., `"deploymentID"`, `"locationName"`). Use `"all"` or `NULL` to screen the entire dataset. Defaults to `"deploymentID"`.
#'
#' @returns A tibble detailing observation counts, percentage annotated, first and last
#'   annotated timestamps, and total annotated duration (in days) per group.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Data paths
#' zipfile <- "../fis-grofwild/Projecten/Drongengoed/Input/Agouti/drongengoed.zip"
#' exdir <- "../fis-grofwild/Projecten/Drongengoed/Input/Agouti/filesDRG"
#'
#' # Download and unzip files
#' download_gdrive_if_missing("1F7mCj-Wm0Ggq1evz1HusxZBgX-1ttx-S", destfile = zipfile)
#' unzip(zipfile, exdir = exdir)
#'
#' # Import as Camtrap DP
#' drg <- camtraptor::read_camtrap_dp(file.path(exdir, "datapackage.json"))
#'
#' # Check deployments where EITHER lifeStage OR sex is annotated
#' drg$data$deployments <- drg$data$deployments %>%
#' mutate(year = year(start), month = month(start),
#'        year_month = floor_date(start, unit = "month"))
#'
#' coverage_dep <- get_annotation_completeness(
#' package = drg,
#' fields = c("lifeStage", "sex"),
#' mode = "any",
#' species = "Capreolus capreolus",
#' by = "year_month"
#' )
#' }
#'

get_annotation_completeness <- function(
    package,
    fields = c("lifeStage", "sex"),
    mode = c("any", "all"),
    species = "all",
    by = "deploymentID") {
  mode <- match.arg(mode)

  obs <- package$data$observations
  dep <- package$data$deployments

  # 1. Validate requested fields exist in observations
  missing_fields <- setdiff(fields, names(obs))
  if (length(missing_fields) > 0) {
    stop(sprintf("Field(s) %s not found in package$data$observations.",
                 paste(sQuote(missing_fields), collapse = ", ")))
  }

  # 2. Identify timestamp column
  ts_col <- intersect(c("timestamp", "eventStart", "observationStart"), names(obs))[1]
  if (is.na(ts_col)) {
    stop("Could not find a valid timestamp column (e.g., 'timestamp', 'eventStart') in observations.")
  }

  # 3. Filter species if requested
  if (!identical(species, "all") && !is.null(species)) {
    if ("scientificName" %in% names(obs)) {
      obs <- obs %>% dplyr::filter(.data$scientificName %in% species)
    }
  }

  # 4. Create annotation flag
  obs <- obs %>%
    dplyr::mutate(
      is_annotated = if (mode == "any") {
        dplyr::if_any(dplyr::all_of(fields), ~ !is.na(.x) & .x != "")
      } else {
        dplyr::if_all(dplyr::all_of(fields), ~ !is.na(.x) & .x != "")
      }
    )

  # 5. Attach grouping metadata from deployments table
  by_cols <- if (is.null(by) || identical(by, "all")) character(0) else by

  if (length(by_cols) > 0) {
    extra_dep_cols <- setdiff(by_cols, names(obs))
    if (length(extra_dep_cols) > 0) {
      dep_sub <- dep %>% dplyr::select(dplyr::all_of(c("deploymentID", extra_dep_cols))) %>% dplyr::distinct()
      obs <- obs %>% dplyr::left_join(dep_sub, by = "deploymentID")
    }
  }

  # 6. Aggregate observation metrics
  if (length(by_cols) > 0) {
    obs_sum <- obs %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(by_cols))) %>%
      dplyr::summarise(
        n_total_obs     = dplyr::n(),
        n_annotated_obs = sum(.data$is_annotated, na.rm = TRUE),
        pct_annotated   = round(100 * (sum(.data$is_annotated, na.rm = TRUE) / dplyr::n()), 1),
        annotated_start = if (any(.data$is_annotated)) min(.data[[ts_col]][.data$is_annotated], na.rm = TRUE) else NA,
        annotated_end   = if (any(.data$is_annotated)) max(.data[[ts_col]][.data$is_annotated], na.rm = TRUE) else NA,
        .groups = "drop"
      )

    # Merge back to deployment registry to retain deployments with zero observations/annotations
    if (all(by_cols %in% names(dep))) {
      dep_base <- dep %>% dplyr::select(dplyr::all_of(by_cols)) %>% dplyr::distinct()
      res <- dplyr::left_join(dep_base, obs_sum, by = by_cols) %>%
        dplyr::mutate(
          n_total_obs     = dplyr::coalesce(.data$n_total_obs, 0L),
          n_annotated_obs = dplyr::coalesce(.data$n_annotated_obs, 0L),
          pct_annotated   = dplyr::coalesce(.data$pct_annotated, 0)
        )
    } else {
      res <- obs_sum
    }

  } else {
    res <- obs %>%
      dplyr::summarise(
        n_total_obs     = dplyr::n(),
        n_annotated_obs = sum(.data$is_annotated, na.rm = TRUE),
        pct_annotated   = round(100 * (sum(.data$is_annotated, na.rm = TRUE) / dplyr::n()), 1),
        annotated_start = if (any(.data$is_annotated)) min(.data[[ts_col]][.data$is_annotated], na.rm = TRUE) else NA,
        annotated_end   = if (any(.data$is_annotated)) max(.data[[ts_col]][.data$is_annotated], na.rm = TRUE) else NA
      )
  }

  # 7. Calculate annotated period duration in days
  res %>%
    dplyr::mutate(
      annotated_days = dplyr::if_else(
        is.na(.data$annotated_start) | is.na(.data$annotated_end),
        NA_real_,
        round(as.numeric(difftime(.data$annotated_end, .data$annotated_start, units = "days")), 1)
      )
    )
}

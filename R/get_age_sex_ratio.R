#' get_age_sex_ratio
#'
#' @author Martijn Bollen
#'
#' @description Calculate Demographic Ratios Across Flexible Aggregation Levels
#' Wrapper around `camtraptor` functions to calculate age/sex demographic
#' counts, group-level RAIs, and ratios grouped by deployment, location, metadata
#' variables, or across the entire dataset.
#'
#' @param package Camera trap data package object (as returned by `read_camtrap_dp()`).
#' @param species Scientific or vernacular species name(s) to filter on. Defaults to `"all"`.
#' @param num_life_stage Vector of life stage(s) for the numerator group. `NULL` applies no filter.
#' @param num_sex Vector of sex class(es) for the numerator group. `NULL` applies no filter.
#' @param den_life_stage Vector of life stage(s) for the denominator group. `NULL` applies no filter.
#' @param den_sex Vector of sex class(es) for the denominator group. `NULL` applies no filter.
#' @param by Character vector of column name(s) in `package$data$deployments` to group by
#'   (e.g., `"deploymentID"`, `"locationName"`). Use `"all"` or `NULL` for whole dataset totals. Defaults to `"deploymentID"`.
#' @param ... Additional arguments passed to `camtraptor` functions.
#'
#' @returns A tibble with numerator/denominator counts (`n_*`), group effort (days),
#'   group relative abundance indices (`rai_*`), and demographic ratios (`ratio_obs`, `ratio_ind`)
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
#' drg$data$deployments <- drg$data$deployments %>%
#' mutate(year = year(start), month = month(start),
#'        year_month = floor_date(start, unit = "month")) %>%
#' filter(month %in% 4:8, year %in% 2023:2025)
#'
#' # Fawn to Doe ratio per location
#' location_fawn_doe_ratios <- get_age_sex_ratio(
#'  package = drg,
#'  species = "Capreolus capreolus",
#'  num_life_stage = "juvenile",
#'  den_life_stage = c("adult", "subadult"), den_sex = "female",
#'  by = "locationName"
#')
#'
#' # Fawn to Doe ratio per year
#' yearly_fawn_doe_ratios <- get_age_sex_ratio(
#'  package = drg,
#'  species = c("Capreolus capreolus", "Dama dama"),
#'  num_life_stage = "juvenile",
#'  den_life_stage = "adult", den_sex = "female",
#'  by = "year" # or by = NULL
#' )
#'
#' # Fawn to doe ratio - overall
#' overall_fawn_doe_ratio <- get_age_sex_ratio(
#'  package = drg,
#'  species = c("Capreolus capreolus", "Dama dama"),
#'  num_life_stage = "juvenile",
#'  den_life_stage = "adult", den_sex = "female",
#'  by = "all"
#' )
#' }
#'

get_age_sex_ratio <- function(
    package,
    species = "all",
    num_life_stage = "juvenile",
    num_sex = NULL,
    den_life_stage = "adult",
    den_sex = "female",
    by = "deploymentID",
    ...) {
  # 1. Parse and validate aggregation level (`by`)
  by_cols <- if (is.null(by) || identical(by, "all")) character(0) else by

  if (length(by_cols) > 0) {
    missing_cols <- setdiff(by_cols, names(package$data$deployments))
    if (length(missing_cols) > 0) {
      stop(sprintf("Column(s) %s not found in package$data$deployments.",
                   paste(sQuote(missing_cols), collapse = ", ")))
    }
  }

  # 2. Extract deployment metadata and effort
  dep_meta <- package$data$deployments %>%
    dplyr::select(dplyr::all_of(c("deploymentID", setdiff(by_cols, "deploymentID"))))

  dep_effort <- camtraptor::get_effort(package, ...) %>%
    dplyr::left_join(dep_meta, by = "deploymentID")

  # 3. Fetch raw counts for numerator and denominator
  n_obs_num <- camtraptor::get_n_obs(package, species = species, life_stage = num_life_stage, sex = num_sex, ...)
  n_ind_num <- camtraptor::get_n_individuals(package, species = species, life_stage = num_life_stage, sex = num_sex, ...)

  n_obs_den <- camtraptor::get_n_obs(package, species = species, life_stage = den_life_stage, sex = den_sex, ...)
  n_ind_den <- camtraptor::get_n_individuals(package, species = species, life_stage = den_life_stage, sex = den_sex, ...)

  # Join counts and metadata
  num_dep <- n_obs_num %>%
    dplyr::rename(n_obs = "n") %>%
    dplyr::full_join(dplyr::rename(n_ind_num, n_ind = "n"), by = intersect(names(.), names(n_ind_num))) %>%
    dplyr::left_join(dep_meta, by = "deploymentID")

  den_dep <- n_obs_den %>%
    dplyr::rename(n_obs = "n") %>%
    dplyr::full_join(dplyr::rename(n_ind_den, n_ind = "n"), by = intersect(names(.), names(n_ind_den))) %>%
    dplyr::left_join(dep_meta, by = "deploymentID")

  # 4. Group & Aggregate Effort and Demographic Counts
  group_keys <- c(by_cols, intersect("scientificName", names(num_dep)))

  if (length(by_cols) > 0) {
    effort_grouped <- dep_effort %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(by_cols))) %>%
      dplyr::summarise(effort = sum(.data$effort, na.rm = TRUE), .groups = "drop")
  } else {
    effort_grouped <- dplyr::tibble(effort = sum(dep_effort$effort, na.rm = TRUE))
  }

  if (length(group_keys) > 0) {
    num_grouped <- num_dep %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(group_keys))) %>%
      dplyr::summarise(
        n_obs_num = sum(.data$n_obs, na.rm = TRUE),
        n_ind_num = sum(.data$n_ind, na.rm = TRUE),
        .groups = "drop"
      )
    den_grouped <- den_dep %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(group_keys))) %>%
      dplyr::summarise(
        n_obs_den = sum(.data$n_obs, na.rm = TRUE),
        n_ind_den = sum(.data$n_ind, na.rm = TRUE),
        .groups = "drop"
      )
    res <- dplyr::full_join(num_grouped, den_grouped, by = group_keys)
  } else {
    res <- dplyr::tibble(
      n_obs_num = sum(num_dep$n_obs, na.rm = TRUE),
      n_ind_num = sum(num_dep$n_ind, na.rm = TRUE),
      n_obs_den = sum(den_dep$n_obs, na.rm = TRUE),
      n_ind_den = sum(den_dep$n_ind, na.rm = TRUE)
    )
  }

  if (length(by_cols) > 0) {
    res <- dplyr::full_join(res, effort_grouped, by = by_cols)
  } else {
    res <- dplyr::mutate(res, effort = effort_grouped$effort[1])
  }

  # 5. Compute Group-Level RAIs and Streamlined Ratios
  res %>%
    dplyr::mutate(
      n_obs_num = dplyr::coalesce(.data$n_obs_num, 0),
      n_ind_num = dplyr::coalesce(.data$n_ind_num, 0),
      n_obs_den = dplyr::coalesce(.data$n_obs_den, 0),
      n_ind_den = dplyr::coalesce(.data$n_ind_den, 0),

      # Group-level RAIs per 100 effort days for absolute density reference
      rai_obs_num = dplyr::if_else(.data$effort == 0, NA_real_, 100 * (.data$n_obs_num / .data$effort)),
      rai_ind_num = dplyr::if_else(.data$effort == 0, NA_real_, 100 * (.data$n_ind_num / .data$effort)),
      rai_obs_den = dplyr::if_else(.data$effort == 0, NA_real_, 100 * (.data$n_obs_den / .data$effort)),
      rai_ind_den = dplyr::if_else(.data$effort == 0, NA_real_, 100 * (.data$n_ind_den / .data$effort)),

      # Simplified ratios (effort cancels out completely)
      ratio_obs   = dplyr::if_else(.data$n_obs_den == 0, NA_real_, .data$n_obs_num / .data$n_obs_den),
      ratio_ind   = dplyr::if_else(.data$n_ind_den == 0, NA_real_, .data$n_ind_num / .data$n_ind_den)
    )
}


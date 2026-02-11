# GitHub Copilot Instructions for fistools

## Repository Overview

This is an R package containing tools and data used for wildlife management and invasive species research in Flanders, Belgium, maintained by the research institute for forest and nature (INBO).

## Package Structure

- **R/**: Source code with functions for wildlife management, spatial analysis, data processing, and OpenStreetMap integration
- **data/**: Package datasets (LazyData enabled with xz compression)
- **data_raw/**: Raw data files used to generate package datasets
- **man/**: Auto-generated documentation files (do not edit manually)
- **preprocessing/**: Scripts for data preprocessing
- **.github/workflows/**: CI/CD workflows for R-CMD-check, test coverage, and pkgdown site building

## R Package Development Standards

### Documentation with roxygen2

All exported functions MUST be documented using roxygen2 comments with the following structure:

```r
#' Function Title
#'
#' @description
#' Detailed description of what the function does
#'
#' @author Author Name
#'
#' @param param_name Description of the parameter
#'
#' @details
#' Additional details about the function's behavior, edge cases, or usage notes
#'
#' @returns Description of the return value
#'
#' @examples
#' \dontrun{
#' # Example usage
#' result <- function_name(param = "value")
#' }
#'
#' @export
```

Key roxygen2 guidelines:
- Use `@author` to credit the function author
- Use `@param` for each function parameter
- Use `@returns` (not `@return`) to describe the output
- Use `@examples` with `\dontrun{}` for examples that require external data or user interaction
- Use `@export` for functions that should be available to package users
- Use `@family` tags to group related functions (e.g., `@family spatial`)
- Use `@details` for important implementation notes or warnings

### Code Style

- Use **snake_case** for function names and variables
- Use **descriptive names** that clearly indicate purpose
- Functions should have clear, single responsibilities
- Include input validation at the start of functions using `assertthat` or base R checks
- Use the pipe operator `%>%` from `magrittr` for data transformation chains
- Prefer `dplyr` verbs for data manipulation

### Dependencies

- All dependencies must be listed in the DESCRIPTION file under `Imports:` or `Suggests:`
- Use `::` notation when calling functions from other packages to be explicit
- Core dependencies include: dplyr, sf, stringr, httr, googledrive, osmdata
- Spatial operations use `sf` package (not `sp` unless necessary for legacy compatibility)

### Testing and Validation

- Run `R CMD check` before submitting changes (automated via `.github/workflows/R-CMD-check.yaml`)
- Ensure test coverage is maintained (automated via `.github/workflows/test-coverage.yaml`)
- Test on multiple R versions (release, devel, oldrel-1) and OS platforms (Ubuntu, Windows, macOS)

### Version Management

- Package version follows semantic versioning (currently 1.2.27)
- Version is incremented automatically via `.github/workflows/increment_version.yaml`
- Do not manually update the version number in DESCRIPTION unless explicitly required

### Data Files

- Package data should be documented in R/ directory with a corresponding .R file
- Use LazyData compression (xz) for efficiency
- Document datasets using roxygen2 with `@format` and `@source` tags
- Example data files should use `drg_example` naming pattern

### Spatial Data Conventions

- Use CRS EPSG:31370 (Belgian Lambert 72) for Belgian spatial data
- Use CRS EPSG:4326 (WGS84) for coordinate data from GPS or web services
- Always validate and transform CRS when combining spatial datasets
- Functions should accept `sf` objects as input when working with spatial data
- Return spatial data as `sf` objects with appropriate CRS set

### Naming Conventions for Wildlife Management

- Species names in Dutch: "REE", "WILD ZWIJN", "DAMHERT", etc.
- Label types: "REEKITS", "REEGEIT", "REEBOK"
- Use consistent terminology from the FIS team's domain vocabulary

### Error Handling

- Provide informative error messages in Dutch or English
- Use `stop()` for fatal errors with clear messages
- Use `warning()` for non-fatal issues
- Use `message()` for progress updates in long-running functions
- Consider using `progress` package for progress bars in iterative operations

### External Services

- Google Drive integration uses `googledrive` package
- AWS S3 integration uses `aws.s3` package
- OpenStreetMap data fetching uses `osmdata` package
- Database connections use `DBI` package

### Building and Publishing

- Package documentation site is built with `pkgdown` and published to GitHub Pages
- The site is available at https://inbo.github.io/fistools/
- Documentation is automatically rebuilt on push to main branch
- Reference documentation is auto-generated from roxygen2 comments

### File Formatting

- Use UTF-8 encoding for all text files
- Line endings should be normalized (LF on Unix/Linux, CRLF on Windows)
- Use the `normalize_line_endings()` function if needed

### Best Practices

1. **Minimal changes**: Only modify what's necessary to fix the issue or add the feature
2. **Backward compatibility**: Avoid breaking changes to existing function interfaces
3. **Documentation first**: Update documentation before or alongside code changes
4. **Examples matter**: Provide working examples that users can understand and adapt
5. **Spatial awareness**: Always consider CRS and units when working with spatial data
6. **Performance**: Use vectorized operations and avoid loops when possible in R
7. **Reusability**: Create general-purpose functions that can be used in multiple contexts

## Common Tasks

### Adding a new function
1. Create a new .R file in R/ directory
2. Add roxygen2 documentation header
3. Implement the function with proper error handling
4. Add examples in `\dontrun{}` blocks
5. Run `devtools::document()` to generate .Rd file
6. Test with `devtools::check()`

### Adding a new dataset
1. Create raw data in data_raw/ directory
2. Create a script in data_raw/ to process the data
3. Save with `usethis::use_data(dataset_name, compress = "xz")`
4. Document in R/ with roxygen2 (`@format`, `@source`)

### Updating dependencies
1. Add to DESCRIPTION Imports or Suggests
2. Update NAMESPACE if needed
3. Run `devtools::check()` to ensure compatibility

## Contact and Contribution

This package is maintained by the FIS team at INBO. Follow the Contributor Covenant Code of Conduct when contributing.

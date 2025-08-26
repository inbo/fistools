#' Normalize line endings according to `.gitattributes`
#'
#' @author Soria Delva
#'
#' @description
#' This function adjusts the line endings (LF or CRLF) and enforces file attribute handling of all files in the current directory and subdirectories, according to the settings specified in the `.gitattributes` file.
#' This creates consistency between the files on the online repository and those in the local environment.
#'
#'
#' @details
#' The function
#' - Checks whether a `.gitattributes` file is available.
#' - Normalizes all files using Git.
#' - Checks if files were altered and asks users if these changes can be committed.
#' - Provides status updates, so users can follow the progress of the function.
#'
#'
#' @return
#' Files in the directory will be altered where relevant. Users get the option to commit these changes.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Run normalization and (optionally) commit changes
#' normalize_line_endings()
#' }

normalize_line_endings <- function() {

  # Step 0: Check if .gitattributes exists
  assertthat::assert_that(file.exists(".gitattributes"),
                          msg = paste( ".gitattributes file is missing in the root of the repository. Please add a .gitattributes file.")
  )

  # Step 1: Normalize all files according to .gitattributes
  system("git add --renormalize .")

  # Step 2: Check if there’s anything to commit
  status <- system("git status --porcelain", intern = TRUE)
  if (length(status) == 0) {
    cat("No changes to commit. Everything is already normalized.\n")
    return()
  }

  # Step 3: Ask user if they want to commit
  answer <- utils::askYesNo("Do you want to commit the changes?")
  if (isFALSE(answer) || is.na(answer)) {
    cat("Files are not committed yet.\n")
    return()
  }

  # Step 4: Commit the changes
  cat("Committing changes...\n")
  commit_status <- system( paste("git commit -m", shQuote("Normalize all files according to the .gitattributes file")))

  if (commit_status == 0) {
    cat("Commit successful!\n")
  } else {
    cat("Commit failed. Git status:\n")
    cat(system("git status", intern = TRUE), sep = "\n")
  }
}

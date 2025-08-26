#' Normalize line endings according to `.gitattributes`
#'
#' @author Soria Delva
#'
#' @description
#' Deze functie herwerkt line endings (LF of CRLF) van alle bestanden in de huidige directory
#' en subdirectories, op basis van de regels in het `.gitattributes`-bestand. Dit zorgt voor consistentie tussen
#' de online repository en de bestanden op de lokale computer
#'
#' @details
#' De functie
#' - Controleert eerst of er een `.gitattributes`-bestand aanwezig is.
#' - Voert vervolgens de renormalisatie van alle bestanden uit met Git.
#' - Controleert of bestanden aangepast zijn en vraagt of deze mogen gecommit worden.
#' - Geeft statusmeldingen weer over de voortgang en het resultaat.
#'
#'
#' @return
#' Bestanden worden, indien relevant, aangepast, en de gebruiker krijgt de optie om deze veranderingen meteen te committen.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Run renormalization and (optionally) commit changes
#' normalize_line_endings()
#' }

normalize_line_endings <- function() {

  # Step 0: Check if .gitattributes exists
  # Test that taxon_key is provided
  assertthat::assert_that(file.exists(".gitattributes"),
                          msg = paste( ".gitattributes file is missing in the root of the repository. Please add a .gitattributes file.")
  )

  # Step 1: Renormalize all files according to .gitattributes
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
    cat("Commit failed. Check Git status for details.\n")
  }
}

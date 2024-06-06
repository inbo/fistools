---
name: Nieuwe functie aanmaken
about: Checklist voor het aanmaken van een nieuwe functie
title: '[NEW function]'
labels: New, Function
assignees: ''

---
## Voorstel functie naam "<functienaam>"

## Functionality
- [ ] list of the expected functionality

## Checklist
- [ ] maak een nieuw R-bestand 
- [ ] sla het R bestand op onder `./R` met filenaam is gelijk aan functienaam
- [ ] voorzie een functie titel met `#'` op regel 1 van je script
- [ ] voorzie een auteur met `#' @author`
- [ ] voorzie een beschrijving met `#' @description`
- [ ] voorzie uitleg over de input parameter(s) met `#' @param name`
- [ ] voorzie uitleg over de output van de functie met `#' @returns`
- [ ] voorzie minstens 1 voorbeeld van het gebruik van de functie dmv `#' @examples`
- [ ] voorzie de export - tag dmv `#' @export` ([#14](https://github.com/inbo/fistools/issues/14))
- [ ] voer `usethis::use_package("packagename", min_version = TRUE)` uit in de console voor iedere package die je gebruikt. 
- [ ] voer `roxygen2::roxygenise()` uit in de console
- [ ] voer `devtools::check()` uit in de console
- [ ] los eventuele errors, warnings en notes<sup>1</sup> op
- [ ] increment versie dmv `usethis::use_version(which = "minor")`<sup>2</sup>
- [ ] maak een pull request met @soriadelva of @SanderDevisscher en eventueel andere relevante gebruikers als reviewer.

*<sup>1</sup>in de mate van het mogelijke*

*<sup>2</sup>als je meer dan 5 functies en/of datasets in één pull request veranderd hebt gebruik: `usethis::use_version(which = "major")`*

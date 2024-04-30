---
name: Nieuwe dataset
about: Checklist voor het uploaden van een nieuwe dataset
title: '[NEW dataset]'
labels: New, Data
assignees: 

---

## Voorstel dataset naam:

## checklist:
- [ ] plaats de ruwe data in `./data_raw/`
- [ ] schrijf (of kopieer) script, in `./src/` om de ruwe data om te zetten in een `.rda` of `.rds` bestand
- [ ] creëer het data bestand en schrijf het weg met `saveRDS()` of `save()`<sup>1</sup>
- [ ] voorzie een auteur met `#' @author`
- [ ] voorzie een beschrijving met `#' @description`
- [ ] voer `roxygen2::roxygenise()` uit in de console
- [ ] voer `devtools::check()` uit in de console
- [ ] los eventuele errors, warnings en notes<sup>2</sup> op
- [ ] maak een pull request met @soriadelva of @SanderDevisscher en eventueel andere relevante gebruikers als reviewer.

*<sup>1</sup>`saveRDS()` kan gebruikt worden om een enkel bestand op te slaan terwijl `save()` het opslaan van meerdere bestanden in 1 .rda/.rds bestand toelaat.*

*<sup>2</sup>in de mate van het mogelijke.*

---
name: Bug report
about: Create a report to help us improve
title: "[BUG]"
labels: bug
assignees: ''

---

**Welke functie/dataset**

**Beschrijf de bug**
Beschrijf de bug kort en krachtig

**Stappen om de bug te reproduceren:**
Voeg hier een stuk code in om de fout te reporduceren

**Verwachte uikomst**
Een korte en krachtige beschrijving van de gewenste uitkomst

**Screenshots**
Indien van toepassing

**Extra context**
*sessionInfo*
```
```
*package - versie*
resultaat van `utils::packageVersion("fistools")`

**Checklist**
- [ ] corrigeer bug
- [ ] voer `devtools::check()` uit in de console
- [ ] los eventuele errors, warnings en notes<sup>1</sup> op
- [ ] increment versie dmv `usethis::use_version(which = "patch")`<sup>2</sup>
- [ ] maak een pull request met @soriadelva of @SanderDevisscher en eventueel andere relevante gebruikers als reviewer.

*<sup>1</sup>in de mate van het mogelijke*

*<sup>2</sup>Indien het nodig is om de functie grotendeels te herzien (bvb tgv een depricated package) om de bug op te lossen of als er meerdere functies en/of datasets bij betrokken zijn, gebruik: `usethis::use_version(which = "minor")`. *

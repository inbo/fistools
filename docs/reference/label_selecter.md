# label_selecter

Deze functie onderzoekt of de labels bestaan in de datasets
AfschotMelding (AM), ToegekendeLabels (TL), Toekenningen_Cleaned
(TL_Cleaned), Dieren_met_onderkaakgegevens (DMOG),
Dieren_met_onderkaakgegevens_Georef (DMOGG).

## Usage

``` r
label_selecter(
  label,
  update = FALSE,
  label_type,
  jaar,
  soort,
  bo_dir = "~/Github/backoffice-wild-analyse/",
  debug = FALSE
)
```

## Arguments

- label:

  een character (lijst) met labelnummer(s) die dienen onderzocht te
  worden. Dit kan in 3 vormen (volgnummer, met streepjes of zonder
  streepjes) of een combinatie van deze vormen aangeleverd worden

- update:

  een boolean die aangeeft of ook de nog niet wegeschreven dwh -
  bestanden moeten worden gecontroleerd.

- label_type:

  een een character (lijst) met labeltypes die dienen onderzocht te
  worden.

- jaar:

  een numerieke (lijst) van jaren die dienen onderzocht te worden.

- soort:

  een character van de soort die onderzocht dient te worden.

- bo_dir:

  een character met de directory waar de backoffice-wild-analyse
  repository staat.

- debug:

  een boolean die aangeeft of de debug modus moet worden aangezet.

## Value

Een dataframe met de volgende kolommen:

- INPUTLABEL: de input label

- LABELTYPE: de labeltype(s) die onderzocht worden

- JAAR: het jaar waarin de labels onderzocht worden

- AM_OLD: een boolean die aangeeft of de label(s) in AfschotMelding
  voorkomen **voor** de update van DWH_Connect

- AM_OLD_LABEL: de label(s) die in AfschotMelding voorkomen **voor** de
  update van DWH_Connect

- TL_OLD: een boolean die aangeeft of de label(s) in ToegekendeLabels
  voorkomen **voor** de update van DWH_Connect

- TL_OLD_LABEL: de label(s) die in ToegekendeLabels voorkomen **voor**
  de update van DWH_Connect

- TL_CLEANED: een boolean die aangeeft of de label(s) in
  Toekenningen_Cleaned voorkomen

- TL_CLEANED_LABEL: de label(s) die in Toekenningen_Cleaned voorkomen

- DMOG: een boolean die aangeeft of de label(s) in
  Dieren_met_onderkaakgegevens voorkomen

- DMOG_LABEL: de label(s) die in Dieren_met_onderkaakgegevens voorkomen

- DMOG_GEO: een boolean die aangeeft of de label(s) in
  Dieren_met_onderkaakgegevens_Georef voorkomen

- DMOG_GEO_LABEL: de label(s) die in Dieren_met_onderkaakgegevens_Georef
  voorkomen *Als `update = TRUE` worden de volgende kolommen
  toegevoegd:*

- AM_NEW: een boolean die aangeeft of de label(s) in AfschotMelding
  voorkomen **na** de update van DWH_Connect

- AM_NEW_LABEL: de label(s) die in AfschotMelding voorkomen **na** de
  update van DWH_Connect

- TL_NEW: een boolean die aangeeft of de label(s) in ToegekendeLabels
  voorkomen **na** de update van DWH_Connect

- TL_NEW_LABEL: de label(s) die in ToegekendeLabels voorkomen **na** de
  update van DWH_Connect

## Details

De parameter `label_type`, `jaar` en `soort` zijn enkel relevant als één
van de labels de vorm 'volgnummer' heeft. Wanneer deze parameter niet
gespecifieerd worden zal een default waarde voor het jaar (2013 t.e.m.
max(AfschotMelding\$Jaartal)) en label_type (c("REEGEIT", "REEKITS",
"REEBOK", "WILD ZWIJN", "DAMHERT", "EDELHERT")) gebruikt worden. Wanneer
soort gespecifieerd is zal de lijst van labeltypes beperkt worden tot
deze die op de soort betrekking hebben. Voor ree bvb wordt dit reekits,
reegeit en reebok.

De parameters `label`, `label_type`, `jaar` en `soort` kunnen als lijst
aangeleverd worden.

De parameters `label_type`, `jaar` en `soort` zijn niet
hoofdlettergevoelig.

`bo_dir` is de directory waar de backoffice-wild-analyse repository
staat. De functie checkt namelijk of de labels voorkomen in de lokale
versie van de backoffice-wild-analyse repository. Hiervoor is het
belangrijk dat de backoffice-wild-analyse repository lokaal aanwezig is
en de laatste versie gepulled is.

`update` is een boolean die aangeeft of de nog niet wegeschreven dwh -
bestanden moeten worden gecontroleerd. om dit te kunnen lopen is een
verbinding met de DWH nodig. Dit is enkel mogelijk als je met de VPN van
het INBO verbonden bent. Of als je aanwezig bent op een vestiging van de
Vlaamse Overheid (VAC).

## See also

Other other: [`retry_function()`](retry_function.md)

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
#enkel label:
 label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
 output <- label_selecter(label)

#label & labeltype
 label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
 labeltype <- c("reegeit", "REEBOK")
 output <- label_selecter(label, label_type = labeltype)

#label & jaar & soort
 label <- c(1234, "ANB2016REEGEIT001234", "ANB-2016-REEGEIT001234")
 soort <- "ree"
 jaar <- c(2018, 2019)
 output <- label_selecter(label, jaar = jaar , soort = soort)
} # }
```

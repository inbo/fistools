# connect to bucket

Deze functie refresht de sessiontoken nodig om contact te leggen met
inbo AWS S3 buckets. De functie maakt een profiel aan met een
sessiontoken die één uur geldig blijft. Deze heb je nodig om verbinding
te maken met de s3 buckets.

## Usage

``` r
connect_to_bucket(
  bucket_name,
  bucket_type = "inbo-uat",
  role = "inbo-developers-fis-role"
)
```

## Arguments

- bucket_name:

  String met de naam van de bucket.

- bucket_type:

  String met het type bucket. ofwel "inbo-uat" of "inbo-prod"

- role:

  String met de rechtengroep waartoe je behoort. Default is:
  "inbo-developers-fis-role"

## Value

Dataframe met een lijst van bestanden op de bucket met relevante info.

## Voorbereiding:

De volgende programma's moeten worden geïnstalleerd vooraleer je deze
functie kunt gebruiken: -*AWS CLI* moet worden geïnstalleerd als dat nog
niet gebeurd is. Hiervoor heb je admin rechten nodig, een *ict helpdesk
call* is dus aan de orde. Na de installatie moeten je *AWS credentials*
eenmalig aangemaakt worden. Voer hiervoor `aws configure` uit in
*windows powershell*. De credentials kan je bekomen bij Jens Polspoel.
-*devops-toolkit* moet lokaal worden geïnstalleerd dit doe je door
*https://github.com/inbo/devops-toolkit* te clonen dmv *github dekstop*.
Vervolgens kopiëer je *aws-cli-mfa-login.py* & *common.py* naar de Home
Directory van Windows. Default is dat
*C:/Users/%voornaam_achternaam%/bin*. -*Python* moet worden
geïnstalleerd als dat nog niet gebeurd is. Dit kan rechtstreeks in *R*
met onderstaande code: `install.packages("reticulate")`
`reticulate::install_python()` `system('pip install boto3')`

## Author

Sander Devisscher

Jens Polspoel

## Examples

``` r
 if (FALSE) { # \dontrun{
# Alleen de bucket_name is uiterst noodzakelijk:
# Connect to the UAT bucket of exotenportaal:
connect_to_bucket("inbo-exotenportaal-uat-eu-west-1-default")
# Connect to the UAT bucket of faunabeheer:
connect_to_bucket("inbo-faunabeheer-uat-eu-west-1-default")
} # }
```

# Start localhost connection

After the upgrade to a newer version of postgresql connecting to the
autopsiedb no longer occurs via the bastion but via a modified
localhost. This function allows connection to newer postgresql
databases. But its mainly focused on the autopsiedb.

## Usage

``` r
start_localhost_connection(
  db = "2",
  envir = "inbo-prod",
  role = "inbo-autopsies-rds-connect-role",
  devops_toolkit_path = "../../../bin/devops-toolkit-windows-amd64.exe",
  port = 5555
)
```

## Arguments

- db:

  the number corresponding to the db you want to access, default is 2

- envir:

  the environment in which the db resides, default is "inbo-prod"

- role:

  your role used to connect to the db

- devops_toolkit_path:

  the path, ending with `.exe`, where the devops-toolkit was installed.

- port:

  connection port of the localhost instance, default = 5555

## Voorbereiding:

De volgende programma's moeten worden geinstalleerd vooraleer je deze
functie kunt gebruiken: -*AWS CLI* moet worden geinstalleerd als dat nog
niet gebeurd is. Hiervoor heb je admin rechten nodig, een *ict helpdesk
call* is dus aan de orde. Na de installatie moeten je *AWS credentials*
eenmalig aangemaakt worden. Voer hiervoor `aws configure` uit in
*windows powershell*. De credentials kan je bekomen bij Jens Polspoel.
-*devops-toolkit* moet lokaal worden geïnstalleerd dit doe je door de
laatste versie van *https://github.com/inbo/devops-toolkit/releases/tag/
(\>= v1.0.3)* te downloaden. De functie werkt enkel met de windows
versie van devops-toolkit

Vervolgens kopieer je *aws-cli-mfa-login* naar de Home Directory van
Windows. Default is dat *C:/Users/%voornaam_achternaam%/bin*. Hernoem
het bestand vervolgens naar *aws-cli-mfa-login.exe*.

## See also

[`end_localhost_connection()`](end_localhost_connection.md)

## Author

Jens Polspoel

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
 start_localhost_connection()

 con <- odbc::dbConnect(odbc::odbc(),
                      Driver = "PostgreSQL Unicode(x64)",
                      database = "autopsies",
                      server = "127.0.0.1",
                      port = 5555,
                      uid = Sys.getenv("autopsies_user"),
                      pwd = paste0("{", Sys.getenv("autopsies_pwd"), "}"),
                      sslmode = "require")

 identificatie <- DBI::dbGetQuery(con,
                                  "SELECT * FROM public.identificatie")

end_localhost_connection()
} # }
```

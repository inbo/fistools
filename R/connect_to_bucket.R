#' connect to bucket
#'
#' @author Sander Devisscher
#' @author Jens Polspoel
#'
#' @description
#' Deze functie refresht de sessiontoken nodig om contact te leggen met inbo
#' AWS S3 buckets. De functie maakt een profiel aan met een sessiontoken die één
#' uur geldig blijft. Deze heb je nodig om verbinding te maken met de s3 buckets.
#'
#' @param bucket_name String met de naam van de bucket.
#' @param bucket_type String met het type bucket. ofwel "inbo-uat" of "inbo-prod"
#' @param role String met de rechtengroep waartoe je behoort. Default is:
#' "inbo-developers-fis-role"
#'
#' @details
#' # Voorbereiding:
#' De volgende programma's moeten worden geïnstalleerd vooraleer je deze functie
#' kunt gebruiken:
#' -*AWS CLI* moet worden geïnstalleerd als dat nog niet gebeurd is. Hiervoor
#' heb je admin rechten nodig, een _ict helpdesk call_ is dus aan de orde.
#' Na de installatie moeten je *AWS credentials* eenmalig aangemaakt worden.
#' Voer hiervoor `aws configure` uit in _windows powershell_. De credentials
#' kan je bekomen bij Jens Polspoel.
#' -*devops-toolkit* moet lokaal worden geïnstalleerd dit doe je door
#' *https://github.com/inbo/devops-toolkit* te clonen dmv _github dekstop_.
#' Vervolgens kopiëer je *aws-cli-mfa-login.py* & *common.py* naar de Home
#' Directory van Windows. Default is dat *C:/Users/%voornaam_achternaam%/bin*.
#' -*Python* moet worden geïnstalleerd als dat nog niet gebeurd is. Dit kan
#' rechtstreeks in _R_ met onderstaande code:
#' `install.packages("reticulate")`
#' `reticulate::install_python()`
#' `system('pip install boto3')`
#'
#' @return Dataframe met een lijst van bestanden op de bucket met relevante info.
#'
#' @export
#'
#' @examples
#'  \dontrun{
#' # Alleen de bucket_name is uiterst noodzakelijk:
#' # Connect to the UAT bucket of exotenportaal:
#' connect_to_bucket("inbo-exotenportaal-uat-eu-west-1-default")
#' # Connect to the UAT bucket of faunabeheer:
#' connect_to_bucket("inbo-faunabeheer-uat-eu-west-1-default")
#' }

connect_to_bucket <- function(bucket_name,
                              bucket_type = "inbo-uat",
                              role = "inbo-developers-fis-role"){

  # Refresh session token ####
  # Onderstaande code maakt een profiel aan met een sessiontoken die één uur
  # geldig blijft. Deze heb je nodig om verbinding te maken met de s3 buckets.
  if(file.exists("../../../bin/aws-cli-mfa-login")){
    system(paste0('python ../../../bin/devops-toolkit -u ',
                  Sys.getenv("USERNAME"),
                  ' -a ', bucket_type, ' -r ', role))
  }else{
    stop("Installeer aws-cli-mfa-login van inbo/devops-tools in je windows home
         directory, zie details")
  }

  # Set AWS profile name ####
  aws_profile <- paste0(bucket_type, "-",
                        strsplit(Sys.getenv("USERNAME"), split = "-"))
  aws_profile <- gsub(pattern = "_", replacement = "-", x = aws_profile)

  Sys.setenv("AWS_PROFILE" = aws_profile)

  # Test connection ####
  filelist <- aws.s3::get_bucket_df(bucket = bucket_name,
                                    region = "eu-west-1")

  return(filelist)
}

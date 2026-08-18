#' Start localhost connection
#'
#' After the upgrade to a newer version of postgresql connecting to the
#' autopsiedb no longer occurs via the bastion but via a modified localhost.
#' This function allows connection to newer postgresql databases. But its mainly
#' focused on the autopsiedb.
#'
#' @param db the number corresponding to the db you want to access, default is 2
#' @param envir the environment in which the db resides, default is "inbo-prod"
#' @param role your role used to connect to the db
#' @param devops_toolkit_path the path, ending with `.exe`, where the devops-toolkit
#' was installed.
#' @param port connection port of the localhost instance, default = 5555
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
#' -*devops-toolkit* moet lokaal worden geïnstalleerd dit doe je door de laatste
#' versie van *https://github.com/inbo/devops-toolkit/releases/tag/ (>= v1.0.3)*
#' te downloaden. De functie werkt enkel met de windows versie van devops-toolkit
#'
#' Vervolgens kopiëer je *aws-cli-mfa-login* naar de Home
#' Directory van Windows. Default is dat *C:/Users/%voornaam_achternaam%/bin*.
#' Hernoem het bestand vervolgens naar *aws-cli-mfa-login.exe*.
#'
#' @seealso [end_localhost_connection()]
#'
#' @export
#' @author Jens Polspoel
#' @author Sander Devisscher
#'
#' @examples
#' \dontrun{
#'  start_localhost_connection()
#'
#'  con <- odbc::dbConnect(odbc::odbc(),
#'                       Driver = "PostgreSQL Unicode(x64)",
#'                       database = "autopsies",
#'                       server = "127.0.0.1",
#'                       port = 5556,
#'                       uid = "etl_role",
#'                       pwd = paste0("{", pwd_raw, "}"),
#'                       sslmode = "require")
#'
#' end_localhost_connection()
#' }
#'

start_localhost_connection <- function(db = "2",
                                       envir = "inbo-prod",
                                       role = "inbo-autopsies-rds-connect-role",
                                       devops_toolkit_path = "../../../bin/devops-toolkit-windows-amd64.exe",
                                       port = 5555){

  devops_toolkit_path <- normalizePath(devops_toolkit_path)

  # Test prep ####
  if(file.exists(devops_toolkit_path)){
    cat("The devops-toolkit is installed!")
  }else{
    stop(paste0("The devops-toolkit is not installed at ", devops_toolkit_path,
                " \n points to the wrong file. Try reïnstalling the devops-toolkit, or changing the devops_toolkit_path variable"))
  }

  # create sessiontoken ####
  ## MFA ####
  mfa_code <- svDialogs::dlg_input("Enter MFA Code: ")$res

  ## CMD ####
  cmd <- paste0(devops_toolkit_path, ' aws-mfa -u ',
                Sys.getenv("USERNAME"),
                ' -a ', envir, ' -r ', role)
  ## execute ####
  system(
    command = cmd,
    input = mfa_code,
    ignore.stdout = FALSE,
    ignore.stderr = FALSE,
    wait = TRUE
  )

  ## store profile ####
  aws_profile <- paste0(envir, "-",
                        strsplit(Sys.getenv("USERNAME"), split = "-"))
  aws_profile <- gsub(pattern = "_", replacement = "-", x = aws_profile)

  Sys.setenv("AWS_DEFAULT_PROFILE" = aws_profile)

  # Connect to the autopsiedb ####
  ## DB checks ####
  ### is character? ####
  if(!is.character(db)){
    db <- as.character(db)
  }

  ### is provided ####
  if(is.null(db) | is.na(db)){
    cmd3 <- paste0(devops_toolkit_path,
                   ' rds-list -p ', Sys.getenv("AWS_DEFAULT_PROFILE"))

    db <- svDialogs::dlg_input(paste0("No db provided use the number of one
                                            of these: ", system(
                                              command = cmd3,
                                              intern = FALSE,
                                              ignore.stdout = FALSE,
                                              ignore.stderr = FALSE,
                                              wait = TRUE
                                            )))$res
  }

  ## Connection ####
  cmd2 <- paste0(devops_toolkit_path,
                 ' rds-connect -l ', port, ' -p ', Sys.getenv("AWS_DEFAULT_PROFILE"))

  system(
    command = cmd2,
    input = db,
    ignore.stdout = FALSE,
    ignore.stderr = FALSE,
    wait = FALSE
  )
}

#' Close localhost connection
#'
#' A local host connection will remain open unless closed therefor you should
#' use this function to close it. This function uses `get_active_localhost`
#' under the hood to collect a list of active localhost connections on a given
#' port.
#'
#' @param port connection port of the localhost instance, default = 5555
#'
#' @seealso [start_localhost_connection()]
#'
#' @export
#' @author Jens Polspoel
#' @author Sander Devisscher

end_localhost_connection <- function(port = 5555){

}

get_active_localhost <- function(port = 5555){

  cmd <- paste0('powershell -Command "Get-Process -Id (Get-NetTCPConnection -LocalPort ', port, ').OwningProcess"')

  # get a list of active localhost instances
  active <- system(command = cmd, intern = TRUE)

  # 2. Clean the output
  # Remove completely empty lines or lines with only whitespace
  clean_output <- active[trimws(active) != ""]

  # Remove the separator line containing dashes (-------)
  clean_output <- clean_output[!grepl("-------", clean_output)]

  # 3. Read into a dataframe
  # text = clean_output reads directly from the character vector
  if(nchar(clean_output[1]) == 119){
    df <- read.table(text = clean_output, header = TRUE, stringsAsFactors = FALSE)
    return(df)
  }else{
    warning("No active localhost instances found")
    return(NULL)
  }
}


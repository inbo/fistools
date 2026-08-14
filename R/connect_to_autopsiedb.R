#' Connect to autopsiedb
#'
#' After the upgrade to a newer version of postgresql connecting to the
#' autopsiedb no longer occurs via the bastion but via a modified localhost.
#'
#' @param name description


connect_to_autopsiedb <- function(table,
                                  db = "2",
                                  connectie_type = "inbo-prod",
                                  role = "inbo-autopsies-rds-connect-role",
                                  devops_toolkit_path = "../../../bin/devops-toolkit-windows-amd64.exe"){

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
                ' -a ', connectie_type, ' -r ', role)
  ## execute ####
  system(
    command = cmd,
    input = mfa_code,
    ignore.stdout = FALSE,
    ignore.stderr = FALSE,
    wait = TRUE
  )

  ## store profile ####
  aws_profile <- paste0(connectie_type, "-",
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
                   ' rds-list -p ', aws_profile)

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
                 ' rds-connect -l 5555 -p ', aws_profile)

  system(
    command = cmd2,
    input = db,
    ignore.stdout = FALSE,
    ignore.stderr = FALSE,
    wait = TRUE
  )
}

connect_to_autopsiedb <- function(table,
                                  connectie_type = "inbo-uat",
                                  role = "inbo-developers-fis-role"){

  aws_profile <- paste0(connectie_type, "-",
                        strsplit(Sys.getenv("USERNAME"), split = "-"))
  aws_profile <- gsub(pattern = "_", replacement = "-", x = aws_profile)

  Sys.setenv("AWS_PROFILE" = aws_profile)

  mfa_code <- svDialogs::dlg_input("Enter MFA Code: ")$res
  cmd <- paste0(normalizePath("../../../bin/aws-cli-mfa-login.exe"), ' aws-mfa -u ',
                Sys.getenv("USERNAME"),
                ' -a ', connectie_type, ' -r ', role)

  system(cmd, input = mfa_code, intern = FALSE, ignore.stdout = FALSE, ignore.stderr = FALSE, wait = TRUE)

  cmd <- paste0(normalizePath("../../../bin/rds-discover.exe"), 'devops-toolkit rds-list -p', aws_profile, '')

  system(cmd, intern = FALSE, ignore.stdout = FALSE, ignore.stderr = FALSE, wait = TRUE)
}

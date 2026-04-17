read_dmogg <- function(type = "short",
    email = Sys.getenv("email")){

  type <- tolower(type)

  if(!type %in% c("short", "long")){
    stop(paste("Type is not valid, it should be short or long not ", type))
  }

  if(type == "short"){
    #"1IfezXM56qAJijb-qV9TmzimR8oXPtIcy"
    fistools::download_gdrive_if_missing()
  }

  if(type == "long"){
    #"1VUUkwtZYWdzJRpM725D7-9Z5HOYN2cO-"
    fistools::download_gdrive_if_missing()
  }


}

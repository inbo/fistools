#' Check
#'
#' @author Sander Devisscher
#'
#' @description
#' Helper script to determine existance in environment panel
#'
#' @param x environment object
#'
#' @returns
#' 1 = object exists in enviroment
#' 0 = object doesn't exist in enviroment


check <- function(x){tryCatch(if(is.logical(class(x))) 1 else 1, error=function(e) 0)}

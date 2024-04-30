#' Check
#'
#' @author Sander Devisscher
#'
#' @description
#' Helper script to determine existence in environment panel
#'
#' @param x environment object
#'
#' @returns
#' 1 = object exists in environment
#' 0 = object doesn't exist in environment


check <- function(x){tryCatch(if(!is.logical(class(x))) 1 else 1, error=function(e) 0)}

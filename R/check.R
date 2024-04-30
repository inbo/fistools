#' Check
#'
#' @author Sander Devisscher
#'
#' @description
#' Helper script to determine existence in environment panel
#'
#' @param x environment object
#'
#' @details
#' This doesn't work with functions which will yield a 0 by default.
#'
#'
#' @returns
#' 1 = object exists in environment
#' 0 = object doesn't exist in environment


check <- function(x){tryCatch(if(!is.logical(class(x)) && ifelse(is.function(x), stop(), 0)) 1 else 1, error=function(e) 0)}

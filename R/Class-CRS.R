#' CRS class definition
#'
#' This class is used to store coordinate reference system information for
#' spatial objects. It is a simple class with a single slot, \code{projargs},
#' which is a character vector containing the PROJ.4 string representation of
#' the CRS.
#'
#' @slot projargs A character vector containing the PROJ.4 string representation
#' of the CRS.
#'
#' @name CRS-class
#' @rdname CRS-class
#' @aliases CRS-class
#' @keywords classes
#'
#' @source sp version 2.1-3 by Edzer Pebesma, Roger Bivand
#'
#' @author Copyright (c) 2003-7 by Barry Rowlingson and Roger Bivand
#' @exportClass CRS

setClass("CRS", slots = c(projargs = "character"),
# changed to NA_character_ RSB 2020-02-28
	prototype = list(projargs = NA_character_),
	validity = function(object) {
		if (length(object@projargs) != 1)
			return("projargs must be of length 1")
	}
)

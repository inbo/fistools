#' Retry a function multiple times
#'
#' This function evaluates an expression multiple times until it succeeds or the maximum number of attempts is reached.
#'
#' @param expr An expression to evaluate.
#' @param max_attempts The maximum number of attempts to make.
#' @param sleep_time The time to sleep between attempts, in seconds.
#'
#'
#' @return The result of the expression if successful.
#'
#' @author Sander Devisscher
#' @family other
#'
#' @examples
#' \dontrun{
#' # This example will fail or succeed randomly.
#'
#' some_function <- function() {
#'  if (runif(1) < 0.5) {  # Randomly fail
#'    stop("Failed")
#'    }
#'  return("Success")
#' }
#'
#' retry_function({some_function()}, max_attempts = 5, sleep_time = 1)
#' }
#'
#' @export

retry_function <- function(expr,
                           max_attempts = 3,
                           sleep_time = 0) {
  attempts <- 0
  success <- FALSE
  result <- NULL

  while (attempts < max_attempts && !success) {
    attempts <- attempts + 1
    result <- tryCatch({
      eval(expr)  # Evaluate the expression
    }, error = function(e) {
      message(sprintf("Attempt %d failed: %s", attempts, e$message))
      NULL  # Return NULL on error
    })

    if (!is.null(result)) {
      success <- TRUE  # If result is not NULL, we succeeded
    } else {
      Sys.sleep(sleep_time)  # Sleep before retrying
    }
  }

  if (!success) {
    stop("All attempts failed.")
  }

  return(result)
}

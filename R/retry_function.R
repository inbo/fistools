#' Retry a function multiple times
#'
#' This function evaluates an expression multiple times until it succeeds or the maximum number of attempts is reached.
#'
#' @param expr An expression to evaluate.
#' @param max_attempts The maximum number of attempts to make.
#'
#' @return The result of the expression if successful.
#'
#' @author Sander Devisscher
#' @family other
#'
#' @examples
#' \dontrun{
#' # This example will fail the first two times, but succeed on the third attempt.
#' retry_function({
#'  if (runif(1) < 0.5) {  # Randomly fail
#'  stop("Failed")
#'  }
#'  print("Success")
#'  })
#' }
#'
#' @export

retry_function <- function(expr, max_attempts = 3) {
  attempts <- 0
  success <- FALSE
  result <- NULL

  while (attempts < max_attempts && !success) {
    attempts <- attempts + 1
    result <- tryCatch({
      eval(expr)  # Evaluate the expression
      success <- TRUE
      result  # Return the result if successful
    }, error = function(e) {
      message(sprintf("Attempt %d failed: %s", attempts, e$message))
      NULL  # Return NULL on error
    })
  }

  if (!success) {
    stop("All attempts failed.")
  }

  return(result)
}

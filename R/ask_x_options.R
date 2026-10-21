#' @title Custom Multiple Choice Popup Dialog
#'
#' @description
#' Creates a custom graphical user interface (GUI) dialog box using the
#' \code{tcltk} package. This function prompts the user with a message and a
#' configurable number of button options, pausing R execution until a selection
#' is made or the window is closed.
#'
#' @param title Character string. The title of the popup window.
#' Default is \code{"Choose an Option"}.
#' @param message Character string. The instruction or message displayed above
#' the buttons. Default is \code{"Please make a selection:"}.
#' @param n Numeric. The exact number of options/buttons to generate.
#' Default is \code{4}.
#' @param options Character vector. The text labels for the buttons. The length
#' of this vector must exactly match \code{n}.
#' Default is \code{c("Option 1", "Option 2", "Option 3", "Option 4")}.
#'
#' @return A character string matching the text of the clicked button. Returns
#' \code{NA} if the user closes the window (e.g., via the 'X' button) without
#' making a selection.
#'
#' @seealso \code{\link[tcltk]{tk_messageBox}} for standard dialog boxes.
#'
#' @examples
#' \dontrun{
#' # Standard usage with default 4 options
#' response <- ask_x_options()
#' print(response)
#'
#' # Customizing for a Yes/No/Cancel scenario (n = 3)
#' response_3 <- ask_x_options(
#'   title = "Unsaved Changes",
#'   message = "What would you like to do with your current document?",
#'   n = 3,
#'   options = c("Save", "Don't Save", "Cancel")
#' )
#' }
#'
#' @export

ask_x_options <- function(title = "Choose an Option",
                          message = "Please make a selection:",
                          n = 4,
                          options = c("Option 1", "Option 2", "Option 3", "Option 4")) {

  # Ensure we have exactly 4 options
  if(length(options) != n) {
    stop(paste0("Please provide exactly ", n, " options in the 'options' argument."))
  }

  # Create a new top-level window
  tt <- tcltk::tktoplevel()
  tcltk::tkwm.title(tt, title)

  # Variable to store the user's selection
  result <- tcltk::tclVar("")

  # Add the message label to the window
  msg_label <- tcltk::tklabel(tt, text = message, padx = 20, pady = 20)
  tcltk::tkgrid(msg_label, columnspan = n)

  # Function to handle button clicks
  on_click <- function(choice) {
    tcltk::tclvalue(result) <- choice
    tcltk::tkdestroy(tt) # Close the window
  }

  # Create the 4 buttons
  btn_list <- base::lapply(1:n, function(i) {
    tcltk::tkbutton(tt, text = options[i], width = 10,
             command = function() on_click(options[i]))
  })

  # Combine the unnamed list of buttons with the named layout arguments
  grid_args <- c(btn_list, list(padx = 10, pady = c(0, 20)))

  # Feed the combined list to tkgrid
  base::do.call(tcltk::tkgrid, grid_args)

  # Center the window on the screen (optional but nice)
  tcltk::tkwm.geometry(tt, "+400+300")

  # Pause R execution until the window is closed
  tcltk::tkwait.window(tt)

  # Retrieve and return the result
  final_result <- tcltk::tclvalue(result)

  # If the user closes the window with the 'X' button instead of clicking an option, return NA
  if(final_result == "") {
    return(NA)
  }

  return(final_result)
}

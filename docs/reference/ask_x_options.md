# Custom Multiple Choice Popup Dialog

Creates a custom graphical user interface (GUI) dialog box using the
`tcltk` package. This function prompts the user with a message and a
configurable number of button options, pausing R execution until a
selection is made or the window is closed.

## Usage

``` r
ask_x_options(
  title = "Choose an Option",
  message = "Please make a selection:",
  n = 4,
  options = c("Option 1", "Option 2", "Option 3", "Option 4")
)
```

## Arguments

- title:

  Character string. The title of the popup window. Default is
  `"Choose an Option"`.

- message:

  Character string. The instruction or message displayed above the
  buttons. Default is `"Please make a selection:"`.

- n:

  Numeric. The exact number of options/buttons to generate. Default is
  `4`.

- options:

  Character vector. The text labels for the buttons. The length of this
  vector must exactly match `n`. Default is
  `c("Option 1", "Option 2", "Option 3", "Option 4")`.

## Value

A character string matching the text of the clicked button. Returns `NA`
if the user closes the window (e.g., via the 'X' button) without making
a selection.

## See also

[`tk_messageBox`](https://rdrr.io/r/tcltk/tk_messageBox.html) for
standard dialog boxes.

## Examples

``` r
if (FALSE) { # \dontrun{
# Standard usage with default 4 options
response <- ask_x_options()
print(response)

# Customizing for a Yes/No/Cancel scenario (n = 3)
response_3 <- ask_x_options(
  title = "Unsaved Changes",
  message = "What would you like to do with your current document?",
  n = 3,
  options = c("Save", "Don't Save", "Cancel")
)
} # }
```

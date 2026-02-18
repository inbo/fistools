# Generate a Colored PDF from a Line Art Image

This function takes a line art image (like a logo), applies a specified
color to the lines, and saves it as a high-resolution PDF suitable for
printing. It uses the `magick` package to handle image processing.

## Usage

``` r
generate_colored_pdf(input = NULL, output, color = "#c04384", density = 300)
```

## Arguments

- input:

  Optional, the file path to the input line art image (e.g., PNG, JPEG).

- output:

  The file path where the output PDF should be saved.

- color:

  A character string specifying the target color in a format recognized
  by `magick` (e.g., "red", "#FF0000", "rgb(255,0,0)"). The default
  color is INBO pink ("#c04384").

- density:

  An integer specifying the resolution (DPI) for the output PDF. The
  default is 300, which is suitable for high-quality printing.

## Value

A PDF file saved at the specified output path, containing the colored
line art.

## Details

The function performs the following steps: 0. If the `input` parameter
is not provided, it prompts the user to select an image file using a
file dialog.

1.  Reads the input image using `magick::image_read()`.

2.  Optionally upscales the image if its width is less than 3000 pixels
    to ensure better print quality.

3.  Creates a mask by converting the image to grayscale, inverting it,
    and applying a level adjustment to enhance contrast.

4.  Creates a blank canvas filled with the specified target color.

5.  Applies the mask to the color canvas using the "CopyOpacity"
    operator, which makes the lines visible in the target color while
    keeping the background transparent.

6.  Optionally flattens the image over a white background to ensure it
    prints correctly, especially if the PDF viewer does not handle
    transparency well.

7.  Converts the final image to the CMYK colorspace, which is standard
    for printing.

8.  Saves the final image as a PDF with the specified density.

## Author

Sander Devisscher

## Examples

``` r
if (FALSE) { # \dontrun{
input_file  <- "image.jpeg"      # Change to your file name
output_file <- "output_cmyk.pdf" # Output file name

generate_colored_pdf(input_file, output_file)
} # }
```

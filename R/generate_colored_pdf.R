#' Generate a Colored PDF from a Line Art Image
#'
#' This function takes a line art image (like a logo), applies a specified color to the lines, and saves it as a high-resolution PDF suitable for printing. It uses the `magick` package to handle image processing.
#'
#' @param input The file path to the input line art image (e.g., PNG, JPEG).
#' @param output The file path where the output PDF should be saved.
#' @param color A character string specifying the target color in a format recognized by `magick` (e.g., "red", "#FF0000", "rgb(255,0,0)"). The default color is INBO pink ("#c04384").
#' @param density An integer specifying the resolution (DPI) for the output PDF. The default is 300, which is suitable for high-quality printing.
#'
#' @details
#' The function performs the following steps:
#' 1. Reads the input image using `magick::image_read()`.
#' 2. Optionally upscales the image if its width is less than 3000 pixels to ensure better print quality.
#' 3. Creates a mask by converting the image to grayscale, inverting it, and applying a level adjustment to enhance contrast.
#' 4. Creates a blank canvas filled with the specified target color.
#' 5. Applies the mask to the color canvas using the "CopyOpacity" operator, which makes the lines visible in the target color while keeping the background transparent.
#' 6. Optionally flattens the image over a white background to ensure it prints correctly, especially if the PDF viewer does not handle transparency well.
#' 7. Converts the final image to the CMYK colorspace, which is standard for printing.
#' 8. Saves the final image as a PDF with the specified density.
#'
#' @returns A PDF file saved at the specified output path, containing the colored line art.
#'
#' @examples
#' \dontrun{
#' input_file  <- "image.jpeg"      # Change to your file name
#' output_file <- "output_cmyk.pdf" # Output file name
#'
#' generate_colored_pdf(input_file, output_file)
#' }
#'
#' @export
#' @author Sander Devisscher
#'
generate_colored_pdf <- function(input,
                                 output,
                                 color = "#c04384",
                                 density = 300) {

  # 1. Read the image
  img <- magick::image_read(input)

  # 2. Upscale for High Resolution
  # We check width; if it's small (< 3000px), we upscale it for better print quality.
  info <- magick::image_info(img)
  if(info$width < 3000) {
    img <- magick::image_resize(img, geometry = "3000x")
  }

  # 3. Create a Mask
  # Convert to grayscale to ensure we ignore existing colors
  gray <- magick::image_convert(img, type = "Grayscale")

  # Invert: We need the Text to be White (Opaque) and BG to be Black (Transparent)
  # for the 'CopyOpacity' operation later.
  # Note: Standard 'image_transparent' works, but this manual mask is more precise for lines.
  mask <- magick::image_negate(gray)

  # Optional: Increase contrast to clean up noise (thresholding)
  # Pixels darker than 80% become black, lighter than 20% become white
  mask <- magick::image_level(mask, black_point = 20, white_point = 80)

  # 4. Create the Color Layer
  # Update info after resize
  info <- magick::image_info(img)

  # Create a blank canvas filled with your exact Target Color
  # We force the colorspace to CMYK to ensure the color values stick
  canvas <- magick::image_blank(width = info$width,
                        height = info$height,
                        color = color)

  # 5. Apply the Mask
  # 'CopyOpacity' applies the grayscale values of 'mask' as the Alpha channel of 'canvas'
  # Where mask is White -> Canvas Color shows.
  # Where mask is Black -> Canvas becomes Transparent.
  colored_logo <- magick::image_composite(canvas, mask, operator = "CopyOpacity")

  # 6. Flatten over White Background (Optional)
  # If you want a transparent PDF, skip this.
  # For print, it is safer to flatten over white.
  bg <- magick::image_blank(width = info$width,
                    height = info$height,
                    color = "white")
  final_img <- magick::image_composite(bg, colored_logo, operator = "Over")

  # 7. Convert to Final Colorspace and Save
  # Ensure the final PDF is explicitly CMYK
  final_img <- magick::image_convert(final_img, colorspace = "CMYK")

  # Write to PDF
  magick::image_write(final_img, path = output, format = "pdf", density = density)

  message(paste("Success! Saved to:", output))
}

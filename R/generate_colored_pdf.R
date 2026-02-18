generate_colored_pdf <- function(input, output, color, density) {

  # 1. Read the image
  img <- image_read(input)

  # 2. Upscale for High Resolution
  # We check width; if it's small (< 3000px), we upscale it for better print quality.
  info <- image_info(img)
  if(info$width < 3000) {
    img <- image_resize(img, geometry = "3000x")
  }

  # 3. Create a Mask
  # Convert to grayscale to ensure we ignore existing colors
  gray <- image_convert(img, type = "Grayscale")

  # Invert: We need the Text to be White (Opaque) and BG to be Black (Transparent)
  # for the 'CopyOpacity' operation later.
  # Note: Standard 'image_transparent' works, but this manual mask is more precise for lines.
  mask <- image_negate(gray)

  # Optional: Increase contrast to clean up noise (thresholding)
  # Pixels darker than 80% become black, lighter than 20% become white
  mask <- image_level(mask, black_point = 20, white_point = 80)

  # 4. Create the Color Layer
  # Update info after resize
  info <- image_info(img)

  # Create a blank canvas filled with your exact Target Color
  # We force the colorspace to CMYK to ensure the color values stick
  canvas <- image_blank(width = info$width,
                        height = info$height,
                        color = color)

  # 5. Apply the Mask
  # 'CopyOpacity' applies the grayscale values of 'mask' as the Alpha channel of 'canvas'
  # Where mask is White -> Canvas Color shows.
  # Where mask is Black -> Canvas becomes Transparent.
  colored_logo <- image_composite(canvas, mask, operator = "CopyOpacity")

  # 6. Flatten over White Background (Optional)
  # If you want a transparent PDF, skip this.
  # For print, it is safer to flatten over white.
  bg <- image_blank(width = info$width,
                    height = info$height,
                    color = "white")
  final_img <- image_composite(bg, colored_logo, operator = "Over")

  # 7. Convert to Final Colorspace and Save
  # Ensure the final PDF is explicitly CMYK
  final_img <- image_convert(final_img, colorspace = "CMYK")

  # Write to PDF
  image_write(final_img, path = output, format = "pdf", density = density)

  message(paste("Success! Saved to:", output))
}

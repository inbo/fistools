# Read the DESCRIPTION file
desc <- read.dcf("DESCRIPTION")

# Convert to a named list
desc_list <- as.list(desc[1,])

# Load each field into the environment
for (name in names(desc_list)) {
  assign(name, desc_list[[name]], envir = .GlobalEnv)
}

# install packages in the DESCRIPTION file Imports field
Imports <- strsplit(Imports, ",\n")[[1]]

# loop through each package and install it
for (package in Imports) {
  # remove version numbers
  package <- gsub("\\(.*\\)", "", package)
  # remove leading and trailing whitespace
  package <- trimws(package)
  # unload the package if it is already loaded
  if (package %in% rownames(installed.packages())) detach(package, unload = TRUE)
  install.packages(package)
}

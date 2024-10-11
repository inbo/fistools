# Script to check whether version in DESCRIPTION file is higher than the one in the package
# This script is intended to be run in a CI environment
# It will increment the version in the DESCRIPTION file if it is lower than the one in the package

# Load the local DESCRIPTION file
desc_local <- as.data.frame(read.dcf("DESCRIPTION"))

# Get the version from the DESCRIPTION file
version_local <- desc_local$Version

# Download the DESCRIPTION file from the repository
# https://raw.githubusercontent.com/inbo/fistools/main/DESCRIPTION

dest_file <- paste0(tempdir(),"\\DESCRIPTION")

download.file("https://raw.githubusercontent.com/inbo/fistools/main/DESCRIPTION", dest_file)

desc_remote <- as.data.frame(read.dcf(dest_file))

version_remote <- desc_remote$Version

# get git branch name
branch <- system("git rev-parse --abbrev-ref HEAD", intern = TRUE)

print(branch)

# Check if new-function or new-dataset is in branch
if(grepl("new-function", branch) |
   grepl("new-dataset", branch) |
   grepl("new function", branch) |
   grepl("new dataset", branch)){
  type <- "minor"
}else{
  type <- "patch"

}

# Check if the version in the DESCRIPTION file is lower than the one in the package
# Convert to a list of numbers
version_local <- as.numeric(unlist(strsplit(version_local, "\\.")[1]))
version_remote <- as.numeric(unlist(strsplit(version_remote, "\\.")[1]))

maj_local <- version_local[1]
maj_remote <- version_remote[1]

min_local <- version_local[2]
min_remote <- version_remote[2]

patch_local <- version_local[3]
patch_remote <- version_remote[3]

increment <- FALSE
# equilise the version:
# larger major version in remote
while(maj_local < maj_remote){
  message("The local version in DESCRIPTION file is lower than the one in the package")
  usethis::use_version(which = "major", push = FALSE)
  maj_local <- maj_local + 1
  increment <- TRUE
}

# larger minor version in remote
if(maj_local == maj_remote){
  while(min_local < min_remote){
    message("The local version in DESCRIPTION file is lower than the one in the package")
    usethis::use_version(which = "minor", push = FALSE)
    min_local <- min_local + 1
    increment <- TRUE
  }
}

# larger patch version in remote
if(maj_local == maj_remote & min_local == min_remote){
  while(patch_local < patch_remote){
    message("The local version in DESCRIPTION file is lower than the one in the package")
    usethis::use_version(which = "patch", push = FALSE)
    patch_local <- patch_local + 1
    increment <- TRUE
  }
}

if(maj_local == maj_remote & min_local == min_remote & patch_local == patch_remote){
  message("The local version in DESCRIPTION file is equal to the one in the package")
  increment <- TRUE
}

if(increment){
  usethis::use_version(which = type)
}else{
  print("Version in DESCRIPTION file is already higher than the one in the package")
}

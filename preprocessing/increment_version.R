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

# Check if new-function or new-dataset is in branch
if(grepl("new-function", branch) | grepl("new-dataset", branch)){
  type <- "minor"
}else{
  type <- "patch"

}

# Check if the version in the DESCRIPTION file is lower than the one in the package

if(version_local == version_remote){
  usethis::use_version(which = type)
}else{
  print("Version in DESCRIPTION file is already higher than the one in the package")
}

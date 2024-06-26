% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_dep_media.R
\name{download_dep_media}
\alias{download_dep_media}
\title{Download deployment media}
\usage{
download_dep_media(
  dataset,
  depID,
  species = NULL,
  favorite = FALSE,
  outputfolder = NULL
)
}
\arguments{
\item{dataset}{character string, path to the folder where a camptraptor datapackage has been unzipped.}

\item{depID}{character string, ID of the deployment to download media from.}

\item{species}{character string, latin name of the species to download}

\item{favorite}{boolean, do you only want the pretty pictures?}

\item{outputfolder}{character string, path where the function should download the media into}
}
\value{
Downloads the specified media files into the outputfolder
}
\description{
This function allows the user to download all media related to a Agouti -
dataset which matches the given parameters.
}
\details{
If you are getting an Authorization Error (#403), this probably means your Agouti project has Restrict Images on. This needs to be turned off.
If depID = "all" and favorite = TRUE, the function will download all favorited pictures in the whole dataset.
}
\examples{
\dontrun{
drg <- fistools::drg_example

# Situation 1: download whole deployment
download_dep_media(dataset = drg,
                    depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f")

# Situation 2: download only wanted species
download_dep_media(dataset = drg,
                    depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f",
                    species = "Dama dama")

# Situation 3: download only favorited species media
download_dep_media(dataset = drg,
                    depID = "96413aa6-5f1f-4dfb-8fab-8f06decc179f",
                    species = "Dama dama",
                    favorite = TRUE)

# Situation 4: download only favorited species media
download_dep_media(dataset = drg,
                    depID = "all",
                    favorite = TRUE)
}

}
\author{
Lynn Pallemaerts

Emma Cartuyvels

Sander Devisscher

Soria Delva
}

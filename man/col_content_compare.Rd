% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/col_content_compare.R
\name{col_content_compare}
\alias{col_content_compare}
\title{Compare column contents of two dataframes}
\usage{
col_content_compare(df1, col1, df2, col2)
}
\arguments{
\item{df1}{A data frame}

\item{col1}{A column name of df1}

\item{df2}{A data frame}

\item{col2}{A column name of df2}
}
\value{
A list of values missing from the first column, missing from the second column,
and the values that are in both columns.
}
\description{
Compares the content of 2 similar columns of two data frames.
The function prints a list of values missing from the first column,
missing from the second column, and the values that are in both columns.
}
\examples{
 \dontrun{
dataset1 <- data.frame(a = c(1, 2, 3, 4, 5), b = c("a", "b", "c", "d", "e"))
dataset2 <- data.frame(c = c(1, 2, 3, 4, 5), d = c("a", "b", "f", "d", "e"))
col_content_compare(df1 = dataset1, "b", df2 = dataset2, "d")
}

}
\seealso{
Other dataframe_comparison: 
\code{\link{colcompare}()}
}
\author{
Sander Devisscher
}
\concept{column comparison}
\concept{dataframe_comparison}

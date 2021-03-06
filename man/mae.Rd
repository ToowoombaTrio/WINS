% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/caclulate_error.R
\name{mae}
\alias{mae}
\title{Calculate Root Mean Absolute Error}
\usage{
mae(actual, predicted)
}
\arguments{
\item{actual}{observed values}

\item{predicted}{predicted values}
}
\description{
Function that calculates Root Mean Absolute Error (MAE)
}
\examples{
# Example data
actual <- c(4, 6, 9, 10, 4, 6, 4, 7, 8, 7)
predicted <- c(5, 6, 8, 10, 4, 8, 4, 9, 8, 9)
mae(actual, predicted)

}

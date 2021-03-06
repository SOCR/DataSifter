% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/thinning.R
\name{thinning}
\alias{thinning}
\title{Thinning the Original Data}
\usage{
thinning(data, col_preserve = 0.5, col_pct = 0.7)
}
\arguments{
\item{data}{Original dataset}

\item{col_preserve}{The maximum percentage of number of columns can be deleted due to massive missingness.}

\item{col_pct}{Criterion for column deletion due to massive missingness. If missing percentage is larger than this threshold, delete the corresponding column.}
}
\value{
Returns a list of two elements. "data.new" Returns data after deleting non-informative columns. "misscol" Returns olumns deleted by the procedure.
}
\description{
Delete features in the original data with a majority of data missing.
}

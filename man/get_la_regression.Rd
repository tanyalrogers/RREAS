% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/regressions.R
\name{get_la_regression}
\alias{get_la_regression}
\title{Get length-age regressions}
\usage{
get_la_regression()
}
\value{
A function which takes a species code, vector of years, and vector of
lengths (mm) as input, and returns a vector of ages (days).
}
\description{
Runs length-age regressions using data in the AGE table and outputs a
function to convert lengths into ages. This function (and the outputed
function) are used internally in \code{\link{get_totals}} and \code{\link{get_distributions}} but
it can be called independently, e.g. if you want to see what the
regressions look like.
}
\details{
This fits standard linear regressions. Calling this functions runs the
regressions for all available species.

Length-age regressions can be done for all species in the AGE table. Run
\code{unique(AGE$SPECIES)} for a list. These include all the rockfishes in
\code{\link{sptable_rockfish100}}, as well as YOY hake (382) and YOY lingcod (448).

The rockfish model uses data from all species. It fits a slope for each
species, and intercepts for each year. The mean intercept is used for
missing years.

The hake model has a unique slope and intercept for each year. For missing
years, the slope and intercept from the pooled data (all years) is used.

For the lingcod model, which has only 1 year of data, there is a single
slope and intercept used for all years.

If the resulting function is unable to generate a regression for the input species, a
warning will be displayed and the function will return NA for any
length input.
}
\examples{
\dontrun{
len_to_age = get_la_regression()
}
}
\keyword{functions}

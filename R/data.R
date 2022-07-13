#' Species table for rockfishes used in 100 day index
#'
#'
#' @format A data frame with 12 rows and 4 variables:
#' \describe{
#'   \item{SPECIES}{Species code}
#'   \item{MATURITY}{Maturity code}
#'   \item{NAME}{Name (3 letter code)}
#'   \item{MINLEN}{Minimum length (20 mm)}
#'   \item{COMMON}{Common name}
#' }
#' @keywords datasets
"sptable_rockfish100"

#' Species table for common RREAS species and species groups
#'
#'
#' @format A data frame with 12 rows and 3 variables:
#' \describe{
#'   \item{SPECIES}{Species code}
#'   \item{MATURITY}{Maturity code}
#'   \item{NAME}{Name}
#' }
#' @keywords datasets
"sptable"

#' Species table for RREAS species and species groups (biomass)
#'
#'
#' @format A data frame with 12 rows and 3 variables:
#' \describe{
#'   \item{SPECIES}{Species code}
#'   \item{MATURITY}{Maturity code}
#'   \item{NAME}{Name}
#' }
#' @keywords datasets
"sptable_lw"

#' Rockfish length-weight groupings
#'
#' This table is used interally for length-weight regressions.
#'
#' @format A data frame with 12 rows and 3 variables:
#' \describe{
#'   \item{SPECIES}{Species code}
#'   \item{COMMON_NAME}{Common name}
#'   \item{SCI_NAME}{Scientific name}
#'   \item{RFGROUP}{Group number}
#'   \item{SPECIES_GROUP}{Rockfish}
#'   \item{NMEAS}{Number measured}
#' }
#' @keywords datasets
"rflwgroups"

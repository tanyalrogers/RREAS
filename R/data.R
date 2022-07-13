#' Species table for rockfishes used in 100 day index
#'
#' Table of rockfish species for which 100 day standardized indices can be generated.
#' Specifies a minimum length of 20 mm. Includes a common name field that can be joined
#' later for plotting purposes.
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
#' Table of species and species groups for which indices are commonly
#' reported in ecosystem assessments.
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
#' Table of species and species groups for which biomass estimates can be obtained.
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
#' Length-weight groupings for all rockfish species, specifying which species
#' should be pooled for regressions and used as proxies for other species.
#' There are currently 4 groupings based on general body shape.
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

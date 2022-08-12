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

#' RREAS data from ERDDAP
#'
#' RREAS data tables pulled from ERDDAP. These are reformatted as relational tables
#' matching the format of the table in the database. Data on ERDDAP begins
#' in 1990 and ends about 4 years from the present.
#'
#' @name RREAS_ERDDAP
#' @aliases CATCH_ERDDAP HAUL_ERDDAP HAULSTANDARD_ERDDAP SPECIES_CODES_ERDDAP
#'
#' @details Contains additional SPECIES/MATURITY categories 1472/T (total krill)
#'   and 1940/T (total rockfish).
#'
#' @format Data frames with some combination of the following fields
#' \describe{
#'   \item{CRUISE}{Cruise ID}
#'   \item{HAUL_NO}{Haul number}
#'   \item{VESSEL}{Survey vessel code}
#'   \item{STATION}{Station code}
#'   \item{HAUL_DATE}{Haul date and time}
#'   \item{YEAR}{Survey year}
#'   \item{MONTH}{Haul month}
#'   \item{JDAY}{Haul julian day}
#'   \item{NET_IN_LATDD}{Latitude at which net went in water (decimal degrees)}
#'   \item{NET_IN_LONDD}{Longitude at which net went in water (decimal degrees)}
#'   \item{LATDD}{Latitude of station (decimal degrees)}
#'   \item{LONDD}{Longitude of station (decimal degrees)}
#'   \item{BOTTOM_DEPTH}{Bottom depth of haul (m)}
#'   \item{STATION_BOTTOM_DEPTH}{Bottom depth of station (m)}
#'   \item{STRATA}{Survey region (C:Core, NC:North core, SC: South core, N: North, S: South)}
#'   \item{AREA}{Survey area (transect or subregion)}
#'   \item{SPECIES}{Species code}
#'   \item{MATURITY}{Maturity code}
#'   \item{COMMON_NAME}{Common name}
#'   \item{SCI_NAME}{Scientific name}
#'   \item{TOTAL_NO}{Number of individuals caught}
#'   \item{STD_LENGTH}{Standard length (mm)}
#' }
#' @references Sakuma, K.M., Field, J.C., Mantua, N.J., Ralston, S., Marinovic,
#'   B.B. and Carrion, C.N. (2016) Anomalous epipelagic micronekton assemblage patterns
#'   in the neritic waters of the California Current in spring 2015 during a
#'   period of extreme ocean conditions. CalCOFI Rep. 57:163-183
#' @source \url{https://oceanview.pfeg.noaa.gov/erddap/tabledap/FED_Rockfish_Catch.html}
#'   \url{https://oceanview.pfeg.noaa.gov/erddap/tabledap/FED_Rockfish_Length.html}
#' @keywords datasets
NULL

#' @rdname RREAS_ERDDAP
"HAUL_ERDDAP"
#' @rdname RREAS_ERDDAP
"HAULSTANDARD_ERDDAP"
#' @rdname RREAS_ERDDAP
"CATCH_ERDDAP"
#' @rdname RREAS_ERDDAP
"LENGTH_ERDDAP"
#' @rdname RREAS_ERDDAP
"SPECIES_CODES_ERDDAP"

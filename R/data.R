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
#' reported in ecosystem assessments. Includes notes on irregularities
#' in species classifications.
#'
#' @details
#' We include notes here on some irregularities in species classifications
#' in the RREAS database. With the exception of myctophids, these species are
#' not in `sptable`, but users who want to generate a species table for these
#' species or species groups should be aware of these inconsistencies.
#' Information can also be found in the SPECIES_CODES table.
#'
#' **Myctophids:** Blue lanternfish (685) and California headlightfish (192) have
#' always been identified to species and separated from unknown myctophids
#' (407). Over time, more myctophids (e.g. Northern lampfish (661), California
#' lanternfish (669)) have been identified to species and no longer classified
#' as 407. Thus, depending on the survey year, 407 encompasses different
#' species.
#'
#' **Squids:** Market squid (1101) have always been identified to species and
#' separated from unknown squid (1918). Over time, more squid have been
#' identified to species and no longer classified as 1918. Thus, depending on
#' the survey year, 1918 encompasses different species.
#'
#' **Heteropods:** Prior to 2016, all heteropods were classified as unknown
#' heteropods (1869). In 2016, this category was split into Carinaria (2050) and
#' Pterotrachea (2853).
#'
#' **Smelts:** Prior to 2018, all smelts were classified as unknown smelt (453).
#' Starting in 2018, adult smelt were identified to species. Larval smelt
#' remained classified as 453.
#'
#' **Eelpouts:** Prior to CRUISE 8806, eelpouts were not consistently identified. Many
#' unknown eelpouts (743) were probably pallid eelpouts (359). Starting with
#' CRUISE 8806, pallid eelpouts were consistently identified to species and separated from
#' unknown eelpouts.
#'
#' **Dragonfish:** Prior to 1990, dragonfish were not consistently identified. Many
#' unknown dragonfish (378) were likely longfin dragonfish (681). Starting in
#' 1990, longfin dragonfish were consistently identified to species and separated from
#' unknown dragonfish.
#'
#'
#' @format A data frame with 73 rows and 3 variables:
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
#' @format A data frame with 92 rows and 3 variables:
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
#' @format A data frame with 62 rows and 6 variables:
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

#' RREAS data tables
#'
#' Meta-data for RREAS data tables. Additional details can be found in the data publication.
#'
#' @name RREAS_TABLES
#' @aliases STATIONS_RREAS SPECIES_CODES_RREAS CATCH_ERDDAP CATCH_RREAS HAUL_ERDDAP HAUL_RREAS
#'   HAULSTANDARD_ERDDAP HAULSTANDARD_RREAS WEIGHT_RREAS CTD_HEADER CTD_CAST NET_MENSURATION
#'
#' @details All latitudes and longitudes in the Dryad and ERDDAP datasets are in
#'   decimal degrees. Latitudes and longitudes in the Access Database are in
#'   a different format, but are converted to decimal degrees in HAULSTANDARD.
#'   All times are local time (Pacific Daylight Time).
#'
#'   The data from ERDDAP are reformatted as relational tables matching
#'   the format of the tables in the database. Data on ERDDAP begins in 1990.
#'   The ERDDAP version contains additional SPECIES/MATURITY categories 1472/T
#'   (total krill) and 1940/T (total rockfish).
#'
#' @format Data frames with some combination of the following fields
#' \describe{
#'   \item{CRUISE}{Cruise ID}
#'   \item{HAUL_NO}{Haul number}
#'   \item{VESSEL}{Survey vessel code}
#'   \item{STATION}{Station code}
#'   \item{HAUL_DATE}{Haul date}
#'   \item{NET_IN_LAT/LON/TIME}{Codend in water}
#'   \item{DOORS_IN_LAT/LON/TIME}{Doors in water}
#'   \item{NET_FISHING_LAT/LON/TIME}{Begin fishing at target depth}
#'   \item{NET_BACK_LAT/LON/TIME}{End fishing at target depth}
#'   \item{DOORS_OUT_LAT/LON/TIME}{Doors out of water}
#'   \item{NET_OUT_LAT/LON/TIME}{Codend out of water}
#'   \item{STRATA}{Target fishing depth:1=10m, 2=30m, 3=90m}
#'   \item{PROBLEM}{Problem code: 0=no problem, 2=rockfish subsampled,
#'     3=aborted trawl due to scyphozoans, 9=aborted trawl due to pelagic tunicates}
#'   \item{STANDARD_STATION}{Was the trawl done at station, at the target fishing depth,
#'     and for the target fishing time with no problems affecting data quality: 1=standard trawl, 0=non-standard trawl}
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
#'   \item{RAW_NO}{Number of individuals caught, unadjusted}
#'   \item{TOTAL_NO}{Number of individuals caught, adjusted (all tows standardized to 15 minute)}
#'   \item{STD_LENGTH}{Organism size (mm): Standard length for fishes, mantle length for squids,
#'     carapace length for crustaceans, bell diameter for jellies, total length for other invertebrates}
#'   \item{WEIGHT}{Organism wet weight (g)}
#'   \item{CTD_INDEX}{CTD cast number}
#'
#' }
#' @references Sakuma, K.M., Field, J.C., Mantua, N.J., Ralston, S., Marinovic,
#'   B.B. and Carrion, C.N. (2016) Anomalous epipelagic micronekton assemblage patterns
#'   in the neritic waters of the California Current in spring 2015 during a
#'   period of extreme ocean conditions. CalCOFI Rep. 57:163-183
#' @source Dryad data from: URL. ERDDAP data from: \url{https://oceanview.pfeg.noaa.gov/erddap/tabledap/FED_Rockfish_Catch.html}
#'   \url{https://oceanview.pfeg.noaa.gov/erddap/tabledap/FED_Rockfish_Length.html}
#' @keywords datasets
NULL

#' @rdname RREAS_TABLES
"STATIONS_RREAS"
#' @rdname RREAS_TABLES
"SPECIES_CODES_RREAS"
#' @rdname RREAS_TABLES
"HAUL_ERDDAP"
#' @rdname RREAS_TABLES
"HAUL_RREAS"
#' @rdname RREAS_TABLES
"HAULSTANDARD_ERDDAP"
#' @rdname RREAS_TABLES
"HAULSTANDARD_RREAS"
#' @rdname RREAS_TABLES
"CATCH_ERDDAP"
#' @rdname RREAS_TABLES
"CATCH_RREAS"
#' @rdname RREAS_TABLES
"LENGTH_ERDDAP"
#' @rdname RREAS_TABLES
"LENGTH_RREAS"
#' @rdname RREAS_TABLES
"WEIGHT_RREAS"
#' @rdname RREAS_TABLES
"NET_MENSURATION"
#' @rdname RREAS_TABLES
"CTD_HEADER"
#' @rdname RREAS_TABLES
"CTD_CAST"


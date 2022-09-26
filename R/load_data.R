#' Load Data from MS Access Database
#'
#' Loads the HAUL, CATCH, and LENGTH tables from one or more surveys in the RREAS database,
#' along with the AGE, WEIGHT, and SPECIES_CODES tables from RREAS. Also creates and loads a
#' HAULSTANDARD table for each survey containing only standard stations and with a standardized set of
#' columns including YEAR, MONTH, JDAY, and lat/lon in decimal degrees. HAULSTANDARD tables all have
#' the same format and can be stacked with \code{rbind}.
#' \strong{This function requires a local copy of the RREAS MS Access Database.}
#'
#' @details
#'
#' If the "NWFSC" dataset is requested, then the HAULSTANDARD_NWFSC table will
#' contain the NWFSC stations sampled in the NWFSC survey, the RREAS stations
#' sampled in the NWFSC survey, and the NWFSC stations sampled in the RREAS
#' survey.
#'
#' If a path to "atsea.mdb" is given, containing the current year's data, it
#' will be appended to the RREAS tables.
#'
#' @param mdb_path File path to the juv_cruise mdb file (required).
#' @param atsea_path File path to "atsea.mdb" containing the current year's data (optional).
#'   Data will be appended to the RREAS tables.
#' @param datasets Character vector indicating which dataset(s) to load. Multiple dataset can
#'   be specified. Options are "RREAS", "ADAMS", "PWCC", "NWFSC". If unspecified, loads just "RREAS".
#' @param krill_len_path File path to "krill_lengths.csv" (optional, unless you later want
#'   to get krill biomass).
#'   \emph{This argument will be removed once the krill lengths are added to the database.}
#' @param startyear Start year (default is 1983).
#' @param activestationsonly Logical. Include only active stations in the resulting tables.
#'   ACTIVE is a column in HAULSTANDARD and can always be used to subset later.
#' @return Tables are written to the global environment (and will overwrite any existing tables
#'   with the same names). Diplays "Data loaded" if successful.
#' @export
#' @keywords functions
#' @references Sakuma, K.M., Field, J.C., Mantua, N.J., Ralston, S., Marinovic,
#'   B.B. and Carrion, C.N. (2016) Anomalous epipelagic micronekton assemblage patterns
#'   in the neritic waters of the California Current in spring 2015 during a
#'   period of extreme ocean conditions. CalCOFI Rep. 57:163-183
#' @examples
#' \dontrun{
#' load_mdb(mdb_path = "insert_filepath/juv_cruise_backup27JAN21.mdb",
#'   krill_len_path = "insert_filepath/krill_lengths.csv",
#'   datasets = c("RREAS","ADAMS","PWCC","NWFSC"),
#'   activestationsonly = F)
#' }
load_mdb=function(mdb_path,atsea_path=NULL,datasets="RREAS",krill_len_path=NULL,
                  startyear=1983, activestationsonly=TRUE) {

  if(!file.exists(mdb_path)) {
    stop("Database not found. Check that the file path is correct.")
  }

  if(!all(datasets %in% c("RREAS","ADAMS","NWFSC","PWCC"))) {
    stop(paste(setdiff(datasets, c("RREAS","ADAMS","NWFSC","PWCC")), collapse = ", "), " is not an available dataset. Must be one or more of the following: 'RREAS','ADAMS','NWFSC','PWCC'")
  }

  #convert positions to decimal degrees
  convertdd <- function(x) {
    DEG <- floor(x/100)
    MIN <- x - DEG*100
    DD <- DEG + MIN/60
    return(DD)
  }

  channel <- RODBC::odbcConnectAccess2007(mdb_path)
  #RREAS standard stations
  standardstations<-RODBC::sqlQuery(channel, "SELECT * FROM dbo_STANDARD_STATIONS WHERE station<1000", stringsAsFactors = F)
  if(activestationsonly) {
    standardstations<-dplyr::filter(standardstations,ACTIVE=="Y")
  }

  on.exit(RODBC::odbcCloseAll()) #in case of errors

  if("RREAS" %in% datasets) {

    HAUL <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_HAUL", as.is=1, stringsAsFactors = F)
    CATCH <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_CATCH", as.is=1, stringsAsFactors = F)
    LENGTH <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_LENGTH", as.is=1, stringsAsFactors = F)
    #these tables only from RREAS main
    SPECIES_CODES <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_SPECIES_CODES", stringsAsFactors = F)
    WEIGHT <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_WEIGHT", as.is=1, stringsAsFactors = F)
    AGE <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_AGE", as.is=1, stringsAsFactors = F)

    #use DOORS_IN for missing NET_IN position, lag CRUISE 2001
    HAUL$NET_IN_LAT[is.na(HAUL$NET_IN_LAT)]<-HAUL$DOORS_IN_LAT[is.na(HAUL$NET_IN_LAT)]
    HAUL$NET_IN_LONG[is.na(HAUL$NET_IN_LONG)]<-HAUL$DOORS_IN_LONG[is.na(HAUL$NET_IN_LONG)]

    #convert coords to dd
    standardstations$LATDD<-convertdd(standardstations$LATITUDE)
    standardstations$LONDD<-(-convertdd(standardstations$LONGITUDE))
    HAUL$NET_IN_LATDD<-convertdd(HAUL$NET_IN_LAT)
    HAUL$NET_IN_LONDD<-(-convertdd(HAUL$NET_IN_LONG))
    #add year, month, and julian day
    HAUL$YEAR<-lubridate::year(HAUL$HAUL_DATE)
    HAUL$MONTH<-lubridate::month(HAUL$HAUL_DATE)
    HAUL$JDAY<-lubridate::yday(HAUL$HAUL_DATE)

    #join HAUL and standard station info, filter
    HAULSTANDARD<<-dplyr::inner_join(HAUL, standardstations, by="STATION") %>%
      dplyr::arrange(YEAR) %>%
      dplyr::filter(YEAR>=startyear) %>% #set start year
      dplyr::filter(STANDARD_STATION==1) %>%
      dplyr::filter(!(CRUISE %in% c("8703","8804","9003"))) %>% #not real cruises
      dplyr::mutate(SURVEY="RREAS") %>%
      dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                    LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)
  }

  if("ADAMS" %in% datasets) {

    HAUL_ADAMS <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_HAUL_ADAMS", as.is=1, stringsAsFactors = F)
    CATCH_ADAMS <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_CATCH_ADAMS", as.is=1, stringsAsFactors = F)
    LENGTH_ADAMS <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_LENGTH_ADAMS", as.is=1, stringsAsFactors = F)

    #convert coords to dd
    HAUL_ADAMS$NET_IN_LATDD<-convertdd(HAUL_ADAMS$NET_IN_LAT)
    HAUL_ADAMS$NET_IN_LONDD<-(-convertdd(HAUL_ADAMS$NET_IN_LONG))
    #add year, month, and julian day
    HAUL_ADAMS$YEAR<-lubridate::year(HAUL_ADAMS$HAUL_DATE)
    HAUL_ADAMS$MONTH<-lubridate::month(HAUL_ADAMS$HAUL_DATE)
    HAUL_ADAMS$JDAY<-lubridate::yday(HAUL_ADAMS$HAUL_DATE)

    #join HAUL and standard station info, filter
    HAULSTANDARD_ADAMS<<-dplyr::inner_join(HAUL_ADAMS, standardstations, by="STATION") %>%
      dplyr::arrange(YEAR) %>%
      dplyr::filter(STANDARD_STATION==1) %>%
      dplyr::mutate(SURVEY="ADAMS", BOTTOM_DEPTH=NA) %>%
      dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                    LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)
  }

  if("PWCC" %in% datasets) {

    HAUL_PWCC <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_PWCC_HAUL", as.is=1, stringsAsFactors = F)
    CATCH_PWCC <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_PWCC_CATCH", as.is=1, stringsAsFactors = F)
    LENGTH_PWCC <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_PWCC_LENGTH", as.is=1, stringsAsFactors = F)

    #rename columns
    colnames(HAUL_PWCC)<-sub("PWCC_","",colnames(HAUL_PWCC))
    colnames(CATCH_PWCC)<-sub("PWCC_","",colnames(CATCH_PWCC))
    colnames(LENGTH_PWCC)<-sub("PWCC_","",colnames(LENGTH_PWCC))

    HAUL_PWCC<-HAUL_PWCC %>%
      dplyr::mutate(NET_IN_LAT=NET_FISHING_LAT,
                    NET_IN_LONG=NET_FISHING_LONG,
                    HAUL_DATE=DOORS_IN_TIME,
                    STRATA=dplyr::case_when(NET_IN_LAT>4615 ~ "WA",
                                            NET_IN_LAT<=4615 & NET_IN_LAT>=4200 ~ "OR",
                                            NET_IN_LAT<4200 & NET_IN_LAT>4018 ~ "N",
                                            NET_IN_LAT<=4018 & NET_IN_LAT>3825 ~ "NC",
                                            NET_IN_LAT<=3825 & NET_IN_LAT>3630 ~ "C",
                                            NET_IN_LAT<=3630 & NET_IN_LAT>3427 ~ "SC",
                                            NET_IN_LAT<=3427 ~ "S"),
                    STATION=NA, #or assign
                    AREA=NA,
                    STATION_BOTTOM_DEPTH=NA,
                    ACTIVE=NA)

    #convert coords to dd
    HAUL_PWCC$NET_IN_LATDD<-convertdd(HAUL_PWCC$NET_IN_LAT)
    HAUL_PWCC$NET_IN_LONDD<-(-convertdd(HAUL_PWCC$NET_IN_LONG))
    #add year, month, and julian day
    HAUL_PWCC$YEAR<-lubridate::year(HAUL_PWCC$HAUL_DATE)
    HAUL_PWCC$MONTH<-lubridate::month(HAUL_PWCC$HAUL_DATE)
    HAUL_PWCC$JDAY<-lubridate::yday(HAUL_PWCC$HAUL_DATE)

    #join HAUL and standard station info, filter
    HAULSTANDARD_PWCC<<- HAUL_PWCC %>% #inner_join(HAUL_PWCC, standardstations, by="STATION") %>%
      dplyr::arrange(YEAR) %>%
      dplyr::filter(STANDARD==1) %>%
      dplyr::mutate(SURVEY="PWCC",LATDD=NET_IN_LATDD,LONDD=NET_IN_LONDD) %>% #LATDD and LONDD (if not from station)
      dplyr::filter(!is.na(LONDD)) %>% #delete 1 station with missing lon (entry 895)
      dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                    LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)
  }

  if("NWFSC" %in% datasets) {

    HAUL_NWFSC <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_NWFSC_JUV_HAUL", as.is=1, stringsAsFactors = F)
    CATCH_NWFSC <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_NWFSC_JUV_CATCH", as.is=1, stringsAsFactors = F)
    LENGTH_NWFSC <<- RODBC::sqlQuery(channel, "SELECT * FROM dbo_NWFSC_JUV_LENGTH", as.is=1, stringsAsFactors = F)
    #NWFSC standard stations
    standardstations_NWFSC<-RODBC::sqlQuery(channel, "SELECT * FROM dbo_NWFSC_STANDARD_STATIONS WHERE station<1000", stringsAsFactors = F)
    if(activestationsonly) {
      standardstations_NWFSC<-dplyr::filter(standardstations_NWFSC,ACTIVE=="Y")
    }

    #use NET_FISHING for missing NET_IN position
    HAUL_NWFSC$NET_IN_LAT[is.na(HAUL_NWFSC$NET_IN_LAT)]<-HAUL_NWFSC$NET_FISHING_LAT[is.na(HAUL_NWFSC$NET_IN_LAT)]
    HAUL_NWFSC$NET_IN_LONG[is.na(HAUL_NWFSC$NET_IN_LONG)]<-HAUL_NWFSC$NET_FISHING_LONG[is.na(HAUL_NWFSC$NET_IN_LONG)]

    #use NET_FISHING_TIME for missing HAUL_DATE
    HAUL_NWFSC$HAUL_DATE[is.na(HAUL_NWFSC$HAUL_DATE)]<-HAUL_NWFSC$NET_FISHING_TIME[is.na(HAUL_NWFSC$HAUL_DATE)]

    #convert coords to dd
    standardstations_NWFSC$LATDD<-convertdd(standardstations_NWFSC$LATITUDE)
    standardstations_NWFSC$LONDD<-(-convertdd(standardstations_NWFSC$LONGITUDE))
    HAUL_NWFSC$NET_IN_LATDD<-convertdd(HAUL_NWFSC$NET_IN_LAT)
    HAUL_NWFSC$NET_IN_LONDD<-(-convertdd(HAUL_NWFSC$NET_IN_LONG))
    #add year, month, and julian day
    HAUL_NWFSC$YEAR<-lubridate::year(HAUL_NWFSC$HAUL_DATE)
    HAUL_NWFSC$MONTH<-lubridate::month(HAUL_NWFSC$HAUL_DATE)
    HAUL_NWFSC$JDAY<-lubridate::yday(HAUL_NWFSC$HAUL_DATE)
    #fill in year for hauls with missing dates
    HAUL_NWFSC<-dplyr::mutate(HAUL_NWFSC, YEAR=dplyr::case_when(!is.na(HAUL_DATE) ~ YEAR,
                                                                CRUISE=="1101" ~ 2011,
                                                                CRUISE=="1506" ~ 2015,
                                                                CRUISE=="1609" ~ 2016))
    #HAUL_NWFSC<-mutate(HAUL_NWFSC, YEAR=ifelse(!is.na(HAUL_DATE), YEAR, as.numeric(substr(CRUISE,1,2))+2000)) #also works

    #join HAUL and standard station info, filter
    #NWFSC stations in RREAS table
    HAULSTANDARD_NWFSC_RREAS<-dplyr::inner_join(HAUL, standardstations_NWFSC, by="STATION") %>%
      dplyr::filter(STANDARD_STATION==1) %>%
      dplyr::mutate(SURVEY="RREAS") %>%
      dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                    LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)
    #NWFSC and RREAS stations in NWFSC table
    HAULSTANDARD_NWFSC<-dplyr::inner_join(HAUL_NWFSC, rbind(standardstations,standardstations_NWFSC), by="STATION") %>%
      dplyr::filter(STANDARD_STATION==1) %>%
      dplyr::mutate(SURVEY="NWFSC") %>%
      dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                    LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)
    HAULSTANDARD_NWFSC<<-rbind(HAULSTANDARD_NWFSC,HAULSTANDARD_NWFSC_RREAS) %>%
      dplyr::arrange(YEAR)
  }

  RODBC::odbcCloseAll()
  rm(channel)

  #ATSEA data, combine with RREAS main
  if(!is.null(atsea_path)) {

    if(!file.exists(atsea_path)) {
      stop("At sea database not found. Check that the file path is correct.")
    }

    channel <- RODBC::odbcConnectAccess2007(atsea_path)
    HAUL_ATSEA <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_HAUL", as.is=1, stringsAsFactors = F)
    CATCH_ATSEA <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_CATCH", as.is=1, stringsAsFactors = F)
    LENGTH_ATSEA <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_LENGTH", as.is=1, stringsAsFactors = F)
    RODBC::odbcCloseAll()
    rm(channel)

    #convert coords to dd
    HAUL_ATSEA$NET_IN_LATDD<-convertdd(HAUL_ATSEA$NET_IN_LAT)
    HAUL_ATSEA$NET_IN_LONDD<-(-convertdd(HAUL_ATSEA$NET_IN_LONG))
    #add year, month, and julian day
    HAUL_ATSEA$YEAR<-lubridate::year(HAUL_ATSEA$HAUL_DATE)
    HAUL_ATSEA$MONTH<-lubridate::month(HAUL_ATSEA$HAUL_DATE)
    HAUL_ATSEA$JDAY<-lubridate::yday(HAUL_ATSEA$HAUL_DATE)

    #round lengths to nearest mm
    LENGTH_ATSEA$STD_LENGTH<-round(LENGTH_ATSEA$STD_LENGTH,digits=0)

    #join HAUL and standard station info, filter
    HAULSTANDARD_ATSEA<-dplyr::inner_join(HAUL_ATSEA, standardstations, by="STATION") %>%
      dplyr::arrange(YEAR) %>%
      dplyr::filter(STANDARD_STATION==1) %>%
      dplyr::mutate(SURVEY="RREAS") %>%
      dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                    LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)
    HAULSTANDARD<<-rbind(HAULSTANDARD,HAULSTANDARD_ATSEA)
    CATCH<<-rbind(CATCH,CATCH_ATSEA)
    LENGTH<<-rbind(LENGTH,LENGTH_ATSEA)
  }

  #krill length data
  if(!is.null(krill_len_path)) {

    if(!file.exists(krill_len_path)) {
      stop("Krill length file not found. Check that the file path is correct.")
    }

    krill_length<<-read.csv(krill_len_path, stringsAsFactors = F)
  }
  return(cat("Data loaded."))
}

#' Load RREAS data from ERDDAP
#'
#' Loads the HAUL, CATCH, LENGTH, and SPECIES_CODES tables from the RREAS survey
#' as currently stored in NOAA's ERDDAP database. These are reformatted as
#' relational tables to match the format of the tables in the database. This
#' dataset contains data from 1990 to 2018 and only from standard, active
#' stations. The function also loads a HAULSTANDARD table with a standardized
#' set of columns including YEAR, MONTH, JDAY, and lat/lon in decimal degrees.
#' See [`RREAS_ERDDAP`] for metadata. This function has no arguments.
#'
#' @details
#' The data tables are stored internally in the package (internet
#' connection is not required). The maintainers will update the package data
#' whenever the data on ERDDAP is updated.
#'
#' As all hauls on ERDDAP are from standard, active stations, HAUL and
#' HAULSTANDARD will have the same number of rows. HAULSTANDARD will have some
#' additional columns and the columns will be in a different order. This is just
#' to match the HAULSTANDARD table generated from the database.
#'
#' This dataset (unlike the database) contains additional SPECIES/MATURITY
#' categories 1472/T (total krill) and 1940/T (total rockfish). These export
#' as NaN from ERDDAP (prior to 2016), but are corrected here.
#'
#' Abundance (including abundance with size limits) and size distributions can
#' be obtained from this dataset using [`get_totals`] and [`get_distributions`].
#'
#' The WEIGHT and AGE tables are not included, so requests for biomass, age
#' standardized abundance, mass distributions, or age distributions will be
#' unsuccessful.
#'
#'
#' @return Tables are written to the global environment (and will overwrite any existing tables
#'   with the same names). Diplays "Data loaded" if successful.
#' @export
#' @references Sakuma, K.M., Field, J.C., Mantua, N.J., Ralston, S., Marinovic,
#'   B.B. and Carrion, C.N. (2016) Anomalous epipelagic micronekton assemblage patterns
#'   in the neritic waters of the California Current in spring 2015 during a
#'   period of extreme ocean conditions. CalCOFI Rep. 57:163-183
#' @seealso [`load_mdb`], [`RREAS_ERDDAP`]
#' @keywords functions
#' @examples
#' load_erddap()
#'
load_erddap=function() {
  HAUL <<- HAUL_ERDDAP
  HAULSTANDARD <<- HAULSTANDARD_ERDDAP
  CATCH <<- CATCH_ERDDAP
  LENGTH <<- LENGTH_ERDDAP
  SPECIES_CODES <<- SPECIES_CODES_ERDDAP
  return(cat("Data loaded."))
}

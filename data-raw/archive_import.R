#Import archived data to package (from Access database used to generate Dryad csv files)

library(dplyr)
library(RODBC)
dbpath <- "C:/Rogers/Documents/Rockfish/RREAS/Survey data/database paper/RREAS database JUN2026.accdb"
channel <- RODBC::odbcConnectAccess2007(dbpath)
CTD_HEADER<-RODBC::sqlQuery(channel, "SELECT * FROM dbo_CTD_HEADER", stringsAsFactors = F, as.is=1)
CTD_CAST<-RODBC::sqlQuery(channel, "SELECT * FROM dbo_CTD_CAST", stringsAsFactors = F, as.is=1)
NET_MENSURATION<-RODBC::sqlQuery(channel, "SELECT * FROM dbo_NET_MENSURATION", stringsAsFactors = F, as.is=1)

usethis::use_data(CTD_CAST, overwrite = TRUE)
usethis::use_data(CTD_HEADER, overwrite = TRUE)
usethis::use_data(NET_MENSURATION, overwrite = TRUE)

STATIONS_RREAS <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_STANDARD_STATIONS", stringsAsFactors = F)
SPECIES_CODES_RREAS <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_SPECIES_CODES", stringsAsFactors = F)
HAUL_RREAS <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_HAUL", as.is=1, stringsAsFactors = F)
CATCH_RREAS <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_CATCH", as.is=1, stringsAsFactors = F)
LENGTH_RREAS <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_LENGTH", as.is=1, stringsAsFactors = F)
WEIGHT_RREAS <- RODBC::sqlQuery(channel, "SELECT * FROM dbo_JUV_WEIGHT", as.is=1, stringsAsFactors = F)

RODBC::odbcCloseAll()

usethis::use_data(STATIONS_RREAS, overwrite = TRUE)
usethis::use_data(SPECIES_CODES_RREAS, overwrite = TRUE)
usethis::use_data(HAUL_RREAS, overwrite = TRUE)
usethis::use_data(CATCH_RREAS, overwrite = TRUE)
usethis::use_data(LENGTH_RREAS, overwrite = TRUE)
usethis::use_data(WEIGHT_RREAS, overwrite = TRUE)

#use DOORS_IN for missing NET_IN position, lag CRUISE 2001
HAUL_RREAS$NET_IN_LAT[is.na(HAUL_RREAS$NET_IN_LAT)]<-HAUL_RREAS$DOORS_IN_LAT[is.na(HAUL_RREAS$NET_IN_LAT)]
HAUL_RREAS$NET_IN_LONG[is.na(HAUL_RREAS$NET_IN_LONG)]<-HAUL_RREAS$DOORS_IN_LONG[is.na(HAUL_RREAS$NET_IN_LONG)]

#rename lat lon (no conversion needed)
STATIONS_RREAS$LATDD<-STATIONS_RREAS$LATITUDE
STATIONS_RREAS$LONDD<-STATIONS_RREAS$LONGITUDE
HAUL_RREAS$NET_IN_LATDD<-HAUL_RREAS$NET_IN_LAT
HAUL_RREAS$NET_IN_LONDD<-HAUL_RREAS$NET_IN_LONG
#add year, month, and julian day
HAUL_RREAS$YEAR<-lubridate::year(HAUL_RREAS$HAUL_DATE)
HAUL_RREAS$MONTH<-lubridate::month(HAUL_RREAS$HAUL_DATE)
HAUL_RREAS$JDAY<-lubridate::yday(HAUL_RREAS$HAUL_DATE)

#join HAUL and standard station info, filter
HAULSTANDARD_RREAS<-dplyr::inner_join(HAUL_RREAS, STATIONS_RREAS, by="STATION") %>%
  dplyr::arrange(YEAR) %>%
  dplyr::filter(STANDARD_STATION==1) %>%
  dplyr::mutate(SURVEY="RREAS") %>%
  dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)

usethis::use_data(HAULSTANDARD_RREAS, overwrite = TRUE)

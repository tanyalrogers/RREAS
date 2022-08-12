#Download and save ERDDAP data to package
#  Takes SPECIES_CODES table from database
#  Formats data into relations tables, as in database

library(dplyr)
library(tidyr)
library(lubridate)

load_mdb(mdb_path = "E:/Documents/NMFS laptop/Rockfish/RREAS/Survey data/juv_cruise_backup27JAN21.mdb",
         datasets = "RREAS",
         activestationsonly = T)

#save species codes table
SPECIES_CODES_ERDDAP <- SPECIES_CODES
usethis::use_data(SPECIES_CODES_ERDDAP, overwrite = TRUE)

#haul and catch data

download.file(url="https://oceanview.pfeg.noaa.gov/erddap/tabledap/FED_Rockfish_Catch.csv?time%2Clatitude%2Clongitude%2Ccruise%2Chaul_no%2Cvessel%2Cstation%2Ccatch%2Cspecies_code%2Cmaturity%2Cstation_latitude%2Cstation_longitude%2Cstation_bottom_depth%2Carea%2Cstrata%2Cbottom_depth%2Cstation_active&time%3E=1990-05-13&time%3C=2018-06-21T21%3A52%3A29Z",
              destfile = "data-raw/erddap_catch.csv")

# have to set end date 1 day later, or last haul does not download
download.file(url="https://oceanview.pfeg.noaa.gov/erddap/tabledap/FED_Rockfish_Catch.csv?time%2Clatitude%2Clongitude%2Ccruise%2Chaul_no%2Cvessel%2Cstation%2Ccatch%2Cspecies_code%2Ccommon_name%2Csci_name%2Cspecies_group%2Cmaturity%2Cspecies_notes%2Caphiaid%2Cmatch_type%2Clsid%2Cstation_latitude%2Cstation_longitude%2Cctd_index%2Cstation_bottom_depth%2Carea%2Cstrata%2Ctdr_depth%2Cdepth_strata%2Cbottom_depth%2Cstation_active%2Cstation_notes&time%3E=2018-01-01&time%3C=2018-06-21T21%3A52%3A29Z",
              destfile = "data-raw/erddap_catch_test.csv")

cnames=names(read.csv("data-raw/erddap_catch.csv", stringsAsFactors = F, header = T, nrows = 1))
CATCH_HAUL_ERDDAP=read.csv("data-raw/erddap_catch.csv", stringsAsFactors = F, header = T, skip = 1, col.names = toupper(cnames), colClasses = c("CRUISE"="character"))
CATCH_ERDDAP=select(CATCH_HAUL_ERDDAP, CRUISE, HAUL_NO, SPECIES=SPECIES_CODE, MATURITY, TOTAL_NO=CATCH) %>%
  filter(TOTAL_NO>0)
HAUL_ERDDAP=select(CATCH_HAUL_ERDDAP, CRUISE, HAUL_NO, VESSEL, STATION, HAUL_DATE=TIME, NET_IN_LATDD=LATITUDE, NET_IN_LONDD=LONGITUDE, BOTTOM_DEPTH, LATDD=STATION_LATITUDE, LONDD=STATION_LONGITUDE, STATION_BOTTOM_DEPTH, STRATA, AREA, ACTIVE=STATION_ACTIVE) %>%
  group_by(CRUISE, HAUL_NO) %>% slice(1) %>% as.data.frame()

#fix total krill and total rockfish
krillind=which(is.nan(CATCH_ERDDAP$SPECIES) & CATCH_ERDDAP$MATURITY=="U")
rfind=which(is.nan(CATCH_ERDDAP$SPECIES) & CATCH_ERDDAP$MATURITY=="Y")
CATCH_ERDDAP$SPECIES[krillind] <- 1472
CATCH_ERDDAP$MATURITY[krillind] <- "T"
CATCH_ERDDAP$SPECIES[rfind] <- 1940
CATCH_ERDDAP$MATURITY[rfind] <- "T"


usethis::use_data(CATCH_ERDDAP, overwrite = TRUE)
usethis::use_data(HAUL_ERDDAP, overwrite = TRUE)

#test for discrepancies
test=filter(HAULSTANDARD, YEAR>=1990 & YEAR <=2018)
table(HAUL_ERDDAP$CRUISE)
table(test$CRUISE)
anti_join( test[,c("CRUISE","HAUL_NO")], HAUL_ERDDAP[,c("CRUISE","HAUL_NO")])
#there is one extra haul in the database that's not on erddap (1802 haul 135)

#haulstandard table

#add year, month, and julian day
HAUL_ERDDAP$HAUL_DATE<-lubridate::ymd_hms(HAUL_ERDDAP$HAUL_DATE)
HAUL_ERDDAP$YEAR<-lubridate::year(HAUL_ERDDAP$HAUL_DATE)
HAUL_ERDDAP$MONTH<-lubridate::month(HAUL_ERDDAP$HAUL_DATE)
HAUL_ERDDAP$JDAY<-lubridate::yday(HAUL_ERDDAP$HAUL_DATE)

HAULSTANDARD_ERDDAP <- HAUL_ERDDAP %>%
  dplyr::mutate(SURVEY="RREAS") %>%
  dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE)

usethis::use_data(HAULSTANDARD_ERDDAP, overwrite = TRUE)

#length data
download.file(url="https://oceanview.pfeg.noaa.gov/erddap/tabledap/FED_Rockfish_Length.csv?cruise%2Chaul_no%2Cstd_length%2Cspecies_code%2Cmaturity&time%3E=1990-05-13&time%3C=2018-06-21T21%3A52%3A29Z",
              destfile = "data-raw/erddap_length.csv")

cnames2=names(read.csv("data-raw/erddap_length.csv", stringsAsFactors = F, header = T, nrows = 1))
LENGTH_ERDDAP=read.csv("data-raw/erddap_length.csv", stringsAsFactors = F, header = T, skip = 1, col.names = toupper(cnames2), colClasses = c("CRUISE"="character"))
LENGTH_ERDDAP=LENGTH_ERDDAP %>% rename(SPECIES=SPECIES_CODE)

usethis::use_data(LENGTH_ERDDAP, overwrite = TRUE)

#more tests
test1=filter(CATCH, CRUISE=="1405", HAUL_NO==39)
test2=filter(CATCH_ERDDAP, CRUISE=="1405", HAUL_NO==39)

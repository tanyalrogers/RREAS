library(RREAS)
library(dplyr)

load_mdb(mdb_path="C:/Users/trogers/Documents/Rockfish/RREAS/Survey data/juv_cruise_backup10JAN24.mdb", activestationsonly = F)

table(HAUL$DEPTH_STRATA)

haul2=subset(HAUL, DEPTH_STRATA!=4 & !is.na(STATION)) %>%
  #remove depth strata 2 and standard station 0
  subset(!(STANDARD_STATION==0 & DEPTH_STRATA==2)) %>%
  #for depth strata 1,3 keep only hauls with problem code 0 or 2
  subset(!(DEPTH_STRATA %in% c(1,3) & !PROBLEM %in% c(0,2))) %>%
  mutate(CRUISE_HAUL=paste(CRUISE,HAUL_NO,sep = "_"),
         CRUISE_STATION_SWEEP=paste(CRUISE,STATION,SWEEP,sep = "_"))

towscounts = haul2 %>%
  group_by(CRUISE, STATION, SWEEP, CRUISE_STATION_SWEEP) %>%
  summarise(ustrata=length(unique(DEPTH_STRATA)),
            ntows=n(),
            diff=ntows-ustrata,
            consec=max(diff(HAUL_NO), na.rm = T),
            timerange=difftime(max(NET_IN_TIME), min(NET_IN_TIME), units = "hours")) %>%
  #remove sweeps with only 1 tow
  filter(ustrata>1) %>%
  mutate(flag=ifelse(diff>0 | consec >1 | timerange > 2 | is.na(timerange), 1, 0))

haul3 = haul2 %>%
  filter(CRUISE_STATION_SWEEP %in% towscounts$CRUISE_STATION_SWEEP) %>%
  select(CRUISE, HAUL_NO, CRUISE_HAUL, STATION, CRUISE_STATION_SWEEP, SWEEP, DEPTH_STRATA, PROBLEM, STANDARD_STATION, CTD_INDEX, HAUL_DATE, NET_IN_TIME) %>%
  left_join(towscounts) %>% arrange(CRUISE, HAUL_NO)

write.csv(haul3,"data-raw/depth_stratified_raw.csv", row.names = F)

#Needed to manually classify cases where sweep is NA (2005 onwards, coastwide sampling so no more
#sweeps), and where there are more tows than depth strata (some not consecutive).

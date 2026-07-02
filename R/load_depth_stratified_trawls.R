#' Extract RREAS depth-stratified trawls
#'
#' Pulls out the subset of depth-stratified trawls from the HAUL table. Creates the table
#' HAULDEPTHSTRATIFED.
#'
#' @details
#'
#' RREAS standard trawls are conducted at 30 m headrope depth (DEPTH_STRATA 2),
#' with the exception of stations with a bottom depth of less than 60 m, which
#' are towed at 10 m headrope depth (DEPTH_STRATA 1). These are the hauls which
#' appear in HAULSTANDARD.
#'
#' Historically, mostly before the coastwide expansion in 2004, multiple depth
#' strata (DEPTH_STRATA 1: 10 m, DEPTH_STRATA 2: 30 m, DEPTH_STRATA 3: 90 m)
#' were sampled in succession at specific stations, mostly at stations 110, 125,
#' 133, and 170, but occassionally others. This function pulls out these
#' depth-stratified trawls into the table HAULDEPTHSTRATIFED. It has the same
#' format as HAULSTANDARD, but with a few extra columns: DEPTH_STRATA, SWEEP (indicates
#' which of the 3 passes the sampling is from; there is generally one set of
#' depth-stratified trawls per sweep, but not always), and SWEEP_SEP (separates cases
#' in which there are multiple sets of depth stratified trawls per sweep, and sets
#' of depth stratified trawls where SWEEP in NA, which occurs after 2004;
#' otherwise equal to SWEEP). Each set of consecutive depth stratified trawls will
#' have a unique CRUISE/STATION/SWEEP_SEP value.
#'
#' HAULDEPTHSTRATIFED can be passed to `get_totals` or `get_distributions` to
#' get catch data from these hauls instead of HAULSTANDARD by supplying it under
#' `haultable`.
#'
#' Depth-stratified trawls are defined as valid trawls at the same station done in
#' succession at more than one depth strata. These are cataloged in the internal table
#' `ds_tows`.
#'
#'
#' @return Table is written to the global environment (and will overwrite any existing tables
#'   with the same names). Diplays "HAULDEPTHSTRATIFED created." if successful.
#' @export
#' @keywords functions
#' @examples
#' load_trawls()
#' load_depth_stratified_trawls()
#' anchovytable <- data.frame(SPECIES=209, MATURITY="A",NAME="Adult Anchovy")
#' anchovyabund <- get_totals(anchovytable, what = "abundance", haultable = HAULDEPTHSTRATIFIED)
#'
load_depth_stratified_trawls=function() {

  #convert positions to decimal degrees
  convertdd <- function(x) {
    DEG <- floor(x/100)
    MIN <- x - DEG*100
    DD <- DEG + MIN/60
    return(DD)
  }

  #use DOORS_IN for missing NET_IN position, lag CRUISE 2001
  HAUL$NET_IN_LAT[is.na(HAUL$NET_IN_LAT)]<-HAUL$DOORS_IN_LAT[is.na(HAUL$NET_IN_LAT)]
  HAUL$NET_IN_LONG[is.na(HAUL$NET_IN_LONG)]<-HAUL$DOORS_IN_LONG[is.na(HAUL$NET_IN_LONG)]

  #convert coords to dd
  HAUL$NET_IN_LATDD<-convertdd(HAUL$NET_IN_LAT)
  HAUL$NET_IN_LONDD<-(-convertdd(HAUL$NET_IN_LONG))

  #add year, month, and julian day
  HAUL$YEAR<-lubridate::year(HAUL$HAUL_DATE)
  HAUL$MONTH<-lubridate::month(HAUL$HAUL_DATE)
  HAUL$JDAY<-lubridate::yday(HAUL$HAUL_DATE)

  stationinfo <- HAULSTANDARD %>%
    dplyr::select(STATION,STATION_BOTTOM_DEPTH,LATDD,LONDD,STRATA,AREA,ACTIVE,SURVEY) %>%
    unique.data.frame()

  HAUL$CRUISE_HAUL=paste(HAUL$CRUISE,HAUL$HAUL_NO,sep = "_")
  HAULDEPTHSTRATIFIED=subset(HAUL, CRUISE_HAUL %in% ds_tows$CRUISE_HAUL)
  HAULDEPTHSTRATIFIED<-HAULDEPTHSTRATIFIED %>%
    dplyr::left_join(stationinfo, by="STATION") %>%
    dplyr::left_join(ds_tows, by = "CRUISE_HAUL") %>%
    dplyr::select(SURVEY,CRUISE,HAUL_NO,YEAR,MONTH,JDAY,HAUL_DATE,STATION,NET_IN_LATDD,NET_IN_LONDD,
                  LATDD,LONDD,BOTTOM_DEPTH,STATION_BOTTOM_DEPTH,STRATA,AREA,ACTIVE,DEPTH_STRATA,SWEEP,SWEEP_SEP) %>%
    dplyr::arrange(YEAR)

  if(any(is.na(HAULDEPTHSTRATIFIED$SURVEY))) {
    message("Note: ", sum(is.na(HAULDEPTHSTRATIFIED$SURVEY)), " trawls at inactive stations omitted. To include, load data with activestationsonly=FALSE.")
  }
  HAULDEPTHSTRATIFIED<<-subset(HAULDEPTHSTRATIFIED, !is.na(SURVEY))

  return(cat("HAULDEPTHSTRATIFED created."))
}

#' Get CPUE index
#'
#' Given an output table from [`get_totals`], calculates the mean log(CPUE+1)
#' for each YEAR and NAME. Allows an optional grouping variable (e.g. STRATA).
#'
#' @details
#'
#' If there are multiple hauls at the same station in a given year, these are
#' averaged first, and then all stations means in a given year are averaged.
#'
#' NAs will be filled in for years with no hauls in a given grouping.
#'
#' @param df Data frame output from [`get_totals`].
#' @param var The variable in `df` for which to compute the index, typically "TOTAL_NO"
#'   (default), "BIOMASS", or "N100".
#' @param group Optional grouping variable in `df` for which to compute separate
#'   indices. Typically "STRATA". Multiple grouping variables are allowed.
#' @param standardized Whether or not to compute a scaled index, in addition. Defaults
#'   to TRUE. Scaling is done within groups for each NAME, across years.
#' @param sd Calculate standard deviations and standard errors. This is done after averaging
#'   repeat tows at the same station, so n is the number of stations. Defaults of FALSE.
#'
#' @return A data frame with columns NAME, YEAR, any grouping variables, and an index.
#'
#' @export
#' @keywords functions
#' @examples
#' \dontrun{
#' rockfish100equiv <- get_totals(sptable_rockfish100, what = "100day")
#' rockfish100index <- get_logcpueindex(rockfish100equiv, var="N100", group="STRATA")
#' }
get_logcpueindex <- function(df, var="TOTAL_NO", group=NULL, standardized=TRUE, sd=FALSE) {
  if(any(is.na(df$STATION))) {
    stop("Data has missing STATION numbers, please fill in values.",
         "\ne.g. df$STATION=ifelse(is.na(df$STATION),paste0(df$CRUISE,df$HAUL_NO),df$STATION)")
  }
  #df$STATION=ifelse(is.na(df$STATION),paste0(df$CRUISE,df$HAUL_NO),df$STATION)
  if(is.null(group)) {
    f1 <- as.formula(paste(var, "~ YEAR+STATION+NAME"))
    f2 <- as.formula(paste(var, "~ YEAR+NAME"))
  } else {
    f1 <- as.formula(paste(var, "~", paste("YEAR+STATION",group,"NAME",sep="+",collapse = "+")))
    f2 <- as.formula(paste(var, "~", paste("YEAR",group,"NAME",sep="+",collapse = "+")))
  }
  sum1 <- aggregate(f1, data=df, FUN=function(x) mean(log(x+1)))
  sum2 <- aggregate(f2, data=sum1, FUN=mean)
  colnames(sum2)[which(colnames(sum2)==var)] <- paste0(var,"_INDEX")
  if(sd) {
    sd2 <- aggregate(f2, data=sum1, FUN=stats::sd)
    colnames(sd2)[which(colnames(sd2)==var)] <- paste0(var,"_INDEX_SD")
    sum2 <- cbind(sum2,sd2[,paste0(var,"_INDEX_SD"),drop=F])
    sd3 <- aggregate(f2, data=sum1, FUN=function(x) stats::sd(x)/sqrt(length(x)))
    colnames(sd3)[which(colnames(sd3)==var)] <- paste0(var,"_INDEX_SE")
    sum2 <- cbind(sum2,sd3[,paste0(var,"_INDEX_SE"),drop=F])
  }
  #fill in missing years
  if(is.null(group)) {
    sum2 <- tidyr::complete(sum2, NAME, YEAR=tidyr::full_seq(YEAR, period = 1))
  } else {
    sum2 <- tidyr::complete(sum2, NAME, .data[[group]], YEAR=tidyr::full_seq(YEAR, period = 1))
  }
  if(standardized) {
    var2=paste0(var,"_INDEX")
    #well this is a pain in the ass
    sum2 <- sum2 %>% dplyr::group_by(sum2[c(group,"NAME")]) %>%
      dplyr::mutate("{paste0(var2,'_SC')}" := (.data[[var2]]-mean(.data[[var2]], na.rm=T))/sd(.data[[var2]], na.rm=T)) %>%
      dplyr::ungroup() %>% as.data.frame()
  }
  return(sum2)
}

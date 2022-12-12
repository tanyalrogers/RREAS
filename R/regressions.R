#' Get length-weight regression
#'
#' Runs a length-weight regression using data in the WEIGHT table and outputs a
#' function to convert lengths into weights. This function (and the outputed
#' function) are used internally in [`get_totals`] and [`get_distributions`] but
#' it can be called independently, e.g. if you want to see what the regressions
#' look like.
#'
#' @details
#'
#' This fits a linear regression to log-log data. The outputed conversion
#' function will do the transformations and backtransformations automatically, so
#' the inputed lengths should be in the original units (mm).
#'
#' Length-weight regressions can be done for all species in the WEIGHT table
#' (run `unique(WEIGHT$SPECIES)` for a list) and for all species in
#' [`sptable_lw`].
#'
#' The rockfishes are divided into 4 groups given in table [`rflwgroups`]. The
#' groups are based on general body shape and similarity of regression
#' intercepts. Within a given group, species with length-weight data are pooled,
#' and the regression is used for all species in that group, including those
#' without length-weight data. Thus the species with data act as proxies for
#' species without data.
#'
#' For anchovy (209), adults (A) and juveniles (Y) are pooled for the
#' regression.
#'
#' For northern lampfish (661) and California lanternfish (669), data from both
#' species are pooled for the regression. Unknown myctophids (407) will use
#' this regression.
#'
#' For octopus (2026), which has weight but no length data, the mean weight is
#' used.
#'
#' This function includes and will use published length-weight regressions for
#' select species not in the WEIGHT table. These species are sardine (562), T.
#' spinfera (1473, also used by 1791), and E. pacifica (1816, also used by 1847,
#' as well as 1472, 1846, 2829, 2830, 2835, 2849 assumed to be the mean size of
#' all measured krill).
#'
#' If the function is unable to generate a regression for the input species, a
#' warning will be displayed and the resulting function will return NA for any
#' length input.
#'
#' @param species Species code
#' @param maturity Maturity code
#' @param plot Logical. Whether to produce a plot (logical). Plots will not be
#'   produced for published regressions, just ones fit using the WEIGHT data.
#'
#' @return A function which takes a vector of lengths (mm) as input, and returns
#'   a vector of masses (g).
#'
#' @seealso [`sptable_lw`], [`rflwgroups`]
#' @export
#' @keywords functions
#' @examples
#' print(rflwgroups)
#' \dontrun{
#' get_lw_regression(species = 209, maturity = "A", plot=T)
#' get_lw_regression(species = 562, maturity = "A")
#' }
get_lw_regression=function(species, maturity, plot=F){

  if(!exists("WEIGHT")) {
    stop("WEIGHT table required to obtain length-weight regression")
  }

  if(species %in% unique(rflwgroups$SPECIES)) { #if species in rf table
    proxyspp<-rflwgroups$SPECIES[which(rflwgroups$RFGROUP==rflwgroups$RFGROUP[which(rflwgroups$SPECIES==species)])]
    fwts<-subset(WEIGHT,SPECIES %in% proxyspp & MATURITY==maturity)
    len_reg<-lm(log(WEIGHT)~log(STD_LENGTH), data=fwts)
    len_to_wt<-function(length) {
      exp(predict(len_reg, newdata = data.frame(STD_LENGTH=length)))
    }
  } else if(species %in% c(1473,1791)) { #T.spinifera and congeners
    len_to_wt<-function(length) {
      4.76007*(0.004*length^2.81)/1000
    }
  } else if(species %in% c(1816,1472,1846,1847,2829,2830,2835,2849)) { #E.pacifica (1816) and similar species
    len_to_wt<-function(length) {
      4.76007*(0.0008*length^3.19)/1000
    }
  } else if(species==2026) { #optopus (no length data, just use mean weight)
    fwts<-subset(WEIGHT,SPECIES==species & MATURITY==maturity)
    mean_len=mean(fwts$WEIGHT)
    len_to_wt<-function(length) {
      mean_len
    }
  } else if(species==562) { #sardine (regression from 2019 assessment)
    len_to_wt<-function(length) {
      0.0000075252*length^3.232205
    }
  } else if(species==209) { #anchovy (combine A and Y lengths)
    fwts<-subset(WEIGHT,SPECIES==species)
    len_reg<-lm(log(WEIGHT)~log(STD_LENGTH), data=fwts)
    len_to_wt<-function(length) {
      exp(predict(len_reg, newdata = data.frame(STD_LENGTH=length)))
    }
  } else if(species %in% c(407,661,669)) { #N lampfish, CA lanternsfish, unknown myctophid
    fwts<-subset(WEIGHT,SPECIES %in% c(661,669))
    len_reg<-lm(log(WEIGHT)~log(STD_LENGTH), data=fwts)
    len_to_wt<-function(length) {
      exp(predict(len_reg, newdata = data.frame(STD_LENGTH=length)))
    }
  } else if(species %in% unique(WEIGHT$SPECIES)) { #if species in main table
    fwts<-subset(WEIGHT,SPECIES==species & MATURITY==maturity)
    len_reg<-lm(log(WEIGHT)~log(STD_LENGTH), data=fwts)
    len_to_wt<-function(length) {
      exp(predict(len_reg, newdata = data.frame(STD_LENGTH=length)))
    }
  } else {
    warning(paste("Length-weight information not available for species", species, maturity))
    len_to_wt<-function(length) {
      NA
    }
  }

  #make plot
  if(plot & species %in% unique(WEIGHT$SPECIES) & species!=2026) {
    par(mfrow=c(1,2))
    plot(WEIGHT~STD_LENGTH, data=fwts, main=species)
    plot(log(WEIGHT)~log(STD_LENGTH), data=fwts, main=species)
    abline(len_reg)
  }

  return(len_to_wt)
}

#' Get length-age regressions
#'
#' Runs length-age regressions using data in the AGE table and outputs a
#' function to convert lengths into ages. This function (and the outputed
#' function) are used internally in [`get_totals`] and [`get_distributions`] but
#' it can be called independently, e.g. if you want to see what the
#' regressions look like.
#'
#' @details
#'
#' This fits standard linear regressions. Calling this functions runs the
#' regressions for all available species.
#'
#' Length-age regressions can be done for all species in the AGE table. Run
#' `unique(AGE$SPECIES)` for a list. These include all the rockfishes in
#' [`sptable_rockfish100`], as well as YOY hake (382) and YOY lingcod (448).
#'
#' The rockfish model uses data from all species. It fits a slope for each
#' species, and intercepts for each year. The mean intercept is used for
#' missing years.
#'
#' The hake model has a unique slope and intercept for each year. For missing
#' years, the slope and intercept from the pooled data (all years) is used.
#'
#' For the lingcod model, which has only 1 year of data, there is a single
#' slope and intercept used for all years.
#'
#' If the resulting function is unable to generate a regression for the input species, a
#' warning will be displayed and the function will return NA for any
#' length input.
#'
#'
#' @return A function which takes a species code, vector of years, and vector of
#'   lengths (mm) as input, and returns a vector of ages (days).
#'
#' @export
#' @keywords functions
#' @examples
#' \dontrun{
#' len_to_age = get_la_regression()
#' }
get_la_regression=function() {

  if(!exists("AGE")) {
    stop("AGE table required to obtain length-age regression")
  }

  AGEsub <- AGE %>%
    # remove records with missing age and fish <20mm
    dplyr::filter(!is.na(AGE) & STD_LENGTH >= 20) %>%
    #add year column
    dplyr::mutate(YEAR=as.numeric(substring(CRUISE,1,2)),
                  YEAR=ifelse(YEAR<80,YEAR+2000,YEAR+1900)) %>%
    #convert SPECIES and YEAR to factor
    dplyr::mutate(YEAR=factor(YEAR),SPECIES=factor(SPECIES))

  rockfishes <- AGEsub %>%
    dplyr::filter(SPECIES %in% sptable_rockfish100$SPECIES)
  lingcod <- AGEsub %>%
    dplyr::filter(SPECIES %in% 448)
  hake <- AGEsub %>%
    dplyr::filter(SPECIES %in% 382)

  # ggplot(rockfishes,aes(x=STD_LENGTH, y=AGE, color=YEAR)) +
  #   #facet_wrap(~SPECIES) +
  #   geom_point() +
  #   geom_smooth(method = "lm", se = F)
  # ggplot(rockfishes,aes(x=STD_LENGTH, y=AGE, color=SPECIES)) +
  #   #facet_wrap(~SPECIES) +
  #   geom_point() +
  #   geom_smooth(method = "lm", se = F)
  # ggplot(lingcod,aes(x=STD_LENGTH, y=AGE, color=YEAR)) +
  #   geom_point() +
  #   geom_smooth(method = "lm", se = F)
  # ggplot(hake,aes(x=STD_LENGTH, y=AGE, color=YEAR)) +
  #   geom_point() +
  #   geom_smooth(method = "lm", se = F)

  ##rockfishes

  #slope for each species, intercepts vary by year
  #use mean intercept for missing years
  rockfishlm <- lm(AGE~SPECIES:STD_LENGTH+YEAR+0, data=rockfishes)
  #summary(rockfishlm)

  years=unique(HAULSTANDARD$YEAR)
  nyrs=length(years)

  # Store slope and intercept estimates
  agelm.ints <- dummy.coef(rockfishlm)[[1]]
  slp.vec <- dummy.coef(rockfishlm)[[2]]
  intdf=data.frame(YEAR=as.numeric(names(agelm.ints)),intercept=agelm.ints)
  slopedf=data.frame(SPECIES=as.numeric(names(slp.vec)),slope=slp.vec)

  rfcoeftab <- expand.grid(YEAR=years,SPECIES=sptable_rockfish100$SPECIES)
  rfcoeftab <- rfcoeftab %>% dplyr::left_join(intdf,by="YEAR") %>% dplyr::left_join(slopedf,by="SPECIES") %>%
    # replace missing years with mean of intercepts
    dplyr::mutate(intercept=ifelse(is.na(intercept),mean(agelm.ints),intercept))

  ##hake

  #slopes and intercepts for each year
  hakelm <- lm(AGE~STD_LENGTH:YEAR+YEAR+0, data=hake)
  summary(hakelm)
  #universal slope
  hakelm2 <- lm(AGE~STD_LENGTH, data=hake)
  summary(hakelm2)

  # Store slope and intercept estimates
  year.ints <- dummy.coef(hakelm)[[1]]
  year.slp <- dummy.coef(hakelm)[[2]]
  hakedf=data.frame(YEAR=as.numeric(names(year.ints)),intercept=year.ints,slope=year.slp)

  hakecoeftab <- data.frame(YEAR=years)
  hakecoeftab <- hakecoeftab %>% dplyr::left_join(hakedf,by="YEAR") %>%
    # replace missing years int and slope of universal model
    dplyr::mutate(intercept=ifelse(is.na(intercept),coef(hakelm2)[1],intercept),
                  slope=ifelse(is.na(slope),coef(hakelm2)[2],slope))

  ##lingcod

  #simple regression (1 slope, 1 intercept), only 1 year of data
  lingcodlm <- lm(AGE~STD_LENGTH, data=lingcod)
  #summary(lingcodlm)

  #prepare function
  len_to_age=function(species, year, length) {

    if(species==448) { #lingcod
      ages=predict(lingcodlm, newdata=data.frame(STD_LENGTH=length))
      names(ages)<-NULL
    } else if(species==382) { #hake
      newdata=data.frame(YEAR=year, STD_LENGTH=length)
      # append age-length parameters to catch at length, calculate number of age-100 fish
      newdatajoin <- dplyr::left_join(newdata, hakecoeftab, by=c('YEAR'))
      ages <- with(newdatajoin, intercept + slope*STD_LENGTH)
    } else if(species %in% sptable_rockfish100$SPECIES) { #rockfishes
      newdata=data.frame(SPECIES=species, YEAR=year, STD_LENGTH=length)
      # append age-length parameters to catch at length, calculate number of age-100 fish
      newdatajoin <- dplyr::left_join(newdata, rfcoeftab, by=c('YEAR','SPECIES'))
      ages <- with(newdatajoin, intercept + slope*STD_LENGTH)
    } else {
      warning(paste("Length-age information not available for species", species))
      ages <- rep(NA,times=length(length))
    }
    return(ages)
  }

  return(len_to_age)
}

#' Convert age to 100 day equivalents
#'
#' Convert ages into 100 day equivalents using assumed mortality rate. This
#' function is used internally in [`get_totals`] and [`get_distributions`] but it
#' can be called independently if desired.
#'
#' @details
#'
#' Assumes a natural mortality rate of 0.04 per day. Uses the equation `exp(-0.04*(100-age))`.
#'
#' @param age Vector of ages
#'
#' @return Vector of 100 day equivalents
#'
#' @export
#' @keywords functions
#' @examples
#' age_to_100day(c(90,100,110))
age_to_100day=function(age) {
  exp(-0.04*(100-age))
}

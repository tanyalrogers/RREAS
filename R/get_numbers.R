#' Get total haul-level abundance, biomass, or 100-day standardized abundance
#'
#' Obtains total haul-level abundance, biomass, or 100-day standardized
#' abundance for select species the hauls in HAULSTANDARD. There will be a
#' single entry per haul. Data from multiple species can be obtained with a
#' single function call (see Details).
#'
#' @details
#'
#' If a station was sampled, but the requested species was *not counted* at the
#' time, it will appear as an NA. If the species was counted but was *not
#' present*, it will appear as 0. If the species was counted but the counts
#' numbers are unreliable (the case for some species prior to 1990,
#' presence/absence will still be reliable), a message will be displayed.
#' Description of additional irregularities in species classification can be
#' found in the [`sptable`] documentation (pertains to myctophids, squids,
#' heteropods, smelts, eelpouts, and dragonfish) and in the SPECIES_CODES table.
#' **It your responsibility to know when your focal species were or were not being
#' recorded and how.**
#'
#' Length data are required for "biomass", "100day", and length-specific
#' abundances. If length data are available for a species, but not available for
#' a particular haul where the species was present, mean length values will be
#' used. If available, the mean for the same CRUISE and REGION will be used,
#' followed by CRUISE and STRATA, then CRUISE, then the global mean. In the
#' output table, if TOTAL_NO>0 but NMEAS is 0, this indicates that length data
#' were unavailable and means were used. If size limits are specified, the mean
#' proportion of fish in the length range will also be used for hauls missing
#' length data, with the same rank ordering of available mean values.
#'
#' Biomass is only available for species with length-weight regressions. Species
#' available for biomass estimates are listed in [`sptable_lw`]. See
#' [`get_lw_regression`] (used internally) for more details.
#'
#' 100 day standardized abundance is only available for species with length-age
#' regression. This includes the rockfish species listed in
#' [`sptable_rockfish100`], hake (382) and lingcod (448). See
#' [`get_la_regression`] (used internally) for more details. Note that all
#' species will use the same age-abundance conversion.  See [`age_to_100day`]
#' (used internally) for more details.
#'
#' **Formatting the species table**
#'
#' The structure of the `speciestable` determines which species will be
#' pulled whether multiple species codes should be added together under one
#' category (e.g. total rockfish). It needs to be in a particular format.
#'
#' The package contains several tables already in the correct format, which can
#' be passed directly to the `speciestable` argument, and can be subsetted.
#' [`sptable`] contains a suite of common species for which abundance indices
#' are typically calculated. [`sptable_lw`] contains species for which biomass
#' can be obtained. [`sptable_rockfish100`] contains the rockfish species used
#' to generate the 100 day index, and specifies a min length of 20.
#'
#'
#' The `speciestable` should be a data frame with the following columns:
#' \describe{
#'   \item{SPECIES}{Species code, as in table SPECIES_CODES}
#'   \item{MATURITY}{Maturity code, either "Y", "A", or "U"}
#'   \item{NAME}{Custom name that will be assigned in the output table.
#'      Rows with the same NAME will be combined in the output}
#'   \item{MINLEN}{(Optional) Minimum length in mm (>=).}
#'   \item{MAXLEN}{(Optional) Maximum length in mm (<).}
#'   }
#'
#' Specifying min and/or max lengths is optional. If columns are omitted or values are NA, min
#' length defaults to 0 and max length to Inf (in other words, no constraints).
#'
#' If multiple datasets are specified, these will be combined in the output table (column SURVEY
#' will indicate origin).
#'
#' @param speciestable Dataframe containing species information (see Details).
#' @param datasets Character vector indicating which dataset(s) to use. Multiple dataset can
#'   be specified. Options are "RREAS","ADAMS","PWCC","NWFSC". If unspecified, just uses RREAS.
#' @param startyear Start year (default is 1983).
#' @param what What totals you want, either "abundance","biomass", or "100day".
#'   Defaults to "abundance".
#'
#' @return A dataframe with haul information, NAME, and totals. If "abundance"
#'   is requested, will include column TOTAL_NO. If "biomass" is requested, will
#'   include columns TOTAL_NO, NMEAS (number measured), and BIOMASS (g). If "100day"
#'   is requested, will include columns TOTAL_NO, NMEAS (number measured), and
#'   N100. If size limits are specified, will include additional columns
#'   NMEAS_SIZE (number measured in the size range), and NSIZE (total number in
#'   the size range, which is probably what you want, not TOTAL_NO). If multiple
#'   NAME values were present, the data will be in long format (stacked). If you
#'   request data from multiple datasets, they results will be combined (column
#'   SURVEY differentiates source). The NAME field is converted to a factor so
#'   names will plot in the same order supplied in `speciestable`.
#'
#' @export
#' @seealso [`get_distributions`], [`get_numbers`], [`get_lw_regression`], [`get_la_regression`],
#'   [`age_to_100day`], [`sptable`], [`sptable_lw`], [`sptable_rockfish100`]
#' @keywords functions
#' @examples
#' \dontrun{
#' krillsp=data.frame(SPECIES=c(1473,1816),
#'   MATURITY=c("U","U"),
#'   NAME=c("T. spinifera","E. pacifica"))
#' krillabundance=get_totals(speciestable=krillsp, what="abundance")
#'
#' somebiomasses=get_totals(speciestable=sptable, what="biomass")
#'
#' rockfish100day=get_totals(speciestable=sptable_rockfish100, what="100day",
#'   datasets=c("RREAS","ADAMS","PWCC","NWFSC"))
#' }
get_totals=function(speciestable,datasets="RREAS",startyear=1983,
                    what=c("abundance","biomass","100day")) {
  what=match.arg(what)
  if(what=="abundance") {
    out=get_numbers(speciestable,datasets,startyear,what="abundance",aggregate=TRUE)
  }
  if(what=="biomass") {
    out=get_numbers(speciestable,datasets,startyear,what="biomass",aggregate=TRUE)
  }
  if(what=="100day") {
    out=get_numbers(speciestable,datasets,startyear,what="100day",aggregate=TRUE)
  }
  return(out)
}


#' Get size, mass, or age distribution data
#'
#' Obtains size, mass, or age distribution data for select species for the hauls
#' in HAULSTANDARD. There will be *multiple* entries per haul. Data from
#' multiple species can be obtained with a single function call.
#'
#' @details
#'
#' Biomass distributions are only available for species with length-weight
#' regressions, and age distributions are only available for species with
#' length-age regression. See [`get_totals`] for more details.
#'
#' If a haul had no fish, it will appear in the output dataset (with
#' TOTAL_NO=0). If a haul had fish, but no fish were measured, there will be a
#' TOTAL_NO>0, NMEAS will be 0, and there will be a single length/mass/age entry
#' for that haul, which will be the average values used as a substitute. If a
#' haul has length measurements, there will be multiple entries for that haul,
#' and haul-level information will be repeated.
#'
#' The `speciestable` should be formatted in the same way as described in
#' [`get_totals`].
#'
#' @param speciestable Dataframe containing species information (see Details).
#' @param datasets Character vector indicating which dataset(s) to use. Multiple
#'   dataset can be specified. Options are "RREAS", "ADAMS", "PWCC", "NWFSC". If
#'   unspecified, just uses "RREAS".
#' @param startyear Start year (default is 1983).
#' @param what What type of distribution you want, either "size", "mass", or
#'   "age".
#'
#' @return A dataframe with haul information, NAME, TOTAL_NO, NMEAS (number
#'   measured), EXP (expansion factor), SP_NO (specimen number), and values for
#'   the requested distribution. If "size" is requested, will include column
#'   STD_LENGTH (mm). If "mass" is requested, will include columns STD_LENGTH and
#'   WEIGHT (g). If "age" is requested, will include columns STD_LENGTH, AGE (days), N100i
#'   (number of 100 day equivalents), and JDAY_DOB (julian date of birth). If size
#'   limits are specified, will include additional columns NMEAS_SIZE (number
#'   measured in the size range), PSIZE (proportion of measured fish in the size
#'   range), and NSIZE (total number in the size range, which is probably what
#'   you want, not TOTAL_NO). If multiple NAME values were present, the data
#'   will be in long format (stacked). If you request data from multiple
#'   datasets, they results will be combined (column SURVEY differentiates
#'   source). The NAME field is converted to a factor so names will plot in the
#'   same order supplied in `speciestable`.
#'
#' @export
#' @seealso [`get_totals`], [`get_numbers`], [`get_lw_regression`], [`get_la_regression`],
#'   [`age_to_100day`], [`sptable`], [`sptable_lw`], [`sptable_rockfish100`]
#' @keywords functions
#' @examples
#' \dontrun{
#' rockfish100agedist <- get_distributions(sptable_rockfish100, what = "age")
#' }
get_distributions=function(speciestable,datasets="RREAS",startyear=1983,
                          what=c("size","mass","age")) {
  what=match.arg(what)
  if(what=="size") {
    out=get_numbers(speciestable,datasets,startyear,what="abundance",aggregate=FALSE)
  }
  if(what=="mass") {
    out=get_numbers(speciestable,datasets,startyear,what="biomass",aggregate=FALSE)
  }
  if(what=="age") {
    out=get_numbers(speciestable,datasets,startyear,what="100day",aggregate=FALSE)
  }
  return(out)
}

#' Underlying function for `get_totals` and `get_distributions`
#'
#' Underlying master function for get_totals and get_distributions.
#' It can be called directly, however the other functions may be more intuitive.
#'
#' @details
#'
#' The same set of steps is required to obtain all the various distributions and totals.
#' This function loops through each row of `speciestable`, and simply exits the loop at different
#' points depending on the data requested. The results are stacked, and if totals are requested,
#' results for entries with the same NAME are added together.
#'
#' @param speciestable Dataframe containing species information (see details).
#' @param datasets Character vector indicating which dataset(s) to use. Multiple dataset can
#'   be specified. Options are "RREAS","ADAMS","PWCC","NWFSC". If unspecified, just uses RREAS.
#' @param startyear Start year (default is 1983).
#' @param what Either "abundance","biomass", or "100day".
#' @param aggregate If TRUE, function will produce total abundance if
#'   what="abundance", total biomass if what="biomass", and 100 day standardized
#'   abundance if what="100day". If FALSE, function will produce size
#'   distribution if what="abundance", mass distribution if what="biomass", and
#'   age distribution if what="100day".
#' @return A single dataframe. See [`get_totals`] and [`get_distributions`] for more details.
#' @export
#' @seealso [`get_totals`], [`get_distributions`]
#' @keywords functions
get_numbers=function(speciestable,datasets="RREAS",startyear=1983,
                     what=c("abundance","biomass","100day"),aggregate=TRUE) {
  what=match.arg(what)

  if(!all(datasets %in% c("RREAS","ADAMS","NWFSC","PWCC"))) {
    stop(paste(setdiff(datasets, c("RREAS","ADAMS","NWFSC","PWCC")), collapse = ", "), " is not an available dataset. Must be one or more of the following: 'RREAS','ADAMS','NWFSC','PWCC'")
  }

  #species table lengths
  if("MINLEN" %in% colnames(speciestable) | "MAXLEN" %in% colnames(speciestable)) {
    sizelims=TRUE
  } else {
    sizelims=FALSE
  }
  #create if don't exist
  if(!("MINLEN" %in% colnames(speciestable))) {
    speciestable$MINLEN=0
  }
  if(!("MAXLEN" %in% colnames(speciestable))) {
    speciestable$MAXLEN=Inf
  }
  #if NA, set from to 0 and Inf
  speciestable$MINLEN[is.na(speciestable$MINLEN)]=0
  speciestable$MAXLEN[is.na(speciestable$MAXLEN)]=Inf

  #select datasets
  HAULSTANDARDall=NULL
  LENGTHall=NULL
  CATCHall=NULL
  if("RREAS" %in% datasets) {
    HAULSTANDARDall=rbind(HAULSTANDARDall,HAULSTANDARD)
    LENGTH$SURVEY="RREAS"
    LENGTHall=rbind(LENGTHall,LENGTH)
    CATCH$SURVEY="RREAS"
    CATCHall=rbind(CATCHall,CATCH)
  }
  if("ADAMS" %in% datasets) {
    HAULSTANDARDall=rbind(HAULSTANDARDall,HAULSTANDARD_ADAMS)
    LENGTH_ADAMS$SURVEY="ADAMS"
    LENGTHall=rbind(LENGTHall,LENGTH_ADAMS)
    CATCH_ADAMS$SURVEY="ADAMS"
    CATCHall=rbind(CATCHall,CATCH_ADAMS)
  }
  if("PWCC" %in% datasets) {
    HAULSTANDARDall=rbind(HAULSTANDARDall,HAULSTANDARD_PWCC)
    colnames(LENGTH_PWCC)<-sub("PWCC_","",colnames(LENGTH_PWCC))
    LENGTH_PWCC$SURVEY="PWCC"
    LENGTHall=rbind(LENGTHall,LENGTH_PWCC)
    colnames(CATCH_PWCC)<-sub("PWCC_","",colnames(CATCH_PWCC))
    CATCH_PWCC$SURVEY="PWCC"
    CATCHall=rbind(CATCHall,CATCH_PWCC)
  }
  if("NWFSC" %in% datasets) {
    HAULSTANDARDall=rbind(HAULSTANDARDall,HAULSTANDARD_NWFSC)
    LENGTH_NWFSC$SURVEY="NWFSC"
    LENGTHall=rbind(LENGTHall,LENGTH_NWFSC)
    CATCH_NWFSC$SURVEY="NWFSC"
    CATCHall=rbind(CATCHall,CATCH_NWFSC)
  }

  #subset to start year
  HAULSTANDARDsub=HAULSTANDARDall %>% dplyr::filter(YEAR>=startyear)
  outlist=NULL

  if(what=="100day") { #run length age regressions
    len_to_age = get_la_regression()
  }

  #loop through species in table
  for(i in 1:nrow(speciestable)) {
    fspecies<-speciestable$SPECIES[i]
    fmaturity<-speciestable$MATURITY[i]

    #pull CATCH records of species i
    sptemp=dplyr::filter(CATCHall, SPECIES==fspecies & MATURITY==fmaturity)
    #join to table of standard hauls, fill species info, fill in zeros for hauls with no match
    catchcombo=dplyr::select(HAULSTANDARDsub, SURVEY, YEAR, CRUISE, HAUL_NO, STRATA, AREA) %>%
      dplyr::left_join(sptemp, by = c("SURVEY", "CRUISE", "HAUL_NO")) %>%
      dplyr:: mutate(SPECIES=fspecies, MATURITY=fmaturity,
                     NAME=speciestable$NAME[i], TOTAL_NO=ifelse(is.na(TOTAL_NO),0,TOTAL_NO)) %>%
      dplyr::select(SURVEY, YEAR, CRUISE, HAUL_NO, STRATA, AREA, SPECIES, MATURITY, NAME, TOTAL_NO)

    #set uncounted species to NA
    if(fspecies %in% uncounted$SPECIES) {
      nacruises=uncounted$CRUISE[uncounted$SPECIES==fspecies]
      catchcombo=catchcombo %>%
        dplyr::mutate(TOTAL_NO=ifelse(SURVEY=="RREAS" & CRUISE %in% nacruises, NA, TOTAL_NO))
    }

    #issue message for unreliable counts
    if(fspecies %in% unreliable$SPECIES) {
      tcruises=catchcombo$CRUISE[catchcombo$SURVEY=="RREAS"]
      urcruises=unreliable$CRUISE[unreliable$SPECIES==fspecies]
      if(any(tcruises %in% urcruises)) {
        message("Note: Counts of SPECIES ", fspecies, " in CRUISES ",
                paste(intersect(tcruises, urcruises), collapse = " "), " are unreliable.")
      }
    }

    ### just total adundance
    if(what=="abundance" & sizelims==FALSE & aggregate) {
      outlist[[i]]=catchcombo
      aggvars="TOTAL_NO"
      next
    }

    #get length data for species i
    if(exists("krill_length")) {
      if(fspecies %in% unique(krill_length$SPECIES)) { #krill
        flength<-dplyr::filter(krill_length,SPECIES==fspecies & MATURITY==fmaturity)
        flength$SURVEY<-"RREAS"
        meankrilllength<-mean(krill_length$STD_LENGTH)
      } else { #not krill
        flength<-dplyr::filter(LENGTHall,SPECIES==fspecies & MATURITY==fmaturity)
        meankrilllength<-1 #wont get used, just to stop case_when from choking
      }
    } else {
      flength<-dplyr::filter(LENGTHall,SPECIES==fspecies & MATURITY==fmaturity)
      meankrilllength<-1 #wont get used, just to stop case_when from choking
    }

    flength$STD_LENGTH<-round(flength$STD_LENGTH,digits=0)

    #get total fish measured per trawl (total, size range), expansion factor, prop in size range
    fmeasured<-flength %>% dplyr::group_by(SURVEY,CRUISE,HAUL_NO) %>%
      dplyr::summarise(NMEAS=dplyr::n(),NMEAS_SIZE=length(which(STD_LENGTH>=speciestable$MINLEN[i] & STD_LENGTH<speciestable$MAXLEN[i]))) %>%
      dplyr::ungroup()
    catchcombo<-dplyr::left_join(catchcombo,fmeasured, by = c("SURVEY", "CRUISE", "HAUL_NO")) %>%
      dplyr::mutate(EXP=TOTAL_NO/NMEAS, PSIZE=NMEAS_SIZE/NMEAS, NSIZE=TOTAL_NO*PSIZE,
                    NSIZE=ifelse(TOTAL_NO==0,0,NSIZE),
                    NMEAS=ifelse(!is.na(TOTAL_NO) & is.na(NMEAS), 0, NMEAS),
                    NMEAS_SIZE=ifelse(!is.na(TOTAL_NO) & is.na(NMEAS_SIZE), 0, NMEAS_SIZE))

    #get avg prop in size range to fill in NSIZE, EXP for TOTAL_NO>0 but no length measurements
    catchcombo<-catchcombo %>%
      dplyr::group_by(SURVEY,CRUISE,AREA) %>% dplyr::mutate(MPSIZE_AREA=mean(PSIZE,na.rm = T)) %>% dplyr::ungroup() %>%
      dplyr::group_by(SURVEY,CRUISE,STRATA) %>% dplyr::mutate(MPSIZE_STRATA=mean(PSIZE,na.rm = T)) %>% dplyr::ungroup() %>%
      dplyr::group_by(SURVEY,CRUISE) %>% dplyr::mutate(MPSIZE_CRUISE=mean(PSIZE,na.rm = T)) %>% dplyr::ungroup() %>%
      dplyr::mutate(MPSIZE_GLOBAL=mean(PSIZE,na.rm = T),
                    PSIZE=dplyr::case_when(fspecies==2026 ~ 1,
                                           !is.na(PSIZE) | !is.na(NSIZE) ~ PSIZE,
                                           !is.na(MPSIZE_AREA) ~ MPSIZE_AREA,
                                           !is.na(MPSIZE_STRATA) ~ MPSIZE_STRATA,
                                           !is.na(MPSIZE_CRUISE) ~ MPSIZE_CRUISE,
                                           TRUE ~ MPSIZE_GLOBAL),
                    PSIZE=ifelse(is.na(TOTAL_NO),NA,PSIZE),
                    NSIZE=ifelse(!is.na(NSIZE),NSIZE,TOTAL_NO*PSIZE),
                    EXP=ifelse(is.na(EXP) & !is.na(PSIZE),NSIZE,EXP)) %>%
      dplyr::select(-MPSIZE_AREA,-MPSIZE_STRATA,-MPSIZE_CRUISE,-MPSIZE_GLOBAL) %>%
      as.data.frame()

    ### total abundance with size limits
    if(what=="abundance" & sizelims==TRUE & aggregate) {
      outlist[[i]]=catchcombo
      aggvars=c("TOTAL_NO","NMEAS","NMEAS_SIZE","NSIZE")
      next
    }

    #merge length data (only within size class)
    flength_size<-dplyr::filter(flength, STD_LENGTH>=speciestable$MINLEN[i] & STD_LENGTH<speciestable$MAXLEN[i])
    lengthcatchcombo<-dplyr::left_join(catchcombo,flength_size,by = c("SURVEY", "CRUISE", "HAUL_NO", "SPECIES", "MATURITY"))

    #compute mean lengths for different groupings
    lengthcatchcombo<-lengthcatchcombo %>%
      dplyr::group_by(SURVEY,CRUISE,AREA) %>% dplyr::mutate(MLEN_AREA=mean(STD_LENGTH,na.rm = T)) %>% dplyr::ungroup() %>%
      dplyr::group_by(SURVEY,CRUISE,STRATA) %>% dplyr::mutate(MLEN_STRATA=mean(STD_LENGTH,na.rm = T)) %>% dplyr::ungroup() %>%
      dplyr::group_by(SURVEY,CRUISE) %>% dplyr::mutate(MLEN_CRUISE=mean(STD_LENGTH,na.rm = T)) %>% dplyr::ungroup() %>%
      dplyr::mutate(MLEN_GLOBAL=mean(STD_LENGTH,na.rm = T),
                    MLEN=dplyr::case_when(fspecies==2026 ~ 1, #octopus dummy length
                                          fspecies %in% c(1472,1846,1847,2829,2830,2835,2849,1791) ~ meankrilllength, #length for unid and rare krill
                                          !is.na(MLEN_AREA) ~ MLEN_AREA,
                                          !is.na(MLEN_STRATA) ~ MLEN_STRATA,
                                          !is.na(MLEN_CRUISE) ~ MLEN_CRUISE,
                                          TRUE ~ MLEN_GLOBAL),
                    #fill in values where positive catch but no length data
                    STD_LENGTH=ifelse(is.na(STD_LENGTH) & NSIZE>0, MLEN, STD_LENGTH)) %>%
      dplyr::select(-MLEN_AREA,-MLEN_STRATA,-MLEN_CRUISE,-MLEN_GLOBAL,-MLEN) %>%
      as.data.frame()

    ### length distribution with size limits
    if(what=="abundance" & sizelims==TRUE & !aggregate) {
      outlist[[i]]=lengthcatchcombo
      next
    }
    ### length distribution without size limits (remove some unneccessary cols)
    if(what=="abundance" & sizelims==FALSE & !aggregate) {
      outlist[[i]]=lengthcatchcombo %>% dplyr::select(-NMEAS_SIZE,-PSIZE,-NSIZE)
      next
    }

    if(what=="biomass") {
      #get length weight regression for species i
      len_to_wt<-get_lw_regression(fspecies, fmaturity, plot=F)

      #compute weights
      lengthcatchcombo$WEIGHT<-len_to_wt(lengthcatchcombo$STD_LENGTH)

      ### mass distribution with size limits
      if(sizelims==TRUE & !aggregate) {
        outlist[[i]]=lengthcatchcombo
        next
      }
      ### mass distribution without size limits (remove some unneccessary cols)
      if(sizelims==FALSE & !aggregate) {
        outlist[[i]]=lengthcatchcombo %>% dplyr::select(-NMEAS_SIZE,-PSIZE,-NSIZE)
        next
      }

      #sum total biomass by haul
      biomass<-lengthcatchcombo %>% dplyr::group_by(SURVEY, CRUISE, HAUL_NO) %>%
        dplyr::summarise(BIOMASS=sum(WEIGHT*EXP))
      biomass<-dplyr::left_join(catchcombo,biomass,by = c("SURVEY", "CRUISE", "HAUL_NO")) %>%
        dplyr::mutate(BIOMASS=ifelse(is.na(BIOMASS) & !is.na(TOTAL_NO),0,BIOMASS))

      ### total biomass with size limits
      if(sizelims==TRUE & aggregate) {
        outlist[[i]]=biomass
        aggvars=c("TOTAL_NO","NMEAS","NMEAS_SIZE","NSIZE","BIOMASS")
        next
      }
      ### total biomass without size limits (remove some unneccessary cols)
      if(sizelims==FALSE & aggregate) {
        outlist[[i]]=biomass %>% dplyr::select(-NMEAS_SIZE,-PSIZE,-NSIZE)
        aggvars=c("TOTAL_NO","NMEAS","BIOMASS")
        next
      }
    }

    if(what=="100day") {

      #compute ages from lengths
      lengthcatchcombo$AGE<-len_to_age(fspecies,lengthcatchcombo$YEAR,lengthcatchcombo$STD_LENGTH)

      #compute 100 day equivalents
      lengthcatchcombo$N100i<-age_to_100day(lengthcatchcombo$AGE)

      #get birthdate distribution
      lengthcatchcombo<-dplyr::left_join(lengthcatchcombo,dplyr::select(HAULSTANDARDsub,SURVEY,CRUISE,HAUL_NO,JDAY),by = c("SURVEY", "CRUISE", "HAUL_NO")) %>%
        dplyr::mutate(JDAY_DOB=JDAY-AGE) %>%
        dplyr::select(-JDAY)

      ### age distribution with size limits
      if(sizelims==TRUE & !aggregate) {
        outlist[[i]]=lengthcatchcombo
        next
      }
      ### age distribution without size limits (remove some unneccessary cols)
      if(sizelims==FALSE & !aggregate) {
        outlist[[i]]=lengthcatchcombo %>% dplyr::select(-NMEAS_SIZE,-PSIZE,-NSIZE)
        next
      }

      #sum total N100 by haul
      N100eq<-lengthcatchcombo %>% dplyr::group_by(SURVEY, CRUISE, HAUL_NO) %>%
        dplyr::summarise(N100=sum(N100i*EXP))
      N100eq<-dplyr::left_join(catchcombo,N100eq,by = c("SURVEY", "CRUISE", "HAUL_NO")) %>%
        dplyr::mutate(N100=ifelse(is.na(N100) & !is.na(TOTAL_NO),0,N100))

      ### total N100eq with size limits
      if(sizelims==TRUE & aggregate) {
        outlist[[i]]=N100eq
        aggvars=c("TOTAL_NO","NMEAS","NMEAS_SIZE","NSIZE","N100")
        next
      }
      ### total N100eq (remove some unneccessary cols)
      if(sizelims==FALSE & aggregate) {
        outlist[[i]]=N100eq %>% dplyr::select(-NMEAS_SIZE,-PSIZE,-NSIZE)
        aggvars=c("TOTAL_NO","NMEAS","N100")
        next
      }
    }

  }

  #stack results
  output=dplyr::bind_rows(outlist)

  #sum for species with same NAME field (if aggregate==T)
  if(aggregate) {
    output=output %>% dplyr::group_by(SURVEY, CRUISE, HAUL_NO, YEAR, STRATA, AREA, NAME) %>%
      dplyr::summarise_at(aggvars,sum,na.rm=T) %>% dplyr::ungroup()
  }
  #rejoin to table of standard hauls (info lost during summarizing)
  output=dplyr::left_join(HAULSTANDARDsub, output, by = c("SURVEY", "CRUISE", "HAUL_NO", "YEAR", "STRATA", "AREA")) %>%
    dplyr::arrange(NAME,YEAR)

  #convert to factor, so plot in order supplied
  output$NAME=factor(output$NAME,levels=unique(speciestable$NAME))

  return(output)
}

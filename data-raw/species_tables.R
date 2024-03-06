## code to prepare pre-made species tables

#rockfish for 100 day index
sptable_rockfish100 <- data.frame(SPECIES = c(582,597,599,601,603,604,606,609,612,616,618,627),
                                  MATURITY = "Y",
                                  NAME = c('aur','ent','fla','goo','hop','jor','lev','mel','mys','pau','pin','sax'),
                                  MINLEN = 20,
                                  COMMON = c("Brown","Widow","Yellowtail","Chilipepper","Squarespot","Shortbelly",
                                             "Cowcod", "Black","Blue","Bocaccio","Canary","Stripetail"))

usethis::use_data(sptable_rockfish100, overwrite = TRUE)

#species groups for CCIEA index
rockfishes=data.frame(SPECIES=c(579:636,1940,2355,2437,2375,2381,2805),
                      MATURITY="Y",
                      NAME="YOY Rockfish")
sanddabs=data.frame(SPECIES=c(147,148,150),
                    MATURITY="Y",
                    NAME="YOY Sanddabs")
myctophids=data.frame(SPECIES=c(192,331,407,510,661,669,685,712,2808,2814,2847),
                      MATURITY="U",
                      NAME="Total Myctophids")
krill=data.frame(SPECIES=c(791,1472,1473,1759,1791,1816,1846,1847,2060,2829,2830,2835,2836,2849),
                 MATURITY="U",
                 NAME="Total Krill")
octopus=data.frame(SPECIES=c(2026,2844,2855),
                   MATURITY="U",
                   NAME="Octopus")
otherspecies=data.frame(SPECIES=c(1101,382,209,209,562,562,2058,2468,2393),
                        MATURITY=c("U","Y","A","Y","A","Y","U","U","U"),
                        NAME=c("Market Squid","YOY Pacific Hake","Adult Anchovy","YOY Anchovy","Adult Sardine","YOY Sardine","Pyrosomes","Thetys","Salps"))

sptable=rbind(rockfishes, otherspecies, sanddabs, myctophids, octopus, krill)
#write.csv(speciestable,"data-raw/species_table.csv",row.names = F)
usethis::use_data(sptable, overwrite = TRUE)

#species in sptable, but never caught
setdiff(sptable$SPECIES, SPECIES_CODES$SPECIES)
# krill 791 1759 2060 2836 (not in sptable_lw)
# myctophids 331 510 2808 (not in sptable_lw)
# rockfishes 579 581 585 586 587 588 589 590 591 596 598 600 602 605 608 613 614 617 622 623 625 631 632 633 634

#rockfish length-weight groups
rflwgroups<-read.csv("data-raw/rockfish lw groups.csv", stringsAsFactors = F)
usethis::use_data(rflwgroups, overwrite = TRUE)

#lw regression species
sptable_lw<-read.csv("data-raw/lw species table.csv", stringsAsFactors = F)
usethis::use_data(sptable_lw, overwrite = TRUE)

#species in sptable, but not in sptable_lw
setdiff(sptable$SPECIES, sptable_lw$SPECIES)
# krill 791 1759 2060 2836 (not in sptable_lw)
# myctophids 331 510 2808 2847 (not in sptable_lw)
# octopus  2844 2855
# sanddabs 150
# salps 2393
# rockfishes 632 634

#in lw regression table, but:
#never caught
uncaught=setdiff(sptable_lw$SPECIES, unique(c(CATCH$SPECIES, CATCH_ADAMS$SPECIES, CATCH_NWFSC$SPECIES, CATCH_PWCC$SPECIES)))
caught=intersect(sptable_lw$SPECIES, unique(c(CATCH$SPECIES, CATCH_ADAMS$SPECIES, CATCH_NWFSC$SPECIES, CATCH_PWCC$SPECIES)))
#caught not measured
caught_unmeas=setdiff(caught,unique(c(LENGTH$SPECIES, LENGTH_ADAMS$SPECIES, LENGTH_NWFSC$SPECIES, LENGTH_PWCC$SPECIES)))
caught_meas=intersect(caught,unique(c(LENGTH$SPECIES, LENGTH_ADAMS$SPECIES, LENGTH_NWFSC$SPECIES, LENGTH_PWCC$SPECIES)))

caught_unmeas #ensure there are procedures for dealing with these species
# 2375 2026 1472 1473 1791 1816 1846 1847 2829 2830 2835 2849
# 2375: Blue/widow rockfish complex: only 1 record from CRUISE 8608, counts 0 towards biomass
# 2026: Octopus
# 1816 1847 1473: In krill length table
# 1472 1791 1846 2829 2830 2835 2849: Other krill species
uncaught
# 586 579 581 585 587 588 590 608 613 589 591 596 598 600 602 605 614 617 622 623 625 631 633
# These are all rockfishes

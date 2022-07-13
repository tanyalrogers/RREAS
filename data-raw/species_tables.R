## code to prepare pre-made species tables

#rockfish for 100 day index
sptable_rockfish100 <- data.frame(SPECIES = c(582,597,599,601,603,604,606,609,612,616,618,627),
                                  MATURITY = "Y",
                                  NAME = c('aur','ent','fla','goo','hop','jor','lev','mel','mys','pau','pin','sax'),
                                  MINLEN = 20,
                                  COMMON = c("Brown","Widow","Yellowtail","Chilipepper","Squarespot","Shortbelly",
                                             "Cowcod", "Black","Blue","Bocaccio","Canary","Stripetail"))

usethis::use_data(sptable_rockfish100, overwrite = TRUE)

#all species groups to date
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
otherspecies=data.frame(SPECIES=c(1101,382,209,209,562,562),
                        MATURITY=c("U","Y","A","Y","A","Y"),
                        NAME=c("Market Squid","YOY Pacific Hake","Adult Anchovy","YOY Anchovy","Adult Sardine","YOY Sardine"))

sptable=rbind(rockfishes, otherspecies, sanddabs, myctophids, octopus, krill)
#write.csv(speciestable,"data-raw/species_table.csv",row.names = F)
usethis::use_data(sptable, overwrite = TRUE)

#rockfish length-weight groups
rflwgroups<-read.csv("data-raw/rockfish lw groups.csv", stringsAsFactors = F)
usethis::use_data(rflwgroups, overwrite = TRUE)

#lw regression species
sptable_lw<-read.csv("data-raw/lw species table.csv", stringsAsFactors = F)
usethis::use_data(sptable_lw, overwrite = TRUE)


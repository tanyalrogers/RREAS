
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RREAS

<!-- badges: start -->
<!-- badges: end -->

This package contains data and support functions for the NOAA SWFSC
Rockfish Recruitment and Ecosystem Assessment Survey (RREAS).

This is version 0.1.1. Please report any problems!

An overview of methods, history, findings, and applications of the
survey can be found
[here](https://storymaps.arcgis.com/collections/af0fa37db2bf4f1cadb024ec0ffbdfb5).

To cite this dataset, please cite:  
Sakuma, K.M., Field, J.C., Mantua, N.J., Ralston, S., Marinovic, B.B.
and Carrion, C.N. (2016) Anomalous epipelagic micronekton assemblage
patterns in the neritic waters of the California Current in spring 2015
during a period of extreme ocean conditions. CalCOFI Rep. 57:163-183

To cite this software package, use `citation(package = "RREAS")`.

## Installation

To install the latest version of the package:

``` r
install.packages("devtools") #if required
devtools::install_github("tanyalrogers/RREAS")
```

## Loading data

``` r
library(RREAS)
```

There are two different functions for loading RREAS data:

- `load_erddap` loads the survey data as it is currently stored on
  [ERDDAP](https://oceanview.pfeg.noaa.gov/erddap/index.html), which
  contains data from 1990 to 2018 for standard, active stations only.
  The data tables are contained within the package and are reformatted
  as relational tables (HAUL, CATCH, LENGTH, SPECIES_CODES) to match the
  format in the database. A HAULSTANDARD table is also loaded with a
  standardized set of columns matching those produced by `load_mdb`.
  Note that the AGE and WEIGHT tables are not included in this dataset.

- `load_mdb` loads data from a local copy of the RREAS MS Access
  Database (required to use this function). This function will load the
  HAUL, CATCH, and LENGTH tables from one (or more) surveys in the RREAS
  database, along with the AGE, WEIGHT, and SPECIES_CODES tables from
  RREAS. It also creates and loads a HAULSTANDARD table containing only
  standard stations and with a standardized set of columns including
  YEAR, MONTH, JDAY, and lat/lon in decimal degrees. HAULSTANDARD tables
  all have the same format and so tables from multiple surveys can be
  stacked with `rbind`.

Metadata for the ERDDAP tables (also applicable to the mdb tables) can
be found under `help(RREAS_ERDDAP)`.

To load the ERDDAP data, simply run:

``` r
load_erddap()
#> Data loaded.
```

You will see that the data tables are loaded to your global environment:

``` r
ls(name = .GlobalEnv) #list objects in your workspace
#> [1] "CATCH"         "HAUL"          "HAULSTANDARD"  "LENGTH"       
#> [5] "SPECIES_CODES"
```

To load data from a local MS Access Database, you will need to specify
the file path to the database. The default behavior of `load_mdb` is to
load just the RREAS data (`datasets = "RREAS"`), with HAULSTANDARD
containing only active stations (`activestationsonly = TRUE`):

``` r
#replace the file paths with those for your machine
#any previously loaded tables with the same name in your workspace will be overwritten
load_mdb(mdb_path="E:/Documents/NMFS laptop/Rockfish/RREAS/Survey data/juv_cruise_backup27JAN21.mdb",
         krill_len_path="E:/Documents/NMFS laptop/Rockfish/Index generation/length weight/krill_lengths.csv")
#> Data loaded.
ls(name = .GlobalEnv) #list objects in your workspace
#> [1] "AGE"           "CATCH"         "HAUL"          "HAULSTANDARD" 
#> [5] "krill_length"  "LENGTH"        "SPECIES_CODES" "WEIGHT"
```

Currently, the krill lengths are not in the database, so must be
supplied as a separate file. This file is *not necessary* however,
unless you want to get krill biomass or length distributions. Just omit
this argument if you don’t have the file.

To load data from multiple surveys, specify which ones under `datasets`.
If you want to include non-active stations in HAULSTANDARD, just set
(`activestationsonly = FALSE`). ACTIVE is a column in HAULSTANDARD and
can always be used to subset later.

``` r
#replace the file paths with those for your machine
load_mdb(mdb_path="E:/Documents/NMFS laptop/Rockfish/RREAS/Survey data/juv_cruise_backup27JAN21.mdb",
         krill_len_path="E:/Documents/NMFS laptop/Rockfish/Index generation/length weight/krill_lengths.csv",
         datasets = c("RREAS","ADAMS","PWCC","NWFSC"),
         activestationsonly = TRUE)
#> Data loaded.
ls(name = .GlobalEnv) #list objects in your workspace
#>  [1] "AGE"                "CATCH"              "CATCH_ADAMS"       
#>  [4] "CATCH_NWFSC"        "CATCH_PWCC"         "HAUL"              
#>  [7] "HAUL_ADAMS"         "HAUL_NWFSC"         "HAUL_PWCC"         
#> [10] "HAULSTANDARD"       "HAULSTANDARD_ADAMS" "HAULSTANDARD_NWFSC"
#> [13] "HAULSTANDARD_PWCC"  "krill_length"       "LENGTH"            
#> [16] "LENGTH_ADAMS"       "LENGTH_NWFSC"       "LENGTH_PWCC"       
#> [19] "SPECIES_CODES"      "WEIGHT"
```

There is another, optional argument to load `atsea.mdb` and append the
current year’s data.

See `help(load_mdb)` for more information.

## Extracting data for species

There are two main data extraction functions: `get_totals` and
`get_distributions`. The function `get_totals` can be used to obtain
total haul-level abundance, biomass, or 100-day standardized abundance.
The function `get_distributions` can be used to obtain size, mass, or
age distribution data. Note only haul-level abundance and size
distributions can be obtained from the ERDDAP dataset.

### Formatting the species table

Both functions require a specially formatted dataframe (the
`speciestable`) as an input. This table specifies which species to
extract (multiple species can be specified), whether/how to aggregate
them, and whether any length constraints should be imposed.

The species table must have the following columns:  
- SPECIES: Species codes  
- MATURITY: Maturity codes  
- NAME: A custom name, typically the common name. Rows with the same the
same NAME value will be aggregated together.

The table may optionally include:  
- MINLEN: The minimum length in mm, greater than or equal to (if column
is missing or value is NA, defaults to 0)  
- MAXLEN: The maximum length in mm, less than (if column is missing or
value is NA, defaults to Inf)

Here’s an example of of how you might construct a table for YOY Anchovy,
Adult Anchovy, and Total Anchovy:

``` r
anchovytable <- data.frame(SPECIES=209, MATURITY=c("Y","A","Y","A"),
                           NAME=c("YOY Anchovy", "Adult Anchovy", "Total Anchovy", "Total Anchovy"))
anchovytable
#>   SPECIES MATURITY          NAME
#> 1     209        Y   YOY Anchovy
#> 2     209        A Adult Anchovy
#> 3     209        Y Total Anchovy
#> 4     209        A Total Anchovy
```

If you wanted to split adult Anchovy into two size classes, here’s how
you might do that:

``` r
anchovytable_len <- data.frame(SPECIES=209, MATURITY="A",
                               NAME=c("Small adult anchovy", "Large adult anchovy"),
                               MINLEN=c(90,120),
                               MAXLEN=c(120,NA))
anchovytable_len
#>   SPECIES MATURITY                NAME MINLEN MAXLEN
#> 1     209        A Small adult anchovy     90    120
#> 2     209        A Large adult anchovy    120     NA
```

The package contains some pre-made species tables with common species.
You can explicitly load them using `data()`, but this isn’t strictly
necessary. They also exist in the background, so you can just call them
directly.

``` r
#Some common species and species groups used in ecosystem reports.
data("sptable")
unique(sptable$NAME) #available species and species groups
#>  [1] "YOY Rockfish"     "Market Squid"     "YOY Pacific Hake" "Adult Anchovy"   
#>  [5] "YOY Anchovy"      "Adult Sardine"    "YOY Sardine"      "YOY Sanddabs"    
#>  [9] "Total Myctophids" "Octopus"          "Total Krill"
head(sptable)
#>   SPECIES MATURITY         NAME
#> 1     579        Y YOY Rockfish
#> 2     580        Y YOY Rockfish
#> 3     581        Y YOY Rockfish
#> 4     582        Y YOY Rockfish
#> 5     583        Y YOY Rockfish
#> 6     584        Y YOY Rockfish
```

``` r
#Species for which length-weight regressions exist.
data("sptable_lw")
unique(sptable_lw$NAME) #available species and species groups
#>  [1] "YOY Rockfish"             "Blacksmelt"              
#>  [3] "YOY Pacific sanddab"      "YOY Anchovy"             
#>  [5] "Adult Anchovy"            "Total Anchovy"           
#>  [7] "California Smoothtongue"  "YOY Pacific Hake"        
#>  [9] "YOY Lingcod"              "YOY Sardine"             
#> [11] "Adult Sardine"            "Total Sardine"           
#> [13] "Market Squid"             "Sea nettle"              
#> [15] "Octopus"                  "Pyrosome"                
#> [17] "Armhook squid"            "Thetys salp"             
#> [19] "Blacktip squid"           "Moon jelly"              
#> [21] "Boreal clubhook squid"    "Blue lanternfish"        
#> [23] "California headlightfish" "California lanternfish"  
#> [25] "Nannobrachium spp."       "Mexican lampfish"        
#> [27] "Northern lampfish"        "Total Myctophids"        
#> [29] "Total Krill"              "Carinaria"               
#> [31] "Medusafish"               "King-of-the-salmon"
```

``` r
#Rockfish species used in the 100 day standardized abundance index.
data("sptable_rockfish100")
sptable_rockfish100
#>    SPECIES MATURITY NAME MINLEN      COMMON
#> 1      582        Y  aur     20       Brown
#> 2      597        Y  ent     20       Widow
#> 3      599        Y  fla     20  Yellowtail
#> 4      601        Y  goo     20 Chilipepper
#> 5      603        Y  hop     20  Squarespot
#> 6      604        Y  jor     20  Shortbelly
#> 7      606        Y  lev     20      Cowcod
#> 8      609        Y  mel     20       Black
#> 9      612        Y  mys     20        Blue
#> 10     616        Y  pau     20    Bocaccio
#> 11     618        Y  pin     20      Canary
#> 12     627        Y  sax     20  Stripetail
```

### Getting totals

The function `get_totals` has 4 inputs:  
- `speciestable`: The species table data frame  
- `datasets`: Which datasets you want to use (defaults to RREAS only).
Datasets have to be loaded to use them.  
- `startyear`: Start year (optional). Defaults to 1983.  
- `what`: What kind of total you want, either “abundance”,“biomass”, or
“100day”. Defaults to “abundance”.

Values will be generated for each haul in HAULSTANDARD.

If a station was sampled, but the requested species was *not counted* at
the time, it will appear as an NA. If the species was counted but was
*not present*, it will appear as 0. If the species was counted but the
counts numbers are unreliable (the case for some species prior to 1990,
presence/absence will still be reliable), a message will be displayed.
Description of additional irregularities in species classification can
be found in the `sptable` documentation and in the SPECIES_CODES table.
**It your responsibility to know when your focal species were or were
not being recorded.**

Biomass is only available for species with length-weight regressions.
See `help(get_lw_regression)` for more info on how the regressions are
done. (The function `get_lw_regression` is used internally, but can be
run independently if desired.)

100 day standardized abundance is only available for species with
length-age regressions. This includes the rockfish species listed in
`sptable_rockfish100`, hake (382), and lingcod (448). See
`help(get_la_regression)` and `help(age_to_100day)` for more details on
how the regressions are done. (These functions are also used internally,
but can be run independently if desired.)

If you ask for “biomass” or “100day”, the output will also include
TOTAL_NO (abundance) and NMEAS (number of fish measured). If you include
length constraints, the output table will include additional columns
NMEAS_SIZE (number measured in the size range) and NSIZE (total number
in the size range, which is probably what you want, not TOTAL_NO).

Only one table is outputted, so if you request data from multiple
datasets, they results will be combined (column SURVEY differentiates
source). If multiple NAME values are present, the results will be
stacked in long format. See `help(get_totals)` for more details.

Examples:

``` r
#YOY, Adult, Total anchovy abundances
anchovyabund <- get_totals(anchovytable, datasets = c("RREAS","NWFSC"), what = "abundance")
head(anchovyabund)
#>   SURVEY CRUISE HAUL_NO YEAR MONTH JDAY  HAUL_DATE STATION NET_IN_LATDD
#> 1  RREAS   8303       7 1983     6  161 1983-06-10     104     36.28833
#> 2  RREAS   8303      15 1983     6  163 1983-06-12     119     36.85500
#> 3  RREAS   8303      17 1983     6  164 1983-06-13     114     36.76167
#> 4  RREAS   8303      18 1983     6  164 1983-06-13     116     36.74667
#> 5  RREAS   8303      24 1983     6  165 1983-06-14     117     36.70667
#> 6  RREAS   8303      25 1983     6  165 1983-06-14     113     36.65333
#>   NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH STATION_BOTTOM_DEPTH STRATA
#> 1    -122.0833 36.30000 -122.0900          438                  354     SC
#> 2    -121.9883 36.84667 -121.9833           80                   91      C
#> 3    -121.8850 36.76667 -121.8667           82                   73      C
#> 4    -121.9833 36.74000 -121.9767          444                  287      C
#> 5    -122.1150 36.70000 -122.1083         1828                 1920      C
#> 6    -122.0533 36.64667 -122.0500         1097                  900      C
#>                   AREA ACTIVE          NAME TOTAL_NO
#> 1            Point Sur      Y Adult Anchovy        0
#> 2  Monterey Bay Inside      Y Adult Anchovy      268
#> 3  Monterey Bay Inside      Y Adult Anchovy       40
#> 4  Monterey Bay Inside      Y Adult Anchovy       14
#> 5 Monterey Bay Outside      Y Adult Anchovy        0
#> 6 Monterey Bay Outside      Y Adult Anchovy        0

#Biomass for different anchovy size classes
anchovybiomass_len <- get_totals(anchovytable_len, what = "biomass")
tail(anchovybiomass_len)
#>      SURVEY CRUISE HAUL_NO YEAR MONTH JDAY           HAUL_DATE STATION
#> 7033  RREAS   2103     130 2021     6  159 2021-06-08 03:58:01     425
#> 7034  RREAS   2103      22 2021     5  124 2021-05-04 22:33:18     124
#> 7035  RREAS   2103      23 2021     5  125 2021-05-05 00:01:49     125
#> 7036  RREAS   2103      24 2021     5  125 2021-05-05 01:41:27     126
#> 7037  RREAS   2103      25 2021     5  125 2021-05-05 03:57:50     127
#> 7038  RREAS   2103      26 2021     5  125 2021-05-05 21:03:12     101
#>      NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 7033     33.91300    -120.6992 33.91833 -120.7117         1851
#> 7034     36.97217    -122.3608 36.98333 -122.3750          125
#> 7035     36.97067    -122.4112 36.98333 -122.4250          286
#> 7036     36.97233    -122.5807 36.98333 -122.5917          420
#> 7037     36.97433    -122.7435 36.98333 -122.7583         1050
#> 7038     36.30717    -121.9562 36.30000 -121.9383           75
#>      STATION_BOTTOM_DEPTH STRATA       AREA ACTIVE                NAME TOTAL_NO
#> 7033                 1848      S San Miguel      Y Small adult anchovy      489
#> 7034                  128      C  Davenport      Y Small adult anchovy       28
#> 7035                  446      C  Davenport      Y Small adult anchovy      918
#> 7036                  432      C  Davenport      Y Small adult anchovy        0
#> 7037                 1045      C  Davenport      Y Small adult anchovy        0
#> 7038                   65     SC  Point Sur      Y Small adult anchovy        0
#>      NMEAS NMEAS_SIZE    NSIZE  BIOMASS
#> 7033    19         15 386.0526 4623.876
#> 7034    22          0   0.0000    0.000
#> 7035    20         15 688.5000 8418.535
#> 7036     0          0   0.0000    0.000
#> 7037     0          0   0.0000    0.000
#> 7038     0          0   0.0000    0.000

#100 day rockfish
rockfish100equiv <- get_totals(sptable_rockfish100, what = "100day")
tail(rockfish100equiv)
#>       SURVEY CRUISE HAUL_NO YEAR MONTH JDAY           HAUL_DATE STATION
#> 42223  RREAS   2103     130 2021     6  159 2021-06-08 03:58:01     425
#> 42224  RREAS   2103      22 2021     5  124 2021-05-04 22:33:18     124
#> 42225  RREAS   2103      23 2021     5  125 2021-05-05 00:01:49     125
#> 42226  RREAS   2103      24 2021     5  125 2021-05-05 01:41:27     126
#> 42227  RREAS   2103      25 2021     5  125 2021-05-05 03:57:50     127
#> 42228  RREAS   2103      26 2021     5  125 2021-05-05 21:03:12     101
#>       NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 42223     33.91300    -120.6992 33.91833 -120.7117         1851
#> 42224     36.97217    -122.3608 36.98333 -122.3750          125
#> 42225     36.97067    -122.4112 36.98333 -122.4250          286
#> 42226     36.97233    -122.5807 36.98333 -122.5917          420
#> 42227     36.97433    -122.7435 36.98333 -122.7583         1050
#> 42228     36.30717    -121.9562 36.30000 -121.9383           75
#>       STATION_BOTTOM_DEPTH STRATA       AREA ACTIVE NAME TOTAL_NO NMEAS
#> 42223                 1848      S San Miguel      Y  sax        0     0
#> 42224                  128      C  Davenport      Y  sax       17    17
#> 42225                  446      C  Davenport      Y  sax        5     5
#> 42226                  432      C  Davenport      Y  sax        5     5
#> 42227                 1045      C  Davenport      Y  sax        1     1
#> 42228                   65     SC  Point Sur      Y  sax        0     0
#>       NMEAS_SIZE NSIZE      N100
#> 42223          0     0 0.0000000
#> 42224         16    16 7.6758936
#> 42225          5     5 2.6746351
#> 42226          5     5 2.2873666
#> 42227          1     1 0.4218778
#> 42228          0     0 0.0000000
```

### Getting distributions

The function `get_distributions` has the same 4 inputs, except `what`
should be either “size”, “mass”, or “age”. As with `get_totals`,
regressions must exist for mass and age distributions.

If a haul had no fish, it will appear in the output dataset (with
TOTAL_NO=0). If a haul had fish, but no fish were measured, there will
be a TOTAL_NO\>0, NMEAS will be 0, and there will be a single
length/mass/age entry for that haul, which will be the average values
used as a substitute.

The output table will include TOTAL_NO, NMEAS (number measured), EXP
(expansion factor), SP_NO (specimen number) and values for the requested
distribution. If “size” is requested, will include column STD_LENGTH. If
“mass” is requested, will include columns STD_LENGTH and WEIGHT. If
“age” is requested, will include columns STD_LENGTH, AGE, N100i (number
of 100 day equivalents), and JDAY_DOB (date of birth). If size limits
are specified, will include additional columns NMEAS_SIZE (number
measured in the size range), PSIZE (proportion of measured fish in the
size range), and NSIZE (total number in the size range).

Only one table is outputted, so if you request data from multiple
datasets, they results will be combined (column SURVEY differentiates
source). If multiple NAME values are present, the results will be
stacked in long format. See `help(get_distributions)` for more details.

``` r
#Size distribution for anchovy
anchovysizedist <- get_distributions(anchovytable, what = "size")
head(anchovysizedist)
#>   SURVEY CRUISE HAUL_NO YEAR MONTH JDAY  HAUL_DATE STATION NET_IN_LATDD
#> 1  RREAS   8303       7 1983     6  161 1983-06-10     104     36.28833
#> 2  RREAS   8303      15 1983     6  163 1983-06-12     119     36.85500
#> 3  RREAS   8303      17 1983     6  164 1983-06-13     114     36.76167
#> 4  RREAS   8303      18 1983     6  164 1983-06-13     116     36.74667
#> 5  RREAS   8303      24 1983     6  165 1983-06-14     117     36.70667
#> 6  RREAS   8303      25 1983     6  165 1983-06-14     113     36.65333
#>   NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH STATION_BOTTOM_DEPTH STRATA
#> 1    -122.0833 36.30000 -122.0900          438                  354     SC
#> 2    -121.9883 36.84667 -121.9833           80                   91      C
#> 3    -121.8850 36.76667 -121.8667           82                   73      C
#> 4    -121.9833 36.74000 -121.9767          444                  287      C
#> 5    -122.1150 36.70000 -122.1083         1828                 1920      C
#> 6    -122.0533 36.64667 -122.0500         1097                  900      C
#>                   AREA ACTIVE SPECIES MATURITY          NAME TOTAL_NO NMEAS EXP
#> 1            Point Sur      Y     209        A Adult Anchovy        0     0  NA
#> 2  Monterey Bay Inside      Y     209        A Adult Anchovy      268     0 268
#> 3  Monterey Bay Inside      Y     209        A Adult Anchovy       40     0  40
#> 4  Monterey Bay Inside      Y     209        A Adult Anchovy       14     0  14
#> 5 Monterey Bay Outside      Y     209        A Adult Anchovy        0     0  NA
#> 6 Monterey Bay Outside      Y     209        A Adult Anchovy        0     0  NA
#>   SP_NO STD_LENGTH
#> 1    NA         NA
#> 2    NA   119.9586
#> 3    NA   119.9586
#> 4    NA   119.9586
#> 5    NA         NA
#> 6    NA         NA

#Mass distribution for different anchovy size classes
anchovymassdist <- get_distributions(anchovytable_len, what = "mass")
tail(anchovymassdist)
#>       SURVEY CRUISE HAUL_NO YEAR MONTH JDAY           HAUL_DATE STATION
#> 14954  RREAS   2103      23 2021     5  125 2021-05-05 00:01:49     125
#> 14955  RREAS   2103      23 2021     5  125 2021-05-05 00:01:49     125
#> 14956  RREAS   2103      23 2021     5  125 2021-05-05 00:01:49     125
#> 14957  RREAS   2103      24 2021     5  125 2021-05-05 01:41:27     126
#> 14958  RREAS   2103      25 2021     5  125 2021-05-05 03:57:50     127
#> 14959  RREAS   2103      26 2021     5  125 2021-05-05 21:03:12     101
#>       NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 14954     36.97067    -122.4112 36.98333 -122.4250          286
#> 14955     36.97067    -122.4112 36.98333 -122.4250          286
#> 14956     36.97067    -122.4112 36.98333 -122.4250          286
#> 14957     36.97233    -122.5807 36.98333 -122.5917          420
#> 14958     36.97433    -122.7435 36.98333 -122.7583         1050
#> 14959     36.30717    -121.9562 36.30000 -121.9383           75
#>       STATION_BOTTOM_DEPTH STRATA      AREA ACTIVE SPECIES MATURITY
#> 14954                  446      C Davenport      Y     209        A
#> 14955                  446      C Davenport      Y     209        A
#> 14956                  446      C Davenport      Y     209        A
#> 14957                  432      C Davenport      Y     209        A
#> 14958                 1045      C Davenport      Y     209        A
#> 14959                   65     SC Point Sur      Y     209        A
#>                      NAME TOTAL_NO NMEAS NMEAS_SIZE  EXP PSIZE NSIZE SP_NO
#> 14954 Small adult anchovy      918    20         15 45.9  0.75 688.5  6516
#> 14955 Small adult anchovy      918    20         15 45.9  0.75 688.5  6517
#> 14956 Small adult anchovy      918    20         15 45.9  0.75 688.5  6518
#> 14957 Small adult anchovy        0     0          0   NA    NA   0.0    NA
#> 14958 Small adult anchovy        0     0          0   NA    NA   0.0    NA
#> 14959 Small adult anchovy        0     0          0   NA    NA   0.0    NA
#>       STD_LENGTH   WEIGHT
#> 14954        103 11.34121
#> 14955        105 12.10997
#> 14956        110 14.19203
#> 14957         NA       NA
#> 14958         NA       NA
#> 14959         NA       NA

#rockfish age distributions
rockfish100agedist <- get_distributions(sptable_rockfish100, what = "age")
tail(rockfish100agedist)
#>        SURVEY CRUISE HAUL_NO YEAR MONTH JDAY           HAUL_DATE STATION
#> 103879  RREAS   2103      24 2021     5  125 2021-05-05 01:41:27     126
#> 103880  RREAS   2103      24 2021     5  125 2021-05-05 01:41:27     126
#> 103881  RREAS   2103      24 2021     5  125 2021-05-05 01:41:27     126
#> 103882  RREAS   2103      24 2021     5  125 2021-05-05 01:41:27     126
#> 103883  RREAS   2103      25 2021     5  125 2021-05-05 03:57:50     127
#> 103884  RREAS   2103      26 2021     5  125 2021-05-05 21:03:12     101
#>        NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 103879     36.97233    -122.5807 36.98333 -122.5917          420
#> 103880     36.97233    -122.5807 36.98333 -122.5917          420
#> 103881     36.97233    -122.5807 36.98333 -122.5917          420
#> 103882     36.97233    -122.5807 36.98333 -122.5917          420
#> 103883     36.97433    -122.7435 36.98333 -122.7583         1050
#> 103884     36.30717    -121.9562 36.30000 -121.9383           75
#>        STATION_BOTTOM_DEPTH STRATA      AREA ACTIVE SPECIES MATURITY NAME
#> 103879                  432      C Davenport      Y     627        Y  sax
#> 103880                  432      C Davenport      Y     627        Y  sax
#> 103881                  432      C Davenport      Y     627        Y  sax
#> 103882                  432      C Davenport      Y     627        Y  sax
#> 103883                 1045      C Davenport      Y     627        Y  sax
#> 103884                   65     SC Point Sur      Y     627        Y  sax
#>        TOTAL_NO NMEAS NMEAS_SIZE EXP PSIZE NSIZE SP_NO STD_LENGTH      AGE
#> 103879        5     5          5   1     1     5    99         26 82.57587
#> 103880        5     5          5   1     1     5   100         27 84.65180
#> 103881        5     5          5   1     1     5   101         22 74.27215
#> 103882        5     5          5   1     1     5   102         20 70.12030
#> 103883        1     1          1   1     1     1  1493         24 78.42401
#> 103884        0     0          0  NA    NA     0    NA         NA       NA
#>            N100i JDAY_DOB
#> 103879 0.4980946 42.42413
#> 103880 0.5412207 40.34820
#> 103881 0.3573235 50.72785
#> 103882 0.3026470 54.87970
#> 103883 0.4218778 46.57599
#> 103884        NA       NA
```

## Generating indices

Given an output table from `get_totals`, there is a function
`get_logcpueindex` which will compute `mean(log(x+1))` for an `x` of
your choice, for each YEAR and NAME. It allows optional grouping
variables (typically STRATA). A standardized index (within groups) is
also computed by default, but can be turned off by setting
`standardized=FALSE`.

``` r
library(ggplot2)
library(dplyr)

anchovyindex1 <- get_logcpueindex(anchovyabund, var = "TOTAL_NO", group="STRATA")
head(anchovyindex1)
#>          NAME STRATA YEAR TOTAL_NO_INDEX TOTAL_NO_INDEX_SC
#> 1 YOY Anchovy      C 1983     0.00000000        -0.6362502
#> 2 YOY Anchovy      C 1984     0.04993692        -0.5594029
#> 3 YOY Anchovy      C 1985     0.08788898        -0.5009989
#> 4 YOY Anchovy      C 1986     0.72783491         0.4838058
#> 5 YOY Anchovy      C 1987     0.48685054         0.1129580
#> 6 YOY Anchovy      C 1988     0.17104788        -0.3730267

anchovyindex1plot <- anchovyindex1 %>% 
  #filter(!(YEAR<2004 & STRATA!="C")) %>% #exclude non-core areas before 2004
  mutate(STRATA=factor(STRATA, levels = c("WA","OR","N","NC","C","SC","S")))
ggplot(anchovyindex1plot,aes(y=TOTAL_NO_INDEX,x=YEAR)) +
  facet_grid(STRATA~NAME) +
  geom_point() + geom_line() +
  theme_bw() +
  labs(x="Year", y="log Abundance")
```

<img src="man/figures/README-indices-1.png" width="100%" />

``` r

anchovyindex2 <- get_logcpueindex(anchovybiomass_len, var = "BIOMASS", group="STRATA")
head(anchovyindex2)
#>                  NAME STRATA YEAR BIOMASS_INDEX BIOMASS_INDEX_SC
#> 1 Small adult anchovy      C 1983     2.0613810       0.66499025
#> 2 Small adult anchovy      C 1984     3.0168360       1.37970873
#> 3 Small adult anchovy      C 1985     2.6174411       1.08094535
#> 4 Small adult anchovy      C 1986     0.4256878      -0.55857346
#> 5 Small adult anchovy      C 1987     1.1512273      -0.01584101
#> 6 Small adult anchovy      C 1988     1.1424928      -0.02237477

anchovyindex2plot <- anchovyindex2 %>% 
  #filter(!(YEAR<2004 & STRATA!="C")) %>% #exclude non-core areas before 2004
  mutate(STRATA=factor(STRATA, levels = c("N","NC","C","SC","S")))
ggplot(anchovyindex2plot,aes(y=BIOMASS_INDEX,x=YEAR)) +
  facet_grid(STRATA~NAME) +
  geom_point() + geom_line() +
  theme_bw() +
  labs(x="Year", y="log Biomass")
```

<img src="man/figures/README-indices-2.png" width="100%" />

``` r

rockfish100index <- get_logcpueindex(rockfish100equiv, var="N100", group="STRATA")
head(rockfish100index)
#>   NAME STRATA YEAR N100_INDEX N100_INDEX_SC
#> 1  aur      C 1983 0.00000000    -0.7036166
#> 2  aur      C 1984 0.22410049     0.8650105
#> 3  aur      C 1985 0.00000000    -0.7036166
#> 4  aur      C 1986 0.35336455     1.7698149
#> 5  aur      C 1987 0.01173913    -0.6214467
#> 6  aur      C 1988 0.00000000    -0.7036166

rf100plot <- rockfish100index %>% 
  filter(STRATA=="C" & NAME!="mel" & NAME!="lev") %>% 
  left_join(sptable_rockfish100, by = "NAME")
ggplot(rf100plot,aes(y=N100_INDEX_SC,x=YEAR, group=COMMON, color=COMMON)) +
  geom_point() + geom_line() +
  theme_bw() +
  labs(x="Year", y="log 100-day standardized abundance", color="Rockfish species")
```

<img src="man/figures/README-indices-3.png" width="100%" />

## Remaining things to do

- Need to add model-based index generation methods.
- Jellyfish values do not take into account hauls cancelled due to
  jellyfish.

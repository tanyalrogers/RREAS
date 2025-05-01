
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RREAS <img src='man/figures/rreas-logo.png' align="right" style="height:139px;"/>

<!-- badges: start -->
<!-- badges: end -->

This package contains data and support functions for the NOAA SWFSC
Rockfish Recruitment and Ecosystem Assessment Survey (RREAS).

This is version 0.1.5. Please report any problems!

An overview of methods, history, findings, and applications of the
survey can be found
[here](https://storymaps.arcgis.com/collections/af0fa37db2bf4f1cadb024ec0ffbdfb5).

To cite this dataset, please cite:  
Sakuma, K.M., Field, J.C., Mantua, N.J., Ralston, S., Marinovic, B.B.
and Carrion, C.N. (2016) Anomalous epipelagic micronekton assemblage
patterns in the neritic waters of the California Current in spring 2015
during a period of extreme ocean conditions. CalCOFI Rep. 57:163-183

To cite this software package, use `citation(package = "RREAS")`.

Juvenile cowcod illustration in our logo by Sophie Webb.

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
  contains data from 1990 to 2023 for standard, active stations only.
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
load_mdb(mdb_path="C:/Users/trogers/Documents/Rockfish/RREAS/Survey data/juv_cruise_backup02APR25.mdb",
         krill_len_path="C:/Users/trogers/Documents/Rockfish/Index generation/length weight/krill_lengths.csv")
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
load_mdb(mdb_path="C:/Users/trogers/Documents/Rockfish/RREAS/Survey data/juv_cruise_backup02APR25.mdb",
         krill_len_path="C:/Users/trogers/Documents/Rockfish/Index generation/length weight/krill_lengths.csv",
         datasets = c("RREAS","ADAMS","PWCC","NWFSC"),
         activestationsonly = TRUE)
#> Note: HAULSTANDARD_PWCC has missing STATION numbers.
#> Note: HAULSTANDARD_NWFSC has missing STATION numbers.
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
current year’s data if it is not in the primary database.

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
#>  [5] "YOY Anchovy"      "Adult Sardine"    "YOY Sardine"      "Pyrosomes"       
#>  [9] "Thetys"           "Salps"            "YOY Sanddabs"     "Total Myctophids"
#> [13] "Octopus"          "Total Krill"
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
#>  [3] "YOY Pacific sanddab"      "YOY Speckled sanddab"    
#>  [5] "YOY Sanddabs"             "YOY Anchovy"             
#>  [7] "Adult Anchovy"            "Total Anchovy"           
#>  [9] "California Smoothtongue"  "YOY Pacific Hake"        
#> [11] "YOY Lingcod"              "YOY Sardine"             
#> [13] "Adult Sardine"            "Total Sardine"           
#> [15] "Market Squid"             "Sea nettle"              
#> [17] "Octopus"                  "Pyrosome"                
#> [19] "Armhook squid"            "Thetys salp"             
#> [21] "Blacktip squid"           "Moon jelly"              
#> [23] "Boreal clubhook squid"    "Blue lanternfish"        
#> [25] "California headlightfish" "California lanternfish"  
#> [27] "Nannobrachium spp."       "Mexican lampfish"        
#> [29] "Northern lampfish"        "Total Myctophids"        
#> [31] "Total Krill"              "Carinaria"               
#> [33] "Medusafish"               "King-of-the-salmon"
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

The function `get_totals` has 5 inputs:  
- `speciestable`: The species table data frame  
- `datasets`: Which datasets you want to use (defaults to RREAS only).
Datasets have to be loaded to use them.  
- `startyear`: Start year (optional). Defaults to 1983.  
- `what`: What kind of total you want, either “abundance”,“biomass”, or
“100day”. Defaults to “abundance”.  
- `haultable`: Table of hauls to from which to obtain totals. Defaults
to HAULSTANDARD.

Values will be generated for each haul in HAULSTANDARD, unless another
table is specified under `haultable`. See `help(get_totals)` for more
detail.

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
#> 7541  RREAS   2406     119 2024     6  168 2024-06-16 02:54:53     484
#> 7542  RREAS   2406     120 2024     6  168 2024-06-16 21:20:40     411
#> 7543  RREAS   2406     121 2024     6  168 2024-06-16 23:13:17     412
#> 7544  RREAS   2406     122 2024     6  169 2024-06-17 01:07:30     413
#> 7545  RREAS   2406     123 2024     6  169 2024-06-17 21:18:18     483
#> 7546  RREAS   2406     124 2024     6  169 2024-06-17 23:35:59     484
#>      NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 7541     32.70683    -117.3353 32.70833 -117.3333           97
#> 7542     33.68717    -119.2857 33.69000 -119.2867          930
#> 7543     33.58767    -119.4448 33.58667 -119.4483         1853
#> 7544     33.48400    -119.5887 33.48667 -119.6050          722
#> 7545     32.81133    -117.4192 32.81667 -117.4217          530
#> 7546     32.70667    -117.3350 32.70833 -117.3333          530
#>      STATION_BOTTOM_DEPTH STRATA        AREA ACTIVE                NAME
#> 7541                   94      S   San Diego      Y Small adult anchovy
#> 7542                  892      S San Nicolas      Y Small adult anchovy
#> 7543                 1874      S San Nicolas      Y Small adult anchovy
#> 7544                  775      S San Nicolas      Y Small adult anchovy
#> 7545                  555      S   San Diego      Y Small adult anchovy
#> 7546                   94      S   San Diego      Y Small adult anchovy
#>      TOTAL_NO NMEAS NMEAS_SIZE NSIZE  BIOMASS
#> 7541        0     0          0     0  0.00000
#> 7542        0     0          0     0  0.00000
#> 7543        0     0          0     0  0.00000
#> 7544        0     0          0     0  0.00000
#> 7545        0     0          0     0  0.00000
#> 7546        1     1          1     1 11.72114

#100 day rockfish
rockfish100equiv <- get_totals(sptable_rockfish100, what = "100day")
tail(rockfish100equiv)
#>       SURVEY CRUISE HAUL_NO YEAR MONTH JDAY           HAUL_DATE STATION
#> 45271  RREAS   2406     119 2024     6  168 2024-06-16 02:54:53     484
#> 45272  RREAS   2406     120 2024     6  168 2024-06-16 21:20:40     411
#> 45273  RREAS   2406     121 2024     6  168 2024-06-16 23:13:17     412
#> 45274  RREAS   2406     122 2024     6  169 2024-06-17 01:07:30     413
#> 45275  RREAS   2406     123 2024     6  169 2024-06-17 21:18:18     483
#> 45276  RREAS   2406     124 2024     6  169 2024-06-17 23:35:59     484
#>       NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 45271     32.70683    -117.3353 32.70833 -117.3333           97
#> 45272     33.68717    -119.2857 33.69000 -119.2867          930
#> 45273     33.58767    -119.4448 33.58667 -119.4483         1853
#> 45274     33.48400    -119.5887 33.48667 -119.6050          722
#> 45275     32.81133    -117.4192 32.81667 -117.4217          530
#> 45276     32.70667    -117.3350 32.70833 -117.3333          530
#>       STATION_BOTTOM_DEPTH STRATA        AREA ACTIVE NAME TOTAL_NO NMEAS
#> 45271                   94      S   San Diego      Y  sax        0     0
#> 45272                  892      S San Nicolas      Y  sax        0     0
#> 45273                 1874      S San Nicolas      Y  sax        0     0
#> 45274                  775      S San Nicolas      Y  sax        0     0
#> 45275                  555      S   San Diego      Y  sax        0     0
#> 45276                   94      S   San Diego      Y  sax        0     0
#>       NMEAS_SIZE NSIZE N100
#> 45271          0     0    0
#> 45272          0     0    0
#> 45273          0     0    0
#> 45274          0     0    0
#> 45275          0     0    0
#> 45276          0     0    0
```

### Getting distributions

The function `get_distributions` has the same 5 inputs, except `what`
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
#> 2    NA   120.1699
#> 3    NA   120.1699
#> 4    NA   120.1699
#> 5    NA         NA
#> 6    NA         NA

#Mass distribution for different anchovy size classes
anchovymassdist <- get_distributions(anchovytable_len, what = "mass")
tail(anchovymassdist)
#>       SURVEY CRUISE HAUL_NO YEAR MONTH JDAY           HAUL_DATE STATION
#> 16589  RREAS   2406     119 2024     6  168 2024-06-16 02:54:53     484
#> 16590  RREAS   2406     120 2024     6  168 2024-06-16 21:20:40     411
#> 16591  RREAS   2406     121 2024     6  168 2024-06-16 23:13:17     412
#> 16592  RREAS   2406     122 2024     6  169 2024-06-17 01:07:30     413
#> 16593  RREAS   2406     123 2024     6  169 2024-06-17 21:18:18     483
#> 16594  RREAS   2406     124 2024     6  169 2024-06-17 23:35:59     484
#>       NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 16589     32.70683    -117.3353 32.70833 -117.3333           97
#> 16590     33.68717    -119.2857 33.69000 -119.2867          930
#> 16591     33.58767    -119.4448 33.58667 -119.4483         1853
#> 16592     33.48400    -119.5887 33.48667 -119.6050          722
#> 16593     32.81133    -117.4192 32.81667 -117.4217          530
#> 16594     32.70667    -117.3350 32.70833 -117.3333          530
#>       STATION_BOTTOM_DEPTH STRATA        AREA ACTIVE SPECIES MATURITY
#> 16589                   94      S   San Diego      Y     209        A
#> 16590                  892      S San Nicolas      Y     209        A
#> 16591                 1874      S San Nicolas      Y     209        A
#> 16592                  775      S San Nicolas      Y     209        A
#> 16593                  555      S   San Diego      Y     209        A
#> 16594                   94      S   San Diego      Y     209        A
#>                      NAME TOTAL_NO NMEAS NMEAS_SIZE EXP PSIZE NSIZE SP_NO
#> 16589 Small adult anchovy        0     0          0  NA    NA     0    NA
#> 16590 Small adult anchovy        0     0          0  NA    NA     0    NA
#> 16591 Small adult anchovy        0     0          0  NA    NA     0    NA
#> 16592 Small adult anchovy        0     0          0  NA    NA     0    NA
#> 16593 Small adult anchovy        0     0          0  NA    NA     0    NA
#> 16594 Small adult anchovy        1     1          1   1     1     1 24032
#>       STD_LENGTH   WEIGHT
#> 16589         NA       NA
#> 16590         NA       NA
#> 16591         NA       NA
#> 16592         NA       NA
#> 16593         NA       NA
#> 16594        104 11.72114

#rockfish age distributions
rockfish100agedist <- get_distributions(sptable_rockfish100, what = "age")
tail(rockfish100agedist)
#>        SURVEY CRUISE HAUL_NO YEAR MONTH JDAY           HAUL_DATE STATION
#> 115212  RREAS   2406     119 2024     6  168 2024-06-16 02:54:53     484
#> 115213  RREAS   2406     120 2024     6  168 2024-06-16 21:20:40     411
#> 115214  RREAS   2406     121 2024     6  168 2024-06-16 23:13:17     412
#> 115215  RREAS   2406     122 2024     6  169 2024-06-17 01:07:30     413
#> 115216  RREAS   2406     123 2024     6  169 2024-06-17 21:18:18     483
#> 115217  RREAS   2406     124 2024     6  169 2024-06-17 23:35:59     484
#>        NET_IN_LATDD NET_IN_LONDD    LATDD     LONDD BOTTOM_DEPTH
#> 115212     32.70683    -117.3353 32.70833 -117.3333           97
#> 115213     33.68717    -119.2857 33.69000 -119.2867          930
#> 115214     33.58767    -119.4448 33.58667 -119.4483         1853
#> 115215     33.48400    -119.5887 33.48667 -119.6050          722
#> 115216     32.81133    -117.4192 32.81667 -117.4217          530
#> 115217     32.70667    -117.3350 32.70833 -117.3333          530
#>        STATION_BOTTOM_DEPTH STRATA        AREA ACTIVE SPECIES MATURITY NAME
#> 115212                   94      S   San Diego      Y     627        Y  sax
#> 115213                  892      S San Nicolas      Y     627        Y  sax
#> 115214                 1874      S San Nicolas      Y     627        Y  sax
#> 115215                  775      S San Nicolas      Y     627        Y  sax
#> 115216                  555      S   San Diego      Y     627        Y  sax
#> 115217                   94      S   San Diego      Y     627        Y  sax
#>        TOTAL_NO NMEAS NMEAS_SIZE EXP PSIZE NSIZE SP_NO STD_LENGTH AGE N100i
#> 115212        0     0          0  NA    NA     0    NA         NA  NA    NA
#> 115213        0     0          0  NA    NA     0    NA         NA  NA    NA
#> 115214        0     0          0  NA    NA     0    NA         NA  NA    NA
#> 115215        0     0          0  NA    NA     0    NA         NA  NA    NA
#> 115216        0     0          0  NA    NA     0    NA         NA  NA    NA
#> 115217        0     0          0  NA    NA     0    NA         NA  NA    NA
#>        JDAY_DOB
#> 115212       NA
#> 115213       NA
#> 115214       NA
#> 115215       NA
#> 115216       NA
#> 115217       NA
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

#Note that anchovyabund includes the NWFSC hauls and that the 2024 data have
#some missing stations numbers that need to be filled in for get_logcpueindex to work. This will otherwise produce an error.
anchovyabund$STATION=ifelse(is.na(anchovyabund$STATION),
                            paste0(anchovyabund$CRUISE,anchovyabund$HAUL_NO),
                            anchovyabund$STATION)
anchovyindex1 <- get_logcpueindex(anchovyabund, var = "TOTAL_NO", group="STRATA")
head(anchovyindex1)
#>          NAME STRATA YEAR TOTAL_NO_INDEX TOTAL_NO_INDEX_SC
#> 1 YOY Anchovy      C 1983     0.00000000       -0.65200700
#> 2 YOY Anchovy      C 1984     0.04993692       -0.57613892
#> 3 YOY Anchovy      C 1985     0.08788898       -0.51847917
#> 4 YOY Anchovy      C 1986     0.72783491        0.45377684
#> 5 YOY Anchovy      C 1987     0.48685054        0.08765449
#> 6 YOY Anchovy      C 1988     0.17104788       -0.39213765

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
#> 1 Small adult anchovy      C 1983     2.0673648       0.58209365
#> 2 Small adult anchovy      C 1984     3.0254248       1.28537690
#> 3 Small adult anchovy      C 1985     2.6267725       0.99273817
#> 4 Small adult anchovy      C 1986     0.4276985      -0.62153644
#> 5 Small adult anchovy      C 1987     1.1545682      -0.08796311
#> 6 Small adult anchovy      C 1988     1.1468212      -0.09364995

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
#> 1  aur      C 1983 0.00000000    -0.7151397
#> 2  aur      C 1984 0.22593180     0.8905761
#> 3  aur      C 1985 0.00000000    -0.7151397
#> 4  aur      C 1986 0.35444641     1.8039400
#> 5  aur      C 1987 0.01188546    -0.6306687
#> 6  aur      C 1988 0.00000000    -0.7151397

rf100plot <- rockfish100index %>% 
  filter(STRATA=="C" & NAME!="mel" & NAME!="lev") %>% 
  left_join(sptable_rockfish100, by = "NAME")
ggplot(rf100plot,aes(y=N100_INDEX_SC,x=YEAR, group=COMMON, color=COMMON)) +
  geom_point() + geom_line() +
  theme_bw() +
  labs(x="Year", y="log 100-day standardized abundance", color="Rockfish species")
```

<img src="man/figures/README-indices-3.png" width="100%" />

## Depth-stratified tows

RREAS standard tows are conducted at 30 m headrope depth (DEPTH_STRATA
2), with the exception of stations with a bottom depth of less than 60
m, which are towed at 10 m headrope depth (DEPTH_STRATA 1). These are
the tows which appear in HAULSTANDARD.

Historically, mostly before the coastwide expansion in 2004, multiple
depth strata (DEPTH_STRATA 1: 10 m, DEPTH_STRATA 2: 30 m, DEPTH_STRATA
3: 90 m) were sampled in succession at specific stations, mostly at
stations 110, 125, 133, and 170, but occassionally others. The function
`load_depth_stratified_tows` pulls out these depth-stratified tows into
the table HAULDEPTHSTRATIFED. It has the same format as HAULSTANDARD,
but with a few extra columns: DEPTH_STRATA, SWEEP (indicates which of
the 3 passes the sampling is from; there is generally one set of
depth-stratified tows per sweep, but not always), and SWEEP_SEP
(separates cases in which there are multiple sets of depth stratified
tows per sweep, and sets of depth stratified tows where SWEEP in NA,
which occurs after 2004; otherwise equal to SWEEP). Each set of
consecutive depth stratified tows will have a unique
CRUISE/STATION/SWEEP_SEP value.

HAULDEPTHSTRATIFED can be passed to `get_totals` or `get_distributions`
to get catch data from these hauls instead of HAULSTANDARD by supplying
it under `haultable`. Note that all of the depth-stratified tows are not
present in the ERDDAP dataset.

Note that to get *all* of the depth-stratified tows, you have to include
the non-active stations (`activestationsonly = FALSE`).

``` r
load_mdb(mdb_path="C:/Users/trogers/Documents/Rockfish/RREAS/Survey data/juv_cruise_backup02APR25.mdb",
         activestationsonly = FALSE)
#> Data loaded.
load_depth_stratified_tows()
#> HAULDEPTHSTRATIFED created.
str(HAULDEPTHSTRATIFIED)
#> 'data.frame':    669 obs. of  20 variables:
#>  $ SURVEY              : chr  "RREAS" "RREAS" "RREAS" "RREAS" ...
#>  $ CRUISE              : chr  "8303" "8303" "8303" "8303" ...
#>  $ HAUL_NO             : int  22 23 31 32 38 40 41 5 6 30 ...
#>  $ YEAR                : num  1983 1983 1983 1983 1983 ...
#>  $ MONTH               : num  6 6 6 6 6 6 6 6 6 6 ...
#>  $ JDAY                : num  165 165 166 166 166 167 167 165 165 166 ...
#>  $ HAUL_DATE           : POSIXct, format: "1983-06-14 00:00:00" "1983-06-14 00:00:00" ...
#>  $ STATION             : int  118 118 125 125 132 132 132 125 125 103 ...
#>  $ NET_IN_LATDD        : num  36.8 36.8 37 37 37.3 ...
#>  $ NET_IN_LONDD        : num  -122 -122 -122 -122 -123 ...
#>  $ LATDD               : num  36.8 36.8 37 37 37.3 ...
#>  $ LONDD               : num  -122 -122 -122 -122 -123 ...
#>  $ BOTTOM_DEPTH        : int  841 822 505 170 98 100 100 201 177 102 ...
#>  $ STATION_BOTTOM_DEPTH: int  966 966 446 446 95 95 95 446 446 102 ...
#>  $ STRATA              : chr  "C" "C" "C" "C" ...
#>  $ AREA                : chr  "Monterey Bay Outside" "Monterey Bay Outside" "Davenport" "Davenport" ...
#>  $ ACTIVE              : chr  "N" "N" "Y" "Y" ...
#>  $ DEPTH_STRATA        : int  3 2 2 3 2 3 1 2 3 1 ...
#>  $ SWEEP               : int  1 1 1 1 1 1 1 1 1 1 ...
#>  $ SWEEP_SEP           : num  1 1 1 1 1 1 1 1 1 1 ...

anchovyabund_ds <- get_totals(anchovytable, what = "abundance", haultable = HAULDEPTHSTRATIFIED)

#to get depth stratified tows with all 3 strata sampled
HAULDEPTHSTRATIFIED=HAULDEPTHSTRATIFIED %>% group_by(CRUISE,STATION,SWEEP_SEP) %>%
  mutate(ustrata=length(unique(DEPTH_STRATA)))
filter(HAULDEPTHSTRATIFIED, ustrata==3) %>% nrow()
#> [1] 441
filter(HAULDEPTHSTRATIFIED, ustrata==3 & YEAR>=1990) %>% nrow()
#> [1] 282

#see which tows have CTDs
HAULDEPTHSTRATIFIED=HAULDEPTHSTRATIFIED %>%
  left_join(HAUL %>% select(CRUISE, HAUL_NO, CTD_INDEX), by = c("CRUISE", "HAUL_NO"))
```

## Remaining things to do

- Need to add model-based index generation methods.
- Jellyfish values do not take into account hauls cancelled due to
  jellyfish.

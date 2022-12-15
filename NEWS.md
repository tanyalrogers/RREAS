# RREAS 0.1.2

* Update ERDAPP data (still 1990-2018, but with errors fixed)
* Displays message if NAs are inserted
* Includes NAs for gelatinous species uncounted for part of the 2012 survey
* Added gelatinous species to `sptable` so that it contains all CCIEA species
* Bug fixes, mostly related to biomass calculations

# RREAS 0.1.1

* Reports uncounted species as NAs instead of 0s (uses internal table generated from xlsx file).
* Displays message if requesting counts of species from years when counts were unreliable (uses internal table generated from xlsx file).
* Describes irregularities in species classifications in help file for `sptable`.
* Report NMEAS as 0 instead of NA when no fish were measured. Includes when no fish were caught.
* Spelling check for dataset names.
* Added survey webpage to readme.
* Miscellaneous bug fixes.
* Added `NEWS.md` file to track changes to the package.

# RREAS 0.1.0

* First version. ERDDAP data to 2018.

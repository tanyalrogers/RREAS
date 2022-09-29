# Generate internal tables of uncounted/unreliable species

# Species not counted
# SPECIES CRUISE combos should be NA

uncounted0=readxl::read_xlsx("data-raw/MWT species NA cruises.xlsx", sheet=1)
uncounted=uncounted0[,c("SPECIES","CRUISE")]

# Species counted but counts are not reliable
# SPECIES CRUISE combos should produce message

unreliable0=readxl::read_xlsx("data-raw/MWT species NA cruises.xlsx", sheet=2)
unreliable=unreliable0[,c("SPECIES","CRUISE")]

usethis::use_data(uncounted, unreliable, internal = TRUE)

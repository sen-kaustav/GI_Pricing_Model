library(CASdatasets)
library(tidyverse)
library(duckdb)
library(duckplyr)

# Setup the database ------------------------------------------------------

con <- dbConnect(duckdb(), dbdir = "datasets.duckdb")

# Prep the freMTPL dataset ------------------------------------------------

data("freMTPL2freq")
data("freMTPL2sev")

df_freq <- freMTPL2freq |> 
  as_tibble()

df_sev <- freMTPL2sev |> 
  as_tibble()

df_sev_agg <- df_sev |>
  summarise(ClaimAmount = sum(ClaimAmount), .by = IDpol)

df_combined <- df_freq |> 
  left_join(df_sev_agg, by = "IDpol")

# Save the combined dataset into the database
dbWriteTable(con, "freMTPL_combined", df_combined, overwrite = TRUE)

# Shutdown the database ----------------------------------------------------

dbDisconnect(con)

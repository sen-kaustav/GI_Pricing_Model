# Load packages ----------------------------------------------------------

library(tidyverse)

# Inputs -----------------------------------------------------------------

val_date <- ymd("20191130")

make_age_bins <- function(age_vec) {
  cut(age_vec, breaks = c(-Inf, 20, seq(25, 75, 5), Inf), ordered_result = TRUE)
}

make_senority_bins <- function(senority_vec) {
  cut(
    senority_vec,
    breaks = c(-Inf, 1:10, 15, 20, Inf),
    labels = c(1:10, "10-15", "15-20", "20+"),
    ordered_results = TRUE
  )
}

# Read in data -----------------------------------------------------------

insurance_data <- read_delim(
  "data/Motor vehicle insurance data.csv",
  delim = ";"
)

# Data cleaning ----------------------------------------------------------

clean_data <-
  insurance_data |>
  mutate(
    # convert strings into dates
    across(starts_with("Date"), dmy),
    Date_end = case_when(
      is.na(Date_lapse) ~ Date_next_renewal,
      TRUE ~ pmin(Date_lapse, Date_next_renewal)
    ),

    # age calculations derived from dates
    Exposure = time_length(Date_end - Date_last_renewal, "years"),
    Car_Age = year(val_date) - Year_matriculation,
    Driver_Age = time_length(val_date - Date_birth, "years"),
    Driver_Age_bin = make_age_bins(Driver_Age),
    License_Age = time_length(Date_driving_licence - Date_birth, "years"),
    License_Age_bin = make_age_bins(License_Age),
    Seniority_bin = make_senority_bins(Seniority)
  ) |>
  mutate(across(
    c(
      Distribution_channel,
      Seniority_bin,
      Type_risk,
      Area,
      Second_driver,
      Type_fuel
    ),
    as.factor
  )) |>
  mutate(
    Distribution_channel = fct_recode(
      Distribution_channel,
      "Agent" = "0",
      "Insurance broker" = "1"
    ),
    Type_risk = fct_recode(
      Type_risk,
      "Motorbikes" = "1",
      "Vans" = "2",
      "Passenger car" = "3",
      "Agricultural vehicle" = "4"
    ),
    Area = fct_recode(Area, "Rural" = "0", "Urban" = "1"),
    Second_driver = fct_recode(
      Second_driver,
      "Single driver" = "0",
      "Multiple drivers" = "1"
    ),
    # Replace missing value with the most common fuel type (Diesel)
    Type_fuel = replace_na(Type_fuel, "D"),
    Type_fuel = fct_recode(Type_fuel, "Petrol" = "P", "Diesel" = "D")
  ) |>
  filter(Exposure > 0) |>
  select(
    # Predictors (expect ID)
    ID,
    Distribution_channel,
    Seniority_bin,
    Type_risk,
    Area,
    Second_driver,
    Power,
    Value_vehicle,
    Type_fuel,
    Car_Age,
    Driver_Age,
    Driver_Age_bin,
    License_Age,
    License_Age_bin,
    # Response
    Claim_Amount = Cost_claims_year,
    Claim_Count = N_claims_year,
    # Offset term (Exposure)
    Exposure
  )

# Output cleaned data ----------------------------------------------------

arrow::write_parquet(clean_data, fs::path("clean_data", "motor_data.parquet"))

# Data exploration -------------------------------------------------------

# clean_data |>
#   mutate(
#     Seniority_bin = fct_collapse(Seniority_bin, "Early" = c("1", "2", "3"))
#   ) |>
#   count(Seniority_bin, wt = Exposure)

# clean_data |>
#   count(Seniority, wt = Exposure, sort = TRUE)

# clean_data |>
#   group_by(Seniority_bin) |>
#   summarise(Exposure = sum(Exposure)) |>
#   ggplot() +
#   geom_col(aes(x = Seniority_bin, y = Exposure))

# clean_data |>
#   ggplot(aes(Seniority, weight = Exposure)) +
#   geom_histogram(binwidth = 1, alpha = 0.8, fill = "steelblue") +
#   theme_minimal(base_family = "Inter", base_size = 12)

# clean_data |>
#   group_by(Driver_Age_bin) |>
#   summarise(Exposure = sum(Exposure)) |>
#   ggplot() +
#   geom_col(aes(x = Driver_Age_bin, y = Exposure))

# clean_data |>
#   count(Cylinder_capacity, Type_risk, sort = TRUE) |>
#   mutate(Type_risk = as.factor(Type_risk)) |>
#   ggplot(aes(Cylinder_capacity, n)) +
#   geom_point(aes(color = Type_risk))

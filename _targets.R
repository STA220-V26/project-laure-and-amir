# Created by use_targets().
# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("readr", "dplyr", "stringr", "lubridate", "janitor", "curl", "fs"), 
  format = "qs"
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(

  # load
   tar_target(
    name = data_zip,
    command = download_data(),
    format = "file"
  ), 

  tar_target(
    name = patients_raw, # download the patient data
    command = load_patients(data_zip) #function
  ),

  tar_target(
    allergies_raw,
    load_allergies(data_zip) 
  ),

  # clean
  tar_target(
    patients_clean,
    clean_patients(patients_raw)
  ),

    tar_target(
    pollen,
    clean_pollen(allergies_raw)
  ),

  # Link and summary
    tar_target(
      patients_pollen,
      link_patients_pollen(patients_clean, pollen)
    ),
  tar_target(
    pollen_by_state,
    rate_by_state(patients_pollen)
  ),

  # Chi2 test - difference in allergy rates btw states?
  tar_target(
    chi2_state,
    test_pollen_chi2(
      patients_pollen, group = "state"
    )
  )
)

# tar_make()                  # start the pipeline
# tar_read(pollen_by_state)   # see just a result
# tar_visnetwork() # if I want to see the network

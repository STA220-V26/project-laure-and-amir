# Created by use_targets().
# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble"), 
  format = "qs"
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(

  tar_target(
    name = download, # name of the target
    command = download_data() #function
  ),

  tar_target(
    patients_raw,
    load_patients() 
  ),

  tar_target(
    patients_clean,
    clean_patients(patients_raw)
  )
)

# tar_visnetwork() # if I want to see the network

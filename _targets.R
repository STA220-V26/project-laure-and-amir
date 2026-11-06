# Created by use_targets().
# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("readr", "dplyr", "stringr", "curl", "fs", "ggplot2", "usmap", "scales"),
  format = "qs"
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# target list:
list(

  # load
   tar_target(
    name = data_zip,                  # download the course data file (zip)
    command = download_data(),
    format = "file"
  ), 

  tar_target(
    name = patients_raw,              # read the patient data from zip
    command = load_patients(data_zip) 
  ),

  tar_target(                         # read the allergy data from zip
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
    test_pollen_chi2(patients_pollen)
  ),

  # The map (supplementary)
    tar_target(
    pollen_map,
    plot_pollen_map(pollen_by_state)
  )
)

# tar_make()                  # to copy-paste in the console start the pipeline but NOT UNCOMMENT!!!! (loop)
# tar_read(pollen_by_state)   # see just a result
# tar_read(chi2_state         # to see chi2
# tar_read(pollen_map)        # to see the map
# tar_visnetwork()            # if I want to see the network
# next line: to install only the missing packages
# install.packages(setdiff(c("package name","other packages name"), rownames(installed.packages())))

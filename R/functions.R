# used packages: readr, dplyr, stringr, lubridate, janitor



# Load -------------------------------------------------------------------

# load the data from the git data file of the course
download_data <- function(path = "data/data.zip") {
  dir_create(fs::path_dir(path))
  if (!file_exists(path)) {
    curl_download(
      "https://github.com/eribul/cs/raw/refs/heads/main/data.zip",
      path,
      quiet = FALSE
    )
  }
  path
}

# to read from zip
read_from_zip <- function(zip_path, file) {
  readr::read_csv(unz(zip_path, 
                  paste0("data-fixed/", file)),
                  show_col_types = FALSE)
}


load_patients  <- function(zip_path) read_from_zip(zip_path, "patients.csv")
load_allergies <- function(zip_path) read_from_zip(zip_path, "allergies.csv")


# Summary of checks on the raw data --------------------------------------

check_data <- function(patients_raw, allergies_raw, pollen) {
  checks <- c(
    no_dupl_patients   = !any(duplicated(patients_raw$id)),
    no_death_bef_birth = all(is.na(patients_raw$deathdate) |
    patients_raw$deathdate >= patients_raw$birthdate),
    allpoll_with_pat   = all(pollen$patient %in% patients_raw$id),
    no_dupl_poll       = !any(duplicated(pollen))
  )
  
  if (all(checks)) {
    message("Data checks OK: no duplicated patients, no death before birth, every pollen record has a patient, no duplicated pollen records.")
  } else {
    message("Data checks PROBLEM: ", paste(names(checks)[!checks], collapse = ", "))
  }
  
  list(
    checks      = checks,
    n_patients  = nrow(patients_raw),
    n_allergies = nrow(allergies_raw),
    missing     = colSums(is.na(patients_raw)),
    per_state   = table(patients_raw$state)
  )
}


# Clean the data ---------------------------------------------------------

# only useful columns and verifications done before on potential issues (detailed in readme)
clean_patients <- function(patients_raw) {
  patients_raw |>
    select(id, birthdate, deathdate, gender, state, county)
}

# Pollen allergies only (no other types) - tree or grass pollen (or both - they have one line for each)
clean_pollen <- function(allergies_raw) {
  allergies_raw |>
    filter(str_detect(description, "pollen")) |>
    mutate(pollen_type = if_else(
      str_detect(description, "Tree"), "tree", "grass"
    )) |>
    select(patient, start, pollen_type)
}

# Link patients and allergies ----------------------------------------------

# patients with both grass and pollen have 1 line for each -> to take into account in link

link_patients_pollen <- function(patients_clean, pollen) {
  pollen_par_patient <- pollen |>
    group_by(patient) |>
    summarise(
      first_pollen_date = min(start),
      n_pollen_types    = n_distinct(pollen_type),
      .groups = "drop"
    )
    patients_clean |>
    left_join(pollen_par_patient, by = c("id" = "patient")) |>
    mutate(
      pollen_allergy = !is.na(first_pollen_date),                      # pollen_allergy = True if has a date of first allergy diagnosis
      both_pollens   = coalesce(n_pollen_types, 0L) == 2,              # both_pollen = true if allergic to both gras and tree (had 2 in n_pollen_types)
      # age at the first diagnosis (explorative supplementary analysis), cut for it to be a natural number
      age_at_onset   = floor(as.numeric(first_pollen_date - birthdate) / 365.25)
    )
}
  

# Summary by state --------------------------------------------------------

rate_by_state <- function(patients_pollen) {
  patients_pollen |>
    group_by(state) |>
    summarise(
      n_patients = n(),
      n_pollen   = sum(pollen_allergy),
      rate       = n_pollen / n_patients,
      .groups = "drop"
    ) |>
    arrange(desc(rate))
}


# Chi2 Test --------------------------------------------------------------

test_pollen_chi2 <- function(patients_pollen) {
  chisq.test(table(patients_pollen$state, patients_pollen$pollen_allergy))
}
# H0 would be that all states have the same rate of allergy
# 6 states of 1100 patients so big enough to do a Chi Square


# Chi 2 checks -----------------------------------------------------------

check_chi2 <- function(patients_pollen) {
  tbl    <- table(patients_pollen$state, patients_pollen$pollen_allergy)
  exp    <- suppressWarnings(chisq.test(tbl)$exp)

  checks <- c(
    a_row_per_patient   = !any(duplicated(patients_pollen$id)),
    no_missing_state    = !any(is.na(patients_pollen$state)),
    all_expected_min5   = all(exp >= 5)
  )

  if (all(checks)) {
    message("Chi2 conditions OK: 1row/patient, no missing state, all expected counts >= 5 (smallest: ", round(min(exp), 1), ").")
  } else {
    message("Chi2 conditions PROBLEM: ", paste(names(checks)[!checks], collapse = ", "))
  }

  list(checks = checks, table = tbl, expected = round(exp, 1))
}

# Supplementary map ------------------------------------------------------

plot_pollen_map <- function(pollen_by_state) {
  plot_usmap(data = pollen_by_state, values = "rate", regions = "states") +
    scale_fill_distiller(
      palette = "YlOrRd", direction = 1,
      limits = c(0.05, 0.10),
      labels = percent, name = "Pollen allergy", na.value = "grey90"
    ) +
    labs(title = "Proportion of patients with a pollen allergy, by state") +
    theme(legend.position = "right")
}
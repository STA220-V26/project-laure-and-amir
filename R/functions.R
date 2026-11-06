# used packages: readr, dplyr, stringr, lubridate, janitor



# Load -------------------------------------------------------------------

# load the data from the git data file of the course
download_data <- function(path = "data/data.zip") {
  fs::dir_create(fs::path_dir(path))
  if (!fs::file_exists(path)) {
    curl::curl_download(
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
                  show_col_types = FALSE) |>
    janitor::clean_names()  #put the column name in small letters (no capital letter)
}

load_patients  <- function(zip_path) read_from_zip(zip_path, "patients.csv")
load_allergies <- function(zip_path) read_from_zip(zip_path, "allergies.csv")


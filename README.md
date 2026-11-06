# Pollen allergy across US states and counties

STA220 – Data project (ECS4) · Laure & Amir

## Research question

Is the distribution of pollen allergies unequal across the territory (states or counties)?

**Hypothesis:** the proportion of patients with a pollen allergy differs between states/counties.
We will assess this with a chi-square test of independence.

**Exploratory (if time allows):**
- a map coloured by the rate of pollen allergy
- the age/date at which pollen allergies first appear, and whether it differs between areas

## Data

Synthetic patient data (Synthea) provided in the course (`data.zip`, downloaded automatically by the pipeline).
Two datasets are linked by patient id:

- `patients.csv` – one row per patient, including state and county
- `allergies.csv` – one row per allergy diagnosis

The rate of pollen allergy is computed as: patients with a pollen allergy / all patients in the registry for that area.

Data files are stored in `data/` and are not under version control.

## How to run

```r
install.packages(c("targets", "qs2", "readr", "dplyr", "stringr",
                   "lubridate", "janitor", "curl", "fs"))
targets::tar_make()
```

## Project structure

```
.
├── .gitignore         – files excluded from Git
├── R/
│   └── functions.R    – functions used by pipeline
├── README.md          
├── _targets.R         – targets pipeline
└── data/              – raw data (downloaded automatically, not versioned)
```

## Data validation
We explored the data and ran a certain amount of checks before designing the clean functions :no deaths or diagnoses before birth, no diagnoses after death, no duplicated patient ids and no duplicated pollen records were found. All pollen records are of type allergy (category environment). 601 of 6,851 patients (8.8%) have a pollen allergy; 410 of them have both tree and grass pollen allergy.
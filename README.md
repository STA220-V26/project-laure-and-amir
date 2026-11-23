# Pollen allergy across US states

STA220 – Data project (ECS4) · Laure Rapp & Amir Dinari

## Research question

Is the distribution of pollen allergies unequal across the territory (states)?

**Hypothesis:** the proportion of patients with a pollen allergy differs between states. We will assess this with a chi-square test of independence.

**Exploratory:**

- a map coloured by the rate of pollen allergy (done)
- the age at which pollen allergies first appear, and whether it differs between states (age at first diagnosis computed: almost always 0–1 year, so not analysed further)

## Data

Synthetic patient data provided in the course (`data.zip`, downloaded automatically by the pipeline). Two datasets are linked by patient id:

- `patients.csv` – one row per patient, including state and county
- `allergies.csv` – one row per allergy diagnosis

The rate of pollen allergy is computed as: patients with a pollen allergy / all patients in the registry for that area.

Data files are stored in `data/` and are not under version control.

## Main result

No evidence that the proportion of pollen allergy differs between states (chi-square test, p = 0.83).
Results, figures, interpretation and possible further analyses are in `presentation.qmd`, rendered as a report (`report.html`) and as slides (`slides.html`).

## How to run

The package versions are recorded with [renv](https://rstudio.github.io/renv/) in `renv.lock`, so that anyone who runs the code uses the same packages (the R version used is also written in `renv.lock`).

1.  **Get the project.** Clone the repository and open the project folder in RStudio or Positron (the R working directory must be the project folder).

    ``` bash
    git clone https://github.com/STA220-V26/project-laure-and-amir.git
    ```

2.  **Install the packages.** renv starts automatically when R is opened in the folder (through `.Rprofile`). Then install the exact versions from `renv.lock`:

    ``` r
    renv::restore()
    ```

    If renv is not installed yet, run `install.packages("renv")` first.

3.  **Run the pipeline.** The data (`data.zip`) are downloaded automatically the first time.

    ``` r
    targets::tar_make()
    ```

4.  **See the results.**

    ``` r
    targets::tar_read(data_check)       # checks of the raw data + summary
    targets::tar_read(pollen_by_state)  # pollen allergy rate by state
    targets::tar_read(chi2_check)       # conditions for the chi-square test
    targets::tar_read(chi2_state)       # chi-square test
    targets::tar_read(pollen_map)       # map
    targets::tar_visnetwork()           # graph of the pipeline
    ```

    `tar_make()` also renders the report and the slides: open `report.html` or `slides.html`.

**For contributors:** after installing a new package, run `renv::snapshot()` and commit `renv.lock`.

## Project structure

```         
.
├── .gitignore         – files excluded from Git
├── .Rprofile          – starts renv when R is opened in the project
├── R/
│   └── functions.R    – functions used by the pipeline
├── README.md
├── _targets.R         – targets pipeline
├── presentation.qmd   – Quarto source: reads the results from the pipeline (tar_read)
├── report.html        – rendered report (web page)
├── slides.html        – rendered slides (revealjs)
├── renv.lock          – package versions (renv)
├── renv/              – renv settings (the project library itself is not versioned)
└── data/              – raw data (downloaded automatically, not versioned)
```

## Data validation

We explored the data and ran several checks before writing the cleaning functions: no deaths or diagnoses before birth, no diagnoses after death, no duplicated patient ids and no duplicated pollen records were found. The main checks are repeated in the pipeline (`tar_read(data_check)`), including no pollen diagnosis before birth or after death. All pollen records are of type allergy (category environment). 601 of 6,851 patients (8.8%) have a pollen allergy; 410 of them have both tree and grass pollen allergy.
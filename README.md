------------------------------------------------------------------------

# BIOS 731 Homework 2

## A Simulation Study Investigating the Bootstrap

Author: **Ruilong Chen**

This repository contains all code required to reproduce the simulation study for Homework 2. The goal of this project is to evaluate Wald, bootstrap percentile, and bootstrap-t confidence intervals for the treatment effect in a linear regression model using a large-scale simulation study.

------------------------------------------------------------------------

# Project Structure

```         
bios731_hw2_RuilongChen/
│
├── HW_simulation-2.qmd                 # Main report (knits to PDF)
├── README.md               # This file
├── .gitignore
│
├── R/
│   ├── config.R            # Global simulation settings
│   ├── ci_methods.R        
│   ├── estimators.R           
│   ├── ci_methods.R         
│   ├── one_rep.R           
│   ├── run_scenario.R    
│   └── run_all.R           
│
└── data/                   # Simulation outputs (NOT tracked by git)
```

The **data/** folder contains `.rds` files produced by the simulation. These files are excluded from version control via `.gitignore`.

------------------------------------------------------------------------

# Simulation Overview

We compare three 95% confidence interval methods for the treatment effect:

1.  Wald confidence interval
2.  Bootstrap percentile interval
3.  Bootstrap-t interval

The simulation evaluates:

-   Bias of the treatment effect estimator
-   Empirical coverage probability
-   Distribution of standard error estimates
-   Computation time

Simulation factors:

| Factor                | Levels       |
|-----------------------|--------------|
| Sample size           | 10, 50, 500  |
| True treatment effect | 0, 0.5, 2    |
| Error distribution    | Normal, t(3) |

Total scenarios: **18**

Each scenario uses **475 Monte-Carlo replicates**.

------------------------------------------------------------------------

# Bootstrap Settings and Trade-off

The assignment suggested:

-   B = 500
-   B_inner = 100

However, running the full simulation with these values would require approximately **10 hours** of computation.

To balance computational cost and feasibility, the simulation uses:

-   **B = 50** outer bootstrap resamples
-   **B_inner = 10** inner bootstrap resamples

With parallelization across scenarios, the full simulation runs in approximately **6 minutes**.

This choice introduces additional Monte Carlo variability in the bootstrap intervals, which is discussed in the report.

------------------------------------------------------------------------

# How to Reproduce the Simulation

### Step 1 — Clone the repository

``` bash
git clone <repo-url>
```

Open the project using the `.Rproj` file.

------------------------------------------------------------------------

### Step 2 — Run the simulation

From the R console:

``` r
source("R/run_all.R")
run_all()
```

This will:

-   Run all 18 scenarios in parallel
-   Save results as `.rds` files in the `data/` folder

------------------------------------------------------------------------

### Step 3 — Generate the report

Open and knit:

```         
HW_simulation-2.qmd
```

This will:

-   Load the saved simulation results
-   Produce tables and figures
-   Generate the final PDF report

------------------------------------------------------------------------

# Reproducibility Notes

-   All paths are relative.
-   Random seeds are set within the simulation code.
-   Running the project from the root directory will reproduce all results.

------------------------------------------------------------------------

# Required R Packages

``` r
tidyverse
future
future.apply
ggplot2
knitr
kableExtra
```

Install missing packages if necessary.

------------------------------------------------------------------------

# Contact

Ruilong Chen BIOS 731 — Advanced Statistical Computing

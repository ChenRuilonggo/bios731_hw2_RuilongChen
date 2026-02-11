# R/run_all.R

source("R/config.R")
source("R/sim_data.R")
source("R/estimators.R")
source("R/ci_methods.R")
source("R/one_rep.R")
source("R/run_scenario.R")

library(dplyr)
library(tidyr)
library(future.apply)

run_all <- function(cfg = CFG) {
  scenarios <- make_scenarios()
  
  future::plan(future::multisession)
  
  future.apply::future_lapply(seq_len(nrow(scenarios)), function(i) {
    sc <- scenarios[i, ]
    run_one_scenario(sc$n, sc$beta_treat, sc$err_dist, sc$scenario_id, cfg,
                    scene_idx = i, n_scenes = nrow(scenarios))
    NULL
  })

  
  future::plan(future::sequential)
  invisible(TRUE)
}

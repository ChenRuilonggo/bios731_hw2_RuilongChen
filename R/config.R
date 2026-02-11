# R/config.R

CFG <- list(
  n_sim   = 475,
  level   = 0.95,
  B       = 50,
  B_inner = 10,
  beta0   = 0,
  p_treat = 0.5,
  seed_base = 1
)

make_scenarios <- function() {
  tidyr::crossing(
    n = c(10, 50, 500),
    beta_treat = c(0, 0.5, 2),
    err_dist = c("normal", "t3")
  ) |>
    dplyr::mutate(
      scenario_id = paste0("n", n, "_b", beta_treat, "_", err_dist)
    )
}

ensure_data_dir <- function(path = "data") {
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
}


scenario_seed <- function(n, beta_treat, err_dist, base_seed = 12345) {
  key <- paste0("n", n, "_b", beta_treat, "_", err_dist)
  

  seed_val <- sum(utf8ToInt(key))
  

  as.integer(base_seed + seed_val)
}

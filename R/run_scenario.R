log_msg <- function(path, msg) {
  # Append a timestamped message to a log file
  line <- paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | ", msg, "\n")
  cat(line, file = path, append = TRUE)
}



run_one_scenario <- function(n, beta_treat, err_dist, scenario_id, cfg,
                             scene_idx = NA_integer_, n_scenes = NA_integer_) {
  ensure_data_dir("data")
  if (!dir.exists("logs")) dir.create("logs")

  log_file <- file.path("logs", paste0("log_", scenario_id, ".txt"))

  # Scenario header
  log_msg(log_file, "======================================")
  log_msg(log_file, paste0("Starting scenario ", scene_idx, "/", n_scenes, ": ", scenario_id))
  log_msg(log_file, paste0("n=", n, " | beta=", beta_treat, " | err=", err_dist))

  # Reproducible per scenario
  seed <- scenario_seed(n, beta_treat, err_dist, cfg$seed_base)
  set.seed(seed)
  log_msg(log_file, paste0("Seed=", seed))

  reps <- vector("list", cfg$n_sim)

  for (s in seq_len(cfg$n_sim)) {
    if (s == 1 || s %% 25 == 0) {
      log_msg(log_file, paste0("Progress: sim ", s, "/", cfg$n_sim))
    }
    reps[[s]] <- one_rep(n, beta_treat, err_dist, cfg)
  }

  out <- dplyr::bind_rows(reps) |>
    dplyr::mutate(
      n = n,
      beta_treat = beta_treat,
      err_dist = err_dist,
      scenario_id = scenario_id,
      sim_id = dplyr::row_number()
    )

  out_path <- file.path("data", paste0("sim_", scenario_id, ".rds"))
  saveRDS(out, file = out_path)

  log_msg(log_file, paste0("Finished scenario: ", scenario_id))
  log_msg(log_file, paste0("Saved: ", out_path))

  invisible(out)
}



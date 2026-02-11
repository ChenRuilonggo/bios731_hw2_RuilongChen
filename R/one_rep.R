# R/one_rep.R

one_rep <- function(n, beta_treat, err_dist, cfg) {
  dat <- simulate_data(
    n = n,
    beta_treat = beta_treat,
    err_dist = err_dist,
    beta0 = cfg$beta0,
    p_treat = cfg$p_treat
  )
  
  est <- fit_ols_treat(dat)
  beta_hat <- est$beta_hat
  se_hat   <- est$se_hat
  
  # Wald
  t_wald <- system.time({
    ci1 <- ci_wald(beta_hat, se_hat, level = cfg$level)
  })[["elapsed"]]
  
  # Bootstrap percentile
  t_perc <- system.time({
    out2 <- ci_boot_percentile(dat, B = cfg$B, level = cfg$level)
    ci2 <- out2$ci
    se_boot <- out2$se_boot
  })[["elapsed"]]
  
  # Bootstrap t (nested)
  t_bt <- system.time({
    out3 <- ci_boot_t_nested(dat, B = cfg$B, B_inner = cfg$B_inner, level = cfg$level)
    ci3 <- out3$ci
  })[["elapsed"]]
  
  data.frame(
    beta_hat = beta_hat,
    se_hat = se_hat,
    se_boot = se_boot,
    cover_wald = covers(ci1, beta_treat),
    cover_perc = covers(ci2, beta_treat),
    cover_bt   = covers(ci3, beta_treat),
    time_wald = t_wald,
    time_perc = t_perc,
    time_bt   = t_bt
  )
}

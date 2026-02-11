# R/ci_methods.R

ci_wald <- function(beta_hat, se_hat, level = 0.95) {
  alpha <- 1 - level
  z <- qnorm(1 - alpha / 2)
  c(beta_hat - z * se_hat, beta_hat + z * se_hat)
}

boot_beta_star <- function(dat, B) {
  n <- nrow(dat)
  beta_star <- numeric(B)
  
  for (b in seq_len(B)) {
    idx <- sample.int(n, size = n, replace = TRUE)
    est <- fit_ols_treat(dat[idx, , drop = FALSE])
    beta_star[b] <- est$beta_hat
  }
  
  # Remove invalid bootstrap estimates (NA/Inf)
  beta_star[is.finite(beta_star)]
}


ci_boot_percentile <- function(dat, B = 500, level = 0.95) {
  
  beta_star <- boot_beta_star(dat, B)
  
  # If too few valid bootstrap estimates remain,
  # return NA to avoid unstable quantiles.
  if (length(beta_star) < 20) {
    return(list(ci = c(NA, NA), se_boot = NA))
  }
  
  alpha <- 1 - level
  ci <- as.numeric(
    quantile(beta_star, probs = c(alpha/2, 1 - alpha/2))
  )
  
  list(ci = ci, se_boot = sd(beta_star))
}


ci_boot_t_nested <- function(dat, B = 500, B_inner = 100, level = 0.95) {
  
  n <- nrow(dat)
  
  # Original estimate
  orig <- fit_ols_treat(dat)
  beta_hat <- orig$beta_hat
  se_hat   <- orig$se_hat
  
  # If original fit fails (extremely rare), return NA
  if (!is.finite(beta_hat) || !is.finite(se_hat)) {
    return(list(ci = c(NA, NA)))
  }
  
  t_star <- numeric(B)
  
  for (b in seq_len(B)) {
    
    # ----- outer bootstrap -----
    idx_b <- sample.int(n, size = n, replace = TRUE)
    dat_b <- dat[idx_b, , drop = FALSE]
    
    est_b <- fit_ols_treat(dat_b)
    
    # If outer bootstrap sample is degenerate, skip
    if (!is.finite(est_b$beta_hat)) {
      t_star[b] <- NA
      next
    }
    
    beta_b <- est_b$beta_hat
    
    # ----- inner bootstrap to estimate SE(beta_b) -----
    beta_inner <- numeric(B_inner)
    
    for (k in seq_len(B_inner)) {
      idx_k <- sample.int(n, size = n, replace = TRUE)
      est_k <- fit_ols_treat(dat_b[idx_k, , drop = FALSE])
      beta_inner[k] <- est_k$beta_hat
    }
    
    # Remove invalid inner bootstrap estimates
    beta_inner <- beta_inner[is.finite(beta_inner)]
    
    # If too few valid inner bootstrap samples, skip
    if (length(beta_inner) < 10) {
      t_star[b] <- NA
      next
    }
    
    se_b <- sd(beta_inner)
    
    if (!is.finite(se_b) || se_b <= 0) {
      t_star[b] <- NA
      next
    }
    
    # bootstrap t statistic
    t_star[b] <- (beta_b - beta_hat) / se_b
  }
  
  # Remove invalid t*
  t_star <- t_star[is.finite(t_star)]
  
  # If too few valid t statistics remain, return NA
  if (length(t_star) < 20) {
    return(list(ci = c(NA, NA)))
  }
  
  alpha <- 1 - level
  
  q_hi <- quantile(t_star, probs = alpha/2)
  q_lo <- quantile(t_star, probs = 1 - alpha/2)
  
  ci <- c(beta_hat - q_lo * se_hat,
          beta_hat - q_hi * se_hat)
  
  list(ci = ci)
}

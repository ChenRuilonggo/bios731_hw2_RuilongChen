# R/estimators.R

fit_ols_treat <- function(dat) {
  
  # If treatment has no variation in the sample,
  # the regression coefficient is not identifiable.
  # This happens frequently in bootstrap samples with small n.
  if (length(unique(dat$x)) < 2) {
    return(list(beta_hat = NA_real_, se_hat = NA_real_))
  }
  
  fit <- lm(y ~ x, data = dat)
  cf  <- summary(fit)$coefficients
  
  # Extra safety check: if the coefficient was dropped
  # due to singular design matrix, return NA.
  if (!("x" %in% rownames(cf))) {
    return(list(beta_hat = NA_real_, se_hat = NA_real_))
  }
  
  list(
    beta_hat = unname(cf["x", "Estimate"]),
    se_hat   = unname(cf["x", "Std. Error"])
  )
}

covers <- function(ci, truth) {
  isTRUE(ci[1] <= truth && truth <= ci[2])
}

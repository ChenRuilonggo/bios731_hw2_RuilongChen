# R/sim_data.R

simulate_data <- function(n, beta_treat, err_dist = c("normal", "t3"),
                          beta0 = 0, p_treat = 0.5) {
  err_dist <- match.arg(err_dist)
  
  x <- rbinom(n, size = 1, prob = p_treat)
  
  if (err_dist == "normal") {
    eps <- rnorm(n, mean = 0, sd = sqrt(2))
  } else {
    nu <- 3
    u  <- rt(n, df = nu)
    eps <- u * sqrt(2 * (nu - 2) / nu)  # Var = 2
  }
  
  y <- beta0 + beta_treat * x + eps
  data.frame(y = y, x = x)
}

# --- Potential for Conflict Index --- #
# Vaske, J. J., Beaman, J., Barreto, H., & Shelby, L. B. (2010).
# An Extension and Further Validation of the Potential for Conﬂict Index.
# Leisure Sciences, 32(X), 240–254

############################
### >>> qd_pci1
############################

#' Potential conflict index (first variant)
#'
#' questionnaire data analysis: potential conflict index
#' @param x vector with scores of the respondents
#' @param scale_values vector with levels; default: -2:2
#' @param x_is_table if TRUE, x is table with the distribution of the scores
#'
#' @return PCI-score (potential for conflict index)
#' @export
#' @family plotting
#'
#' @examples
#' \dontrun{
#'  set.seed(201)
#'  Xv <- sample(-2:2, size = 100, replace = TRUE) #random responses
#'  Yv <- rep(c(-2,2),50) #most extreme difference
#'  Zv <- rep(2,100) #minimal difference

#'  #qd_pci1
#'  qd_pci1(Xv, scale_values = -2:2, x_is_table = FALSE) # 0.4
#'  qd_pci1(Yv, scale_values = -2:2, x_is_table = FALSE) # 1
#'  qd_pci1(Zv, scale_values = -2:2, x_is_table = FALSE) # 0
#' }
#'
qd_pci1 <- function(x, scale_values = c(-2:2),
                    x_is_table = FALSE){

  ### ERROR CONTROL AND PREPARE DATA
  if (scale_values[1] != -scale_values[length(scale_values)])
    stop("index should be symmetric")
  if (x_is_table) {
    if (length(x) != length(scale_values))
      stop("table of x should contain countdata for every scale-value")
  } else {
    x <- table(factor(x, levels = scale_values))
  }
  S <- NULL #To avoid the compilation NOTE

  ### PREP DATA
  countdata <- data.frame(N = as.numeric(x),
                          X = abs(scale_values),
                          S = sign(scale_values))
  negatives <- subset(countdata, S == -1)
  positives <- subset(countdata, S == 1)
  neutrals  <- subset(countdata, S == 0)

  #CALC DATA
  sum_Xa <- sum(positives$N * positives$X)
  sum_Xu <- sum(negatives$N * negatives$X)
  Xt     <- sum_Xa + sum_Xu
  n      <- sum(positives$N) + sum(negatives$N) + sum(neutrals$N)
  Z      <- n * max(c(min(scale_values), max(scale_values)))

  #RETURN RESULT
  (1 - abs((sum_Xa / Xt) - (sum_Xu / Xt))) * Xt/Z
}




###########################
### >>> qd_pci2
###########################


#' Distance matrix for qd_pci2
#'
#'Calculates distance matrix for the function qd_pci2
#' @param x vector with the scores of the respondents
#' @param m m value in the formula (see details)
#' @param p power value in the formula (see details)
#' @details
#' \deqn{Dp_{x,y} = (|r_{x} - r_{y}|) - (m-1))^{p}}
#' \deqn{if sign(r_{x} \neq r_{y}) \\
#' else d_{x,y} = 0}
#' Dp_x,y = (|r_x - r_y| - (m-1))^p
#' @return single value containing pci index
#' @examples
#' \dontrun{
#' #'set.seed(201)
#'Xv <- sample(-2:2, size = 100, replace = TRUE) #random responses
#'qd_pci2(Xv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 0.37
#' }
#' @export
#' @family plotting


qd_pci2_D <- function(x, m=1, p=1){
  d <- matrix(nrow = length(x), ncol = length(x), data = NA)
  for (i in 1:nrow(d)) {
    for (j in 1:i) {
      if (abs(c(sign(x[i]) - sign(x[j]))) == 2) {
        d[i,j] <- d[j,i] <- (abs(x[i] - x[j]) - (m - 1)) ^ p
      }
      else {
        d[i,j] <- d[j,i] <- 0
      }
    }
  }
  return(d)
}

###----------------

#' Potential conflict index (second variant)
#'
#' Calculates the potential conflict index based on the distance matrix between responses.
#'
#' @param x vector with scores of the respondents
#' @param scale_values vector with levels; default: -2:2
#' @param x_is_table if TRUE, x is table with the distribution of the scores
#' @param m correction; default: m = 1
#' @param p power; default: p = 1
#' @param print flag; if TRUE print results
#'
#' @return PCI-score (potential for conflict index)
#' @export
#' @family plotting
#'
#' @examples
#' \dontrun{
#'set.seed(201)
#'Xv <- sample(-2:2, size = 100, replace = TRUE) #random responses
#'Yv <- rep(c(-2,2),50) #most extreme difference
#'Zv <- rep(2,100) #minimal difference
#' #qd_pci2 - using D2 (m=1)
#'qd_pci2(Xv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 0.37
#'qd_pci2(Yv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 1
#'qd_pci2(Zv, scale_values = -2:2, x_is_table = FALSE, m = 1, p = 1) # 0

#qd_pci2 - using D1 (m=2)
#'qd_pci2(Xv, scale_values = -2:2, x_is_table = FALSE, m = 2, p = 1) # 0.31
#'qd_pci2(Yv, scale_values = -2:2, x_is_table = FALSE, m = 2, p = 1) # 1
#'qd_pci2(Zv, scale_values = -2:2, x_is_table = FALSE, m = 2, p = 1) # 0
#' }
qd_pci2 <- function(x, scale_values = c(-2:2),
                    x_is_table = FALSE, m = 1, p = 1, print = FALSE){

  ### ERROR CONTROL AND PREPARE DATA

  if (scale_values[1] != -scale_values[length(scale_values)])
    stop("index should be symmetric")
  if (x_is_table) {
    if (length(x) != length(scale_values))
      stop("table of x should contain countdata for every scale-value")
  } else {
    x <- table(factor(x, levels = scale_values))
  }

  ### PREP DATA

  #Total N
  Ntot <- sum(x)

  #call distance function
  d <- qd_pci2_D(scale_values, m = m, p = p)

  #matrix with counts
  n <- matrix(nrow = length(x), ncol = length(x), data = rep(x, length(x)))

  #Actual Distance
  #n = nk, t(n) = nh
  #d is distance matrix between the scale_value levels
  #d * nk * nh accounts for number of elements in each scale_value level
  #rowsums(d*n*t(n)) calculates the deltax for each level
  #diag(d)*diag(n)^2 actual distance with itself is subtracted
  #sum(...) sums the results for each level

  weightedsum <- sum(rowSums(d * n * t(n)) - (diag(d) * diag(n) * diag(n)))

  #Maximum Possible Distance
  #dmax = max distance between 2 single elements
  #even N: multiply with Ntot^2 = max distance
  #  if each element is at the extremes
  #odd N: multiply with Ntot^2 - 1
  dmax <- max(d)

  delta <- dmax * (Ntot^2 - Ntot %% 2) / 2

  #return the normalized sum
  if (print == TRUE) {
    cat("\nqd_pci2 (m =", m, ", p =", p, ",
       levels =", length(scale_values), ")\n")
    cat("------------------------------------\n")
    cat("Total actual distance:", weightedsum, "\n")
    cat("Maximum total distance:", delta, "\n")
    cat("Maximum distance:", dmax, "\n")
    cat("\nqd_pci2:", round(weightedsum / delta, 2),"\n")
  }

  return(invisible(weightedsum / delta))
}



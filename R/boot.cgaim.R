################################################################################
#
# Performs bootstrap on CGAIM
#
################################################################################

#' Boostrap CGAIM
#' 
#' Generates bootstrap replicates of a \code{cgaim} object.
#' 
#' @param object A \code{cgaim} object.
#' @param boot.type The type of bootstrap to perform. Currently
#' available type are \code{"residuals"}, \code{"wild"} and 
#' \code{"pairs"}. See details
#' @param bsamples A numerical matrix of observation indices specifying 
#' bootstrap samples.
#' Rows indicate observations and columns bootstrap samples.
#' If \code{NULL} (the default), samples are generated internally.
#' @param B Number of bootstrap samples to generate when \code{bsamples = NULL}.
#' @param l Block length for block-bootstrap. Samples are generated by
#'    resampling block of observation of length \code{l}. The classical
#'    bootstrap corresponds to \code{l = 1} (the default).
#' @param nc Positive integer. If \code{nc > 1}, the function is parallelized with \code{nc} indicating the number of cores to use.
#' 
#' @details
#' This function fits the \code{cgaim} on bootstrap samples.
#' It is called internally by the \code{\link{confint.cgaim}} function, but can also be
#' called directly to generate various statistics.
#' 
#' Three types of bootstrap are currently implemented. \code{"residuals"} 
#' (the default) resamples the residuals in \code{object} to then be added to fitted values, creating alternative response vectors. The \code{cgaim} is then fitted on these newly generated y values with the original x. \code{"wild"} is
#' similar except that residuals are multiplied by random draws from a
#' standard normal distribution before being added to fitted values. 
#' \code{"pairs"} resamples directly pairs of y and x to create 
#' bootstrap samples.
#' 
#' Bootstrap samples can either be prespecified by the user through
#' \code{bsamples} or generated internally. In the former case, 
#' the columns of \code{bsamples} indicate the number of replications \code{B} and
#' the rows should match the original number of observations. Internally
#' generated bootstrap samples are controlled by the number of replications
#' \code{B} and block length \code{l}, implementing block bootstrap.
#' The latter is particularly recommended for time series data.
#' 
#' As fitting a large number of \code{cgaim} models can be computationally
#' intensive, the function can be run in parallel, using the 
#' \code{\link{doParallel}} package. This can be done by setting the
#' argument \code{nc} to a value greater than 1, controlling the number
#' of cores used in parallelization.
#' 
#' @returns A \code{boot.cgaim} object with components
#'   \item{\code{boot}}{The bootstrap result. A list that includes all
#'     \code{B} replications of \code{alpha}, \code{beta}, \code{gfit} and
#'     \code{indexfit} organized in arrays.}
#'   \item{\code{obs}}{The original \code{object} passed to the function.}
#'   \item{\code{samples}}{The bootstrap samples. A matrix with indices 
#'     corresponding to original observations.}
#'   \item{\code{boot.type}}{The type of bootstrap performed.}
#'   \item{\code{B}}{The number of bootstrap replications.}
#'   \item{\code{l}}{The block length for block bootstrap.}
#' 
#'  
#' @examples 
#' # A simple CGAIM
#' n <- 200
#' x1 <- rnorm(n)
#' x2 <- x1 + rnorm(n)
#' z <- x1 + x2
#' y <- z + rnorm(n)
#' df1 <- data.frame(y, x1, x2) 
#' ans <- cgaim(y ~ g(x1, x2, acons = list(monotone = 1)), data = df1)
#' 
#' # Use function to compute confidence intervals (B should be increased)
#' set.seed(1989) 
#' boot1 <- boot.cgaim(ans, B = 10)
#' ci1 <- confint(boot1)
#' 
#' # Produces the same result as
#' set.seed(1989)
#' ci2 <- confint(ans, type = "boot", B = 10)
#' 
#' # Create sampling beforehand
#' bsamp <- matrix(sample(1:n, n * 10, replace = TRUE), n)
#' boot2 <- boot.cgaim(ans, bsamples = bsamp)
#' 
#' # Parallel computing (two cores)
#' \donttest{
#' boot3 <- boot.cgaim(ans, nc = 2)
#' }
#' 
#' @export
boot.cgaim <- function(object, boot.type = c("residuals", "wild", "pairs"), 
  bsamples = NULL, B = 100, l = 1, nc = 1)
{
  # Check boot.type
  boot.type <- match.arg(boot.type)
  
  # Extract useful features
  n <- length(object$fitted)
  
  #----- Get model specifications
  pars <- object[c("x", "index", "control", "Cmat", "bvec", "sm_mod")]
  pars$w <- object$weights
  
  #----- Create samples
  if (is.null(bsamples)){
    firstb <- sample(seq_len(n - l + 1), ceiling((n * B) / l), replace = TRUE)
    blocks <- sapply(firstb, function(b) b:(b + l - 1))
    bsamples <- matrix(blocks[seq_len(n * B)], nrow = n, ncol = B)
  } else {
    B <- ncol(bsamples)
  }
  
  #----- Refit on bootstrap samples
  
  # Prepare loop: either parallel or not
  if (nc > 1){
    `%mydo%` <- foreach::`%dopar%`
    doParallel::registerDoParallel(cores = nc)
  } else {
    `%mydo%` <- foreach::`%do%`
  }
  
  # Loop across samples
  b <- NULL # So that 'b' does not bother R CMD CHECK
  allres <- foreach::foreach(b = seq_len(B), .packages = "cgaim") %mydo% {
    
    # Get sample
    bsamp <- bsamples[, b]
    
    # Get y (and x) values
    if (boot.type == "pairs"){
      pars$y <- object$y[bsamp]
      attr(pars$y, "varname") <- attr(object$y, "varname")
      pars$x <- object$x[bsamp,]
      if (!is.null(pars$sm_mod$Xcov)) pars$sm_mod$Xcov <- 
        pars$sm_mod$Xcov[bsamp,]
      pars$w <- object$w[bsamp]
    } else {
      bres <- object$residuals[bsamp]
      if (boot.type == "wild") bres <- bres * stats::rnorm(n)
      pars$y <- object$fitted + bres
      attributes(pars$y) <- attributes(object$y)
    }
    
    # Fit model
    # ::: for do.call. Necessary within parallelized worker
    fitfun <- get("cgaim.fit", asNamespace("cgaim")) 
    resb <- do.call(fitfun, pars)
    
    # Return
    resb[c("alpha", "beta", "gfit", "indexfit")]
  }
  
  # Stop clusters
  if (nc > 1) doParallel::stopImplicitCluster()
  
  #----- Reshape and return
  
  # Reshape to have each parameter in arrays
  out <- lapply(names(allres[[1]]), 
    function(nm) sapply(allres, "[[", nm, simplify = "array"))
  names(out) <- names(allres[[1]])
  
  # Return
  ans <- list(boot = out, obs = object, 
    samples = bsamples, boot.type = boot.type, B = B, l = l)
  class(ans) <- "boot.cgaim"
  ans
}
% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/g.R, R/s.R
\name{g}
\alias{g}
\alias{s}
\title{Defining terms in CGAIM formula}
\usage{
g(..., label = NULL, acons = list(), Cmat = NULL, bvec = 0,
  fcons = NULL, s_opts = list())

s(x, fcons = NULL, s_opts = list())
}
\arguments{
\item{...}{Variables entering the index. May include vectors and 
matrices.}

\item{label}{Character (or any object that can coerced into one) labeling the index. By default, named after the first variable in \code{...}.}

\item{acons}{A list of character naming common constraints to be applied to 
the index weights \code{alpha}. See \code{\link{build_constraints}} for 
allowed constraints.}

\item{Cmat}{A constraint matrix for alpha coefficients. Number of
columns must match the number of variables in the index.}

\item{bvec}{Numeric vector of constraint bounds. Recycled if necessary.}

\item{fcons}{The type of shape constraint to be applied on the smooth 
function. See details.}

\item{s_opts}{A named list of options to be passed to the smoothing of 
ridge functions. Depends on the method used to smooth additive models. 
See details.}

\item{x}{Covariate on which the smooth is applied.}
}
\value{
A matrix containing the variables passed in \code{...} with 
additional attributes:
\item{fcons}{The shape constraint for smoothing.}
\item{s_opts}{Arguments passed to the smoothing function.}
\item{label}{The label of the term.}

The following attributes result from a call to \code{g} only:
\item{term}{The terms in the index.}
\item{nterms}{The number of variables in the index.}
\item{Cmat}{The constraint matrix for alpha coefficients.}
\item{bvec}{The associated boundary vector.}
}
\description{
Functions used to define terms within a \code{cgaim} formula. \code{g} 
 defines an index with ridge function and \code{s} a smooth covariate.
}
\details{
These functions define nonlinear terms in the formula, with \code{g} defining
an index created from a collection of terms passed through the \code{...}
argument while \code{s} is applied to a single variable, similarly to 
\code{\link[mgcv]{s}} in \code{mgcv}. 

For indices, \code{g} allows the definition of constraints applied to
the index only. This is a convenient alternative to passing the whole
constraint matrix \code{Cmat} in \code{\link{cgaim}}. Constraints can be
defined by a prespecified matrix through the argument \code{Cmat} or
through the argument \code{acons} for common constraints (see 
\code{\link{build_constraints}}). Note that any provided \code{Cmat} must
match the total number of variables in \code{...}, including potential
matrix expansion and factors. Both \code{Cmat} and \code{acons} can be
passed to the function, which will bind them internally.

Both \code{g} and \code{s} allow the definition of shape constraints for the
smooth. Eight shape-constraints are currently available: 
 monotone increasing (\code{fcons = "inc"}), 
 monotone decreasing (\code{fcons = "dec"}), 
 convex (\code{fcons = "cvx"}), 
 concave (\code{fcons = "ccv"}), 
 increasing and convex(\code{fcons = "inccvx"}), 
 decreasing and convex (\code{fcons = "deccvx"}), 
 increasing and concave (\code{fcons = "incccv"}), 
 decreasing and concave (\code{fcons = "decccv"}). 

Smoothing can be controlled by the \code{s_opts} parameter. It is a list of
argument depends on the method used for smoothing. See \code{\link[mgcv]{s}} 
for \code{smooth_method = "scam"}. For \code{smooth_method = "cgam"}, 
the parameters allowed may vary according to the shape-constraint chosen. 
 The full list can be found in \code{\link[cgam]{cgam}}, but only the 
 constraints beginning with \code{s.} are allowed for now. 
 No parameter are necessary when \code{smooth_method = "scar"} 
 (see \code{\link[scar]{scar}}).
}
\examples{
## Simulate some data
n <- 200
x1 <- rnorm(n)
x2 <- rnorm(n)
x3 <- rnorm(n)
x4 <- rnorm(n)
mu <- 4 * exp(8 * x1) / (1 + exp(8 * x1)) + exp(x3)
y <- mu + rnorm(n)
df1 <- data.frame(y, x1, x2, x3, x4)

## Fit an unconstrained the model
ans <- cgaim(y ~ g(x1, x2) + g(x3, x4), data = df1)

## Fit constrained model
ans2 <- cgaim(y ~ g(x1, x2, acons = list(monotone = -1)) + 
  g(x3, x4, fcons = "cvx"), data = df1)
  
## Pass constraint matrices instead
ans3 <- cgaim(y ~ g(x1, x2, Cmat = -diff(diag(2))) + 
  g(x3, x4, fcons = "cvx"), data = df1)
  
## Label indices   
ans4 <- cgaim(y ~ g(x1, x2, label = "foo") + g(x3, x4, label = "bar"), 
  data = df1)
  
}
\seealso{
\code{\link{cgaim}} for fitting the CGAIM, 
\code{\link{build_constraints}} for built-in constraint matrices.
}

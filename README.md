# Constrained Groupwise Additive Index Models

[![](https://www.r-pkg.org/badges/version/cgaim?color=green)](https://cran.r-project.org/package=cgaim)
[![](http://cranlogs.r-pkg.org/badges/grand-total/cgaim?color=green)](https://cran.r-project.org/package=cgaim)

## Description

The `cgaim` package allows fitting Groupwise Additive Index Models with constraints (CGAIM) on both the ridge functions and indices coefficients. Methods to plot the ridge functions, predict new data and compute confidence intervals are also included in the package.

The model and fitting are described in:

-----

Pierre Masselot, Fateh Chebana, Céline Campagna, Éric Lavigne, Taha B M J Ouarda, Pierre Gosselin (2022). **Constrained groupwise additive index models.** *Biostatistics*, 24(04), 1066–1084. https://doi.org/10.1093/biostatistics/kxac023.

-----

## Installation

The package is available for installation from the usual CRAN repository. Alternatively, to install the development version:

1. In R, install the package directly from Github using the command (the package `devtools` is required):
```r
> library(devtools)
> install_github("PierreMasselot/cgaim")
```
2. The package can then be loaded as usual: `library(cgaim)`.
3. Help can be accessed from R with `?cgaim`.

## Functions

The main function of the package is the eponymous `cgaim` that fits the model. Then, the `print.cgaim` method allows displaying the results. The `confint.cgaim` and `vcov.cgaim` methods allow computing confidence intervals and variance-covariance matrix using various approaches. Ridge functions can be displayed using the `plot.cgaim` method, with the possibility to add confidence intervals. Finally, `predict.cgaim` allows computing the indices and perform prediction on new observations.
See the help of each function.

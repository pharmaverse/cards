
<!-- README.md is generated from README.Rmd. Please edit that file -->

# cards <a href="https://pharmaverse.github.io/cards/"><img src="https://raw.githubusercontent.com/pharmaverse/cards/main/man/figures/logo.png" align="right" height="120" alt="cards website" /></a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/cards)](https://CRAN.R-project.org/package=cards)
[![Codecov test
coverage](https://codecov.io/gh/pharmaverse/cards/graph/badge.svg)](https://app.codecov.io/gh/pharmaverse/cards)
[![Downloads](https://cranlogs.r-pkg.org/badges/cards)](https://cran.r-project.org/package=cards)
[![R-CMD-check](https://github.com/pharmaverse/cards/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/pharmaverse/cards/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The [CDISC Analysis Results
Standard](https://www.cdisc.org/standards/foundational/analysis-results-standard)
aims to facilitate automation, reproducibility, reusability, and
traceability of analysis results data (ARD). The {cards} package creates
these **C**DISC **A**nalysis **R**esult **D**ata **S**ets.

Use cases:

1.  Quality Control (QC) of existing tables and figures.

2.  Pre-calculate statistics to be summarized in tables and figures.

3.  Medical writers may easily access statistics and place in reports
    without copying and pasting from reports.

4.  Provides a consistent format for results and lends results to be
    combined across studies for re-use and re-analysis.

## Installation

Install cards from CRAN with:

``` r
install.packages("cards")
```

You can install the development version of cards from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("pharmaverse/cards")
```

## Extensions

[<img
src="https://raw.githubusercontent.com/pharmaverse/cardx/main/man/figures/logo.png"
style="float: right" width="120" alt="cardx website" />](https://pharmaverse.github.io/cardx/)

The {cards} package exports three types of functions:

1.  Functions to create basic ARD objects.

2.  Utilities to create new ARD objects.

3.  Functions to work with existing ARD objects.

The [{cardx}](https://github.com/pharmaverse/cardx/) R package is an
extension to {cards} that uses the utilities from {cards} and exports
functions for creating additional ARD objects––including functions to
summarize t-tests, Wilcoxon Rank-Sum tests, regression models, and more.

## Getting Started

Review the [Getting
Started](https://pharmaverse.github.io/cards//main/articles/getting-started.html)
page for examples using ARDs to calculate statistics to later include in
tables.

``` r
library(cards)

ard_summary(ADSL, by = "ARM", variables = "AGE")
#> # An ARD data frame: 24 × 10
#>    group1 group1_level       variable context stat_name stat_label  stat fmt_fun
#>    <chr>  <list>             <chr>    <chr>   <chr>     <chr>      <lis>  <list>
#>  1 ARM    Placebo            AGE      summary N         N          86          0
#>  2 ARM    Placebo            AGE      summary mean      Mean       75.2        1
#>  3 ARM    Placebo            AGE      summary sd        SD          8.59       1
#>  4 ARM    Placebo            AGE      summary median    Median     76          1
#>  5 ARM    Placebo            AGE      summary p25       Q1         69          1
#>  6 ARM    Placebo            AGE      summary p75       Q3         82          1
#>  7 ARM    Placebo            AGE      summary min       Min        52          1
#>  8 ARM    Placebo            AGE      summary max       Max        89          1
#>  9 ARM    Xanomeline High D… AGE      summary N         N          84          0
#> 10 ARM    Xanomeline High D… AGE      summary mean      Mean       74.4        1
#> # ℹ 14 more rows
#> # ℹ 2 more variables: warning <list>, error <list>
```

# cards

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

# install.packages("devtools")
devtools::install_github("insightsengineering/cards")
```

## Extensions

[![cardx
website](https://raw.githubusercontent.com/insightsengineering/cardx/main/man/figures/logo.png)](https://insightsengineering.github.io/cardx/)

The {cards} package exports three types of functions:

1.  Functions to create basic ARD objects.

2.  Utilities to create new ARD objects.

3.  Functions to work with existing ARD objects.

The [{cardx}](https://github.com/insightsengineering/cardx/) R package
is an extension to {cards} that uses the utilities from {cards} and
exports functions for creating additional ARD objects––including
functions to summarize t-tests, Wilcoxon Rank-Sum tests, regression
models, and more.

## Getting Started

Review the [Getting
Started](https://insightsengineering.github.io/cards//main/articles/getting-started.html)
page for examples using ARDs to calculate statistics to later include in
tables.

``` r

library(cards)

ard_summary(ADSL, by = "ARM", variables = "AGE")
#> {cards} data frame: 24 x 10
#>    group1 group1_level variable stat_name stat_label   stat
#> 1     ARM      Placebo      AGE         N          N     86
#> 2     ARM      Placebo      AGE      mean       Mean 75.209
#> 3     ARM      Placebo      AGE        sd         SD   8.59
#> 4     ARM      Placebo      AGE    median     Median     76
#> 5     ARM      Placebo      AGE       p25         Q1     69
#> 6     ARM      Placebo      AGE       p75         Q3     82
#> 7     ARM      Placebo      AGE       min        Min     52
#> 8     ARM      Placebo      AGE       max        Max     89
#> 9     ARM    Xanomeli…      AGE         N          N     84
#> 10    ARM    Xanomeli…      AGE      mean       Mean 74.381
#> ℹ 14 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

## Other Resources

[TABLE]

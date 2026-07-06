# Summary Functions

- `continuous_summary_fns()` returns a named list of summary functions
  for continuous variables. Some functions include slight modifications
  to their base equivalents. For example, the
  [`min()`](https://rdrr.io/r/base/Extremes.html) and
  [`max()`](https://rdrr.io/r/base/Extremes.html) functions return `NA`
  instead of `Inf` when an empty vector is passed. Statistics `"p25"`
  and `"p75"` are calculated with `quantile(type = 2)`, which matches
  [SAS's default
  value](https://psiaims.github.io/CAMIS/Comp/r-sas-summary-stats.html).

## Usage

``` r
continuous_summary_fns(
  summaries = c("N", "mean", "sd", "median", "p25", "p75", "min", "max"),
  other_stats = NULL
)
```

## Arguments

- summaries:

  (`character`)\
  a character vector of results to include in output. Select one or more
  from 'N', 'mean', 'sd', 'median', 'p25', 'p75', 'min', 'max'.

- other_stats:

  (named `list`)\
  named list of other statistic functions to supplement the
  pre-programmed functions.

## Value

named list of summary statistics

## Examples

``` r
# continuous variable summaries
ard_summary(
  ADSL,
  variables = "AGE",
  statistic = ~ continuous_summary_fns(c("N", "median"))
)
#> {cards} data frame: 2 x 8
#>   variable context stat_name stat_label stat fmt_fun
#> 1      AGE summary         N          N  254       0
#> 2      AGE summary    median     Median   77       1
#> ℹ 2 more variables: warning, error
```

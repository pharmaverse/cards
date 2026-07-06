# Pairwise ARD

Utility to perform pairwise comparisons.

## Usage

``` r
ard_pairwise(data, variable, .f, include = NULL)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- variable:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  Column to perform pairwise analyses for.

- .f:

  (`function`)\
  a function that creates ARDs. The function accepts a single argument
  and a subset of `data` will be passed including the two levels of
  `variable` for the pairwise analysis.

- include:

  (`vector`)\
  a vector of levels of the `variable` column to include in comparisons.
  Pairwise comparisons will only be performed for pairs that have a
  level specified here. Default is `NULL` and all pairwise computations
  are included.

## Value

list of ARDs

## Examples

``` r
ard_pairwise(
  ADSL,
  variable = ARM,
  .f = \(df) {
    ard_mvsummary(
      df,
      variables = AGE,
      statistic = ~ list(ttest = \(x, data, ...) t.test(x ~ data$ARM)[c("statistic", "p.value")])
    )
  },
  include = "Placebo" # only include comparisons to the "Placebo" group
)
#> $`'Placebo' vs. 'Xanomeline High Dose'`
#> {cards} data frame: 2 x 8
#>   variable   context stat_name stat_label  stat fmt_fun
#> 1      AGE mvsummary statistic  statistic 0.655       1
#> 2      AGE mvsummary   p.value    p.value 0.513       1
#> ℹ 2 more variables: warning, error
#> 
#> $`'Placebo' vs. 'Xanomeline Low Dose'`
#> {cards} data frame: 2 x 8
#>   variable   context stat_name stat_label   stat fmt_fun
#> 1      AGE mvsummary statistic  statistic -0.353       1
#> 2      AGE mvsummary   p.value    p.value  0.724       1
#> ℹ 2 more variables: warning, error
#> 
#> attr(,"args")
#> attr(,"args")$variable
#> [1] "ARM"
#> 
#> attr(,"args")$include
#> [1] "Placebo"
#> 
```

# Stack ARDs

Stack multiple ARD calls sharing common input `data` and `by` variables.
Optionally incorporate additional information on represented variables,
e.g. overall calculations, rates of missingness, attributes, or
transform results with
[`shuffle_ard()`](https://insightsengineering.github.io/cards/reference/deprecated.md).

If the `ard_stack(by)` argument is specified, a univariate tabulation of
the by variable will also be returned.

## Usage

``` r
ard_stack(
  data,
  ...,
  .by = NULL,
  .overall = FALSE,
  .missing = FALSE,
  .attributes = FALSE,
  .total_n = FALSE,
  .shuffle = FALSE,
  .by_stats = TRUE
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- ...:

  ([`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html))\
  Series of ARD function calls to be run and stacked

- .by:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to tabulate by in the series of ARD function calls. Any rows
  with `NA` or `NaN` values are removed from all calculations.

- .overall:

  (`logical`)\
  logical indicating whether overall statistics should be calculated
  (i.e. re-run all `ard_*()` calls with `by=NULL`). Default is `FALSE`.

- .missing:

  (`logical`)\
  logical indicating whether to include the results of
  [`ard_missing()`](https://insightsengineering.github.io/cards/reference/ard_missing.md)
  for all variables represented in the ARD. Default is `FALSE`.

- .attributes:

  (`logical`)\
  logical indicating whether to include the results of
  [`ard_attributes()`](https://insightsengineering.github.io/cards/reference/ard_attributes.md)
  for all variables represented in the ARD. Default is `FALSE`.

- .total_n:

  (`logical`)\
  logical indicating whether to include of
  [`ard_total_n()`](https://insightsengineering.github.io/cards/reference/ard_total_n.md)
  in the returned ARD.

- .shuffle:

  **\[deprecated\]** support for `.shuffle = TRUE` has been removed.

- .by_stats:

  (`logical`)\
  logical indicating whether to include overall stats of the `by`
  variables in the returned ARD.

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_stack(
  data = ADSL,
  ard_tabulate(variables = "AGEGR1"),
  ard_summary(variables = "AGE"),
  .by = "ARM",
  .overall = TRUE,
  .attributes = TRUE
)
#> {cards} data frame: 83 x 11
#>    group1 group1_level variable variable_level stat_name stat_label  stat
#> 1     ARM      Placebo   AGEGR1          65-80         n          n    42
#> 2     ARM      Placebo   AGEGR1          65-80         N          N    86
#> 3     ARM      Placebo   AGEGR1          65-80         p          % 0.488
#> 4     ARM      Placebo   AGEGR1            <65         n          n    14
#> 5     ARM      Placebo   AGEGR1            <65         N          N    86
#> 6     ARM      Placebo   AGEGR1            <65         p          % 0.163
#> 7     ARM      Placebo   AGEGR1            >80         n          n    30
#> 8     ARM      Placebo   AGEGR1            >80         N          N    86
#> 9     ARM      Placebo   AGEGR1            >80         p          % 0.349
#> 10    ARM      Placebo      AGE                        N          N    86
#> ℹ 73 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

ard_stack(
  data = ADSL,
  ard_tabulate(variables = "AGEGR1"),
  ard_summary(variables = "AGE"),
  .by = "ARM"
)
#> {cards} data frame: 60 x 11
#>    group1 group1_level variable variable_level stat_name stat_label  stat
#> 1     ARM      Placebo   AGEGR1          65-80         n          n    42
#> 2     ARM      Placebo   AGEGR1          65-80         N          N    86
#> 3     ARM      Placebo   AGEGR1          65-80         p          % 0.488
#> 4     ARM      Placebo   AGEGR1            <65         n          n    14
#> 5     ARM      Placebo   AGEGR1            <65         N          N    86
#> 6     ARM      Placebo   AGEGR1            <65         p          % 0.163
#> 7     ARM      Placebo   AGEGR1            >80         n          n    30
#> 8     ARM      Placebo   AGEGR1            >80         N          N    86
#> 9     ARM      Placebo   AGEGR1            >80         p          % 0.349
#> 10    ARM      Placebo      AGE                        N          N    86
#> ℹ 50 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

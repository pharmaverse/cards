# Missing ARD Statistics

Compute Analysis Results Data (ARD) for statistics related to data
missingness.

## Usage

``` r
ard_missing(data, ...)

# S3 method for class 'data.frame'
ard_missing(
  data,
  variables,
  by = dplyr::group_vars(data),
  statistic = everything() ~ c("N_obs", "N_miss", "N_nonmiss", "p_miss", "p_nonmiss"),
  fmt_fun = NULL,
  stat_label = everything() ~ default_stat_labels(),
  fmt_fn = deprecated(),
  ...
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- ...:

  Arguments passed to methods.

- variables:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to include in summaries.

- by:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  results are tabulated by **all combinations** of the columns
  specified.

- statistic:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element is a named list of functions (or the RHS of a formula), e.g.
  `list(mpg = list(mean = \(x) mean(x)))`.

  The value assigned to each variable must also be a named list, where
  the names are used to reference a function and the element is the
  function object. Typically, this function will return a scalar
  statistic, but a function that returns a named list of results is also
  acceptable, e.g. `list(conf.low = -1, conf.high = 1)`. However, when
  errors occur, the messaging will be less clear in this setting.

- fmt_fun:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element is a named list of functions (or the RHS of a formula), e.g.
  `list(mpg = list(mean = \(x) round(x, digits = 2) |> as.character()))`.

- stat_label:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element is either a named list or a list of formulas defining the
  statistic labels, e.g. `everything() ~ list(mean = "Mean", sd = "SD")`
  or `everything() ~ list(mean ~ "Mean", sd ~ "SD")`.

- fmt_fn:

  **\[deprecated\]**

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_missing(ADSL, by = "ARM", variables = "AGE")
#> {cards} data frame: 15 x 10
#>    group1 group1_level variable stat_name stat_label stat
#> 1     ARM      Placebo      AGE     N_obs  Vector L…   86
#> 2     ARM      Placebo      AGE    N_miss  N Missing    0
#> 3     ARM      Placebo      AGE N_nonmiss  N Non-mi…   86
#> 4     ARM      Placebo      AGE    p_miss  % Missing    0
#> 5     ARM      Placebo      AGE p_nonmiss  % Non-mi…    1
#> 6     ARM    Xanomeli…      AGE     N_obs  Vector L…   84
#> 7     ARM    Xanomeli…      AGE    N_miss  N Missing    0
#> 8     ARM    Xanomeli…      AGE N_nonmiss  N Non-mi…   84
#> 9     ARM    Xanomeli…      AGE    p_miss  % Missing    0
#> 10    ARM    Xanomeli…      AGE p_nonmiss  % Non-mi…    1
#> 11    ARM    Xanomeli…      AGE     N_obs  Vector L…   84
#> 12    ARM    Xanomeli…      AGE    N_miss  N Missing    0
#> 13    ARM    Xanomeli…      AGE N_nonmiss  N Non-mi…   84
#> 14    ARM    Xanomeli…      AGE    p_miss  % Missing    0
#> 15    ARM    Xanomeli…      AGE p_nonmiss  % Non-mi…    1
#> ℹ 4 more variables: context, fmt_fun, warning, error

ADSL |>
  dplyr::group_by(ARM) |>
  ard_missing(
    variables = "AGE",
    statistic = ~"N_miss"
  )
#> {cards} data frame: 3 x 10
#>   group1 group1_level variable stat_name stat_label stat
#> 1    ARM      Placebo      AGE    N_miss  N Missing    0
#> 2    ARM    Xanomeli…      AGE    N_miss  N Missing    0
#> 3    ARM    Xanomeli…      AGE    N_miss  N Missing    0
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

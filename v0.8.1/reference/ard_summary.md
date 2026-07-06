# Univariate ARD Statistics

Compute Analysis Results Data (ARD) for simple continuous summary
statistics.

## Usage

``` r
ard_summary(data, ...)

# S3 method for class 'data.frame'
ard_summary(
  data,
  variables,
  by = dplyr::group_vars(data),
  strata = NULL,
  statistic = everything() ~ continuous_summary_fns(),
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

- by, strata:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to tabulate by/stratify by for summary statistic calculation.
  Arguments are similar, but with an important distinction:

  `by`: results are calculated for **all combinations** of the columns
  specified, including unobserved combinations and unobserved factor
  levels.

  `strata`: results are calculated for **all *observed* combinations**
  of the columns specified.

  Arguments may be used in conjunction with one another.

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

# if a single function returns a named list, the named
# results will be placed in the resulting ARD
ADSL |>
  dplyr::group_by(ARM) |>
  ard_summary(
    variables = "AGE",
    statistic =
      ~ list(conf.int = \(x) t.test(x)[["conf.int"]] |>
        as.list() |>
        setNames(c("conf.low", "conf.high")))
  )
#> {cards} data frame: 6 x 10
#>   group1 group1_level variable stat_name stat_label   stat
#> 1    ARM      Placebo      AGE  conf.low   conf.low 73.368
#> 2    ARM      Placebo      AGE conf.high  conf.high 77.051
#> 3    ARM    Xanomeli…      AGE  conf.low   conf.low  72.67
#> 4    ARM    Xanomeli…      AGE conf.high  conf.high 76.092
#> 5    ARM    Xanomeli…      AGE  conf.low   conf.low 73.868
#> 6    ARM    Xanomeli…      AGE conf.high  conf.high 77.465
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

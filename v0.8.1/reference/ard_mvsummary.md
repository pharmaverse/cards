# Multivariate ARD Summaries

Function is similar to
[`ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md),
but allows for more complex, multivariate summaries. While
`ard_summary(statistic)` only allows for a univariable function,
`ard_mvsummary(statistic)` can handle more complex data summaries.

## Usage

``` r
ard_mvsummary(data, ...)

# S3 method for class 'data.frame'
ard_mvsummary(
  data,
  variables,
  by = dplyr::group_vars(data),
  strata = NULL,
  statistic,
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
  The form of the statistics argument is identical to
  `ard_summary(statistic)` argument, except the summary function *must*
  accept the following arguments:

  - `x`: a vector

  - `data`: the data frame that has been subset such that the
    `by`/`strata` columns and rows in which `"variable"` is `NA` have
    been removed.

  - `full_data`: the full data frame

  - `by`: character vector of the `by` variables

  - `strata`: character vector of the `strata` variables

  It is unlikely any one function will need *all* of the above elements,
  and it's recommended the function passed accepts `...` so that any
  unused arguments will be properly ignored. The `...` also allows this
  function to perhaps be updated in the future with more passed
  arguments. For example, if one needs a second variable from the data
  frame, the function inputs may look like: `foo(x, data, ...)`

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
# example how to mimic behavior of `ard_summary()`
ard_mvsummary(
  ADSL,
  by = "ARM",
  variables = "AGE",
  statistic = list(AGE = list(mean = \(x, ...) mean(x)))
)
#> {cards} data frame: 3 x 10
#>   group1 group1_level variable stat_name stat_label   stat
#> 1    ARM      Placebo      AGE      mean       Mean 75.209
#> 2    ARM    Xanomeli…      AGE      mean       Mean 74.381
#> 3    ARM    Xanomeli…      AGE      mean       Mean 75.667
#> ℹ 4 more variables: context, fmt_fun, warning, error

# return the grand mean and the mean within the `by` group
grand_mean <- function(data, full_data, variable, ...) {
  list(
    mean = mean(data[[variable]], na.rm = TRUE),
    grand_mean = mean(full_data[[variable]], na.rm = TRUE)
  )
}

ADSL |>
  dplyr::group_by(ARM) |>
  ard_mvsummary(
    variables = "AGE",
    statistic = list(AGE = list(means = grand_mean))
  )
#> {cards} data frame: 6 x 10
#>   group1 group1_level variable  stat_name stat_label   stat
#> 1    ARM      Placebo      AGE       mean       Mean 75.209
#> 2    ARM      Placebo      AGE grand_mean  grand_me… 75.087
#> 3    ARM    Xanomeli…      AGE       mean       Mean 74.381
#> 4    ARM    Xanomeli…      AGE grand_mean  grand_me… 75.087
#> 5    ARM    Xanomeli…      AGE       mean       Mean 75.667
#> 6    ARM    Xanomeli…      AGE grand_mean  grand_me… 75.087
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

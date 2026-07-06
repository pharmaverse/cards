# Mock ARDs

**\[experimental\]**\
Create empty ARDs used to create mock tables or table shells. Where
applicable, the formatting functions are set to return `'xx'` or
`'xx.x'`.

## Usage

``` r
mock_categorical(
  variables,
  statistic = everything() ~ c("n", "p", "N"),
  by = NULL
)

mock_continuous(
  variables,
  statistic = everything() ~ c("N", "mean", "sd", "median", "p25", "p75", "min", "max"),
  by = NULL
)

mock_dichotomous(
  variables,
  statistic = everything() ~ c("n", "p", "N"),
  by = NULL
)

mock_missing(
  variables,
  statistic = everything() ~ c("N_obs", "N_miss", "N_nonmiss", "p_miss", "p_nonmiss"),
  by = NULL
)

mock_attributes(label)

mock_total_n()
```

## Arguments

- variables:

  (`character` or named `list`)\
  a character vector of variable names for functions
  `mock_continuous()`, `mock_missing()`, and `mock_attributes()`.

  a named list for functions `mock_categorical()` and
  `mock_dichotomous()`, where the list element is a vector of variable
  values. For `mock_dichotomous()`, only a single value is allowed for
  each variable.

- statistic:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  elements are character vectors of statistic names to appear in the
  ARD.

- by:

  (named `list`)\
  a named list where the list element is a vector of variable values.

- label:

  (named `list`)\
  named list of variable labels, e.g. `list(cyl = "No. Cylinders")`.

## Value

an ARD data frame of class 'card'

## Examples

``` r
mock_categorical(
  variables =
    list(
      AGEGR1 = factor(c("<65", "65-80", ">80"), levels = c("<65", "65-80", ">80"))
    ),
  by = list(TRTA = c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"))
) |>
  apply_fmt_fun()
#> {cards} data frame: 27 x 12
#>    group1 group1_level variable variable_level stat_name stat_label stat
#> 1    TRTA      Placebo   AGEGR1            <65         n          n     
#> 2    TRTA      Placebo   AGEGR1            <65         p          %     
#> 3    TRTA      Placebo   AGEGR1            <65         N          N     
#> 4    TRTA      Placebo   AGEGR1          65-80         n          n     
#> 5    TRTA      Placebo   AGEGR1          65-80         p          %     
#> 6    TRTA      Placebo   AGEGR1          65-80         N          N     
#> 7    TRTA      Placebo   AGEGR1            >80         n          n     
#> 8    TRTA      Placebo   AGEGR1            >80         p          %     
#> 9    TRTA      Placebo   AGEGR1            >80         N          N     
#> 10   TRTA    Xanomeli…   AGEGR1            <65         n          n     
#>    stat_fmt
#> 1        xx
#> 2      xx.x
#> 3        xx
#> 4        xx
#> 5      xx.x
#> 6        xx
#> 7        xx
#> 8      xx.x
#> 9        xx
#> 10       xx
#> ℹ 17 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

mock_continuous(
  variables = c("AGE", "BMIBL"),
  by = list(TRTA = c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"))
) |>
  # update the mock to report 'xx.xx' for standard deviations
  update_ard_fmt_fun(variables = c("AGE", "BMIBL"), stat_names = "sd", fmt_fun = \(x) "xx.xx") |>
  apply_fmt_fun()
#> {cards} data frame: 48 x 11
#>    group1 group1_level variable stat_name stat_label stat stat_fmt
#> 1    TRTA      Placebo      AGE         N          N            xx
#> 2    TRTA      Placebo      AGE      mean       Mean          xx.x
#> 3    TRTA      Placebo      AGE        sd         SD         xx.xx
#> 4    TRTA      Placebo      AGE    median     Median          xx.x
#> 5    TRTA      Placebo      AGE       p25         Q1          xx.x
#> 6    TRTA      Placebo      AGE       p75         Q3          xx.x
#> 7    TRTA      Placebo      AGE       min        Min          xx.x
#> 8    TRTA      Placebo      AGE       max        Max          xx.x
#> 9    TRTA      Placebo    BMIBL         N          N            xx
#> 10   TRTA      Placebo    BMIBL      mean       Mean          xx.x
#> ℹ 38 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

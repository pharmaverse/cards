# Stratified ARD

General function for calculating ARD results within subgroups.

While the examples below show use with other functions from the cards
package, this function would primarily be used with the statistical
functions in the cardx functions.

## Usage

``` r
ard_strata(.data, .by = NULL, .strata = NULL, .f, ...)
```

## Arguments

- .data:

  (`data.frame`)\
  a data frame

- .by, .strata:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to tabulate by/stratify by for calculation. Arguments are
  similar, but with an important distinction:

  `.by`: results are tabulated by **all combinations** of the columns
  specified, including unobserved combinations and unobserved factor
  levels.

  `.strata`: results are tabulated by **all *observed* combinations** of
  the columns specified.

  These argument *should not* include any columns that appear in the
  `.f` argument.

- .f:

  (`function`, `formula`)\
  a function or a formula that can be coerced to a function with
  [`rlang::as_function()`](https://rlang.r-lib.org/reference/as_function.html)
  (similar to `purrr::map(.f)`)

- ...:

  Additional arguments passed on to the `.f` function.

## Value

an ARD data frame of class 'card'

## Examples

``` r
# Example 1 ----------------------------------
ard_strata(
  ADSL,
  .by = ARM,
  .f = ~ ard_summary(.x, variables = AGE)
)
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

# Example 2 ----------------------------------
df <- data.frame(
  USUBJID = 1:12,
  PARAMCD = rep(c("PARAM1", "PARAM2"), each = 6),
  AVALC = c(
    "Yes", "No", "Yes", # PARAM1
    "Yes", "Yes", "No", # PARAM1
    "Low", "Medium", "High", # PARAM2
    "Low", "Low", "Medium" # PARAM2
  )
)

ard_strata(
  df,
  .strata = PARAMCD,
  .f = \(.x) {
    lvls <-
      switch(.x[["PARAMCD"]][1],
        "PARAM1" = c("Yes", "No"),
        "PARAM2" = c("Zero", "Low", "Medium", "High")
      )

    .x |>
      dplyr::mutate(AVALC = factor(AVALC, levels = lvls)) |>
      ard_tabulate(variables = AVALC)
  }
)
#> {cards} data frame: 18 x 11
#>     group1 group1_level variable variable_level stat_name stat_label  stat
#> 1  PARAMCD       PARAM1    AVALC            Yes         n          n     4
#> 2  PARAMCD       PARAM1    AVALC            Yes         N          N     6
#> 3  PARAMCD       PARAM1    AVALC            Yes         p          % 0.667
#> 4  PARAMCD       PARAM1    AVALC             No         n          n     2
#> 5  PARAMCD       PARAM1    AVALC             No         N          N     6
#> 6  PARAMCD       PARAM1    AVALC             No         p          % 0.333
#> 7  PARAMCD       PARAM2    AVALC           Zero         n          n     0
#> 8  PARAMCD       PARAM2    AVALC           Zero         N          N     6
#> 9  PARAMCD       PARAM2    AVALC           Zero         p          %     0
#> 10 PARAMCD       PARAM2    AVALC            Low         n          n     3
#> 11 PARAMCD       PARAM2    AVALC            Low         N          N     6
#> 12 PARAMCD       PARAM2    AVALC            Low         p          %   0.5
#> 13 PARAMCD       PARAM2    AVALC         Medium         n          n     2
#> 14 PARAMCD       PARAM2    AVALC         Medium         N          N     6
#> 15 PARAMCD       PARAM2    AVALC         Medium         p          % 0.333
#> 16 PARAMCD       PARAM2    AVALC           High         n          n     1
#> 17 PARAMCD       PARAM2    AVALC           High         N          N     6
#> 18 PARAMCD       PARAM2    AVALC           High         p          % 0.167
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

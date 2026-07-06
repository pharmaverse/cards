# Update ARDs

Functions used to update ARD formatting functions and statistic labels.

This is a helper function to streamline the update process. If it does
not exactly meet your needs, recall that an ARD is just a data frame and
it can be modified directly.

## Usage

``` r
update_ard_fmt_fun(
  x,
  variables = everything(),
  stat_names,
  fmt_fun,
  filter = TRUE,
  fmt_fn = deprecated()
)

update_ard_stat_label(
  x,
  variables = everything(),
  stat_names,
  stat_label,
  filter = TRUE
)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- variables:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  variables in `x$variable` to apply update. Default is
  [`everything()`](https://tidyselect.r-lib.org/reference/everything.html).

- stat_names:

  (`character`)\
  character vector of the statistic names (i.e. values from
  `x$stat_name`) to apply the update.

- fmt_fun:

  (`function`)\
  a function or alias recognized by
  [`alias_as_fmt_fun()`](https://insightsengineering.github.io/cards/reference/alias_as_fmt_fun.md).

- filter:

  (`expression`)\
  an expression that evaluates to a logical vector identifying rows in
  `x` to apply the update to. Default is `TRUE`, and update is applied
  to all rows.

- fmt_fn:

  **\[deprecated\]**

- stat_label:

  (`function`)\
  a string of the updated statistic label.

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_summary(ADSL, variables = AGE) |>
  update_ard_fmt_fun(stat_names = c("mean", "sd"), fmt_fun = 8L) |>
  update_ard_stat_label(stat_names = c("mean", "sd"), stat_label = "Mean (SD)") |>
  apply_fmt_fun()
#> {cards} data frame: 8 x 9
#>   variable context stat_name stat_label   stat    stat_fmt
#> 1      AGE summary         N          N    254         254
#> 2      AGE summary      mean  Mean (SD) 75.087 75.08661417
#> 3      AGE summary        sd  Mean (SD)  8.246  8.24623390
#> 4      AGE summary    median     Median     77        77.0
#> 5      AGE summary       p25         Q1     70        70.0
#> 6      AGE summary       p75         Q3     81        81.0
#> 7      AGE summary       min        Min     51        51.0
#> 8      AGE summary       max        Max     89        89.0
#> ℹ 3 more variables: fmt_fun, warning, error

# same as above, but only apply update to the Placebo level
ard_summary(
  ADSL,
  by = ARM,
  variables = AGE,
  statistic = ~ continuous_summary_fns(c("N", "mean"))
) |>
  update_ard_fmt_fun(stat_names = "mean", fmt_fun = 8L, filter = group1_level == "Placebo") |>
  apply_fmt_fun()
#> {cards} data frame: 6 x 11
#>   group1 group1_level variable stat_name stat_label   stat    stat_fmt
#> 1    ARM      Placebo      AGE         N          N     86          86
#> 2    ARM      Placebo      AGE      mean       Mean 75.209 75.20930233
#> 3    ARM    Xanomeli…      AGE         N          N     84          84
#> 4    ARM    Xanomeli…      AGE      mean       Mean 74.381        74.4
#> 5    ARM    Xanomeli…      AGE         N          N     84          84
#> 6    ARM    Xanomeli…      AGE      mean       Mean 75.667        75.7
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

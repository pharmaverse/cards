# Add Calculated Row

Use this function to add a new statistic row that is a function of the
other statistics in an ARD.

## Usage

``` r
add_calculated_row(
  x,
  expr,
  stat_name,
  by = c(all_ard_groups(), all_ard_variables(), any_of("context")),
  stat_label = stat_name,
  fmt_fun = NULL,
  fmt_fn = deprecated()
)
```

## Arguments

- x:

  (`card`)\
  data frame of class `'card'`

- expr:

  (`expression`)\
  an expression

- stat_name:

  (`string`)\
  string naming the new statistic

- by:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  Grouping variables to calculate statistics within

- stat_label:

  (`string`)\
  string of the statistic label. Default is the `stat_name`.

- fmt_fun:

  (`integer`, `function`, `string`)\
  a function of an integer or string that can be converted to a function
  with
  [`alias_as_fmt_fun()`](https://insightsengineering.github.io/cards/reference/alias_as_fmt_fun.md).

- fmt_fn:

  **\[deprecated\]**

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_summary(mtcars, variables = mpg) |>
  add_calculated_row(expr = max - min, stat_name = "range")
#> {cards} data frame: 9 x 8
#>   variable context stat_name stat_label   stat fmt_fun
#> 1      mpg summary         N          N     32       0
#> 2      mpg summary      mean       Mean 20.091       1
#> 3      mpg summary        sd         SD  6.027       1
#> 4      mpg summary    median     Median   19.2       1
#> 5      mpg summary       p25         Q1  15.35       1
#> 6      mpg summary       p75         Q3   22.8       1
#> 7      mpg summary       min        Min   10.4       1
#> 8      mpg summary       max        Max   33.9       1
#> 9      mpg summary     range      range   23.5       1
#> ℹ 2 more variables: warning, error

ard_summary(mtcars, variables = mpg) |>
  add_calculated_row(
    expr =
      dplyr::case_when(
        mean > median ~ "Right Skew",
        mean < median ~ "Left Skew",
        .default = "Symmetric"
      ),
    stat_name = "skew"
  )
#> {cards} data frame: 9 x 8
#>   variable context stat_name stat_label      stat fmt_fun
#> 1      mpg summary         N          N        32       0
#> 2      mpg summary      mean       Mean    20.091       1
#> 3      mpg summary        sd         SD     6.027       1
#> 4      mpg summary    median     Median      19.2       1
#> 5      mpg summary       p25         Q1     15.35       1
#> 6      mpg summary       p75         Q3      22.8       1
#> 7      mpg summary       min        Min      10.4       1
#> 8      mpg summary       max        Max      33.9       1
#> 9      mpg summary      skew       skew Right Sk…    <fn>
#> ℹ 2 more variables: warning, error
```

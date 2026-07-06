# Apply Formatting Functions

Apply the formatting functions to each of the raw statistics. Function
aliases are converted to functions using
[`alias_as_fmt_fun()`](https://insightsengineering.github.io/cards/reference/alias_as_fmt_fun.md).

## Usage

``` r
apply_fmt_fun(x, replace = FALSE)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- replace:

  (scalar `logical`)\
  logical indicating whether to replace values in the `'stat_fmt'`
  column (if present). Default is `FALSE`.

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_summary(ADSL, variables = "AGE") |>
  apply_fmt_fun()
#> {cards} data frame: 8 x 9
#>   variable context stat_name stat_label   stat stat_fmt
#> 1      AGE summary         N          N    254      254
#> 2      AGE summary      mean       Mean 75.087     75.1
#> 3      AGE summary        sd         SD  8.246      8.2
#> 4      AGE summary    median     Median     77     77.0
#> 5      AGE summary       p25         Q1     70     70.0
#> 6      AGE summary       p75         Q3     81     81.0
#> 7      AGE summary       min        Min     51     51.0
#> 8      AGE summary       max        Max     89     89.0
#> ℹ 3 more variables: fmt_fun, warning, error
```

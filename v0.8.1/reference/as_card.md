# Data Frame as ARD

Convert data frames to ARDs of class 'card'.

## Usage

``` r
as_card(x, check = TRUE)
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

- check:

  (scalar `logical`)\
  Whether the input data frame should be checked for standard ARD
  features

## Value

an ARD data frame of class 'card'

## Examples

``` r
data.frame(
  stat_name = c("N", "mean"),
  stat_label = c("N", "Mean"),
  stat = c(10, 0.5)
) |>
  as_card(check = FALSE)
#> {cards} data frame: 2 x 3
#>   stat_name stat_label stat
#> 1         N          N   10
#> 2      mean       Mean  0.5
dplyr::tibble(
  variable = "AGE",
  stat_name = c("N", "mean"),
  stat_label = c("N", "Mean"),
  stat = list(10, 0.5),
  fmt_fun = replicate(2, list()),
  warning = replicate(2, list()),
  error = replicate(2, list())
) |>
  as_card()
#> {cards} data frame: 2 x 7
#>   variable stat_name stat_label stat warning error
#> 1      AGE         N          N   10              
#> 2      AGE      mean       Mean  0.5              
#> ℹ 1 more variable: fmt_fun
```

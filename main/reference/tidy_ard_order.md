# Standard Order of ARD

ARD functions for relocating columns and rows to the standard order.

- `tidy_ard_column_order()` relocates columns of the ARD to the standard
  order.

- `tidy_ard_row_order()` orders rows of ARD according to groups and
  strata (group 1, then group2, etc), while retaining the column order
  of the input ARD.

## Usage

``` r
tidy_ard_column_order(x, group_order = c("ascending", "descending"))

tidy_ard_row_order(x)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- group_order:

  (`string`)\
  specifies the ordering of the grouping variables. Must be one of
  `c("ascending", "descending")`. Default is `"ascending"`, where
  grouping variables begin with `"group1"` variables, followed by
  `"group2"` variables, etc.

## Value

an ARD data frame of class 'card'

## Examples

``` r
# order columns
ard <-
  dplyr::bind_rows(
    ard_summary(mtcars, variables = "mpg"),
    ard_summary(mtcars, variables = "mpg", by = "cyl")
  )

tidy_ard_column_order(ard) |>
  tidy_ard_row_order()
#> {cards} data frame: 32 x 10
#>    group1 group1_level variable stat_name stat_label   stat
#> 1    <NA>                   mpg         N          N     32
#> 2    <NA>                   mpg      mean       Mean 20.091
#> 3    <NA>                   mpg        sd         SD  6.027
#> 4    <NA>                   mpg    median     Median   19.2
#> 5    <NA>                   mpg       p25         Q1  15.35
#> 6    <NA>                   mpg       p75         Q3   22.8
#> 7    <NA>                   mpg       min        Min   10.4
#> 8    <NA>                   mpg       max        Max   33.9
#> 9     cyl            4      mpg         N          N     11
#> 10    cyl            4      mpg      mean       Mean 26.664
#> ℹ 22 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

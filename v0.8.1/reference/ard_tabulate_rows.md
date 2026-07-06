# Row Tabulate ARD

Tabulate the number of rows in a data frame.

## Usage

``` r
ard_tabulate_rows(
  data,
  colname = "..row_count..",
  by = dplyr::group_vars(data),
  strata = NULL,
  fmt_fun = NULL
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- colname:

  (`string`)\
  name of the column that will be returned along with the row
  tabulation.

- by, strata:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to use for grouping or stratifying the table output. Arguments
  are similar, but with an important distinction:

  `by`: results are tabulated by **all combinations** of the columns
  specified, including unobserved combinations and unobserved factor
  levels.

  `strata`: results are tabulated by **all *observed* combinations** of
  the columns specified.

  Arguments may be used in conjunction with one another.

- fmt_fun:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element is a named list of functions (or the RHS of a formula), e.g.
  `list(mpg = list(mean = \(x) round(x, digits = 2) |> as.character()))`.

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_tabulate_rows(ADSL, by = TRTA)
#> {cards} data frame: 3 x 11
#>   group1 group1_level      variable variable_level stat_name stat_label stat
#> 1   TRTA      Placebo ..row_count..           TRUE         n          n   86
#> 2   TRTA    Xanomeli… ..row_count..           TRUE         n          n   84
#> 3   TRTA    Xanomeli… ..row_count..           TRUE         n          n   84
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

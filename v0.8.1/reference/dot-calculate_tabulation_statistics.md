# Calculate Tabulation Statistics

Function takes the summary instructions from the
`statistic = list(variable_name = list(tabulation=c("n", "N", "p")))`
argument, and returns the tabulations in an ARD structure.

## Usage

``` r
.calculate_tabulation_statistics(
  data,
  variables,
  by,
  strata,
  denominator,
  statistic
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- variables:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to include in summaries. Default is
  [`everything()`](https://tidyselect.r-lib.org/reference/everything.html).

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

- denominator:

  (`string`, `data.frame`, `integer`)\
  Specify this argument to change the denominator, e.g. the `"N"`
  statistic. Default is `'column'`. See below for details.

- statistic:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element one or more of `c("n", "N", "p", "n_cum", "p_cum")` (on the
  RHS of a formula).

## Value

an ARD data frame of class 'card'

## Examples

``` r
cards:::.calculate_tabulation_statistics(
  ADSL,
  variables = "ARM",
  by = NULL,
  strata = NULL,
  denominator = "cell",
  statistic = list(ARM = list(tabulation = c("N")))
)
#> # A tibble: 3 × 6
#>   variable variable_level stat_name stat      warning error 
#>   <chr>    <list>         <chr>     <list>    <list>  <list>
#> 1 ARM      <chr [1]>      N         <int [1]> <NULL>  <NULL>
#> 2 ARM      <chr [1]>      N         <int [1]> <NULL>  <NULL>
#> 3 ARM      <chr [1]>      N         <int [1]> <NULL>  <NULL>
```

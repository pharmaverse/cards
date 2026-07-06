# Rename ARD Variables

Rename the grouping and variable columns to their original column names.

## Usage

``` r
rename_ard_columns(
  x,
  columns = c(all_ard_groups("names"), all_ard_variables("names")),
  fill = "{colname}",
  fct_as_chr = TRUE,
  unlist = NULL
)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class `'card'` or `'card_unlisted'`

- columns:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to rename, e.g. selecting columns
  `c('group1', 'group2', 'variable')` will rename `'group1_level'` to
  the name of the variable found in `'group1'`. When, for example, the
  `'group1_level'` does not exist, the values of the new column are
  filled with the values in the `fill` argument. Default is
  `c(all_ard_groups("names"), all_ard_variables("names"))`.

- fill:

  (scalar/glue)\
  a scalar to fill column values when the variable does not have levels.
  If a character is passed, then it is processed with
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) where
  the `colname` element is available to inject into the string, e.g.
  `'Overall {colname}'` may resolve to `'Overall AGE'` for an AGE
  column. Default is `'{colname}'`.

- fct_as_chr:

  (scalar `logical`)\
  When `TRUE`, factor elements will be converted to character before
  unlisting. When the column being unlisted contains mixed types of
  classes, the factor elements are often converted to the underlying
  integer value instead of retaining the label. Default is `TRUE`.

- unlist:

  **\[deprecated\]**

## Value

a data frame of class `'card_renamed'`

## Examples

``` r
# Example 1 ----------------------------------
ADSL |>
  ard_tabulate(by = ARM, variables = AGEGR1) |>
  apply_fmt_fun() |>
  rename_ard_columns() |>
  unlist_ard_columns()
#> # A tibble: 27 × 10
#>    ARM       AGEGR1 context stat_name stat_label   stat stat_fmt fmt_fun warning
#>    <chr>     <chr>  <chr>   <chr>     <chr>       <dbl> <chr>    <list>  <list> 
#>  1 Placebo   65-80  tabula… n         n          42     42       <int>   <NULL> 
#>  2 Placebo   65-80  tabula… N         N          86     86       <int>   <NULL> 
#>  3 Placebo   65-80  tabula… p         %           0.488 48.8     <fn>    <NULL> 
#>  4 Placebo   <65    tabula… n         n          14     14       <int>   <NULL> 
#>  5 Placebo   <65    tabula… N         N          86     86       <int>   <NULL> 
#>  6 Placebo   <65    tabula… p         %           0.163 16.3     <fn>    <NULL> 
#>  7 Placebo   >80    tabula… n         n          30     30       <int>   <NULL> 
#>  8 Placebo   >80    tabula… N         N          86     86       <int>   <NULL> 
#>  9 Placebo   >80    tabula… p         %           0.349 34.9     <fn>    <NULL> 
#> 10 Xanomeli… 65-80  tabula… n         n          55     55       <int>   <NULL> 
#> # ℹ 17 more rows
#> # ℹ 1 more variable: error <list>

# Example 2 ----------------------------------
ADSL |>
  ard_summary(by = ARM, variables = AGE) |>
  apply_fmt_fun() |>
  rename_ard_columns(fill = "Overall {colname}") |>
  unlist_ard_columns()
#> # A tibble: 24 × 10
#>    ARM         AGE   context stat_name stat_label  stat stat_fmt fmt_fun warning
#>    <chr>       <chr> <chr>   <chr>     <chr>      <dbl> <chr>    <list>  <list> 
#>  1 Placebo     Over… summary N         N          86    86       <int>   <NULL> 
#>  2 Placebo     Over… summary mean      Mean       75.2  75.2     <int>   <NULL> 
#>  3 Placebo     Over… summary sd        SD          8.59 8.6      <int>   <NULL> 
#>  4 Placebo     Over… summary median    Median     76    76.0     <int>   <NULL> 
#>  5 Placebo     Over… summary p25       Q1         69    69.0     <int>   <NULL> 
#>  6 Placebo     Over… summary p75       Q3         82    82.0     <int>   <NULL> 
#>  7 Placebo     Over… summary min       Min        52    52.0     <int>   <NULL> 
#>  8 Placebo     Over… summary max       Max        89    89.0     <int>   <NULL> 
#>  9 Xanomeline… Over… summary N         N          84    84       <int>   <NULL> 
#> 10 Xanomeline… Over… summary mean      Mean       74.4  74.4     <int>   <NULL> 
#> # ℹ 14 more rows
#> # ℹ 1 more variable: error <list>
```

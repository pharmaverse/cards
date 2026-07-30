# Calculate Continuous Statistics

Calculate statistics and return in an ARD format

## Usage

``` r
.calculate_stats_as_ard(
  df_nested,
  variables,
  statistic,
  by,
  strata,
  data,
  new_col_name = "...ard_all_stats..."
)
```

## Arguments

- df_nested:

  (`data.frame`)\
  a nested data frame

- variables:

  (`character`)\
  character vector of variables

- statistic:

  (named `list`)\
  named list of statistical functions

## Value

an ARD data frame of class 'card'

## Examples

``` r
data_nested <- ADSL |>
  nest_for_ard(
    by = "ARM",
    strata = NULL,
    key = "...ard_nested_data..."
  )

cards:::.calculate_stats_as_ard(
  df_nested = data_nested,
  variables = "AGE",
  statistic = list(mean = "mean"),
  by = "ARM",
  strata = NULL,
  data = ADSL
)
#> # A tibble: 3 × 4
#>   group1 group1_level ...ard_nested_data... ...ard_all_stats...
#>   <chr>  <list>       <list>                <list>             
#> 1 ARM    <chr [1]>    <tibble [86 × 48]>    <tibble [0 × 0]>   
#> 2 ARM    <chr [1]>    <tibble [84 × 48]>    <tibble [0 × 0]>   
#> 3 ARM    <chr [1]>    <tibble [84 × 48]>    <tibble [0 × 0]>   
```

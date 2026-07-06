# Check ARD Structure

Function tests the structure and returns notes when object does not
conform to expected structure.

## Usage

``` r
check_ard_structure(
  x,
  column_order = TRUE,
  method = TRUE,
  error_on_fail = FALSE
)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- column_order:

  (scalar `logical`)\
  check whether ordering of columns adheres to to
  [`cards::tidy_ard_column_order()`](https://insightsengineering.github.io/cards/reference/tidy_ard_order.md).

- method:

  (scalar `logical`)\
  check whether a `"stat_name"` equal to `"method"` appears in results.

- error_on_fail:

  (scalar `logical`)\
  Error if a check is failed? FALSE by default.

## Value

an ARD data frame of class 'card' (invisible)

## Examples

``` r
ard_summary(ADSL, variables = "AGE") |>
  dplyr::select(-warning, -error) |>
  check_ard_structure()
#> The following columns are not present: "warning" and "error".
#> Expecting a row with `stat_name = 'method'`, but it is not present.
```

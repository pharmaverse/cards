# Compare ARDs

**\[experimental\]**\
`compare_ard()` compares columns of two ARDs row-by-row using a shared
set of key columns. Rows where the column values differ are returned.

The `is_ard_equal()` function accepts a `compare_ard()` object, and
returns `TRUE` or `FALSE` depending on whether the comparison reported
difference. `check_ard_equal()` returns as error if not equal.

## Usage

``` r
compare_ard(
  x,
  y,
  keys = c(all_ard_groups(), all_ard_variables(), any_of(c("variable", "variable_level",
    "stat_name"))),
  columns = any_of(c("stat_label", "stat", "stat_fmt")),
  tolerance = sqrt(.Machine$double.eps),
  check.attributes = TRUE
)

is_ard_equal(x)

check_ard_equal(x)
```

## Arguments

- x:

  (`card`)\
  first ARD to compare.

- y:

  (`card`)\
  second ARD to compare.

- keys:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns identifying unique records. The intersection of the selected
  columns in both ARDs is used. Default is
  `c(all_ard_groups(), all_ard_variables(), any_of(c("variable", "variable_level", "stat_name")))`.

- columns:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to compare between the two ARDs. Default is
  `any_of(c("stat_label", "stat", "stat_fmt"))`.

- tolerance:

  (`numeric(1)`)\
  numeric tolerance passed to
  [`all.equal()`](https://rdrr.io/r/base/all.equal.html) for numeric
  comparisons. Default is `sqrt(.Machine$double.eps)`.

- check.attributes:

  (`logical(1)`)\
  logical passed to
  [`all.equal()`](https://rdrr.io/r/base/all.equal.html) indicating
  whether object attributes (e.g. names) should be compared. Default is
  `TRUE`.

## Value

a named list of class `"ard_comparison"` containing:

- `rows_in_x_not_y`: data frame of rows present in `x` but not in `y`
  (based on key columns)

- `rows_in_y_not_x`: data frame of rows present in `y` but not in `x`
  (based on key columns)

- `compare`: a named list where each element is a data frame containing
  the key columns, the compared column values from both ARDs, and a
  `difference` column with the
  [`all.equal()`](https://rdrr.io/r/base/all.equal.html) description for
  rows where values differ

## Examples

``` r
base <- ard_summary(ADSL, by = ARM, variables = AGE)
compare <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1),
  by = ARM,
  variables = AGE
)

compare_ard(base, compare)$compare$stat
#> NULL
```

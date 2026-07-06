# Fill Overall Group Variables

This function fills the missing values of grouping variables with
`"Overall <variable_name>"` or `"Any <variable_name>"`where relevant.
Specifically, it will modify grouping values from rows with likely
overall calculations present (e.g. non-missing variable/variable_level,
missing group variables, and evidence that the `variable` has been
computed by group in other rows). `"Overall"` values will be populated
only for grouping variables that have been used in other calculations of
the same variable and statistics. `"Any"` will be used if it is likely
to be a hierarchical calculation.

## Usage

``` r
.fill_overall_grp_values(x, vars_protected)
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

## Value

data frame

## Examples

``` r
data <- dplyr::tibble(
  grp = c("AA", "AA", NA, "BB", NA),
  variable = c("A", "B", "A", "C", "C"),
  variable_level = c(1, 2, 1, 3, 3),
  A = rep(NA, 5),
  B = rep(NA, 5),
  ..cards_idx.. = c(1:5)
)

cards:::.fill_overall_grp_values(data, vars_protected = "..cards_idx..")
#> # A tibble: 5 × 6
#>   grp         variable variable_level A     B     ..cards_idx..
#>   <chr>       <chr>             <dbl> <chr> <chr>         <int>
#> 1 AA          A                     1 NA    NA                1
#> 2 AA          B                     2 NA    NA                2
#> 3 Overall grp A                     1 NA    NA                3
#> 4 BB          C                     3 NA    NA                4
#> 5 Overall grp C                     3 NA    NA                5
```

# Back Fill Group Variables

This function back fills the values of group variables using
variable/variable_levels. The back filling will occur if the value of
the `variable` column matches the name of a grouping variable, and the
grouping variable's value is `NA`.

## Usage

``` r
.fill_grps_from_variables(x)
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

## Value

data frame

## Examples

``` r
data <- data.frame(
  variable = c(rep("A", 3), rep("B", 2)),
  variable_level = 1:5,
  A = rep(NA, 5),
  B = rep(NA, 5)
)

cards:::.fill_grps_from_variables(data)
#> # A tibble: 5 × 4
#>   variable variable_level     A     B
#>   <chr>             <int> <int> <int>
#> 1 A                     1     1    NA
#> 2 A                     2     2    NA
#> 3 A                     3     3    NA
#> 4 B                     4    NA     4
#> 5 B                     5    NA     5
```

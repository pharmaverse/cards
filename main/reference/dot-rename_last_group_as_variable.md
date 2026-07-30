# Rename Last Group to Variable

In the `ard_hierarchical*()` functions, the last grouping variable is
renamed to `variable` and `variable_level` before being returned.

## Usage

``` r
.rename_last_group_as_variable(df_result, by, variables)
```

## Arguments

- df_result:

  (`data.frame`)\
  an ARD data frame of class 'card'

## Value

an ARD data frame of class 'card'

## Examples

``` r
data <- data.frame(x = 1, y = 2, group1 = 3, group2 = 4)

cards:::.rename_last_group_as_variable(data, by = "ARM", variables = "AESOC")
#>   x y group1 variable
#> 1 1 2      3        4
```

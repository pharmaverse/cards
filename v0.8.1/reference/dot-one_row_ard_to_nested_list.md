# Convert One Row to Nested List

Convert One Row to Nested List

## Usage

``` r
.one_row_ard_to_nested_list(x)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card' with one row

## Value

an expression that represents an element of a nested list

## Examples

``` r
ard_summary(mtcars, variables = mpg) |>
  dplyr::filter(dplyr::row_number() %in% 1L) |>
  apply_fmt_fun() |>
  cards:::.one_row_ard_to_nested_list()
#> lst_return[["variable"]][["mpg"]][["stat_name"]][["N"]] <- list(
#>     stat = 32L, stat_fmt = "32", warning = NULL, error = NULL, 
#>     context = "summary")
```

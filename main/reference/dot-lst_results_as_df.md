# Prepare Results as Data Frame

Function takes the results from
[`eval_capture_conditions()`](https://insightsengineering.github.io/cards/reference/eval_capture_conditions.md),
which is a named list, e.g. `list(result=, warning=, error=)`, and
converts it to a data frame.

## Usage

``` r
.lst_results_as_df(x, variable, fun_name, fun)
```

## Arguments

- x:

  (named `list`)\
  the result from
  [`eval_capture_conditions()`](https://insightsengineering.github.io/cards/reference/eval_capture_conditions.md)

- variable:

  (`string`)\
  variable name of the results

- fun_name:

  (`string`)\
  name of function called to get results in `x`

## Value

a data frame

## Examples

``` r
msgs <- eval_capture_conditions({
  warning("Warning 1")
  warning("Warning 2")
  letters[1:2]
})

cards:::.lst_results_as_df(msgs, "result", "mean")
#>   stat_name stat              warning error variable
#> 1      mean a, b Warning 1, Warning 2  NULL   result
```

# ARD Identity

Function ingests pre-calculated statistics and returns the identical
results, but in an ARD format.

## Usage

``` r
ard_identity(x, variable, context = "identity")
```

## Arguments

- x:

  (named `list`/`data.frame`)\
  named list of results or a data frame. Names are the statistic names,
  and the values are the statistic values. These comprise the
  `"stat_name"` and `"stat"` columns in the returned ARD.

- variable:

  (`string`)\
  string of a variable name that is assigned to the `"variable"` column
  in the ARD.

- context:

  (`string`)\
  string to be added to the `"context"` column. Default is `"identity"`.

## Value

a ARD

## Examples

``` r
t.test(formula = AGE ~ 1, data = ADSL)[c("statistic", "parameter", "p.value")] |>
  ard_identity(variable = "AGE", context = "onesample_t_test")
#> {cards} data frame: 3 x 8
#>   variable   context stat_name stat_label    stat fmt_fun
#> 1      AGE onesampl… statistic  statistic 145.119       1
#> 2      AGE onesampl… parameter  parameter     253       1
#> 3      AGE onesampl…   p.value    p.value       0       1
#> ℹ 2 more variables: warning, error
```

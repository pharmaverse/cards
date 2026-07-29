# Maximum Value

For each column in the passed data frame, the function returns a named
list with the value being the largest/last element after a sort.
Character values are ordered in the C locale (via
`order(method = "radix")`), so the result is independent of the session
locale and consistent with the ordering used elsewhere in the package.
For factors, the last level is returned, and for logical vectors `TRUE`
is returned.

## Usage

``` r
maximum_variable_value(data)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

## Value

a named list

## Examples

``` r
ADSL[c("AGEGR1", "BMIBLGR1")] |> maximum_variable_value()
#> $AGEGR1
#> [1] ">80"
#> 
#> $BMIBLGR1
#> [1] ">=30"
#> 
```

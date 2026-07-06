# Generate Formatting Function

Returns a function with the requested rounding and scaling schema.

## Usage

``` r
label_round(digits = 1, scale = 1, width = NULL)
```

## Arguments

- digits:

  (`integer`)\
  a non-negative integer specifying the number of decimal places round
  statistics to

- scale:

  (`numeric`)\
  a scalar real number. Before rounding, the input will be scaled by
  this quantity

- width:

  (`integer`)\
  a non-negative integer specifying the minimum width of the returned
  formatted values

## Value

a function

## Examples

``` r
label_round(2)(pi)
#> [1] "3.14"
label_round(1, scale = 100)(pi)
#> [1] "314.2"
label_round(2, width = 5)(pi)
#> [1] " 3.14"
```

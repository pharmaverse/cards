# Rounding of Numbers

Rounds the values in its first argument to the specified number of
decimal places (default 0). Importantly, `round5()` **does not** use
Base R's "round to even" default. Standard rounding methods are
implemented, for example, `cards::round5(0.5) = 1`, whereas
`base::round(0.5) = 0`.

## Usage

``` r
round5(x, digits = 0)
```

## Arguments

- x:

  (`numeric`)\
  a numeric vector

- digits:

  (`integer`)\
  integer indicating the number of decimal places

## Value

a numeric vector

## Details

Function inspired by `janitor::round_half_up()`.

## Examples

``` r
x <- 0:4 / 2
round5(x) |> setNames(x)
#>   0 0.5   1 1.5   2 
#>   0   1   1   2   2 

# compare results to Base R
round(x) |> setNames(x)
#>   0 0.5   1 1.5   2 
#>   0   0   1   2   2 
```

# A list_flatten()-like Function

Function operates similarly to
`purrr::list_flatten(x, name_spec = "{inner}")`.

## Usage

``` r
.purrr_list_flatten(x)
```

## Arguments

- x:

  (named `list`)\
  a named list

## Value

a named list

## Examples

``` r
x <- list(a = 1, b = list(b1 = 2, b2 = 3), c = list(c1 = 4, c2 = list(c2a = 5)))

cards:::.purrr_list_flatten(x)
#> $a
#> [1] 1
#> 
#> $b1
#> [1] 2
#> 
#> $b2
#> [1] 3
#> 
#> $c1
#> [1] 4
#> 
#> $c2
#> $c2$c2a
#> [1] 5
#> 
#> 
```

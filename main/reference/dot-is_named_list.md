# Named List Predicate

A predicate function to check whether input is a named list and *not* a
data frame.

## Usage

``` r
.is_named_list(x, allow_df = FALSE)
```

## Arguments

- x:

  (`any`)\
  object to check

## Value

a logical

## Examples

``` r
cards:::.is_named_list(list(a = 1:3))
#> [1] TRUE
```

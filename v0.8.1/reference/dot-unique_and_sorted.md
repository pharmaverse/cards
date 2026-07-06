# ARD-flavor of unique()

Essentially a wrapper for `unique(x) |> sort()` with `NA` levels
removed. For factors, all levels are returned even if they are
unobserved. Similarly, logical vectors always return `c(TRUE, FALSE)`,
even if both levels are not observed.

## Usage

``` r
.unique_and_sorted(x, useNA = c("no", "always"))
```

## Arguments

- x:

  (`any`)\
  a vector

## Value

a vector

## Examples

``` r
cards:::.unique_and_sorted(factor(letters[c(5, 5:1)], levels = letters))
#>  [1] a b c d e f g h i j k l m n o p q r s t u v w x y z
#> Levels: a b c d e f g h i j k l m n o p q r s t u v w x y z

cards:::.unique_and_sorted(c(FALSE, TRUE, TRUE, FALSE))
#> [1] FALSE  TRUE

cards:::.unique_and_sorted(c(5, 5:1))
#> [1] 1 2 3 4 5
```

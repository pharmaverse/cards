# Check Variable Names

Checks variable names in a data frame against protected names and
modifies them if needed

## Usage

``` r
.check_var_nms(x, vars_protected)
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

- vars_protected:

  (`character`)\
  a character vector of protected names

## Value

a data frame

## Examples

``` r
data <- data.frame(a = "x", b = "y", c = "z", ..cards_idx.. = 1)

cards:::.check_var_nms(data, vars_protected = c("x", "z"))
#>     a b   c ..cards_idx..
#> 1 x.1 y z.1             1
```

# Check 'xx' Format Structure

A function that checks a **single** string for consistency. String must
begin with 'x' and only consist of x's, a single period or none, and may
end with a percent symbol.

If string is consistent, `TRUE` is returned. Otherwise an error.

## Usage

``` r
.check_fmt_string(x, variable, stat_name)
```

## Arguments

- x:

  (`string`)\
  string to check

- variable:

  (`character`)\
  the variable whose statistic is to be formatted

- stat_name:

  (`character`)\
  the name of the statistic that is to be formatted

## Value

a logical

## Examples

``` r
cards:::.check_fmt_string("xx.x") # TRUE
#> [1] TRUE
cards:::.check_fmt_string("xx.x%") # TRUE
#> [1] TRUE
```

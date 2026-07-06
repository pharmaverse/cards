# Check Protected Column Names

Checks that column names in a passed data frame are not protected, that
is, they do not begin with `"...ard_"` and end with `"..."`.

## Usage

``` r
.check_no_ard_columns(x, exceptions = "...ard_dummy_for_counting...")
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

- exceptions:

  (`string`)\
  character string of column names to exclude from checks

## Value

returns invisible if check is successful, throws an error message if
not.

## Examples

``` r
data <- data.frame("ard_x" = 1)

cards:::.check_no_ard_columns(data)
```

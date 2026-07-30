# Perform Value Checks

Check the validity of the values passed in `ard_tabulate_value(value)`.

## Usage

``` r
.check_dichotomous_value(data, value)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- value:

  (named `list`)\
  a named list

## Value

returns invisible if check is successful, throws an error message if
not.

## Examples

``` r
cards:::.check_dichotomous_value(mtcars, list(cyl = 4))
```

# Check for Missing Levels in `denominator`

When a user passes a data frame in the `denominator` argument, this
function checks that the data frame contains all the same levels of the
`by` and `strata` variables that appear in `data`.

## Usage

``` r
.check_for_missing_combos_in_denom(data, denominator, by, strata)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- denominator:

  (`data.frame`)\
  denominator data frame

- by:

  (`character`)\
  character vector of by column names

- strata:

  (`character`)\
  character vector of strata column names

## Value

returns invisible if check is successful, throws an error message if
not.

## Examples

``` r
cards:::.check_for_missing_combos_in_denom(ADSL, denominator = "col", by = "ARM", strata = "AGEGR1")
```

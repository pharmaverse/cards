# Process `denominator` Argument

Function takes the `ard_tabulate(denominator)` argument and returns a
structured data frame that is merged with the count data and used as the
denominator in percentage calculations.

## Usage

``` r
.process_denominator(data, variables, denominator, by, strata)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- variables:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to include in summaries. Default is
  [`everything()`](https://tidyselect.r-lib.org/reference/everything.html).

- denominator:

  (`string`, `data.frame`, `integer`)\
  Specify this argument to change the denominator, e.g. the `"N"`
  statistic. Default is `'column'`. See below for details.

- by, strata:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to use for grouping or stratifying the table output. Arguments
  are similar, but with an important distinction:

  `by`: results are tabulated by **all combinations** of the columns
  specified, including unobserved combinations and unobserved factor
  levels.

  `strata`: results are tabulated by **all *observed* combinations** of
  the columns specified.

  Arguments may be used in conjunction with one another.

## Value

a data frame

## Examples

``` r
cards:::.process_denominator(mtcars, denominator = 1000, variables = "cyl", by = "gear")
#> $cyl
#> # A tibble: 1 × 1
#>   ...ard_N...
#>         <int>
#> 1        1000
#> 
```

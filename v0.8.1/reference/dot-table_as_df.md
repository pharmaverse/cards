# Results from `table()` as Data Frame

Takes the results from [`table()`](https://rdrr.io/r/base/table.html)
and returns them as a data frame. After the
[`table()`](https://rdrr.io/r/base/table.html) results are made into a
data frame, all the variables are made into character columns, and the
function also restores the column types to their original classes. For
`strata` columns, only observed combinations are returned.

## Usage

``` r
.table_as_df(
  data,
  variable = NULL,
  by = NULL,
  strata = NULL,
  useNA = c("no", "always"),
  count_column = "...ard_n..."
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- variable:

  (`string`)\
  a string indicating a column in data

- by:

  (`character`)\
  a character vector indicating columns in data

- strata:

  (`character`)\
  a character vector indicating columns in data

- useNA:

  (`string`)\
  one of `"no"` and `"always"`. Will be passed to `table(useNA)`.

## Value

data frame

## Examples

``` r
cards:::.table_as_df(ADSL, variable = "ARM", by = "AGEGR1", strata = NULL)
#> # A tibble: 9 × 3
#>   AGEGR1 ARM                  ...ard_n...
#>   <chr>  <chr>                      <int>
#> 1 65-80  Placebo                       42
#> 2 <65    Placebo                       14
#> 3 >80    Placebo                       30
#> 4 65-80  Xanomeline High Dose          55
#> 5 <65    Xanomeline High Dose          11
#> 6 >80    Xanomeline High Dose          18
#> 7 65-80  Xanomeline Low Dose           47
#> 8 <65    Xanomeline Low Dose            8
#> 9 >80    Xanomeline Low Dose           29
```

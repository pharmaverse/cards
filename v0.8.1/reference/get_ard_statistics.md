# ARD Statistics as List

Returns the statistics from an ARD as a named list.

## Usage

``` r
get_ard_statistics(x, ..., .column = "stat", .attributes = NULL)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- ...:

  ([`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html))\
  optional arguments indicating rows to subset of the ARD. For example,
  to return only rows where the column `"AGEGR1"` is `"65-80"`, pass
  `AGEGR1 %in% "65-80"`.

- .column:

  (`string`)\
  string indicating the column that will be returned in the list.
  Default is `"statistic"`

- .attributes:

  (`character`)\
  character vector of column names that will be returned in the list as
  attributes. Default is `NULL`

## Value

named list

## Examples

``` r
ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

get_ard_statistics(
  ard,
  group1_level %in% "Placebo",
  variable_level %in% "65-80",
  .attributes = "stat_label"
)
#> $n
#> [1] 42
#> attr(,"stat_label")
#> [1] "ARM"
#> 
#> $N
#> [1] 86
#> attr(,"stat_label")
#> [1] "ARM"
#> 
#> $p
#> [1] 0.4883721
#> attr(,"stat_label")
#> [1] "ARM"
#> 
```

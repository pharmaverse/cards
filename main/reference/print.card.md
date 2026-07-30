# Print

**\[experimental\]**\
Print method for objects of class 'card'

## Usage

``` r
# S3 method for class 'card'
print(x, n = NULL, columns = c("auto", "all"), n_col = 6L, ...)

# S3 method for class 'compare_ard'
print(x, ...)
```

## Arguments

- x:

  (`data.frame`)\
  object of class 'card'

- n:

  (`integer`)\
  integer specifying the number of rows to print

- columns:

  (`string`)\
  string indicating whether to print a selected number of columns or
  all.

- n_col:

  (`integer`)\
  some columns are removed when there are more than a threshold of
  columns present. This argument sets that threshold. This is only used
  when `columns='auto'` and default is `6L`. Columns `'error'`,
  `'warning'`, `'context'`, and `'fmt_fun'` *may* be removed from the
  print. All other columns will be printed, even if more than `n_col`
  columns are present.

- ...:

  ([`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html))\
  not used

## Value

an ARD data frame of class 'card' (invisibly)

## Examples

``` r
ard_tabulate(ADSL, variables = AGEGR1) |>
  print()
#> {cards} data frame: 9 x 9
#>   variable variable_level  context stat_name stat_label  stat
#> 1   AGEGR1          65-80 tabulate         n          n   144
#> 2   AGEGR1          65-80 tabulate         N          N   254
#> 3   AGEGR1          65-80 tabulate         p          % 0.567
#> 4   AGEGR1            <65 tabulate         n          n    33
#> 5   AGEGR1            <65 tabulate         N          N   254
#> 6   AGEGR1            <65 tabulate         p          %  0.13
#> 7   AGEGR1            >80 tabulate         n          n    77
#> 8   AGEGR1            >80 tabulate         N          N   254
#> 9   AGEGR1            >80 tabulate         p          % 0.303
#> ℹ 3 more variables: fmt_fun, warning, error
```

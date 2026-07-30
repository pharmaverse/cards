# Replace NULL Statistics with Specified Value

When a statistical summary function errors, the `"stat"` column will be
`NULL`. It is, however, sometimes useful to replace these values with a
non-`NULL` value, e.g. `NA`.

## Usage

``` r
replace_null_statistic(x, value = NA, rows = TRUE)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- value:

  (usually a `scalar`)\
  The value to replace `NULL` values with. Default is `NA`.

- rows:

  ([`data-masking`](https://rlang.r-lib.org/reference/args_data_masking.html))\
  Expression that return a logical value, and are defined in terms of
  the variables in `.data`. Only rows for which the condition evaluates
  to `TRUE` are replaced. Default is `TRUE`, which applies to all rows.

## Value

an ARD data frame of class 'card'

## Examples

``` r
# the quantile functions error because the input is character, while the median function returns NA
data.frame(x = rep_len(NA_character_, 10)) |>
  ard_summary(
    variables = x,
    statistic = ~ continuous_summary_fns(c("median", "p25", "p75"))
  ) |>
  replace_null_statistic(rows = !is.null(error))
#> {cards} data frame: 3 x 8
#>   variable context stat_name stat_label stat     error
#> 1        x summary    median     Median   NA          
#> 2        x summary       p25         Q1   NA non-nume…
#> 3        x summary       p75         Q3   NA non-nume…
#> ℹ 2 more variables: fmt_fun, warning
```

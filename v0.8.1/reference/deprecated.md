# Deprecated functions

**\[deprecated\]**\
Some functions have been deprecated and are no longer being actively
supported.

**Renamed functions**

- `ard_categorical()` to
  [`ard_tabulate()`](https://insightsengineering.github.io/cards/reference/ard_tabulate.md)

- `ard_continuous()` to
  [`ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md)

- `ard_complex()` to
  [`ard_mvsummary()`](https://insightsengineering.github.io/cards/reference/ard_mvsummary.md)

- `apply_fmt_fn()` to
  [`apply_fmt_fun()`](https://insightsengineering.github.io/cards/reference/apply_fmt_fun.md)

- `alias_as_fmt_fn()` to
  [`alias_as_fmt_fun()`](https://insightsengineering.github.io/cards/reference/alias_as_fmt_fun.md)

- `update_ard_fmt_fn()` to
  [`update_ard_fmt_fun()`](https://insightsengineering.github.io/cards/reference/update_ard.md)

**Deprecated functions**

- `shuffle_ard()`

**\[deprecated\]**\

This function ingests an ARD object and shuffles the information to
prepare for analysis. Helpful for streamlining across multiple ARDs.
Combines each group/group_level into 1 column, back fills missing
grouping values from the variable levels where possible, and optionally
trims statistics-level metadata.

## Usage

``` r
ard_continuous(data, ...)

ard_categorical(data, ...)

ard_complex(data, ...)

ard_dichotomous(data, ...)

# S3 method for class 'data.frame'
ard_continuous(data, ...)

# S3 method for class 'data.frame'
ard_categorical(data, ...)

# S3 method for class 'data.frame'
ard_complex(data, ...)

# S3 method for class 'data.frame'
ard_dichotomous(data, ...)

apply_fmt_fn(...)

alias_as_fmt_fn(...)

update_ard_fmt_fn(...)

shuffle_ard(x, trim = TRUE)
```

## Arguments

- data, ...:

  **\[deprecated\]**

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- trim:

  (`logical`)\
  logical representing whether or not to trim away statistic-level
  metadata and filter only on numeric statistic values.

## Value

a tibble

## Examples

``` r
bind_ard(
  ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1"),
  ard_tabulate(ADSL, variables = "ARM")
) |>
  shuffle_ard()
#> Warning: `shuffle_ard()` was deprecated in cards 0.8.0.
#> ℹ Please use `tfrmt::shuffle_card()` instead.
#> # A tibble: 36 × 7
#>    ARM               variable variable_level context stat_name stat_label   stat
#>    <chr>             <chr>    <chr>          <chr>   <chr>     <chr>       <dbl>
#>  1 Placebo           AGEGR1   65-80          tabula… n         n          42    
#>  2 Placebo           AGEGR1   65-80          tabula… N         N          86    
#>  3 Placebo           AGEGR1   65-80          tabula… p         %           0.488
#>  4 Placebo           AGEGR1   <65            tabula… n         n          14    
#>  5 Placebo           AGEGR1   <65            tabula… N         N          86    
#>  6 Placebo           AGEGR1   <65            tabula… p         %           0.163
#>  7 Placebo           AGEGR1   >80            tabula… n         n          30    
#>  8 Placebo           AGEGR1   >80            tabula… N         N          86    
#>  9 Placebo           AGEGR1   >80            tabula… p         %           0.349
#> 10 Xanomeline High … AGEGR1   65-80          tabula… n         n          55    
#> # ℹ 26 more rows
```

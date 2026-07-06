# Unlist ARD Columns

Unlist ARD Columns

## Usage

``` r
unlist_ard_columns(
  x,
  columns = c(where(is.list), -any_of(c("warning", "error", "fmt_fun"))),
  fill = NA,
  fct_as_chr = TRUE
)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card' or any data frame

- columns:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to unlist. Default is
  `c(where(is.list), -any_of(c("warning", "error", "fmt_fun")))`.

- fill:

  (scalar)\
  scalar to fill NULL values with before unlisting (if they are
  present). Default is `NA`.

- fct_as_chr:

  (scalar `logical`)\
  When `TRUE`, factor elements will be converted to character before
  unlisting. When the column being unlisted contains mixed types of
  classes, the factor elements are often converted to the underlying
  integer value instead of retaining the label. Default is `TRUE`.

## Value

a data frame of class `'card_unlisted'`

## Examples

``` r
ADSL |>
  ard_tabulate(by = ARM, variables = AGEGR1) |>
  apply_fmt_fun() |>
  unlist_ard_columns()
#> # A tibble: 27 × 12
#>    group1 group1_level      variable variable_level context stat_name stat_label
#>    <chr>  <chr>             <chr>    <chr>          <chr>   <chr>     <chr>     
#>  1 ARM    Placebo           AGEGR1   65-80          tabula… n         n         
#>  2 ARM    Placebo           AGEGR1   65-80          tabula… N         N         
#>  3 ARM    Placebo           AGEGR1   65-80          tabula… p         %         
#>  4 ARM    Placebo           AGEGR1   <65            tabula… n         n         
#>  5 ARM    Placebo           AGEGR1   <65            tabula… N         N         
#>  6 ARM    Placebo           AGEGR1   <65            tabula… p         %         
#>  7 ARM    Placebo           AGEGR1   >80            tabula… n         n         
#>  8 ARM    Placebo           AGEGR1   >80            tabula… N         N         
#>  9 ARM    Placebo           AGEGR1   >80            tabula… p         %         
#> 10 ARM    Xanomeline High … AGEGR1   65-80          tabula… n         n         
#> # ℹ 17 more rows
#> # ℹ 5 more variables: stat <dbl>, stat_fmt <chr>, fmt_fun <list>,
#> #   warning <list>, error <list>

ADSL |>
  ard_summary(by = ARM, variables = AGE) |>
  apply_fmt_fun() |>
  unlist_ard_columns()
#> # A tibble: 24 × 11
#>    group1 group1_level      variable context stat_name stat_label  stat stat_fmt
#>    <chr>  <chr>             <chr>    <chr>   <chr>     <chr>      <dbl> <chr>   
#>  1 ARM    Placebo           AGE      summary N         N          86    86      
#>  2 ARM    Placebo           AGE      summary mean      Mean       75.2  75.2    
#>  3 ARM    Placebo           AGE      summary sd        SD          8.59 8.6     
#>  4 ARM    Placebo           AGE      summary median    Median     76    76.0    
#>  5 ARM    Placebo           AGE      summary p25       Q1         69    69.0    
#>  6 ARM    Placebo           AGE      summary p75       Q3         82    82.0    
#>  7 ARM    Placebo           AGE      summary min       Min        52    52.0    
#>  8 ARM    Placebo           AGE      summary max       Max        89    89.0    
#>  9 ARM    Xanomeline High … AGE      summary N         N          84    84      
#> 10 ARM    Xanomeline High … AGE      summary mean      Mean       74.4  74.4    
#> # ℹ 14 more rows
#> # ℹ 3 more variables: fmt_fun <list>, warning <list>, error <list>
```

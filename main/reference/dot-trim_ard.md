# Trim ARD

This function ingests an ARD object and trims columns and rows for
downstream use in displays. The resulting data frame contains only
numeric results, no supplemental information about errors/warnings, and
unnested list columns.

## Usage

``` r
.trim_ard(x)
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

## Value

a tibble

## Examples

``` r
ard <- bind_ard(
  ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1"),
  ard_tabulate(ADSL, variables = "ARM")
) |>
  shuffle_ard(trim = FALSE)
#> Warning: `shuffle_ard()` was deprecated in cards 0.8.0.
#> ℹ Please use `tfrmt::shuffle_card()` instead.

ard |> cards:::.trim_ard()
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

# Add Default Formatting Functions

Add Default Formatting Functions

## Usage

``` r
.default_fmt_fun(x)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

## Value

a data frame

## Examples

``` r
ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1") |>
  dplyr::mutate(fmt_fun = NA)

cards:::.default_fmt_fun(ard)
#> {cards} data frame: 27 x 11
#>    group1 group1_level variable variable_level stat_name stat_label  stat
#> 1     ARM      Placebo   AGEGR1          65-80         n          n    42
#> 2     ARM      Placebo   AGEGR1          65-80         N          N    86
#> 3     ARM      Placebo   AGEGR1          65-80         p          % 0.488
#> 4     ARM      Placebo   AGEGR1            <65         n          n    14
#> 5     ARM      Placebo   AGEGR1            <65         N          N    86
#> 6     ARM      Placebo   AGEGR1            <65         p          % 0.163
#> 7     ARM      Placebo   AGEGR1            >80         n          n    30
#> 8     ARM      Placebo   AGEGR1            >80         N          N    86
#> 9     ARM      Placebo   AGEGR1            >80         p          % 0.349
#> 10    ARM    Xanomeli…   AGEGR1          65-80         n          n    55
#> ℹ 17 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

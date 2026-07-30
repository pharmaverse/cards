# Convert Nested Lists to Column

Some arguments, such as `stat_label`, are passed as nested lists. This
function properly unnests these lists and adds them to the results data
frame.

## Usage

``` r
.process_nested_list_as_df(x, arg, new_column, unlist = FALSE)
```

## Arguments

- x:

  (`data.frame`)\
  result data frame

- arg:

  (`list`)\
  the nested list

- new_column:

  (`string`)\
  new column name

- unlist:

  (`logical`)\
  whether to fully unlist final results

## Value

a data frame

## Examples

``` r
ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

cards:::.process_nested_list_as_df(ard, NULL, "new_col")
#> {cards} data frame: 27 x 12
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
#> ℹ 5 more variables: context, fmt_fun, warning, error, new_col
```

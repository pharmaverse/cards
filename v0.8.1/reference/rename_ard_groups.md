# Rename ARD Group Columns

Functions for renaming group columns names in ARDs.

## Usage

``` r
rename_ard_groups_shift(x, shift = -1)

rename_ard_groups_reverse(x)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'.

- shift:

  (`integer`)\
  an integer specifying how many values to shift the group IDs, e.g.
  `shift=-1` renames `group2` to `group1`.

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard <- ard_summary(ADSL, by = c(SEX, ARM), variables = AGE)

# Example 1 ----------------------------------
rename_ard_groups_shift(ard, shift = -1)
#> There are now non-standard group column names: "group0" and "group0_level".
#> ℹ Is this the shift you had planned?
#> {cards} data frame: 48 x 12
#>    group0 group0_level group1 group1_level variable stat_name stat_label   stat
#> 1     SEX            F    ARM      Placebo      AGE         N          N     53
#> 2     SEX            F    ARM      Placebo      AGE      mean       Mean 76.358
#> 3     SEX            F    ARM      Placebo      AGE        sd         SD  8.733
#> 4     SEX            F    ARM      Placebo      AGE    median     Median     78
#> 5     SEX            F    ARM      Placebo      AGE       p25         Q1     70
#> 6     SEX            F    ARM      Placebo      AGE       p75         Q3     84
#> 7     SEX            F    ARM      Placebo      AGE       min        Min     59
#> 8     SEX            F    ARM      Placebo      AGE       max        Max     89
#> 9     SEX            F    ARM    Xanomeli…      AGE         N          N     40
#> 10    SEX            F    ARM    Xanomeli…      AGE      mean       Mean 74.675
#> ℹ 38 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

# Example 2 ----------------------------------
rename_ard_groups_reverse(ard)
#> {cards} data frame: 48 x 12
#>    group1 group1_level group2 group2_level variable stat_name stat_label   stat
#> 1     ARM      Placebo    SEX            F      AGE         N          N     53
#> 2     ARM      Placebo    SEX            F      AGE      mean       Mean 76.358
#> 3     ARM      Placebo    SEX            F      AGE        sd         SD  8.733
#> 4     ARM      Placebo    SEX            F      AGE    median     Median     78
#> 5     ARM      Placebo    SEX            F      AGE       p25         Q1     70
#> 6     ARM      Placebo    SEX            F      AGE       p75         Q3     84
#> 7     ARM      Placebo    SEX            F      AGE       min        Min     59
#> 8     ARM      Placebo    SEX            F      AGE       max        Max     89
#> 9     ARM    Xanomeli…    SEX            F      AGE         N          N     40
#> 10    ARM    Xanomeli…    SEX            F      AGE      mean       Mean 74.675
#> ℹ 38 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

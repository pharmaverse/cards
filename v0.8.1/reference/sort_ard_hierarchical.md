# Sort Stacked Hierarchical ARDs

**\[experimental\]**\

This function is used to sort stacked hierarchical ARDs.

For the purposes of this function, we define a "variable group" as a
combination of ARD rows grouped by the combination of all their variable
levels, but excluding any `by` variables.

## Usage

``` r
sort_ard_hierarchical(x, sort = everything() ~ "descending")
```

## Arguments

- x:

  (`card`)\
  a stacked hierarchical ARD of class `'card'` created using
  [`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
  or
  [`ard_stack_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md).

- sort:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md),
  `string`)\
  a named list, a list of formulas, a single formula where the list
  element is a named list of functions (or the RHS of a formula), or a
  single string specifying the types of sorting to perform at each
  hierarchy variable level. If the sort method for any variable is not
  specified then the method will default to `"descending"`. If a single
  unnamed string is supplied it is applied to all variables. For each
  variable, the value specified must be one of:

  - `"alphanumeric"` - at the specified hierarchy level of the ARD,
    groups are ordered alphanumerically (i.e. A to Z) by
    `variable_level` text.

  - `"descending"` - within each variable group of the ARD at the
    specified hierarchy level, count sums are calculated for each group
    and groups are sorted in descending order by sum. When `sort` is
    `"descending"` for a given variable and `n` is included in
    `statistic` for the variable then `n` is used to calculate variable
    group sums, otherwise `p` is used. If neither `n` nor `p` are
    present in `x` for the variable, an error will occur.

  Defaults to `everything() ~ "descending"`.

## Value

an ARD data frame of class 'card'

## Note

If overall data is present in `x` (i.e. the ARD was created with
`ard_stack_hierarchical(overall=TRUE)`), the overall data will be sorted
last within each variable group (i.e. after any other rows with the same
combination of variable levels).

## See also

[`filter_ard_hierarchical()`](https://insightsengineering.github.io/cards/reference/filter_ard_hierarchical.md)

## Examples

``` r
ard_stack_hierarchical(
  ADAE,
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  denominator = ADSL,
  id = USUBJID
) |>
  sort_ard_hierarchical(AESOC ~ "alphanumeric")
#> {cards} data frame: 2394 x 13
#>    group1 group1_level group2 group2_level variable variable_level stat_name
#> 1    <NA>                <NA>                  TRTA        Placebo         n
#> 2    <NA>                <NA>                  TRTA        Placebo         N
#> 3    <NA>                <NA>                  TRTA        Placebo         p
#> 4    <NA>                <NA>                  TRTA      Xanomeli…         n
#> 5    <NA>                <NA>                  TRTA      Xanomeli…         N
#> 6    <NA>                <NA>                  TRTA      Xanomeli…         p
#> 7    <NA>                <NA>                  TRTA      Xanomeli…         n
#> 8    <NA>                <NA>                  TRTA      Xanomeli…         N
#> 9    <NA>                <NA>                  TRTA      Xanomeli…         p
#> 10   TRTA      Placebo   <NA>                 AESOC      CARDIAC …         n
#>    stat_label  stat
#> 1           n    86
#> 2           N   254
#> 3           % 0.339
#> 4           n    84
#> 5           N   254
#> 6           % 0.331
#> 7           n    84
#> 8           N   254
#> 9           % 0.331
#> 10          n    13
#> ℹ 2384 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

ard_stack_hierarchical_count(
  ADAE,
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  denominator = ADSL
) |>
  sort_ard_hierarchical(sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"))
#> {cards} data frame: 804 x 13
#>    group1 group1_level group2 group2_level variable variable_level stat_name
#> 1    <NA>                <NA>                  TRTA        Placebo         n
#> 2    <NA>                <NA>                  TRTA        Placebo         N
#> 3    <NA>                <NA>                  TRTA        Placebo         p
#> 4    <NA>                <NA>                  TRTA      Xanomeli…         n
#> 5    <NA>                <NA>                  TRTA      Xanomeli…         N
#> 6    <NA>                <NA>                  TRTA      Xanomeli…         p
#> 7    <NA>                <NA>                  TRTA      Xanomeli…         n
#> 8    <NA>                <NA>                  TRTA      Xanomeli…         N
#> 9    <NA>                <NA>                  TRTA      Xanomeli…         p
#> 10   TRTA      Placebo   <NA>                 AESOC      CARDIAC …         n
#>    stat_label  stat
#> 1           n    86
#> 2           N   254
#> 3           % 0.339
#> 4           n    84
#> 5           N   254
#> 6           % 0.331
#> 7           n    84
#> 8           N   254
#> 9           % 0.331
#> 10          n    27
#> ℹ 794 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

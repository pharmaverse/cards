# Filter Stacked Hierarchical ARDs

**\[experimental\]**\

This function is used to filter stacked hierarchical ARDs.

For the purposes of this function, we define a "variable group" as a
combination of ARD rows grouped by the combination of all their variable
levels, but excluding any `by` variables.

## Usage

``` r
filter_ard_hierarchical(
  x,
  filter,
  var = NULL,
  keep_empty = FALSE,
  quiet = FALSE
)
```

## Arguments

- x:

  (`card`)\
  a stacked hierarchical ARD of class `'card'` created using
  [`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
  or
  [`ard_stack_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md).

- filter:

  (`expression`)\
  an expression that is used to filter variable groups of the
  hierarchical ARD. See the Details section below.

- var:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  hierarchy variable from `x` to perform filtering on. If `NULL`, the
  last hierarchy variable from `x`
  (`dplyr::last(attributes(x)$args$variables)`) will be used.

- keep_empty:

  (scalar `logical`)\
  Logical argument indicating whether to retain summary rows
  corresponding to hierarchy sections that have had all rows filtered
  out. Default is `FALSE`.

- quiet:

  (`logical`)\
  logical indicating whether to suppress any messaging. Default is
  `FALSE`.

## Value

an ARD data frame of class 'card'

## Details

The `filter` argument can be used to filter out variable groups of a
hierarchical ARD which do not meet the requirements provided as an
expression. Variable groups can be filtered on the values of any of the
possible statistics (`n`, `p`, and `N`) provided they are included at
least once in the ARD, as well as the values of any `by` variables.

Additionally, filters can be applied on individual levels of the `by`
variable via the `n_XX`, `N_XX`, and `p_XX` statistics, where each `XX`
represents the index of the `by` variable level to select the statistic
from. For example, `filter = n_1 > 5` will check whether `n` values for
the first level of `by` are greater than 5 in each row group.

Overall statistics for each row group can be used in filters via the
`n_overall`, `N_overall`, and `p_overall` statistics. If the ARD is
created with parameter `overall=TRUE`, then these overall statistics
will be extracted directly from the ARD, otherwise the statistics will
be derived where possible. If `overall=FALSE`, then `n_overall` can only
be derived if the `n` statistic is present in the ARD for the filter
variable, `N_overall` if the `N` statistic is present for the filter
variable, and `p_overall` if both the `n` and `N` statistics are present
for the filter variable.

By default, filters will be applied at the level of the innermost
hierarchy variable, i.e. the last variable supplied to `variables`. If
filters should instead be applied at the level of one of the outer
hierarchy variables, the `var` parameter can be used to select a
different variable to filter on. When `var` is set to a different
(outer) variable and a level of the variable does not meet the filtering
criteria then the section corresponding to that variable level and all
sub-sections within that section will be removed.

To illustrate how the function works, consider the typical example below
where the AE summaries are provided by treatment group.

    ADAE |>
      dplyr::filter(AESOC == "GASTROINTESTINAL DISORDERS",
                    AEDECOD %in% c("VOMITING", "DIARRHOEA")) |>
      ard_stack_hierarchical(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        denominator = ADSL,
        id = USUBJID
      )

|  |  |  |  |
|----|----|----|----|
| **SOC** / AE | Placebo | Xanomeline High Dose | Xanomeline Low Dose |
| **GASTROINTESTINAL DISORDERS** | 11 (13%) | 10 (12%) | 8 (9.5%) |
| DIARRHOEA | 9 (10%) | 4 (4.8%) | 5 (6.0%) |
| VOMITING | 3 (3.5%) | 7 (8.3%) | 3 (3.6%) |

Filters are applied to the summary statistics of the innermost variable
in the hierarchy by default—`AEDECOD` in this case. If we wanted to
filter based on SOC rates instead of AE rates we could specify
`var = AESOC` instead. If any of the summary statistics meet the filter
requirement for any of the treatment groups, the entire row is retained.
For example, if `filter = n >= 9` were passed, the criteria would be met
for DIARRHOEA as the Placebo group observed 9 AEs and as a result the
summary statistics for the other treatment groups would be retained as
well. Conversely, no treatment groups' summary statistics satisfy the
filter requirement for VOMITING so all rows associated with this AE
would be removed.

In addition to filtering on individual statistic values, filters can be
applied across the treatment groups (i.e. across all `by` variable
values) by using aggregate functions such as
[`sum()`](https://rdrr.io/r/base/sum.html) and
[`mean()`](https://rdrr.io/r/base/mean.html). For simplicity, it is
suggested to use the `XX_overall` statistics in place of `sum(XX)` in
equivalent scenarios. For example, `n_overall` is equivalent to
`sum(n)`. A value of `filter = sum(n) >= 18` (or
`filter = n_overall >= 18`) retains AEs where the sum of the number of
AEs across the treatment groups is greater than or equal to 18.

If `filter = n_overall >= 18` and `var = AESOC` then all rows
corresponding to an SOC with an overall rate less than 18 - including
all AEs within that SOC - will be removed.

If `ard_stack_hierarchical(overall=TRUE)` was run, the overall column is
**not** considered in any filtering except for `XX_overall` statistics,
if specified.

If `ard_stack_hierarchical(over_variables=TRUE)` was run, any overall
statistics are kept regardless of filtering.

Some examples of possible filters:

- `filter = n > 5`: keep AEs where one of the treatment groups observed
  more than 5 AEs

- `filter = n == 2 & p < 0.05`: keep AEs where one of the treatment
  groups observed exactly 2 AEs *and* one of the treatment groups
  observed a proportion less than 5%

- `filter = n_overall >= 4`: keep AEs where there were 4 or more AEs
  observed across the treatment groups

- `filter = mean(n) > 4 | n > 3`: keep AEs where the mean number of AEs
  is 4 or more across the treatment groups *or* one of the treatment
  groups observed more than 3 AEs

- `filter = n_2 > 2`: keep AEs where the `"Xanomeline High Dose"`
  treatment group (second `by` variable level) observed more than 2 AEs

## See also

[`sort_ard_hierarchical()`](https://insightsengineering.github.io/cards/reference/sort_ard_hierarchical.md)

## Examples

``` r
# create a base AE ARD
ard <- ard_stack_hierarchical(
  ADAE,
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  denominator = ADSL,
  id = USUBJID,
  overall = TRUE
)

# Example 1 ----------------------------------
# Keep AEs from TRTA groups where more than 3 AEs are observed across the group
filter_ard_hierarchical(ard, sum(n) > 3)
#> {cards} data frame: 477 x 13
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
#> ℹ 467 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

# Example 2 ----------------------------------
# Keep AEs where at least one level in the TRTA group has more than 3 AEs observed
filter_ard_hierarchical(ard, n > 3)
#> {cards} data frame: 306 x 13
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
#> ℹ 296 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

# Example 3 ----------------------------------
# Keep AEs that have an overall prevalence of greater than 5%
filter_ard_hierarchical(ard, sum(n) / sum(N) > 0.05)
#> {cards} data frame: 198 x 13
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
#> ℹ 188 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

# Example 4 ----------------------------------
# Keep AEs that have a difference in prevalence of greater than 3% between reference group with
# `TRTA = "Xanomeline High Dose"` and comparison group with `TRTA = "Xanomeline Low Dose"`
filter_ard_hierarchical(ard, abs(p_2 - p_3) > 0.03)
#> When applying filters on specific levels of `by` variable "TRTA" xx_1 =
#> "Placebo", xx_2 = "Xanomeline High Dose", and xx_3 = "Xanomeline Low Dose".
#> {cards} data frame: 162 x 13
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
#> ℹ 152 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

# Example 5 ----------------------------------
# Keep AEs from SOCs that have an overall prevalence of greater than 20%
filter_ard_hierarchical(ard, p_overall > 0.20, var = AESOC)
#> {cards} data frame: 882 x 13
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
#> 10   TRTA      Placebo   <NA>                 AESOC      GASTROIN…         n
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
#> 10          n    17
#> ℹ 872 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

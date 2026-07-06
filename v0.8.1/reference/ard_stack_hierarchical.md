# Stacked Hierarchical ARD Statistics

Use these functions to calculate multiple summaries of nested or
hierarchical data in a single call.

- `ard_stack_hierarchical()`: Calculates *rates* of events (e.g. adverse
  events) utilizing the `denominator` and `id` arguments to identify the
  rows in `data` to include in each rate calculation.

- `ard_stack_hierarchical_count()`: Calculates *counts* of events
  utilizing all rows for each tabulation.

## Usage

``` r
ard_stack_hierarchical(
  data,
  variables,
  by = dplyr::group_vars(data),
  id,
  denominator,
  include = everything(),
  statistic = everything() ~ c("n", "N", "p"),
  overall = FALSE,
  over_variables = FALSE,
  attributes = FALSE,
  total_n = FALSE,
  shuffle = FALSE,
  by_stats = TRUE
)

ard_stack_hierarchical_count(
  data,
  variables,
  by = dplyr::group_vars(data),
  denominator = NULL,
  include = everything(),
  overall = FALSE,
  over_variables = FALSE,
  attributes = FALSE,
  total_n = FALSE,
  shuffle = FALSE,
  by_stats = TRUE
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- variables:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  Specifies the nested/hierarchical structure of the data. The variables
  that are specified here and in the `include` argument will have
  summary statistics calculated.

- by:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  variables to perform tabulations by. All combinations of the variables
  specified here appear in results. Default is
  `dplyr::group_vars(data)`.

- id:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  argument used to subset `data` to identify rows in `data` to calculate
  event rates in `ard_stack_hierarchical()`. See details below.

- denominator:

  (`data.frame`, `integer`)\
  used to define the denominator and enhance the output. The argument is
  required for `ard_stack_hierarchical()` and optional for
  `ard_stack_hierarchical_count()`.

  - the univariate tabulations of the `by` variables are calculated with
    `denominator`, when a data frame is passed, e.g. tabulation of the
    treatment assignment counts that may appear in the header of a
    table.

  - the `denominator` argument must be specified when `id` is used to
    calculate the event rates.

  - if `total_n=TRUE`, the `denominator` argument is used to return the
    total N

- include:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  Specify the subset a columns indicated in the `variables` argument for
  which summary statistics will be returned. Default is
  [`everything()`](https://tidyselect.r-lib.org/reference/everything.html).

- statistic:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element one or more of `c("n", "N", "p", "n_cum", "p_cum")` (on the
  RHS of a formula).

- overall:

  (scalar `logical`)\
  logical indicating whether overall statistics should be calculated
  (i.e. repeat the operations with `by=NULL` in *most cases*, see below
  for details). Default is `FALSE`.

- over_variables:

  (scalar `logical`)\
  logical indicating whether summary statistics should be calculated
  over or across the columns listed in the `variables` argument. Default
  is `FALSE`.

- attributes:

  (scalar `logical`)\
  logical indicating whether to include the results of
  [`ard_attributes()`](https://insightsengineering.github.io/cards/reference/ard_attributes.md)
  for all variables represented in the ARD. Default is `FALSE`.

- total_n:

  (scalar `logical`)\
  logical indicating whether to include of `ard_total_n(denominator)` in
  the returned ARD.

- shuffle:

  **\[deprecated\]** support for `.shuffle = TRUE` has been removed.

- by_stats:

  (`logical`)\
  logical indicating whether to include overall stats of the `by`
  variables in the returned ARD.

## Value

an ARD data frame of class 'card'

## Subsetting Data for Rate Calculations

To calculate event rates, the `ard_stack_hierarchical()` function
identifies rows to include in the calculation. First, the primary data
frame is sorted by the columns identified in the `id`, `by`, and
`variables` arguments.

As the function cycles over the variables specified in the `variables`
argument, the data frame is grouped by `id`,
`intersect(by, names(denominator))`, and `variables` utilizing the last
row within each of the groups.

For example, if the call is
`ard_stack_hierarchical(data = ADAE, variables = c(AESOC, AEDECOD), id = USUBJID)`,
then we'd first subset ADAE to be one row within the grouping
`c(USUBJID, AESOC, AEDECOD)` to calculate the event rates in
`'AEDECOD'`. We'd then repeat and subset ADAE to be one row within the
grouping `c(USUBJID, AESOC)` to calculate the event rates in `'AESOC'`.

## Overall Argument

When we set `overall=TRUE`, we wish to re-run our calculations removing
the stratifying columns. For example, if we ran the code below, we
results would include results with the code chunk being re-run with
`by=NULL`.

    ard_stack_hierarchical(
      data = ADAE,
      variables = c(AESOC, AEDECOD),
      by = TRTA,
      denominator = ADSL,
      id = USUBJID,
      overall = TRUE
    )

But there is another case to be aware of: when the `by` argument
includes columns that are not present in the `denominator`, for example
when tabulating results by AE grade or severity in addition to treatment
assignment. In the example below, we're tabulating results by treatment
assignment and AE severity. By specifying `overall=TRUE`, we will re-run
the to get results with `by = AESEV` and again with `by = NULL`.

    ard_stack_hierarchical(
      data = ADAE,
      variables = c(AESOC, AEDECOD),
      by = c(TRTA, AESEV),
      denominator = ADSL,
      id = USUBJID,
      overall = TRUE
    )

## Examples

``` r
ard_stack_hierarchical(
  ADAE,
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  denominator = ADSL,
  id = USUBJID
)
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
)
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

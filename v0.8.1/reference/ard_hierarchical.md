# Hierarchical ARD Statistics

*Functions `ard_hierarchical()` and `ard_hierarchical_count()` are
primarily helper functions for
[`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
and
[`ard_stack_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md),
meaning that it will be rare a user needs to call
`ard_hierarchical()`/`ard_hierarchical_count()` directly.*

Performs hierarchical or nested tabulations, e.g. tabulates AE terms
nested within AE system organ class.

- `ard_hierarchical()` includes summaries for the last variable listed
  in the `variables` argument, nested within the other variables
  included.

- `ard_hierarchical_count()` includes summaries for *all* variables
  listed in the `variables` argument each summary nested within the
  preceding variables, e.g. `variables=c(AESOC, AEDECOD)` summarizes
  `AEDECOD` nested in `AESOC`, and also summarizes the counts of
  `AESOC`.

## Usage

``` r
ard_hierarchical(data, ...)

ard_hierarchical_count(data, ...)

# S3 method for class 'data.frame'
ard_hierarchical(
  data,
  variables,
  by = dplyr::group_vars(data),
  statistic = everything() ~ c("n", "N", "p"),
  denominator = NULL,
  fmt_fun = NULL,
  stat_label = everything() ~ default_stat_labels(),
  id = NULL,
  fmt_fn = deprecated(),
  ...
)

# S3 method for class 'data.frame'
ard_hierarchical_count(
  data,
  variables,
  by = dplyr::group_vars(data),
  fmt_fun = NULL,
  stat_label = everything() ~ default_stat_labels(),
  fmt_fn = deprecated(),
  ...
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- ...:

  Arguments passed to methods.

- variables:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  variables to perform the nested/hierarchical tabulations within.

- by:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  variables to perform tabulations by. All combinations of the variables
  specified here appear in results. Default is
  `dplyr::group_vars(data)`.

- statistic:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element one or more of `c("n", "N", "p", "n_cum", "p_cum")` (on the
  RHS of a formula).

- denominator:

  (`data.frame`, `integer`)\
  used to define the denominator and enhance the output. The argument is
  required for `ard_hierarchical()` and optional for
  `ard_hierarchical_count()`.

  - the univariate tabulations of the `by` variables are calculated with
    `denominator`, when a data frame is passed, e.g. tabulation of the
    treatment assignment counts that may appear in the header of a
    table.

  - the `denominator` argument must be specified when `id` is used to
    calculate the event rates.

- fmt_fun:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element is a named list of functions (or the RHS of a formula), e.g.
  `list(mpg = list(mean = \(x) round(x, digits = 2) |> as.character()))`.

- stat_label:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element is either a named list or a list of formulas defining the
  statistic labels, e.g. `everything() ~ list(n = "n", p = "pct")` or
  `everything() ~ list(n ~ "n", p ~ "pct")`.

- id:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  an optional argument used to assert there are no duplicates within the
  `c(id, variables)` columns.

- fmt_fn:

  **\[deprecated\]**

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_hierarchical(
  data = ADAE |>
    dplyr::slice_tail(n = 1L, by = c(USUBJID, TRTA, AESOC, AEDECOD)),
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  id = USUBJID,
  denominator = ADSL
)
#> {cards} data frame: 2178 x 13
#>    group1 group1_level group2 group2_level variable variable_level stat_name
#> 1    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n
#> 2    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         N
#> 3    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         p
#> 4    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n
#> 5    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         N
#> 6    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         p
#> 7    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL H…         n
#> 8    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL H…         N
#> 9    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL H…         p
#> 10   TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIOVEN…         n
#>    stat_label  stat
#> 1           n     1
#> 2           N    86
#> 3           % 0.012
#> 4           n     0
#> 5           N    86
#> 6           %     0
#> 7           n     1
#> 8           N    86
#> 9           % 0.012
#> 10          n     1
#> ℹ 2168 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error

ard_hierarchical_count(
  data = ADAE,
  variables = c(AESOC, AEDECOD),
  by = TRTA
)
#> {cards} data frame: 726 x 13
#>    group1 group1_level group2 group2_level variable variable_level stat_name
#> 1    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n
#> 2    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n
#> 3    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL H…         n
#> 4    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIOVEN…         n
#> 5    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIOVEN…         n
#> 6    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      BRADYCAR…         n
#> 7    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      BUNDLE B…         n
#> 8    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      BUNDLE B…         n
#> 9    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      CARDIAC …         n
#> 10   TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      CARDIAC …         n
#>    stat_label stat
#> 1           n    1
#> 2           n    0
#> 3           n    2
#> 4           n    1
#> 5           n    2
#> 6           n    4
#> 7           n    1
#> 8           n    2
#> 9           n    0
#> 10          n    1
#> ℹ 716 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

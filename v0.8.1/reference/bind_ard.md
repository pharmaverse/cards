# Bind ARDs

Wrapper for
[`dplyr::bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
with additional checks for duplicated statistics.

## Usage

``` r
bind_ard(
  ...,
  .distinct = TRUE,
  .update = FALSE,
  .order = FALSE,
  .quiet = FALSE
)
```

## Arguments

- ...:

  ([`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html))\
  ARDs to combine. Each argument can either be an ARD, or a list of
  ARDs. Columns are matched by name, and any missing columns will be
  filled with `NA`.

- .distinct:

  (`logical`)\
  logical indicating whether to remove non-distinct values from the ARD.
  Duplicates are checked across grouping variables, primary variables,
  context (if present), the **statistic name and the statistic value**.
  Default is `TRUE`. If a statistic name and value is repeated and
  `.distinct=TRUE`, the more recently added statistics will be retained,
  and the other(s) omitted.

- .update:

  (`logical`)\
  logical indicating whether to update ARD and remove duplicated named
  statistics. Duplicates are checked across grouping variables, primary
  variables, and the **statistic name**. Default is `FALSE`. If a
  statistic name is repeated and `.update=TRUE`, the more recently added
  statistics will be retained, and the other(s) omitted.

- .order:

  (`logical`)\
  logical indicating whether to order the rows of the stacked ARDs,
  allowing statistics that share common group and variable values to
  appear in consecutive rows. Default is `FALSE`. Ordering will be based
  on the order of the group/variable values prior to stacking.

- .quiet:

  (`logical`)\
  logical indicating whether to suppress any messaging. Default is
  `FALSE`

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

bind_ard(ard, ard, .update = TRUE)
#> ℹ 27 rows with duplicated statistic values have been removed.
#> • See cards::bind_ard(.distinct) (`?cards::bind_ard()`) for details.
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

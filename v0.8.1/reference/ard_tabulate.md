# Tabulate ARD

Compute Analysis Results Data (ARD) for categorical summary statistics.

## Usage

``` r
ard_tabulate(data, ...)

# S3 method for class 'data.frame'
ard_tabulate(
  data,
  variables,
  by = dplyr::group_vars(data),
  strata = NULL,
  statistic = everything() ~ c("n", "p", "N"),
  denominator = "column",
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
  columns to include in summaries. Default is
  [`everything()`](https://tidyselect.r-lib.org/reference/everything.html).

- by, strata:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  columns to use for grouping or stratifying the table output. Arguments
  are similar, but with an important distinction:

  `by`: results are tabulated by **all combinations** of the columns
  specified, including unobserved combinations and unobserved factor
  levels.

  `strata`: results are tabulated by **all *observed* combinations** of
  the columns specified.

  Arguments may be used in conjunction with one another.

- statistic:

  ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
  a named list, a list of formulas, or a single formula where the list
  element one or more of `c("n", "N", "p", "n_cum", "p_cum")` (on the
  RHS of a formula).

- denominator:

  (`string`, `data.frame`, `integer`)\
  Specify this argument to change the denominator, e.g. the `"N"`
  statistic. Default is `'column'`. See below for details.

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

- fmt_fn:

  **\[deprecated\]**

## Value

an ARD data frame of class 'card'

## Denominators

By default, the `ard_tabulate()` function returns the statistics `"n"`,
`"N"`, and `"p"`, where little `"n"` are the counts for the variable
levels, and big `"N"` is the number of non-missing observations. The
calculation for the proportion is `p = n/N`.

However, it is sometimes necessary to provide a different `"N"` to use
as the denominator in this calculation. For example, in a calculation of
the rates of various observed adverse events, you may need to update the
denominator to the number of enrolled subjects.

In such cases, use the `denominator` argument to specify a new
definition of `"N"`, and subsequently `"p"`. The argument expects one of
the following inputs:

- a string: one of `"column"`, `"row"`, or `"cell"`.

  - `"column"`, the default, returns percentages where the sum is equal
    to one within the variable after the data frame has been subset with
    `by`/`strata`.

  - `"row"` gives 'row' percentages where `by`/`strata` columns are the
    'top' of a cross table, and the variables are the rows. This is
    well-defined for a single `by` or `strata` variable, and care must
    be taken when there are more to ensure the the results are as you
    expect.

  - `"cell"` gives percentages where the denominator is the number of
    non-missing rows in the source data frame.

- a data frame. Any columns in the data frame that overlap with the
  `by`/`strata` columns will be used to calculate the new `"N"`.

- an integer. This single integer will be used as the new `"N"`

- a structured data frame. The data frame will include columns from
  `by`/`strata`. The last column must be named `"...ard_N..."`. The
  integers in this column will be used as the updated `"N"` in the
  calculations.

When the `p` statistic is returned, the proportion is returned—bounded
by `[0, 1]`. The default function to format the statistic scales the
proportion by 100 and the percentage is returned which matches the
default statistic label of `'%'`. To get the formatted values, pass the
ARD to
[`apply_fmt_fun()`](https://insightsengineering.github.io/cards/reference/apply_fmt_fun.md).

## Examples

``` r
ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
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

ADSL |>
  dplyr::group_by(ARM) |>
  ard_tabulate(
    variables = "AGEGR1",
    statistic = everything() ~ "n"
  )
#> {cards} data frame: 9 x 11
#>   group1 group1_level variable variable_level stat_name stat_label stat
#> 1    ARM      Placebo   AGEGR1          65-80         n          n   42
#> 2    ARM      Placebo   AGEGR1            <65         n          n   14
#> 3    ARM      Placebo   AGEGR1            >80         n          n   30
#> 4    ARM    Xanomeli…   AGEGR1          65-80         n          n   55
#> 5    ARM    Xanomeli…   AGEGR1            <65         n          n   11
#> 6    ARM    Xanomeli…   AGEGR1            >80         n          n   18
#> 7    ARM    Xanomeli…   AGEGR1          65-80         n          n   47
#> 8    ARM    Xanomeli…   AGEGR1            <65         n          n    8
#> 9    ARM    Xanomeli…   AGEGR1            >80         n          n   29
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

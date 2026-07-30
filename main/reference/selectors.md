# ARD Selectors

These selection helpers match variables according to a given pattern.

- `all_ard_groups()`: Function selects grouping columns, e.g. columns
  named `"group##"` or `"group##_level"`.

- `all_ard_variables()`: Function selects variables columns, e.g.
  columns named `"variable"` or `"variable_level"`.

- `all_ard_group_n()`: Function selects `n` grouping columns.

- `all_missing_columns()`: Function selects columns that are all `NA` or
  empty.

## Usage

``` r
all_ard_groups(types = c("names", "levels"))

all_ard_variables(types = c("names", "levels"))

all_ard_group_n(n, types = c("names", "levels"))

all_missing_columns()
```

## Arguments

- types:

  (`character`)\
  type(s) of columns to select. `"names"` selects the columns variable
  name columns, and `"levels"` selects the level columns. Default is
  `c("names", "levels")`.

- n:

  (`integer`)\
  integer(s) indicating which grouping columns to select.

## Value

tidyselect output

## Examples

``` r
ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

ard |> dplyr::select(all_ard_groups())
#> {cards} data frame: 27 x 2
#>    group1 group1_level
#> 1     ARM      Placebo
#> 2     ARM      Placebo
#> 3     ARM      Placebo
#> 4     ARM      Placebo
#> 5     ARM      Placebo
#> 6     ARM      Placebo
#> 7     ARM      Placebo
#> 8     ARM      Placebo
#> 9     ARM      Placebo
#> 10    ARM    Xanomeli…
#> ℹ 17 more rows
#> ℹ Use `print(n = ...)` to see more rows
ard |> dplyr::select(all_ard_variables())
#> {cards} data frame: 27 x 2
#>    variable variable_level
#> 1    AGEGR1          65-80
#> 2    AGEGR1          65-80
#> 3    AGEGR1          65-80
#> 4    AGEGR1            <65
#> 5    AGEGR1            <65
#> 6    AGEGR1            <65
#> 7    AGEGR1            >80
#> 8    AGEGR1            >80
#> 9    AGEGR1            >80
#> 10   AGEGR1          65-80
#> ℹ 17 more rows
#> ℹ Use `print(n = ...)` to see more rows
```

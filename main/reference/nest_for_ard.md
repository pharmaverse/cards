# ARD Nesting

This function is similar to
[`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html),
except that it retains rows for unobserved combinations (and unobserved
factor levels) of by variables, and unobserved combinations of
stratifying variables.

The levels are wrapped in lists so they can be stacked with other types
of different classes.

## Usage

``` r
nest_for_ard(
  data,
  by = NULL,
  strata = NULL,
  key = "data",
  rename_columns = TRUE,
  list_columns = TRUE,
  include_data = TRUE,
  include_by_and_strata = FALSE
)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- by, strata:

  (`character`)\
  columns to nest by/stratify by. Arguments are similar, but with an
  important distinction:

  `by`: data frame is nested by **all combinations** of the columns
  specified, including unobserved combinations and unobserved factor
  levels.

  `strata`: data frame is nested by **all *observed* combinations** of
  the columns specified.

  Arguments may be used in conjunction with one another.

- key:

  (`string`)\
  the name of the new column with the nested data frame. Default is
  `"data"`.

- rename_columns:

  (`logical`)\
  logical indicating whether to rename the `by` and `strata` variables.
  Default is `TRUE`.

- list_columns:

  (`logical`)\
  logical indicating whether to put levels of `by` and `strata` columns
  in a list. Default is `TRUE`.

- include_data:

  (scalar `logical`)\
  logical indicating whether to include the data subsets as a
  list-column. Default is `TRUE`.

- include_by_and_strata:

  (`logical`)\
  When `TRUE`, the `by` and `strata` variables are included in the
  nested data frames.

## Value

a nested tibble

## Examples

``` r
nest_for_ard(
  data =
    ADAE |>
      dplyr::left_join(ADSL[c("USUBJID", "ARM")], by = "USUBJID") |>
      dplyr::filter(AOCCSFL %in% "Y"),
  by = "ARM",
  strata = "AESOC"
)
#> # A tibble: 69 × 5
#>    group1 group1_level group2 group2_level data              
#>    <chr>  <list>       <chr>  <list>       <list>            
#>  1 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [12 × 55]>
#>  2 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [15 × 55]>
#>  3 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [13 × 55]>
#>  4 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [0 × 55]> 
#>  5 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [2 × 55]> 
#>  6 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [1 × 55]> 
#>  7 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [1 × 55]> 
#>  8 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [1 × 55]> 
#>  9 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [2 × 55]> 
#> 10 ARM    <chr [1]>    AESOC  <chr [1]>    <tibble [2 × 55]> 
#> # ℹ 59 more rows
```

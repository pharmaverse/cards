# Rename ARD Columns

If `variable` is provided, adds the standard `variable` column to `x`.
If `by`/`strata` are provided, adds the standard `group##` column(s) to
`x` and renames the provided columns to `group##_level` in `x`, where
`##` is determined by the column's position in `c(by, strata)`.

## Usage

``` r
.nesting_rename_ard_columns(x, variable = NULL, by = NULL, strata = NULL)
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

- variable:

  (`character`)\
  name of `variable` column in `x`. Default is `NULL`.

- by:

  (`character`)\
  character vector of names of `by` columns in `x`. Default is `NULL`.

- strata:

  (`character`)\
  character vector of names of `strata` columns in `x`. Default is
  `NULL`.

## Value

a tibble

## Examples

``` r
ard <- nest_for_ard(
  data =
    ADAE |>
      dplyr::left_join(ADSL[c("USUBJID", "ARM")], by = "USUBJID") |>
      dplyr::filter(AOCCSFL %in% "Y"),
  by = "ARM",
  strata = "AESOC",
  rename_columns = FALSE
)

cards:::.nesting_rename_ard_columns(ard, by = "ARM", strata = "AESOC")
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

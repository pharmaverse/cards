# Updating ARD Objects

## Introduction

ARD (Analysis Results Data) objects are data frames that contain
statistical summaries. Because they are data frames, any value in the
ARD can be updated using standard dplyr or base R functions.

### Working with List Columns

ARD objects contain **list columns** such as `stat`, `fmt_fun`,
`stat_label`, and others. List columns are columns where each cell can
hold any R object—a number, a function, a vector, or even another data
frame. If you’re unfamiliar with list columns, they may look unusual
when printed:

``` r

ard <- ard_summary(ADSL, variables = AGE) |>
  select(variable, stat_name, stat, fmt_fun) |>
  head(3)
print(ard)
#> {cards} data frame: 3 x 4
#>   variable stat_name   stat fmt_fun
#> 1      AGE         N    254       0
#> 2      AGE      mean 75.087       1
#> 3      AGE        sd  8.246       1
```

While list columns can be updated just like any other column in a data
frame, the syntax can be less intuitive. For example, to update the
`fmt_fun` column for specific statistics, you might write:

``` r

ard |>
  mutate(
    fmt_fun = ifelse(stat_name %in% c("mean", "sd"), list(2L), fmt_fun)
  )
#> {cards} data frame: 3 x 4
#>   variable stat_name   stat fmt_fun
#> 1      AGE         N    254       0
#> 2      AGE      mean 75.087       2
#> 3      AGE        sd  8.246       2
```

This requires wrapping values in
[`list()`](https://rdrr.io/r/base/list.html) and can become cumbersome
for more complex updates.

### Helper Functions

To simplify working with these list columns, {cards} provides helper
functions:

- **[`update_ard_fmt_fun()`](https://insightsengineering.github.io/cards/reference/update_ard.md)**:
  Update formatting functions for specific statistics
- **[`update_ard_stat_label()`](https://insightsengineering.github.io/cards/reference/update_ard.md)**:
  Update statistic labels

These functions handle the list column mechanics for you, making it
easier to customize your ARD objects.

## Basic Usage

### Updating Formatting Functions

By default, statistics may use simple formatting. You can update the
formatting function for specific statistics:

``` r

# Create a basic ARD
ard <- ard_summary(ADSL, variables = AGE)

# Update formatting for mean and sd to show more decimal places
ard_updated <- ard |>
  update_ard_fmt_fun(
    stat_names = c("mean", "sd"),
    fmt_fun = 2L # 2 decimal places
  ) |>
  apply_fmt_fun()

# View results
ard_updated |>
  select(stat_name, stat, stat_fmt)
#> {cards} data frame: 8 x 3
#>   stat_name   stat stat_fmt
#> 1         N    254      254
#> 2      mean 75.087    75.09
#> 3        sd  8.246     8.25
#> 4    median     77     77.0
#> 5       p25     70     70.0
#> 6       p75     81     81.0
#> 7       min     51     51.0
#> 8       max     89     89.0
```

### Updating Statistic Labels

Combine formatting updates with custom labels:

``` r

ard_summary(ADSL, variables = AGE) |>
  update_ard_fmt_fun(stat_names = c("mean", "sd"), fmt_fun = 1L) |>
  update_ard_stat_label(
    stat_names = c("mean", "sd"),
    stat_label = "Mean (SD)"
  ) |>
  apply_fmt_fun()
#> {cards} data frame: 8 x 9
#>   variable context stat_name stat_label   stat stat_fmt
#> 1      AGE summary         N          N    254      254
#> 2      AGE summary      mean  Mean (SD) 75.087     75.1
#> 3      AGE summary        sd  Mean (SD)  8.246      8.2
#> 4      AGE summary    median     Median     77     77.0
#> 5      AGE summary       p25         Q1     70     70.0
#> 6      AGE summary       p75         Q3     81     81.0
#> 7      AGE summary       min        Min     51     51.0
#> 8      AGE summary       max        Max     89     89.0
#> ℹ 3 more variables: fmt_fun, warning, error
```

## Selective Updates

### Filtering by Variable

Update formatting for specific variables only:

``` r

ard_summary(ADSL, variables = c(AGE, BMIBL)) |>
  update_ard_fmt_fun(
    variables = AGE, # Only update AGE
    stat_names = "mean",
    fmt_fun = 3L
  ) |>
  apply_fmt_fun()
#> {cards} data frame: 16 x 9
#>    variable context stat_name stat_label   stat stat_fmt
#> 1       AGE summary         N          N    254      254
#> 2       AGE summary      mean       Mean 75.087   75.087
#> 3       AGE summary        sd         SD  8.246      8.2
#> 4       AGE summary    median     Median     77     77.0
#> 5       AGE summary       p25         Q1     70     70.0
#> 6       AGE summary       p75         Q3     81     81.0
#> 7       AGE summary       min        Min     51     51.0
#> 8       AGE summary       max        Max     89     89.0
#> 9     BMIBL summary         N          N    253      253
#> 10    BMIBL summary      mean       Mean 24.672     24.7
#> 11    BMIBL summary        sd         SD  4.092      4.1
#> 12    BMIBL summary    median     Median   24.2     24.2
#> 13    BMIBL summary       p25         Q1   21.9     21.9
#> 14    BMIBL summary       p75         Q3   27.3     27.3
#> 15    BMIBL summary       min        Min   13.7     13.7
#> 16    BMIBL summary       max        Max   40.1     40.1
#> ℹ 3 more variables: fmt_fun, warning, error
```

### Filtering by Group

When working with stratified analyses, use the `filter` argument to
target specific groups:

``` r

# Update formatting only for the Placebo arm
ard_summary(
  ADSL,
  by = ARM,
  variables = AGE,
  statistic = ~ continuous_summary_fns(c("N", "mean"))
) |>
  update_ard_fmt_fun(
    stat_names = "mean",
    fmt_fun = 3L,
    filter = group1_level == "Placebo"
  ) |>
  apply_fmt_fun()
#> {cards} data frame: 6 x 11
#>   group1 group1_level variable stat_name stat_label   stat stat_fmt
#> 1    ARM      Placebo      AGE         N          N     86       86
#> 2    ARM      Placebo      AGE      mean       Mean 75.209   75.209
#> 3    ARM    Xanomeli…      AGE         N          N     84       84
#> 4    ARM    Xanomeli…      AGE      mean       Mean 74.381     74.4
#> 5    ARM    Xanomeli…      AGE         N          N     84       84
#> 6    ARM    Xanomeli…      AGE      mean       Mean 75.667     75.7
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

## Custom Formatting Functions

Beyond integer aliases, you can pass custom functions:

``` r

# Custom formatter that adds parentheses
format_with_parens <- function(x) {
  paste0("(", format(round(x, 1), nsmall = 1), ")")
}

ard_summary(ADSL, variables = AGE) |>
  update_ard_fmt_fun(
    stat_names = "sd",
    fmt_fun = format_with_parens
  ) |>
  apply_fmt_fun()
#> {cards} data frame: 8 x 9
#>   variable context stat_name stat_label   stat stat_fmt
#> 1      AGE summary         N          N    254      254
#> 2      AGE summary      mean       Mean 75.087     75.1
#> 3      AGE summary        sd         SD  8.246    (8.2)
#> 4      AGE summary    median     Median     77     77.0
#> 5      AGE summary       p25         Q1     70     70.0
#> 6      AGE summary       p75         Q3     81     81.0
#> 7      AGE summary       min        Min     51     51.0
#> 8      AGE summary       max        Max     89     89.0
#> ℹ 3 more variables: fmt_fun, warning, error
```

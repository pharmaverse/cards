# As card function

Add attributes to a function that specify the expected results. It is
used when
[`ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md)
or
[`ard_mvsummary()`](https://insightsengineering.github.io/cards/reference/ard_mvsummary.md)
errors and constructs an ARD with the correct structure when the results
cannot be calculated.

## Usage

``` r
as_cards_fn(f, stat_names)

is_cards_fn(f)

get_cards_fn_stat_names(f)
```

## Arguments

- f:

  (`function`)\
  a function

- stat_names:

  (`character`)\
  a character vector of the expected statistic names returned by
  function `f`

## Value

an ARD data frame of class 'card'

## Examples

``` r
# When there is no error, everything works as if we hadn't used `as_card_fn()`
ttest_works <-
  as_cards_fn(
    \(x) t.test(x)[c("statistic", "p.value")],
    stat_names = c("statistic", "p.value")
  )
ard_summary(
  mtcars,
  variables = mpg,
  statistic = ~ list(ttest = ttest_works)
)
#> {cards} data frame: 2 x 8
#>   variable context stat_name stat_label   stat fmt_fun
#> 1      mpg summary statistic  statistic 18.857       1
#> 2      mpg summary   p.value    p.value      0       1
#> ℹ 2 more variables: warning, error

# When there is an error and we use `as_card_fn()`,
#   we will see the same structure as when there is no error
ttest_error <-
  as_cards_fn(
    \(x) {
      t.test(x)[c("statistic", "p.value")]
      stop("Intentional Error")
    },
    stat_names = c("statistic", "p.value")
  )
ard_summary(
  mtcars,
  variables = mpg,
  statistic = ~ list(ttest = ttest_error)
)
#> {cards} data frame: 2 x 8
#>   variable context stat_name stat_label stat     error
#> 1      mpg summary statistic  statistic      Intentio…
#> 2      mpg summary   p.value    p.value      Intentio…
#> ℹ 2 more variables: fmt_fun, warning

# if we don't use `as_card_fn()` and there is an error,
#   the returned result is only one row
ard_summary(
  mtcars,
  variables = mpg,
  statistic = ~ list(ttest = \(x) {
    t.test(x)[c("statistic", "p.value")]
    stop("Intentional Error")
  })
)
#> {cards} data frame: 1 x 8
#>   variable context stat_name stat_label stat     error
#> 1      mpg summary     ttest      ttest      Intentio…
#> ℹ 2 more variables: fmt_fun, warning
```

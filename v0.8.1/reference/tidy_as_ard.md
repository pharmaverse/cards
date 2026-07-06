# Build ARD from Tidier

**\[questioning\]**\
*Function is questioning because we think a better solution may be
[`ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md) +
[`ard_formals()`](https://insightsengineering.github.io/cards/reference/ard_formals.md).*

Function converts a model's one-row tidy data frame into an ARD
structure. The tidied data frame must have been constructed with
[`eval_capture_conditions()`](https://insightsengineering.github.io/cards/reference/eval_capture_conditions.md).

This function is primarily for developers and few consistency checks
have been included.

## Usage

``` r
tidy_as_ard(
  lst_tidy,
  tidy_result_names,
  fun_args_to_record = character(0L),
  formals = list(),
  passed_args = list(),
  lst_ard_columns
)
```

## Arguments

- lst_tidy:

  (named `list`)\
  list of tidied results constructed with
  [`eval_capture_conditions()`](https://insightsengineering.github.io/cards/reference/eval_capture_conditions.md),
  e.g.
  `eval_capture_conditions(t.test(mtcars$mpg ~ mtcars$am) |> broom::tidy())`.

- tidy_result_names:

  (`character`)\
  character vector of column names expected by the tidier method. This
  is used to construct blank results in the event of an error.

- fun_args_to_record:

  (`character`)\
  character vector of function argument names that are added to the ARD.

- formals:

  (`pairlist`)\
  the results from [`formals()`](https://rdrr.io/r/base/formals.html),
  e.g. `formals(fisher.test)`. This is used to get the default argument
  values from unspecified arguments.

- passed_args:

  (named `list`)\
  named list of additional arguments passed to the modeling function.

- lst_ard_columns:

  (named `list`)\
  named list of values that will be added to the ARD data frame.

## Value

an ARD data frame of class 'card'

## Examples

``` r
# example how one may create a fisher.test() ARD function
my_ard_fishertest <- function(data, by, variable, ...) {
  # perform fisher test and format results -----------------------------------
  lst_tidy_fisher <-
    eval_capture_conditions(
      # this manipulation is similar to `fisher.test(...) |> broom::tidy()`
      stats::fisher.test(x = data[[variable]], y = data[[by]], ...)[c("p.value", "method")] |>
        as.data.frame()
    )

  # build ARD ------------------------------------------------------------------
  tidy_as_ard(
    lst_tidy = lst_tidy_fisher,
    tidy_result_names = c("p.value", "method"),
    fun_args_to_record =
      c(
        "workspace", "hybrid", "hybridPars", "control", "or",
        "conf.int", "conf.level", "simulate.p.value", "B"
      ),
    formals = formals(stats::fisher.test),
    passed_args = dots_list(...),
    lst_ard_columns = list(group1 = by, variable = variable, context = "fishertest")
  )
}

my_ard_fishertest(mtcars, by = "am", variable = "vs")
#> {cards} data frame: 2 x 8
#>   group1 variable   context stat_name      stat fmt_fun
#> 1     am       vs fisherte…   p.value     0.473       1
#> 2     am       vs fisherte…    method Fisher's…    NULL
#> ℹ 2 more variables: warning, error
```

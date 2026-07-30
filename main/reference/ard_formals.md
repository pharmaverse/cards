# Argument Values ARD

Place default and passed argument values to a function into an ARD
structure.

## Usage

``` r
ard_formals(fun, arg_names, passed_args = list(), envir = parent.frame())
```

## Arguments

- fun:

  (`function`)\
  a [function](https://rdrr.io/r/base/function.html) passed to
  `formals(fun)`

- arg_names:

  (`character`)\
  character vector of argument names to return

- passed_args:

  (named `list`)\
  a named list of user-passed arguments. Default is
  [`list()`](https://rdrr.io/r/base/list.html), which returns all
  default values from a function

- envir:

  (`environment`)\
  an environment passed to `formals(envir)`

## Value

an partial ARD data frame of class 'card'

## Examples

``` r
# Example 1 ----------------------------------
# add the `mcnemar.test(correct)` argument to an ARD structure
ard_formals(fun = mcnemar.test, arg_names = "correct")
#> {cards} data frame: 1 x 3
#>   stat_name stat_label stat
#> 1   correct    correct TRUE

# Example 2 ----------------------------------
# S3 Methods need special handling to access the underlying method
ard_formals(
  fun = asNamespace("stats")[["t.test.default"]],
  arg_names = c("mu", "paired", "var.equal", "conf.level"),
  passed_args = list(conf.level = 0.90)
)
#> {cards} data frame: 4 x 3
#>    stat_name stat_label  stat
#> 1         mu         mu     0
#> 2     paired     paired FALSE
#> 3  var.equal  var.equal FALSE
#> 4 conf.level  conf.lev…   0.9
```

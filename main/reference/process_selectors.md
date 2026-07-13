# Process tidyselectors

Functions process tidyselect arguments passed to functions in the cards
package. The processed values are saved to the calling environment, by
default.

- `process_selectors()`: the arguments will be processed with tidyselect
  and converted to a vector of character column names.

- `process_formula_selectors()`: for arguments that expect named lists
  or lists of formulas (where the LHS of the formula is a tidyselector).
  This function processes these inputs and returns a named list. If a
  name is repeated, the last entry is kept.

- `fill_formula_selectors()`: when users override the default argument
  values, it can be important to ensure that each column from a data
  frame is assigned a value. This function checks that each column in
  `data` has an assigned value, and if not, fills the value in with the
  default value passed here.

- `compute_formula_selector()`: used in `process_formula_selectors()` to
  evaluate a single argument.

- `check_list_elements()`: used to check the class/type/values of the
  list elements, primarily those processed with
  `process_formula_selectors()`.

- `cards_select()`: wraps `tidyselect::eval_select() |> names()`, and
  returns better contextual messaging when errors occur.

## Usage

``` r
process_selectors(data, ...)

process_formula_selectors(data, ...)

fill_formula_selectors(data, ...)

# S3 method for class 'data.frame'
process_selectors(data, ..., env = caller_env())

# S3 method for class 'data.frame'
process_formula_selectors(
  data,
  ...,
  env = caller_env(),
  include_env = FALSE,
  allow_empty = TRUE
)

# S3 method for class 'data.frame'
fill_formula_selectors(data, ..., env = caller_env())

compute_formula_selector(
  data,
  x,
  arg_name = caller_arg(x),
  env = caller_env(),
  strict = TRUE,
  include_env = FALSE,
  allow_empty = TRUE
)

check_list_elements(
  x,
  predicate,
  error_msg = NULL,
  arg_name = rlang::caller_arg(x)
)

cards_select(expr, data, ..., arg_name = NULL)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- ...:

  ([`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html))\
  named arguments where the value of the argument is processed with
  tidyselect.

  - `process_selectors()`: the values are tidyselect-compatible
    selectors

  - `process_formula_selectors()`: the values are named lists, list of
    formulas a combination of both, or a single formula. Users may pass
    `~value` as a shortcut for `everything() ~ value`.

  - `check_list_elements()`: named arguments where the name matches an
    existing list in the `env` environment, and the value is a predicate
    function to test each element of the list, e.g. each element must be
    a string or a function.

- env:

  (`environment`)\
  env to save the results to. Default is the calling environment.

- include_env:

  (`logical`)\
  whether to include the environment from the formula object in the
  returned named list. Default is `FALSE`

- allow_empty:

  (`logical`)\
  Logical indicating whether empty result is acceptable while process
  formula-list selectors. Default is `TRUE`.

- x:

  - `compute_formula_selector()`:
    ([`formula-list-selector`](https://insightsengineering.github.io/cards/reference/syntax.md))\
    a named list, list of formulas, or a single formula that will be
    converted to a named list.

  - `check_list_elements()`: (named `list`)\
    a named list

- arg_name:

  (`string`)\
  the name of the argument being processed. Used in error messaging.
  Default is `caller_arg(x)`.

- strict:

  (`logical`)\
  whether to throw an error if a variable doesn't exist in the reference
  data (passed to
  [`tidyselect::eval_select()`](https://tidyselect.r-lib.org/reference/eval_select.html))

- predicate:

  (`function`)\
  a predicate function that returns `TRUE` or `FALSE`

- error_msg:

  (`character`)\
  a character vector that will be used in error messaging when
  mis-specified arguments are passed. Elements `"{arg_name}"` and
  `"{variable}"` are available using glue syntax for messaging.

- expr:

  (`expression`)\
  Defused R code describing a selection according to the tidyselect
  syntax.

## Value

`process_selectors()`, `fill_formula_selectors()`,
`process_formula_selectors()` and `check_list_elements()` return NULL.
`compute_formula_selector()` returns a named list.

## Examples

``` r
example_env <- rlang::new_environment()

process_selectors(ADSL, variables = starts_with("TRT"), env = example_env)
get(x = "variables", envir = example_env)
#> [1] "TRT01P"  "TRT01PN" "TRT01A"  "TRT01AN" "TRTSDT"  "TRTEDT"  "TRTDUR" 
#> [8] "TRTA"   

fill_formula_selectors(ADSL, env = example_env)

process_formula_selectors(
  ADSL,
  statistic = list(starts_with("TRT") ~ mean, TRTSDT = min),
  env = example_env
)
get(x = "statistic", envir = example_env)
#> $TRT01P
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x563a69c6a348>
#> <environment: namespace:base>
#> 
#> $TRT01PN
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x563a69c6a348>
#> <environment: namespace:base>
#> 
#> $TRT01A
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x563a69c6a348>
#> <environment: namespace:base>
#> 
#> $TRT01AN
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x563a69c6a348>
#> <environment: namespace:base>
#> 
#> $TRTEDT
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x563a69c6a348>
#> <environment: namespace:base>
#> 
#> $TRTDUR
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x563a69c6a348>
#> <environment: namespace:base>
#> 
#> $TRTA
#> function (x, ...) 
#> UseMethod("mean")
#> <bytecode: 0x563a69c6a348>
#> <environment: namespace:base>
#> 
#> $TRTSDT
#> function (..., na.rm = FALSE)  .Primitive("min")
#> 

check_list_elements(
  get(x = "statistic", envir = example_env),
  predicate = function(x) !is.null(x),
  error_msg = c(
    "Error in the argument {.arg {arg_name}} for variable {.val {variable}}.",
    "i" = "Value must be a named list of functions."
  )
)

# process one list
compute_formula_selector(ADSL, x = starts_with("U") ~ 1L)
#> $USUBJID
#> [1] 1
#> 
```

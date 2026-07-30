# Evaluate and Capture Conditions

**`eval_capture_conditions()`**

Evaluates an expression while also capturing error and warning
conditions. Function always returns a named list
`list(result=, warning=, error=)`. If there are no errors or warnings,
those elements will be `NULL`. If there is an error, the result element
will be `NULL`.

Messages are neither saved nor printed to the console.

Evaluation is done via
[`rlang::eval_tidy()`](https://rlang.r-lib.org/reference/eval_tidy.html).
If errors and warnings are produced using the `{cli}` package, the
messages are processed with
[`cli::ansi_strip()`](https://cli.r-lib.org/reference/ansi_strip.html)
to remove styling from the message.

**`captured_condition_as_message()`/`captured_condition_as_error()`**

These functions take the result from `eval_capture_conditions()` and
return errors or warnings as either messages (via
[`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html))
or errors (via
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)).
These functions handle cases where the condition messages may include
curly brackets, which would typically cause issues when processed with
the `cli::cli_*()` functions.

Functions return the `"result"` from `eval_capture_conditions()`.

## Usage

``` r
eval_capture_conditions(expr, data = NULL, env = caller_env())

captured_condition_as_message(
  x,
  message = c("The following {type} occured:", x = "{condition}"),
  type = c("error", "warning"),
  envir = rlang::current_env()
)

captured_condition_as_error(
  x,
  message = c("The following {type} occured:", x = "{condition}"),
  type = c("error", "warning"),
  call = get_cli_abort_call(),
  envir = rlang::current_env()
)
```

## Arguments

- expr:

  An [expression](https://rlang.r-lib.org/reference/topic-defuse.html)
  or [quosure](https://rlang.r-lib.org/reference/topic-quosure.html) to
  evaluate.

- data:

  A data frame, or named list or vector. Alternatively, a data mask
  created with
  [`as_data_mask()`](https://rlang.r-lib.org/reference/as_data_mask.html)
  or
  [`new_data_mask()`](https://rlang.r-lib.org/reference/as_data_mask.html).
  Objects in `data` have priority over those in `env`. See the section
  about data masking.

- env:

  The environment in which to evaluate `expr`. This environment is not
  applicable for quosures because they have their own environments.

- x:

  (`captured_condition`)\
  a captured condition created by `eval_capture_conditions()`.

- message:

  (`character`)\
  message passed to
  [`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html)
  or
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html).
  The condition being printed is saved in an object named `condition`,
  which should be included in this message surrounded by curly brackets.

- type:

  (`string`)\
  the type of condition to return. Must be one of `'error'` or
  `'warning'`.

- envir:

  Environment to evaluate the glue expressions in.

- call:

  (`environment`)\
  Execution environment of currently running function. Default is
  `get_cli_abort_call()`.

## Value

a named list

## Examples

``` r
# function executes without error or warning
eval_capture_conditions(letters[1:2])
#> $result
#> [1] "a" "b"
#> 
#> $warning
#> NULL
#> 
#> $error
#> NULL
#> 
#> attr(,"class")
#> [1] "captured_condition" "list"              

# an error is thrown
res <- eval_capture_conditions(stop("Example Error!"))
res
#> $result
#> NULL
#> 
#> $warning
#> NULL
#> 
#> $error
#> [1] "Example Error!"
#> 
#> attr(,"class")
#> [1] "captured_condition" "list"              
captured_condition_as_message(res)
#> The following error occured:
#> ✖ Example Error!
#> NULL

# if more than one warning is returned, all are saved
eval_capture_conditions({
  warning("Warning 1")
  warning("Warning 2")
  letters[1:2]
})
#> $result
#> [1] "a" "b"
#> 
#> $warning
#> [1] "Warning 1" "Warning 2"
#> 
#> $error
#> NULL
#> 
#> attr(,"class")
#> [1] "captured_condition" "list"              

# messages are not printed to the console
eval_capture_conditions({
  message("A message!")
  letters[1:2]
})
#> $result
#> [1] "a" "b"
#> 
#> $warning
#> NULL
#> 
#> $error
#> NULL
#> 
#> attr(,"class")
#> [1] "captured_condition" "list"              
```

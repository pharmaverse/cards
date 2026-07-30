# Message or error

Either error or message depending on input.

## Usage

``` r
.message_or_error(
  msg,
  error = FALSE,
  call = get_cli_abort_call(),
  envir = rlang::caller_env()
)
```

## Arguments

- msg:

  (scalar `character`)\
  Error message

- error:

  (scalar `logical`)\
  If this should produce an error or a warning. FALSE by default

- call:

  The execution environment of a currently running function, e.g.
  `call = caller_env()`. The corresponding function call is retrieved
  and mentioned in error messages as the source of the error.

  You only need to supply `call` when throwing a condition from a helper
  function which wouldn't be relevant to mention in the message.

  Can also be `NULL` or a [defused function
  call](https://rlang.r-lib.org/reference/topic-defuse.html) to
  respectively not display any call or hard-code a code to display.

  For more information about error calls, see [Including function calls
  in error
  messages](https://rlang.r-lib.org/reference/topic-error-call.html).

- envir:

  (`environment`)\
  Environment to evaluate the glue expressions in passed in
  `cli::cli_abort(message)`. Default is
  [`rlang::current_env()`](https://rlang.r-lib.org/reference/stack.html)

## Value

Invisible NULL

## Examples

``` r
if (FALSE) { # \dontrun{
cards:::.message_or_error("This will be a message", FALSE)
cards:::.message_or_error("This will be an error", TRUE)
} # }
```

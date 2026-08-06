#' Process tidyselectors
#'
#' @description
#' Functions process tidyselect arguments passed to functions in the cards package.
#' The processed values are saved to the calling environment, by default.
#'
#' - `process_selectors()`: the arguments will be processed with tidyselect and
#'   converted to a vector of character column names.
#'
#' - `process_formula_selectors()`: for arguments that expect named lists or
#'   lists of formulas (where the LHS of the formula is a tidyselector). This
#'   function processes these inputs and returns a named list. If a name is
#'   repeated, the last entry is kept.
#'
#' - `fill_formula_selectors()`: when users override the default argument values,
#'   it can be important to ensure that each column from a data frame is assigned
#'   a value. This function checks that each column in `data` has an assigned
#'   value, and if not, fills the value in with the default value passed here.
#'
#' - `compute_formula_selector()`: used in `process_formula_selectors()` to
#'   evaluate a single argument.
#'
#' - `check_list_elements()`: used to check the class/type/values of the list
#'   elements, primarily those processed with `process_formula_selectors()`.
#'
#' - `cards_select()`: wraps `tidyselect::eval_select() |> names()`, and returns
#'   better contextual messaging when errors occur.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param ... ([`dynamic-dots`][rlang::dyn-dots])\cr
#'   named arguments where the value of the argument is processed with tidyselect.
#'   - `process_selectors()`: the values are tidyselect-compatible selectors
#'   - `process_formula_selectors()`: the values are named lists, list of formulas
#'     a combination of both, or a single formula. Users may pass `~value` as a
#'     shortcut for `everything() ~ value`.
#'   - `check_list_elements()`: named arguments where the name matches an existing
#'     list in the `env` environment, and the value is a predicate function
#'     to test each element of the list, e.g. each element must be a string or
#'     a function.
#' @param env (`environment`)\cr
#'   env to save the results to. Default is the calling environment.
#' @param x
#'  - `compute_formula_selector()`: ([`formula-list-selector`][syntax])\cr
#'    a named list, list of formulas, or a single formula that will be
#'    converted to a named list.
#'  - `check_list_elements()`: (named `list`)\cr
#'    a named list
#' @param predicate (`function`)\cr
#'   a predicate function that returns `TRUE` or `FALSE`
#' @param arg_name (`string`)\cr
#'   the name of the argument being processed. Used
#'   in error messaging. Default is `caller_arg(x)`.
#' @param error_msg (`character`)\cr
#'   a character vector that will
#'   be used in error messaging when mis-specified arguments are passed. Elements
#'   `"{arg_name}"` and `"{variable}"` are available using glue syntax for messaging.
#' @param strict (`logical`)\cr
#'   whether to throw an error if a variable doesn't exist in the reference data
#'   (passed to [tidyselect::eval_select()])
#' @param include_env (`logical`)\cr
#'   whether to include the environment from the formula object in the returned
#'   named list. Default is `FALSE`
#' @param allow_empty (`logical`)\cr
#'   Logical indicating whether empty result is acceptable while process
#'   formula-list selectors. Default is `TRUE`.
#' @param expr (`expression`)\cr
#'   Defused R code describing a selection according to the tidyselect syntax.
#'
#' @return `process_selectors()`, `fill_formula_selectors()`, `process_formula_selectors()`
#' and `check_list_elements()` return NULL. `compute_formula_selector()` returns a
#' named list.
#' @name process_selectors
#'
#' @examples
#' example_env <- rlang::new_environment()
#'
#' process_selectors(ADSL, variables = starts_with("TRT"), env = example_env)
#' get(x = "variables", envir = example_env)
#'
#' fill_formula_selectors(ADSL, env = example_env)
#'
#' process_formula_selectors(
#'   ADSL,
#'   statistic = list(starts_with("TRT") ~ mean, TRTSDT = min),
#'   env = example_env
#' )
#' get(x = "statistic", envir = example_env)
#'
#' check_list_elements(
#'   get(x = "statistic", envir = example_env),
#'   predicate = function(x) !is.null(x),
#'   error_msg = c(
#'     "Error in the argument {.arg {arg_name}} for variable {.val {variable}}.",
#'     "i" = "Value must be a named list of functions."
#'   )
#' )
#'
#' # process one list
#' compute_formula_selector(ADSL, x = starts_with("U") ~ 1L)
NULL

#' @name process_selectors
#' @export
process_selectors <- function(data, ...) {
  UseMethod("process_selectors")
}

#' @name process_selectors
#' @export
process_formula_selectors <- function(data, ...) {
  UseMethod("process_formula_selectors")
}

#' @name process_selectors
#' @export
fill_formula_selectors <- function(data, ...) {
  UseMethod("fill_formula_selectors")
}

#' @name process_selectors
#' @export
process_selectors.data.frame <- function(data, ..., env = caller_env()) {
  set_cli_abort_call()

  # saved dots as named list of quos
  dots <- enquos(...)

  # save named list of character column names selected
  ret <-
    imap(
      dots,
      function(x, arg_name) {
        processed_value <-
          cards_select(
            expr = x,
            data = data,
            allow_rename = FALSE,
            arg_name = arg_name
          )
      }
    )

  # save processed args to the calling env (well, that is the default env)
  for (i in seq_along(ret)) {
    assign(x = names(ret)[i], value = ret[[i]], envir = env)
  }
}


#' @name process_selectors
#' @export
process_formula_selectors.data.frame <- function(data, ..., env = caller_env(),
                                                 include_env = FALSE, allow_empty = TRUE) {
  set_cli_abort_call()

  # saved dots as named list
  dots <- dots_list(...)

  # initialize empty list to store results and evaluate each input
  ret <- rep_named(names(dots), list())
  for (i in seq_along(dots)) {
    ret[[i]] <-
      compute_formula_selector(
        data = data, x = dots[[i]],
        arg_name = names(dots)[i],
        env = env,
        include_env = include_env
      )
  }

  # save processed args to the calling env (well, that is the default env)
  for (i in seq_along(ret)) {
    assign(x = names(ret)[i], value = ret[[i]], envir = env)
  }
}

#' @name process_selectors
#' @export
fill_formula_selectors.data.frame <- function(data, ..., env = caller_env()) {
  set_cli_abort_call()

  dots <- dots_list(...)
  ret <- rep_named(names(dots), list(NULL))
  data_names <- names(data)
  dots_names <- names(dots)

  for (i in seq_along(dots)) {
    if (!is_empty(setdiff(data_names, names(get(dots_names[i], envir = env))))) {
      # process the default selector
      ret[[i]] <-
        compute_formula_selector(
          data = data, x = dots[[i]],
          arg_name = dots_names[i], env = env
        )
      # add the previously specified values and overwrite the default
      ret[[i]][names(get(dots_names[i], envir = env))] <-
        get(dots_names[i], envir = env)
    }
  }

  # save processed args to the calling env (well, that is the default env)
  for (i in seq_along(ret)) {
    if (!is.null(ret[[i]])) assign(x = names(ret)[i], value = ret[[i]], envir = env)
  }
}

#' @name process_selectors
#' @export
compute_formula_selector <- function(data, x, arg_name = caller_arg(x), env = caller_env(),
                                     strict = TRUE, include_env = FALSE, allow_empty = TRUE) {
  set_cli_abort_call()

  # check inputs ---------------------------------------------------------------
  check_formula_list_selector(x, arg_name = arg_name, allow_empty = allow_empty, call = env)

  # user passed a named list, return unaltered
  if (.is_named_list(x)) {
    # remove duplicates (keeping the last one)
    x <- x[names(x) |> rev() |> Negate(duplicated)() |> rev()] # styler: off

    return(x[intersect(names(x), names(data))])
  }

  # if user passed a single formula, wrap it in a list
  if (inherits(x, "formula")) x <- list(x)

  for (i in seq_along(x)) {
    # if element is a formula, convert to a named list
    if (inherits(x[[i]], "formula")) {
      lhs_quo <- f_lhs_as_quo(x[[i]])

      if (!is.null(data)) {
        lhs_quo <- cards_select(
          # if nothing found on LHS of formula, using `everything()`
          expr = lhs_quo %||% dplyr::everything(),
          data = data,
          strict = strict,
          allow_rename = FALSE,
          arg_name = arg_name
        )
      }

      colnames <- eval_tidy(lhs_quo)
      x[i] <-
        rep_len(
          list(
            eval_tidy(f_rhs_as_quo(x[[i]])) |>
              structure(
                .Environment =
                  switch(isTRUE(include_env), attr(x[[i]], ".Environment")) # styler: off
              )
          ),
          length.out = length(colnames)
        ) |>
        stats::setNames(nm = colnames) |>
        list()
    }
  }

  # flatten the list to a top-level list only
  x <- .purrr_list_flatten(x)

  # remove duplicates (keeping the last one)
  x <- x[names(x) |> rev() |> Negate(duplicated)() |> rev()] # styler: off

  # only keeping names in the data frame
  x[intersect(names(x), names(data))]
}

#' @name process_selectors
#' @export
check_list_elements <- function(x,
                                predicate,
                                error_msg = NULL,
                                arg_name = rlang::caller_arg(x)) {
  set_cli_abort_call()

  imap(
    x,
    function(lst_element, variable) {
      if (!isTRUE(predicate(lst_element))) {
        msg <-
          error_msg %||%
          "The value for argument {.arg {arg_name}} and variable {.val {variable}} is not the expected type."
        cli::cli_abort(message = msg, call = get_cli_abort_call())
      }
    }
  )

  invisible()
}

#' @name process_selectors
#' @export
cards_select <- function(expr, data, ...,
                         arg_name = NULL) {
  set_cli_abort_call()

  tryCatch(
    tidyselect::eval_select(expr = expr, data = data, ...) |> names(),
    error = function(e) {
      cli::cli_abort(
        message = c(
          switch(!is.null(arg_name),
            "Error processing {.arg {arg_name}} argument."
          ),
          "!" = cli::ansi_strip(conditionMessage(e)),
          i = "Select among columns {.val {names(data)}}"
        ),
        call = get_cli_abort_call()
      )
    }
  )
}


# These functions are like rlang::f_lhs(), but they extract the expression
# as a quosure with the env from the formula.
f_lhs_as_quo <- function(f) {
  if (is.null(f_lhs(f))) return(NULL) # styler: off
  quo(!!f_lhs(f)) |> structure(.Environment = attr(f, ".Environment"))
}

f_rhs_as_quo <- function(f) {
  if (is.null(f_rhs(f))) return(NULL) # styler: off
  quo(!!f_rhs(f)) |> structure(.Environment = attr(f, ".Environment"))
}

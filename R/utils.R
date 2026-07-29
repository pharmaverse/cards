#' ARD-flavor of unique()
#'
#' Essentially a wrapper for `unique(x)` sorted in the C locale with `NA` levels
#' removed. Character values are ordered with `order(method = "radix")`, so the
#' result is independent of the session locale and matches the ordering
#' `dplyr::arrange()` applies. For factors, all levels are returned even if they
#' are unobserved. Similarly, logical vectors always return `c(TRUE, FALSE)`,
#' even if both levels are not observed.
#'
#' @param x (`any`)\cr
#'   a vector
#'
#' @return a vector
#' @keywords internal
#'
#' @examples
#' cards:::.unique_and_sorted(factor(letters[c(5, 5:1)], levels = letters))
#'
#' cards:::.unique_and_sorted(c(FALSE, TRUE, TRUE, FALSE))
#'
#' cards:::.unique_and_sorted(c(5, 5:1))
.unique_and_sorted <- function(x, useNA = c("no", "always")) {
  # styler: off
  useNA <- match.arg(useNA)
  # if a factor return a factor that includes the same levels (including unobserved levels)
  if (inherits(x, "factor")) {
    return(
      factor(
        if (useNA == "no") levels(x)
        else c(levels(x), NA_character_),
        levels = levels(x)
      )
    )
  }
  if (inherits(x, "logical")) {
    if (useNA == "no") return(c(FALSE, TRUE))
    else return(c(FALSE, TRUE, NA))
  }

  # otherwise, return the unique values sorted in the C locale (radix), which is
  # independent of the session locale and matches dplyr::arrange() ordering.
  # `na.last = NA` drops NA, matching sort()'s default.
  ux <- unique(x)
  ux <- ux[order(ux, method = "radix", na.last = NA)]
  if (useNA == "no") return(ux)
  else return(c(ux, NA))
  # styler: on
}


#' Named List Predicate
#'
#' A predicate function to check whether input is a named list and _not_ a data frame.
#'
#' @param x (`any`)\cr
#'   object to check
#'
#' @return a logical
#' @keywords internal
#'
#' @examples
#' cards:::.is_named_list(list(a = 1:3))
.is_named_list <- function(x, allow_df = FALSE) {
  if (isFALSE(allow_df)) {
    return(is.list(x) && is_named(x) && !is.data.frame(x))
  }
  if (isTRUE(allow_df)) {
    return(is.list(x) && is_named(x))
  }
}

#' A list_flatten()-like Function
#'
#' Function operates similarly to `purrr::list_flatten(x, name_spec = "{inner}")`.
#'
#' @param x (named `list`)\cr
#'   a named list
#'
#' @return a named list
#' @keywords internal
#'
#' @examples
#' x <- list(a = 1, b = list(b1 = 2, b2 = 3), c = list(c1 = 4, c2 = list(c2a = 5)))
#'
#' cards:::.purrr_list_flatten(x)
.purrr_list_flatten <- function(x) {
  ret <- list()

  for (i in seq_along(x)) {
    if (.is_named_list(x[[i]])) {
      ret <- append(ret, values = x[[i]])
    } else {
      ret <- append(ret, values = x[i])
    }
  }

  ret
}


#' Message or error
#'
#' Either error or message depending on input.
#'
#' @param msg (scalar `character`)\cr
#'   Error message
#' @param error (scalar `logical`)\cr
#'   If this should produce an error or a warning. FALSE by default
#' @param envir (`environment`)\cr
#'   Environment to evaluate the glue expressions in passed in `cli::cli_abort(message)`.
#'   Default is `rlang::current_env()`
#' @inheritParams cli::cli_abort
#' @return Invisible NULL
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' cards:::.message_or_error("This will be a message", FALSE)
#' cards:::.message_or_error("This will be an error", TRUE)
#' }
.message_or_error <- function(msg, error = FALSE, call = get_cli_abort_call(),
                              envir = rlang::caller_env()) {
  if (error) {
    cli::cli_abort(
      msg,
      call = call, .envir = envir
    )
  } else {
    cli::cli_inform(msg, call = call, .envir = envir)
  }
}

#' Stack ARDs
#'
#' @description
#' Stack multiple ARD calls sharing common input `data` and `by` variables.
#' Optionally incorporate additional information on represented variables, e.g.
#' overall calculations, rates of missingness, attributes, or transform results
#' with `shuffle_ard()`.
#'
#' If the `ard_stack(by)` argument is specified, a univariate tabulation of the
#' by variable will also be returned.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param .by ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns to tabulate by in the series of ARD function calls.
#'   Any rows with `NA` or `NaN` values are removed from all calculations.
#' @param ... ([`dynamic-dots`][rlang::dyn-dots])\cr
#'   Series of ARD function calls to be run and stacked
#' @param .overall (`logical`)\cr logical indicating whether overall statistics
#'   should be calculated (i.e. re-run all `ard_*()` calls with `by=NULL`).
#'   Default is `FALSE`.
#' @param .missing (`logical`)\cr
#'   logical indicating whether to include the results of `ard_missing()` for all
#'   variables represented in the ARD. Default is `FALSE`.
#' @param .attributes (`logical`)\cr
#'   logical indicating whether to include the results of `ard_attributes()` for all
#'   variables represented in the ARD. Default is `FALSE`.
#' @param .shuffle `r lifecycle::badge("deprecated")` support for `.shuffle = TRUE`
#'   has been removed.
#' @param .total_n (`logical`)\cr
#'   logical indicating whether to include of `ard_total_n()` in the returned ARD.
#' @param .by_stats (`logical`)\cr
#'   logical indicating whether to include overall stats of the `by` variables in the returned ARD.
#'
#' @return an ARD data frame of class 'card'
#' @export
#'
#' @examples
#' ard_stack(
#'   data = ADSL,
#'   ard_tabulate(variables = "AGEGR1"),
#'   ard_summary(variables = "AGE"),
#'   .by = "ARM",
#'   .overall = TRUE,
#'   .attributes = TRUE
#' )
#'
#' ard_stack(
#'   data = ADSL,
#'   ard_tabulate(variables = "AGEGR1"),
#'   ard_summary(variables = "AGE"),
#'   .by = "ARM"
#' )
#'
ard_stack <- function(data,
                      ...,
                      .by = NULL,
                      .overall = FALSE,
                      .missing = FALSE,
                      .attributes = FALSE,
                      .total_n = FALSE,
                      .shuffle = FALSE,
                      .by_stats = TRUE) {
  set_cli_abort_call()

  # process arguments ----------------------------------------------------------
  process_selectors(data, .by = {{ .by }})

  # check inputs ---------------------------------------------------------------
  check_not_missing(data)
  check_data_frame(data)

  check_scalar_logical(.overall)
  check_scalar_logical(.missing)
  check_scalar_logical(.attributes)
  check_scalar_logical(.shuffle)
  check_scalar_logical(.total_n)
  check_scalar_logical(.by_stats)

  if (is_empty(.by) && isTRUE(.overall)) {
    cli::cli_inform(
      c("The {.arg .by} argument should be specified when using {.code .overall=TRUE}.",
        i = "Setting {.code ard_stack(.overall=FALSE)}."
      )
    )
    .overall <- FALSE
  }

  # remove missing `.by` rows --------------------------------------------------
  df_na_by <- is.na(data[.by]) | apply(data[.by], MARGIN = 2, is.nan)
  if (!is_empty(.by) && any(df_na_by)) {
    rows_with_na <- apply(df_na_by, MARGIN = 1, any)
    cli::cli_inform(c("*" = "Removing {.val {sum(rows_with_na)}} row{?s} with
                            {.val {NA}} or {.val {NaN}} values in {.val {eval(.by)}} column{?s}."))
    data <- data[!rows_with_na, ]
  }

  # evaluate the dots using common `data` and `by` -----------------------------
  ard_list <- .eval_ard_calls(data, .by, ...)

  # add overall ----------------------------------------------------------------
  if (isTRUE(.overall)) {
    ard_list <- c(
      ard_list,
      .eval_ard_calls(data, .by = character(0), ...)
    )
  }

  # compute Ns by group / combine main calls -----------------------------------
  if (!is_empty(by) && isTRUE(.by_stats)) {
    ard_full <- bind_ard(
      ard_list,
      ard_tabulate(
        data = data,
        variables = all_of(.by)
      )
    )
  } else {
    ard_full <- bind_ard(ard_list, .update = TRUE)
  }

  # get all variables represented ----------------------------------------------
  variables <- unique(ard_full$variable) |> setdiff(.by)

  # missingness ----------------------------------------------------------------
  if (isTRUE(.missing)) {
    ard_full <- bind_ard(
      ard_full,
      ard_missing(data = data, by = any_of(.by), variables = all_of(variables))
    )
    if (!is_empty(by) && isTRUE(.overall)) {
      ard_full <- bind_ard(
        ard_full,
        ard_missing(data = data, by = character(0L), variables = all_of(variables))
      )
    }
  }

  # attributes -----------------------------------------------------------------
  if (isTRUE(.attributes)) {
    ard_full <- bind_ard(
      ard_full,
      ard_attributes(data, variables = all_of(c(variables, .by)))
    )
  }

  # total n --------------------------------------------------------------------
  if (isTRUE(.total_n)) {
    ard_full <- bind_ard(
      ard_full,
      ard_total_n(data)
    )
  }

  # order ----------------------------------------------------------------------
  ard_full <- tidy_ard_row_order(ard_full)

  # append attributes ----------------------------------------------------------
  attr(ard_full, "args") <- list(
    by = .by
  )

  # shuffle --------------------------------------------------------------------
  if (isTRUE(.shuffle)) {
    lifecycle::deprecate_stop(
      when = "0.7.0",
      what = "cards::ard_stack(.shuffle)"
    )
  }

  # assign new class -----------------------------------------------------------
  class(ard_full) <- c("ard_stack", class(ard_full))

  # return final ARD -----------------------------------------------------------
  ard_full
}


#' Evaluate the `ard_*()` function calls
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param .by ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns to tabulate by in the series of ARD function calls
#' @param ... ([`dynamic-dots`][rlang::dyn-dots])\cr
#'   Series of ARD function calls to be run and stacked
#'
#' @return list of ARD data frames of class 'card'
#' @keywords internal
#'
#' @examples
#' cards:::.eval_ard_calls(
#'   data = ADSL,
#'   .by = "ARM",
#'   ard_tabulate(variables = "AGEGR1"),
#'   ard_summary(variables = "AGE")
#' )
.eval_ard_calls <- function(data, .by, ...) {
  # capture quosures -----------------------------------------------------------
  dots <- enquos(...)


  # run the ARD calls -------------------------------------------------------
  imap(
    dots,
    function(x, y) {
      if (!is_call_simple(x)) {
        if (identical(y, "by")) {
          cli::cli_abort(
            c("Cannot evaluate expression {.code {y} = {quo_squash(x)}}.",
              i = "Did you mean {.code .{y} = {quo_squash(x)}}?"
            ),
            call = get_cli_abort_call()
          )
        }

        cli::cli_abort(
          "{.fun cards::ard_stack} works with {.help [simple calls](rlang::call_name)}
           and {.code {as_label(x)}} is not simple.",
          call = get_cli_abort_call()
        )
      }
      x_ns <- call_ns(x)
      x_fn <- call_name(x)
      x_args <- call_args(x)

      # if a function was namespaced, then grab function from that pkg's Namespace
      # styler: off
      final_fn <-
        if (is.null(x_ns)) x_fn
        else get(x_fn, envir = asNamespace(x_ns))
      # styler: on

      do.call(final_fn, c(list(data = data, by = .by), x_args), envir = attr(x, ".Environment"))
    }
  )
}

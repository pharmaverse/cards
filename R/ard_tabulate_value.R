#' Tabulate Value ARD
#'
#' Tabulate an Analysis Results Data (ARD) for dichotomous or a specified value.
#'
#' @inheritParams ard_tabulate
#' @param value (named `list`)\cr
#'   named list of values to tabulate. Default is `maximum_variable_value(data)`,
#'   which returns the largest/last value after a sort.
#'
#' @return an ARD data frame of class 'card'
#' @name ard_tabulate_value
#'
#' @inheritSection ard_tabulate Denominators
#'
#' @examples
#' ard_tabulate_value(mtcars, by = vs, variables = c(cyl, am), value = list(cyl = 4))
#'
#' mtcars |>
#'   dplyr::group_by(vs) |>
#'   ard_tabulate_value(
#'     variables = c(cyl, am),
#'     value = list(cyl = 4),
#'     statistic = ~"p"
#'   )
NULL

#' @rdname ard_tabulate_value
#' @export
ard_tabulate_value <- function(data, ...) {
  check_not_missing(data)
  UseMethod("ard_tabulate_value")
}

#' @rdname ard_tabulate_value
#' @export
ard_tabulate_value.data.frame <- function(data,
                                          variables,
                                          by = dplyr::group_vars(data),
                                          strata = NULL,
                                          value = maximum_variable_value(data[variables]),
                                          statistic = everything() ~ c("n", "N", "p"),
                                          denominator = NULL,
                                          fmt_fun = NULL,
                                          stat_label = everything() ~ default_stat_labels(),
                                          fmt_fn = deprecated(),
                                          ...) {
  set_cli_abort_call()

  # deprecated args ------------------------------------------------------------
  if (lifecycle::is_present(fmt_fn)) {
    lifecycle::deprecate_soft(
      when = "0.6.1",
      what = "ard_tabulate_value(fmt_fn)",
      with = "ard_tabulate_value(fmt_fun)"
    )
    fmt_fun <- fmt_fn
  }

  # check inputs ---------------------------------------------------------------
  check_not_missing(variables)

  # process inputs -------------------------------------------------------------
  process_selectors(data, variables = {{ variables }}, by = {{ by }}, strata = {{ strata }})
  process_formula_selectors(data[variables], value = value)
  fill_formula_selectors(
    data[variables],
    value = formals(asNamespace("cards")[["ard_tabulate_value.data.frame"]])[["value"]] |> eval()
  )
  .check_dichotomous_value(data, value)

  # return empty ARD if no variables selected ----------------------------------
  if (is_empty(variables)) {
    return(dplyr::tibble() |> as_card(check = FALSE))
  }

  # calculate summary statistics -----------------------------------------------
  ard_final <- ard_tabulate(
    data = data,
    variables = all_of(variables),
    by = any_of(by),
    strata = any_of(strata),
    statistic = statistic,
    denominator = denominator,
    fmt_fun = fmt_fun,
    stat_label = stat_label
  ) |>
    dplyr::filter({
      keep <- logical(dplyr::n())
      val <- .env$value
      for (v in names(val)) {
        idx <- which(.data$variable == v)
        if (length(idx) > 0) {
          v_levels <- .data$variable_level[idx]
          if (all(lengths(v_levels) == 1L)) {
            keep[idx] <- unlist(v_levels, recursive = FALSE, use.names = FALSE) %in% val[[v]]
          } else {
            keep[idx] <- vapply(v_levels, function(x) x %in% val[[v]], logical(1))
          }
        }
      }
      keep
    }) |>
    dplyr::mutate(context = "tabulate_value")

  # append attributes ----------------------------------------------------------
  attr(ard_final, "args") <- list(
    variables = variables,
    by = by,
    strata = strata
  )

  ard_final
}

#' Perform Value Checks
#'
#' Check the validity of the values passed in `ard_tabulate_value(value)`.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param value (named `list`)\cr
#'   a named list
#'
#' @return returns invisible if check is successful, throws an error message if not.
#' @keywords internal
#'
#' @examples
#' cards:::.check_dichotomous_value(mtcars, list(cyl = 4))
.check_dichotomous_value <- function(data, value) {
  imap(
    value,
    function(value, column) {
      accepted_values <- .unique_and_sorted(data[[column]])
      if (length(value) != 1L || !value %in% accepted_values) {
        message <- "Error in argument {.arg value} for variable {.val {column}}."
        message <-
          case_switch(
            length(value) != 1L ~ c(message, "i" = "The value must be one of {.val {accepted_values}}."),
            .default = c(message, "i" = "A value of {.val {value}} was passed, but must be one of {.val {accepted_values}}.")
          )
        if (length(value) == 1L) {
          message <-
            case_switch(
              inherits(data[[column]], "factor") ~
                c(message, i = "To summarize this value, use {.fun forcats::fct_expand} to add {.val {value}} as a level."),
              .default = c(message, i = "To summarize this value, make the column a factor and include {.val {value}} as a level.")
            )
        }


        cli::cli_abort(
          message = message,
          call = get_cli_abort_call()
        )
      }
    }
  ) |>
    invisible()
}

case_switch <- function(..., .default = NULL) {
  dots <- dots_list(...)

  for (f in dots) {
    if (isTRUE(eval(f_lhs(f), envir = attr(f, ".Environment")))) {
      return(eval(f_rhs(f), envir = attr(f, ".Environment")))
    }
  }

  return(.default)
}

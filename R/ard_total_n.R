#' ARD Total N
#'
#' Returns the total N for the data frame.
#' The placeholder variable name returned in the object is `"..ard_total_n.."`
#'
#' @inheritParams ard_tabulate
#' @inheritParams rlang::args_dots_empty
#'
#' @return an ARD data frame of class 'card'
#' @name ard_total_n
#'
#' @examples
#' ard_total_n(ADSL)
NULL

#' @rdname ard_total_n
#' @export
ard_total_n <- function(data, ...) {
  check_not_missing(data)
  UseMethod("ard_total_n")
}

#' @rdname ard_total_n
#' @export
ard_total_n.data.frame <- function(data, ...) {
  # process inputs -------------------------------------------------------------
  set_cli_abort_call()
  check_dots_empty()
  check_data_frame(data)

  # calculate total N ----------------------------------------------------------
  ans <-
    dplyr::tibble(
      variable = "..ard_total_n..",
      context = "total_n",
      stat_name = "N",
      stat_label = "N",
      stat = list(nrow(data)),
      fmt_fun = list(0L),
      warning = list(NULL),
      error = list(NULL)
    ) |>
    as_card()

  attr(ans, "args") <- list(variables = "..ard_total_n..", by = character(0), strata = character(0))

  ans
}

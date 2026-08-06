#' Data Frame as ARD
#'
#' Convert data frames to ARDs of class 'card'.
#'
#'
#' @param x (`data.frame`)\cr
#'   a data frame
#' @param check (scalar `logical`)\cr
#'   Whether the input data frame should be checked for standard ARD features
#' @return an ARD data frame of class 'card'
#' @export
#'
#' @examples
#' data.frame(
#'   stat_name = c("N", "mean"),
#'   stat_label = c("N", "Mean"),
#'   stat = c(10, 0.5)
#' ) |>
#'   as_card(check = FALSE)
#' dplyr::tibble(
#'   variable = "AGE",
#'   stat_name = c("N", "mean"),
#'   stat_label = c("N", "Mean"),
#'   stat = list(10, 0.5),
#'   fmt_fun = replicate(2, list()),
#'   warning = replicate(2, list()),
#'   error = replicate(2, list())
#' ) |>
#'   as_card()
as_card <- function(x, check = TRUE) {
  set_cli_abort_call()

  # check in inputs ------------------------------------------------------------
  check_class(x, cls = "data.frame")
  check_scalar_logical(check)

  # convert to class "card" ----------------------------------------------------
  # ensure the ARD is always a tibble, so it prints via the pillar/tibble
  # machinery (a plain data.frame would otherwise print as a base data frame)
  if (!inherits(x, "tbl")) {
    x <- tibble::as_tibble(x)
  }
  if (inherits(x, "card")) {
    out <- x
  } else {
    out <- structure(x, class = c("card", class(x)))
  }
  if (check) {
    check_ard_structure(out,
      column_order = FALSE, method = FALSE,
      error_on_fail = TRUE
    )
  }

  out
}

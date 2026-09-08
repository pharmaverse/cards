#' Compare ARDs
#'
#' @description
#' `r lifecycle::badge('experimental')`\cr
#' `compare_ard()` compares columns of two ARDs row-by-row using a shared set
#' of key columns. Rows where the column values differ are returned.
#'
#' The `is_ard_equal()` function accepts a `compare_ard()`
#' object, and returns `TRUE` or `FALSE` depending on whether the comparison
#' reported difference. `check_ard_equal()` returns as error if not equal.
#'
#' @param x (`card`)\cr
#'   first ARD to compare.
#' @param y (`card`)\cr
#'   second ARD to compare.
#' @param keys ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns identifying unique records. The selection is evaluated
#'   separately against each ARD and must resolve to the same set of
#'   columns in both; otherwise an error is thrown. Default is
#'   `c(all_ard_groups(), all_ard_variables(), any_of(c("variable", "variable_level", "stat_name")))`.
#' @param columns ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns to compare between the two ARDs. The selection is evaluated
#'   against each ARD, and the columns present in both are compared. When the
#'   two selections differ, a message reports the columns that were skipped;
#'   when they have nothing in common, an error is thrown. Default is
#'   `any_of(c("stat_label", "stat", "stat_fmt"))`.
#' @param tolerance (`numeric(1)`)\cr
#'   numeric tolerance passed to `all.equal()` for numeric comparisons.
#'   Default is `sqrt(.Machine$double.eps)`.
#' @param check.attributes (`logical(1)`)\cr
#'   logical passed to `all.equal()` indicating whether object attributes
#'   (e.g. names) should be compared. Default is `TRUE`.
#'
#' @return a named list of class `"ard_comparison"` containing:
#'
#'   - `rows_in_x_not_y`: data frame of rows present in `x` but not in `y`
#'     (based on key columns)
#'   - `rows_in_y_not_x`: data frame of rows present in `y` but not in `x`
#'     (based on key columns)
#'   - `compare`: a named list where each element is a data frame containing
#'     the key columns, the compared column values from both ARDs, and a
#'     `difference` column with the `all.equal()` description for rows where
#'     values differ
#'
#' @name compare_ard
#'
#' @examples
#' base <- ard_summary(ADSL, by = ARM, variables = AGE)
#' compare <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1),
#'   by = ARM,
#'   variables = AGE
#' )
#'
#' compare_ard(base, compare)$compare$stat
NULL

#' @name compare_ard
#' @export
compare_ard <- function(x,
                        y,
                        keys = c(all_ard_groups(), all_ard_variables(), any_of(c("variable", "variable_level", "stat_name"))),
                        columns = any_of(c("stat_label", "stat", "stat_fmt")),
                        tolerance = sqrt(.Machine$double.eps),
                        check.attributes = TRUE) {
  set_cli_abort_call()

  check_class(x, cls = "card")
  check_class(y, cls = "card")

  # process keys and compare arguments -----------------------------------------
  keys <- .process_keys_arg(x, y, keys = {{ keys }})
  columns <- .process_compare_arg(x, y, columns = {{ columns }})

  # check for duplicates in keys -----------------------------------------------
  .check_keys_unique(x, keys, arg_name = "x")
  .check_keys_unique(y, keys, arg_name = "y")

  # initialize results list ----------------------------------------------------
  results <- rlang::rep_named(c("keys", "columns", "rows_in_x_not_y", "rows_in_y_not_x"), list(NULL))
  results[["comparison"]] <- rlang::rep_named(columns, list(NULL))

  # save keys and columns ------------------------------------------------------
  results[["keys"]] <- keys
  results[["columns"]] <- columns

  # find rows present in one ARD but not the other -----------------------------
  results[["rows_in_x_not_y"]] <- .compare_rows(x, y, keys)
  results[["rows_in_y_not_x"]] <- .compare_rows(y, x, keys)

  # compare columns and find mismatches ----------------------------------------
  results[["comparison"]] <- .compare_columns(x, y, keys, columns, tolerance, check.attributes)

  # return results with class --------------------------------------------------
  structure(results, class = c("compare_ard", class(results)))
}

#' @name compare_ard
#' @export
is_ard_equal <- function(x) {
  # check input class ----------------------------------------------------------
  check_class(x, "compare_ard")

  # check if there are mismatches rows -----------------------------------------
  if (nrow(x[["rows_in_x_not_y"]]) > 0L || nrow(x[["rows_in_y_not_x"]]) > 0L) {
    return(FALSE)
  }

  # check comparison results ---------------------------------------------------
  for (i in seq_along(x[["comparison"]])) {
    if (nrow(x[["comparison"]][[i]]) > 0L) {
      return(FALSE)
    }
  }

  # If not triggered earlier, then ARDs are equal
  TRUE
}

#' @name compare_ard
#' @export
check_ard_equal <- function(x) {
  is_ard_equal <- is_ard_equal(x)

  if (isFALSE(is_ard_equal)) {
    cli::cli_abort("ARDs are not equal.")
  }

  invisible(TRUE)
}

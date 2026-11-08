#' Bind ARDs
#'
#' Wrapper for `dplyr::bind_rows()` with additional checks
#' for duplicated statistics.
#'
#' @param ... ([`dynamic-dots`][rlang::dyn-dots])\cr
#'   ARDs to combine. Each argument can either be an ARD,
#'   or a list of ARDs. Columns are matched by name, and any missing
#'   columns will be filled with `NA`.
#' @param .distinct (`logical`)\cr
#'   logical indicating whether to remove non-distinct values from the ARD.
#'   Duplicates are checked across grouping variables, primary variables,
#'   context (if present), the **statistic name and the statistic value**.
#'   Default is `TRUE`. If a statistic name and value is repeated and `.distinct=TRUE`,
#'   the more recently added statistics will be retained, and the other(s) omitted.
#' @param .update (`logical`)\cr
#'   logical indicating whether to update ARD and remove duplicated named statistics.
#'   Duplicates are checked across grouping variables, primary variables, and the
#'   **statistic name**.
#'   Default is `FALSE`. If a statistic name is repeated and `.update=TRUE`,
#'   the more recently added statistics will be retained, and the other(s) omitted.
#' @param .order (`logical`)\cr
#'   logical indicating whether to order the rows of the stacked ARDs, allowing
#'   statistics that share common group and variable values to appear in
#'   consecutive rows. Default is `FALSE`. Ordering will be based on the order
#'   of the group/variable values prior to stacking.
#' @param .quiet (`logical`)\cr
#'   logical indicating whether to suppress any messaging. Default is `FALSE`
#'
#' @return an ARD data frame of class 'card'
#' @export
#'
#' @examples
#' ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
#'
#' bind_ard(ard, ard, .update = TRUE)
bind_ard <- function(..., .distinct = TRUE, .update = FALSE, .order = FALSE, .quiet = FALSE) {
  set_cli_abort_call()

  # check inputs ---------------------------------------------------------------
  check_scalar_logical(.distinct)
  check_scalar_logical(.update)
  check_scalar_logical(.order)
  check_scalar_logical(.quiet)

  # stack ARDs -----------------------------------------------------------------
  data <- dplyr::bind_rows(...)

  # check for non-distinct statistics ------------------------------------------
  not_distinct <-
    dplyr::select(data, all_ard_groups(), all_ard_variables(), any_of("context"), "stat_name", "stat")[seq(nrow(data), 1L), ] |>
    duplicated()
  if (any(not_distinct) && isTRUE(.distinct)) {
    if (isFALSE(.quiet)) {
      cli::cli_inform(c(
        "i" = "{sum(not_distinct)} row{?s} with {.emph duplicated statistic values} {?has/have} been removed.",
        "*" = "See {.help [cards::bind_ard(.distinct)](cards::bind_ard)} for details."
      ))
    }
    data <- data[!rev(not_distinct), ]
  }

  # check for duplicate stat_name ----------------------------------------------
  dupes <-
    dplyr::select(data, all_ard_groups(), all_ard_variables(), "stat_name")[seq(nrow(data), 1L), ] |>
    duplicated()

  if (any(dupes) && isTRUE(.update)) {
    if (isFALSE(.quiet)) {
      cli::cli_inform(c(
        "i" = "{sum(dupes)} row{?s} with {.emph duplicated statistic names} {?has/have} been removed.",
        "*" = "See {.help [cards::bind_ard(.update)](cards::bind_ard)} for details."
      ))
    }
    data <-
      dplyr::filter(
        data,
        .by = c(all_ard_groups(), all_ard_variables(), "stat_name"),
        dplyr::row_number() == dplyr::n()
      )
  } else if (any(dupes) && isFALSE(.update)) {
    cli::cli_abort(
      c(
        "!" = "{sum(dupes)} row{?s} with {.emph duplicated statistic names} {?has/have} been found.",
        "i" = "See {.help [cards::bind_ard(.update)](cards::bind_ard)} for details."
      ),
      call = get_cli_abort_call()
    )
  }

  # optionally reorder ---------------------------------------------------------
  if (isTRUE(.order)) {
    data <- tidy_ard_row_order(data)
  }

  # return stacked ARDs --------------------------------------------------------
  res <- tidy_ard_column_order(data) |> as_card(check = FALSE)

  # Assign "bind_ard" class alongside existing classes
  class(res) <- c("bind_ard", class(res))

  res
}

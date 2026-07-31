#' Hierarchical ARD Statistics
#'
#' @description
#' _Functions `ard_hierarchical()` and `ard_hierarchical_count()` are primarily helper
#' functions for [`ard_stack_hierarchical()`] and [`ard_stack_hierarchical_count()`],
#' meaning that it will be rare a user needs to call
#' `ard_hierarchical()`/`ard_hierarchical_count()` directly._
#'
#' Performs hierarchical or nested tabulations, e.g. tabulates AE terms
#' nested within AE system organ class.
#' - `ard_hierarchical()` includes summaries for the last variable listed
#'   in the `variables` argument, nested within the other variables included.
#' - `ard_hierarchical_count()` includes summaries for _all_ variables
#'   listed in the `variables` argument each summary nested within the preceding
#'   variables, e.g. `variables=c(AESOC, AEDECOD)` summarizes `AEDECOD` nested
#'   in `AESOC`, and also summarizes the counts of `AESOC`.
#'
#' @param variables ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   variables to perform the nested/hierarchical tabulations within.
#' @param by ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   variables to perform tabulations by. All combinations of the variables
#'   specified here appear in results. Default is `dplyr::group_vars(data)`.
#' @param id ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   an optional argument used to assert there are no duplicates within
#'   the `c(id, variables)` columns.
#' @param denominator (`data.frame`, `integer`)\cr
#'   used to define the denominator and enhance the output.
#'   The argument is required for `ard_hierarchical()` and optional
#'   for `ard_hierarchical_count()`.
#'   - the univariate tabulations of the `by` variables are calculated with `denominator`,
#'     when a data frame is passed, e.g. tabulation of the treatment assignment
#'     counts that may appear in the header of a table.
#'   - the `denominator` argument must be specified when `id` is used to
#'     calculate the event rates.
#' @inheritParams ard_tabulate
#'
#' @return an ARD data frame of class 'card'
#' @name ard_hierarchical
#'
#' @examples
#' ard_hierarchical(
#'   data = ADAE |>
#'     dplyr::slice_tail(n = 1L, by = c(USUBJID, TRTA, AESOC, AEDECOD)),
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   id = USUBJID,
#'   denominator = ADSL
#' )
#'
#' ard_hierarchical_count(
#'   data = ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA
#' )
NULL

#' @rdname ard_hierarchical
#' @export
ard_hierarchical <- function(data, ...) {
  check_not_missing(data)
  UseMethod("ard_hierarchical")
}

#' @rdname ard_hierarchical
#' @export
ard_hierarchical_count <- function(data, ...) {
  check_not_missing(data)
  UseMethod("ard_hierarchical_count")
}

#' @rdname ard_hierarchical
#' @export
ard_hierarchical.data.frame <- function(data,
                                        variables,
                                        by = dplyr::group_vars(data),
                                        statistic = everything() ~ c("n", "N", "p"),
                                        denominator = NULL,
                                        fmt_fun = NULL,
                                        stat_label = everything() ~ default_stat_labels(),
                                        id = NULL,
                                        fmt_fn = deprecated(),
                                        ...) {
  set_cli_abort_call()
  check_dots_used()

  # deprecated args ------------------------------------------------------------
  if (lifecycle::is_present(fmt_fn)) {
    lifecycle::deprecate_warn(
      when = "0.6.1",
      what = "ard_hierarchical(fmt_fn)",
      with = "ard_hierarchical(fmt_fun)"
    )
    fmt_fun <- fmt_fn
  }

  # check inputs ---------------------------------------------------------------
  check_not_missing(variables)

  # process arguments ----------------------------------------------------------
  process_selectors(
    data,
    variables = {{ variables }},
    by = {{ by }},
    id = {{ id }}
  )
  data <- dplyr::ungroup(data)

  if (!is_empty(id) && vctrs::vec_duplicate_any(data[c(id, by, variables)])) {
    cli::cli_warn(c(
      "Duplicate rows found in data for the {.val {id}} column{?s}.",
      "i" = "Percentages/Denominators are not correct."
    ))
  }

  # return empty ARD if no variables selected ----------------------------------
  if (is_empty(variables)) {
    return(dplyr::tibble() |> as_card(check = FALSE))
  }

  # if denominator doesn't have all by, they need to be added ------------------
  if (
    !is.null(denominator) &&
      is.data.frame(denominator) &&
      !all(by %in% names(denominator))
  ) {
    by_vars_not_present <- by |> setdiff(names(denominator))
    denominator <-
      data |>
      dplyr::select(all_of(by_vars_not_present)) |>
      dplyr::distinct() |>
      dplyr::mutate(
        ...ard_data_column... = list(denominator)
      ) |>
      tidyr::unnest(cols = "...ard_data_column...")
  }

  # add dummy variable for counting --------------------------------------------
  data[["...ard_dummy_for_counting..."]] <- 1L

  # perform tabulations --------------------------------------------------------
  df_result <-
    ard_tabulate(
      data = data,
      variables = "...ard_dummy_for_counting...",
      by = all_of(by),
      strata = all_of(variables),
      statistic = statistic,
      denominator = denominator,
      fmt_fun = fmt_fun,
      stat_label = stat_label
    )

  # renaming columns -----------------------------------------------------------
  df_result <- .rename_last_group_as_variable(
    df_result,
    by = by,
    variables = variables
  )

  # return ard -----------------------------------------------------------------
  ard_final <- df_result |>
    dplyr::mutate(context = "hierarchical")

  # append attributes ----------------------------------------------------------
  attr(ard_final, "args") <- list(
    variables = variables,
    by = by
  )

  ard_final
}

#' @rdname ard_hierarchical
#' @export
ard_hierarchical_count.data.frame <- function(data,
                                              variables,
                                              by = dplyr::group_vars(data),
                                              fmt_fun = NULL,
                                              stat_label = everything() ~ default_stat_labels(),
                                              fmt_fn = deprecated(),
                                              ...) {
  set_cli_abort_call()
  check_dots_used()

  # deprecated args ------------------------------------------------------------
  if (lifecycle::is_present(fmt_fn)) {
    lifecycle::deprecate_warn(
      when = "0.6.1",
      what = "ard_hierarchical_count(fmt_fn)",
      with = "ard_hierarchical_count(fmt_fun)"
    )
    fmt_fun <- fmt_fn
  }

  # check inputs ---------------------------------------------------------------
  check_not_missing(variables)

  # process arguments ----------------------------------------------------------
  process_selectors(data, variables = {{ variables }}, by = {{ by }})

  # return empty ARD if no variables selected ----------------------------------
  if (is_empty(variables)) {
    return(dplyr::tibble() |> as_card(check = FALSE))
  }

  # add dummy variable for counting --------------------------------------------
  data[["...ard_dummy_for_counting..."]] <- 1L

  # perform tabulations --------------------------------------------------------
  ard_final <- ard_tabulate(
    data = data,
    variables = "...ard_dummy_for_counting...",
    by = all_of(by),
    strata = all_of(variables),
    statistic = everything() ~ "n",
    fmt_fun = fmt_fun,
    stat_label = stat_label
  ) |>
    .rename_last_group_as_variable(by = by, variables = variables) |>
    dplyr::mutate(context = "hierarchical_count") |>
    as_card(check = FALSE)

  # append attributes ----------------------------------------------------------
  attr(ard_final, "args") <- list(
    variables = variables,
    by = by
  )

  ard_final
}

#' Rename Last Group to Variable
#'
#' In the `ard_hierarchical*()` functions, the last grouping variable is
#' renamed to `variable` and `variable_level` before being returned.
#'
#' @param df_result (`data.frame`)\cr
#'   an ARD data frame of class 'card'
#'
#' @return an ARD data frame of class 'card'
#' @keywords internal
#'
#' @examples
#' data <- data.frame(x = 1, y = 2, group1 = 3, group2 = 4)
#'
#' cards:::.rename_last_group_as_variable(data, by = "ARM", variables = "AESOC")
.rename_last_group_as_variable <- function(df_result, by, variables) {
  df_result |>
    dplyr::select(-all_ard_variables()) |>
    dplyr::rename(
      variable = all_ard_group_n(n = length(c(by, variables)), types = "names"),
      variable_level = all_ard_group_n(
        n = length(c(by, variables)),
        types = "levels"
      )
    )
}

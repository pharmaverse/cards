#' Stacked Hierarchical ARD Statistics
#'
#' @description
#' Use these functions to calculate multiple summaries of nested or hierarchical data
#' in a single call.
#'
#' - `ard_stack_hierarchical()`: Calculates *rates* of events (e.g. adverse events)
#'   utilizing the `denominator` and `id` arguments to identify the rows in `data`
#'   to include in each rate calculation.
#'
#' - `ard_stack_hierarchical_count()`: Calculates *counts* of events utilizing
#'   all rows for each tabulation.
#'
#' @section Subsetting Data for Rate Calculations:
#'
#' To calculate event rates, the `ard_stack_hierarchical()` function identifies
#' rows to include in the calculation.
#' First, the primary data frame is sorted by the columns identified in
#' the `id`, `by`, and `variables` arguments.
#'
#' As the function cycles over the variables specified in the `variables` argument,
#' the data frame is grouped by `id`, `intersect(by, names(denominator))`, and `variables`
#' utilizing the last row within each of the groups.
#'
#' For example, if the call is
#' `ard_stack_hierarchical(data = ADAE, variables = c(AESOC, AEDECOD), id = USUBJID)`,
#' then we'd first subset ADAE to be one row within the grouping `c(USUBJID, AESOC, AEDECOD)`
#' to calculate the event rates in `'AEDECOD'`. We'd then repeat and
#' subset ADAE to be one row within the grouping `c(USUBJID, AESOC)`
#' to calculate the event rates in `'AESOC'`.
#'
#' @section Overall Argument:
#' When we set `overall=TRUE`, we wish to re-run our calculations removing the
#' stratifying columns. For example, if we ran the code below, we results would
#' include results with the code chunk being re-run with `by=NULL`.
#'
#' ```r
#' ard_stack_hierarchical(
#'   data = ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL,
#'   id = USUBJID,
#'   overall = TRUE
#' )
#' ```
#'
#' But there is another case to be aware of: when the `by` argument includes
#' columns that are not present in the `denominator`, for example when tabulating
#' results by AE grade or severity in addition to treatment assignment.
#' In the example below, we're tabulating results by treatment assignment and
#' AE severity. By specifying `overall=TRUE`, we will re-run the to get
#' results with `by = AESEV` and again with `by = NULL`.
#'
#' ```r
#' ard_stack_hierarchical(
#'   data = ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = c(TRTA, AESEV),
#'   denominator = ADSL,
#'   id = USUBJID,
#'   overall = TRUE
#' )
#' ```
#'
#' @inheritParams ard_hierarchical
#' @inheritParams ard_stack
#' @param variables ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   Specifies the nested/hierarchical structure of the data.
#'   The variables that are specified here and in the `include` argument
#'   will have summary statistics calculated.
#' @param id ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   argument used to subset `data` to identify rows in `data` to calculate
#'   event rates in `ard_stack_hierarchical()`. See details below.
#' @param denominator (`data.frame`, `integer`)\cr
#'   used to define the denominator and enhance the output.
#'   The argument is required for `ard_stack_hierarchical()` and optional
#'   for `ard_stack_hierarchical_count()`.
#'   - the univariate tabulations of the `by` variables are calculated with `denominator`,
#'     when a data frame is passed, e.g. tabulation of the treatment assignment
#'     counts that may appear in the header of a table.
#'   - the `denominator` argument must be specified when `id` is used to
#'     calculate the event rates.
#'   - if `total_n=TRUE`, the `denominator` argument is used to return the total N
#' @param include ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   Specify the subset a columns indicated in the `variables` argument for which
#'   summary statistics will be returned. Default is `everything()`.
#' @param overall (scalar `logical`)\cr logical indicating whether overall statistics
#'   should be calculated (i.e. repeat the operations with `by=NULL` in _most cases_, see below for details).
#'   Default is `FALSE`.
#' @param over_variables (scalar `logical`)\cr
#' logical indicating whether summary statistics
#'   should be calculated over or across the columns listed in the `variables` argument.
#'   Default is `FALSE`.
#' @param attributes (scalar `logical`)\cr
#'   logical indicating whether to include the results of `ard_attributes()` for all
#'   variables represented in the ARD. Default is `FALSE`.
#' @param total_n (scalar `logical`)\cr
#'   logical indicating whether to include of `ard_total_n(denominator)` in the returned ARD.
#' @param shuffle `r lifecycle::badge("deprecated")` support for `.shuffle = TRUE`
#'   has been removed.
#' @param by_stats (`logical`)\cr
#'   logical indicating whether to include overall stats of the `by` variables in the returned ARD.
#'
#' @return an ARD data frame of class 'card'
#' @name ard_stack_hierarchical
#'
#' @examples
#' ard_stack_hierarchical(
#'   ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL,
#'   id = USUBJID
#' )
#'
#' ard_stack_hierarchical_count(
#'   ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL
#' )
NULL

#' @rdname ard_stack_hierarchical
#' @export
ard_stack_hierarchical <- function(
  data,
  variables,
  by = dplyr::group_vars(data),
  id,
  denominator,
  include = everything(),
  statistic = everything() ~ c("n", "N", "p"),
  overall = FALSE,
  over_variables = FALSE,
  attributes = FALSE,
  total_n = FALSE,
  shuffle = FALSE,
  by_stats = TRUE
) {
  set_cli_abort_call()

  # check inputs ---------------------------------------------------------------
  check_not_missing(variables)
  check_not_missing(id)
  check_not_missing(denominator)
  cards::process_selectors(data, id = {{ id }})

  # denominator must a data frame, or integer
  if (!is.data.frame(denominator) && !is_integerish(denominator)) {
    cli::cli_abort(
      "The {.arg denominator} argument must be a {.cls data.frame} or an {.cls integer}, not {.obj_type_friendly {denominator}}.",
      call = get_cli_abort_call()
    )
  }

  # check the id argument is not empty
  if (is_empty(id)) {
    cli::cli_abort(
      "Argument {.arg id} cannot be empty.",
      call = get_cli_abort_call()
    )
  }

  # create ARD -----------------------------------------------------------------
  internal_stack_hierarchical(
    data = data,
    variables = {{ variables }},
    by = {{ by }},
    id = {{ id }},
    denominator = denominator,
    include = {{ include }},
    statistic = statistic,
    overall = overall,
    over_variables = over_variables,
    attributes = attributes,
    total_n = total_n,
    shuffle = shuffle,
    by_stats = by_stats
  )
}

#' @rdname ard_stack_hierarchical
#' @export
ard_stack_hierarchical_count <- function(
  data,
  variables,
  by = dplyr::group_vars(data),
  denominator = NULL,
  include = everything(),
  overall = FALSE,
  over_variables = FALSE,
  attributes = FALSE,
  total_n = FALSE,
  shuffle = FALSE,
  by_stats = TRUE
) {
  set_cli_abort_call()

  # check inputs ---------------------------------------------------------------
  check_not_missing(variables)
  # denominator must be empty, a data frame, or integer
  if (
    !is_empty(denominator) &&
      !is.data.frame(denominator) &&
      !is_integerish(denominator)
  ) {
    cli::cli_abort(
      "The {.arg denominator} argument must be empty, a {.cls data.frame}, or an {.cls integer}, not {.obj_type_friendly {denominator}}.",
      call = get_cli_abort_call()
    )
  }

  # create ARD -----------------------------------------------------------------
  internal_stack_hierarchical(
    data = data,
    variables = {{ variables }},
    by = {{ by }},
    id = NULL,
    denominator = denominator,
    include = {{ include }},
    statistic = NULL,
    overall = overall,
    over_variables = over_variables,
    attributes = attributes,
    total_n = total_n,
    shuffle = shuffle,
    by_stats = by_stats
  )
}

internal_stack_hierarchical <- function(
  data,
  variables,
  by = dplyr::group_vars(data),
  id = NULL,
  denominator = NULL,
  include = everything(),
  statistic = NULL,
  overall = FALSE,
  over_variables = FALSE,
  attributes = FALSE,
  total_n = FALSE,
  shuffle = FALSE,
  by_stats = TRUE
) {
  # process inputs -------------------------------------------------------------
  check_not_missing(data)
  check_not_missing(variables)
  cards::process_selectors(
    data,
    variables = {{ variables }},
    id = {{ id }},
    by = {{ by }}
  )
  cards::process_selectors(data[variables], include = {{ include }})
  check_scalar_logical(overall)
  check_scalar_logical(over_variables)
  check_scalar_logical(attributes)
  check_scalar_logical(total_n)
  check_scalar_logical(shuffle)
  check_scalar_logical(by_stats)

  # check inputs ---------------------------------------------------------------
  # both variables and include must be specified
  if (is_empty(variables) || is_empty(include)) {
    cli::cli_abort(
      "Arguments {.arg variables} and {.arg include} cannot be empty.",
      call = get_cli_abort_call()
    )
  }

  # the last `variables` variable should be included
  if (!utils::tail(variables, 1L) %in% include) {
    cli::cli_abort(
      "The last column specified in the {.arg variables} (i.e. {.val {utils::tail(variables, 1L)}}) must be in the {.arg include} argument.",
      call = get_cli_abort_call()
    )
  }

  if (is_empty(by) && isTRUE(overall)) {
    cli::cli_inform(
      c(
        "The {.arg by} argument must be specified when using {.code overall=TRUE}.",
        i = "Setting {.code overall=FALSE}."
      )
    )
    overall <- FALSE
  }

  if (!is.data.frame(denominator) && isTRUE(overall)) {
    cli::cli_inform(
      c(
        "The {.arg denominator} argument must be specified as a data frame when using {.code overall=TRUE}.",
        i = "Setting {.code overall=FALSE}."
      )
    )
    overall <- FALSE
  }

  if (is_empty(denominator) && isTRUE(total_n)) {
    cli::cli_inform(
      c(
        "The {.arg denominator} argument must be specified when using {.code total_n=TRUE}.",
        i = "Setting {.code total_n=FALSE}."
      )
    )
    total_n <- FALSE
  }

  # drop missing values --------------------------------------------------------
  # is.na() is TRUE for NaN, so a separate is.nan() scan is unnecessary
  df_na_nan <- is.na(data[c(by, variables)])
  if (any(df_na_nan)) {
    rows_with_na <- rowSums(df_na_nan) > 0L
    cli::cli_inform(c(
      "*" = "Removing {.val {sum(rows_with_na)}} row{?s} from {.arg data} with
                            {.val {NA}} or {.val {NaN}} values in {.val {c(by, variables)}} column{?s}."
    ))
    data <- data[!rows_with_na, ]
  }

  # remove missing by variables from `denominator`
  if (
    is.data.frame(denominator) && !is_empty(intersect(by, names(denominator)))
  ) {
    df_na_nan_denom <-
      is.na(denominator[intersect(by, names(denominator))])
    if (any(df_na_nan_denom)) {
      rows_with_na_denom <- rowSums(df_na_nan_denom) > 0L
      cli::cli_inform(c(
        "*" = "Removing {.val {sum(rows_with_na_denom)}} row{?s} from {.arg denominator} with
                            {.val {NA}} or {.val {NaN}} values in {.val {intersect(by, names(denominator))}} column{?s}."
      ))
      denominator <- denominator[!rows_with_na_denom, ]
    }
  }

  # keep only `id` and `by` variables in `denominator`
  if (is.data.frame(denominator)) {
    denominator <- denominator[, intersect(c(id, by), names(denominator)), drop = FALSE]
  }

  # sort data if using `ard_hierarchical(id)` ----------------------------------
  if (!is_empty(id)) {
    data <- dplyr::arrange(data, dplyr::pick(all_of(c(id, by, variables))))
  } # styler: off

  # print denom columns if not 100% clear which are used
  if (!is_empty(id) && is.data.frame(denominator)) {
    denom_cols <- intersect(by, names(denominator))
    if (!setequal(by, denom_cols)) {
      msg <-
        ifelse(
          is_empty(denom_cols),
          "Denominator set by number of rows in {.arg denominator} data frame.",
          "Denominator set by {.val {denom_cols}} column{?s} in {.arg denominator} data frame."
        )
      cli::cli_inform(c("i" = msg))
    }
  }

  # go about calculating the statistics within the variables -------------------
  # define index in `variables` that also appear in `include`
  which_include <- which(variables %in% include)

  lst_results <- list()
  for (i in which_include) {
    lst_results <-
      lst_results |>
      append(
        .run_hierarchical_fun(
          data = data,
          variables = variables[seq_len(i)],
          by = by,
          denominator = denominator,
          id = id,
          statistic = statistic
        ) |>
          list()
      )
  }

  # calculate results overall if requested -------------------------------------
  if (isTRUE(overall)) {
    for (i in which_include) {
      lst_results <-
        lst_results |>
        append(
          .run_hierarchical_fun(
            data = data,
            variables = variables[seq_len(i)],
            by = setdiff(by, names(denominator)),
            denominator = denominator,
            id = id,
            statistic = statistic
          ) |>
            list()
        )

      # if there are columns in `by` not present in `denominator`, re-run with `by = NULL`
      if (!is_empty(setdiff(by, names(denominator)))) {
        lst_results <-
          lst_results |>
          append(
            .run_hierarchical_fun(
              data = data,
              variables = variables[seq_len(i)],
              by = NULL,
              denominator = denominator,
              id = id,
              statistic = statistic
            ) |>
              list()
          )
      }
    }
  }

  # add univariate tabulations of by variables ---------------------------------
  if (
    isTRUE(by_stats) &&
      is.data.frame(denominator) &&
      !is_empty(intersect(by, names(denominator)))
  ) {
    lst_results <-
      lst_results |>
      append(
        ard_tabulate(
          data = denominator,
          variables = all_of(intersect(by, names(denominator)))
        ) |>
          list()
      )
  }

  # add overall row if requested -----------------------------------------------
  if (isTRUE(over_variables)) {
    lst_results <-
      lst_results |>
      append(
        # need to use this call to also re-run for `overall=TRUE` when specified
        rlang::call2(
          "internal_stack_hierarchical",
          data = expr(
            data |> dplyr::mutate(..ard_hierarchical_overall.. = TRUE)
          ),
          variables = "..ard_hierarchical_overall..",
          by = by,
          id = id,
          include = "..ard_hierarchical_overall..",
          denominator = expr(denominator),
          statistic = statistic,
          overall = overall,
          over_variables = FALSE,
          attributes = FALSE,
          total_n = FALSE,
          shuffle = FALSE,
          by_stats = FALSE
        ) %>%
          {
            suppressMessages(eval_tidy(.))
          } |> # styler: off
          list()
      )
  }

  # add attributes if requested ------------------------------------------------
  if (isTRUE(attributes)) {
    lst_results <-
      lst_results |>
      append(
        ard_attributes(dplyr::select(data, any_of(c(by, variables)))) |>
          list()
      )
  }

  # add total n if requested ---------------------------------------------------
  if (isTRUE(total_n) && is.data.frame(denominator)) {
    lst_results <-
      lst_results |>
      append(ard_total_n(denominator) |> list())
  } else if (isTRUE(total_n) && is_integerish(denominator)) {
    lst_results <-
      lst_results |>
      append(
        ard_total_n(data) |>
          dplyr::mutate(stat = list(as.integer(denominator))) |>
          list()
      )
  }

  # combine results ------------------------------------------------------------
  result <- lst_results |>
    dplyr::bind_rows() |>
    cards::tidy_ard_column_order() |>
    cards::tidy_ard_row_order() %>%
    structure(., class = c(ifelse(is_empty(id), "ard_stack_hierarchical_count", "ard_stack_hierarchical"), class(.)))

  # append attributes used for sorting/filtering -------------------------------
  attr(result, "args") <- list(
    by = by,
    variables = variables,
    include = include
  )

  # sort ARD alphanumerically --------------------------------------------------
  result <- result |> sort_ard_hierarchical(sort = "alphanumeric")

  # shuffle if requested -------------------------------------------------------
  if (isTRUE(shuffle)) {
    lifecycle::deprecate_stop(
      when = "0.7.0",
      what = "cards::ard_stack_hierarchical(shuffle)"
    )
  }

  # return final result --------------------------------------------------------
  result |>
    as_card(check = FALSE)
}

# this function calculates either the counts or the rates of the events
.run_hierarchical_fun <- function(
  data,
  variables,
  by,
  denominator,
  id,
  statistic
) {
  if (is_empty(id)) {
    ard_hierarchical_count(
      data = data,
      variables = all_of(variables),
      by = all_of(by)
    )
  } else {
    # keep the last row per `c(id, by-in-denom, variables)` group, in data order
    # (equivalent to dplyr::slice_tail(n = 1L, by = ...), but avoids the
    # per-group R-level slicing that dominates the runtime on large data)
    slice_keys <- c(id, intersect(by, names(denominator)), variables)
    keep_last <- !duplicated(vctrs::vec_group_id(data[slice_keys]), fromLast = TRUE)
    ard_hierarchical(
      data = vctrs::vec_slice(data, keep_last),
      variables = all_of(variables),
      by = all_of(by),
      denominator = denominator,
      id = all_of(id),
      statistic = statistic
    )
  }
}

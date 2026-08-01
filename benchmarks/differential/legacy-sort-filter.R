# AUTO-GENERATED verbatim copy of sort_ard_hierarchical() + filter_ard_hierarchical()
# and their internal helpers, captured from the pre-rewrite commit for the #176
# differential harness. DO NOT EDIT — regenerate from the pristine sources if the
# baseline moves. Sourced into an env whose parent is asNamespace('cards').

#' Sort Stacked Hierarchical ARDs
#'
#' @description `r lifecycle::badge('experimental')`\cr
#'
#' This function is used to sort stacked hierarchical ARDs.
#'
#' For the purposes of this function, we define a "variable group" as a combination of ARD rows grouped by the
#' combination of all their variable levels, but excluding any `by` variables.
#'
#' @param x (`card`)\cr
#'   a stacked hierarchical ARD of class `'card'` created using [ard_stack_hierarchical()] or
#'   [`ard_stack_hierarchical_count()`].
#' @param sort ([`formula-list-selector`][syntax], `string`)\cr
#'   a named list, a list of formulas, a single formula where the list element is a named list of functions
#'   (or the RHS of a formula), or a single string specifying the types of sorting to perform at each hierarchy variable
#'   level. If the sort method for any variable is not specified then the method will default to `"descending"`. If a
#'   single unnamed string is supplied it is applied to all variables. For each variable, the value specified must
#'   be one of:
#'   - `"alphanumeric"` - at the specified hierarchy level of the ARD, groups are ordered alphanumerically
#'     (i.e. A to Z) by `variable_level` text.
#'   - `"descending"` - within each variable group of the ARD at the specified hierarchy level, count sums are
#'     calculated for each group and groups are sorted in descending order by sum. When `sort` is `"descending"` for a
#'     given variable and `n` is included in `statistic` for the variable then `n` is used to calculate variable group
#'     sums, otherwise `p` is used. If neither `n` nor `p` are present in `x` for the variable, an error will occur.
#'
#'   Defaults to `everything() ~ "descending"`.
#'
#' @return an ARD data frame of class 'card'
#' @seealso [filter_ard_hierarchical()]
#' @name sort_ard_hierarchical
#'
#' @note
#' If overall data is present in `x` (i.e. the ARD was created with `ard_stack_hierarchical(overall=TRUE)`), the
#' overall data will be sorted last within each variable group (i.e. after any other rows with the same combination of
#' variable levels).
#'
#' @examplesIf (identical(Sys.getenv("NOT_CRAN"), "true") || identical(Sys.getenv("IN_PKGDOWN"), "true"))
#' ard_stack_hierarchical(
#'   ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL,
#'   id = USUBJID
#' ) |>
#'   sort_ard_hierarchical(AESOC ~ "alphanumeric")
#'
#' ard_stack_hierarchical_count(
#'   ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL
#' ) |>
#'   sort_ard_hierarchical(sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"))
NULL

#' @rdname sort_ard_hierarchical
#' @export
sort_ard_hierarchical <- function(x, sort = everything() ~ "descending") {
  set_cli_abort_call()

  # check and process inputs ---------------------------------------------------------------------
  check_not_missing(x)
  check_not_missing(sort)
  check_class(x, "card")

  if (!any(c("ard_stack_hierarchical", "ard_stack_hierarchical_count") %in% class(x))) {
    cli::cli_warn(
      c("The {.fun sort_ard_hierarchical} function was created for stacked hierarchical ARDs created using
         {.fun ard_stack_hierarchical} or {.fun ard_stack_hierarchical_count}.",
        "i" = "Unexpected results may occur."
      )
    )
  }

  if (all(x$variable %in% "..ard_hierarchical_overall..")) {
    return(x)
  }

  ard_args <- attributes(x)$args

  # for calculations by highest severity, innermost variable is extracted from `by`
  if (length(ard_args$by) > 1) {
    ard_args$variables <- c(ard_args$variables, dplyr::last(ard_args$by))
    ard_args$include <- c(ard_args$include, dplyr::last(ard_args$by))
    ard_args$by <- ard_args$by[-length(ard_args$by)]
  }

  # get and check sorting method(s)
  if (is.character(sort)) {
    sort <- stats::as.formula(paste0("everything() ~ '", sort, "'"))
  }
  process_formula_selectors(
    as.list(ard_args$variables) |> data.frame() |> stats::setNames(ard_args$variables),
    sort = sort
  )
  fill_formula_selectors(
    as.list(ard_args$variables) |> data.frame() |> stats::setNames(ard_args$variables),
    sort = everything() ~ "descending"
  )
  check_list_elements(
    x = sort,
    predicate = \(x) x %in% c("descending", "alphanumeric"),
    error_msg = "Sorting type must be either {.val descending} or {.val alphanumeric} for all variables."
  )

  by <- ard_args$by
  cols <-
    ard_args$variables |>
    stats::setNames(
      x |>
        dplyr::select(all_ard_group_n(seq_along(ard_args$variables) + length(by), types = "names"), "variable") |>
        names()
    )

  # attributes and total n not sorted - appended to bottom of sorted ARD
  has_attr <- "attributes" %in% x$context | "total_n" %in% x$context
  if (has_attr) {
    x_attr <- x |>
      dplyr::filter(.data$context %in% c("attributes", "total_n"))
    x <- x |>
      dplyr::filter(!.data$context %in% c("attributes", "total_n"))
  }

  # header row info not sorted - appended to top of sorted ARD
  has_hdr <- !is_empty(by) | "..ard_hierarchical_overall.." %in% x$variable
  if (has_hdr) {
    x_header <- x |>
      dplyr::filter(.data$variable %in% c(by, "..ard_hierarchical_overall..")) |>
      # header statistic rows above "..ard_hierarchical_overall.." rows
      dplyr::arrange(dplyr::desc(.data$variable))
    x <- x |>
      dplyr::filter(!.data$variable %in% c(by, "..ard_hierarchical_overall.."))
  }

  # reformat ARD for sorting ---------------------------------------------------------------------
  x_sort <- x |>
    # for sorting, assign indices to each row in original order
    dplyr::mutate(idx = dplyr::row_number())

  # reformat current variable columns for sorting
  x_sort <- x_sort |>
    .ard_reformat_sort(by, cols)

  for (i in seq_along(cols)) {
    sort_i <- sort[[cols[i]]] # current sorting type
    cur_var <- names(cols)[i] # current grouping variable

    x_sort <- x_sort |>
      # group by current and all previous grouping columns
      dplyr::group_by(dplyr::pick(
        any_of(cards::all_ard_group_n(seq_len(i) + length(by))),
        any_of(c(cur_var, paste0(cur_var, "_level")))
      ))

    if (sort_i == "descending") {
      # descending sort
      x_sort <- x_sort |>
        # calculate sums for each group at the current level, then get group indices
        .append_hierarchy_sums(ard_args, cols, i)
    } else {
      # alphanumeric sort
      x_sort <- x_sort |>
        # sort grouping variables in alphanumeric order
        dplyr::arrange(.by_group = TRUE) |>
        # append group indices
        dplyr::mutate(!!paste0("sort_group_", i) := dplyr::cur_group_id())
    }
  }

  idx_sorted <- x_sort |>
    dplyr::ungroup() |>
    # sort according to determined orders at each hierarchy level
    dplyr::arrange(dplyr::pick(starts_with("sort_group_"))) |>
    # pull ordered row indices
    dplyr::pull("idx")

  # sort ARD
  x <- x[idx_sorted, ]

  # if present, keep header info at top of ARD
  if (has_hdr) x <- dplyr::bind_rows(x_header, x)

  # if present, keep attributes at bottom of ARD
  if (has_attr) x <- dplyr::bind_rows(x, x_attr)

  x
}

# this function reformats a hierarchical ARD for sorting
.ard_reformat_sort <- function(x, by, cols) {
  for (i in seq_along(cols)) {
    # get current grouping variables
    cur_var <- names(cols)[i]
    cur_var_lvl <- paste0(cur_var, "_level")

    # outer hierarchy variables - process summary rows
    if (!cur_var %in% "variable") {
      x[x$variable %in% cols[i], ] <-
        x[x$variable %in% cols[i], ] |>
        dplyr::mutate(
          # move variable/level names to correct grouping variable columns
          !!cur_var := .data$variable,
          !!cur_var_lvl := as.list(.data$variable_level),
          # mark rows as overall summary data
          variable = "..overall..",
          variable_level = as.list(NA_character_)
        )
    }

    # overall=TRUE - process summary rows (no `by` variable)
    if (!is_empty(by) & !cur_var %in% "variable" & any(x[[paste0("group", i)]] %in% cols[i])) {
      next_var_gp <- paste0("group", i + length(by) + 1) %in% names(x)
      x[x[[paste0("group", i)]] %in% cols[i], ] <-
        x[x[[paste0("group", i)]] %in% cols[i], ] |>
        dplyr::mutate(
          # shift variable/level names one to the right
          !!paste0("group", i + length(by) + 1) := if (next_var_gp) .data[[cur_var]] else NULL,
          !!paste0("group", i + length(by) + 1, "_level") := if (next_var_gp) as.list(.data[[cur_var_lvl]]) else NULL,
          !!cur_var := .data[[paste0("group", i)]],
          !!cur_var_lvl := as.list(.data[[paste0("group", i, "_level")]])
        )
    }

    # previous hierarchy variables - process summary rows
    if (any(is.na(x[[cur_var]]))) {
      x[is.na(x[[cur_var]]), ] <-
        x[is.na(x[[cur_var]]), ] |>
        dplyr::mutate(
          # mark summary rows from previous variables as "empty" for the current
          # to sort them prior to non-summary rows in the same section
          !!cur_var :=
            dplyr::case_when(
              .data$variable %in% "..overall.." ~ "..empty..",
              .default = NA
            ),
          !!cur_var_lvl := as.list(NA)
        )
    }

    # unlist cur_var_lvl column (vectorized equivalent of the rowwise unlist)
    x[[cur_var_lvl]] <-
      vapply(x[[cur_var_lvl]], function(.x) as.character(unlist(.x)), character(1L))
  }

  x
}

# this function calculates and appends group sums/ordering for the current hierarchy level (across `by` variables)
.append_hierarchy_sums <- function(x, ard_args, cols, i) {
  cur_var <- names(cols)[i] # get current grouping variable
  next_var <- names(cols)[i + 1] # get next grouping variable

  # all variables in x have n or p stat present (not required if filtered out first)
  n_stat <- is_empty(setdiff(
    intersect(ard_args$include, x$variable),
    x |> dplyr::filter(.data$stat_name == "n") |> dplyr::pull("variable")
  ))
  if (!n_stat) {
    p_stat <- is_empty(setdiff(
      intersect(ard_args$include, x$variable),
      x |> dplyr::filter(.data$stat_name == "p") |> dplyr::pull("variable")
    ))
    if (!p_stat) { # p statistic is also not available
      cli::cli_abort(
        paste(
          "If {.code sort='descending'} for any variables then either {.val n} or {.val p} must be present in {.arg x}",
          "for each of these specified variables in order to calculate the count sums used for sorting."
        ),
        call = get_cli_abort_call()
      )
    }
  }
  sort_stat <- if (n_stat) "n" else "p" # statistic used to calculate group sums

  # calculate group sums
  sum_i <- paste0("sum_group_", i) # sum column label
  x_sums <- x |>
    dplyr::filter(
      .data$stat_name == sort_stat, # select statistic to sum
      if (!is_empty(ard_args$by)) .data$group1 %in% ard_args$by else TRUE,
      if (length(c(ard_args$by, ard_args$variables)) > 1) {
        if (ard_args$variables[i] %in% ard_args$include & !cur_var %in% "variable") {
          # if current variable is in include, sum *only* summary rows for the current variable
          .data$variable %in% "..overall.." &
            if (!next_var %in% "variable") .data[[next_var]] %in% "..empty.." else TRUE
        } else {
          # otherwise, sum all *innermost* rows for the current variable
          TRUE
        }
      } else {
        TRUE
      }
    ) |>
    # get sum in each group
    dplyr::summarize(!!sum_i := sum(unlist(.data$stat[.data$stat_name == sort_stat]))) |>
    dplyr::ungroup()

  sort_cols <- append(dplyr::group_vars(x), sum_i, after = length(dplyr::group_vars(x)) - 1) # sorting columns
  x_sums <- x_sums |>
    # sort group sums in descending order, grouping variables in alphanumeric order
    dplyr::arrange(across(all_of(sort_cols), \(x) if (is.numeric(x)) dplyr::desc(x) else x)) |>
    # record order of groups
    dplyr::mutate(!!paste0("sort_group_", i) := dplyr::row_number())

  # append corresponding group order index to each row
  x |>
    dplyr::left_join(x_sums, by = dplyr::group_vars(x))
}

#' Filter Stacked Hierarchical ARDs
#'
#' @description `r lifecycle::badge('experimental')`\cr
#'
#' This function is used to filter stacked hierarchical ARDs.
#'
#' For the purposes of this function, we define a "variable group" as a combination of ARD rows
#' grouped by the combination of all their variable levels, but excluding any `by` variables.
#'
#' @param x (`card`)\cr
#'   a stacked hierarchical ARD of class `'card'` created using [`ard_stack_hierarchical()`] or
#'   [`ard_stack_hierarchical_count()`].
#' @param filter (`expression`)\cr
#'   an expression that is used to filter variable groups of the hierarchical ARD. See the
#'   Details section below.
#' @param var ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   hierarchy variable from `x` to perform filtering on. If `NULL`, the last hierarchy variable
#'   from `x` (`dplyr::last(attributes(x)$args$variables)`) will be used.
#' @param keep_empty (scalar `logical`)\cr
#'   Logical argument indicating whether to retain summary rows corresponding to hierarchy
#'   sections that have had all rows filtered out. Default is `FALSE`.
#' @param quiet (`logical`)\cr
#'   logical indicating whether to suppress any messaging. Default is `FALSE`.
#'
#' @details
#' The `filter` argument can be used to filter out variable groups of a hierarchical
#'   ARD which do not meet the requirements provided as an expression.
#' Variable groups can be filtered on the values of any of the possible
#'   statistics (`n`, `p`, and `N`) provided they are included at least once
#'   in the ARD, as well as the values of any `by` variables.
#'
#' Additionally, filters can be applied on individual levels of the `by` variable via the
#'   `n_XX`, `N_XX`, and `p_XX` statistics, where each `XX` represents the index of the `by`
#'   variable level to select the statistic from. For example, `filter = n_1 > 5` will check
#'   whether `n` values for the first level of `by` are greater than 5 in each row group.
#'
#' Overall statistics for each row group can be used in filters via the `n_overall`, `N_overall`,
#'   and `p_overall` statistics. If the ARD is created with parameter `overall=TRUE`, then these
#'   overall statistics will be extracted directly from the ARD, otherwise the statistics will be
#'   derived where possible. If `overall=FALSE`, then `n_overall` can only be derived if the `n`
#'   statistic is present in the ARD for the filter variable, `N_overall` if the `N` statistic is
#'   present for the filter variable, and `p_overall` if both the `n` and `N` statistics are
#'   present for the filter variable.
#'
#' By default, filters will be applied at the level of the innermost hierarchy variable, i.e.
#'   the last variable supplied to `variables`. If filters should instead be applied at the level
#'   of one of the outer hierarchy variables, the `var` parameter can be used to select a different
#'   variable to filter on. When `var` is set to a different (outer) variable and a level of the
#'   variable does not meet the filtering criteria then the section corresponding to that variable
#'   level and all sub-sections within that section will be removed.
#'
#' To illustrate how the function works, consider the typical example below
#'   where the AE summaries are provided by treatment group.
#'
#' ```r
#' ADAE |>
#'   dplyr::filter(AESOC == "GASTROINTESTINAL DISORDERS",
#'                 AEDECOD %in% c("VOMITING", "DIARRHOEA")) |>
#'   ard_stack_hierarchical(
#'     variables = c(AESOC, AEDECOD),
#'     by = TRTA,
#'     denominator = ADSL,
#'     id = USUBJID
#'   )
#' ```
#'
#' |**SOC** / AE                   |  Placebo  | Xanomeline High Dose  | Xanomeline Low Dose  |
#' |:------------------------------|----------:|----------------------:|---------------------:|
#' |__GASTROINTESTINAL DISORDERS__ | 11 (13%)  |             10 (12%)  |            8 (9.5%)  |
#' |DIARRHOEA                      |  9 (10%)  |             4 (4.8%)  |            5 (6.0%)  |
#' |VOMITING                       | 3 (3.5%)  |             7 (8.3%)  |            3 (3.6%)  |
#'
#' Filters are applied to the summary statistics of the innermost variable in the hierarchy by
#'   default---`AEDECOD` in this case. If we wanted to filter based on SOC rates instead of AE
#'   rates we could specify `var = AESOC` instead.
#' If any of the summary statistics meet the filter requirement for any of the treatment groups,
#'   the entire row is retained.
#' For example, if `filter = n >= 9` were passed, the criteria would be met for DIARRHOEA
#'   as the Placebo group observed 9 AEs and as a result the summary statistics for the other
#'   treatment groups would be retained as well.
#' Conversely, no treatment groups' summary statistics satisfy the filter requirement
#'   for VOMITING so all rows associated with this AE would be removed.
#'
#' In addition to filtering on individual statistic values, filters can be applied
#'   across the treatment groups (i.e. across all `by` variable values) by using
#'   aggregate functions such as `sum()` and `mean()`. For simplicity, it is suggested to use
#'   the `XX_overall` statistics in place of `sum(XX)` in equivalent scenarios. For example,
#'   `n_overall` is equivalent to `sum(n)`.
#' A value of `filter = sum(n) >= 18` (or `filter = n_overall >= 18`) retains AEs where the sum of
#'   the number of AEs across the treatment groups is greater than or equal to 18.
#'
#' If `filter = n_overall >= 18` and `var = AESOC` then all rows corresponding to an SOC with an
#'   overall rate less than 18 - including all AEs within that SOC - will be removed.
#'
#' If `ard_stack_hierarchical(overall=TRUE)` was run, the overall column is __not__ considered in
#'   any filtering except for `XX_overall` statistics, if specified.
#'
#' If `ard_stack_hierarchical(over_variables=TRUE)` was run, any overall statistics are kept regardless
#'   of filtering.
#'
#' Some examples of possible filters:
#' - `filter = n > 5`: keep AEs where one of the treatment groups observed more than 5 AEs
#' - `filter = n == 2 & p < 0.05`: keep AEs where one of the treatment groups observed exactly 2
#'    AEs _and_ one of the treatment groups observed a proportion less than 5%
#' - `filter = n_overall >= 4`: keep AEs where there were 4 or more AEs observed across the treatment groups
#' - `filter = mean(n) > 4 | n > 3`: keep AEs where the mean number of AEs is 4 or more across the
#'   treatment groups _or_ one of the treatment groups observed more than 3 AEs
#' - `filter = n_2 > 2`: keep AEs where the `"Xanomeline High Dose"` treatment group (second `by` variable
#'   level) observed more than 2 AEs
#'
#' @return an ARD data frame of class 'card'
#' @seealso [sort_ard_hierarchical()]
#' @name filter_ard_hierarchical
#'
#' @examplesIf (identical(Sys.getenv("NOT_CRAN"), "true") || identical(Sys.getenv("IN_PKGDOWN"), "true"))
#' # create a base AE ARD
#' ard <- ard_stack_hierarchical(
#'   ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL,
#'   id = USUBJID,
#'   overall = TRUE
#' )
#'
#' # Example 1 ----------------------------------
#' # Keep AEs from TRTA groups where more than 3 AEs are observed across the group
#' filter_ard_hierarchical(ard, sum(n) > 3)
#'
#' # Example 2 ----------------------------------
#' # Keep AEs where at least one level in the TRTA group has more than 3 AEs observed
#' filter_ard_hierarchical(ard, n > 3)
#'
#' # Example 3 ----------------------------------
#' # Keep AEs that have an overall prevalence of greater than 5%
#' filter_ard_hierarchical(ard, sum(n) / sum(N) > 0.05)
#'
#' # Example 4 ----------------------------------
#' # Keep AEs that have a difference in prevalence of greater than 3% between reference group with
#' # `TRTA = "Xanomeline High Dose"` and comparison group with `TRTA = "Xanomeline Low Dose"`
#' filter_ard_hierarchical(ard, abs(p_2 - p_3) > 0.03)
#'
#' # Example 5 ----------------------------------
#' # Keep AEs from SOCs that have an overall prevalence of greater than 20%
#' filter_ard_hierarchical(ard, p_overall > 0.20, var = AESOC)
NULL

#' @rdname filter_ard_hierarchical
#' @export
filter_ard_hierarchical <- function(x, filter, var = NULL, keep_empty = FALSE, quiet = FALSE) {
  set_cli_abort_call()

  # check and process inputs ---------------------------------------------------------------------
  check_not_missing(x)
  check_not_missing(filter)
  check_scalar_logical(keep_empty)
  check_scalar_logical(quiet)
  check_class(x, "card")
  if (!any(c("ard_stack_hierarchical", "ard_stack_hierarchical_count") %in% class(x))) {
    cli::cli_warn(
      c("The {.fun filter_ard_hierarchical} function was created for stacked hierarchical ARDs created using
         {.fun ard_stack_hierarchical} or {.fun ard_stack_hierarchical_count}.",
        "i" = "Unexpected results may occur."
      )
    )
  }

  ard_args <- attributes(x)$args
  by <- ard_args$by

  # get and check name of filtering variable
  process_selectors(
    as.list(ard_args$variables) |> data.frame() |> stats::setNames(ard_args$variables),
    var = {{ var }}
  )
  if (is_empty(var)) var <- dplyr::last(ard_args$variables)
  check_scalar(var, message = "Only one variable can be selected as {.arg var}.")
  if (!var %in% ard_args$include) {
    cli::cli_abort(
      paste(
        "No statistics available in the ARD for variable {.val {var}}. In order to filter on {.val {var}}",
        "it must be specified in the {.arg include} argument when the ARD is created."
      ),
      call = get_cli_abort_call()
    )
  }
  which_var <- which(ard_args$variables == var)

  # check filter input is valid
  filter <- enquo(filter)
  if (!quo_is_call(filter)) {
    cli::cli_abort(
      "The {.arg filter} argument must be an expression.",
      call = get_cli_abort_call()
    )
  }

  # attributes and total n not filtered - appended to bottom of filtered ARD
  has_attr <- "attributes" %in% x$context | "total_n" %in% x$context
  if (has_attr) {
    x_attr <- x |>
      dplyr::filter(.data$context %in% c("attributes", "total_n"))
    x <- x |>
      dplyr::filter(!.data$context %in% c("attributes", "total_n"))
  }

  # remove "overall" data from `x`
  if (is_empty(by)) {
    x_overall <- x
  } else {
    is_overall <- apply(x, 1, function(x) !isTRUE(any(x %in% by)))
    x_overall <- x[is_overall, ]
    x <- x[!is_overall, ]
  }
  no_overall <- nrow(x_overall) == 0

  # check that any column-wise/overall statistics in filter are valid
  filter_vars <- all.vars(filter)
  by_cols <- if (!is_empty(by)) c("group1", "group1_level") else NULL
  valid_filter_vars <- unique(x$stat_name[x$variable == var])
  if (!is_empty(by)) {
    by_lvls <- unique(stats::na.omit(unlist(x[["group1_level"]])))
    overall_stats <- if (!no_overall) {
      unique(x_overall$stat_name)
    } else if (no_overall && !all(c("n", "N") %in% valid_filter_vars)) {
      setdiff(valid_filter_vars, "p")
    } else {
      valid_filter_vars
    }
    overall_stat_vars <- if (!is_empty(overall_stats)) paste(overall_stats, "overall", sep = "_") else NULL
    col_stat_vars <- paste(rep(valid_filter_vars, each = length(by_lvls)), seq_along(by_lvls), sep = "_")
    valid_filter_vars <- c(valid_filter_vars, col_stat_vars, overall_stat_vars, by)
    if (any(col_stat_vars %in% filter_vars) && !quiet) {
      by_ids <- cli::cli_vec(
        paste(paste("xx", seq_along(by_lvls), sep = "_"), paste0('"', by_lvls, '"'), sep = " = ")
      )
      cli::cli_inform("When applying filters on specific levels of {.arg by} variable {.val {by}} {by_ids}.")
    }
  }
  if (!all(filter_vars %in% valid_filter_vars)) {
    var_miss <- setdiff(filter_vars, valid_filter_vars)
    cli::cli_abort(
      c(
        paste(
          "The expression provided as {.arg filter} includes condition{?s} for statistic{?s}",
          "{.val {var_miss}} which {?is/are} not present in the ARD and {?does/do} not",
          "correspond to any of the {.var by} variable levels."
        ),
        i = "Valid filter terms for variable {.val {var}} are: {.val {valid_filter_vars}}."
      ),
      call = get_cli_abort_call()
    )
  }

  # reshape ARD so each stat is in its own column ------------------------------------------------
  x_f <- x |>
    dplyr::mutate(idx = dplyr::row_number()) |>
    dplyr::select(
      all_ard_groups(),
      all_ard_variables(),
      "stat_name",
      "stat",
      "idx"
    ) |>
    tidyr::pivot_wider(
      id_cols = c(all_ard_groups(), all_ard_variables()),
      names_from = "stat_name",
      values_from = "stat",
      values_fn = unlist,
      unused_fn = list
    )

  # apply filter ---------------------------------------------------------------------------------
  f_idx <- x_f |>
    dplyr::group_by(across(c(
      all_ard_groups(),
      all_ard_variables(),
      -all_of(by_cols)
    ))) |>
    dplyr::group_map(\(.df, .g) {
      # only filter rows for variable `var`
      if (.g$variable == var) {
        .df_all <- .df
        # allow filtering on values from a specific column
        if (!is_empty(by)) {
          # use `by` variable name as `group1_level` column name
          names(.df_all)[names(.df_all) == by_cols[c(FALSE, TRUE)]] <- by

          # process any column-wise or overall filters present
          if (any(c(col_stat_vars, overall_stat_vars) %in% filter_vars)) {
            # if specified, add column-wise statistics to filter on
            .df_col_stats <- if (any(col_stat_vars %in% filter_vars)) {
              .df_all |>
                dplyr::mutate(id_num = dplyr::row_number()) |>
                tidyr::pivot_wider(
                  id_cols = c(all_ard_groups(), all_ard_variables()),
                  names_from = "id_num",
                  values_from = any_of(c("n", "N", "p"))
                )
            } else {
              dplyr::tibble(group1 = by)
            }

            # add overall stats - derive values if overall=FALSE
            if (!no_overall) {
              .df_overall <- .g |>
                as_card(check = FALSE) |>
                cards::rename_ard_groups_shift()
              .df_overall <- dplyr::left_join(.df_overall, x_overall, by = names(.df_overall))
            }
            if ("n_overall" %in% filter_vars) {
              .df_col_stats$n_overall <-
                if (!no_overall) .df_overall$stat[.df_overall$stat_name == "n"][[1]] else sum(.df[["n"]])
            }
            if ("N_overall" %in% filter_vars) {
              .df_col_stats$N_overall <-
                if (!no_overall) .df_overall$stat[.df_overall$stat_name == "N"][[1]] else sum(.df[["N"]])
            }
            if ("p_overall" %in% filter_vars) {
              .df_col_stats$p_overall <-
                if (!no_overall) {
                  .df_overall$stat[.df_overall$stat_name == "p"][[1]]
                } else {
                  sum(.df[["n"]]) / sum(.df[["N"]])
                }
            }
            .df_all <- dplyr::bind_rows(.df_all, .df_col_stats)
          }
        }

        # apply filter
        .df[["idx"]][any(eval_tidy(filter, data = .df_all), na.rm = TRUE)]
      } else {
        .df[["idx"]]
      }
    }) |>
    unlist() |>
    sort()
  x <- x[f_idx, ]

  # remove inner variable rows if `var` is an outer variable that does not meet the filter criteria
  if (which_var < length(ard_args$variables)) {
    var_gp_nm <- paste0("group", length(by) + which_var) # get `var` group variable name

    # get all combos of variables kept after filtering
    # keep only unique combos up to `var` group variable
    var_keep <- x |>
      dplyr::filter(.data$variable == var) |>
      dplyr::mutate(
        !!var_gp_nm := .data$variable,
        !!paste0(var_gp_nm, "_level") := .data$variable_level
      )
    var_keep <- dplyr::distinct(var_keep[(1 + length(by) * 2):((length(by) + which_var) * 2)])

    # track row indices
    x <- x |> dplyr::mutate(idx = dplyr::row_number())

    # get row indices to exclude - all rows within `var` sections that have been removed
    f_idx_inner <-
      dplyr::anti_join(
        x[x[[var_gp_nm]] == var & !is.na(x[[var_gp_nm]]), ],
        var_keep,
        by = names(var_keep)
      ) |>
      dplyr::pull("idx")

    # filter out inner rows
    x <- x |>
      dplyr::filter(!.data$idx %in% f_idx_inner) |>
      dplyr::select(-"idx")
  }

  # remove summary rows from empty sections if requested
  if (!keep_empty && var != ard_args$variables[1] && length(ard_args$include) > 1) {
    cols <-
      ard_args$variables |>
      stats::setNames(
        x |>
          dplyr::select(all_ard_group_n(seq_along(ard_args$variables) + length(by), types = "names"), "variable") |>
          names()
      )
    outer_cols <- utils::head(cols, -1)
    # if all inner rows filtered out, remove all summary rows - only overall/header rows left
    if (!dplyr::last(ard_args$variables) %in% x$variable) {
      # if no inner rows remain, remove all summary rows
      x <- x |> dplyr::filter(!.data$variable %in% outer_cols)
    } else {
      x_sum <- x |>
        dplyr::mutate(idx = dplyr::row_number()) |>
        # reformat current variable columns for filtering
        .ard_reformat_sort(by, cols)

      # check if each hierarchy section (from innermost to outermost) is empty and if so remove its summary row
      for (i in rev(seq_along(outer_cols))) {
        # get group keys of all non-empty sections
        x_gps <- x_sum |>
          # group by current and all previous grouping columns
          dplyr::group_by(dplyr::pick(
            any_of(cards::all_ard_group_n((1:i) + length(by))),
            any_of(cards::all_ard_variables())
          )) |>
          dplyr::group_keys() |>
          dplyr::filter(!.data$variable %in% "..overall..") |>
          dplyr::select(any_of(cards::all_ard_group_n((1:i) + length(by)))) |>
          dplyr::distinct()

        # get indices of rows to remove (summary rows from empty sections)
        idx_rm <- x_sum |>
          dplyr::filter(.data[[names(cols)[i]]] %in% cols[i]) |>
          dplyr::anti_join(x_gps, by = names(x_gps)) |>
          dplyr::pull("idx")

        # remove summary rows from empty sections
        x_sum <- x_sum |>
          dplyr::filter(!.data$idx %in% idx_rm)
      }
      # filter out all empty summary rows
      idx_keep <- sort(x_sum$idx)
      x <- x[idx_keep, ]
    }
  }

  # if present, keep attributes at bottom of ARD
  if (has_attr) x <- dplyr::bind_rows(x, x_attr)

  as_card(x, check = FALSE)
}

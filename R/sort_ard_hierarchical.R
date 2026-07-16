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
#' @param sort_level (`character`)\cr
#'     name of the treatment column value level by which you want to sort, e.g.,"Placebo". Leave it blank if you want to sort by
#'     the sum across all treatment column value levels. It is useful when at least one elements of the sort
#'     list has been specified as `"descending"`; however, it has no effect when sorting is specified as `sort = everything() ~ "alphanumeric"`.
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
#'
#' ard_stack_hierarchical_count(
#'   ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL
#' ) |>
#'   sort_ard_hierarchical(sort_level = "Placebo")
NULL

#' @rdname sort_ard_hierarchical
#' @export
sort_ard_hierarchical <- function(x, sort = everything() ~ "descending", sort_level = NULL) {
  set_cli_abort_call()

  # check and process inputs ---------------------------------------------------------------------
  check_string(sort_level, allow_empty = TRUE)
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
    ard_args$original_by <- ard_args$by
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


  # if sort_level is specified then we can't have missing by argument.
  if (!is.null(sort_level) & is_empty(ard_args$by)) {
    cli::cli_abort(
      "If 'by' argument is missing then sort_level has no useful meaning,
        please specify 'by' argument if you want to use sort_level.",
      call = get_cli_abort_call()
    )
  }


  # if there are two or more by variables then sort_level is no longer useful, therefore abort.
  if (!is.null(sort_level) & !is_empty(ard_args$by) & length(ard_args$original_by) > 1) {
    cli::cli_abort(
      "The argument `sort_level` is not useful with more than one by variables.",
      call = get_cli_abort_call()
    )
  }


  # check that the values for sort_level actually exists in the data
  if (!is.null(sort_level) & !is_empty(ard_args$by)) {
    valid_choices <- unlist(unique(x$group1_level))
    sort_level <- rlang::arg_match(sort_level, values = valid_choices)
  }


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
        .append_hierarchy_sums(ard_args, cols, i, sort_level = sort_level)
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

    x <- x |>
      dplyr::rowwise() |>
      # unlist cur_var_lvl column
      dplyr::mutate(dplyr::across(all_of(cur_var_lvl), ~ as.character(unlist(.x)))) |>
      dplyr::ungroup()
  }

  x
}

# this function calculates and appends group sums/ordering for the current hierarchy level (across `by` variables)
.append_hierarchy_sums <- function(x, ard_args, cols, i, sort_level = NULL) {
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
      if (!is.null(sort_level) & !is_empty(ard_args$by)) .data$group1_level == sort_level else TRUE,
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

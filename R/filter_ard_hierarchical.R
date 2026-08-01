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
    # a row is "overall" iff none of its cells hold a `by` variable name. This is
    # the vectorized equivalent of the per-row `any(x %in% by)` scan: for
    # character/list columns it reuses the exact `match()` coercion the row-wise
    # `apply()` triggered, but touches each column once. Rows already matched are
    # dropped from later columns (an OR reduction is order-independent), so the
    # expensive list columns are only scanned for the few not-yet-matched rows -
    # typically none, since `by` rows match on `group1` immediately.
    is_hit <- logical(nrow(x))
    for (col in x) {
      todo <- which(!is_hit)
      if (length(todo) == 0L) break
      vals <- col[todo]
      is_hit[todo[if (is.character(vals) || is.list(vals)) vals %in% by else as.character(vals) %in% by]] <- TRUE
    }
    is_overall <- !is_hit
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
  # group the reshaped ARD by hierarchy path (all group/variable columns except
  # the `by` columns). Only groups for variable `var` are filtered; every other
  # group is kept unchanged.
  key_cols <- setdiff(
    c(
      grep("^group[0-9]+(_level)?$", names(x_f), value = TRUE),
      intersect(c("variable", "variable_level"), names(x_f))
    ),
    by_cols
  )
  grp <- vctrs::vec_group_loc(x_f[key_cols])
  is_var_group <- grp$key$variable == var
  var_gis <- which(is_var_group)

  stat_present <- intersect(c("n", "N", "p"), names(x_f))
  multi_stat <- length(stat_present) > 1L
  use_col_stats <- !is_empty(by) && any(col_stat_vars %in% filter_vars)
  use_overall <- !is_empty(by) && any(overall_stat_vars %in% filter_vars)
  need_extra <- use_col_stats || use_overall

  # precompute the overall statistics for every filtered group in a single pass,
  # replacing the per-group rename + left_join against `x_overall`. `vec_match()`
  # takes the first matching overall row, exactly as the legacy `[[1]]` did.
  ov <- list()
  if (use_overall && !no_overall) {
    shifted <- grp$key |>
      vctrs::vec_slice(is_var_group) |>
      as_card(check = FALSE) |>
      cards::rename_ard_groups_shift()
    jc <- names(shifted)
    lookup_overall <- function(s) {
      xo <- x_overall[x_overall$stat_name == s, , drop = FALSE]
      xo$stat[vctrs::vec_match(shifted[jc], xo[jc])]
    }
    if ("n_overall" %in% filter_vars) ov$n <- lookup_overall("n")
    if ("N_overall" %in% filter_vars) ov$N <- lookup_overall("N")
    if ("p_overall" %in% filter_vars) ov$p <- lookup_overall("p")
  }

  keep_group <- !is_var_group
  for (j in seq_along(var_gis)) {
    gi <- var_gis[j]
    ii <- grp$loc[[gi]]
    k <- length(ii)
    dat <- as.list(vctrs::vec_slice(x_f, ii))
    if (!is_empty(by)) names(dat)[names(dat) == "group1_level"] <- by

    if (need_extra) {
      # append one summary row carrying the column-wise / overall statistics,
      # mirroring the legacy bind_rows(.df_all, .df_col_stats): grouping columns
      # present in `.df_col_stats` keep their (constant) value in the new row,
      # every other original column is padded with NA / NULL.
      for (nm in names(dat)) {
        v <- dat[[nm]]
        real <- nm == "group1" ||
          (use_col_stats && nm %in% c("group2", "group2_level", "variable", "variable_level"))
        dat[[nm]] <-
          if (is.list(v)) {
            c(v, if (real) v[1L] else list(NULL))
          } else {
            c(v, if (real) v[1L] else if (is.character(v)) NA_character_ else NA_real_)
          }
      }
      if (use_col_stats) {
        for (s in stat_present) {
          vals <- x_f[[s]][ii]
          for (pos in seq_len(k)) {
            nm <- if (multi_stat) paste0(s, "_", pos) else as.character(pos)
            dat[[nm]] <- c(rep(NA_real_, k), vals[pos])
          }
        }
      }
      if ("n_overall" %in% filter_vars) {
        dat$n_overall <- c(rep(NA_real_, k), if (!no_overall) ov$n[[j]] else sum(x_f[["n"]][ii]))
      }
      if ("N_overall" %in% filter_vars) {
        dat$N_overall <- c(rep(NA_real_, k), if (!no_overall) ov$N[[j]] else sum(x_f[["N"]][ii]))
      }
      if ("p_overall" %in% filter_vars) {
        dat$p_overall <- c(
          rep(NA_real_, k),
          if (!no_overall) ov$p[[j]] else sum(x_f[["n"]][ii]) / sum(x_f[["N"]][ii])
        )
      }
    }

    keep_group[gi] <- any(eval_tidy(filter, data = dat), na.rm = TRUE)
  }

  f_idx <- sort(unlist(x_f$idx[unlist(grp$loc[keep_group])]))
  x <- x[f_idx, ]

  # remove inner variable rows if `var` is an outer variable that does not meet the filter criteria
  if (which_var < length(ard_args$variables)) {
    var_gp_nm <- paste0("group", length(by) + which_var) # get `var` group variable name
    var_lvl_nm <- paste0(var_gp_nm, "_level")
    # group name/level columns identifying the hierarchy path down to `var`
    join_gp <- paste0("group", seq_len(which_var) + length(by))
    join_cols <- as.vector(rbind(join_gp, paste0(join_gp, "_level")))

    # unique hierarchy paths (down to `var`) that survived filtering on `var`;
    # the `var` name/level come from the variable/variable_level columns
    surv <- which(x$variable == var)
    keep_keys <- x[surv, join_cols]
    keep_keys[[var_gp_nm]] <- x$variable[surv]
    keep_keys[[var_lvl_nm]] <- x$variable_level[surv]
    keep_keys <- vctrs::vec_unique(keep_keys)

    # drop all rows nested within `var` sections that were filtered out
    inner <- which(x[[var_gp_nm]] == var & !is.na(x[[var_gp_nm]]))
    drop_inner <- inner[is.na(vctrs::vec_match(x[inner, join_cols], keep_keys))]
    if (length(drop_inner)) x <- x[-drop_inner, ]
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
        gk_i <- sort(c(
          paste0("group", seq_len(i) + length(by)),
          paste0("group", seq_len(i) + length(by), "_level")
        ))
        gk_i <- gk_i[gk_i %in% names(x_sum)]
        keys_i <- x_sum[gk_i]

        # hierarchy paths (down to level `i`) that still hold a non-summary row
        nonempty <- vctrs::vec_unique(vctrs::vec_slice(keys_i, !x_sum$variable %in% "..overall.."))

        # remove level `i` summary rows whose section is now empty
        drop <- x_sum[[names(cols)[i]]] %in% cols[i] & is.na(vctrs::vec_match(keys_i, nonempty))
        x_sum <- vctrs::vec_slice(x_sum, !drop)
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

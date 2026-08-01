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

  # statistic used for descending count sums, resolved once (it is invariant
  # across levels). Only required - and only checked for availability - when at
  # least one variable sorts by "descending".
  sort_stat <- if (any(unlist(sort) == "descending")) .hierarchy_sort_stat(x_sort, ard_args)

  # compute a sort-order rank ("sort_group") for every row at each hierarchy
  # level; the final row order is a single stable sort over these ranks
  x_cols <- names(x_sort)
  sort_groups <- vector("list", length(cols))
  for (i in seq_along(cols)) {
    cur_var <- names(cols)[i] # current grouping column
    # grouping-key columns for the current and all previous hierarchy levels
    gk_cols <- .hierarchy_group_cols(x_cols, length(by), i, cur_var, paste0(cur_var, "_level"))
    gid <- vctrs::vec_group_id(x_sort[gk_cols])

    sort_groups[[i]] <-
      if (sort[[cols[i]]] == "descending") {
        # rank groups by descending count sum (summed across `by`), levels ascending
        .hierarchy_sort_group_desc(x_sort, gk_cols, gid, sort_stat, ard_args, cols, i)
      } else {
        # rank groups alphanumerically by their grouping-variable levels
        .hierarchy_sort_group_alpha(x_sort, gk_cols, gid)
      }
  }

  # order rows by the per-level ranks; the stable radix sort keeps the original
  # (idx) order for rows tied at every level, matching the legacy arrange chain
  idx_sorted <- x_sort$idx[do.call(order, c(sort_groups, list(method = "radix")))]

  # sort ARD
  x <- x[idx_sorted, ]

  # if present, keep header info at top of ARD
  if (has_hdr) x <- dplyr::bind_rows(x_header, x)

  # if present, keep attributes at bottom of ARD
  if (has_attr) x <- dplyr::bind_rows(x, x_attr)

  x
}

# this function reformats a hierarchical ARD for sorting. It operates one column
# at a time (targeted `[[col]][rows] <-` assignments) rather than replacing whole
# rows via `x[cond, ] <- x[cond, ] |> mutate(...)`, avoiding a full-frame copy per
# level. Assignment order within each block mirrors the sequential `mutate()` it
# replaces (originals are read before the columns holding them are overwritten).
.ard_reformat_sort <- function(x, by, cols) {
  for (i in seq_along(cols)) {
    # get current grouping variables
    cur_var <- names(cols)[i]
    cur_var_lvl <- paste0(cur_var, "_level")

    # outer hierarchy variables - process summary rows
    if (!cur_var %in% "variable") {
      w <- which(x$variable %in% cols[i])
      if (length(w)) {
        # move variable/level names to correct grouping variable columns
        x[[cur_var]][w] <- x$variable[w]
        x[[cur_var_lvl]][w] <- x$variable_level[w]
        # mark rows as overall summary data
        x$variable[w] <- "..overall.."
        x$variable_level[w] <- list(NA_character_)
      }
    }

    # overall=TRUE - process summary rows (no `by` variable)
    group_i <- paste0("group", i)
    if (!is_empty(by) && !cur_var %in% "variable" && any(x[[group_i]] %in% cols[i])) {
      w <- which(x[[group_i]] %in% cols[i])
      next_grp <- paste0("group", i + length(by) + 1)
      # shift variable/level names one to the right (only if the target column
      # exists; assigning NULL to a missing column in the old `mutate` was a no-op)
      if (next_grp %in% names(x)) {
        x[[next_grp]][w] <- x[[cur_var]][w]
        x[[paste0(next_grp, "_level")]][w] <- x[[cur_var_lvl]][w]
      }
      x[[cur_var]][w] <- x[[group_i]][w]
      x[[cur_var_lvl]][w] <- x[[paste0(group_i, "_level")]][w]
    }

    # previous hierarchy variables - process summary rows
    w <- which(is.na(x[[cur_var]]))
    if (length(w)) {
      # mark summary rows from previous variables as "empty" for the current
      # to sort them prior to non-summary rows in the same section
      x[[cur_var]][w] <- ifelse(x$variable[w] %in% "..overall..", "..empty..", NA_character_)
      x[[cur_var_lvl]][w] <- list(NA)
    }

    # unlist cur_var_lvl column (vectorized equivalent of the rowwise unlist)
    x[[cur_var_lvl]] <-
      vapply(x[[cur_var_lvl]], function(.x) as.character(unlist(.x)), character(1L))
  }

  x
}

# grouping-key columns at hierarchy level `i`: the group##/group##_level columns
# for the `by`+1 .. `by`+i positions that exist in the data, followed by the
# current grouping-variable name/level columns. Mirrors the tidyselect the sort
# loop used: pick(all_ard_group_n(seq_len(i) + by), any_of(c(cur_var, cur_var_level))).
.hierarchy_group_cols <- function(nms, by_len, i, cur_var, cur_var_lvl) {
  grpn <- seq_len(i) + by_len
  grp <- sort(c(paste0("group", grpn), paste0("group", grpn, "_level")))
  grp <- grp[grp %in% nms]
  extra <- intersect(c(cur_var, cur_var_lvl), nms)
  c(grp, setdiff(extra, grp))
}

# statistic ("n" or "p") used to compute descending count sums. Errors if
# neither is present for every included variable still named in `x$variable`.
.hierarchy_sort_stat <- function(x, ard_args) {
  needed <- intersect(ard_args$include, x$variable)
  has_stat <- function(s) is_empty(setdiff(needed, x$variable[x$stat_name == s]))
  if (has_stat("n")) {
    return("n")
  }
  if (has_stat("p")) {
    return("p")
  }
  cli::cli_abort(
    paste(
      "If {.code sort='descending'} for any variables then either {.val n} or {.val p} must be present in {.arg x}",
      "for each of these specified variables in order to calculate the count sums used for sorting."
    ),
    call = get_cli_abort_call()
  )
}

# per-row group rank for a "descending" level: groups are ordered by their
# grouping levels ascending and their count sum (summed across `by`) descending.
# Returns NA for groups that contribute no `sort_stat` rows (as the legacy
# left_join did).
.hierarchy_sort_group_desc <- function(x, gk_cols, gid, sort_stat, ard_args, cols, i) {
  cur_var <- names(cols)[i]
  next_var <- names(cols)[i + 1L]
  by <- ard_args$by

  # rows contributing to the count sum at this level (verbatim translation of
  # the legacy .append_hierarchy_sums() filter)
  keep <- x$stat_name == sort_stat
  if (!is_empty(by)) keep <- keep & x$group1 %in% by
  if (length(c(by, ard_args$variables)) > 1L &&
    ard_args$variables[i] %in% ard_args$include && !cur_var %in% "variable") {
    keep <- keep & x$variable %in% "..overall.."
    if (!next_var %in% "variable") keep <- keep & x[[next_var]] %in% "..empty.."
  }

  sel <- which(keep)
  locs <- vctrs::vec_group_loc(gid[sel])
  present <- locs$key
  stat_sel <- x$stat[sel]
  sums <- vapply(locs$loc, function(ii) sum(unlist(stat_sel[ii])), numeric(1L))

  # order the present groups: grouping levels ascending, sum descending, with
  # the sum inserted before the innermost level column (as the legacy sort_cols)
  keyvals <- as.list(vctrs::vec_slice(x[gk_cols], match(present, gid)))
  m <- length(gk_cols)
  order_args <- c(keyvals[seq_len(m - 1L)], list(sums), keyvals[m])
  decreasing <- c(rep(FALSE, m - 1L), TRUE, FALSE)
  ord <- do.call(order, c(unname(order_args), list(method = "radix", decreasing = decreasing)))

  rank <- integer(length(present))
  rank[ord] <- seq_along(present)
  rank[match(gid, present)]
}

# per-row group rank for an "alphanumeric" level: dense rank of each group by
# its grouping levels in ascending (C-locale) order, matching the legacy
# group_by() + cur_group_id().
.hierarchy_sort_group_alpha <- function(x, gk_cols, gid) {
  n_grp <- attr(gid, "n")
  keyvals <- as.list(vctrs::vec_slice(x[gk_cols], match(seq_len(n_grp), gid)))
  ord <- do.call(order, c(unname(keyvals), list(method = "radix")))
  rank <- integer(n_grp)
  rank[ord] <- seq_len(n_grp)
  rank[gid]
}

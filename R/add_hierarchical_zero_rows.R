#' Add Zero Rows to Stacked Hierarchical ARDs
#'
#' @description `r lifecycle::badge('experimental')`\cr
#'
#' A stacked hierarchical ARD only has rows for the levels observed in the data:
#' an SOC with no events, or an AE never reported under an SOC, has no rows.
#'
#' `add_hierarchical_zero_rows()` adds these rows. Pass the level
#' combinations you expect in `levels`: each combination missing from `x` is
#' added with `n = 0`, the denominator `N` of its `by` group, and `p = 0`. As in
#' the rest of the ARD, `p` is `NaN` only when the `by` group is empty (`N = 0`).
#'
#' @param x (`card`)\cr
#'   a stacked hierarchical ARD of class `'card'` created using [ard_stack_hierarchical()] or
#'   [ard_stack_hierarchical_count()].
#' @param levels (`data.frame`)\cr
#'   the expected level combinations, one per row. The columns are named after the
#'   hierarchy variables of `x` and start from the top of the hierarchy, e.g. `AESOC`
#'   alone, or `AESOC` and `AEDECOD`. Their order does not matter.
#'
#' @details
#' Rows are only added for the variables with summary rows in `x` (see the
#' `include` argument of [ard_stack_hierarchical()]).
#'
#' The result is sorted alphanumerically, as returned by [ard_stack_hierarchical()],
#' so that each added level sits under its parent. Use [sort_ard_hierarchical()]
#' afterwards for a different order.
#'
#' @return an ARD data frame of class 'card'
#' @seealso [sort_ard_hierarchical()]
#' @name add_hierarchical_zero_rows
#'
#' @examplesIf (identical(Sys.getenv("NOT_CRAN"), "true") || identical(Sys.getenv("IN_PKGDOWN"), "true"))
#' # AEs of two SOCs: no severe AE is reported for EYE DISORDERS,
#' # and only some of the CARDIAC DISORDERS AEs are severe
#' adae <- ADAE |>
#'   dplyr::filter(AESOC %in% c("CARDIAC DISORDERS", "EYE DISORDERS"))
#'
#' ard <- adae |>
#'   dplyr::filter(AESEV == "SEVERE") |>
#'   ard_stack_hierarchical(
#'     variables = c(AESOC, AEDECOD),
#'     by = TRTA,
#'     denominator = ADSL,
#'     id = USUBJID
#'   )
#'
#' # add the SOC with no severe AEs
#' add_hierarchical_zero_rows(ard, levels = dplyr::distinct(adae, AESOC))
#'
#' # add every SOC/AE combination of the two SOCs
#' add_hierarchical_zero_rows(ard, levels = dplyr::distinct(adae, AESOC, AEDECOD))
NULL

#' @rdname add_hierarchical_zero_rows
#' @export
add_hierarchical_zero_rows <- function(x, levels) {
  set_cli_abort_call()

  # check inputs ---------------------------------------------------------------
  check_not_missing(x)
  check_not_missing(levels)
  check_class(x, c("ard_stack_hierarchical", "ard_stack_hierarchical_count"))
  check_data_frame(levels)

  ard_args <- attributes(x)$args
  variables <- ard_args$variables

  # the columns of `levels` are the top hierarchy variables, in any order
  top_variables <- variables[seq_len(ncol(levels))]
  if (ncol(levels) == 0L || !setequal(names(levels), top_variables)) {
    cli::cli_abort(
      c(
        "The columns of {.arg levels} must be hierarchy variables of {.arg x}, starting from the top.",
        i = "The hierarchy variables of {.arg x}, from the top, are {.val {variables}}."
      ),
      call = get_cli_abort_call()
    )
  }
  if (anyNA(levels)) {
    cli::cli_abort(
      "The {.arg levels} argument cannot contain missing values.",
      call = get_cli_abort_call()
    )
  }
  levels <- dplyr::distinct(levels[top_variables])

  # only the variables with summary rows in `x` get new rows, and only `n`, `N`
  # and `p` have a known value for an unobserved level
  complete_variables <- intersect(top_variables, ard_args$include)
  is_summary_row <- x$context %in% c("hierarchical", "hierarchical_count") & x$variable %in% complete_variables
  unexpected_stats <- setdiff(x$stat_name[is_summary_row], c("n", "N", "p"))
  if (!is_empty(unexpected_stats)) {
    cli::cli_abort(
      c(
        "Cannot add unobserved levels to an ARD with the {.val {unexpected_stats}} statistic{?s}.",
        i = "Only the {.val {c('n', 'N', 'p')}} statistics can be set for an unobserved level."
      ),
      call = get_cli_abort_call()
    )
  }

  # build the rows of the unobserved levels ------------------------------------
  new_rows <-
    lapply(
      complete_variables,
      \(variable) {
        .unobserved_level_rows(
          x = x[is_summary_row & x$variable == variable, ],
          levels = levels,
          variable = variable,
          ancestors = variables[seq_len(match(variable, variables) - 1L)]
        )
      }
    ) |>
    dplyr::bind_rows()

  if (nrow(new_rows) == 0L) {
    return(x)
  }

  # sort as `ard_stack_hierarchical()` does, so each added level sits under its parent
  dplyr::bind_rows(x, new_rows) |>
    sort_ard_hierarchical(sort = "alphanumeric")
}

# rows for the combinations of `levels` missing from `x`, the summary rows of
# `variable`. Each layout of `x` (one per set of group columns: with the `by`
# variables, or overall without them) is completed from a template, the rows of
# one observed level, which hold every `by` group with its denominator `N`
.unobserved_level_rows <- function(x, levels, variable, ancestors) {
  if (nrow(x) == 0L) {
    cli::cli_abort(
      "Cannot add levels for {.val {variable}}: {.arg x} has no rows for this variable to copy.",
      call = get_cli_abort_call()
    )
  }
  expected <- dplyr::distinct(levels[c(ancestors, variable)])
  expected_chr <- dplyr::mutate(expected, across(everything(), as.character))
  group_cols <- grep("^group[0-9]+$", names(x), value = TRUE)

  lapply(
    vctrs::vec_group_loc(x[group_cols])$loc,
    \(loc) {
      x_layout <- x[loc, ]
      # the level columns of the ancestors and of `variable` in this layout
      level_cols <- c(
        sprintf("%s_level", group_cols[match(ancestors, unlist(x_layout[1L, group_cols]))]),
        "variable_level"
      )
      observed <- x_layout[level_cols] |>
        unlist_ard_columns(columns = everything()) |>
        dplyr::mutate(across(everything(), as.character)) |>
        stats::setNames(names(expected))
      missing <- vctrs::vec_slice(expected, !vctrs::vec_in(expected_chr, observed))
      if (nrow(missing) == 0L) {
        return(NULL)
      }

      # copy the template once per missing combination, then set its levels
      template <- x_layout[vctrs::vec_equal(observed, vctrs::vec_slice(observed, 1L)), ]
      i_missing <- rep(seq_len(nrow(missing)), each = nrow(template))
      new <- template[rep(seq_len(nrow(template)), times = nrow(missing)), ]
      for (i in seq_along(level_cols)) {
        new[[level_cols[i]]] <- .as_levels_like(
          missing[[i]][i_missing],
          like = template[[level_cols[i]]][[1L]],
          arg = paste0("levels$", names(missing)[i])
        )
      }

      # `n` is 0 and so is `p = n / N`, except in an empty `by` group (`N = 0`):
      # there `p` is NaN, which is exactly where the template's own `p` is NaN
      new$stat[new$stat_name == "n"] <- list(0L)
      is_p <- new$stat_name == "p"
      new$stat[is_p] <- lapply(new$stat[is_p], \(p) if (is.nan(p)) NaN else 0)
      for (col in intersect(c("warning", "error"), names(new))) {
        new[[col]] <- rep(list(NULL), nrow(new))
      }
      if ("stat_fmt" %in% names(new)) {
        new <- apply_fmt_fun(new, replace = TRUE)
      }
      new
    }
  ) |>
    dplyr::bind_rows()
}

# new level values in the type of the levels already in the ARD (`like`), as a
# list column. A factor keeps its levels, extended by any new value
.as_levels_like <- function(values, like, arg) {
  values <-
    if (is.factor(like)) {
      factor(as.character(values), levels = union(levels(like), as.character(values)))
    } else {
      vctrs::vec_cast(values, like, x_arg = arg, call = get_cli_abort_call())
    }
  as.list(values)
}

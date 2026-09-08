#' Add Unobserved Levels to Hierarchical ARDs
#'
#' @description `r lifecycle::badge('experimental')`\cr
#'
#' A stacked hierarchical ARD keeps only the levels seen in the data, so a
#' category that never occurs (an SOC with no events, a preferred term absent
#' under an observed SOC, an unused grade) simply drops out instead of showing
#' up with a count of zero.
#'
#' `add_hierarchical_unobserved_levels()` puts those rows back. Supply a data
#' frame of the level combinations you expect to see, and any that are missing
#' are added with a count of zero; proportions are left as `NaN`, since a
#' never-observed level has no one at risk (`0 / 0` is undefined) and should be
#' recoded for display rather than asserted as zero here.
#'
#' @param x (`card`)\cr
#'   a stacked hierarchical ARD created with [ard_stack_hierarchical()].
#' @param levels (`data.frame`)\cr
#'   the expected level combinations. Its columns are named after the
#'   hierarchical variables to complete, in hierarchy order (e.g. columns
#'   `AESOC` and `AEDECOD`), matching the `variables`/`include` of the original
#'   [ard_stack_hierarchical()] call. Each row is a combination that should be
#'   present: any combination not already in `x` is added as a zero-count row.
#'   Use a single column (e.g. just `AESOC`) to complete only the top level.
#'
#' @return a stacked hierarchical ARD
#' @seealso [gtsummary::tbl_hierarchical()], [ard_stack_hierarchical()], [sort_ard_hierarchical()]
#' @name add_hierarchical_unobserved_levels
#'
#' @examples
#' set.seed(1)
#' adae <- data.frame(
#'   USUBJID = sprintf("S%03d", 1:20),
#'   AESOC = sample(c("Cardiac", "GI"), 20, TRUE),
#'   AEDECOD = sample(c("PT1", "PT2"), 20, TRUE)
#' )
#'
#' ard <- ard_stack_hierarchical(
#'   adae,
#'   variables = c(AESOC, AEDECOD),
#'   id = USUBJID,
#'   denominator = data.frame(USUBJID = sprintf("S%03d", 1:30))
#' )
#'
#' # complete the top level: the unobserved SOC "Vascular" is added as a zero-row
#' ard |>
#'   add_hierarchical_unobserved_levels(
#'     levels = data.frame(AESOC = c("Cardiac", "GI", "Vascular"))
#'   )
#'
#' # complete both levels, including children of the unobserved parent "Vascular"
#' ard |>
#'   add_hierarchical_unobserved_levels(
#'     levels = data.frame(
#'       AESOC = c("Cardiac", "Cardiac", "GI", "GI", "Vascular", "Vascular"),
#'       AEDECOD = c("PT1", "PT2", "PT1", "PT2", "PTX", "PTY")
#'     )
#'   )
NULL

# count statistics set to zero on an added level. Proportions are left as `NaN`
# (a never-observed level has no one at risk, so `0 / 0` is undefined) and are
# recoded for display downstream rather than being asserted as zero here
.hierarchical_zero_stats <- c("n", "n_cum")
.hierarchical_nan_stats <- c("p", "p_cum")

#' @rdname add_hierarchical_unobserved_levels
#' @export
add_hierarchical_unobserved_levels <- function(x, levels) {
  set_cli_abort_call()

  # process inputs -------------------------------------------------------------
  check_not_missing(x)
  check_not_missing(levels)
  check_class(x, "card")
  check_class(x, "ard_stack_hierarchical")
  check_data_frame(levels)

  # the columns of `levels` name the hierarchical variables to complete, in
  # hierarchy order, and must exist in the ARD's own variable column
  vars <- names(levels)
  var_universe <- unique(x[["variable"]])
  unknown <- setdiff(vars, var_universe)
  if (length(unknown) > 0L) {
    cli::cli_abort(
      c(
        "Columns of {.arg levels} must name hierarchical variables present in {.arg x}.",
        "i" = "Unknown column{?s}: {.val {unknown}}.",
        "i" = "Available variable{?s}: {.val {var_universe}}."
      ),
      call = get_cli_abort_call()
    )
  }

  # a level column that is a factor could reintroduce the very NA-from-bad-level
  # problem we are fixing, so compare as character throughout
  levels[] <- lapply(levels, as.character)

  top_var <- vars[1L]
  child_var <- if (length(vars) >= 2L) vars[2L] else NA_character_

  # helper: first level value from a list-column (`variable_level`, `groupN_level`)
  level_chr <- function(col) {
    vapply(
      col,
      function(z) {
        z <- as.character(z)
        if (length(z)) z[[1L]] else NA_character_
      },
      character(1L)
    )
  }

  # the hierarchical parent of a nested variable is stored in the last populated
  # `groupN` column: without a `by` the top variable has no group columns and the
  # child's parent is `group1`; with a `by` the arm occupies `group1` and the
  # parent shifts to `group2`. Detect the child's parent group column from data.
  child_rows <- if (!is.na(child_var)) x[x[["variable"]] == child_var, ] else x[0, ]
  parent_group_col <- NA_character_
  if (nrow(child_rows) > 0L) {
    group_cols <- grep("^group[0-9]+$", names(x), value = TRUE)
    for (gc in group_cols) {
      if (any(as.character(child_rows[[gc]]) == top_var, na.rm = TRUE)) {
        parent_group_col <- gc
        break
      }
    }
  }
  parent_level_col <- if (!is.na(parent_group_col)) paste0(parent_group_col, "_level") else NA_character_

  # build a zero-row block from an observed template, overriding the variable and
  # its level, optionally setting the hierarchical parent, and zeroing counts
  build_block <- function(template, parent_level, variable, level) {
    if (nrow(template) == 0L) {
      return(template)
    }
    template[["variable"]] <- variable
    template[["variable_level"]] <- rep(list(level), nrow(template))
    if (!is.null(parent_level) && !is.na(parent_group_col)) {
      template[[parent_group_col]] <- top_var
      template[[parent_level_col]] <- rep(list(parent_level), nrow(template))
    }
    is_zero <- template[["stat_name"]] %in% .hierarchical_zero_stats
    template[["stat"]][is_zero] <- as.list(rep(0, sum(is_zero)))
    is_nan <- template[["stat_name"]] %in% .hierarchical_nan_stats
    template[["stat"]][is_nan] <- as.list(rep(NaN, sum(is_nan)))
    if ("warning" %in% names(template)) template[["warning"]] <- rep(list(NULL), nrow(template))
    if ("error" %in% names(template)) template[["error"]] <- rep(list(NULL), nrow(template))
    template
  }

  # blueprint rows carry the correct stat structure (n/N/p, by-groups, fmt_fun).
  # one blueprint per `by`-group is preserved by taking all rows of one level.
  observed_top <- unique(level_chr(x[["variable_level"]][x[["variable"]] == top_var]))
  blueprint_top <- x[x[["variable"]] == top_var & level_chr(x[["variable_level"]]) == observed_top[1L], ]
  # a child blueprint spans one child level under one parent, across all
  # `by`-groups; the parent level is overwritten per added row
  blueprint_child <- if (nrow(child_rows) > 0L) {
    first_child <- level_chr(child_rows[["variable_level"]])[1L]
    child_one <- child_rows[level_chr(child_rows[["variable_level"]]) == first_child, ]
    if (!is.na(parent_level_col)) {
      first_parent <- level_chr(child_one[[parent_level_col]])[1L]
      child_one[level_chr(child_one[[parent_level_col]]) == first_parent, ]
    } else {
      child_one
    }
  } else {
    x[0, ]
  }

  new_blocks <- list()

  # top-level completion: add every expected top value not already observed
  expected_top <- unique(levels[[top_var]])
  expected_top <- expected_top[!is.na(expected_top)]
  for (lvl in setdiff(expected_top, observed_top)) {
    new_blocks <- c(new_blocks, list(build_block(blueprint_top, NULL, top_var, lvl)))
  }

  # child completion: for every expected parent, add the children listed in
  # `levels` that are not already observed under it. A newly added (unobserved)
  # parent has no observed children, so its full child set is added -- the same
  # code path as an observed parent, giving consistent behaviour for all levels.
  if (!is.na(child_var) && !is.na(parent_level_col)) {
    for (parent in expected_top) {
      expected_kids <- unique(levels[[child_var]][levels[[top_var]] == parent])
      expected_kids <- expected_kids[!is.na(expected_kids)]
      observed_kids <- unique(level_chr(
        child_rows[["variable_level"]][level_chr(child_rows[[parent_level_col]]) == parent]
      ))
      for (kid in setdiff(expected_kids, observed_kids)) {
        new_blocks <- c(new_blocks, list(build_block(blueprint_child, parent, child_var, kid)))
      }
    }
  }

  if (length(new_blocks) == 0L) {
    return(x)
  }

  out <- dplyr::bind_rows(x, dplyr::bind_rows(new_blocks))
  class(out) <- class(x)
  out
}

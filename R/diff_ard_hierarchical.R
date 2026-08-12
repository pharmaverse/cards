#' Rate Differences for Stacked Hierarchical ARDs
#'
#' @description `r lifecycle::badge('experimental')`\cr
#'
#' Calculate the difference in event rates between two groups of a stacked
#' hierarchical ARD created with [ard_stack_hierarchical()]. For every node in
#' the hierarchy (e.g. each system organ class and each preferred term), the
#' rate (`p` statistic) of a second group is subtracted from the rate of a first
#' group and returned under a new statistic named `"estimate"`.
#'
#' The input ARD must contain the `p` statistic and at least one `by` variable.
#' The `by` (grouping) dimension is collapsed in the result---only the `estimate`
#' rows are returned.
#'
#' @param x (`card`)\cr
#'   a stacked hierarchical ARD of class `'card'` created using
#'   [ard_stack_hierarchical()]. Must contain the `p` statistic and at least one
#'   `by` variable.
#' @param levels (`list`)\cr
#'   a list specifying the two groups being differenced, `p(group 1) - p(group 2)`.
#'   Required unless `x` has a single `by` variable with exactly two levels, in
#'   which case the difference defaults to the first level minus the second level
#'   (in the order the levels appear in the source data). Two forms are accepted:
#'   - a *flat named list* keyed by a single `by` variable whose name is repeated
#'     to give its two levels in order, e.g.
#'     `list(TRTA = "Xanomeline High Dose", TRTA = "Placebo")`. When `x` has more
#'     than one `by` variable, every other `by` variable must also be named once
#'     to pin it to a single level.
#'   - a list of *two named lists*, each fully specifying one group's combination
#'     of `by` variable levels, e.g.
#'     `list(list(TRTA = "Xanomeline High Dose"), list(TRTA = "Placebo"))` or, with
#'     two `by` variables,
#'     `list(list(TRTA = "Xanomeline High Dose", SEX = "F"), list(TRTA = "Placebo", SEX = "F"))`.
#'     This form is required when `x` has more than one `by` variable.
#'
#'   Defaults to `NULL`.
#'
#' @return an ARD data frame of class 'card'
#' @seealso [sort_ard_hierarchical()], [filter_ard_hierarchical()]
#' @name diff_ard_hierarchical
#'
#' @details
#' Rates are stored on the `[0, 1]` scale (as `p` is), so the returned `estimate`
#' values lie in `[-1, 1]`. A hierarchy node observed in only one of the two
#' groups is treated as a rate of `0` in the group where it is absent.
#'
#' @examplesIf (identical(Sys.getenv("NOT_CRAN"), "true") || identical(Sys.getenv("IN_PKGDOWN"), "true"))
#' ard <- ard_stack_hierarchical(
#'   ADAE,
#'   variables = c(AESOC, AEDECOD),
#'   by = TRTA,
#'   denominator = ADSL,
#'   id = USUBJID
#' )
#'
#' # difference between two of the three treatment arms
#' diff_ard_hierarchical(ard, levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo"))
#'
#' # equivalent, using the two-cell form
#' diff_ard_hierarchical(
#'   ard,
#'   levels = list(list(TRTA = "Xanomeline High Dose"), list(TRTA = "Placebo"))
#' )
NULL

#' @rdname diff_ard_hierarchical
#' @export
diff_ard_hierarchical <- function(x, levels = NULL) {
  set_cli_abort_call()

  # check and process inputs ---------------------------------------------------------------------
  check_not_missing(x)
  check_class(x, "card")

  if (!any(c("ard_stack_hierarchical", "ard_stack_hierarchical_count") %in% class(x))) {
    cli::cli_warn(
      c("The {.fun diff_ard_hierarchical} function was created for stacked hierarchical ARDs created using
         {.fun ard_stack_hierarchical}.",
        "i" = "Unexpected results may occur."
      )
    )
  }

  ard_args <- attributes(x)$args
  by <- ard_args$by

  # must have at least one `by` variable
  if (is_empty(by)) {
    cli::cli_abort(
      "The ARD {.arg x} must contain at least one {.arg by} variable to calculate rate differences.",
      call = get_cli_abort_call()
    )
  }

  # must have the `p` statistic for the hierarchy rows
  if (!"p" %in% x$stat_name[x$context %in% "hierarchical"]) {
    cli::cli_abort(
      c("The {.val p} statistic must be present in {.arg x} to calculate rate differences.",
        "i" = "Include {.val p} in the {.arg statistic} argument of {.fun ard_stack_hierarchical}."
      ),
      call = get_cli_abort_call()
    )
  }

  # resolve the two groups being differenced -----------------------------------------------------
  groups <- .diff_resolve_groups(x, by, levels)

  # calculate the rate differences ---------------------------------------------------------------
  result <- .diff_compute(x, by, groups$A, groups$B)

  # append attributes and class ------------------------------------------------------------------
  attr(result, "args") <- list(
    by = NULL,
    variables = ard_args$variables,
    include = ard_args$include,
    diff = list(group1 = groups$A, group2 = groups$B)
  )
  class(result) <- c("ard_stack_hierarchical", setdiff(class(result), "ard_stack_hierarchical"))

  result
}

# resolve the two comparison groups from `levels` (or the 2-level default). Returns a list with
# elements `A` and `B`, each a named list mapping every `by` variable to a single level.
.diff_resolve_groups <- function(x, by, levels) {
  # valid levels of a `by` variable, read from its group##_level column
  by_valid <- function(by_var) {
    lvl_col <- paste0("group", match(by_var, by), "_level")
    unique(as.character(unlist(x[[lvl_col]])))
  }

  # default: single `by` variable with exactly two levels --------------------------------------
  if (is.null(levels)) {
    if (length(by) != 1L) {
      cli::cli_abort(
        c("The {.arg levels} argument must be specified when {.arg x} has more than one {.arg by} variable.",
          "i" = "Specify the two groups as two named lists, e.g. {.code levels = list(list(...), list(...))}."
        ),
        call = get_cli_abort_call()
      )
    }
    lvls <- .diff_by_levels_in_order(x, by)
    if (length(lvls) != 2L) {
      cli::cli_abort(
        c("The {.arg by} variable {.val {by}} must have exactly two levels to calculate a rate difference
           without specifying {.arg levels}.",
          "i" = "{.val {by}} has {length(lvls)} level{?s}: {.val {lvls}}. Specify {.arg levels} to choose two."
        ),
        call = get_cli_abort_call()
      )
    }
    return(list(
      A = stats::setNames(list(lvls[1]), by),
      B = stats::setNames(list(lvls[2]), by)
    ))
  }

  # `levels` supplied: detect which of the two forms was given ---------------------------------
  is_two_cell <- rlang::is_list(levels) && length(levels) == 2L &&
    all(vapply(levels, rlang::is_list, logical(1L)))

  if (is_two_cell) {
    cellA <- .diff_check_cell(levels[[1]], by, by_valid)
    cellB <- .diff_check_cell(levels[[2]], by, by_valid)
    if (identical(cellA[order(names(cellA))], cellB[order(names(cellB))])) {
      cli::cli_abort(
        "The two groups specified in {.arg levels} must differ.",
        call = get_cli_abort_call()
      )
    }
    return(list(A = cellA, B = cellB))
  }

  .diff_parse_flat_levels(levels, by, by_valid)
}

# the levels of a single `by` variable in source-data (factor) order. Preferentially read from
# the `by` variable's univariate tabulation rows, which preserve the original level order even
# after the hierarchy is alphanumerically sorted; fall back to appearance order in group1_level.
.diff_by_levels_in_order <- function(x, by) {
  tab <- x$variable %in% by & x$context %in% "tabulate"
  tab_p <- tab & x$stat_name %in% "p"
  if (any(tab_p)) tab <- tab_p
  if (any(tab)) {
    lv <- vapply(
      x$variable_level[tab],
      function(z) if (is_empty(z)) NA_character_ else as.character(z[[1]]),
      character(1L)
    )
    return(unique(stats::na.omit(lv)))
  }

  lvl_col <- paste0("group", match(by, by), "_level")
  lv <- vapply(
    x[[lvl_col]],
    function(z) if (is_empty(z)) NA_character_ else as.character(z[[1]]),
    character(1L)
  )
  unique(stats::na.omit(lv))
}

# validate a single "cell" (one group) of the two-cell `levels` form. Returns the cell as a
# named list of single character levels covering every `by` variable.
.diff_check_cell <- function(cell, by, by_valid) {
  nms <- rlang::names2(cell)
  if (!rlang::is_list(cell) || is_empty(cell) || any(!nzchar(nms))) {
    cli::cli_abort(
      "Each group in {.arg levels} must be a fully named list of {.arg by} variable levels.",
      call = get_cli_abort_call()
    )
  }
  if (anyDuplicated(nms)) {
    cli::cli_abort(
      "Each {.arg by} variable may be specified only once within a group of {.arg levels}.",
      call = get_cli_abort_call()
    )
  }
  if (!setequal(nms, by)) {
    cli::cli_abort(
      c("Each group in {.arg levels} must specify a level for every {.arg by} variable.",
        "i" = "The {.arg by} variable{?s} {.val {by}} must each appear once."
      ),
      call = get_cli_abort_call()
    )
  }
  if (any(lengths(cell) != 1L)) {
    cli::cli_abort(
      "Each element of a {.arg levels} group must be a single level.",
      call = get_cli_abort_call()
    )
  }
  for (v in nms) {
    valid <- by_valid(v)
    if (!as.character(cell[[v]]) %in% valid) {
      cli::cli_abort(
        "The {.arg levels} value for {.val {v}} must be one of {.val {valid}}, not {.val {cell[[v]]}}.",
        call = get_cli_abort_call()
      )
    }
  }

  lapply(cell, as.character)
}

# validate the flat repeated-name `levels` form and return groups `A`/`B`. The difference
# variable is the `by` variable named twice; any other `by` variable is named once (pinned).
.diff_parse_flat_levels <- function(levels, by, by_valid) {
  nms <- rlang::names2(levels)
  if (!rlang::is_list(levels) || is_empty(levels) || any(!nzchar(nms))) {
    cli::cli_abort(
      "The {.arg levels} argument must be a fully named list, e.g.
       {.code list(TRTA = \"Placebo\", TRTA = \"Low Dose\")}.",
      call = get_cli_abort_call()
    )
  }
  if (!all(nms %in% by)) {
    cli::cli_abort(
      c("The names of {.arg levels} must be {.arg by} variables used to create {.arg x}.",
        "i" = "The {.arg by} variable{?s} {.val {by}} {?is/are} available."
      ),
      call = get_cli_abort_call()
    )
  }
  if (any(lengths(levels) != 1L)) {
    cli::cli_abort(
      "Each element of {.arg levels} must be a single {.arg by} variable level.",
      call = get_cli_abort_call()
    )
  }

  counts <- table(factor(nms, levels = by))
  diff_var <- names(counts)[counts == 2L]
  if (length(diff_var) != 1L || any(counts > 2L)) {
    cli::cli_abort(
      c("Exactly one {.arg by} variable must be repeated in {.arg levels} to define the two groups being differenced.",
        "i" = if (length(by) > 1L) {
          "With more than one {.arg by} variable, specify the two groups as two named lists, e.g.
           {.code list(list(...), list(...))}."
        } else {
          "Repeat the {.arg by} variable name, e.g. {.code list({by} = \"level1\", {by} = \"level2\")}."
        }
      ),
      call = get_cli_abort_call()
    )
  }
  others <- setdiff(by, diff_var)
  if (any(counts[others] != 1L)) {
    cli::cli_abort(
      c("Every {.arg by} variable other than the difference variable must be specified exactly once in {.arg levels}.",
        "i" = "The {.arg by} variable{?s} {.val {by}} must each appear (the difference variable twice)."
      ),
      call = get_cli_abort_call()
    )
  }

  diff_levels <- as.character(unlist(levels[nms == diff_var], use.names = FALSE))
  if (diff_levels[1] == diff_levels[2]) {
    cli::cli_abort(
      "The two levels of the difference variable {.val {diff_var}} in {.arg levels} must differ.",
      call = get_cli_abort_call()
    )
  }

  # validate all levels are present
  for (v in by) {
    valid <- by_valid(v)
    vals <- as.character(unlist(levels[nms == v], use.names = FALSE))
    bad <- setdiff(vals, valid)
    if (length(bad)) {
      cli::cli_abort(
        c(
          "{cli::qty(bad)}The {.arg levels} value{?s} {.val {bad}} for {.val {v}} {?is/are} not a valid level.",
          "i" = "{cli::qty(valid)}Valid level{?s}: {.val {valid}}."
        ),
        call = get_cli_abort_call()
      )
    }
  }

  fixed <- stats::setNames(
    lapply(others, function(v) as.character(levels[[which(nms == v)]])),
    others
  )
  A <- c(stats::setNames(list(diff_levels[1]), diff_var), fixed)
  B <- c(stats::setNames(list(diff_levels[2]), diff_var), fixed)
  list(A = A, B = B)
}

# compute `p(group A) - p(group B)` for every hierarchy node and return the reshaped ARD
# (only the `estimate` rows, with the `by` group columns collapsed away).
.diff_compute <- function(x, by, groupA, groupB) {
  # `p` rows for hierarchy nodes only (excludes `by` univariate tabulation, attributes, etc.)
  xp <- x[x$stat_name %in% "p" & x$context %in% "hierarchical", , drop = FALSE]

  by_lvl_cols <- stats::setNames(paste0("group", seq_along(by), "_level"), by)
  by_cols <- c(paste0("group", seq_along(by)), paste0("group", seq_along(by), "_level"))

  # per-row logical mask selecting rows matching a group's `by`-level specification
  group_mask <- function(spec) {
    keep <- rep(TRUE, nrow(xp))
    for (v in names(spec)) {
      vals <- vapply(
        xp[[by_lvl_cols[[v]]]],
        function(z) if (is_empty(z)) NA_character_ else as.character(z[[1]]),
        character(1L)
      )
      keep <- keep & !is.na(vals) & vals == spec[[v]]
    }
    keep
  }

  A <- xp[group_mask(groupA), , drop = FALSE]
  B <- xp[group_mask(groupB), , drop = FALSE]

  # hierarchy key = non-`by` group columns + variable/variable_level
  grp_cols <- grep("^group[0-9]+(_level)?$", names(xp), value = TRUE)
  key <- c(setdiff(grp_cols, by_cols), "variable", "variable_level")

  pA <- vapply(A$stat, function(z) as.numeric(z[[1]]), numeric(1L))
  pB <- vapply(B$stat, function(z) as.numeric(z[[1]]), numeric(1L))

  # subtract group B from group A (missing node in B counts as rate 0)
  b_for_a <- vctrs::vec_match(A[key], B[key])
  pB_for_a <- ifelse(is.na(b_for_a), 0, pB[b_for_a])
  A$stat <- as.list(pA - pB_for_a)
  out <- A

  # nodes present only in group B contribute `0 - p(B)`
  a_for_b <- vctrs::vec_match(B[key], A[key])
  b_only <- which(is.na(a_for_b))
  if (length(b_only)) {
    Bo <- B[b_only, , drop = FALSE]
    Bo$stat <- as.list(0 - pB[b_only])
    out <- vctrs::vec_rbind(out, Bo)
  }

  # overwrite statistic metadata
  out$stat_name <- "estimate"
  out$stat_label <- "% difference"
  out$context <- "diff_hierarchical"
  out$fmt_fun <- list(label_round(digits = 1, scale = 100))
  out$warning <- list(NULL)
  out$error <- list(NULL)

  # collapse the `by` dimension: drop `by` group columns and shift the rest left
  out <- out[, setdiff(names(out), by_cols), drop = FALSE] |>
    as_card(check = FALSE)
  if (any(grepl("^group[0-9]+", names(out)))) {
    out <- rename_ard_groups_shift(out, shift = -length(by))
  }

  tidy_ard_column_order(out)
}

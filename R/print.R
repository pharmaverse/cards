#' Print
#'
#' `r lifecycle::badge('experimental')`\cr
#' Print method for objects of class 'card'.
#'
#' ARD tibbles print like a typical tibble (via the \pkg{pillar} package) with
#' a few ARD-specific adaptations:
#' - the header reads `An ARD data frame` instead of `A tibble`
#' - list-columns whose elements are scalars print the *value* of the element,
#'   falling back to the standard tibble summary (e.g. `<chr [2]>`, `<fn>`) for
#'   non-scalar elements
#' - when the tibble is too wide for the console, all-`NULL` `error` and
#'   `warning` columns are suppressed first, then (after the usual column
#'   shrinking) the `fmt_fun`, `stat_label`, `stat_fmt`, and `context` columns
#'   are dropped in that order before falling back to the standard tibble
#'   behaviour. Suppressed columns are reported in the footer.
#'
#' @param x (`data.frame`)\cr
#'   object of class 'card'
#' @param width (`integer`)\cr
#'   width of the printed output
#' @param n (`integer`)\cr
#'   number of rows to print
#' @param max_extra_cols,max_footer_lines (`integer`)\cr
#'   passed to [tibble::print.tbl()]; control the number of columns and footer
#'   lines listed in the footer
#' @param controller,setup,title
#'   arguments passed by the \pkg{pillar} print machinery; not called directly
#' @param ... ([`dynamic-dots`][rlang::dyn-dots])\cr
#'   passed to the underlying \pkg{pillar}/\pkg{tibble} methods
#'
#' @return an ARD data frame of class 'card' (invisibly)
#' @name print.card
#' @keywords internal
#'
#' @examples
#' ard_tabulate(ADSL, variables = AGEGR1) |>
#'   print()
NULL

#' @export
#' @rdname print.card
print.card <- function(x, width = NULL, ..., n = NULL,
                       max_extra_cols = NULL, max_footer_lines = NULL) {
  NextMethod()
}

#' @exportS3Method tibble::tbl_sum
tbl_sum.card <- function(x, ...) {
  out <- NextMethod()
  names(out)[names(out) == "A tibble"] <- "An ARD data frame"
  out
}

#' @exportS3Method pillar::ctl_new_pillar
#' @rdname print.card
ctl_new_pillar.card <- function(controller, x, width, ..., title = NULL) {
  out <- NextMethod()
  # only take over plain list-columns; NULL means the column was dropped, and
  # data.frame/matrix sub-columns are left to the default machinery
  if (is.null(out) || !is.list(x) || is.data.frame(x)) {
    return(out)
  }

  # reuse the default title/type (so the class row still shows `<list>`) and
  # swap in a shaft that prints scalar values
  pillar::new_pillar(list(
    title = out$title,
    type = out$type,
    data = pillar::pillar_component(card_list_shaft(x, ...))
  ))
}

#' Shaft for ARD list-columns
#'
#' Builds a [pillar::pillar_shaft()] for a list-column. When every element is a
#' scalar (length-1 atomic) that can be combined to a common type, the column is
#' formatted natively (significant figures, alignment, colour, width shrinking).
#' Otherwise each element is formatted individually: scalars as their value and
#' everything else as the standard tibble summary (`<chr [2]>`, `<fn>`,
#' `<NULL>`, ...). `NULL` elements are always shown as `<NULL>` (rather than
#' coerced to `NA`).
#'
#' @param x (`list`)\cr a list-column
#' @param ... passed to the underlying \pkg{pillar} shaft constructors
#' @return a `pillar_shaft` object
#' @keywords internal
card_list_shaft <- function(x, ...) {
  # `NULL` is deliberately not treated as a scalar, so that a column containing
  # any `NULL` uses the element-wise path below and renders it as `<NULL>`
  is_scalar <- vapply(
    x,
    function(e) vctrs::vec_is(e) && length(e) == 1L && is.atomic(e),
    logical(1)
  )

  # homogeneous scalar column: format natively
  if (length(x) > 0L && all(is_scalar)) {
    coerced <- tryCatch(vctrs::list_unchop(x), error = function(e) NULL)
    if (!is.null(coerced) && length(coerced) == length(x)) {
      return(pillar::pillar_shaft(coerced, ...))
    }
  }

  # mixed-type or non-scalar column: format element-by-element. Scalars print
  # their value; everything else (incl. `NULL`) prints a subtle `<summary>`.
  fmt <- vapply(
    x,
    function(e) {
      if (vctrs::vec_is(e) && length(e) == 1L && is.atomic(e)) {
        format(e)
      } else {
        pillar::style_subtle(paste0("<", pillar::obj_sum(e), ">"))
      }
    },
    character(1)
  )
  pillar::new_pillar_shaft_simple(fmt, align = "left")
}

#' @exportS3Method pillar::tbl_format_setup
#' @rdname print.card
tbl_format_setup.card <- function(x, width = NULL, ...) {
  # call the tbl method directly (not via dispatch) so that (a) we do not
  # recurse into this method, and (b) the frame keeps its 'card' class, which
  # keeps `ctl_new_pillar.card()` active for the list-column formatting.
  # `envir` is required because pillar is imported, not attached, so the
  # generic is not on the search path.
  tbl_setup <- utils::getS3method("tbl_format_setup", "tbl", envir = asNamespace("pillar"))
  run <- function(df) tbl_setup(df, width = width, ...)

  x_full <- x
  setup <- run(x)
  dropped <- character(0L)

  # only re-arrange columns when the frame overflows the console width
  if (length(setup$extra_cols) > 0L) {
    # proactively drop all-NULL error/warning columns
    for (col in c("error", "warning")) {
      if (col %in% names(x) && all(vapply(x[[col]], is.null, logical(1)))) {
        dropped <- c(dropped, col)
        x[[col]] <- NULL
      }
    }
    if (length(dropped) > 0L) setup <- run(x)

    # progressively drop lower-priority columns until it fits
    for (col in c("fmt_fun", "stat_label", "stat_fmt", "context")) {
      if (length(setup$extra_cols) == 0L) break
      if (col %in% names(x)) {
        dropped <- c(dropped, col)
        x[[col]] <- NULL
        setup <- run(x)
      }
    }
    # anything still overflowing is left to the standard tibble behaviour
  }

  # report the suppressed columns in the footer, in their original column order
  if (length(dropped) > 0L) {
    extra <- c(setup$extra_cols, as.list(x_full[dropped]))
    setup$extra_cols <- extra[order(match(names(extra), names(x_full)))]
    setup$extra_cols_total <- setup$extra_cols_total + length(dropped)
  }

  # restore the '{cards}' header label and the full (untrimmed) dimensions
  setup$tbl_sum <- tibble::tbl_sum(x_full)
  setup
}


#' @export
#' @rdname print.card
print.compare_ard <- function(x, ...) {
  # print comparison details ---------------------------------------------------
  cli::cli_inform("The comparison {.arg keys} are {.val {x$keys}}.")
  cli::cli_inform("The comparison columns are {.val {x$columns}}.")

  # print the mismatches rows --------------------------------------------------
  cli::cli_h1("Mis-matched Rows")
  if (nrow(x$rows_in_x_not_y) == 0L) {
    cli::cli_alert_success("No rows in {.arg x} that do not appear in {.arg y}.")
  } else {
    cli::cli_h3("Rows in {.arg x} that do not appear in {.arg y}.")
    as.data.frame(x$rows_in_x_not_y)
  }
  if (nrow(x$rows_in_y_not_x) == 0L) {
    cli::cli_alert_success("No rows in {.arg y} that do not appear in {.arg x}.")
  } else {
    cli::cli_h3("Rows in {.arg y} that do not appear in {.arg x}.")
    as.data.frame(x$rows_in_y_not_x) |> print()
  }

  # print comparison results ---------------------------------------------------
  cli::cli_h1("Comparison Results")
  for (i in seq_along(x$comparison)) {
    if (nrow(x$comparison[[i]]) == 0L) {
      cli::cli_alert_success("No differences found in column {.val {names(x$comparison[i])}}.")
      next
    }
    cli::cli_alert_warning("Differences found in column {.val {names(x$comparison[i])}} for {.val {nrow(x$comparison[[i]])}} rows.")
    as.data.frame(x$comparison[[i]]) |>
      utils::head(n = 10) |>
      print()
  }

  # return input invisibly -----------------------------------------------------
  invisible(x)
}

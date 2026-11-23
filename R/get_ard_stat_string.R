#' ARD Statistics as String
#'
#' Returns formatted statistics from an ARD, combined into a single string.
#' The formatted statistics (the `"stat_fmt"` column, see [apply_fmt_fun()])
#' are inserted into `pattern` using glue syntax,
#' where each `{stat_name}` is replaced by the corresponding formatted statistic.
#'
#' @param x (`data.frame`)\cr
#'   an ARD data frame of class 'card'
#' @param ... ([`dynamic-dots`][rlang::dyn-dots])\cr
#'   arguments indicating the rows of the ARD to subset.
#'   For example, to return only rows where the column `"AGEGR1"` is `"65-80"`,
#'   pass `AGEGR1 %in% "65-80"`.
#'   After subsetting, each statistic named in `pattern` must appear in exactly one row.
#' @param pattern (`string`)\cr
#'   a string with the statistics to include in glue syntax,
#'   e.g. `"{n} / {N} ({p}%)"`.
#'   The names in the curly brackets must be values of the `"stat_name"` column.
#' @param missing (`string`)\cr
#'   string returned when all statistics in `pattern` are missing.
#'   Default is `""`.
#'
#' @return a string
#' @export
#'
#' @examples
#' ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
#'
#' get_ard_stat_string(
#'   ard,
#'   group1_level %in% "Placebo",
#'   variable_level %in% "65-80",
#'   pattern = "{n} / {N} ({p}%)"
#' )
get_ard_stat_string <- function(x,
                                ...,
                                pattern,
                                missing = "") {
  set_cli_abort_call()

  # check inputs ---------------------------------------------------------------
  check_class(x, cls = "card")
  check_string(pattern)
  check_string(missing)

  stat_names <- .extract_stat_names(pattern)
  if (length(stat_names) == 0L) {
    cli::cli_abort(
      "The {.arg pattern} argument must reference at least one statistic
       in curly brackets, e.g. {.val {{n}} ({{p}}%)}.",
      call = get_cli_abort_call()
    )
  }

  # subset the ARD and apply the formatting functions --------------------------
  ard_subset <- x |>
    apply_fmt_fun() |>
    dplyr::filter(...)

  # each statistic in the pattern must be in exactly one row -------------------
  n_rows <- vapply(stat_names, function(nm) sum(ard_subset$stat_name %in% nm), integer(1L))
  not_found <- names(n_rows)[n_rows == 0L]
  duplicated <- names(n_rows)[n_rows > 1L]
  if (length(not_found) > 0L || length(duplicated) > 0L) {
    msg <- "Each statistic in {.arg pattern} must appear in exactly one row of the subset ARD."
    if (length(not_found) > 0L) {
      msg <- c(msg, x = "Statistic{?s} {.val {not_found}} not found.")
    }
    if (length(duplicated) > 0L) {
      msg <- c(msg, x = "Statistic{?s} {.val {duplicated}} found in more than one row.")
    }
    cli::cli_abort(msg, call = get_cli_abort_call())
  }

  # insert the formatted statistics into the pattern ---------------------------
  stat_fmt <-
    stat_names |>
    lapply(function(nm) {
      fmt <- ard_subset$stat_fmt[[which(ard_subset$stat_name == nm)]]
      # a NULL statistic has a zero-length formatted value
      if (length(fmt) == 0L) NA_character_ else as.character(fmt)
    }) |>
    stats::setNames(stat_names)

  if (all(is.na(stat_fmt))) {
    return(missing)
  }

  glue::glue_data(stat_fmt, pattern) |>
    as.character()
}

#' Extract Statistic Names from Pattern
#'
#' @param pattern (`string`)\cr
#'   a glue pattern, e.g. `"{n} ({p}%)"`
#'
#' @return a character vector of the unique names inside curly brackets
#' @keywords internal
#'
#' @examples
#' cards:::.extract_stat_names("{n} / {N} ({p}%)")
.extract_stat_names <- function(pattern) {
  regmatches(pattern, gregexpr("(?<=\\{)[^{}]+(?=\\})", pattern, perl = TRUE))[[1]] |>
    unique()
}

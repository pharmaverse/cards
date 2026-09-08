#' Process keys Argument
#'
#' @param x (`card`)\cr first ARD
#' @param y (`card`)\cr second ARD
#' @param keys tidyselect expression for key columns
#'
#' @return character vector of key column names
#' @keywords internal
#' @noRd
.process_keys_arg <- function(x, y, keys) {
  # defuse the selection once, so that it is evaluated against each ARD in turn.
  # evaluating `{{ keys }}` twice resolves the selection against `x` and then
  # re-uses those column positions on `y`.
  keys <- enquo(keys)

  keys_x <- cards_select(expr = keys, data = x, allow_rename = FALSE, arg_name = "keys")
  keys_y <- cards_select(expr = keys, data = y, allow_rename = FALSE, arg_name = "keys")

  .check_not_empty(keys_x, arg_name = "keys")

  if (!setequal(keys_x, keys_y)) {
    cli::cli_abort(
      c("The {.arg keys} columns from {.arg x} and {.arg y} do not match.",
        "i" = "Key columns in {.arg x}: {.val {keys_x}}",
        "i" = "Key columns in {.arg y}: {.val {keys_y}}"
      ),
      call = get_cli_abort_call()
    )
  }

  keys_x
}

#' Process compare Argument
#'
#' @param x (`card`)\cr first ARD
#' @param y (`card`)\cr second ARD
#' @param columns tidyselect expression for columns to compare
#'
#' @return character vector of column names to compare
#' @keywords internal
#' @noRd
.process_compare_arg <- function(x, y, columns) {
  # defused for the same reason as `keys` above
  columns <- enquo(columns)

  columns_x <- cards_select(expr = columns, data = x, allow_rename = FALSE, arg_name = "columns")
  columns_y <- cards_select(expr = columns, data = y, allow_rename = FALSE, arg_name = "columns")

  .check_not_empty(columns_x, arg_name = "columns")

  # compare the columns the two ARDs have in common, so that an ARD carrying an
  # optional column the other does not (e.g. `stat_fmt`, added by
  # `apply_fmt_fun()`) can still be compared on the rest
  columns_common <- intersect(columns_x, columns_y)

  if (rlang::is_empty(columns_common)) {
    cli::cli_abort(
      c("The comparison {.arg columns} from {.arg x} and {.arg y} have no columns in common.",
        "i" = "Comparison {.arg columns} in {.arg x}: {.val {columns_x}}",
        "i" = "Comparison {.arg columns} in {.arg y}: {.val {columns_y}}"
      ),
      call = get_cli_abort_call()
    )
  }

  if (!setequal(columns_x, columns_y)) {
    only_x <- setdiff(columns_x, columns_y)
    only_y <- setdiff(columns_y, columns_x)
    cli::cli_inform(
      c(
        "!" = "Some comparison {.arg columns} are not present in both ARDs and are not compared.",
        if (!rlang::is_empty(only_x)) c("i" = "Not present in {.arg y}: {.val {only_x}}"),
        if (!rlang::is_empty(only_y)) c("i" = "Not present in {.arg x}: {.val {only_y}}")
      )
    )
  }

  columns_common
}

#' Check Argument is Not Empty
#'
#' @param x object to check
#' @param arg_name name of argument for error message
#'
#' @return invisible x
#' @keywords internal
#' @noRd
.check_not_empty <- function(x, arg_name = rlang::caller_arg(x)) {
  if (rlang::is_empty(x)) {
    cli::cli_abort(
      "The {.arg {arg_name}} argument cannot be empty.",
      call = get_cli_abort_call()
    )
  }
  invisible(x)
}

#' Check Keys Uniquely Identify Rows
#'
#' @param data data frame to check
#' @param keys character vector of key column names
#' @param arg_name name of argument for error message
#'
#' @return invisible NULL
#' @keywords internal
#' @noRd
.check_keys_unique <- function(data, keys, arg_name) {
  if (anyDuplicated(data[keys]) > 0) {
    duplicated_keys <- .format_duplicate_keys(data, keys)

    cli::cli_abort(
      c(
        "!" = "Duplicate key combinations detected in {.arg {arg_name}}.",
        "i" = "Key columns: {.val {keys}}.",
        duplicated_keys
      ),
      call = get_cli_abort_call()
    )
  }

  invisible(NULL)
}

#' Format Duplicate Keys for Error Message
#'
#' @param data data frame
#' @param keys character vector of key column names
#'
#' @return character vector of formatted duplicate key descriptions
#' @keywords internal
#' @noRd
.format_duplicate_keys <- function(data, keys, limit = 5L) {
  key_data <- dplyr::select(data, dplyr::all_of(keys))
  duplicated_rows <- duplicated(key_data) | duplicated(key_data, fromLast = TRUE)

  if (!any(duplicated_rows)) {
    return(character())
  }

  unique_duplicates <- utils::head(unique(key_data[duplicated_rows, , drop = FALSE]), limit)

  vapply(
    seq_len(nrow(unique_duplicates)),
    function(row_index) {
      row <- unique_duplicates[row_index, , drop = FALSE]
      formatted <- vapply(
        names(row),
        function(column) {
          value <- row[[column]]
          paste0(column, " = ", .format_key_value(value))
        },
        character(1)
      )
      paste(formatted, collapse = ", ")
    },
    character(1)
  ) %>%
    paste0("- ", x = .)
}

#' Format a Single Key Value
#'
#' @param value value to format
#'
#' @return formatted string
#' @keywords internal
#' @noRd
.format_key_value <- function(value) {
  value <- value[[1]]

  if (is.factor(value)) {
    value <- as.character(value)
  }

  if (is.character(value)) {
    if (is.na(value)) {
      return("NA")
    }
    return(encodeString(value, quote = "\""))
  }

  if (is.logical(value)) {
    if (is.na(value)) {
      return("NA")
    }
    return(if (value) "TRUE" else "FALSE")
  }

  if (is.numeric(value)) {
    if (is.na(value)) {
      return("NA")
    }
    return(format(value, trim = TRUE))
  }

  if (inherits(value, "Date") || inherits(value, "POSIXt")) {
    if (is.na(value)) {
      return("NA")
    }
    return(encodeString(as.character(value), quote = "\""))
  }

  value_chr <- as.character(value)
  if (length(value_chr) == 0 || is.na(value_chr)) {
    return("NA")
  }

  encodeString(value_chr, quote = "\"")
}

#' Compare Rows Between Two ARDs
#'
#' Returns rows present in x but not in y based on key columns.
#'
#' @param x (`card`)\cr first ARD
#' @param y (`card`)\cr second ARD
#' @param keys character vector of key column names
#'
#' @return data frame of rows in x not in y
#' @keywords internal
#' @noRd
.compare_rows <- function(x, y, keys) {
  dplyr::anti_join(
    dplyr::select(x, dplyr::all_of(keys)),
    dplyr::select(y, dplyr::all_of(keys)),
    by = keys
  )
}

#' Compare Columns Between Two ARDs
#'
#' Loops through columns to compare and returns a named list of data frames
#' where each data frame contains rows that are not equal between x and y.
#'
#' @param x (`card`)\cr first ARD
#' @param y (`card`)\cr second ARD
#' @param keys character vector of key column names
#' @param compare character vector of column names to compare
#'
#' @return named list of data frames with mismatched rows
#' @keywords internal
#' @noRd
.compare_columns <- function(x, y, keys, compare, tolerance, check.attributes) {
  # select relevant columns
  x <- x[c(keys, compare)]
  y <- y[c(keys, compare)]

  # perform inner join to compare only matching rows
  comparison <- dplyr::inner_join(
    x,
    y,
    by = keys,
    suffix = c(".x", ".y")
  )

  # build mismatch data frame for each compare column
  lapply(
    stats::setNames(compare, compare),
    function(column) {
      column_x <- paste0(column, ".x")
      column_y <- paste0(column, ".y")

      # find rows where values differ
      diffs <- mapply(
        all.equal,
        comparison[[column_x]],
        comparison[[column_y]],
        MoreArgs = list(tolerance = tolerance, check.attributes = check.attributes),
        SIMPLIFY = FALSE,
        USE.NAMES = FALSE
      )

      is_equal <- vapply(diffs, isTRUE, logical(1))
      mismatches <- comparison[!is_equal, , drop = FALSE]
      mismatches$difference <- diffs[!is_equal]

      dplyr::select(
        mismatches,
        dplyr::all_of(c(keys, column_x, column_y)),
        "difference"
      )
    }
  )
}

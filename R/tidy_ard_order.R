#' Standard Order of ARD
#'
#' @description
#' ARD functions for relocating columns and rows to the standard order.
#'
#' - `tidy_ard_column_order()` relocates columns of the ARD to the standard order.
#'
#' - `tidy_ard_row_order()` orders rows of ARD according to groups and
#'   strata (group 1, then group2, etc), while retaining the column order of the input ARD.
#'
#' @param x (`data.frame`)\cr
#'   an ARD data frame of class 'card'
#' @param group_order (`string`)\cr
#'   specifies the ordering of the grouping variables.
#'   Must be one of `c("ascending", "descending")`.
#'   Default is `"ascending"`, where grouping variables begin with `"group1"` variables,
#'   followed by `"group2"` variables, etc.
#'
#' @return an ARD data frame of class 'card'
#' @name tidy_ard_order
#'
#' @examples
#' # order columns
#' ard <-
#'   dplyr::bind_rows(
#'     ard_summary(mtcars, variables = "mpg"),
#'     ard_summary(mtcars, variables = "mpg", by = "cyl")
#'   )
#'
#' tidy_ard_column_order(ard) |>
#'   tidy_ard_row_order()
NULL

#' @rdname tidy_ard_order
#' @export
tidy_ard_column_order <- function(x, group_order = c("ascending", "descending")) {
  set_cli_abort_call()
  group_order <- arg_match(group_order)

  nms <- names(x)
  group_cols <- grep("^group[0-9]+$", nms, value = TRUE)
  group_level_cols <- grep("^group[0-9]+_level$", nms, value = TRUE)
  all_group_cols <- c(group_cols, group_level_cols)

  if (length(all_group_cols) > 0) {
    nums <- as.integer(gsub("[^0-9]", "", all_group_cols))
    if (group_order == "ascending") {
      o <- order(nums, all_group_cols)
    } else {
      o <- order(-nums, all_group_cols)
    }
    ordered_groups <- all_group_cols[o]
  } else {
    ordered_groups <- character(0)
  }

  var_cols <- grep("^variable[0-9]*$", nms, value = TRUE)
  var_lvl_cols <- grep("^variable[0-9]*_level$", nms, value = TRUE)
  all_var_cols <- c(var_cols, var_lvl_cols)

  std_cols <- intersect(c(
    "context",
    "stat_name", "stat_label", "stat", "stat_fmt", "fmt_fun",
    "warning", "error"
  ), nms)

  other_cols <- setdiff(nms, c(ordered_groups, all_var_cols, std_cols))

  new_cols <- c(ordered_groups, all_var_cols, std_cols, other_cols)

  x[, new_cols, drop = FALSE]
}


#' @rdname tidy_ard_order
#' @export
tidy_ard_row_order <- function(x) {
  set_cli_abort_call()

  nms <- names(x)
  group_cols <- grep("^group[0-9]+$", nms, value = TRUE)
  group_lvl_cols <- grep("^group[0-9]+_level$", nms, value = TRUE)
  cols <- c(group_cols, group_lvl_cols)

  if (length(cols) > 0) {
    nums <- as.integer(gsub("[^0-9]", "", cols))
    max_group_n <- max(nums)

    target_cols <- character(0)
    for (i in seq_len(max_group_n)) {
      target_cols <- c(target_cols, paste0("group", i), paste0("group", i, "_level"))
    }
    cols <- intersect(target_cols, cols)

    if (length(cols) > 0) {
      order_list <- lapply(cols, function(col) match(x[[col]], unique(x[[col]])))
      o <- do.call(order, order_list)
      x <- x[o, , drop = FALSE]
      rownames(x) <- NULL
    }
  }

  x
}

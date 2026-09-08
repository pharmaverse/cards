#' ARD Nesting
#'
#' @description
#' This function is similar to [tidyr::nest()], except that it retains
#' rows for unobserved combinations (and unobserved factor levels) of by
#' variables, and unobserved combinations of stratifying variables.
#'
#' The levels are wrapped in lists so they can be stacked with other types
#' of different classes.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param by,strata (`character`)\cr
#'   columns to nest by/stratify by. Arguments are similar,
#'   but with an important distinction:
#'
#'   `by`: data frame is nested by **all combinations** of the columns specified,
#'   including unobserved combinations and unobserved factor levels.
#'
#'   `strata`: data frame is nested by **all _observed_ combinations** of the
#'   columns specified.
#'
#'   Arguments may be used in conjunction with one another.
#' @param key (`string`)\cr
#'   the name of the new column with the nested data frame. Default is `"data"`.
#' @param rename_columns (`logical`)\cr
#'   logical indicating whether to rename the `by` and `strata` variables.
#'   Default is `TRUE`.
#' @param list_columns (`logical`)\cr
#'   logical indicating whether to put levels of `by` and
#'   `strata` columns in a list. Default is `TRUE`.
#' @param include_data (scalar `logical`)\cr
#'   logical indicating whether to include the data subsets as a list-column.
#'   Default is `TRUE`.
#' @param include_by_and_strata (`logical`)\cr
#'   When `TRUE`, the `by` and `strata` variables are included in the nested
#'   data frames.
#'
#' @return a nested tibble
#' @export
#'
#' @examples
#' nest_for_ard(
#'   data =
#'     ADAE |>
#'       dplyr::left_join(ADSL[c("USUBJID", "ARM")], by = "USUBJID") |>
#'       dplyr::filter(AOCCSFL %in% "Y"),
#'   by = "ARM",
#'   strata = "AESOC"
#' )
nest_for_ard <- function(data, by = NULL, strata = NULL, key = "data",
                         rename_columns = TRUE, list_columns = TRUE,
                         include_data = TRUE,
                         include_by_and_strata = FALSE) {
  set_cli_abort_call()

  # if no by/stratifying variables, simply return the data frame
  if (is_empty(by) && is_empty(strata)) {
    return((dplyr::tibble("{key}" := list(data))))
  }

  n_missing <- nrow(data) - nrow(tidyr::drop_na(data, all_of(by), all_of(strata)))
  if (n_missing > 0L) {
    cli::cli_inform("{n_missing} missing observation{?s} in the {.val {c(by, strata)}} column{?s} have been removed.")
  }

  # create nested strata data --------------------------------------------------
  if (!is_empty(strata)) {
    df_strata <-
      data[strata] |>
      tidyr::drop_na() |>
      dplyr::distinct() |>
      dplyr::arrange(across(all_of(strata)))
  }

  # create nested by data --------------------------------------------------
  if (!is_empty(by)) {
    # get a named list of all unique values for each by variable (including unobserved levels)
    lst_unique_vals <-
      by |>
      lapply(FUN = function(x) data[[x]] |> .unique_and_sorted()) |>
      stats::setNames(nm = by)

    # convert that list to a data frame with one row per unique combination
    df_by <- tidyr::expand_grid(!!!lst_unique_vals)
  }

  # combining by and strata data sets into one, as needed ----------------------
  if (!is_empty(by) && is_empty(strata)) {
    df_return <- df_by
  } else if (is_empty(by) && !is_empty(strata)) {
    df_return <- df_strata
  } else if (!is_empty(by) && !is_empty(strata)) {
    df_return <-
      df_strata |>
      dplyr::mutate(
        "{key}" := list(df_by),
        .before = 0L
      ) |>
      tidyr::unnest(cols = all_of(key))
  }

  # we will now add a column to the df_return data frame of the subsetted data
  #   to do so, we partition the row indices in a single pass and slice
  if (isTRUE(include_data)) {
    cols_to_keep <- if (!include_by_and_strata) setdiff(names(data), c(by, strata)) else names(data)
    data_to_slice <- data[cols_to_keep]

    m <- vctrs::vec_match(data[names(df_return)], df_return)
    n_groups <- nrow(df_return)
    idx_list <- split(seq_len(nrow(data)), factor(m, levels = seq_len(n_groups)))
    res_list <- lapply(idx_list, function(idx) {
      sub <- data_to_slice[idx, , drop = FALSE]
      rownames(sub) <- NULL
      sub
    })
    names(res_list) <- NULL
    df_return[[key]] <- res_list
  }

  # put variable levels in list to preserve types when stacked -----------------
  if (isTRUE(list_columns)) {
    cols_to_list <- setdiff(names(df_return), key)
    for (col in cols_to_list) {
      df_return[[col]] <- as.list(df_return[[col]])
    }
  }

  # rename by and strata columns to group## and group##_level ------------------
  if (isTRUE(rename_columns)) {
    df_return <-
      df_return |>
      .nesting_rename_ard_columns(by = by, strata = strata)
  }

  # returning final nested tibble ----------------------------------------------
  ard_final <- df_return |>
    dplyr::as_tibble()

  # append attributes ----------------------------------------------------------
  attr(ard_final, "args") <- list(
    by = by,
    strata = strata
  )

  ard_final
}

#' Rename ARD Columns
#'
#' If `variable` is provided, adds the standard `variable` column to `x`. If `by`/`strata` are
#' provided, adds the standard `group##` column(s) to `x` and renames the provided columns to
#' `group##_level` in `x`, where `##` is determined by the column's position in `c(by, strata)`.
#'
#' @param x (`data.frame`)\cr
#'   a data frame
#' @param variable (`character`)\cr
#'   name of `variable` column in `x`. Default is `NULL`.
#' @param by (`character`)\cr
#'   character vector of names of `by` columns in `x`. Default is `NULL`.
#' @param strata (`character`)\cr
#'   character vector of names of `strata` columns in `x`. Default is `NULL`.
#'
#' @return a tibble
#' @keywords internal
#'
#' @examples
#' ard <- nest_for_ard(
#'   data =
#'     ADAE |>
#'       dplyr::left_join(ADSL[c("USUBJID", "ARM")], by = "USUBJID") |>
#'       dplyr::filter(AOCCSFL %in% "Y"),
#'   by = "ARM",
#'   strata = "AESOC",
#'   rename_columns = FALSE
#' )
#'
#' cards:::.nesting_rename_ard_columns(ard, by = "ARM", strata = "AESOC")
.nesting_rename_ard_columns <- function(x, variable = NULL, by = NULL, strata = NULL) {
  if (!is_empty(variable)) {
    x <-
      x |>
      dplyr::rename(variable_level = !!sym(variable)) |>
      dplyr::mutate(variable = .env$variable, .before = 0L)
  }
  if (!is_empty(by) || !is_empty(strata)) {
    x <-
      x |>
      dplyr::mutate(!!!(as.list(c(by, strata)) |> stats::setNames(paste0("group", seq_along(c(strata, by))))), .before = 0L) |>
      dplyr::rename(!!!(as.list(c(by, strata)) |> stats::setNames(paste0("group", seq_along(c(strata, by)), "_level"))))
  }

  tidy_ard_column_order(x)
}

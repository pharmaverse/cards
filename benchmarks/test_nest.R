library(cards)
library(dplyr)
data_big <- gtsummary::trial[rep(seq_len(nrow(gtsummary::trial)), 2), ]

res1 <- cards::nest_for_ard(
  data_big,
  by = "trt",
  strata = "grade"
)

# Implementation of the optimized version
nest_for_ard2 <- function(data, by = NULL, strata = NULL, key = "data",
                          rename_columns = TRUE, list_columns = TRUE,
                          include_data = TRUE,
                          include_by_and_strata = FALSE) {
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
    lst_unique_vals <-
      by |>
      lapply(FUN = function(x) data[[x]] |> cards:::.unique_and_sorted()) |>
      stats::setNames(nm = by)

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

  if (isTRUE(include_data)) {
    # Optimized subsetting logic using inner_join
    cols_to_keep <- if (!include_by_and_strata) {
      setdiff(names(data), c(by, strata))
    } else {
      names(data)
    }

    # Left join to find group index for each row
    df_return_idx <- df_return
    df_return_idx[["..group_idx.."]] <- seq_len(nrow(df_return))

    data_mapped <- dplyr::inner_join(
      data |> dplyr::mutate("..row_idx.." = seq_len(nrow(data))),
      df_return_idx[c(by, strata, "..group_idx..")],
      by = c(by, strata)
    )

    row_indices <- split(
      data_mapped[["..row_idx.."]],
      factor(data_mapped[["..group_idx.."]], levels = seq_len(nrow(df_return)))
    )

    df_return[[key]] <- lapply(
      row_indices,
      function(idx) {
        # drop = FALSE handles the case when there's only 1 column
        data[idx, cols_to_keep, drop = FALSE]
      }
    )
  }

  # put variable levels in list to preserve types when stacked -----------------
  if (isTRUE(list_columns)) {
    df_return <-
      df_return |>
      dplyr::mutate(across(.cols = -any_of(key), .fns = as.list))
  }

  # rename by and strata columns to group## and group##_level ------------------
  if (isTRUE(rename_columns)) {
    df_return <-
      df_return |>
      cards:::.nesting_rename_ard_columns(by = by, strata = strata)
  }

  ard_final <- df_return |>
    dplyr::as_tibble()

  attr(ard_final, "args") <- list(
    by = by,
    strata = strata
  )

  ard_final
}

res2 <- nest_for_ard2(
  data_big,
  by = "trt",
  strata = "grade"
)

cat("Identical? ", identical(res1, res2), "\n")

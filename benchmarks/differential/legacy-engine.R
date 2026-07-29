# Legacy ard_tabulate() counting engine ---------------------------------------
# Verbatim copy of the five engine functions from R/ard_tabulate.R as of the
# fork point of the #176 performance rewrite (cards 0.8.1.9000, commit of
# main at branch time). DO NOT EDIT. Used by run-differential.R, which swaps
# these into the cards namespace with utils::assignInNamespace() to compare
# legacy vs rewritten engine output in a single session.
#
# This file is sourced into an environment whose parent is asNamespace("cards"),
# so all other internal helpers (.unique_and_sorted, .nesting_rename_ard_columns,
# imap, compact, etc.) resolve from the installed/loaded package.

.calculate_tabulation_statistics <- function(data,
                                             variables,
                                             by,
                                             strata,
                                             denominator,
                                             statistic) {
  # extract the "tabulation" statistics.
  statistics_tabulation <-
    lapply(statistic, function(x) x["tabulation"] |> compact()) |> compact()

  if (is_empty(statistics_tabulation)) {
    return(dplyr::tibble())
  }

  # first process the denominator
  lst_denominator <-
    .process_denominator(
      data = data,
      variables =
        imap(
          statistics_tabulation,
          function(x, variable) {
            if (any(c("N", "p", "p_cum") %in% x[["tabulation"]])) {
              TRUE
            } else {
              NULL
            }
          }
        ) |>
          compact() |>
          names(),
      denominator = denominator,
      by = by,
      strata = strata
    )

  # perform other counts
  df_result_tabulation <-
    imap(
      statistics_tabulation,
      function(tab_stats, variable) {
        df_result_tabulation <-
          .table_as_df(data, variable = variable, by = by, strata = strata, count_column = "...ard_n...")
        if (!is_empty(lst_denominator[[variable]])) {
          df_result_tabulation <-
            if (is_empty(intersect(names(df_result_tabulation), names(lst_denominator[[variable]])))) {
              dplyr::cross_join(
                df_result_tabulation,
                lst_denominator[[variable]]
              )
            } else {
              suppressMessages(dplyr::left_join(
                df_result_tabulation,
                lst_denominator[[variable]]
              ))
            }
        }
        if (any(c("p", "p_cum") %in% tab_stats[["tabulation"]])) {
          df_result_tabulation <-
            df_result_tabulation |>
            dplyr::mutate(
              ...ard_p... = .data$...ard_n... / .data$...ard_N...
            )
        }

        df_result_tabulation <-
          .add_cum_count_stats(
            df_result_tabulation,
            variable = variable,
            by = by,
            strata = strata,
            denominator = denominator,
            tab_stats = tab_stats
          )

        df_res <- .nesting_rename_ard_columns(df_result_tabulation, variable = variable, by = by, strata = strata)

        # Convert grouping columns to list
        for (col in c(grep("^group[0-9]+_level$", names(df_res), value = TRUE), intersect(names(df_res), "variable_level"))) {
          if (!is.list(df_res[[col]])) {
            df_res[[col]] <- as.list(df_res[[col]])
          }
        }

        all_pivot_cols <- c("...ard_n...", "...ard_N...", "...ard_p...", "...ard_n_cum...", "...ard_p_cum...")
        cols_in_df <- all_pivot_cols[all_pivot_cols %in% names(df_res)]

        stat_names_clean <- gsub("...$", "", gsub("^...ard_", "", cols_in_df))

        keep_idx <- stat_names_clean %in% tab_stats[["tabulation"]]
        cols_to_pivot <- cols_in_df[keep_idx]
        stat_names_clean <- stat_names_clean[keep_idx]

        if (length(cols_to_pivot) == 0) {
          return(dplyr::tibble())
        }

        n_rows <- nrow(df_res)
        n_cols <- length(cols_to_pivot)

        # We must drop all potential pivot columns that weren't selected to match pivot_longer behavior
        fixed_cols <- setdiff(names(df_res), cols_in_df)
        df_out <- df_res[fixed_cols]
        df_out <- df_out[rep(seq_len(n_rows), each = n_cols), , drop = FALSE]

        df_out$stat_name <- rep(stat_names_clean, times = n_rows)

        stat_list <- vector("list", n_rows * n_cols)
        for (i in seq_along(cols_to_pivot)) {
          indices <- seq(i, length(stat_list), by = n_cols)
          stat_list[indices] <- as.list(df_res[[cols_to_pivot[i]]])
        }
        df_out$stat <- stat_list

        dplyr::as_tibble(df_out)
      }
    ) |>
    dplyr::bind_rows()

  df_result_tabulation |>
    dplyr::mutate(
      warning = list(NULL),
      error = list(NULL)
    )
}

.add_cum_count_stats <- function(x, variable, by, strata, denominator, tab_stats) {
  # if no cumulative stats were requested, return the object
  if (!any(c("p_cum", "n_cum") %in% tab_stats[["tabulation"]])) {
    return(x)
  }

  # to return cumulative stats, the denominator must be 'column' or 'row'
  if (!is_string(denominator) || !denominator %in% c("column", "row")) {
    cli::cli_abort(
      "The {.arg denominator} argument must be one of {.val {c(\"column\", \"row\")}}
       when cumulative statistics {.val n_cum} or {.val p_cum} are specified, which
       were requested for variable {.var {variable}}.",
      call = get_cli_abort_call()
    )
  }

  # calculate the cumulative statistics
  if (denominator %in% "column") {
    x <- x |>
      dplyr::mutate(
        .by = any_of(c(by, strata)),
        ...ard_n_cum... = switch("n_cum" %in% tab_stats[["tabulation"]],
          cumsum(.data$...ard_n...)
        ),
        ...ard_p_cum... = switch("p_cum" %in% tab_stats[["tabulation"]],
          cumsum(.data$...ard_p...)
        )
      )
  } else if (denominator %in% "row") {
    x <- x |>
      dplyr::mutate(
        .by = any_of(variable),
        ...ard_n_cum... = switch("n_cum" %in% tab_stats[["tabulation"]],
          cumsum(.data$...ard_n...)
        ),
        ...ard_p_cum... = switch("p_cum" %in% tab_stats[["tabulation"]],
          cumsum(.data$...ard_p...)
        )
      )
  }

  x
}

.table_as_df <- function(data, variable = NULL, by = NULL, strata = NULL,
                         useNA = c("no", "always"), count_column = "...ard_n...") {
  useNA <- match.arg(useNA)
  # tabulate results and save in data frame
  ...ard_tab_vars... <- c(by, strata, variable)
  ...ard_tab... <-
    data[...ard_tab_vars...] |>
    dplyr::mutate(across(where(is.logical), ~ factor(., levels = c("FALSE", "TRUE")))) |>
    with(inject(table(!!!syms(...ard_tab_vars...), useNA = !!useNA)))

  # replace NA dimnames with placeholder to avoid R-devel error in as.data.frame()
  ...ard_na_placeholder... <- "___cards_table_NA_PLACEHOLDER___"
  dimnames(...ard_tab...) <- lapply(dimnames(...ard_tab...), function(x) {
    x[is.na(x)] <- ...ard_na_placeholder...
    x
  })

  df_table <-
    ...ard_tab... |>
    dplyr::as_tibble(n = count_column) |>
    dplyr::mutate(across(all_of(...ard_tab_vars...), ~ dplyr::na_if(., ...ard_na_placeholder...)))

  # construct a matching data frame with the variables in their original type/class
  df_original_types <-
    lapply(
      c(by, strata, variable),
      function(x) .unique_and_sorted(data[[x]], useNA = useNA)
    ) |>
    stats::setNames(c(by, strata, variable)) %>%
    {tidyr::expand_grid(!!!.)} |> # styler: off
    arrange_using_order(rev(...ard_tab_vars...))

  # if all columns match, then replace the coerced character cols with their original type/class
  all_cols_equal <-
    every(
      c(by, strata, variable),
      ~ all(
        df_table[[.x]] == as.character(df_original_types[[.x]]) | (is.na(df_table[[.x]]) & is.na(df_original_types[[.x]]))
      )
    )
  if (isTRUE(all_cols_equal)) {
    df_table <-
      dplyr::bind_cols(df_original_types, df_table[count_column], .name_repair = "minimal")
  }
  # I hope this message is never triggered!
  else {
    cli::cli_inform(c(
      "If you see this message, the order of the sorted variables in the tabulaton is unexpected, which could cause downstream issues.",
      "*" = "Please post a reproducible example to {.url https://github.com/insightsengineering/cards/issues/new}, so we can address in the next release.",
      "i" = "You can create a minimal reproducible example with {.fun reprex::reprex}."
    ))
  }

  # if strata is present, remove unobserved rows
  if (!is_empty(strata)) {
    # if we were not able to maintain the original type, convert strata to character
    if (!isTRUE(all_cols_equal)) {
      df_original_strata <- dplyr::distinct(data[strata]) |>
        apply(MARGIN = 2, FUN = as.character)
    } else {
      df_original_strata <- dplyr::distinct(data[strata])
    }

    df_table <-
      dplyr::left_join(
        df_original_strata |> dplyr::arrange(across(all_of(strata))),
        df_table,
        by = strata
      ) |>
      dplyr::select(all_of(names(df_table)))
  }

  df_table
}

# like `dplyr::arrange()`, but uses base R's `order()` to keep consistency in some edge cases
arrange_using_order <- function(data, columns) {
  inject(data[with(data, order(!!!syms(columns))), ])
}

.process_denominator <- function(data, variables, denominator, by, strata) {
  if (is_empty(variables)) {
    return(list())
  }
  # if no by/strata and no denominator (or column), then use number of non-missing in variable
  if ((is.null(denominator) || isTRUE(denominator %in% "column")) && is_empty(c(by, strata))) {
    lst_denominator <-
      lapply(
        variables,
        function(variable) dplyr::tibble(...ard_N... = sum(!is.na(data[[variable]])))
      ) |>
      stats::setNames(variables)
  }
  # if by/strata present and no denominator (or denominator="column"), then use number of non-missing variables
  else if (is.null(denominator) || isTRUE(denominator %in% "column")) {
    lst_denominator <-
      lapply(
        variables,
        function(variable) {
          .table_as_df(
            data,
            variable = variable,
            by = by,
            strata = strata,
            count_column = "...ard_N...",
            useNA = "always"
          ) |>
            tidyr::drop_na(all_of(c(by, strata, variable))) |>
            dplyr::summarise(
              .by = all_of(c(by, strata)),
              ...ard_N... = sum(.data$...ard_N...)
            )
        }
      ) |>
      stats::setNames(variables)
  }
  # if user passed a data frame WITHOUT the counts pre-specified and no by/strata
  else if (is.data.frame(denominator) &&
    !"...ard_N..." %in% names(denominator) &&
    is_empty(intersect(c(by, strata), names(denominator)))) {
    lst_denominator <-
      rep_named(
        variables,
        list(dplyr::tibble(...ard_N... = nrow(denominator)))
      )
  }
  # if user passed a data frame WITHOUT the counts pre-specified with by/strata
  else if (is.data.frame(denominator) && !"...ard_N..." %in% names(denominator)) {
    .check_for_missing_combos_in_denom(
      data,
      denominator = denominator, by = by, strata = strata
    )

    lst_denominator <-
      rep_named(
        variables,
        list(
          .table_as_df(
            denominator,
            by = intersect(by, names(denominator)),
            strata = intersect(strata, names(denominator)),
            count_column = "...ard_N...",
            useNA = "always"
          ) |>
            tidyr::drop_na(any_of(c(by, strata)))
        )
      )
  }
  # if user requested cell percentages
  else if (isTRUE(denominator %in% "cell")) {
    lst_denominator <-
      lapply(
        variables,
        function(variable) {
          dplyr::tibble(
            ...ard_N... =
              tidyr::drop_na(data, all_of(c(by, strata, variable))) |> nrow()
          )
        }
      ) |>
      stats::setNames(variables)
  }
  # if user requested row percentages
  else if (isTRUE(denominator %in% "row")) {
    lst_denominator <-
      lapply(
        variables,
        function(variable) {
          .table_as_df(
            data,
            variable = variable,
            by = by,
            strata = strata,
            count_column = "...ard_N...",
            useNA = "always"
          ) |>
            tidyr::drop_na(all_of(c(by, strata, variable))) |>
            dplyr::summarise(
              .by = all_of(variable),
              ...ard_N... = sum(.data$...ard_N...)
            )
        }
      ) |>
      stats::setNames(variables)
  }
  # if user passed a single integer
  else if (is_scalar_integerish(denominator)) {
    lst_denominator <-
      rep_named(
        variables,
        list(dplyr::tibble(...ard_N... = as.integer(denominator)))
      )
  }
  # if user passed a data frame WITH the counts pre-specified
  else if (is.data.frame(denominator) && "...ard_N..." %in% names(denominator)) {
    # check there are no duplicates in by/strata variables
    if (
      (any(c(by, strata) %in% names(denominator)) && any(duplicated(denominator[c(by, strata)]))) ||
        (!any(c(by, strata) %in% names(denominator)) && nrow(denominator) > 1L)
    ) {
      paste(
        "Specified counts in column {.val '...ard_N...'} are not unique in",
        "the {.arg denominator} argument across the {.arg by} and {.arg strata} columns."
      ) |>
        cli::cli_abort(call = get_cli_abort_call())
    }
    .check_for_missing_combos_in_denom(
      data,
      denominator = denominator, by = by, strata = strata
    )

    # making the by/strata columns character to merge them with the count data frames
    df_denom <-
      denominator |>
      dplyr::select(any_of(c(by, strata, "...ard_N..."))) |>
      tidyr::drop_na() |>
      dplyr::mutate(across(any_of(c(by, strata)), as.character))

    lst_denominator <-
      rep_named(variables, list(df_denom))
  } else {
    cli::cli_abort("The {.arg denominator} argument has been mis-specified.", call = get_cli_abort_call())
  }

  lst_denominator
}

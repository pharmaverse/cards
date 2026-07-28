#' Tabulate ARD
#'
#' Compute Analysis Results Data (ARD) for categorical summary statistics.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param by,strata ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns to use for grouping or stratifying the table output.
#'   Arguments are similar, but with an important distinction:
#'
#'   `by`: results are tabulated by **all combinations** of the columns specified,
#'      including unobserved combinations and unobserved factor levels.
#'
#'   `strata`: results are tabulated by **all _observed_ combinations** of the
#'     columns specified.
#'
#'   Arguments may be used in conjunction with one another.
#' @param variables ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns to include in summaries. Default is `everything()`.
#' @param denominator (`string`, `data.frame`, `integer`)\cr
#'   Specify this argument to change the denominator,
#'   e.g. the `"N"` statistic. Default is `'column'`. See below for details.
#' @param statistic ([`formula-list-selector`][syntax])\cr
#'   a named list, a list of formulas,
#'   or a single formula where the list element one or more of  `c("n", "N", "p", "n_cum", "p_cum")`
#'   (on the RHS of a formula).
#' @param stat_label ([`formula-list-selector`][syntax])\cr
#'   a named list, a list of formulas, or a single formula where
#'   the list element is either a named list or a list of formulas defining the
#'   statistic labels, e.g. `everything() ~ list(n = "n", p = "pct")` or
#'   `everything() ~ list(n ~ "n", p ~ "pct")`.
#' @inheritParams ard_summary
#'
#' @section Denominators:
#' By default, the `ard_tabulate()` function returns the statistics `"n"`, `"N"`, and
#' `"p"`, where little `"n"` are the counts for the variable levels, and big `"N"` is
#' the number of non-missing observations. The calculation for the
#' proportion is  `p = n/N`.
#'
#' However, it is sometimes necessary to provide a different `"N"` to use
#' as the denominator in this calculation. For example, in a calculation
#' of the rates of various observed adverse events, you may need to update the
#' denominator to the number of enrolled subjects.
#'
#' In such cases, use the `denominator` argument to specify a new definition
#' of `"N"`, and subsequently `"p"`.
#' The argument expects one of the following inputs:
#' - a string: one of `"column"`, `"row"`, or `"cell"`.
#'     - `"column"`, the default, returns percentages where the sum is equal to
#'        one within the variable after the data frame has been subset with `by`/`strata`.
#'     - `"row"` gives 'row' percentages where `by`/`strata` columns are the 'top'
#'        of a cross table, and the variables are the rows. This is well-defined
#'        for a single `by` or `strata` variable, and care must be taken when there
#'        are more to ensure the the results are as you expect.
#'   - `"cell"` gives percentages where the denominator is the number of non-missing
#'        rows in the source data frame.
#' - a data frame. Any columns in the data frame that overlap with the `by`/`strata`
#'   columns will be used to calculate the new `"N"`.
#' - an integer. This single integer will be used as the new `"N"`
#' - a structured data frame. The data frame will include columns from `by`/`strata`.
#'   The last column must be named `"...ard_N..."`. The integers in this column will
#'   be used as the updated `"N"` in the calculations.
#'
#' When the `p` statistic is returned, the proportion is returned---bounded by `[0, 1]`.
#' The default function to format the statistic scales the proportion by 100
#' and the percentage is returned which matches the default statistic label of `'%'`.
#' To get the formatted values, pass the ARD to `apply_fmt_fun()`.
#'
#'
#' @return an ARD data frame of class 'card'
#' @name ard_tabulate
#'
#' @examples
#' ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
#'
#' ADSL |>
#'   dplyr::group_by(ARM) |>
#'   ard_tabulate(
#'     variables = "AGEGR1",
#'     statistic = everything() ~ "n"
#'   )
NULL

#' @rdname ard_tabulate
#' @export
ard_tabulate <- function(data, ...) {
  check_not_missing(data)
  UseMethod("ard_tabulate")
}

#' @rdname ard_tabulate
#' @export
ard_tabulate.data.frame <- function(data,
                                    variables,
                                    by = dplyr::group_vars(data),
                                    strata = NULL,
                                    statistic = everything() ~ c("n", "p", "N"),
                                    denominator = "column",
                                    fmt_fun = NULL,
                                    stat_label = everything() ~ default_stat_labels(),
                                    fmt_fn = deprecated(),
                                    ...) {
  set_cli_abort_call()
  check_dots_used()

  # deprecated args ------------------------------------------------------------
  if (lifecycle::is_present(fmt_fn)) {
    lifecycle::deprecate_warn(
      when = "0.6.1",
      what = "ard_tabulate(fmt_fn)",
      with = "ard_tabulate(fmt_fun)"
    )
    fmt_fun <- fmt_fn
  }

  # check inputs ---------------------------------------------------------------
  check_not_missing(variables)
  .check_no_ard_columns(data)

  # process arguments ----------------------------------------------------------
  process_selectors(
    data,
    variables = {{ variables }},
    by = {{ by }},
    strata = {{ strata }}
  )
  data <- dplyr::ungroup(data)
  .check_whether_na_counts(data[variables])

  process_formula_selectors(
    data[variables],
    statistic = statistic,
    stat_label = stat_label,
    fmt_fun = fmt_fun
  )
  fill_formula_selectors(
    data[variables],
    statistic = formals(asNamespace("cards")[["ard_tabulate.data.frame"]])[["statistic"]] |> eval()
  )
  check_list_elements(
    x = statistic,
    predicate = \(x) is.character(x) && all(x %in% c("n", "p", "N", "n_cum", "p_cum")),
    error_msg = "Elements passed in the {.arg statistic} argument must be one or more of {.val {c('n', 'p', 'N', 'n_cum', 'p_cum')}}"
  )

  # return empty ARD if no variables selected ----------------------------------
  if (is_empty(variables)) {
    return(dplyr::tibble() |> as_card(check = FALSE))
  }

  # return note about column names that result in errors -----------------------
  if (any(by %in% c("variable", "variable_level"))) {
    cli::cli_abort(
      "The {.arg by} argument cannot include variables named {.val {c('variable', 'variable_level')}}.",
      call = get_cli_abort_call()
    )
  }


  # check factor levels --------------------------------------------------------
  check_no_na_factor_levels(data[c(variables, by, strata)])
  check_factor_has_levels(data[c(variables, by, strata)])

  # check for column class mis-matches -----------------------------------------
  if (is.data.frame(denominator)) {
    denom_names <- names(denominator)
    for (v in c(by, strata)) {
      if (v %in% denom_names && !identical(class(data[[v]]), class(denominator[[v]]))) {
        cli::cli_inform(
          "The classes for column {.val {v}} in {.arg data} ({.cls {class(data[[v]])}})
          and {.arg denominator} ({.cls {class(denominator[[v]])}}) do not match,
          which {.emph may} cause downstream issues."
        )
      }
    }
  }

  # calculating summary stats --------------------------------------------------
  # calculate tabulation statistics
  df_result_tabulation <-
    .calculate_tabulation_statistics(
      data,
      variables = variables,
      by = by,
      strata = strata,
      denominator = denominator,
      statistic = lapply(statistic, \(x) list(tabulation = x))
    )


  # final processing of fmt_fun ------------------------------------------------
  df_result_final <-
    df_result_tabulation |>
    .process_nested_list_as_df(
      arg = fmt_fun,
      new_column = "fmt_fun"
    ) |>
    .default_fmt_fun()

  # final processing of stat labels --------------------------------------------
  df_result_final <-
    .process_nested_list_as_df(
      x = df_result_final,
      arg = stat_label,
      new_column = "stat_label",
      unlist = TRUE
    ) |>
    dplyr::mutate(
      stat_label =
        map2_chr(
          .data$stat_label, .data$stat_name,
          function(stat_label, stat_name) dplyr::coalesce(stat_label, default_stat_labels()[[stat_name]], stat_name)
        )
    )

  # merge in stat labels and format ARD for return -----------------------------
  ard_final <- df_result_final |>
    dplyr::mutate(context = "tabulate") |>
    tidy_ard_column_order() |>
    tidy_ard_row_order() |>
    as_card(check = FALSE)

  # append attributes ----------------------------------------------------------
  attr(ard_final, "args") <- list(
    variables = variables,
    by = by,
    strata = strata
  )

  ard_final
}


#' Calculate Tabulation Statistics
#'
#' Function takes the summary instructions from the
#' `statistic = list(variable_name = list(tabulation=c("n", "N", "p")))`
#' argument, and returns the tabulations in an ARD structure.
#'
#' @inheritParams ard_tabulate
#' @return an ARD data frame of class 'card'
#' @keywords internal
#'
#' @examples
#' cards:::.calculate_tabulation_statistics(
#'   ADSL,
#'   variables = "ARM",
#'   by = NULL,
#'   strata = NULL,
#'   denominator = "cell",
#'   statistic = list(ARM = list(tabulation = c("N")))
#' )
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

.check_whether_na_counts <- function(data) {
  walk(
    names(data),
    function(x) {
      if (all(is.na(data[[x]])) && !inherits(data[[x]], c("logical", "factor"))) {
        cli::cli_abort(
          c("Column {.val {x}} is all missing and cannot by tabulated.",
            i = "Only columns of class {.cls logical} and {.cls factor} can be tabulated when all values are missing."
          ),
          call = get_cli_abort_call()
        )
      }
    }
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

#' Results from `table()` as Data Frame
#'
#' Takes the results from [table()] and returns them as a data frame.
#' After the [table()] results are made into a data frame, all the variables
#' are made into character columns, and the function also restores the
#' column types to their original classes. For `strata` columns,
#' only observed combinations are returned.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param variable (`string`)\cr
#'   a string indicating a column in data
#' @param by (`character`)\cr
#'   a character vector indicating columns in data
#' @param strata (`character`)\cr
#'   a character vector indicating columns in data
#' @param useNA (`string`)\cr
#'   one of `"no"` and `"always"`. Will be passed to `table(useNA)`.
#'
#' @keywords internal
#' @return data frame
#'
#' @examples
#' cards:::.table_as_df(ADSL, variable = "ARM", by = "AGEGR1", strata = NULL)
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


#' Process `denominator` Argument
#'
#' Function takes the `ard_tabulate(denominator)` argument and returns a
#' structured data frame that is merged with the count data and used as the
#' denominator in percentage calculations.
#'
#' @inheritParams ard_tabulate
#'
#' @return a data frame
#' @keywords internal
#'
#' @examples
#' cards:::.process_denominator(mtcars, denominator = 1000, variables = "cyl", by = "gear")
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


#' Check for Missing Levels in `denominator`
#'
#' When a user passes a data frame in the `denominator` argument, this function
#' checks that the data frame contains all the same levels of the `by`
#' and `strata` variables that appear in `data`.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param denominator (`data.frame`)\cr
#'   denominator data frame
#' @param by (`character`)\cr
#'   character vector of by column names
#' @param strata (`character`)\cr
#'   character vector of strata column names
#'
#' @return returns invisible if check is successful, throws an error message if not.
#' @keywords internal
#'
#' @examples
#' cards:::.check_for_missing_combos_in_denom(ADSL, denominator = "col", by = "ARM", strata = "AGEGR1")
.check_for_missing_combos_in_denom <- function(data, denominator, by, strata) {
  by_vars_to_check <-
    c(by, strata) |>
    intersect(names(data)) |>
    intersect(names(denominator))
  if (is_empty(by_vars_to_check)) {
    return(invisible())
  }

  # find missing combinations
  df_denom_level_check <-
    dplyr::anti_join(
      data[by_vars_to_check] |> unique(),
      denominator[by_vars_to_check] |> unique(),
      by_vars_to_check
    )

  # message users of missing combination
  if (nrow(df_denom_level_check) > 0L) {
    missing_combos <-
      df_denom_level_check |>
      unique() |>
      imap(~ glue::glue("{.y} ({.x})")) |>
      dplyr::bind_cols() |>
      as.matrix() |>
      apply(
        MARGIN = 1,
        FUN = function(x) paste(x, collapse = "/"),
        simplify = FALSE
      )
    paste(
      "The following {.arg by/strata} combinations are missing from the",
      "{.arg denominator} data frame: {.val {missing_combos}}."
    ) |>
      cli::cli_abort(call = get_cli_abort_call())
  }
}

#' Case Switch
#'
#' A pipe-friendly version of a series of `if ()`, `if else ()`, and `else` statements.
#'
#' @param ... `formula`\cr
#'  LHS is the predicate condition, and RHS is the returned value when RHS is `TRUE`
#' @param .default the default value when no conditions in `...` are met.
#'
#' @returns an object
#' @noRd
case_switch <- function(..., .default = NULL) {
  dots <- dots_list(...)

  for (f in dots) {
    if (isTRUE(eval(f_lhs(f), envir = attr(f, ".Environment")))) {
      return(eval(f_rhs(f), envir = attr(f, ".Environment")))
    }
  }

  return(.default)
}

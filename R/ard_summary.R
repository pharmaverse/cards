#' Univariate ARD Statistics
#'
#' Compute Analysis Results Data (ARD) for simple continuous summary statistics.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#' @param variables ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns to include in summaries.
#' @param by,strata ([`tidy-select`][dplyr::dplyr_tidy_select])\cr
#'   columns to tabulate by/stratify by for summary statistic
#'   calculation. Arguments are similar, but with an important distinction:
#'
#'   `by`: results are calculated for **all combinations** of the columns specified,
#'      including unobserved combinations and unobserved factor levels.
#'
#'   `strata`: results are calculated for **all _observed_ combinations** of the
#'     columns specified.
#'
#'   Arguments may be used in conjunction with one another.
#' @param statistic ([`formula-list-selector`][syntax])\cr
#'   a named list, a list of formulas,
#'   or a single formula where the list element is a named list of functions
#'   (or the RHS of a formula),
#'   e.g. `list(mpg = list(mean = \(x) mean(x)))`.
#'
#'   The value assigned to each variable must also be a named list, where the names
#'   are used to reference a function and the element is the function object.
#'   Typically, this function will return a scalar statistic, but a function that
#'   returns a named list of results is also acceptable, e.g.
#'   `list(conf.low = -1, conf.high = 1)`. However, when errors occur, the messaging
#'   will be less clear in this setting.
#' @param fmt_fun ([`formula-list-selector`][syntax])\cr
#'   a named list, a list of formulas,
#'   or a single formula where the list element is a named list of functions
#'   (or the RHS of a formula),
#'   e.g. `list(mpg = list(mean = \(x) round(x, digits = 2) |> as.character()))`.
#' @param stat_label ([`formula-list-selector`][syntax])\cr
#'   a named list, a list of formulas, or a single formula where
#'   the list element is either a named list or a list of formulas defining the
#'   statistic labels, e.g. `everything() ~ list(mean = "Mean", sd = "SD")` or
#'   `everything() ~ list(mean ~ "Mean", sd ~ "SD")`.
#' @param fmt_fn `r lifecycle::badge("deprecated")`
#' @inheritParams rlang::args_dots_used
#'
#' @return an ARD data frame of class 'card'
#' @name ard_summary
#'
#' @examples
#' ard_summary(ADSL, by = "ARM", variables = "AGE")
#'
#' # if a single function returns a named list, the named
#' # results will be placed in the resulting ARD
#' ADSL |>
#'   dplyr::group_by(ARM) |>
#'   ard_summary(
#'     variables = "AGE",
#'     statistic =
#'       ~ list(conf.int = \(x) t.test(x)[["conf.int"]] |>
#'         as.list() |>
#'         setNames(c("conf.low", "conf.high")))
#'   )
NULL

#' @rdname ard_summary
#' @export
ard_summary <- function(data, ...) {
  check_not_missing(data)
  UseMethod("ard_summary")
}

#' @rdname ard_summary
#' @export
ard_summary.data.frame <- function(data,
                                   variables,
                                   by = dplyr::group_vars(data),
                                   strata = NULL,
                                   statistic = everything() ~ continuous_summary_fns(),
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
      what = "ard_summary(fmt_fn)",
      with = "ard_summary(fmt_fun)"
    )
    fmt_fun <- fmt_fn
  }

  # check inputs ---------------------------------------------------------------
  check_not_missing(variables)
  .check_no_ard_columns(data)

  # process arguments ----------------------------------------------------------
  process_selectors(data,
    variables = {{ variables }},
    by = {{ by }},
    strata = {{ strata }}
  )
  data <- dplyr::ungroup(data)

  process_formula_selectors(
    data[variables],
    statistic = statistic,
    fmt_fun = fmt_fun,
    stat_label = stat_label
  )
  fill_formula_selectors(
    data[variables],
    statistic = formals(asNamespace("cards")[["ard_summary.data.frame"]])[["stat_label"]] |> eval(),
    stat_label = formals(asNamespace("cards")[["ard_summary.data.frame"]])[["stat_label"]] |> eval()
  )

  check_list_elements(
    x = statistic,
    predicate = function(x) is.list(x) && is_named(x) && every(x, is.function),
    error_msg =
      c("Error in the argument {.arg {arg_name}} for variable {.val {variable}}.",
        "i" = "Value must be a named list of functions."
      )
  )

  # return empty ARD if no variables selected ----------------------------------
  if (is_empty(variables)) {
    return(dplyr::tibble() |> as_card(check = FALSE))
  }


  # check factor levels --------------------------------------------------------
  check_no_na_factor_levels(data[c(by, strata)])
  check_factor_has_levels(data[c(by, strata)])


  # calculate statistics -------------------------------------------------------
  df_nested <-
    data |>
    nest_for_ard(
      by = by,
      strata = strata,
      key = "...ard_nested_data..."
    )

  # calculate statistics indicated by user in statistics argument
  df_nested <-
    .calculate_stats_as_ard(
      df_nested = df_nested,
      variables = variables,
      statistic = statistic,
      new_col_name = "...ard_all_stats...",
      by = by,
      strata = strata,
      data = data
    )

  # unnest results
  df_results <-
    df_nested |>
    dplyr::select(all_ard_groups(), "...ard_all_stats...") |>
    tidyr::unnest(cols = "...ard_all_stats...")

  # final processing of fmt_fun ------------------------------------------------
  df_results <-
    .process_nested_list_as_df(
      x = df_results,
      arg = fmt_fun,
      new_column = "fmt_fun"
    ) |>
    .default_fmt_fun()

  # final processing of stat labels --------------------------------------------
  df_results <-
    .process_nested_list_as_df(
      x = df_results,
      arg = stat_label,
      new_column = "stat_label",
      unlist = TRUE
    ) |>
    dplyr::mutate(stat_label = dplyr::coalesce(.data$stat_label, .data$stat_name))

  # add meta data and class ----------------------------------------------------
  ard_final <- df_results |>
    dplyr::mutate(context = "summary") |>
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

#' Check Protected Column Names
#'
#' Checks that column names in a passed data frame are not protected, that is,
#' they do not begin with `"...ard_"` and end with `"..."`.
#'
#' @param x (`data.frame`)\cr
#'   a data frame
#' @param exceptions (`string`)\cr
#'   character string of column names to exclude from checks
#'
#' @return returns invisible if check is successful, throws an error message if not.
#' @keywords internal
#'
#' @examples
#' data <- data.frame("ard_x" = 1)
#'
#' cards:::.check_no_ard_columns(data)
.check_no_ard_columns <- function(x, exceptions = "...ard_dummy_for_counting...") {
  colnames <- names(x)
  ard_colnames <-
    colnames[startsWith(colnames, "...ard_") & endsWith(colnames, "...")] |>
    setdiff(exceptions)

  if (!is_empty(ard_colnames)) {
    "Columns beginning with {.val '...ard_'} and ending with {.val '...'} are not allowed." |>
      cli::cli_abort(call = get_cli_abort_call())
  }
}

#' Calculate Continuous Statistics
#'
#' Calculate statistics and return in an ARD format
#'
#' @param df_nested (`data.frame`)\cr
#'   a nested data frame
#' @param variables (`character`)\cr
#'   character vector of variables
#' @param statistic (named `list`)\cr
#'   named list of statistical functions
#'
#' @return an ARD data frame of class 'card'
#' @keywords internal
#'
#' @examples
#' data_nested <- ADSL |>
#'   nest_for_ard(
#'     by = "ARM",
#'     strata = NULL,
#'     key = "...ard_nested_data..."
#'   )
#'
#' cards:::.calculate_stats_as_ard(
#'   df_nested = data_nested,
#'   variables = "AGE",
#'   statistic = list(mean = "mean"),
#'   by = "ARM",
#'   strata = NULL,
#'   data = ADSL
#' )
.calculate_stats_as_ard <- function(df_nested, variables, statistic,
                                    by, strata, data,
                                    new_col_name = "...ard_all_stats...") {
  df_nested[[new_col_name]] <-
    lapply(
      df_nested[["...ard_nested_data..."]],
      function(nested_data) {
        res_list <- unlist(
          lapply(
            variables,
            function(variable) {
              lapply(
                names(statistic[[variable]]),
                function(fun_name) {
                  fun <- statistic[[variable]][[fun_name]]
                  .lst_results_as_df(
                    x = # calculate results, and place in tibble
                      eval_capture_conditions(
                        getOption(
                          "cards.calculate_stats_as_ard.eval_fun",
                          default = expr(do.call(fun, args = list(stats::na.omit(nested_data[[variable]]))))
                        )
                      ),
                    variable = variable,
                    fun_name = fun_name,
                    fun = fun
                  )
                }
              )
            }
          ),
          recursive = FALSE
        )
        dplyr::bind_rows(res_list)
      }
    )

  df_nested
}


#' Prepare Results as Data Frame
#'
#' Function takes the results from [eval_capture_conditions()], which is a
#' named list, e.g. `list(result=, warning=, error=)`, and converts it to a data
#' frame.
#'
#' @param x (named `list`)\cr
#'   the result from [eval_capture_conditions()]
#' @param variable (`string`)\cr
#'   variable name of the results
#' @param fun_name (`string`)\cr
#'   name of function called to get results in `x`
#'
#' @return a data frame
#' @keywords internal
#'
#' @examples
#' msgs <- eval_capture_conditions({
#'   warning("Warning 1")
#'   warning("Warning 2")
#'   letters[1:2]
#' })
#'
#' cards:::.lst_results_as_df(msgs, "result", "mean")
.lst_results_as_df <- function(x, variable, fun_name, fun) {
  # unnesting results if needed
  if (.is_named_list(x$result, allow_df = TRUE)) {
    if (is.data.frame(x$result)) x$result <- unclass(x$result)
    stat_name <- names(x$result)
    res_list <- unname(x$result)
  } else {
    # if result is not a nested list, return a single row tibble
    stat_name <- if (is_empty(x$result) && is_cards_fn(fun)) {
      get_cards_fn_stat_names(fun)
    } else {
      fun_name
    }
    res_list <- list(x$result)
  }

  len <- length(stat_name)

  out <- data.frame(
    stat_name = stat_name,
    stringsAsFactors = FALSE
  )
  out$stat <- res_list
  out$warning <- rep_len(list(x$warning), len)
  out$error <- rep_len(list(x$error), len)
  out$variable <- rep_len(variable, len)

  out
}


#' Convert Nested Lists to Column
#'
#' Some arguments, such as `stat_label`, are passed as nested lists. This
#' function properly unnests these lists and adds them to the results data frame.
#'
#' @param x (`data.frame`)\cr
#'   result data frame
#' @param arg (`list`)\cr
#'   the nested list
#' @param new_column (`string`)\cr
#'   new column name
#' @param unlist (`logical`)\cr
#'   whether to fully unlist final results
#'
#' @return a data frame
#' @keywords internal
#'
#' @examples
#' ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
#'
#' cards:::.process_nested_list_as_df(ard, NULL, "new_col")
.process_nested_list_as_df <- function(x, arg, new_column, unlist = FALSE) {
  # add column if not already present
  if (!new_column %in% names(x)) {
    x[[new_column]] <- list(NULL)
  }

  # process argument if not NULL, and update new column
  if (!is_empty(arg)) {
    df_argument <-
      imap(
        arg,
        function(enlst_arg, variable) {
          lst_stat_names <-
            x[c("variable", "stat_name")] |>
            dplyr::filter(.data$variable %in% .env$variable) |>
            unique() %>%
            {stats::setNames(as.list(.[["stat_name"]]), .[["stat_name"]])} # styler: off

          compute_formula_selector(
            data = lst_stat_names,
            x = enlst_arg
          ) %>%
            # styler: off
            {dplyr::tibble(
              variable = variable,
              stat_name = names(.),
              "{new_column}" := unname(.)
            )}
          # styler: on
        }
      ) |>
      dplyr::bind_rows()

    x <- x |> dplyr::rows_update(df_argument, by = c("variable", "stat_name"), unmatched = "ignore")
  }

  if (isTRUE(unlist)) {
    x[[new_column]] <- lapply(x[[new_column]], function(x) x %||% NA) |> unlist()
  }

  x
}

#' Add Default Formatting Functions
#'
#' @param x (`data.frame`)\cr
#'   an ARD data frame of class 'card'
#'
#' @return a data frame
#' @keywords internal
#'
#' @examples
#' ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1") |>
#'   dplyr::mutate(fmt_fun = NA)
#'
#' cards:::.default_fmt_fun(ard)
.default_fmt_fun <- function(x) {
  x |>
    dplyr::mutate(
      fmt_fun =
        pmap(
          list(.data$stat_name, .data$stat, .data$fmt_fun),
          function(stat_name, stat, fmt_fun) {
            if (!is_empty(fmt_fun)) {
              return(fmt_fun)
            }
            if (stat_name %in% c("p", "p_miss", "p_nonmiss")) {
              return(label_round(digits = 1, scale = 100))
            }
            if (is.integer(stat)) {
              return(0L)
            }
            if (is.numeric(stat)) {
              return(1L)
            }
            return(as.character)
          }
        )
    )
}

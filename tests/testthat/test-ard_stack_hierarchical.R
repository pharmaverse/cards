ADAE_small <-
  ADAE |>
  dplyr::filter(.by = TRTA, dplyr::row_number() <= 2L) |>
  dplyr::select("USUBJID", "TRTA", "AESOC", "AEDECOD", "AESEV") |>
  dplyr::mutate(AESEV = factor(AESEV))

# ard_stack_hierarchical() -----------------------------------------------------
test_that("ard_stack_hierarchical(variables)", {
  # ensure that all nested variables appear in resulting ARD
  expect_silent(
    ard <-
      ard_stack_hierarchical(
        ADAE_small,
        variables = c(AESOC, AEDECOD),
        id = USUBJID,
        denominator = ADSL
      )
  )

  # check the number of rows is expected
  expect_equal(
    nrow(ard),
    (length(unique(ADAE_small$AESOC)) + length(unique(ADAE_small$AEDECOD))) * 3L # multiply by three for n, N, and p
  )

  # check AEDECOD match
  expect_equal(
    ard |> dplyr::filter(!is.na(group1)),
    ard_hierarchical(
      ADAE_small,
      variables = c(AESOC, AEDECOD),
      id = USUBJID,
      denominator = ADSL
    ),
    ignore_attr = TRUE
  )

  # check AESOC match
  expect_equal(
    ard |> dplyr::filter(is.na(group1)) |> dplyr::select(-all_ard_group_n(1L)),
    ard_hierarchical(
      ADAE_small |>
        dplyr::slice_tail(n = 1L, by = c("USUBJID", "TRTA", "AESOC")),
      variables = AESOC,
      id = USUBJID,
      denominator = ADSL
    ),
    ignore_attr = TRUE
  )
})

test_that("ard_stack_hierarchical(variables) messaging removed obs", {
  # missing rows are removed
  expect_snapshot(
    ard <- ADAE_small |>
      dplyr::mutate(AESOC = ifelse(dplyr::row_number() == 1L, NA, AESOC)) |>
      ard_stack_hierarchical(
        variables = c(AESOC, AEDECOD),
        id = USUBJID,
        denominator = ADSL
      )
  )

  expect_snapshot(
    ard <- ADAE_small |>
      ard_stack_hierarchical(
        variables = c(AESOC, AEDECOD),
        id = USUBJID,
        by = TRTA,
        denominator = ADSL |>
          dplyr::mutate(TRTA = ifelse(dplyr::row_number() == 1L, NA, TRTA))
      )
  )
})

test_that("ard_stack_hierarchical(variables) messaging", {
  # no variables selected
  expect_snapshot(
    error = TRUE,
    ADAE_small |>
      ard_stack_hierarchical(
        variables = starts_with("xxxxx"),
        id = USUBJID,
        denominator = ADSL
      )
  )

  # no id selected
  expect_snapshot(
    error = TRUE,
    ADAE_small |>
      ard_stack_hierarchical(
        variables = c(AESOC, AEDECOD),
        id = starts_with("xxxxx"),
        denominator = ADSL
      )
  )
})

test_that("ard_stack_hierarchical(by)", {
  # ensure that all nested variables appear in resulting ARD
  expect_silent(
    ard <-
      ard_stack_hierarchical(
        ADAE_small,
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        id = USUBJID,
        denominator = ADSL
      )
  )

  # check AEDECOD match
  ard_match <- ard_hierarchical(
    ADAE_small,
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    id = USUBJID,
    denominator = ADSL
  ) |>
    cards::tidy_ard_row_order()
  attr(ard_match, "args") <- list(
    by = "TRTA",
    variables = c("AESOC", "AEDECOD"),
    include = c("AESOC", "AEDECOD")
  )

  expect_equal(
    ard |> dplyr::filter(!is.na(group2)),
    suppressWarnings(
      ard_match |>
        sort_ard_hierarchical("alphanumeric")
    ),
    ignore_attr = TRUE
  )

  # check AESOC match
  ard_match <- ard_hierarchical(
    ADAE_small |> dplyr::slice_tail(n = 1L, by = c("USUBJID", "TRTA", "AESOC")),
    variables = AESOC,
    by = TRTA,
    id = USUBJID,
    denominator = ADSL
  ) |>
    cards::tidy_ard_row_order()
  attr(ard_match, "args") <- list(
    by = "TRTA",
    variables = c("AESOC"),
    include = c("AESOC")
  )

  expect_equal(
    ard |>
      dplyr::filter(variable %in% "AESOC") |>
      dplyr::select(-all_ard_group_n(2L)),
    suppressWarnings(
      ard_match |>
        sort_ard_hierarchical("alphanumeric")
    ),
    ignore_attr = TRUE
  )

  # ARD with >2 `by` variables works
  expect_snapshot(expect_message(
    ard_stack_hierarchical(
      cards::ADAE,
      variables = c(AESOC, AEDECOD),
      by = c(TRTA, TRTEMFL, AESEV),
      id = USUBJID,
      denominator = ADSL
    )
  ))
})

test_that("ard_stack_hierarchical(by) messaging", {
  # missing rows are removed
  expect_snapshot(
    ard <- ADAE_small |>
      dplyr::mutate(TRTA = ifelse(dplyr::row_number() == 1L, NA, TRTA)) |>
      ard_stack_hierarchical(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        id = USUBJID,
        denominator = ADSL
      )
  )

  # no messaging if `id` values are present in multiple levels of the `by` variables
  expect_no_warning(
    suppressMessages(
      ard_stack_hierarchical(
        data = ADAE |>
          dplyr::bind_rows(ADAE |> dplyr::mutate(TRTA = "Total")),
        variables = c(AESOC, AEDECOD),
        by = c(TRTA, AESEV),
        denominator = ADSL |>
          dplyr::bind_rows(ADSL |> dplyr::mutate(TRTA = "Total")),
        id = USUBJID
      )
    )
  )
})

test_that("ard_stack_hierarchical(denominator) messaging", {
  # when the wrong type is passed to the argument
  expect_snapshot(
    error = TRUE,
    ADAE_small |>
      ard_stack_hierarchical(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        id = USUBJID,
        denominator = character()
      )
  )

  # denominator arg must be specified
  expect_snapshot(
    error = TRUE,
    ard_stack_hierarchical(
      ADAE,
      variables = c(AESOC, AEDECOD),
      by = TRTA,
      id = USUBJID
    )
  )

  # check denominator only keeps "by" and "id" variables
  adsl_updated <-
    cards::ADSL |>
    dplyr::mutate(
      REGION = "Asia",
      COUNTRY = sample(c("CHN", "JPN", "PAK"), size = dplyr::n(), replace = TRUE)
    )

  expect_equal(
    cards::ard_stack_hierarchical(
      adsl_updated,
      by = "ARM",
      variable = c("REGION", "COUNTRY"),
      id = "USUBJID",
      denominator = adsl_updated
    ),
    cards::ard_stack_hierarchical(
      adsl_updated,
      by = "ARM",
      variable = c("REGION", "COUNTRY"),
      id = "USUBJID",
      denominator = adsl_updated[c("USUBJID", "ARM")]
    ),
    ignore_attr = TRUE,
    ignore_function_env = TRUE
  )
})

# test the rates are correct for items like AESEV, where we want to tabulate the most severe AE within the hierarchies
test_that("ard_stack_hierarchical(by) with columns not in `denominator`", {
  expect_message(
    ard_stack_hierarchical(
      ADAE_small,
      variables = c(AESOC, AEDECOD),
      by = c(AESEV),
      id = USUBJID,
      denominator = ADSL
    ),
    'Denominator set by number of rows in.*denominator.*data frame.' # styler: off
  )

  # when the `by` column not in `denominator` is constant within each subject
  # (i.e. no subject has multiple different levels of it), no rows are
  # actually collapsed/removed, so no message about dropped rows is emitted

  expect_no_message(
    ard_stack_hierarchical(
      ADAE_small,
      variables = c(AESOC, AEDECOD),
      by = c(TRTA, AESEV),
      id = USUBJID,
      denominator = ADSL
    ),
    message = "Because"
  )

  # a subject has both a MILD (or whatever the original level is) and a
  # MODERATE record for the same AESOC - only one is retained/counted, and we
  # should message that rows were dropped because of it

  ADAE_row_add <- ADAE_small |> dplyr::slice(1)

  ADAE_small_bind <- ADAE_small |>
    dplyr::bind_rows(
      ADAE_row_add |> dplyr::mutate(AESEV = "MODERATE")
    )

  expect_snapshot(
    ard_stack_hierarchical(
      data = ADAE_small_bind,
      by = c(TRTA, AESEV),
      variables = c(AESOC, AEDECOD),
      statistic = ~"n",
      denominator = ADSL,
      id = USUBJID,
      by_stats = FALSE
    )
  )

  expect_message(
    ard <- ard_stack_hierarchical(
      ADAE_small,
      variables = c(AESOC, AEDECOD),
      by = c(TRTA, AESEV),
      id = USUBJID,
      denominator = ADSL
    ),
    'Denominator set by.*"TRTA".*column in .*denominator.*data frame.' # styler: off
  )

  # check the rates for AEDECOD are correct
  ard_match <- ADAE_small |>
    dplyr::arrange(USUBJID, TRTA, AESOC, AEDECOD, AESEV) |>
    dplyr::filter(
      .by = c(USUBJID, TRTA, AESOC, AEDECOD),
      dplyr::n() == dplyr::row_number()
    ) |>
    ard_hierarchical(
      variables = c(AESOC, AEDECOD),
      by = c(TRTA, AESEV),
      denominator = ADSL
    ) |>
    tidy_ard_row_order()
  attr(ard_match, "args") <- list(
    by = "TRTA",
    variables = c("AESOC", "AEDECOD", "AESEV"),
    include = c("AESOC", "AEDECOD", "AESEV")
  )

  expect_equal(
    ard |>
      dplyr::filter(variable == "AEDECOD"),
    suppressWarnings(
      ard_match |>
        sort_ard_hierarchical("alphanumeric")
    ),
    ignore_attr = TRUE,
    ignore_function_env = TRUE
  )

  # check the rates for AESOC are correct
  ard_match <- ADAE_small |>
    dplyr::arrange(USUBJID, TRTA, AESOC, AESEV) |>
    dplyr::filter(
      .by = c(USUBJID, TRTA, AESOC),
      dplyr::n() == dplyr::row_number()
    ) |>
    ard_hierarchical(
      variables = AESOC,
      by = c(TRTA, AESEV),
      denominator = ADSL
    ) |>
    tidy_ard_row_order()
  attr(ard_match, "args") <- list(
    by = "TRTA",
    variables = c("AESOC", "AESEV"),
    include = c("AESOC", "AESEV")
  )

  expect_equal(
    ard |>
      dplyr::filter(variable == "AESOC") |>
      rename_ard_columns(),
    suppressWarnings(
      ard_match |>
        sort_ard_hierarchical("alphanumeric") |>
        rename_ard_columns()
    ),
    ignore_attr = TRUE,
    ignore_function_env = TRUE
  )
})

test_that("ard_stack_hierarchical(variables, include) messaging", {
  expect_snapshot(
    error = TRUE,
    ard_stack_hierarchical(
      ADAE_small,
      variables = c(AESOC, AEDECOD),
      include = AESOC,
      by = TRTA,
      denominator = ADSL,
      id = USUBJID
    )
  )
})

test_that("ard_stack_hierarchical(by, overall) messaging", {
  expect_snapshot(
    ard <- ard_stack_hierarchical(
      ADAE_small,
      variables = c(AESOC, AEDECOD),
      denominator = ADSL,
      id = USUBJID,
      overall = TRUE
    )
  )
})

test_that("ard_stack_hierarchical(statistic)", {
  expect_equal(
    ard_stack_hierarchical(
      ADAE,
      variables = AESOC,
      denominator = ADSL,
      id = USUBJID,
      statistic = everything() ~ "p"
    ),
    ard_stack_hierarchical(
      ADAE,
      variables = AESOC,
      denominator = ADSL,
      id = USUBJID,
      statistic = everything() ~ c("n", "N", "p")
    ) |>
      dplyr::filter(stat_name %in% "p")
  )
})

test_that("ard_stack_hierarchical with shuffle", {
  # we expect it to work but with a warning messaged related to the deprecation
  # of the `shuffle` argument
  expect_error(
    ard_shuffled <- ard_stack_hierarchical(
      ADAE_small,
      variables = c(AESOC, AEDECOD),
      id = USUBJID,
      denominator = ADSL,
      shuffle = TRUE
    )
  )
})

# ard_stack_hierarchical_count() -----------------------------------------------
test_that("ard_stack_hierarchical_count(variables)", {
  # ensure that all nested variables appear in resulting ARD
  expect_silent(
    ard <-
      ard_stack_hierarchical_count(
        ADAE_small,
        variables = c(AESOC, AEDECOD)
      )
  )

  # check the number of rows is expected
  expect_equal(
    nrow(ard),
    length(unique(ADAE_small$AESOC)) + length(unique(ADAE_small$AEDECOD))
  )

  # check AEDECOD match
  ard_match <- ard_hierarchical_count(ADAE_small, variables = c(AESOC, AEDECOD))
  attr(ard_match, "args") <- list(
    by = NULL,
    variables = c("AESOC", "AEDECOD"),
    include = c("AESOC", "AEDECOD")
  )

  expect_equal(
    ard |> dplyr::filter(!is.na(group1)),
    suppressWarnings(
      ard_match |> sort_ard_hierarchical("alphanumeric")
    ),
    ignore_attr = TRUE
  )

  # check AESOC match
  ard_match <- ard_hierarchical_count(ADAE_small, variables = AESOC)
  attr(ard_match, "args") <- list(
    by = NULL,
    variables = "AESOC",
    include = "AESOC"
  )

  expect_equal(
    ard |> dplyr::filter(is.na(group1)) |> dplyr::select(-all_ard_group_n(1L)),
    suppressWarnings(
      ard_match |> sort_ard_hierarchical("alphanumeric")
    ),
    ignore_attr = TRUE
  )
})

test_that("ard_stack_hierarchical_count(by)", {
  expect_silent(
    ard <-
      ard_stack_hierarchical_count(
        ADAE_small,
        variables = c(AESOC, AEDECOD),
        by = TRTA
      )
  )

  # check the number of rows is expected
  expect_equal(
    nrow(ard),
    (length(unique(ADAE_small$AESOC)) + length(unique(ADAE_small$AEDECOD))) *
      length(unique(ADAE_small$TRTA))
  )

  # check AEDECOD match
  ard_match <- ard_hierarchical_count(
    ADAE_small,
    variables = c(AESOC, AEDECOD),
    by = TRTA
  ) |>
    cards::tidy_ard_row_order()
  attr(ard_match, "args") <- list(
    by = "TRTA",
    variables = c("AESOC", "AEDECOD"),
    include = c("AESOC", "AEDECOD")
  )

  expect_equal(
    ard |> dplyr::filter(!is.na(group2)),
    suppressWarnings(
      ard_match |> sort_ard_hierarchical("alphanumeric")
    ),
    ignore_attr = TRUE
  )

  # check AESOC match
  ard_match <- ard_hierarchical_count(
    ADAE_small,
    variables = AESOC,
    by = TRTA
  ) |>
    cards::tidy_ard_row_order()
  attr(ard_match, "args") <- list(
    by = "TRTA",
    variables = "AESOC",
    include = "AESOC"
  )

  expect_equal(
    ard |> dplyr::filter(is.na(group2)) |> dplyr::select(-all_ard_group_n(2L)),
    suppressWarnings(
      ard_match |> sort_ard_hierarchical("alphanumeric")
    ),
    ignore_attr = TRUE
  )
})

test_that("ard_stack_hierarchical_count(denominator) messaging", {
  # when the wrong type is passed to the argument
  expect_snapshot(
    error = TRUE,
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        denominator = letters
      )
  )
})

test_that("ard_stack_hierarchical_count(denominator) univariate tabulations", {
  # test that we get the expected univariate by variable tabulations
  expect_equal(
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        denominator = ADSL
      ) |>
      dplyr::filter(variable == "TRTA") |>
      dplyr::select(-all_missing_columns()),
    ard_tabulate(ADSL, variables = TRTA) |>
      dplyr::select(-all_missing_columns()),
    ignore_attr = TRUE
  )

  # everything still works when the by variable includes vars not in the denom data frame
  expect_equal(
    ard <- ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = c(TRTA, AESEV),
        denominator = ADSL
      ) |>
      dplyr::filter(variable == "TRTA") |>
      dplyr::select(-all_missing_columns()),
    ard_tabulate(ADSL, variables = TRTA) |>
      dplyr::select(-all_missing_columns()),
    ignore_attr = TRUE
  )
  expect_true(nrow(dplyr::filter(ard, variable == "AESEV")) == 0L)
})

test_that("ard_stack_hierarchical_count(denominator,total_n)", {
  # check N is correct when denom is a data frame
  expect_equal(
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        denominator = ADSL,
        total_n = TRUE
      ) |>
      dplyr::filter(variable == "..ard_total_n..") |>
      dplyr::select(-all_missing_columns()),
    ard_total_n(ADSL) |>
      dplyr::select(-all_missing_columns()),
    ignore_attr = TRUE
  )

  # check N is correct when denom is an integer
  expect_equal(
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        denominator = nrow(ADSL),
        total_n = TRUE
      ) |>
      dplyr::filter(variable == "..ard_total_n..") |>
      dplyr::select(-all_missing_columns()),
    ard_total_n(ADSL) |>
      dplyr::select(-all_missing_columns()),
    ignore_attr = TRUE
  )
})

test_that("ard_stack_hierarchical_count(denominator,total_n) messaging", {
  # requesting total N without a denominator
  expect_snapshot(
    ard <- ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        total_n = TRUE
      )
  )
})

test_that("ard_stack_hierarchical_count(overall, denominator) messaging", {
  # requesting overall without a data frame denominator
  expect_snapshot(
    ard <- ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        overall = TRUE
      )
  )
})


test_that("ard_stack_hierarchical_count(overall)", {
  withr::local_options(list(width = 250))
  # requesting overall without a data frame denominator
  expect_equal(
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        denominator = ADSL,
        overall = TRUE
      ) |>
      dplyr::filter(
        !group1 %in% "TRTA" & !group2 %in% "TRTA" & !variable %in% "TRTA"
      ) |>
      dplyr::select(-all_missing_columns()),
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        denominator = ADSL
      ) |>
      dplyr::select(-all_missing_columns()),
    ignore_attr = TRUE
  )

  # when the `by` variable includes columns not in `denominator`, ensure we get two sets of overall (by=AESEV and by=NULL)
  # IF THIS EVER BREAKS BE VERY CAREFUL WE HAVE ALL 18 ROWS RETURNED!!!
  expect_snapshot({
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = c(TRTA, AESEV),
        denominator = ADSL,
        overall = TRUE
      ) |>
      dplyr::filter(
        !group1 %in% "TRTA" &
          !group2 %in% "TRTA" &
          !group3 %in% "TRTA" &
          !variable %in% "TRTA"
      )
  })
})

test_that("ard_stack_hierarchical_count(over_variables)", {
  # requesting overall without a data frame denominator
  expect_equal(
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        denominator = ADSL,
        over_variables = TRUE
      ) |>
      dplyr::filter(variable %in% "..ard_hierarchical_overall..") |>
      dplyr::select(-all_missing_columns()),
    ADAE_small |>
      dplyr::mutate(..ard_hierarchical_overall.. = TRUE) |>
      ard_stack_hierarchical_count(
        variables = ..ard_hierarchical_overall..,
        by = TRTA,
        denominator = ADSL
      ) |>
      dplyr::filter(variable %in% "..ard_hierarchical_overall..") |>
      dplyr::select(-all_missing_columns()),
    ignore_attr = TRUE
  )
})

test_that("ard_stack_hierarchical_count(overall,over_variables)", {
  withr::local_options(list(width = 250))
  # ensuring we have an overall row grouped by TRTA, and across TRTA levels (nrow=4)
  expect_snapshot(
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = AESOC,
        by = TRTA,
        denominator = ADSL,
        over_variables = TRUE,
        overall = TRUE
      ) |>
      dplyr::filter(variable == "..ard_hierarchical_overall..") |>
      dplyr::select(all_ard_groups(), "variable", "stat_name", "stat") |>
      as.data.frame()
  )

  # both `overall=TRUE` and `over_variables=TRUE` work together with multiple `by` variables present
  expect_snapshot({
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = c(TRTA, AESEV),
        denominator = ADSL,
        overall = TRUE,
        over_variables = TRUE
      ) |>
      dplyr::filter(
        !group1 %in% "TRTA" &
          !group2 %in% "TRTA" &
          !group3 %in% "TRTA" &
          !variable %in% "TRTA"
      )
  })
})

test_that("ard_stack_hierarchical_count(attributes)", {
  # requesting overall without a data frame denominator
  expect_equal(
    ADAE_small |>
      ard_stack_hierarchical_count(
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        denominator = ADSL,
        attributes = TRUE
      ) |>
      dplyr::filter(context %in% "attributes") |>
      dplyr::select(-all_missing_columns()),
    ADAE_small |>
      ard_attributes(variables = c(TRTA, AESOC, AEDECOD)) |>
      dplyr::select(-all_missing_columns()),
    ignore_attr = TRUE
  )
})

test_that("ard_stack_hierarchical() by_stats argument", {
  # include by_stats
  expect_silent(
    ard <-
      ard_stack_hierarchical(
        ADAE_small,
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        id = USUBJID,
        denominator = ADSL,
        by_stats = TRUE
      )
  )

  expect_equal(
    ard |> dplyr::filter(variable == "TRTA") |> dplyr::select(-all_ard_groups()),
    ard_tabulate(
      data = ADSL,
      variables = TRTA
    ),
    ignore_attr = TRUE
  )

  # no by_stats
  expect_silent(
    ard <-
      ard_stack_hierarchical(
        ADAE_small,
        variables = c(AESOC, AEDECOD),
        by = TRTA,
        id = USUBJID,
        denominator = ADSL,
        by_stats = FALSE
      )
  )

  expect_equal(
    ard |> dplyr::filter(variable == "TRTA") |> nrow(),
    0
  )
})

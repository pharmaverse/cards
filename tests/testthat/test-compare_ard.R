test_that("compare_ard identifies stat mismatches", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1), variables = AGE)

  expect_silent(
    result <- compare_ard(ard_base, ard_modified)
  )

  expect_s3_class(result, "compare_ard")
  expect_true("stat" %in% names(result$comparison))
  expect_gt(nrow(result$comparison$stat), 0L)

  mean_row <- result$comparison$stat |>
    dplyr::filter(stat_name == "mean")

  expect_equal(nrow(mean_row), 1L)
  expect_false(identical(mean_row$stat.x[[1]], mean_row$stat.y[[1]]))
})

test_that("compare_ard returns empty data frames when ARDs are identical", {
  ard <- ard_tabulate(ADSL, variables = AGEGR1)

  expect_silent(result <- compare_ard(ard, ard))

  expect_s3_class(result, "compare_ard")
  expect_equal(nrow(result$rows_in_x_not_y), 0L)
  expect_equal(nrow(result$rows_in_y_not_x), 0L)
  expect_true(all(vapply(result$comparison, nrow, integer(1)) == 0L))
})

test_that("compare_ard validates duplicates in keys", {
  ard <- ard_tabulate(ADSL, variables = AGEGR1)
  ard_dup <- dplyr::bind_rows(ard, ard)

  expect_error(
    suppressMessages(compare_ard(ard_dup, ard)),
    "Duplicate key combinations"
  )
})

test_that("compare_ard supports custom keys", {
  ard <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1), variables = AGE)

  expect_silent(
    result <- compare_ard(ard, ard_modified, keys = c("variable", "stat_name"))
  )

  expect_gt(nrow(result$comparison$stat), 0L)
  expect_true(all(c("variable", "stat_name") %in% names(result$comparison$stat)))
})

test_that("compare_ard supports custom compare columns", {
  ard <- ard_summary(ADSL, variables = AGE)

  # Modify stat_label
  ard_modified <- ard
  ard_modified$stat_label[1] <- "Modified Label"

  expect_silent(
    result <- compare_ard(ard, ard_modified, columns = "stat_label")
  )

  expect_true("stat_label" %in% names(result$comparison))
  expect_equal(nrow(result$comparison$stat_label), 1L)
})

test_that("compare_ard handles ARDs with different grouping structures", {
  ard_with_group <-
    ard_summary(ADSL, variables = AGE, by = ARM) |>
    dplyr::filter(group1_level == "Placebo")

  ard_without_group <- ard_summary(ADSL, variables = AGE)

  # Should use intersection of keys
  expect_error(
    compare_ard(ard_with_group, ard_without_group),
    "do not match"
  )
})

test_that("compare_ard detects rows in x not in y", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_subset <- ard_base |> dplyr::filter(stat_name != "mean")

  expect_silent(result <- compare_ard(ard_base, ard_subset))

  expect_equal(nrow(result$rows_in_x_not_y), 1L)
  expect_equal(result$rows_in_x_not_y$stat_name, "mean")
  expect_equal(nrow(result$rows_in_y_not_x), 0L)
})

test_that("compare_ard detects rows in y not in x", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_subset <- ard_base |> dplyr::filter(stat_name != "mean")

  expect_silent(result <- compare_ard(ard_subset, ard_base))

  expect_equal(nrow(result$rows_in_x_not_y), 0L)
  expect_equal(nrow(result$rows_in_y_not_x), 1L)
  expect_equal(result$rows_in_y_not_x$stat_name, "mean")
})

test_that("compare_ard errors when keys are empty", {
  ard1 <- ard_summary(ADSL, variables = AGE) |>
    dplyr::select(-variable, -stat_name)
  ard2 <- ard_summary(ADSL, variables = BMIBL) |>
    dplyr::select(-variable, -stat_name)

  # Error comes from cards_select, not our check
  expect_error(
    compare_ard(ard1, ard2, keys = "nonexistent_col")
  )
})

test_that("compare_ard errors when compare columns are empty", {
  ard <- ard_summary(ADSL, variables = AGE)

  # Error comes from cards_select, not our check
  expect_error(
    compare_ard(ard, ard, columns = "nonexistent_col")
  )
})

test_that("compare_ard handles missing columns gracefully", {
  ard <- ard_summary(ADSL, variables = AGE)
  ard_no_stat_fmt <- ard |> dplyr::select(-any_of("stat_fmt"))

  # stat_fmt not in either, but stat and stat_label are
  expect_silent(
    result <- compare_ard(ard_no_stat_fmt, ard_no_stat_fmt, columns = any_of(c("stat", "stat_label")))
  )

  expect_true(all(vapply(result$comparison, nrow, integer(1)) == 0L))
})

test_that("compare_ard works with by variables", {
  ard1 <- ard_tabulate(ADSL, by = ARM, variables = AGEGR1)
  ard2 <- ard1
  # Modify one value
  ard2$stat[1] <- list(999L)

  expect_silent(result <- compare_ard(ard1, ard2))

  expect_equal(nrow(result$comparison$stat), 1L)
  expect_true("group1" %in% names(result$comparison$stat))
  expect_true("group1_level" %in% names(result$comparison$stat))
})

test_that("compare_ard validates input classes", {
  expect_error(compare_ard(data.frame(), ard_summary(ADSL, variables = AGE)), class = "check_class")
  expect_error(compare_ard(ard_summary(ADSL, variables = AGE), data.frame()), class = "check_class")
})

test_that("compare_ard returns compare_ard class", {
  ard <- ard_summary(ADSL, variables = AGE)

  expect_silent(result <- compare_ard(ard, ard))

  expect_s3_class(result, "compare_ard")
  expect_true("rows_in_x_not_y" %in% names(result))
  expect_true("rows_in_y_not_x" %in% names(result))
  expect_true("comparison" %in% names(result))
  expect_true(is.list(result$comparison))
})

test_that("check_ard_equal() returns error with unequal ARDs", {
  expect_error(
    compare_ard(
      ard_summary(ADSL[1:10, ], variables = AGE),
      ard_summary(ADSL[1:20, ], variables = AGE)
    ) |>
      check_ard_equal(),
    "ARDs are not equal"
  )
})

# --- is_ard_equal() -----------------------------------------------------------

test_that("is_ard_equal() returns TRUE for identical ARDs", {
  ard <- ard_summary(ADSL, variables = AGE)
  result <- compare_ard(ard, ard)

  expect_true(is_ard_equal(result))
})

test_that("is_ard_equal() returns FALSE when rows differ", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_subset <- ard_base |> dplyr::filter(stat_name != "mean")

  result <- compare_ard(ard_base, ard_subset)
  expect_false(is_ard_equal(result))
})

test_that("is_ard_equal() returns FALSE when stat values differ", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1), variables = AGE)

  result <- compare_ard(ard_base, ard_modified)
  expect_false(is_ard_equal(result))
})

test_that("is_ard_equal() errors on wrong input class", {
  expect_error(is_ard_equal(list()), class = "check_class")
  expect_error(is_ard_equal(data.frame()), class = "check_class")
})

# --- check_ard_equal() --------------------------------------------------------

test_that("check_ard_equal() returns invisible TRUE for equal ARDs", {
  ard <- ard_summary(ADSL, variables = AGE)
  result <- compare_ard(ard, ard)

  expect_true(check_ard_equal(result))
  expect_invisible(check_ard_equal(result))
})

# --- tolerance parameter ------------------------------------------------------

test_that("compare_ard(tolerance) controls numeric comparison sensitivity", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_base
  # add a tiny perturbation to the mean stat
  mean_idx <- which(ard_modified$stat_name == "mean")
  original_val <- ard_modified$stat[[mean_idx]]
  ard_modified$stat[[mean_idx]] <- original_val + 1e-10

  # with default tolerance, the tiny difference is ignored
  result_default <- compare_ard(ard_base, ard_modified)
  mean_diffs <- result_default$comparison$stat |>
    dplyr::filter(stat_name == "mean")
  expect_equal(nrow(mean_diffs), 0L)

  # with very strict tolerance, the difference is detected
  result_strict <- compare_ard(ard_base, ard_modified, tolerance = 0)
  mean_diffs_strict <- result_strict$comparison$stat |>
    dplyr::filter(stat_name == "mean")
  expect_equal(nrow(mean_diffs_strict), 1L)
})

# --- check.attributes parameter ----------------------------------------------

test_that("compare_ard(check.attributes) controls attribute comparison", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_base
  # add a name attribute to one stat value
  mean_idx <- which(ard_modified$stat_name == "mean")
  val <- ard_modified$stat[[mean_idx]]
  ard_modified$stat[[mean_idx]] <- stats::setNames(val, "mean_val")

  # with check.attributes = TRUE (default), the attribute difference is detected
  result_attrs <- compare_ard(ard_base, ard_modified, check.attributes = TRUE)
  mean_diffs <- result_attrs$comparison$stat |>
    dplyr::filter(stat_name == "mean")
  expect_equal(nrow(mean_diffs), 1L)

  # with check.attributes = FALSE, the attribute difference is ignored
  result_no_attrs <- compare_ard(ard_base, ard_modified, check.attributes = FALSE)
  mean_diffs_no <- result_no_attrs$comparison$stat |>
    dplyr::filter(stat_name == "mean")
  expect_equal(nrow(mean_diffs_no), 0L)
})

# --- duplicate keys in y -----------------------------------------------------

test_that("compare_ard validates duplicates in y", {
  ard <- ard_tabulate(ADSL, variables = AGEGR1)
  ard_dup <- dplyr::bind_rows(ard, ard)

  expect_error(
    suppressMessages(compare_ard(ard, ard_dup)),
    "Duplicate key combinations"
  )
})

# --- columns mismatch error ---------------------------------------------------

test_that("compare_ard errors when columns argument selects mismatched columns", {
  ard1 <- ard_summary(ADSL, variables = AGE)
  ard2 <- ard1 |> dplyr::select(-stat_label)

  # stat_label exists in ard1 but not ard2, so cards_select errors
  expect_error(
    compare_ard(ard1, ard2, columns = "stat_label")
  )
})

# --- print.compare_ard() -----------------------------------------------------

test_that("print.compare_ard() works for equal ARDs", {
  ard <- ard_summary(ADSL, variables = AGE)
  result <- compare_ard(ard, ard)

  # print method uses cli messaging; capture both stdout and messages
  expect_message(print(result), "No differences")
})

test_that("print.compare_ard() works for ARDs with differences", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1), variables = AGE)
  result <- compare_ard(ard_base, ard_modified)

  expect_message(print(result), "Differences found")
})

test_that("print.compare_ard() works for ARDs with mismatched rows", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_subset <- ard_base |> dplyr::filter(stat_name != "mean")
  result <- compare_ard(ard_base, ard_subset)

  expect_message(print(result), "do not appear")
})

# --- result metadata ----------------------------------------------------------

test_that("compare_ard() stores actual keys in result when custom keys supplied", {
  ard <- ard_summary(ADSL, variables = AGE)
  result <- compare_ard(ard, ard, keys = c("variable", "stat_name"))
  expect_equal(result$keys, c("variable", "stat_name"))
  expect_true(is_ard_equal(result))
})

test_that("compare_ard() default keys contain expected column names", {
  ard <- ard_summary(ADSL, variables = AGE)
  result <- compare_ard(ard, ard)
  expect_true("stat_name" %in% result$keys)
  expect_true("variable" %in% result$keys)
})

test_that("compare_ard() stores actual columns in result when custom columns supplied", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_base
  ard_modified$stat_label[1] <- "Changed"
  result <- compare_ard(ard_base, ard_modified, columns = "stat_label")
  expect_equal(result$columns, "stat_label")
  expect_gt(nrow(result$comparison$stat_label), 0L)
})

test_that("compare_ard() duplicate key error message contains formatted key values", {
  ard <- ard_tabulate(ADSL, variables = AGEGR1)
  ard_dup <- dplyr::bind_rows(ard, ard)
  expect_error(
    suppressMessages(compare_ard(ard, ard_dup)),
    "variable"
  )
})

# --- result structure ---------------------------------------------------------

test_that("compare_ard result contains keys and columns metadata", {
  ard <- ard_summary(ADSL, variables = AGE)
  result <- compare_ard(ard, ard)

  expect_true("keys" %in% names(result))
  expect_true("columns" %in% names(result))
  expect_type(result$keys, "character")
  expect_type(result$columns, "character")
  expect_true("stat_name" %in% result$keys)
  expect_true("stat" %in% result$columns)
})

# --- comparison difference column ---------------------------------------------

test_that("compare_ard comparison includes difference descriptions", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1), variables = AGE)

  result <- compare_ard(ard_base, ard_modified)

  # the difference column should contain all.equal() output strings
  expect_true("difference" %in% names(result$comparison$stat))
  expect_type(result$comparison$stat$difference, "list")
  expect_true(all(vapply(result$comparison$stat$difference, is.character, logical(1))))
})

# --- multiple comparison columns at once --------------------------------------

test_that("compare_ard compares multiple columns simultaneously", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_modified <- ard_base
  ard_modified$stat[1] <- list(999L)
  ard_modified$stat_label[1] <- "Changed"

  result <- compare_ard(ard_base, ard_modified, columns = any_of(c("stat", "stat_label")))

  expect_true("stat" %in% names(result$comparison))
  expect_true("stat_label" %in% names(result$comparison))
  expect_gt(nrow(result$comparison$stat), 0L)
  expect_gt(nrow(result$comparison$stat_label), 0L)
})

# --- rows in both x and y not in other ----------------------------------------

test_that("compare_ard detects rows missing from both sides", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_other <- ard_summary(ADSL, variables = BMIBL)

  result <- compare_ard(ard_base, ard_other)

  # all rows differ since variables are different
  expect_gt(nrow(result$rows_in_x_not_y), 0L)
  expect_gt(nrow(result$rows_in_y_not_x), 0L)
})

# --- ARD edge cases -----------------------------------------------------------

test_that("compare_ard works with two by variables (4 group columns)", {
  ard1 <- ard_summary(ADSL, by = c(ARM, SEX), variables = AGE)
  ard2 <- ard_summary(dplyr::mutate(ADSL, AGE = AGE + 1), by = c(ARM, SEX), variables = AGE)

  result <- compare_ard(ard1, ard2)

  expect_true(all(c("group1", "group1_level", "group2", "group2_level") %in% result$keys))
  expect_gt(nrow(result$comparison$stat), 0L)
  expect_true(is_ard_equal(compare_ard(ard1, ard1)))
})

test_that("compare_ard handles NULL stat values", {
  ard_base <- ard_tabulate(ADSL, by = ARM, variables = SEX)
  ard_modified <- ard_base
  ard_modified$stat[1L] <- list(NULL)

  result_diff <- compare_ard(ard_base, ard_modified)
  expect_gt(nrow(result_diff$comparison$stat), 0L)

  result_same <- compare_ard(ard_base, ard_base)
  expect_true(is_ard_equal(result_same))
})

test_that("compare_ard ignores warning/error columns by default", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_warn <- ard_base
  ard_warn$warning[[1L]] <- "a warning message"

  result <- compare_ard(ard_base, ard_warn)
  expect_true(is_ard_equal(result))
})

test_that("compare_ard can compare warning column explicitly", {
  ard_base <- ard_summary(ADSL, variables = AGE)
  ard_warn <- ard_base
  ard_warn$warning[[1L]] <- "a warning message"

  result <- compare_ard(ard_base, ard_warn, columns = "warning")
  expect_false(is_ard_equal(result))
  expect_gt(nrow(result$comparison$warning), 0L)
})

test_that("compare_ard handles complex stat values from ard_identity()", {
  ard <- t.test(ADSL$AGE)[c("statistic", "p.value")] |>
    ard_identity(variable = "AGE")

  result <- compare_ard(ard, ard)
  expect_true(is_ard_equal(result))
})

test_that("compare_ard detects differences in complex stat values from ard_identity()", {
  ard_base <- t.test(ADSL$AGE)[c("statistic", "p.value")] |>
    ard_identity(variable = "AGE")
  ard_modified <- t.test(ADSL$AGE + 1)[c("statistic", "p.value")] |>
    ard_identity(variable = "AGE")

  result <- compare_ard(ard_base, ard_modified)
  expect_false(is_ard_equal(result))
})

test_that("compare_ard() resolves keys and columns against each ARD", {
  ard <- ard_tabulate(ADSL, variables = SEX)

  # the same ARD with its columns in a different order, as it may be returned
  # from a source other than cards
  ard_reordered <- dplyr::relocate(ard, "stat_label", .before = 1L)

  expect_silent(result <- compare_ard(ard, ard_reordered))

  expect_equal(result$keys, c("variable", "variable_level", "stat_name"))
  expect_equal(result$columns, c("stat_label", "stat"))
  expect_true(is_ard_equal(result))
})

test_that("compare_ard() accepts selectors combined with column names", {
  # the same summary under two names for the treatment variable
  ard_arm <- ard_summary(ADSL, by = ARM, variables = AGE)
  ard_trt01a <- ard_summary(ADSL, by = TRT01A, variables = AGE)

  expect_silent(
    result <-
      compare_ard(
        ard_arm,
        ard_trt01a,
        keys = c(all_ard_groups("levels"), all_ard_variables(), "stat_name"),
        columns = c(any_of("stat_label"), "stat")
      )
  )

  expect_equal(result$keys, c("group1_level", "variable", "stat_name"))
  expect_equal(result$columns, c("stat_label", "stat"))
  expect_true(is_ard_equal(result))
})

test_that("compare_ard() error messages name the user-facing argument", {
  ard <- ard_tabulate(ADSL, variables = SEX)

  # `.check_not_empty()` reports `keys`/`columns`, not the internal locals
  expect_snapshot(error = TRUE, compare_ard(ard, ard, keys = any_of("not_a_column")))
  expect_snapshot(error = TRUE, compare_ard(ard, ard, columns = any_of("not_a_column")))

  # an unusable selection names the argument it came from
  expect_snapshot(error = TRUE, compare_ard(ard, ard, keys = not_a_column))

  # renaming is not a valid selection here, as the names are used on both ARDs
  expect_snapshot(error = TRUE, compare_ard(ard, ard, keys = c(foo = variable)))
})

test_that("compare_ard() compares the columns present in both ARDs", {
  ard <- ard_summary(ADSL, by = ARM, variables = AGE)
  # `apply_fmt_fun()` adds `stat_fmt`, which the unformatted ARD does not have,
  # so the default `columns` selection resolves differently in each ARD
  ard_fmt <- apply_fmt_fun(ard)

  expect_message(
    result <- compare_ard(ard_fmt, ard),
    "not present in both ARDs"
  )

  expect_equal(result$columns, c("stat_label", "stat"))
  expect_true(is_ard_equal(result))

  # no message when the two selections agree
  expect_silent(compare_ard(ard, ard))
})

test_that("compare_ard() errors when the comparison columns have nothing in common", {
  ard <- ard_summary(ADSL, by = ARM, variables = AGE)

  expect_snapshot(
    error = TRUE,
    compare_ard(
      dplyr::select(ard, -"stat"),
      dplyr::select(ard, -"stat_label"),
      columns = any_of(c("stat_label", "stat"))
    )
  )
})

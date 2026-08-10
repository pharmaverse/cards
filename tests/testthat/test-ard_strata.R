test_that("ard_strata() works", {
  expect_snapshot(
    ard_strata(
      ADSL,
      .by = ARM,
      .f = ~ ard_summary(.x, variables = AGE)
    )
  )

  expect_snapshot(
    ard_strata(
      ADSL,
      .strata = ARM,
      .f = ~ ard_summary(.x, variables = AGE, by = AGEGR1)
    )
  )

  expect_equal(
    ard_strata(ADSL, .by = ARM, .f = ~ ard_summary(.x, by = c(SEX, AGEGR1), variables = AGE)) |>
      tidy_ard_column_order() |>
      tidy_ard_row_order(),
    ard_summary(ADSL, by = c(SEX, AGEGR1, ARM), variables = AGE) |>
      tidy_ard_row_order(),
    ignore_attr = TRUE
  )
})

test_that("ard_strata(by,strata) when both empty", {
  expect_equal(
    ard_strata(ADSL, .f = ~ ard_summary(.x, variables = AGE)),
    ard_summary(ADSL, variables = AGE),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_strata(ADSL, .f = ~ ard_summary(.x, by = ARM, variables = AGE)),
    ard_summary(ADSL, by = ARM, variables = AGE),
    ignore_attr = TRUE
  )
})

test_that("ard_strata computes stats for parameter specific strata", {
  withr::local_options(list(width = 180))

  df <- data.frame(
    USUBJID = 1:12,
    PARAMCD = rep(c("PARAM1", "PARAM2"), each = 6),
    AVALC = c(
      "Yes", "No", "Yes", # PARAM1
      "Yes", "Yes", "No", # PARAM1
      "Low", "Medium", "High", # PARAM2
      "Low", "Low", "Medium" # PARAM2
    )
  )
  param_levels <-
    list(
      PARAM1 = c("Yes", "No"),
      PARAM2 = c("Zero", "Low", "Medium", "High")
    )

  tbl <- ard_strata(
    df,
    .strata = PARAMCD,
    .f = \(.x) {
      param <- .x[["PARAMCD"]][1]
      .x |>
        dplyr::mutate(
          AVALC = factor(AVALC, levels = param_levels[[param]])
        ) |>
        ard_tabulate(variables = AVALC)
    }
  )

  expect_snapshot(print(tbl, n = Inf))
})


test_that("ard_strata() attaches 'args' attribute", {
  # Test with both .by and .strata
  res <- ard_strata(
    ADSL,
    .by = ARM,
    .strata = SEX,
    .f = ~ ard_summary(.x, variables = AGE)
  )

  expect_equal(attr(res, "args")$by, "ARM")
  expect_equal(attr(res, "args")$strata, "SEX")

  # Test with only .by
  res_by <- ard_strata(ADSL, .by = ARM, .f = ~ ard_summary(.x, variables = AGE))
  expect_equal(attr(res_by, "args")$by, "ARM")
  expect_equal(attr(res_by, "args")$strata, character(0))
})

test_that("bind_ard() works", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

  expect_error(
    res <- bind_ard(ard, ard, .update = TRUE),
    NA
  )

  # Verify the new class is assigned and ordered correctly
  expect_s3_class(res, "bind_ard")
  expect_identical(class(res)[1], "bind_ard")
})


test_that("ARD helpers messaging", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

  expect_snapshot(
    bind_ard(ard, ard, .update = letters),
    error = TRUE
  )

  expect_snapshot(
    bind_ard(ard, ard, .distinct = FALSE, .update = FALSE),
    error = TRUE
  )
})

test_that("bind_ard() .order argument works", {
  withr::local_options(list(width = 120))
  withr::local_seed(1123)
  expect_snapshot(
    bind_ard(
      ard_tabulate(ADSL, by = "ARM", variables = "SEX") %>%
        # randomly sort data
        {dplyr::slice(., sample.int(nrow(.)))}, # styler: off
      .order = TRUE
    ) |>
      as.data.frame() |>
      dplyr::select(-c(context, fmt_fun, warning, error))
  )

  expect_snapshot(
    bind_ard(
      ard_tabulate(ADSL, by = "ARM", variables = "SEX") %>%
        # randomly sort data
        {dplyr::slice(., sample.int(nrow(.)))}, # styler: off
      .order = FALSE
    ) |>
      as.data.frame() |>
      dplyr::select(-c(context, fmt_fun, warning, error))
  )
})

test_that("bind_ard(.quiet)", {
  expect_silent(
    ard_summary(ADSL, variables = AGE) %>%
      {bind_ard(., ., .update = TRUE, .quiet = TRUE)} # styler: off
  )
})

test_that("bind_ard(.distinct)", {
  expect_snapshot(
    ard_summary(ADSL, variables = AGE) %>%
      {bind_ard(., ., .update = FALSE)} # styler: off
  )
})

test_that("bind_ard() detects conflicts mixed with exact duplicates", {
  a <- ard_summary(ADSL, variables = AGE, statistic = ~ continuous_summary_fns(c("mean", "sd")))
  b <- a
  b$stat[b$stat_name == "mean"] <- list(999)

  expect_error(bind_ard(a, b[b$stat_name == "mean", ], .quiet = TRUE), "duplicated statistic names")
  expect_error(bind_ard(a, b, .quiet = TRUE), "duplicated statistic names")
  expect_error(bind_ard(b, a, .quiet = TRUE), "duplicated statistic names")
  expect_error(bind_ard(a, b, .distinct = FALSE, .quiet = TRUE), "duplicated statistic names")

  for (distinct in c(TRUE, FALSE)) {
    res <- bind_ard(a, b, .distinct = distinct, .update = TRUE, .quiet = TRUE)
    expect_equal(as.data.frame(res), as.data.frame(b))
  }
})

test_that("bind_ard() retains the latest exact duplicate in input order", {
  a <- ard_summary(ADSL, variables = AGE, statistic = ~ continuous_summary_fns(c("mean", "sd", "min")))
  b <- a[a$stat_name == "mean", ]
  b$stat_label <- "Latest mean"

  res <- bind_ard(a, b, .quiet = TRUE)
  expect_equal(as.data.frame(res), as.data.frame(dplyr::bind_rows(a[-1, ], b)))
  expect_identical(res$stat_name, c("sd", "min", "mean"))
  expect_error(bind_ard(a, a, .distinct = FALSE, .quiet = TRUE), "duplicated statistic names")
})

test_that("bind_ard() respects context when removing exact duplicates", {
  a <- ard_summary(ADSL, variables = AGE, statistic = ~ continuous_summary_fns(c("mean", "sd")))
  b <- a
  b$context[b$stat_name == "mean"] <- "other"

  expect_error(bind_ard(a, b, .quiet = TRUE), "duplicated statistic names")
  expect_equal(
    as.data.frame(bind_ard(a, b, .update = TRUE, .quiet = TRUE)),
    as.data.frame(b)
  )
})

test_that("bind_ard() removes exact duplicates without context", {
  a <- ard_summary(ADSL, variables = AGE, statistic = ~ continuous_summary_fns(c("mean", "sd"))) |>
    dplyr::select(-context)
  b <- a
  b$stat[b$stat_name == "mean"] <- list(999)

  expect_equal(as.data.frame(bind_ard(a, a, .quiet = TRUE)), as.data.frame(a))
  expect_error(bind_ard(a, b, .quiet = TRUE), "duplicated statistic names")
})

test_that("bind_ard() preserves grouping and variable keys", {
  a <- ard_tabulate(ADSL, by = c(ARM, SEX), variables = c(AGEGR1, RACE))
  b <- a
  b$stat[1] <- list(999)

  expect_equal(as.data.frame(bind_ard(a, a, .quiet = TRUE)), as.data.frame(a))
  expect_error(bind_ard(a, b, .quiet = TRUE), "duplicated statistic names")
  expect_equal(
    as.data.frame(bind_ard(a, b, .update = TRUE, .quiet = TRUE)),
    as.data.frame(b)
  )
})

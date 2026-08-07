test_that("print.card() works", {
  expect_snapshot(
    ard_summary(ADSL, by = "ARM", variables = "AGE")
  )

  expect_snapshot(
    ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
  )

  expect_snapshot(
    ard_summary(ADSL, variables = "AGE", fmt_fun = AGE ~ list(~ \(x) round(x, 3)))
  )

  # checking the print of Dates
  expect_snapshot(
    ard_summary(
      data = data.frame(x = seq(as.Date("2000-01-01"), length.out = 10L, by = "day")),
      variables = x,
      statistic = ~ continuous_summary_fns(c("min", "max", "sd"))
    ) |>
      dplyr::select(-fmt_fun)
  )

  # checking the print of a complex matrix statistic result
  expect_snapshot(
    bind_ard(
      ard_attributes(mtcars, variables = mpg),
      ard_summary(
        mtcars,
        variables = mpg,
        statistic =
          ~ continuous_summary_fns(
            "mean",
            other_stats = list(vcov = \(x) lm(mpg ~ am, mtcars) |> vcov())
          )
      )
    )
  )
})

test_that("print.card() drops columns in order when too wide", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

  # narrow width: all-NULL error/warning are suppressed first, then
  # fmt_fun, stat_label, stat_fmt, context are dropped in that order
  expect_snapshot(
    print(ard, width = 60)
  )

  # all columns are shown when width is unconstrained
  expect_snapshot(
    print(ard, width = Inf)
  )
})

test_that("print.card() keeps non-NULL warning/error columns when narrow", {
  ard <- ard_summary(ADSL, by = "ARM", variables = "AGE")
  ard$warning[[1]] <- "a warning"

  expect_snapshot(
    print(ard, width = 60)
  )
})

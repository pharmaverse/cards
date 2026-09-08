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

test_that("print.compare_ard() works", {
  # widen the console so the comparison tables print in one piece rather than
  # being split into column chunks by `print.data.frame()`
  withr::local_options(width = 200)

  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

  # equal ARDs
  expect_snapshot(
    compare_ard(ard, ard)
  )

  # ARDs that differ in both their rows and their values: `x` holds the rows
  # for the ">80" age group and `y` does not, and the percentages differ
  ard_subset <-
    ard_tabulate(
      dplyr::filter(ADSL, AGEGR1 != ">80"),
      by = "ARM",
      variables = "AGEGR1"
    )

  expect_snapshot(
    compare_ard(ard, ard_subset)
  )

  # rows in `y` that do not appear in `x`
  expect_snapshot(
    compare_ard(ard_subset, ard)
  )
})

test_that("print.compare_ard() prints both mis-matched row blocks", {
  # widen the console so the comparison tables print in one piece rather than
  # being split into column chunks by `print.data.frame()`
  withr::local_options(width = 200)

  # each ARD holds an age group the other does not, so both blocks print
  ard_no_high <-
    ard_tabulate(
      dplyr::filter(ADSL, AGEGR1 != ">80"),
      by = "ARM",
      variables = "AGEGR1"
    )
  ard_no_low <-
    ard_tabulate(
      dplyr::filter(ADSL, AGEGR1 != "<65"),
      by = "ARM",
      variables = "AGEGR1"
    )

  expect_snapshot(
    compare_ard(ard_no_high, ard_no_low)
  )
})

test_that("print.compare_ard() prints the mis-matched rows themselves (#605)", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
  ard_subset <-
    ard_tabulate(
      dplyr::filter(ADSL, AGEGR1 != ">80"),
      by = "ARM",
      variables = "AGEGR1"
    )

  # the ">80" rows appear in only one of the two ARDs, so they are never part
  # of the comparison tables -- seeing ">80" on stdout means the mis-matched
  # row block itself printed. `cli` writes to stderr, so it is not captured
  # here. Asserted outside of a snapshot so that regenerating the snapshots
  # cannot quietly accept the output going missing again.
  expect_output(
    print(compare_ard(ard, ard_subset)),
    ">80",
    fixed = TRUE
  )
  expect_output(
    print(compare_ard(ard_subset, ard)),
    ">80",
    fixed = TRUE
  )
})

test_that("print.compare_ard() truncates long mis-matched row blocks", {
  # widen the console so the comparison tables print in one piece rather than
  # being split into column chunks by `print.data.frame()`
  withr::local_options(width = 200)

  # 17 sites x 3 statistics, of which only two sites survive the filter, so the
  # block is far longer than the console can hold and is truncated by the ARD
  # print method with the withheld row count in the footer
  ard <- ard_tabulate(ADSL, variables = "SITEID")
  ard_two_sites <-
    ard_tabulate(
      dplyr::filter(ADSL, SITEID %in% c("701", "703")),
      variables = "SITEID"
    )

  expect_equal(nrow(compare_ard(ard, ard_two_sites)$rows_in_x_not_y), 45L)

  expect_snapshot(
    compare_ard(ard, ard_two_sites)
  )
})

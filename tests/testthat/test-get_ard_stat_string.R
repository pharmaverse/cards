test_that("get_ard_stat_string() works", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

  expect_equal(
    get_ard_stat_string(
      ard,
      group1_level %in% "Placebo",
      variable_level %in% "65-80",
      pattern = "{n} / {N} ({p}%)"
    ),
    "42 / 86 (48.8%)"
  )

  # statistics can be in any order, and repeated
  expect_equal(
    get_ard_stat_string(
      ard,
      group1_level %in% "Placebo",
      variable_level %in% "65-80",
      pattern = "{p}% ({n}/{N}), n = {n}"
    ),
    "48.8% (42/86), n = 42"
  )

  # custom formatting functions are used
  ard_fmt <- ard_summary(
    ADSL,
    variables = "AGE",
    statistic = ~ continuous_summary_fns(c("mean", "sd")),
    fmt_fun = list(AGE = list(mean = 3, sd = 1))
  )
  expect_equal(
    get_ard_stat_string(ard_fmt, pattern = "{mean} ({sd})"),
    "75.087 (8.2)"
  )

  # `missing` is returned when all statistics are missing
  ard_miss <- ard
  ard_miss$stat[ard_miss$stat_name %in% c("n", "N")] <- list(NULL)
  expect_equal(
    get_ard_stat_string(
      ard_miss,
      group1_level %in% "Placebo",
      variable_level %in% "65-80",
      pattern = "{n} / {N}"
    ),
    ""
  )
  expect_equal(
    get_ard_stat_string(
      ard_miss,
      group1_level %in% "Placebo",
      variable_level %in% "65-80",
      pattern = "{n} / {N}",
      missing = "--"
    ),
    "--"
  )
})

test_that("get_ard_stat_string() errors with bad inputs", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

  # not an ARD
  expect_snapshot(
    get_ard_stat_string(mtcars, pattern = "{n}"),
    error = TRUE
  )

  # pattern is not a string
  expect_snapshot(
    get_ard_stat_string(ard, pattern = 1L),
    error = TRUE
  )

  # pattern does not reference any statistic
  expect_snapshot(
    get_ard_stat_string(ard, pattern = "no stats"),
    error = TRUE
  )

  # statistic not in the subset ARD
  expect_snapshot(
    get_ard_stat_string(
      ard,
      group1_level %in% "Placebo",
      variable_level %in% "65-80",
      pattern = "{n} ({not_a_stat})"
    ),
    error = TRUE
  )

  # statistic appears in more than one row
  expect_snapshot(
    get_ard_stat_string(
      ard,
      variable_level %in% "65-80",
      pattern = "{n} / {N}"
    ),
    error = TRUE
  )
})

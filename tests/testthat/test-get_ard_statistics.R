test_that("get_ard_statistics() works", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

  expect_snapshot(
    get_ard_statistics(
      ard,
      group1_level %in% "Placebo",
      variable_level %in% "65-80"
    )
  )

  expect_snapshot(
    get_ard_statistics(
      ard,
      group1_level %in% "Placebo",
      variable_level %in% "65-80",
      .attributes = "stat_label"
    )
  )

  # attributes are taken from the requested columns, not by column position
  expect_equal(
    get_ard_statistics(
      ard,
      group1_level %in% "Placebo",
      variable_level %in% "65-80",
      .attributes = c("stat_label", "stat_name")
    ) |>
      lapply(attributes),
    list(
      n = list(stat_label = "n", stat_name = "n"),
      N = list(stat_label = "N", stat_name = "N"),
      p = list(stat_label = "%", stat_name = "p")
    )
  )
})

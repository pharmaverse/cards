test_that("ard_stack() works", {
  # with by variable
  expect_error(
    ard1 <- ard_stack(
      data = mtcars,
      .by = "cyl",
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1)
    ),
    NA
  )

  # Verify ard_stack class is assigned and ordered correctly
  expect_s3_class(ard1, "ard_stack")
  expect_identical(class(ard1)[1], "ard_stack")

  expect_equal(
    ard1,
    bind_ard(
      ard_summary(data = mtcars, by = "cyl", variables = "mpg"),
      ard_tabulate_value(data = mtcars, by = "cyl", variables = "vs", value = vs ~ 1),
      ard_tabulate(data = mtcars, variables = "cyl"),
      .order = TRUE
    ),
    ignore_function_env = TRUE,
    ignore_attr = TRUE
  )

  # check equivalency NSE
  expect_equal(
    ard1,
    ard_stack(
      data = mtcars,
      .by = cyl,
      ard_summary(variables = mpg),
      ard_tabulate_value(variables = vs, value = vs ~ 1)
    ),
    ignore_function_env = TRUE,
    ignore_attr = TRUE
  )

  # check equivalency tidyselect
  mtcars2 <- mtcars
  by <- "cyl"
  var_cont <- "mpg"
  var_cat <- "vs"
  expect_equal(
    ard1,
    ard_stack(
      data = mtcars2,
      .by = all_of(by),
      ard_summary(variables = all_of(var_cont)),
      ard_tabulate_value(variables = all_of(var_cat), , value = all_of(var_cat) ~ 1)
    )
  )

  # without by variable
  expect_error(
    ard2 <- ard_stack(
      data = mtcars,
      .by = NULL,
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1)
    ),
    NA
  )

  ard_match <- bind_ard(
    ard_summary(data = mtcars, variables = "mpg"),
    ard_tabulate_value(data = mtcars, variables = "vs", value = vs ~ 1),
    .order = TRUE
  )
  attr(ard_match, "args") <- list(
    by = character(0)
  )
  expect_equal(
    ard2,
    ard_match,
    ignore_function_env = TRUE,
    ignore_attr = TRUE
  )


  expect_equal(
    ard2,
    ard_stack(
      data = mtcars2,
      ard_summary(variables = all_of(var_cont)),
      ard_tabulate_value(variables = all_of(var_cat), value = all_of(var_cat) ~ 1)
    )
  )
})

test_that("ard_stack() adding overalls", {
  expect_error(
    ard_test <- ard_stack(
      data = mtcars,
      .by = "cyl",
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1),
      .overall = TRUE
    ),
    NA
  )

  ard_match <- bind_ard(
    ard_summary(data = mtcars, by = "cyl", variables = "mpg"),
    ard_tabulate_value(data = mtcars, by = "cyl", variables = "vs", value = vs ~ 1),
    ard_summary(data = mtcars, variables = "mpg"),
    ard_tabulate_value(data = mtcars, variables = "vs", value = vs ~ 1),
    ard_tabulate(data = mtcars, variables = "cyl"),
    .update = TRUE,
    .order = TRUE
  )
  attr(ard_match, "args") <- list(
    by = "cyl"
  )
  expect_equal(
    ard_test,
    ard_match,
    ignore_attr = TRUE
  )
})


test_that("ard_stack() adding missing/attributes", {
  expect_error(
    ard_test <- ard_stack(
      data = mtcars,
      .by = "cyl",
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1),
      .missing = TRUE,
      .attributes = TRUE
    ),
    NA
  )

  expect_equal(
    ard_test,
    bind_ard(
      ard_summary(data = mtcars, by = "cyl", variables = "mpg"),
      ard_tabulate_value(data = mtcars, by = "cyl", variables = "vs", value = vs ~ 1),
      ard_missing(data = mtcars, by = "cyl", variables = c("mpg", "vs")),
      ard_tabulate(data = mtcars, variables = "cyl"),
      ard_attributes(mtcars, variables = c("mpg", "vs", "cyl")),
      .update = TRUE,
      .order = TRUE
    ),
    ignore_attr = TRUE
  )

  # including `.overall=TRUE`
  expect_error(
    ard_test_overall <- ard_stack(
      data = mtcars,
      .by = "cyl",
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1),
      .missing = TRUE,
      .overall = TRUE,
      .attributes = TRUE
    ),
    NA
  )

  expect_equal(
    ard_test_overall,
    bind_ard(
      ard_summary(data = mtcars, by = "cyl", variables = "mpg"),
      ard_tabulate_value(data = mtcars, by = "cyl", variables = "vs", value = vs ~ 1),
      ard_missing(data = mtcars, by = "cyl", variables = c("mpg", "vs")),
      ard_summary(data = mtcars, variables = "mpg"),
      ard_tabulate_value(data = mtcars, variables = "vs", value = vs ~ 1),
      ard_tabulate(data = mtcars, variables = "cyl"),
      ard_missing(data = mtcars, variables = c("mpg", "vs")),
      ard_attributes(mtcars, variables = c("mpg", "vs", "cyl")),
      .update = TRUE,
      .order = TRUE
    ),
    ignore_attr = TRUE
  )
})


test_that("ard_stack() .shuffle argument errors", {
  expect_error(
    ard_test <- ard_stack(
      data = mtcars,
      .by = "cyl",
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1),
      .shuffle = TRUE
    )
  )
})


test_that("ard_stack() adding total N", {
  expect_equal(
    ard_stack(
      mtcars,
      .by = am,
      ard_summary(variables = mpg),
      .total_n = TRUE
    ) |>
      tail(n = 1) |>
      dplyr::select(-all_ard_groups(), -all_ard_variables("levels")),
    ard_total_n(mtcars),
    ignore_attr = TRUE
  )
})

test_that("ard_stack() works with namespaced functions", {
  expect_equal(
    ard_stack(
      data = mtcars,
      cards::ard_summary(variables = "mpg")
    ),
    ard_stack(
      data = mtcars,
      ard_summary(variables = "mpg")
    )
  )
})

test_that("ard_stack() messaging", {
  withr::local_options(list(width = 150))
  expect_snapshot(
    ard_stack(
      data = mtcars,
      ard_summary(variables = "mpg"),
      .overall = TRUE
    ) |>
      head(1L)
  )

  # by argument doesn't include period in front
  expect_snapshot(
    error = TRUE,
    ard_stack(ADSL, by = "ARM", ard_summary(variables = AGE))
  )
})

test_that("ard_stack() complex call error", {
  withr::local_options(list(width = 150))
  expect_snapshot(
    {
      complex_call <- list()
      complex_call$ard_summary <- ard_summary
      ard_stack(
        data = mtcars,
        .by = am,
        complex_call$ard_summary(variables = "mpg"),
      )
    },
    error = TRUE
  )
})

test_that("ard_stack() follows ard structure", {
  expect_silent(
    ard_stack(
      data = mtcars,
      .by = "cyl",
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1)
    ) |>
      check_ard_structure(method = FALSE)
  )
})

test_that("ard_stack(.by) messaging", {
  withr::local_options(list(width = 150))
  mtcars2 <- mtcars
  mtcars2$am[1] <- NA
  mtcars2$vs[1] <- NA
  expect_snapshot(
    mtcars2 |>
      ard_stack(
        ard_summary(variables = "mpg", statistic = ~ continuous_summary_fns("N")),
        .by = c(am, vs),
        .total_n = TRUE,
        .overall = TRUE
      ) |>
      dplyr::filter(stat_name %in% "N")
  )

  mtcars3 <- mtcars
  mtcars3$am[1] <- NA
  mtcars3$vs[2] <- NaN
  expect_snapshot(
    mtcars3 |>
      ard_stack(
        ard_summary(variables = "mpg", statistic = ~ continuous_summary_fns("N")),
        .by = c(am, vs),
        .total_n = TRUE,
        .overall = TRUE
      ) |>
      dplyr::filter(stat_name %in% "N")
  )
})

test_that("ard_stack() .by_stats argument", {
  # by stats for 1 variable
  expect_error(
    ard_test <- ard_stack(
      data = mtcars,
      .by = "cyl",
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1),
      .by_stats = TRUE
    ),
    NA
  )

  expect_equal(
    ard_test,
    bind_ard(
      ard_summary(data = mtcars, by = "cyl", variables = "mpg"),
      ard_tabulate_value(data = mtcars, by = "cyl", variables = "vs", value = vs ~ 1),
      ard_tabulate(data = mtcars, variables = "cyl"),
      .update = TRUE,
      .order = TRUE
    ),
    ignore_attr = TRUE
  )

  # by stats for 2 variables
  expect_error(
    ard_test <- ard_stack(
      data = mtcars,
      .by = c("am", "cyl"),
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1),
      .by_stats = TRUE
    ),
    NA
  )

  expect_equal(
    ard_test,
    bind_ard(
      ard_summary(data = mtcars, c("am", "cyl"), variables = "mpg"),
      ard_tabulate_value(data = mtcars, c("am", "cyl"), variables = "vs", value = vs ~ 1),
      ard_tabulate(data = mtcars, variables = "am"),
      ard_tabulate(data = mtcars, variables = "cyl"),
      .update = TRUE,
      .order = TRUE
    ),
    ignore_attr = TRUE
  )

  # no by stats
  expect_error(
    ard_test <- ard_stack(
      data = mtcars,
      .by = c("am", "cyl"),
      ard_summary(variables = "mpg"),
      ard_tabulate_value(variables = "vs", value = vs ~ 1),
      .by_stats = FALSE
    ),
    NA
  )

  expect_equal(
    ard_test,
    bind_ard(
      ard_summary(data = mtcars, by = c("am", "cyl"), variables = "mpg"),
      ard_tabulate_value(data = mtcars, by = c("am", "cyl"), variables = "vs", value = vs ~ 1),
      .update = TRUE,
      .order = TRUE
    ),
    ignore_attr = TRUE
  )
})

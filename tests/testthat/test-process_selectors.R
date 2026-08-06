test_that("process_selectors() works", {
  # works with a single argument
  expect_equal(
    {
      process_selectors(mtcars, variables = starts_with("a"))
      list(variables = variables)
    },
    list(variables = "am")
  )

  # works with more than on argument
  # styler: off
  expect_equal(
    {process_selectors(mtcars, variables = starts_with("a"), by = "am")
      list(variables = variables, by = by)},
    list(variables = "am", by = "am")
  )
  # styler: on

  # proper error messaging
  expect_error(
    process_selectors(mtcars, variables = not_a_column),
    "Select among*"
  )
})

test_that("process_formula_selectors() works", {
  # works with a single argument
  # styler: off
  expect_equal({
    process_formula_selectors(mtcars, variables = starts_with("a") ~ 1L, include_env = TRUE)
    list(variables = variables)},
    list(variables = list(am = 1L)),
    ignore_attr = TRUE
  )
  # styler: on

  # works with more than on argument
  # styler: off
  expect_equal({
    process_formula_selectors(
      mtcars, variables = starts_with("a") ~ 1L, by = list(am = 1L), include_env = TRUE
    )
    list(variables = variables, by = by)},
    list(variables = list(am = 1L), by = list(am = 1L)),
    ignore_attr = TRUE
  )
  # styler: on
})

test_that("process_formula_selectors() error messaging", {
  expect_snapshot(
    process_formula_selectors(mtcars, variables = list(letters)),
    error = TRUE
  )

  expect_error(
    process_formula_selectors(mtcars, variables = list(not_a_column ~ letters)),
    "Select among*"
  )
})

test_that("compute_formula_selector() selects the last assignment when multiple appear", {
  formula_selcect_test <- everything() ~ "THE DEFAULT"
  expect_error(
    lst_compute_test <-
      compute_formula_selector(
        data = mtcars[c("mpg", "hp")],
        x = list(formula_selcect_test, mpg = "Special for MPG"),
        include_env = TRUE
      ),
    NA
  )

  # test the formula env is the same as the attached attr env
  expect_equal(
    formula_selcect_test |>
      attr(".Environment"),
    lst_compute_test[["hp"]] |>
      attr(".Environment")
  )

  # remove the env from the snapshot as it changes with each run.
  # just testing the values
  expect_snapshot(
    lst_compute_test |>
      lapply(\(x) structure(x, .Environment = NULL))
  )


  # named list elements that are not in `data` are removed from returned result
  expect_equal(
    compute_formula_selector(
      data = mtcars[c("mpg", "hp")],
      x = list(everything() ~ "THE DEFAULT", not_present = "Special for MPG")
    ),
    list(mpg = "THE DEFAULT", hp = "THE DEFAULT"),
    ignore_attr = TRUE
  )
  expect_equal(
    compute_formula_selector(
      data = mtcars[c("mpg", "hp")],
      x = list(mpg = "THE DEFAULT", not_present = "Special for MPG")
    ),
    list(mpg = "THE DEFAULT")
  )
  expect_equal(
    compute_formula_selector(
      data = mtcars[c("mpg", "hp")],
      x = list(not_present = "Special for MPG")
    ),
    list(NAME = NULL) |> compact()
  )

  # styler: off
  expect_equal({
    label <- list(ARM = "treatment", ARM = "TREATMENT")
    compute_formula_selector(
      ADSL,
      x = label
    )},
    list(ARM = "TREATMENT")
  )
  # styler: on
})

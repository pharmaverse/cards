test_that("nest_for_ard() works", {
  expect_equal(
    nest_for_ard(mtcars, strata = c("cyl", "gear"), rename = TRUE) |>
      nrow(),
    8L
  )

  expect_equal(
    nest_for_ard(mtcars, rename = TRUE) |>
      nrow(),
    1L
  )

  expect_equal(
    nest_for_ard(mtcars, by = "am", strata = c("cyl", "gear"), rename = TRUE) |>
      nrow(),
    16L
  )

  # check order of lgl variables (see Issue #411)
  expect_equal(
    mtcars |>
      dplyr::mutate(am = as.logical(am)) |>
      nest_for_ard(by = "am", include_data = FALSE) |>
      dplyr::pull(group1_level) |>
      unlist(),
    c(FALSE, TRUE)
  )
})

test_that("nest_for_ard() attaches 'args' attribute", {
  res <- nest_for_ard(mtcars,
    by = "am",
    strata = "cyl"
  )

  args <- attr(res, "args")

  expect_equal(args$strata, "cyl")
  expect_equal(args$by, "am")
})

test_that("nest_for_ard() preserves attributes of the nested data", {
  # column labels and data frame attributes must survive the subsetting
  make_data <- function(as_tibble) {
    data <- data.frame(g = c("a", "b", "a"), v = 1:3)
    attr(data$g, "label") <- "G label"
    attr(data$v, "label") <- "V label"
    if (isTRUE(as_tibble)) data <- dplyr::as_tibble(data)
    attr(data, "my_attr") <- "keep me"
    data
  }

  for (as_tibble in c(FALSE, TRUE)) {
    res <- nest_for_ard(make_data(as_tibble), by = "g")
    expect_equal(attr(res$data[[1]], "my_attr"), "keep me")
    expect_equal(attr(res$data[[1]]$v, "label"), "V label")

    res_incl <- nest_for_ard(make_data(as_tibble), by = "g", include_by_and_strata = TRUE)
    expect_equal(attr(res_incl$data[[1]]$g, "label"), "G label")
  }

  # non-default row names are retained for base data frames
  data <- data.frame(g = c("a", "b", "a"), v = 1:3, row.names = c("r1", "r2", "r3"))
  expect_equal(
    nest_for_ard(data, by = "g")$data |> lapply(row.names),
    list(c("r1", "r3"), "r2")
  )
})

test_that("nest_for_ard() works with classed by/strata columns", {
  # `.unique_and_sorted()` can leave the group grid bare where `data` is classed
  data <- data.frame(v = 1:3)
  data$g <- structure(c("a", "b", "a"), class = c("my_class", "character"))

  expect_equal(
    nest_for_ard(data, by = "g")$data |> lapply(nrow),
    list(2L, 1L)
  )
  expect_equal(
    nest_for_ard(data, strata = "g")$data |> lapply(nrow),
    list(2L, 1L)
  )
})

test_that("nest_for_ard() drops by/strata columns for grouped data frames", {
  res <-
    data.frame(g = c("a", "b", "a"), v = 1:3) |>
    dplyr::group_by(g) |>
    nest_for_ard(by = "g")

  expect_equal(lapply(res$data, names), list("v", "v"))
})

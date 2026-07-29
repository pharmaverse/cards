test_that(".warn_or_error errors/warns depending on input", {
  expect_message(
    .message_or_error("something", FALSE)
  )
  expect_error(
    .message_or_error("something", TRUE)
  )
})

test_that(".unique_and_sorted() orders characters in the C locale (matches dplyr::arrange())", {
  x <- c("b", "A", "a", "B", "a-1", "a 1")
  expect_identical(
    .unique_and_sorted(x),
    dplyr::arrange(dplyr::tibble(x = unique(x)), x)$x
  )
  # factors keep their level order; logicals are always FALSE, TRUE
  expect_identical(
    .unique_and_sorted(factor(c("m", "a"), levels = c("m", "a"))),
    factor(c("m", "a"), levels = c("m", "a"))
  )
  expect_identical(.unique_and_sorted(c(TRUE, FALSE)), c(FALSE, TRUE))
})

test_that(".unique_and_sorted() ordering is independent of the session locale", {
  # testthat runs tests in the C locale, so a regression to locale-dependent
  # sorting is only observable after switching to a locale whose collation
  # differs from C. Skip when no such locale can be set on this machine.
  skip_on_cran()
  skip_if_not_installed("withr")

  differs <- FALSE
  for (loc in c(
    "en_US.UTF-8", "en_US.utf8", "English_United States.utf8",
    "English_United States.1252", "English"
  )) {
    set_ok <- tryCatch(
      {
        suppressWarnings(withr::local_collate(loc))
        TRUE
      },
      error = function(e) FALSE
    )
    if (set_ok && !identical(sort(c("a", "A")), c("A", "a"))) {
      differs <- TRUE
      break
    }
  }
  skip_if(!differs, "no collate locale available where base::sort() differs from the C locale")

  # base::sort() is now locale-dependent, but .unique_and_sorted() must stay
  # C-ordered (uppercase before lowercase)
  expect_identical(sort(c("b", "A", "a", "B")), c("a", "A", "b", "B"))
  expect_identical(.unique_and_sorted(c("b", "A", "a", "B")), c("A", "B", "a", "b"))
})

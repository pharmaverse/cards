skip_on_cran()

# a small hierarchical ARD where "Vascular" and "PT3" never occur in the data.
# The expected universe is supplied by the caller via the `levels` data frame,
# so the source columns need not be factors.
make_ard <- function(by = FALSE) {
  set.seed(1)
  adae <- data.frame(
    USUBJID = sprintf("S%03d", 1:20),
    SOC = sample(c("Cardiac", "GI"), 20, TRUE),
    PT = sample(c("PT1", "PT2"), 20, TRUE),
    TRT = rep(c("A", "B"), 10)
  )
  denom <- data.frame(USUBJID = sprintf("S%03d", 1:30), TRT = rep(c("A", "B"), 15))
  if (by) {
    ard_stack_hierarchical(adae, variables = c(SOC, PT), by = TRT, id = USUBJID, denominator = denom)
  } else {
    ard_stack_hierarchical(adae, variables = c(SOC, PT), id = USUBJID, denominator = denom)
  }
}

# first level value from a list-column
lvl1 <- function(col) {
  vapply(col, function(z) {
    z <- as.character(z)
    if (length(z)) z[[1L]] else NA_character_
  }, character(1L))
}

test_that("add_hierarchical_unobserved_levels() completes the top level from a one-column data frame", {
  ard <- make_ard()
  out <- add_hierarchical_unobserved_levels(
    ard,
    levels = data.frame(SOC = c("Cardiac", "GI", "Vascular"))
  )

  expect_s3_class(out, "ard_stack_hierarchical")
  expect_setequal(
    unique(lvl1(out$variable_level[out$variable == "SOC"])),
    c("Cardiac", "GI", "Vascular")
  )
  # top-level only: no PT rows are invented under the unobserved parent
  expect_false(any(lvl1(out$group1_level[out$variable == "PT"]) == "Vascular"))
  # the added row has n = 0 and carries a real denominator N
  expect_equal(
    out$stat[out$variable == "SOC" & lvl1(out$variable_level) == "Vascular" & out$stat_name == "n"][[1L]],
    0
  )
  expect_equal(
    out$stat[out$variable == "SOC" & lvl1(out$variable_level) == "Vascular" & out$stat_name == "N"][[1L]],
    30
  )
  # proportion is left as NaN (0 / 0 is undefined), not asserted as zero
  expect_true(
    is.nan(out$stat[out$variable == "SOC" & lvl1(out$variable_level) == "Vascular" & out$stat_name == "p"][[1L]])
  )
})

test_that("add_hierarchical_unobserved_levels() completes nested levels under observed parents", {
  ard <- make_ard()
  out <- add_hierarchical_unobserved_levels(
    ard,
    levels = data.frame(
      SOC = c("Cardiac", "Cardiac", "Cardiac", "GI", "GI", "GI"),
      PT = c("PT1", "PT2", "PT3", "PT1", "PT2", "PT3")
    )
  )

  # the unobserved PT3 is filled under each observed parent
  for (parent in c("Cardiac", "GI")) {
    expect_true(
      "PT3" %in% lvl1(out$variable_level[out$variable == "PT" & lvl1(out$group1_level) == parent])
    )
  }
})

test_that("add_hierarchical_unobserved_levels() adds children of a missing parent", {
  ard <- make_ard()
  out <- add_hierarchical_unobserved_levels(
    ard,
    levels = data.frame(SOC = c("Vascular", "Vascular"), PT = c("PTX", "PTY"))
  )

  # the unobserved parent is added at the top level
  expect_true("Vascular" %in% lvl1(out$variable_level[out$variable == "SOC"]))
  # and its children are added underneath it
  kids <- out$variable_level[out$variable == "PT" & lvl1(out$group1_level) == "Vascular"]
  expect_setequal(unique(lvl1(kids)), c("PTX", "PTY"))
  expect_true(all(
    unlist(out$stat[out$variable == "PT" & lvl1(out$group1_level) == "Vascular" & out$stat_name == "n"]) == 0
  ))
})

test_that("add_hierarchical_unobserved_levels() adds a missing child of an observed parent", {
  ard <- make_ard()
  out <- add_hierarchical_unobserved_levels(
    ard,
    levels = data.frame(SOC = c("Cardiac", "Cardiac", "Cardiac"), PT = c("PT1", "PT2", "PT3"))
  )

  expect_true("PT3" %in% lvl1(out$variable_level[out$variable == "PT" & lvl1(out$group1_level) == "Cardiac"]))
  expect_equal(
    out$stat[out$variable == "PT" & lvl1(out$variable_level) == "PT3" &
      lvl1(out$group1_level) == "Cardiac" & out$stat_name == "n"][[1L]],
    0
  )
})

test_that("add_hierarchical_unobserved_levels() completes parents and children in one call", {
  ard <- make_ard()
  levels <- data.frame(
    SOC = c("Vascular", "Vascular", "Cardiac"),
    PT = c("PTX", "PTY", "PT3")
  )
  out <- add_hierarchical_unobserved_levels(ard, levels = levels)

  expect_true("Vascular" %in% lvl1(out$variable_level[out$variable == "SOC"]))
  expect_setequal(
    unique(lvl1(out$variable_level[out$variable == "PT" & lvl1(out$group1_level) == "Vascular"])),
    c("PTX", "PTY")
  )
  expect_true("PT3" %in% lvl1(out$variable_level[out$variable == "PT" & lvl1(out$group1_level) == "Cardiac"]))
})

test_that("add_hierarchical_unobserved_levels() preserves the by structure", {
  ard <- make_ard(by = TRUE)
  out <- add_hierarchical_unobserved_levels(
    ard,
    levels = data.frame(SOC = "Vascular", PT = "PTX")
  )

  # one Vascular SOC row per by-group, with the arm retained in group1
  vasc_soc <- out[out$variable == "SOC" & lvl1(out$variable_level) == "Vascular" & out$stat_name == "n", ]
  expect_equal(nrow(vasc_soc), 2L)
  expect_setequal(lvl1(vasc_soc$group1_level), c("A", "B"))

  # one Vascular > PTX row per by-group, with the parent SOC in group2
  vasc_pt <- out[out$variable == "PT" & lvl1(out$variable_level) == "PTX" & out$stat_name == "n", ]
  expect_equal(nrow(vasc_pt), 2L)
  expect_setequal(lvl1(vasc_pt$group2_level), c("Vascular"))
})

test_that("add_hierarchical_unobserved_levels() is a no-op when nothing is missing", {
  ard <- make_ard()
  # every combination in `levels` is already observed, so the input is unchanged
  out <- add_hierarchical_unobserved_levels(
    ard,
    levels = data.frame(
      SOC = c("Cardiac", "Cardiac", "GI", "GI"),
      PT = c("PT1", "PT2", "PT1", "PT2")
    )
  )
  expect_equal(nrow(out), nrow(ard))
})

test_that("add_hierarchical_unobserved_levels() input checks", {
  ard <- make_ard()
  expect_error(
    add_hierarchical_unobserved_levels(data.frame(a = 1), levels = data.frame(SOC = "X")),
    class = "check_class"
  )
  expect_error(
    add_hierarchical_unobserved_levels(ard, levels = "not a data frame"),
    class = "check_data_frame"
  )
  # a column that is not a hierarchical variable in the ARD is rejected
  expect_error(
    add_hierarchical_unobserved_levels(ard, levels = data.frame(NOTAVAR = "X")),
    "Unknown column"
  )
})

test_that("add_hierarchical_unobserved_levels() output remains a valid ARD", {
  ard <- make_ard()
  out <- add_hierarchical_unobserved_levels(
    ard,
    levels = data.frame(SOC = "Vascular", PT = "PTX")
  )
  expect_no_error(sort_ard_hierarchical(out))
})

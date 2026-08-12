skip_on_cran()

# small fixture: two SOCs, treatment arm as the (3-level) `by` variable
ADAE_subset <- cards::ADAE |>
  dplyr::filter(AESOC %in% unique(cards::ADAE$AESOC)[1:2])

ard <- ard_stack_hierarchical(
  data = ADAE_subset,
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  denominator = cards::ADSL,
  id = USUBJID
)

# helper: extract the `p` value for a treatment arm / SOC / term from an ARD
.p_at <- function(x, trt, soc, term = NULL) {
  gv <- function(col) vapply(col, function(z) if (length(z) == 0) NA_character_ else as.character(z[[1]]), "")
  r <- x[x$stat_name == "p" & x$context == "hierarchical", ]
  keep <- gv(r$group1_level) == trt
  if (is.null(term)) {
    keep <- keep & r$variable == "AESOC" & gv(r$variable_level) == soc
  } else {
    keep <- keep & r$variable == "AEDECOD" & gv(r$group2_level) == soc & gv(r$variable_level) == term
  }
  r <- r[which(keep), ]
  if (nrow(r) == 0) 0 else as.numeric(r$stat[[1]])
}

test_that("diff_ard_hierarchical() works", {
  withr::local_options(width = 200)

  expect_silent(
    d <- diff_ard_hierarchical(ard, levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo"))
  )

  # only estimate rows are returned
  expect_setequal(d$stat_name, "estimate")
  # the `by` (TRTA) group column has been collapsed away
  expect_false("TRTA" %in% unlist(d$group1))
  expect_s3_class(d, "ard_stack_hierarchical")

  # new statistic metadata columns
  expect_setequal(d$context, "diff_hierarchical")
  expect_setequal(d$stat_label, "% difference")
  expect_true(all(vapply(d$fmt_fun, is.function, logical(1))))
  expect_true(all(c("warning", "error") %in% names(d)))
  # fmt_fun scales by 100 and rounds to 3 decimals
  expect_equal(d$fmt_fun[[1]](0.024086), "2.4")

  expect_snapshot(
    d |>
      dplyr::select(all_ard_groups(), all_ard_variables(), stat_name, stat) |>
      print(n = 100)
  )
})

test_that("diff_ard_hierarchical() computes correct differences", {
  d <- diff_ard_hierarchical(ard, levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo"))
  gv <- function(col) vapply(col, function(z) if (length(z) == 0) NA_character_ else as.character(z[[1]]), "")

  # check an SOC-level difference
  soc <- unique(cards::ADAE$AESOC)[1]
  d_soc <- d[which(d$variable == "AESOC" & gv(d$variable_level) == soc), ]
  expect_equal(
    as.numeric(d_soc$stat[[1]]),
    .p_at(ard, "Xanomeline High Dose", soc) - .p_at(ard, "Placebo", soc)
  )

  # check a term-level difference
  term_rows <- d[which(d$variable == "AEDECOD"), ]
  soc_t <- gv(term_rows$group1_level)[1]
  term_t <- gv(term_rows$variable_level)[1]
  expect_equal(
    as.numeric(term_rows$stat[[1]]),
    .p_at(ard, "Xanomeline High Dose", soc_t, term_t) -
      .p_at(ard, "Placebo", soc_t, term_t)
  )
})

test_that("diff_ard_hierarchical() flat and two-cell `levels` forms agree, and sign flips", {
  d_flat <- diff_ard_hierarchical(ard, levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo"))
  d_cell <- diff_ard_hierarchical(
    ard,
    levels = list(list(TRTA = "Xanomeline High Dose"), list(TRTA = "Placebo"))
  )
  expect_equal(unlist(d_flat$stat), unlist(d_cell$stat))

  d_rev <- diff_ard_hierarchical(ard, levels = list(TRTA = "Placebo", TRTA = "Xanomeline High Dose"))
  expect_equal(unlist(d_flat$stat), -unlist(d_rev$stat))
})

test_that("diff_ard_hierarchical() defaults to first-minus-second for a single 2-level `by`", {
  keep <- c("Placebo", "Xanomeline High Dose")
  ard_2lvl <- ard_stack_hierarchical(
    data = dplyr::filter(ADAE_subset, TRTA %in% keep),
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = dplyr::filter(cards::ADSL, TRTA %in% keep),
    id = USUBJID
  )

  expect_silent(d_default <- diff_ard_hierarchical(ard_2lvl))
  expect_setequal(d_default$stat_name, "estimate")

  # default order follows the source-data (factor) order: Placebo minus High Dose
  d_explicit <- diff_ard_hierarchical(ard_2lvl, levels = list(TRTA = "Placebo", TRTA = "Xanomeline High Dose"))
  expect_equal(unlist(d_default$stat), unlist(d_explicit$stat))
})

test_that("diff_ard_hierarchical() works with more than one `by` variable", {
  ard2 <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(AESOC, AEDECOD),
    by = c(TRTA, SEX),
    denominator = cards::ADSL,
    id = USUBJID
  )

  d_cell <- diff_ard_hierarchical(
    ard2,
    levels = list(
      list(TRTA = "Xanomeline High Dose", SEX = "F"),
      list(TRTA = "Placebo", SEX = "F")
    )
  )
  expect_setequal(d_cell$stat_name, "estimate")

  # flat form (difference variable repeated + other `by` variable pinned) agrees
  d_flat <- diff_ard_hierarchical(
    ard2,
    levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo", SEX = "F")
  )
  expect_equal(unlist(d_cell$stat), unlist(d_flat$stat))
})

test_that("diff_ard_hierarchical() output can be sorted", {
  d <- diff_ard_hierarchical(ard, levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo"))
  expect_silent(sort_ard_hierarchical(d, sort = everything() ~ "alphanumeric"))
})

test_that("diff_ard_hierarchical() input checks", {
  # no `by` variable
  ard_noby <- ard_stack_hierarchical(
    ADAE_subset,
    variables = c(AESOC, AEDECOD), denominator = cards::ADSL, id = USUBJID
  )
  expect_snapshot(diff_ard_hierarchical(ard_noby), error = TRUE)

  # `p` statistic absent (counts only)
  ard_cnt <- ard_stack_hierarchical_count(
    ADAE_subset,
    variables = c(AESOC, AEDECOD), by = TRTA, denominator = cards::ADSL
  )
  expect_snapshot(diff_ard_hierarchical(ard_cnt), error = TRUE)

  # 3-level `by` with no `levels`
  expect_snapshot(diff_ard_hierarchical(ard), error = TRUE)

  # name not a `by` variable
  expect_snapshot(diff_ard_hierarchical(ard, levels = list(FOO = "a", FOO = "b")), error = TRUE)

  # level not present in the data
  expect_snapshot(diff_ard_hierarchical(ard, levels = list(TRTA = "Placebo", TRTA = "Nope")), error = TRUE)

  # only one entry (not a difference)
  expect_snapshot(diff_ard_hierarchical(ard, levels = list(TRTA = "Placebo")), error = TRUE)

  # identical two-cell groups
  expect_snapshot(
    diff_ard_hierarchical(ard, levels = list(list(TRTA = "Placebo"), list(TRTA = "Placebo"))),
    error = TRUE
  )
})

test_that("diff_ard_hierarchical() warns when input is not a stacked hierarchical ARD", {
  ard_noclass <- ard
  class(ard_noclass) <- setdiff(class(ard_noclass), c("ard_stack_hierarchical", "ard_stack_hierarchical_count"))
  expect_warning(
    diff_ard_hierarchical(ard_noclass, levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo")),
    "stacked hierarchical ARDs"
  )
})

test_that("diff_ard_hierarchical() handles a node present in only one group", {
  gv <- function(col) vapply(col, function(z) if (length(z) == 0) NA_character_ else as.character(z[[1]]), "")

  # drop the High Dose `p` rows for one AE term so it exists only in the Placebo group
  term_rows <- ard[ard$stat_name == "p" & ard$context == "hierarchical" & ard$variable == "AEDECOD", ]
  term <- gv(term_rows$variable_level)[1]
  drop <- ard$variable == "AEDECOD" &
    gv(ard$variable_level) == term &
    gv(ard$group1_level) == "Xanomeline High Dose"
  ard_missing <- ard[!drop, ]

  d <- diff_ard_hierarchical(ard_missing, levels = list(TRTA = "Xanomeline High Dose", TRTA = "Placebo"))
  dr <- d[which(d$variable == "AEDECOD" & gv(d$variable_level) == term), ]
  p_placebo <- .p_at(ard, "Placebo", gv(dr$group1_level)[1], term)
  # absent High Dose rate treated as 0: difference is 0 - p(Placebo)
  expect_equal(as.numeric(dr$stat[[1]]), 0 - p_placebo)
})

test_that("diff_ard_hierarchical() default level order falls back without `by` tabulation rows", {
  keep <- c("Placebo", "Xanomeline High Dose")
  ard_2lvl_nobystat <- ard_stack_hierarchical(
    data = dplyr::filter(ADAE_subset, TRTA %in% keep),
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = dplyr::filter(cards::ADSL, TRTA %in% keep),
    id = USUBJID,
    by_stats = FALSE
  )
  expect_false(any(ard_2lvl_nobystat$variable == "TRTA"))
  expect_silent(d <- diff_ard_hierarchical(ard_2lvl_nobystat))
  expect_setequal(d$stat_name, "estimate")
})

test_that("diff_ard_hierarchical() input checks with multiple `by` variables", {
  ard2 <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(AESOC, AEDECOD),
    by = c(TRTA, SEX),
    denominator = cards::ADSL,
    id = USUBJID
  )

  # more than one `by` variable and no `levels`
  expect_snapshot(diff_ard_hierarchical(ard2), error = TRUE)

  # flat form with no repeated (difference) variable
  expect_snapshot(diff_ard_hierarchical(ard2, levels = list(TRTA = "Placebo", SEX = "F")), error = TRUE)

  # flat form missing another `by` variable
  expect_snapshot(
    diff_ard_hierarchical(ard2, levels = list(TRTA = "Placebo", TRTA = "Xanomeline High Dose")),
    error = TRUE
  )

  # two-cell form: a cell missing a `by` variable
  expect_snapshot(
    diff_ard_hierarchical(ard2, levels = list(list(TRTA = "Placebo"), list(TRTA = "Xanomeline High Dose"))),
    error = TRUE
  )
})

test_that("diff_ard_hierarchical() input checks on `levels` structure", {
  # flat form not fully named
  expect_snapshot(diff_ard_hierarchical(ard, levels = list("Placebo", "Xanomeline High Dose")), error = TRUE)

  # flat element is not a single level
  expect_snapshot(diff_ard_hierarchical(ard, levels = list(TRTA = c("Placebo", "Xanomeline High Dose"))), error = TRUE)

  # flat form repeats a level (two identical levels)
  expect_snapshot(diff_ard_hierarchical(ard, levels = list(TRTA = "Placebo", TRTA = "Placebo")), error = TRUE)

  # two-cell form with an unnamed cell element
  expect_snapshot(
    diff_ard_hierarchical(ard, levels = list(list("Placebo"), list(TRTA = "Placebo"))),
    error = TRUE
  )

  # two-cell form repeating a `by` variable within a cell
  expect_snapshot(
    diff_ard_hierarchical(
      ard,
      levels = list(list(TRTA = "Placebo", TRTA = "Xanomeline High Dose"), list(TRTA = "Placebo"))
    ),
    error = TRUE
  )

  # two-cell form with a cell element that is not a single level
  expect_snapshot(
    diff_ard_hierarchical(ard, levels = list(list(TRTA = c("Placebo", "Xanomeline High Dose")), list(TRTA = "Placebo"))),
    error = TRUE
  )

  # two-cell form with a level not present in the data
  expect_snapshot(
    diff_ard_hierarchical(ard, levels = list(list(TRTA = "Nope"), list(TRTA = "Placebo"))),
    error = TRUE
  )
})

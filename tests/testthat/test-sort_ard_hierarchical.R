skip_on_cran()

ADAE_subset <- cards::ADAE |>
  dplyr::filter(AETERM %in% unique(cards::ADAE$AETERM)[1:5])

ard <- ard_stack_hierarchical(
  data = ADAE_subset,
  variables = c(SEX, RACE, AETERM),
  by = TRTA,
  denominator = cards::ADSL,
  id = USUBJID,
  over_variables = TRUE
)

test_that("sort_ard_hierarchical() works", {
  withr::local_options(width = 200)

  expect_silent(ard_s <- sort_ard_hierarchical(ard))
  expect_snapshot(
    ard_s |>
      dplyr::select(all_ard_groups(), all_ard_variables()) |>
      print(n = 50)
  )

  # works after filtering
  expect_silent(
    ard_s <- ard |> filter_ard_hierarchical(n > 20) |> sort_ard_hierarchical()
  )
})

test_that("sort_ard_hierarchical(sort = 'descending') works", {
  # descending count (default)
  expect_silent(ard <- sort_ard_hierarchical(ard))
  expect_equal(
    ard |>
      dplyr::filter(variable == "SEX") |>
      dplyr::select(variable_level) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    c("F", "M")
  )
  expect_equal(
    ard |>
      dplyr::filter(variable == "RACE") |>
      dplyr::select(
        all_ard_groups("levels"),
        -"group1_level",
        all_ard_variables()
      ) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "WHITE",
      "BLACK OR AFRICAN AMERICAN",
      "WHITE",
      "BLACK OR AFRICAN AMERICAN",
      "AMERICAN INDIAN OR ALASKA NATIVE"
    )
  )
  expect_equal(
    ard |>
      dplyr::filter(variable == "AETERM") |>
      dplyr::select(
        all_ard_groups("levels"),
        -"group1_level",
        all_ard_variables()
      ) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "APPLICATION SITE PRURITUS",
      "ERYTHEMA",
      "APPLICATION SITE ERYTHEMA",
      "DIARRHOEA",
      "APPLICATION SITE PRURITUS",
      "ERYTHEMA",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
      "DIARRHOEA",
      "APPLICATION SITE PRURITUS",
      "APPLICATION SITE ERYTHEMA",
      "ERYTHEMA",
      "DIARRHOEA",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
      "APPLICATION SITE PRURITUS",
      "DIARRHOEA",
      "ERYTHEMA",
      "ERYTHEMA"
    )
  )
})

# helper: map an ARD list-column of scalar levels to a length-preserving character vector
.lvl_chr <- function(col) {
  vapply(col, \(z) if (length(z)) as.character(z[[1]]) else NA_character_, character(1))
}

# helper: the distinct order of a hierarchy variable's levels, optionally within a section
.level_order <- function(x, variable, group_level_col = NULL, group_level = NULL) {
  keep <- x$variable == variable & x$stat_name == "n"
  if (!is.null(group_level_col)) {
    keep <- keep & .lvl_chr(x[[group_level_col]]) == group_level
  }
  unique(.lvl_chr(x$variable_level[which(keep)]))
}

test_that("sort_ard_hierarchical(by_level) restricts descending sorting to a single by level", {
  ADAE_subset2 <- cards::ADAE |>
    dplyr::filter(AEDECOD %in% unique(cards::ADAE$AEDECOD)[1:20])

  ard_full <- ard_stack_hierarchical(
    data = ADAE_subset2,
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID
  )

  expect_silent(
    ard_by <- sort_ard_hierarchical(
      ard_full,
      sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"),
      by_level = list(TRTA = "Placebo")
    )
  )

  # oracle: sorting restricted to the "Placebo" counts is equivalent to sorting an
  # ARD whose counts are derived only from "Placebo" subjects
  ard_oracle <- ard_stack_hierarchical(
    data = dplyr::filter(ADAE_subset2, TRTA == "Placebo"),
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = dplyr::filter(cards::ADSL, TRTA == "Placebo"),
    id = USUBJID
  ) |>
    sort_ard_hierarchical(sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"))

  soc <- "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS"
  placebo_rows <- \(x) x[.lvl_chr(x$group1_level) %in% "Placebo", ]
  expect_equal(
    .level_order(placebo_rows(ard_by), "AEDECOD", "group2_level", soc),
    .level_order(ard_oracle, "AEDECOD", "group2_level", soc)
  )

  # the restricted order differs from the default (summed across all arms) order
  ard_default <- sort_ard_hierarchical(
    ard_full,
    sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending")
  )
  expect_false(
    identical(
      .level_order(placebo_rows(ard_by), "AEDECOD", "group2_level", soc),
      .level_order(placebo_rows(ard_default), "AEDECOD", "group2_level", soc)
    )
  )
})

test_that("sort_ard_hierarchical(by_level) works with multiple by variables", {
  ADAE_subset2 <- cards::ADAE |>
    dplyr::filter(AEDECOD %in% unique(cards::ADAE$AEDECOD)[1:20])

  ard_full <- ard_stack_hierarchical(
    data = ADAE_subset2,
    variables = c(AESOC, AEDECOD),
    by = c(TRTA, SEX),
    denominator = cards::ADSL,
    id = USUBJID
  )

  # restricting on the outer by variable (TRTA)
  expect_silent(
    ard_trt <- sort_ard_hierarchical(
      ard_full,
      sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"),
      by_level = list(TRTA = "Placebo")
    )
  )
  ard_oracle <- ard_stack_hierarchical(
    data = dplyr::filter(ADAE_subset2, TRTA == "Placebo"),
    variables = c(AESOC, AEDECOD),
    by = c(TRTA, SEX),
    denominator = dplyr::filter(cards::ADSL, TRTA == "Placebo"),
    id = USUBJID
  ) |>
    sort_ard_hierarchical(sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"))

  soc <- "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS"
  extract_order <- function(x) {
    keep <- .lvl_chr(x$group1_level) %in% "Placebo" & .lvl_chr(x$group2_level) %in% "F" &
      x$variable == "AEDECOD" & x$stat_name == "n" & .lvl_chr(x$group3_level) %in% soc
    unique(.lvl_chr(x$variable_level[which(keep)]))
  }
  expect_equal(extract_order(ard_trt), extract_order(ard_oracle))

  # restricting on an inner by variable (SEX) also runs and can be combined
  expect_silent(
    sort_ard_hierarchical(
      ard_full,
      sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"),
      by_level = list(SEX = "F")
    )
  )
  expect_silent(
    sort_ard_hierarchical(
      ard_full,
      sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"),
      by_level = list(TRTA = "Placebo", SEX = "F")
    )
  )
})

test_that("sort_ard_hierarchical(by_level = NULL) matches the default", {
  expect_identical(
    sort_ard_hierarchical(ard),
    sort_ard_hierarchical(ard, by_level = NULL)
  )
})

test_that("sort_ard_hierarchical(sort = 'alphanumeric') works", {
  expect_silent(ard <- sort_ard_hierarchical(ard, sort = "alphanumeric"))

  expect_equal(
    ard |>
      dplyr::filter(variable == "SEX") |>
      dplyr::select(variable_level) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    sort(c("F", "M"))
  )
  expect_equal(
    ard |>
      dplyr::filter(variable == "RACE") |>
      dplyr::select(
        all_ard_groups("levels"),
        -"group1_level",
        all_ard_variables()
      ) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "BLACK OR AFRICAN AMERICAN",
      "WHITE",
      "AMERICAN INDIAN OR ALASKA NATIVE",
      "BLACK OR AFRICAN AMERICAN",
      "WHITE"
    )
  )
  expect_equal(
    ard |>
      dplyr::filter(variable == "AETERM") |>
      dplyr::select(
        all_ard_groups("levels"),
        -"group1_level",
        all_ard_variables()
      ) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "APPLICATION SITE PRURITUS",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
      "DIARRHOEA",
      "ERYTHEMA",
      "APPLICATION SITE ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "DIARRHOEA",
      "ERYTHEMA",
      "ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "DIARRHOEA",
      "ERYTHEMA",
      "APPLICATION SITE ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
      "DIARRHOEA",
      "ERYTHEMA"
    )
  )
})

test_that("sort_ard_hierarchical(sort) works with different sorting methods for each variable", {
  expect_silent(
    ard <- sort_ard_hierarchical(
      ard,
      sort = list(SEX ~ "alphanumeric", RACE = "descending", AETERM = "alphanumeric")
    )
  )

  expect_equal(
    ard |>
      dplyr::filter(variable == "SEX") |>
      dplyr::select(variable_level) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    sort(c("F", "M"))
  )
  expect_equal(
    ard |>
      dplyr::filter(variable == "RACE") |>
      dplyr::select(
        all_ard_groups("levels"),
        -"group1_level",
        all_ard_variables()
      ) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "WHITE",
      "BLACK OR AFRICAN AMERICAN",
      "WHITE",
      "BLACK OR AFRICAN AMERICAN",
      "AMERICAN INDIAN OR ALASKA NATIVE"
    )
  )
  expect_equal(
    ard |>
      dplyr::filter(variable == "AETERM") |>
      dplyr::select(
        all_ard_groups("levels"),
        -"group1_level",
        all_ard_variables()
      ) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "APPLICATION SITE ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "DIARRHOEA",
      "ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
      "DIARRHOEA",
      "ERYTHEMA",
      "APPLICATION SITE ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
      "DIARRHOEA",
      "ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "DIARRHOEA",
      "ERYTHEMA",
      "ERYTHEMA"
    )
  )
})

test_that("sort_ard_hierarchical() works when there is no overall row in x", {
  ard_no_overall <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    over_variables = FALSE
  )

  # sort = 'descending'
  expect_silent(ard_no_overall <- sort_ard_hierarchical(ard_no_overall))
  expect_equal(
    ard_no_overall |> dplyr::select(all_ard_groups(), all_ard_variables()),
    ard |>
      sort_ard_hierarchical() |>
      dplyr::select(all_ard_groups(), all_ard_variables()) |>
      dplyr::filter(variable != "..ard_hierarchical_overall..")
  )

  # sort = 'alphanumeric'
  expect_silent(
    ard_no_overall <- sort_ard_hierarchical(
      ard_no_overall,
      sort = "alphanumeric"
    )
  )
  expect_equal(
    ard_no_overall |> dplyr::select(all_ard_groups(), all_ard_variables()),
    ard |>
      sort_ard_hierarchical("alphanumeric") |>
      dplyr::select(all_ard_groups(), all_ard_variables()) |>
      dplyr::filter(variable != "..ard_hierarchical_overall..")
  )
})

test_that("sort_ard_hierarchical() works with only one variable in x", {
  ard_single <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = AETERM,
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    over_variables = TRUE
  )

  # sort = 'descending'
  expect_silent(ard_single <- sort_ard_hierarchical(ard_single))
  expect_equal(
    ard_single |>
      dplyr::filter(variable == "AETERM") |>
      dplyr::pull(variable_level) |>
      unlist() |>
      unique(),
    c(
      "APPLICATION SITE PRURITUS",
      "ERYTHEMA",
      "APPLICATION SITE ERYTHEMA",
      "DIARRHOEA",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE"
    )
  )

  # sort = 'alphanumeric'
  expect_silent(
    ard_single <- sort_ard_hierarchical(ard_single, sort = "alphanumeric")
  )
  expect_equal(
    ard_single |>
      dplyr::filter(variable == "AETERM") |>
      dplyr::pull(variable_level) |>
      unlist() |>
      unique(),
    sort(unique(ADAE_subset$AETERM))
  )

  # works with no `by`
  ard_single <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = AETERM,
    denominator = cards::ADSL,
    id = USUBJID,
    over_variables = TRUE
  )
  expect_silent(ard_single <- sort_ard_hierarchical(ard_single))
})

test_that("sort_ard_hierarchical() works when some variables not included in x", {
  ard_incl <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    include = c(SEX, AETERM),
    over_variables = TRUE
  )

  expect_equal(
    ard_incl |>
      sort_ard_hierarchical() |>
      dplyr::select(all_ard_groups(), all_ard_variables()),
    ard |>
      sort_ard_hierarchical() |>
      dplyr::filter(variable != "RACE") |>
      dplyr::select(all_ard_groups(), all_ard_variables()),
    ignore_attr = TRUE
  )
})

test_that("sort_ard_hierarchical() works when sorting using p instead of n", {
  ard <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    statistic = everything() ~ "p"
  )

  expect_silent(ard_p <- sort_ard_hierarchical(ard))

  ard <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    statistic = everything() ~ "p"
  )
})

test_that("sort_ard_hierarchical() works with overall data", {
  ard_overall <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    over_variables = TRUE,
    overall = TRUE
  )

  expect_silent(ard_overall <- sort_ard_hierarchical(ard_overall))

  expect_equal(
    ard_overall |>
      dplyr::filter(variable == "RACE") |>
      dplyr::select(all_ard_groups("levels"), all_ard_variables()) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    rep(
      c(
        "WHITE",
        "BLACK OR AFRICAN AMERICAN",
        "WHITE",
        "BLACK OR AFRICAN AMERICAN",
        "AMERICAN INDIAN OR ALASKA NATIVE"
      ),
      each = 4
    )
  )
  expect_equal(
    ard_overall |>
      dplyr::filter(variable == "AETERM") |>
      dplyr::select(all_ard_groups("levels"), all_ard_variables()) |>
      dplyr::distinct() |>
      dplyr::pull(variable_level) |>
      unlist(),
    rep(
      c(
        "APPLICATION SITE PRURITUS",
        "ERYTHEMA",
        "APPLICATION SITE ERYTHEMA",
        "DIARRHOEA",
        "APPLICATION SITE PRURITUS",
        "ERYTHEMA",
        "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
        "DIARRHOEA",
        "APPLICATION SITE PRURITUS",
        "APPLICATION SITE ERYTHEMA",
        "ERYTHEMA",
        "DIARRHOEA",
        "ATRIOVENTRICULAR BLOCK SECOND DEGREE",
        "APPLICATION SITE PRURITUS",
        "DIARRHOEA",
        "ERYTHEMA",
        "ERYTHEMA"
      ),
      each = 4
    )
  )
})

test_that("sort_ard_hierarchical() warning messaging works", {
  withr::local_options(width = 200)

  # invalid x input
  expect_snapshot(
    r <- sort_ard_hierarchical(ard_tabulate(
      ADSL,
      by = "ARM",
      variables = "AGEGR1"
    ))
  )

  # invalid sort input
  expect_snapshot(
    sort_ard_hierarchical(ard, sort = "no_sorting"),
    error = TRUE
  )

  # no n or p stat in ARD
  ard_no_np <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    statistic = everything() ~ "N"
  )

  expect_snapshot(
    sort_ard_hierarchical(ard_no_np),
    error = TRUE
  )

  # invalid `by_level` inputs
  expect_snapshot(
    sort_ard_hierarchical(ard, by_level = list(TRTA = "not-a-level")),
    error = TRUE
  )
  expect_snapshot(
    sort_ard_hierarchical(ard, by_level = list(not_a_by_var = "Placebo")),
    error = TRUE
  )
  expect_snapshot(
    sort_ard_hierarchical(ard, by_level = list("Placebo")),
    error = TRUE
  )
  expect_snapshot(
    sort_ard_hierarchical(ard, by_level = list(TRTA = c("Placebo", "Xanomeline Low Dose"))),
    error = TRUE
  )

  # `by_level` requires at least one `by` variable
  ard_no_by <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    denominator = cards::ADSL,
    id = USUBJID
  )
  expect_snapshot(
    sort_ard_hierarchical(ard_no_by, by_level = list(TRTA = "Placebo")),
    error = TRUE
  )
})

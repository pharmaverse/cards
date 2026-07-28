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

ADAE_subset2 <- cards::ADAE |>
  dplyr::filter(AEDECOD %in% unique(cards::ADAE$AEDECOD)[1:20])

ard_2 <- ard_stack_hierarchical(
  data = ADAE_subset2,
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  denominator = cards::ADSL,
  id = USUBJID
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


test_that("sort_ard_hierarchical(sort = list(AESOC ~ 'alphanumeric', AEDECOD ~ 'descending'), sort_level = 'Placebo') works", {
  expect_silent(ard_2 <- sort_ard_hierarchical(ard_2,
    sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"),
    sort_level = "Placebo"
  ))

  expect_equal(
    ard_2 |>
      dplyr::filter(
        group1 == "TRTA", group1_level == "Placebo",
        group2_level == "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS", stat_name == "n"
      ) |>
      dplyr::select(variable_level, stat) |>
      dplyr::distinct(variable_level, .keep_all = TRUE) |>
      dplyr::arrange(desc(as.numeric(stat))) |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "APPLICATION SITE PRURITUS",
      "APPLICATION SITE DERMATITIS",
      "APPLICATION SITE ERYTHEMA",
      "APPLICATION SITE IRRITATION",
      "APPLICATION SITE VESICLES",
      "FATIGUE"
    )
  )

  expect_equal(
    ard_2 |>
      dplyr::filter(
        group1 == "TRTA", group1_level == "Xanomeline Low Dose",
        group2_level == "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS", stat_name == "n"
      ) |>
      dplyr::select(variable_level, stat) |>
      dplyr::distinct(variable_level, .keep_all = TRUE) |>
      dplyr::arrange(desc(as.numeric(stat))) |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "APPLICATION SITE PRURITUS",
      "APPLICATION SITE ERYTHEMA",
      "APPLICATION SITE DERMATITIS",
      "APPLICATION SITE IRRITATION",
      "FATIGUE",
      "APPLICATION SITE VESICLES"
    )
  )

  expect_equal(
    ard_2 |>
      dplyr::filter(
        group1 == "TRTA", group1_level == "Xanomeline High Dose",
        group2_level == "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS", stat_name == "n"
      ) |>
      dplyr::select(variable_level, stat) |>
      dplyr::distinct(variable_level, .keep_all = TRUE) |>
      dplyr::arrange(desc(as.numeric(stat))) |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "APPLICATION SITE PRURITUS",
      "APPLICATION SITE ERYTHEMA",
      "APPLICATION SITE IRRITATION",
      "APPLICATION SITE DERMATITIS",
      "APPLICATION SITE VESICLES",
      "FATIGUE"
    )
  )
})


test_that("sort_ard_hierarchical(sort = AEDECOD ~ 'descending', sort_level = 'Placebo') works", {
  ard_3 <- ard_stack_hierarchical(
    data = cards::ADAE |> dplyr::filter(AEDECOD %in% unique(cards::ADAE$AEDECOD)[1:5]),
    variables = AEDECOD,
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID
  )

  expect_silent(ard_3 <- sort_ard_hierarchical(ard_3, sort = AEDECOD ~ "descending", sort_level = "Placebo"))

  expect_equal(
    ard_3 |>
      dplyr::filter(group1 == "TRTA", group1_level == "Placebo", stat_name == "n") |>
      dplyr::select(variable_level, stat) |>
      dplyr::distinct(variable_level, .keep_all = TRUE) |>
      dplyr::arrange(desc(as.numeric(stat))) |>
      dplyr::pull(variable_level) |>
      unlist(),
    c(
      "DIARRHOEA",
      "ERYTHEMA",
      "APPLICATION SITE PRURITUS",
      "APPLICATION SITE ERYTHEMA",
      "ATRIOVENTRICULAR BLOCK SECOND DEGREE"
    )
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
  ard <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    statistic = everything() ~ "N"
  )

  expect_snapshot(
    sort_ard_hierarchical(ard),
    error = TRUE
  )

  # invalid sort_level input
  expect_snapshot(
    sort_ard_hierarchical(ard_2, sort_level = "Placebo1"),
    error = TRUE
  )

  # sort_level should be a single character not a vector
  expect_snapshot(
    sort_ard_hierarchical(ard_2, sort_level = c("Placebo", "Xanomeline Low Dose")),
    error = TRUE
  )

  # no by variable specified - this should error.

  ard_no_by <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(SEX, RACE, AETERM),
    denominator = cards::ADSL,
    id = USUBJID,
    statistic = everything() ~ "N"
  )

  expect_snapshot(
    sort_ard_hierarchical(ard_no_by, sort_level = "F"),
    error = TRUE
  )


  # if more than two variables in the by statement then sort_level has no useful meaning.
  ard_by_more <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(AESOC, AEDECOD),
    by = c(TRTA, SEX),
    denominator = cards::ADSL,
    id = USUBJID,
    statistic = everything() ~ "N"
  )


  expect_snapshot(
    sort_ard_hierarchical(ard_by_more, sort_level = "Placebo"),
    error = TRUE
  )
})

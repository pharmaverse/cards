skip_on_cran()

ADAE_subset <- cards::ADAE |>
  dplyr::filter(AESOC %in% c("CARDIAC DISORDERS", "EYE DISORDERS"))

# two CARDIAC DISORDERS AEs, each reported in all three arms: EYE DISORDERS and
# the other CARDIAC DISORDERS AEs are unobserved
ADAE_observed <- ADAE_subset |>
  dplyr::filter(AEDECOD %in% c("MYOCARDIAL INFARCTION", "SINUS BRADYCARDIA"))

ard <- ard_stack_hierarchical(
  data = ADAE_observed,
  variables = c(AESOC, AEDECOD),
  by = TRTA,
  denominator = cards::ADSL,
  id = USUBJID
)

# the 27 SOC/AE combinations of the two SOCs
levels_all <- dplyr::distinct(ADAE_subset, AESOC, AEDECOD)

# "SOC / AE" of each AE row with the `n` statistic, so once per arm
ae_rows <- function(x) {
  x <- x |>
    dplyr::filter(variable == "AEDECOD", stat_name == "n") |>
    unlist_ard_columns()
  sort(paste(x$group2_level, x$variable_level, sep = " / "))
}
expected_ae_rows <- sort(rep(paste(levels_all$AESOC, levels_all$AEDECOD, sep = " / "), times = 3L))

test_that("add_hierarchical_zero_rows() works", {
  expect_silent(ard_full <- add_hierarchical_zero_rows(ard, levels = levels_all))

  # each SOC/AE combination has a row per arm, under its SOC
  expect_equal(ae_rows(ard_full), expected_ae_rows)

  # every added level, SOC or AE, has n = 0, the N of its arm, and p = 0
  ard_added <- dplyr::filter(
    ard_full,
    variable %in% c("AESOC", "AEDECOD"),
    !variable_level %in% list("CARDIAC DISORDERS", "MYOCARDIAL INFARCTION", "SINUS BRADYCARDIA")
  )
  expect_equal(nrow(ard_added), 26L * 3L * 3L) # 1 SOC and 25 AEs, in 3 arms, with n, N and p
  expect_identical(unique(ard_added$stat[ard_added$stat_name == "n"]), list(0L))
  expect_identical(unique(ard_added$stat[ard_added$stat_name == "p"]), list(0))
  expect_equal(
    ard_added |> dplyr::filter(stat_name == "N") |> dplyr::distinct(group1_level, stat),
    ard |> dplyr::filter(variable == "AESOC", stat_name == "N") |> dplyr::distinct(group1_level, stat)
  )

  # the rows of `x` are unchanged: removing the zero-count levels gives back `x`
  expect_equal(filter_ard_hierarchical(ard_full, sum(n) > 0), ard)

  # the result is sorted like the output of `ard_stack_hierarchical()`
  expect_equal(sort_ard_hierarchical(ard_full, sort = "alphanumeric"), ard_full)

  # the column order of `levels` does not matter
  expect_equal(
    add_hierarchical_zero_rows(ard, levels = levels_all[c("AEDECOD", "AESOC")]),
    ard_full
  )
})

test_that("add_hierarchical_zero_rows() adds the top level only", {
  ard_soc <- add_hierarchical_zero_rows(ard, levels = dplyr::distinct(ADAE_subset, AESOC))

  # EYE DISORDERS is added, a row per arm and statistic, with no AE rows under it
  expect_equal(nrow(ard_soc), nrow(ard) + 9L)
  expect_true(any(ard_soc$variable_level %in% list("EYE DISORDERS")))
  expect_equal(ae_rows(ard_soc), ae_rows(ard))
})

test_that("add_hierarchical_zero_rows() returns `x` unchanged when no level is missing", {
  expect_identical(
    add_hierarchical_zero_rows(ard, levels = dplyr::distinct(ADAE_observed, AESOC, AEDECOD)),
    ard
  )
})

test_that("add_hierarchical_zero_rows() works with `overall`, `over_variables`, `attributes` and `total_n`", {
  ard_opts <- ard_stack_hierarchical(
    data = ADAE_observed,
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    overall = TRUE,
    over_variables = TRUE,
    attributes = TRUE,
    total_n = TRUE
  )
  ard_full <- add_hierarchical_zero_rows(ard_opts, levels = levels_all)

  # an added AE has a row per arm and an overall row, all under its SOC
  expect_equal(
    ard_full |>
      dplyr::filter(variable == "AEDECOD", variable_level %in% list("GLAUCOMA"), stat_name == "n") |>
      dplyr::select(all_ard_groups()) |>
      unlist_ard_columns() |>
      as.data.frame(),
    data.frame(
      group1 = c("TRTA", "TRTA", "TRTA", "AESOC"),
      group1_level = c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose", "EYE DISORDERS"),
      group2 = c("AESOC", "AESOC", "AESOC", NA),
      group2_level = c("EYE DISORDERS", "EYE DISORDERS", "EYE DISORDERS", NA)
    ),
    ignore_attr = "args"
  )
  # with the N of each arm, and of all subjects in the overall row
  expect_equal(
    ard_full |>
      dplyr::filter(variable == "AEDECOD", variable_level %in% list("GLAUCOMA"), stat_name == "N") |>
      dplyr::pull(stat) |>
      unlist(),
    unname(c(table(cards::ADSL$TRTA), nrow(cards::ADSL)))
  )

  # the rows that do not depend on the levels are unchanged
  other_rows <- \(x) dplyr::filter(x, context %in% c("attributes", "total_n") | variable == "..ard_hierarchical_overall..")
  expect_equal(other_rows(ard_full), other_rows(ard_opts))
})

test_that("add_hierarchical_zero_rows() works with `include`", {
  ard_ae <- ard_stack_hierarchical(
    data = ADAE_observed,
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID,
    include = AEDECOD
  )
  ard_full <- add_hierarchical_zero_rows(ard_ae, levels = levels_all)

  # AE rows are added under their SOC, and no SOC summary rows are created
  expect_equal(ae_rows(ard_full), expected_ae_rows)
  expect_false("AESOC" %in% ard_full$variable)
})

test_that("add_hierarchical_zero_rows() works with ard_stack_hierarchical_count()", {
  ard_count <- ard_stack_hierarchical_count(
    data = ADAE_observed,
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = cards::ADSL
  )
  ard_full <- add_hierarchical_zero_rows(ard_count, levels = levels_all)

  expect_equal(ae_rows(ard_full), expected_ae_rows)

  # an added level only has the `n` statistic, set to 0
  ard_eye <- dplyr::filter(ard_full, variable == "AESOC", variable_level %in% list("EYE DISORDERS"))
  expect_identical(unique(ard_eye$stat_name), "n")
  expect_identical(unique(ard_eye$stat), list(0L))
})

test_that("add_hierarchical_zero_rows() works with three hierarchy variables", {
  ard_sev <- ard_stack_hierarchical(
    data = ADAE_subset,
    variables = c(AESOC, AEDECOD, AESEV),
    by = TRTA,
    denominator = cards::ADSL,
    id = USUBJID
  )
  # no severe GLAUCOMA is reported
  ard_full <- add_hierarchical_zero_rows(
    ard_sev,
    levels = data.frame(AESOC = "EYE DISORDERS", AEDECOD = "GLAUCOMA", AESEV = "SEVERE")
  )

  # only the severity is added, a row per arm and statistic, under its SOC and AE
  expect_equal(nrow(ard_full), nrow(ard_sev) + 9L)
  ard_severe <- dplyr::filter(
    ard_full,
    variable == "AESEV", variable_level %in% list("SEVERE"), group3_level %in% list("GLAUCOMA")
  )
  expect_equal(unique(unlist(ard_severe$group2_level)), "EYE DISORDERS")
  expect_identical(unique(ard_severe$stat[ard_severe$stat_name == "n"]), list(0L))
})

test_that("add_hierarchical_zero_rows() keeps factor levels as factors", {
  # the factor levels are the observed ones only, so the added levels are new
  ard_fct <- ADAE_observed |>
    dplyr::mutate(AESOC = factor(AESOC), AEDECOD = factor(AEDECOD)) |>
    ard_stack_hierarchical(
      variables = c(AESOC, AEDECOD),
      by = TRTA,
      denominator = cards::ADSL,
      id = USUBJID
    )
  ard_full <- add_hierarchical_zero_rows(ard_fct, levels = levels_all)

  # added levels are factors too, so the level columns still unlist to factors
  expect_s3_class(unlist(ard_full$variable_level[ard_full$variable == "AESOC"]), "factor")
  expect_s3_class(unlist(ard_full$group2_level[ard_full$variable == "AEDECOD"]), "factor")
  expect_equal(ae_rows(ard_full), expected_ae_rows)
})

test_that("add_hierarchical_zero_rows() keeps `p` as NaN in an empty `by` group", {
  # "Arm Z" has no subjects, so N = 0 and p = 0 / 0
  arm_levels <- c(sort(unique(cards::ADSL$TRTA)), "Arm Z")
  ard_z <- ard_stack_hierarchical(
    data = dplyr::mutate(ADAE_observed, TRTA = factor(TRTA, levels = arm_levels)),
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = dplyr::mutate(cards::ADSL, TRTA = factor(TRTA, levels = arm_levels)),
    id = USUBJID
  )
  ard_full <- add_hierarchical_zero_rows(ard_z, levels = levels_all)

  ard_eye_p <- dplyr::filter(
    ard_full,
    variable == "AESOC", variable_level %in% list("EYE DISORDERS"), stat_name == "p"
  )
  expect_equal(unlist(ard_eye_p$stat), c(0, 0, 0, NaN))
})

test_that("add_hierarchical_zero_rows() formats the added levels of a formatted ARD", {
  ard_full <- add_hierarchical_zero_rows(apply_fmt_fun(ard), levels = levels_all)

  ard_eye <- dplyr::filter(ard_full, variable == "AESOC", variable_level %in% list("EYE DISORDERS"))
  expect_equal(unlist(ard_eye$stat_fmt[ard_eye$stat_name %in% c("n", "p")]), rep(c("0", "0.0"), times = 3L))
})

test_that("add_hierarchical_zero_rows() errors with incorrect inputs", {
  # `x` is not a stacked hierarchical ARD
  expect_snapshot(
    add_hierarchical_zero_rows(ard_tabulate(cards::ADSL, variables = AGEGR1), levels = levels_all),
    error = TRUE
  )

  # `levels` is not a data frame
  expect_snapshot(
    add_hierarchical_zero_rows(ard, levels = "EYE DISORDERS"),
    error = TRUE
  )

  # a column of `levels` is not a hierarchy variable
  expect_snapshot(
    add_hierarchical_zero_rows(ard, levels = data.frame(TRTA = "Placebo")),
    error = TRUE
  )

  # the columns of `levels` do not start from the top of the hierarchy
  expect_snapshot(
    add_hierarchical_zero_rows(ard, levels = dplyr::distinct(levels_all, AEDECOD)),
    error = TRUE
  )

  # `levels` has missing values
  expect_snapshot(
    add_hierarchical_zero_rows(ard, levels = data.frame(AESOC = NA_character_)),
    error = TRUE
  )

  # a level of the wrong type
  expect_snapshot(
    add_hierarchical_zero_rows(ard, levels = data.frame(AESOC = 1)),
    error = TRUE
  )

  # a statistic with no known value for an unobserved level
  ard_cum <- ard
  ard_cum$stat_name[ard_cum$variable == "AESOC" & ard_cum$stat_name == "N"] <- "n_cum"
  expect_snapshot(
    add_hierarchical_zero_rows(ard_cum, levels = levels_all),
    error = TRUE
  )

  # `x` has no rows to copy for a variable
  expect_snapshot(
    add_hierarchical_zero_rows(dplyr::filter(ard, variable != "AEDECOD"), levels = levels_all),
    error = TRUE
  )
})

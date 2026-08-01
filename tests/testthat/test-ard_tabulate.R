test_that("ard_tabulate() univariate", {
  expect_error(
    ard_cat_uni <- ard_tabulate(mtcars, variables = "am"),
    NA
  )
  expect_snapshot(class(ard_cat_uni))

  expect_equal(
    ard_cat_uni |>
      dplyr::filter(stat_name %in% "n") |>
      dplyr::pull(stat) |>
      as.integer(),
    table(mtcars$am) |> as.integer()
  )

  expect_equal(
    ard_cat_uni |>
      dplyr::filter(stat_name %in% "p") |>
      dplyr::pull(stat) |>
      as.numeric(),
    table(mtcars$am) |> prop.table() |> as.numeric()
  )

  expect_equal(
    dplyr::filter(ard_cat_uni, stat_name %in% "N")$stat[[1]],
    sum(!is.na(mtcars$am))
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = starts_with("xxxxx")
    ),
    dplyr::tibble() |> as_card(check = FALSE)
  )

  # works for ordered factors
  expect_equal(
    ard_tabulate(
      mtcars |> dplyr::mutate(cyl = factor(cyl, ordered = TRUE)),
      variables = cyl
    ) |>
      dplyr::select(stat_name, stat_label, stat),
    ard_tabulate(
      mtcars |> dplyr::mutate(cyl = factor(cyl, ordered = FALSE)),
      variables = cyl
    ) |>
      dplyr::select(stat_name, stat_label, stat)
  )

  expect_equal(
    ard_tabulate(
      mtcars |> dplyr::mutate(cyl = factor(cyl, ordered = TRUE)),
      by = vs,
      variables = cyl
    ) |>
      dplyr::select(stat_name, stat_label, stat),
    ard_tabulate(
      mtcars |> dplyr::mutate(cyl = factor(cyl, ordered = FALSE)),
      by = vs,
      variables = cyl
    ) |>
      dplyr::select(stat_name, stat_label, stat)
  )
})

test_that("ard_tabulate() univariate & specified denomiator", {
  expect_error(
    ard_cat_new_denom <-
      ard_tabulate(
        mtcars,
        variables = "am",
        denominator = list(mtcars) |> rep_len(100) |> dplyr::bind_rows()
      ),
    NA
  )
  expect_snapshot(class(ard_cat_new_denom))

  expect_equal(
    ard_cat_new_denom |>
      dplyr::filter(stat_name %in% "n") |>
      dplyr::pull(stat) |>
      as.integer(),
    table(mtcars$am) |> as.integer()
  )

  expect_equal(
    ard_cat_new_denom |>
      dplyr::filter(stat_name %in% "p") |>
      dplyr::pull(stat) |>
      as.numeric(),
    table(mtcars$am) |> prop.table() |> as.numeric() %>% `/`(100) # styler: off
  )

  expect_equal(
    dplyr::filter(ard_cat_new_denom, stat_name %in% "N")$stat[[1]],
    sum(!is.na(mtcars$am)) * 100L
  )
})

test_that("ard_tabulate(fmt_fun) argument works", {
  ard_tabulate(
    mtcars,
    variables = "am",
    fmt_fun =
      list(
        am =
          list(
            p = function(x) round5(x * 100, digits = 3) |> as.character(),
            N = function(x) format(round5(x, digits = 2), nsmall = 2),
            N_obs = function(x) format(round5(x, digits = 2), nsmall = 2)
          )
      )
  ) |>
    apply_fmt_fun() |>
    dplyr::select(variable, variable_level, stat_name, stat, stat_fmt) |>
    as.data.frame() |>
    expect_snapshot()

  ard_tabulate(
    mtcars,
    variables = c("am", "vs"),
    fmt_fun = list(
      am = list(p = function(x) round5(x * 100, digits = 3)),
      vs = list(p = function(x) round5(x * 100, digits = 1))
    )
  ) |>
    apply_fmt_fun() |>
    dplyr::select(variable, variable_level, stat_name, stat, stat_fmt) |>
    as.data.frame() |>
    expect_snapshot()
})


test_that("ard_tabulate() with strata and by arguments", {
  ADAE_small <-
    ADAE |>
    dplyr::filter(AESOC %in% c("EYE DISORDERS", "INVESTIGATIONS")) |>
    dplyr::slice_head(by = AESOC, n = 3)

  expect_error(
    card_ae_strata <-
      ard_tabulate(
        data = ADAE_small,
        strata = c(AESOC, AELLT),
        by = TRTA,
        variables = AESEV,
        denominator = ADSL
      ),
    NA
  )

  # check that all combinations of AESOC and AELLT are NOT present
  expect_equal(
    card_ae_strata |>
      dplyr::filter(
        group2_level %in% "EYE DISORDERS",
        group3_level %in% "NASAL MUCOSA BIOPSY"
      ) |>
      nrow(),
    0L
  )

  # check the rate calculations in the first SOC/LLT combination
  expect_equal(
    card_ae_strata |>
      dplyr::filter(
        group1_level %in% "Placebo",
        group2_level %in% "EYE DISORDERS",
        group3_level %in% "EYES SWOLLEN",
        variable_level %in% "MILD",
        stat_name %in% "n"
      ) |>
      dplyr::pull(stat) |>
      getElement(1),
    ADAE_small |>
      dplyr::filter(
        AESOC %in% "EYE DISORDERS",
        AELLT %in% "EYES SWOLLEN",
        TRTA %in% "Placebo",
        AESEV %in% "MILD"
      ) |>
      nrow()
  )

  expect_equal(
    card_ae_strata |>
      dplyr::filter(
        group1_level %in% "Placebo",
        group2_level %in% "EYE DISORDERS",
        group3_level %in% "EYES SWOLLEN",
        variable_level %in% "MILD",
        stat_name %in% "p"
      ) |>
      dplyr::pull(stat) |>
      getElement(1),
    (ADAE_small |>
      dplyr::filter(
        AESOC %in% "EYE DISORDERS",
        AELLT %in% "EYES SWOLLEN",
        TRTA %in% "Placebo",
        AESEV %in% "MILD"
      ) |>
      nrow()) /
      (ADSL |> dplyr::filter(ARM %in% "Placebo") |> nrow())
  )

  expect_equal(
    card_ae_strata |>
      dplyr::filter(
        group1_level %in% "Placebo",
        stat_name %in% "N"
      ) |>
      dplyr::pull(stat) |>
      getElement(1),
    ADSL |> dplyr::filter(ARM %in% "Placebo") |> nrow()
  )

  # check for messaging about missing by/strata combos in denominator arg
  expect_snapshot(
    error = TRUE,
    ard_tabulate(
      ADSL,
      by = "ARM",
      variables = "AGEGR1",
      denominator = ADSL |> dplyr::filter(ARM %in% "Placebo")
    )
  )

  # addressing a sort edge case reported here: https://github.com/ddsjoberg/gtsummary/issues/1889
  expect_silent(
    ard_sort_test <-
      iris |>
      dplyr::mutate(
        trt = rep_len(
          c("Bladder + RP LN", "Bladder + Renal Fossa"),
          length.out = dplyr::n()
        )
      ) |>
      ard_tabulate(variables = trt, by = Species)
  )
  expect_s3_class(ard_sort_test$group1_level[[1]], "factor")
})

test_that("ard_tabulate(stat_label) argument works", {
  # formula
  expect_snapshot(
    ard_tabulate(
      data = ADSL,
      by = "ARM",
      variables = c("AGEGR1", "SEX"),
      stat_label = everything() ~ list(c("n", "p") ~ "n (pct)")
    ) |>
      as.data.frame() |>
      dplyr::filter(stat_name %in% c("n", "p")) |>
      dplyr::select(stat_name, stat_label) |>
      unique()
  )

  # list
  expect_snapshot(
    ard_tabulate(
      data = ADSL,
      by = "ARM",
      variables = c("AGEGR1", "SEX"),
      stat_label = everything() ~ list(n = "num", p = "pct")
    ) |>
      as.data.frame() |>
      dplyr::filter(stat_name %in% c("n", "p")) |>
      dplyr::select(stat_name, stat_label) |>
      unique()
  )

  # variable-specific
  expect_snapshot(
    ard_tabulate(
      data = ADSL,
      by = "ARM",
      variables = c("AGEGR1", "SEX"),
      stat_label = AGEGR1 ~ list(c("n", "p") ~ "n (pct)")
    ) |>
      as.data.frame() |>
      dplyr::filter(stat_name %in% c("n", "p")) |>
      dplyr::select(variable, stat_name, stat_label) |>
      unique()
  )
})


test_that("ard_tabulate(denominator='cell') works", {
  expect_error(
    ard_crosstab <- ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      by = "ARM",
      denominator = "cell"
    ),
    NA
  )

  mtrx_conts <- with(ADSL, table(AGEGR1, ARM)) |> unclass()
  mtrx_percs <- mtrx_conts / sum(mtrx_conts)

  expect_equal(
    ard_crosstab |>
      dplyr::filter(
        group1_level %in% "Placebo",
        variable_level %in% "<65",
        stat_name %in% "n"
      ) |>
      dplyr::pull(stat) |>
      getElement(1),
    mtrx_conts["<65", "Placebo"]
  )

  expect_equal(
    ard_crosstab |>
      dplyr::filter(
        group1_level %in% "Placebo",
        variable_level %in% "<65",
        stat_name %in% "p"
      ) |>
      dplyr::pull(stat) |>
      getElement(1),
    mtrx_percs["<65", "Placebo"]
  )

  # works with an all missing variable
  df_missing <-
    dplyr::tibble(
      all_na_lgl = c(NA, NA),
      all_na_fct = factor(all_na_lgl, levels = letters[1:2]),
      letters = letters[1:2]
    )
  expect_equal(
    ard_tabulate(
      data = df_missing,
      variables = c(all_na_lgl, all_na_fct),
      statistic = ~ c("n", "N"),
      denominator = "cell"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 8L)
  )

  expect_equal(
    ard_tabulate(
      data = df_missing,
      variables = c(all_na_lgl, all_na_fct),
      by = letters,
      statistic = ~ c("n", "N"),
      denominator = "cell"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 16L)
  )
})

test_that("ard_tabulate(denominator='row') works", {
  withr::local_options(list(width = 120))
  expect_error(
    ard_crosstab_row <- ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      by = "ARM",
      denominator = "row"
    ),
    NA
  )

  xtab_count <- with(ADSL, table(AGEGR1, ARM))
  xtab_percent <- proportions(xtab_count, margin = 1)

  expect_equal(
    xtab_count[
      rownames(xtab_count) %in% "<65",
      colnames(xtab_count) %in% "Placebo"
    ],
    ard_crosstab_row |>
      dplyr::filter(
        variable_level %in% "<65",
        group1_level %in% "Placebo",
        stat_name %in% "n"
      ) |>
      dplyr::pull(stat) |>
      unlist(),
    ignore_attr = TRUE
  )
  expect_equal(
    xtab_percent[
      rownames(xtab_percent) %in% "<65",
      colnames(xtab_percent) %in% "Placebo"
    ],
    ard_crosstab_row |>
      dplyr::filter(
        variable_level %in% "<65",
        group1_level %in% "Placebo",
        stat_name %in% "p"
      ) |>
      dplyr::pull(stat) |>
      unlist(),
    ignore_attr = TRUE
  )

  expect_equal(
    xtab_count[
      rownames(xtab_count) %in% ">80",
      colnames(xtab_count) %in% "Xanomeline Low Dose"
    ],
    ard_crosstab_row |>
      dplyr::filter(
        variable_level %in% ">80",
        group1_level %in% "Xanomeline Low Dose",
        stat_name %in% "n"
      ) |>
      dplyr::pull(stat) |>
      unlist(),
    ignore_attr = TRUE
  )
  expect_equal(
    xtab_percent[
      rownames(xtab_percent) %in% ">80",
      colnames(xtab_percent) %in% "Xanomeline Low Dose"
    ],
    ard_crosstab_row |>
      dplyr::filter(
        variable_level %in% ">80",
        group1_level %in% "Xanomeline Low Dose",
        stat_name %in% "p"
      ) |>
      dplyr::pull(stat) |>
      unlist(),
    ignore_attr = TRUE
  )

  # testing the arguments work properly
  expect_error(
    ard_with_args <-
      ard_tabulate(
        ADSL,
        variables = "AGEGR1",
        by = "ARM",
        denominator = "row",
        statistic = list(AGEGR1 = c("n", "N")),
        fmt_fun = list(AGEGR1 = list("n" = 2))
      ),
    NA
  )

  expect_snapshot(
    ard_with_args |>
      apply_fmt_fun() |>
      dplyr::select(-fmt_fun, -warning, -error) |>
      as.data.frame()
  )

  # works with an all missing variable
  df_missing <- dplyr::tibble(all_na_lgl = c(NA, NA), letters = letters[1:2])
  expect_equal(
    ard_tabulate(
      data = df_missing,
      variable = all_na_lgl,
      statistic = ~ c("n", "N"),
      denominator = "row"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 4L)
  )

  expect_equal(
    ard_tabulate(
      data = df_missing,
      variable = all_na_lgl,
      by = letters,
      statistic = ~ c("n", "N"),
      denominator = "row"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 8L)
  )
})

test_that("ard_tabulate(denominator='column') works", {
  expect_equal(
    ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      by = "ARM",
      denominator = "column"
    ) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), stat_name, stat),
    ard_tabulate(ADSL, variables = "AGEGR1", by = "ARM") |>
      dplyr::select(all_ard_groups(), all_ard_variables(), stat_name, stat)
  )

  # works with an all missing variable
  df_missing <- dplyr::tibble(all_na_lgl = c(NA, NA), letters = letters[1:2])
  expect_equal(
    ard_tabulate(
      data = df_missing,
      variable = all_na_lgl,
      statistic = ~ c("n", "N"),
      denominator = "column"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 4L)
  )

  expect_equal(
    ard_tabulate(
      data = df_missing,
      variable = all_na_lgl,
      by = letters,
      statistic = ~ c("n", "N"),
      denominator = "column"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 8L)
  )

  # works with an all missing variable
  df_missing <- dplyr::tibble(all_na_lgl = c(NA, NA), letters = letters[1:2])
  expect_equal(
    ard_tabulate(
      data = df_missing,
      variable = all_na_lgl,
      statistic = ~ c("n", "N"),
      denominator = "column"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 4L)
  )

  expect_equal(
    ard_tabulate(
      data = df_missing,
      variable = all_na_lgl,
      by = letters,
      statistic = ~ c("n", "N"),
      denominator = "column"
    ) |>
      dplyr::pull(stat) |>
      unlist(),
    rep_len(0L, length.out = 8L)
  )
})

test_that("ard_tabulate(denominator=integer()) works", {
  expect_equal(
    ard_tabulate(ADSL, variables = AGEGR1, denominator = 1000) |>
      get_ard_statistics(variable_level %in% "<65", .attributes = NULL),
    list(n = 33, N = 1000, p = 33 / 1000)
  )
})

test_that("ard_tabulate(denominator=<data frame with counts>) works", {
  expect_snapshot(
    error = TRUE,
    ard_tabulate(
      ADSL,
      by = ARM,
      variables = AGEGR1,
      denominator = data.frame(
        ARM = c(
          "Placebo",
          "Placebo",
          "Xanomeline High Dose",
          "Xanomeline Low Dose"
        ),
        ...ard_N... = c(86, 86, 84, 84)
      )
    )
  )

  expect_snapshot(
    error = TRUE,
    ard_tabulate(
      ADSL,
      by = ARM,
      variables = AGEGR1,
      denominator = data.frame(ARM = "Placebo", ...ard_N... = 86)
    )
  )

  expect_equal(
    ard_tabulate(
      ADSL,
      by = ARM,
      variables = AGEGR1,
      denominator = data.frame(
        ARM = c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"),
        ...ard_N... = c(86, 84, 84)
      )
    ) |>
      dplyr::select(-fmt_fun),
    ard_tabulate(
      ADSL,
      by = ARM,
      variables = AGEGR1
    ) |>
      dplyr::select(-fmt_fun)
  )
})

test_that("ard_tabulate(denominator=<data frame without counts>) works", {
  expect_equal(
    ADSL |>
      dplyr::mutate(AGEGR1 = NA) |>
      ard_tabulate(
        variables = AGEGR1,
        statistic = ~ c("n", "p"),
        denominator = rep_len(list(ADSL), 10L) |> dplyr::bind_rows()
      ) |>
      dplyr::pull(stat) |>
      unlist() |>
      unique(),
    0L
  )

  expect_equal(
    ADSL |>
      dplyr::mutate(AGEGR1 = NA) |>
      ard_tabulate(
        variables = AGEGR1,
        by = ARM,
        statistic = ~ c("n", "p"),
        denominator = rep_len(list(ADSL), 10L) |> dplyr::bind_rows()
      ) |>
      dplyr::pull(stat) |>
      unlist() |>
      unique(),
    0L
  )
})

test_that("ard_tabulate() and ARD column names", {
  ard_colnames <- c(
    "group1", "group1_level", "variable", "variable_level",
    "context", "stat_name", "stat_label", "stat",
    "fmt_fun", "warning", "error"
  )

  # no errors when these variables are the summary vars
  expect_error(
    {
      lapply(
        ard_colnames,
        function(var) {
          df <- mtcars[c("am", "cyl")]
          names(df) <- c("am", var)
          ard_tabulate(
            data = df,
            by = "am",
            variables = all_of(var)
          )
        }
      )
    },
    NA
  )

  # no errors when these vars are the by var
  expect_error(
    {
      lapply(
        ard_colnames,
        function(byvar) {
          df <- mtcars[c("am", "cyl")]
          names(df) <- c(byvar, "cyl")
          ard_summary(
            data = df,
            by = all_of(byvar),
            variables = "cyl"
          )
        }
      )
    },
    NA
  )
})

test_that("ard_tabulate() with grouped data works", {
  expect_equal(
    ADSL |>
      dplyr::group_by(ARM) |>
      ard_tabulate(variables = AGEGR1),
    ard_tabulate(data = ADSL, by = "ARM", variables = "AGEGR1")
  )
})


test_that("ard_tabulate() and all NA columns", {
  expect_snapshot(
    error = TRUE,
    ADSL |>
      dplyr::mutate(AGEGR1 = NA_character_) |>
      ard_tabulate(variables = AGEGR1)
  )
})

test_that("ard_tabulate() can handle non-syntactic column names", {
  expect_equal(
    ADSL |>
      dplyr::mutate(`Age Group` = AGEGR1) |>
      ard_tabulate(variables = `Age Group`) |>
      dplyr::select(stat),
    ADSL |>
      ard_tabulate(variables = AGEGR1) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ADSL |>
      dplyr::mutate(`Age Group` = AGEGR1) |>
      ard_tabulate(variables = "Age Group") |>
      dplyr::select(stat, error),
    ADSL |>
      ard_tabulate(variables = AGEGR1) |>
      dplyr::select(stat, error),
    ignore_attr = TRUE
  )

  expect_equal(
    ADSL |>
      dplyr::mutate(`Arm Var` = ARM, `Age Group` = AGEGR1) |>
      ard_tabulate(by = `Arm Var`, variables = "Age Group") |>
      dplyr::select(stat, error),
    ADSL |>
      ard_tabulate(by = ARM, variables = AGEGR1) |>
      dplyr::select(stat, error),
    ignore_attr = TRUE
  )

  expect_equal(
    ADSL |>
      dplyr::mutate(`Arm Var` = ARM, `Age Group` = AGEGR1) |>
      ard_tabulate(strata = "Arm Var", variables = `Age Group`) |>
      dplyr::select(stat, error),
    ADSL |>
      ard_tabulate(strata = ARM, variables = AGEGR1) |>
      dplyr::select(stat, error),
    ignore_attr = TRUE
  )
})

test_that("ard_tabulate(strata) returns results in proper order", {
  expect_equal(
    ard_tabulate(
      ADAE |>
        dplyr::arrange(AESEV != "SEVERE") |> # put SEVERE at the top
        dplyr::mutate(
          AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE"))
        ) |>
        dplyr::mutate(ANY_AE = 1L),
      by = TRTA,
      strata = AESEV,
      variables = ANY_AE,
      denominator = ADSL
    ) |>
      dplyr::select(group2_level) |>
      unlist() |>
      unique() |>
      as.character(),
    c("MILD", "MODERATE", "SEVERE")
  )
})

test_that("ard_tabulate(by) messages about protected names", {
  mtcars2 <- mtcars |>
    dplyr::mutate(
      variable = am,
      variable_level = cyl,
      by = am,
      by_level = cyl
    )

  expect_snapshot(
    error = TRUE,
    ard_tabulate(mtcars2, by = variable, variables = gear)
  )

  expect_error(
    ard_tabulate(mtcars2, by = variable_level, variables = gear),
    'The `by` argument cannot include variables named "variable" and "variable_level".'
  )
})

# - test if function parameters can be used as variable names without error
test_that("ard_tabulate() works when using generic names ", {
  # rename some variables
  mtcars2 <- mtcars %>%
    dplyr::rename(
      "variable" = am,
      "variable_level" = cyl,
      "by" = disp,
      "group1_level" = gear
    )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, cyl),
      by = disp,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(variable, variable_level),
      by = by,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(cyl, am),
      by = gear,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(variable_level, variable),
      by = group1_level,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(gear, am),
      by = disp,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(group1_level, variable),
      by = by,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  # rename vars
  mtcars2 <- mtcars %>%
    dplyr::rename("N" = am, "p" = cyl, "name" = disp, "group1_level" = gear)

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, cyl),
      by = disp,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(N, p),
      by = name,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(disp, gear),
      by = am,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(name, group1_level),
      by = N,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, disp),
      by = gear,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(N, name),
      by = group1_level,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, disp),
      by = cyl,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(N, name),
      by = p,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  # rename vars
  mtcars2 <- mtcars %>%
    dplyr::rename(
      "n" = am,
      "mean" = cyl,
      "p.std.error" = disp,
      "n_unweighted" = gear
    )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(gear, cyl),
      by = disp,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(n_unweighted, mean),
      by = p.std.error,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(gear, cyl),
      by = am,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(n_unweighted, mean),
      by = n,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, disp),
      by = cyl,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(n, p.std.error),
      by = mean,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, disp),
      by = gear,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(n, p.std.error),
      by = n_unweighted,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  # rename vars
  mtcars2 <- mtcars %>%
    dplyr::rename(
      "N_unweighted" = am,
      "p_unweighted" = cyl,
      "column" = disp,
      "row" = gear
    )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, cyl),
      by = disp,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(N_unweighted, p_unweighted),
      by = column,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(disp, gear),
      by = am,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(column, row),
      by = N_unweighted,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, disp),
      by = cyl,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(N_unweighted, column),
      by = p_unweighted,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )

  expect_equal(
    ard_tabulate(
      mtcars,
      variables = c(am, disp),
      by = gear,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ard_tabulate(
      mtcars2,
      variables = c(N_unweighted, column),
      by = row,
      denominator = "row"
    ) |>
      dplyr::select(stat),
    ignore_attr = TRUE
  )
})

test_that("ard_tabulate(by) messages about protected names", {
  mtcars2 <- mtcars %>%
    dplyr::rename(
      "variable" = am,
      "variable_level" = cyl,
      "by" = disp,
      "group1_level" = gear
    )

  expect_snapshot(
    error = TRUE,
    ard_tabulate(mtcars2, by = variable, variables = by)
  )

  expect_error(
    ard_tabulate(mtcars2, by = variable_level, variables = by),
    'The `by` argument cannot include variables named "variable" and "variable_level".'
  )
})


test_that("ard_tabulate() follows ard structure", {
  expect_silent(
    ard_tabulate(mtcars, variables = "am") |>
      check_ard_structure(method = FALSE)
  )
})

test_that("ard_tabulate() with hms times", {
  # originally reported in https://github.com/ddsjoberg/gtsummary/issues/1893
  skip_if_pkg_not_installed("hms")
  withr::local_package("hms")

  ADSL2 <-
    ADSL |>
    dplyr::mutate(time_hms = hms(seconds = 15))
  expect_silent(
    ard <- ard_tabulate(ADSL2, by = ARM, variables = time_hms)
  )
  expect_equal(
    ard$stat,
    ard_tabulate(
      ADSL2 |> dplyr::mutate(time_hms = as.numeric(time_hms)),
      by = ARM,
      variables = time_hms
    )$stat
  )
})

test_that("ard_tabulate() errors with incomplete factor columns", {
  # Check error when factors have no levels
  expect_snapshot(
    error = TRUE,
    mtcars |>
      dplyr::mutate(am = factor(am, levels = character(0))) |>
      ard_tabulate(variables = am)
  )

  # Check error when factor has NA level
  expect_snapshot(
    error = TRUE,
    mtcars |>
      dplyr::mutate(am = factor(am, levels = c(0, 1, NA), exclude = NULL)) |>
      ard_tabulate(variables = am)
  )
})

test_that("ard_tabulate(denominator='column') with cumulative counts", {
  # check cumulative stats work without `by/strata`
  expect_silent(
    ard <-
      ard_tabulate(
        ADSL,
        variables = "AGEGR1",
        statistic = everything() ~ c("n", "p", "n_cum", "p_cum")
      )
  )
  # test the final cum n matches the nrow()
  expect_equal(
    ard |>
      dplyr::filter(
        stat_name == "n_cum",
        variable_level %in% dplyr::last(.unique_and_sorted(ADSL$AGEGR1))
      ) |>
      dplyr::pull(stat) |>
      unlist(),
    nrow(ADSL)
  )
  # test the final cum p is 1
  expect_equal(
    ard |>
      dplyr::filter(
        stat_name == "p_cum",
        variable_level %in% dplyr::last(.unique_and_sorted(ADSL$AGEGR1))
      ) |>
      dplyr::pull(stat) |>
      unlist(),
    1
  )
  # check the cum n is correct
  expect_equal(
    ard |>
      dplyr::filter(stat_name %in% "n_cum") |>
      dplyr::select(variable_level, stat) |>
      deframe(),
    table(ADSL$AGEGR1) |>
      cumsum() |>
      as.list()
  )
  # check the cum p is correct
  expect_equal(
    ard |>
      dplyr::filter(stat_name %in% "p_cum") |>
      dplyr::select(variable_level, stat) |>
      deframe(),
    table(ADSL$AGEGR1) |>
      prop.table() |>
      cumsum() |>
      as.list()
  )

  # check cumulative stats work with `by`
  expect_silent(
    ard <-
      ard_tabulate(
        ADSL,
        variables = "AGEGR1",
        by = ARM,
        statistic = everything() ~ c("n", "p", "n_cum", "p_cum")
      )
  )
  # check the cum n is correct
  expect_equal(
    ard |>
      dplyr::filter(stat_name %in% "n_cum", group1_level == "Placebo") |>
      dplyr::select(variable_level, stat) |>
      deframe(),
    table(ADSL$AGEGR1[ADSL$ARM == "Placebo"]) |>
      cumsum() |>
      as.list()
  )
  # check the cum p is correct
  expect_equal(
    ard |>
      dplyr::filter(stat_name %in% "p_cum", group1_level == "Placebo") |>
      dplyr::select(variable_level, stat) |>
      deframe(),
    table(ADSL$AGEGR1[ADSL$ARM == "Placebo"]) |>
      prop.table() |>
      cumsum() |>
      as.list()
  )

  # check with by & strata
  expect_silent(
    ard <-
      ard_tabulate(
        ADSL,
        variables = "AGEGR1",
        by = ARM,
        strata = SEX,
        statistic = everything() ~ c("n", "p", "n_cum", "p_cum")
      )
  )
  # check the cum n is correct
  expect_equal(
    ard |>
      dplyr::filter(
        stat_name %in% "n_cum",
        group1_level == "Placebo",
        group2_level == "F"
      ) |>
      dplyr::select(variable_level, stat) |>
      deframe(),
    table(ADSL$AGEGR1[ADSL$ARM == "Placebo" & ADSL$SEX == "F"]) |>
      cumsum() |>
      as.list()
  )
  # check the cum p is correct
  expect_equal(
    ard |>
      dplyr::filter(
        stat_name %in% "p_cum",
        group1_level == "Placebo",
        group2_level == "F"
      ) |>
      dplyr::select(variable_level, stat) |>
      deframe(),
    table(ADSL$AGEGR1[ADSL$ARM == "Placebo" & ADSL$SEX == "F"]) |>
      prop.table() |>
      cumsum() |>
      as.list()
  )

  # function works when only `n_cum` requested
  expect_equal(
    ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      statistic = everything() ~ "n_cum"
    ),
    ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      statistic = everything() ~ c("n", "p", "n_cum", "p_cum")
    ) |>
      dplyr::filter(stat_name == "n_cum"),
    ignore_attr = TRUE
  )
  # function works when only `p_cum` requested
  expect_equal(
    ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      statistic = everything() ~ "p_cum"
    ),
    ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      statistic = everything() ~ c("n", "p", "n_cum", "p_cum")
    ) |>
      dplyr::filter(stat_name == "p_cum"),
    ignore_attr = TRUE
  )
})

test_that("ard_tabulate(denominator='row') with cumulative counts", {
  # check cumulative stats work without `by/strata`
  expect_silent(
    ard <-
      ard_tabulate(
        ADSL,
        variables = "AGEGR1",
        statistic = everything() ~ c("n", "p", "n_cum", "p_cum"),
        denominator = "row"
      )
  )
  # when no by, the n and n_cum should be the same
  expect_true(
    ard |>
      dplyr::filter(stat_name %in% c("n", "n_cum")) |>
      dplyr::mutate(
        .by = all_ard_variables(),
        check_equal = unlist(stat) == unlist(stat)[1]
      ) |>
      dplyr::pull(check_equal) |>
      unique()
  )
  # when no by, the p and p_cum should be the same and equal to 1
  expect_equal(
    ard |>
      dplyr::filter(stat_name %in% c("p", "p_cum")) |>
      dplyr::pull(stat) |>
      unlist() |>
      unique(),
    1
  )

  # check cumulative stats work with `by`
  expect_silent(
    ard <-
      ard_tabulate(
        ADSL,
        variables = "AGEGR1",
        by = SEX,
        statistic = everything() ~ c("n", "p", "n_cum", "p_cum"),
        denominator = "row"
      )
  )
  # check row n_cum
  expect_equal(
    ard |>
      dplyr::filter(variable_level %in% "<65", stat_name == "n_cum") |>
      dplyr::select(group1_level, stat) |>
      deframe(),
    table(ADSL$SEX[ADSL$AGEGR1 == "<65"]) |>
      cumsum() |>
      as.list()
  )
  # check row p_cum
  expect_equal(
    ard |>
      dplyr::filter(variable_level %in% "<65", stat_name == "p_cum") |>
      dplyr::select(group1_level, stat) |>
      deframe(),
    table(ADSL$SEX[ADSL$AGEGR1 == "<65"]) |>
      prop.table() |>
      cumsum() |>
      as.list()
  )
})

test_that("ard_tabulate() with cumulative counts messaging", {
  # cumulative counts/percents only available when `denominator=c('column', 'row')`
  expect_snapshot(
    error = TRUE,
    ard_tabulate(
      ADSL,
      variables = "AGEGR1",
      by = SEX,
      statistic = everything() ~ c("n", "p", "n_cum", "p_cum"),
      denominator = NULL
    )
  )
})

test_that("ard_tabulate() ordering for multiple strata", {
  adae_mini <- ADAE |>
    dplyr::select(USUBJID, TRTA, AESOC, AEDECOD) |>
    dplyr::filter(AESOC %in% unique(AESOC)[1:4]) |>
    dplyr::group_by(AESOC) |>
    dplyr::filter(AEDECOD %in% unique(AEDECOD)[1:5]) |>
    dplyr::ungroup()

  res_actual <- ard_tabulate(
    adae_mini |> unique() |> dplyr::mutate(any_ae = TRUE),
    strata = c(AESOC, AEDECOD),
    by = TRTA,
    variables = any_ae
  ) |>
    dplyr::select(group2_level, group3_level) |>
    tidyr::unnest(everything()) |>
    unique()

  expect_equal(
    res_actual,
    adae_mini |>
      dplyr::select(group2_level = AESOC, group3_level = AEDECOD) |>
      unique() |>
      dplyr::arrange(group2_level, group3_level),
    ignore_attr = TRUE
  )
})

test_that("ard_tabulate(data, denominator) class mis-match", {
  expect_snapshot(
    ard <-
      ard_tabulate(
        data = ADSL,
        variables = AGEGR1,
        by = TRTA,
        denominator = ADSL |> dplyr::mutate(TRTA = as.factor(TRTA))
      )
  )
})

test_that("ard_tabulate() attaches 'args' attribute", {
  res <- ard_tabulate(
    data = ADSL,
    by = "ARM",
    variables = "AGEGR1"
  )

  args <- attr(res, "args")

  expect_equal(args$variables, "AGEGR1")
  expect_equal(args$by, "ARM")

  # 'args' includes strata when present
  res_strata <- ard_tabulate(ADSL, by = "ARM", strata = "SEX", variables = "AGEGR1")
  expect_identical(
    attr(res_strata, "args"),
    list(variables = "AGEGR1", by = "ARM", strata = "SEX")
  )
})

# Contract-pinning tests ------------------------------------------------------
# The tests below pin behaviors of the counting engine that are relied on
# downstream (row order, storage types, NA handling) but were previously
# untested. They were generated against the engine in cards 0.8.1.9000 and
# guard the planned performance rewrite (#176).

test_that("ard_tabulate() row order is stable with by + multiple strata", {
  withr::local_options(list(width = 200))

  expect_snapshot(
    ard_tabulate(
      mtcars,
      by = am,
      strata = c(cyl, vs),
      variables = gear,
      statistic = ~ c("n", "N", "p", "n_cum", "p_cum")
    ) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
})

test_that("ard_tabulate() stat and level storage types are stable", {
  ard <-
    ard_tabulate(
      ADSL,
      by = "ARM",
      variables = "AGEGR1",
      statistic = ~ c("n", "N", "p", "n_cum", "p_cum")
    )

  # n, N, n_cum are integers; p, p_cum are doubles
  stat_types <- vapply(ard$stat, typeof, character(1))
  expect_true(all(stat_types[ard$stat_name %in% c("n", "N", "n_cum")] == "integer"))
  expect_true(all(stat_types[ard$stat_name %in% c("p", "p_cum")] == "double"))

  # factor variables keep class 'factor' in variable_level elements;
  # the 'ordered' class is dropped
  df_fct <- data.frame(
    f = factor(c("a", "b", "a"), levels = c("a", "b", "c")),
    o = factor(c("lo", "hi", "lo"), levels = c("lo", "hi"), ordered = TRUE)
  )
  ard_fct <- ard_tabulate(df_fct, variables = c(f, o))
  expect_identical(
    unique(lapply(ard_fct$variable_level, class)),
    list("factor")
  )
  # unobserved factor level 'c' is present
  expect_identical(
    ard_fct |>
      dplyr::filter(.data$variable == "f", .data$stat_name == "n") |>
      dplyr::pull("variable_level") |>
      unlist(use.names = FALSE) |>
      as.character(),
    c("a", "b", "c")
  )

  # Date variables keep class 'Date'
  df_date <- data.frame(d = as.Date(c("2024-01-01", "2024-01-02", "2024-01-01")))
  ard_date <- ard_tabulate(df_date, variables = d)
  expect_identical(
    unique(lapply(ard_date$variable_level, class)),
    list("Date")
  )

  # N inherits double type from a denominator data frame with double counts
  ard_dbl_n <-
    ard_tabulate(
      ADSL,
      by = "ARM",
      variables = "AGEGR1",
      denominator =
        data.frame(
          ARM = unique(ADSL$ARM),
          "...ard_N..." = c(86, 84, 84),
          check.names = FALSE
        )
    )
  expect_identical(
    vapply(ard_dbl_n$stat[ard_dbl_n$stat_name == "N"], typeof, character(1)) |> unique(),
    "double"
  )

  # a scalar denominator is coerced to integer
  ard_scalar_n <- ard_tabulate(ADSL, variables = "AGEGR1", denominator = 1000)
  expect_identical(
    vapply(ard_scalar_n$stat[ard_scalar_n$stat_name == "N"], typeof, character(1)) |> unique(),
    "integer"
  )
})

test_that("ard_tabulate() strata combinations containing NA yield a single NA row", {
  withr::local_options(list(width = 200))

  # 'var' is character (not factor): a list-column of factor scalars renders
  # its integer codes on some older R versions and its labels on others, which
  # would make these snapshots R-version dependent. Factor level classes are
  # pinned separately (and robustly) in the storage-types test above.
  df_na_strata <- data.frame(
    trt = c("A", "A", "B", "B", "A"),
    str = c("s1", "s1", "s2", NA, NA),
    var = c("x", "y", "x", "y", "x")
  )

  # column denominator: the NA-strata row has NA for n, N, and p
  expect_snapshot(
    ard_tabulate(df_na_strata, variables = var, by = trt, strata = str) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )

  # cell/integer denominators: the NA-strata row keeps the real N (with NA n/p)
  expect_snapshot(
    ard_tabulate(df_na_strata, variables = var, by = trt, strata = str, denominator = "cell") |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
  expect_snapshot(
    ard_tabulate(df_na_strata, variables = var, by = trt, strata = str, denominator = 100L) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
})

test_that("ard_tabulate(denominator) with an integer works with by and strata", {
  ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1", denominator = 1000L)
  expect_true(
    all(unlist(ard$stat[ard$stat_name == "N"]) == 1000L)
  )
  expect_identical(
    unlist(ard$stat[ard$stat_name == "p"]),
    unlist(ard$stat[ard$stat_name == "n"]) / 1000L
  )

  ard_strata <-
    ard_tabulate(ADSL, by = "ARM", strata = "SEX", variables = "AGEGR1", denominator = 1000L)
  expect_true(
    all(unlist(ard_strata$stat[ard_strata$stat_name == "N"]) == 1000L)
  )
})

test_that("ard_tabulate(denominator) data frames with extra columns work", {
  # extra columns not in by/strata are ignored
  expect_identical(
    ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1", denominator = ADSL[c("ARM", "AGE", "SEX")]),
    ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1", denominator = ADSL["ARM"])
  )

  # extra columns alongside '...ard_N...' are dropped
  ard <-
    ard_tabulate(
      ADSL,
      by = "ARM",
      variables = "AGEGR1",
      denominator =
        data.frame(
          ARM = unique(ADSL$ARM),
          extra_column = "zzz",
          "...ard_N..." = c(10L, 20L, 30L),
          check.names = FALSE
        )
    )
  expect_identical(
    ard |>
      dplyr::filter(.data$stat_name == "N") |>
      dplyr::pull("stat") |>
      unlist() |>
      unique(),
    c(10L, 20L, 30L)
  )
})

test_that("ard_tabulate() handles NaN and Inf in numeric variables", {
  withr::local_options(list(width = 200))

  # NaN is treated as missing; Inf is a level
  expect_snapshot(
    ard_tabulate(
      data.frame(x = c(1, 2, NaN, Inf, 2, 1, Inf)),
      variables = x
    ) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
})

test_that("ard_tabulate() errors when a column is in both variables and by/strata", {
  expect_snapshot(
    error = TRUE,
    ard_tabulate(ADSL, by = "ARM", variables = "ARM")
  )
  expect_snapshot(
    error = TRUE,
    ard_tabulate(ADSL, strata = "AGEGR1", variables = "AGEGR1")
  )
})

test_that("ard_tabulate() with zero-row data keeps factor levels and types", {
  df_zero <- data.frame(f = factor(character(0), levels = c("a", "b")))
  ard <- ard_tabulate(df_zero, variables = f)

  expect_identical(nrow(ard), 6L) # 2 levels x (n, N, p)
  expect_identical(
    unlist(ard$stat[ard$stat_name == "n"]),
    c(0L, 0L)
  )
  expect_identical(
    unlist(ard$stat[ard$stat_name == "N"]),
    c(0L, 0L)
  )
  expect_true(all(is.nan(unlist(ard$stat[ard$stat_name == "p"]))))
  expect_identical(
    unique(lapply(ard$variable_level, class)),
    list("factor")
  )
})

test_that("ard_tabulate() with NA values in a by column drops the NA group", {
  withr::local_options(list(width = 200))

  expect_snapshot(
    ard_tabulate(
      data.frame(b = c("g1", "g1", NA, "g2"), x = c("u", "v", "u", "u")),
      variables = x,
      by = b
    ) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
})

test_that("ard_tabulate(denominator='row') is stable with two by columns", {
  withr::local_options(list(width = 200))

  expect_snapshot(
    ard_tabulate(
      mtcars,
      by = c(am, vs),
      variables = gear,
      denominator = "row"
    ) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
})

test_that("ard_tabulate() cumulative statistics work with strata present", {
  withr::local_options(list(width = 200))

  # column denominator: cumsum within (by, strata) groups
  expect_snapshot(
    ard_tabulate(
      ADSL,
      by = "ARM",
      strata = "SEX",
      variables = "AGEGR1",
      statistic = ~ c("n", "n_cum", "p", "p_cum")
    ) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )

  # row denominator: cumsum within variable levels across groups
  expect_snapshot(
    ard_tabulate(
      ADSL,
      by = "ARM",
      strata = "SEX",
      variables = "AGEGR1",
      denominator = "row",
      statistic = ~ c("n", "n_cum", "p", "p_cum")
    ) |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
})

test_that("ard_tabulate() level ordering of character columns is stable", {
  withr::local_options(list(width = 200))

  # locale-sensitive characters (case, spaces, punctuation) as variable and by.
  # This pin documents the C-locale (`order(method = "radix")`) ordering used by
  # the engine since the #176 rewrite: uppercase sorts before lowercase and the
  # order is independent of the session locale, matching `dplyr::arrange()`.
  df_locale <- data.frame(
    x = c("b", "A", "a B", "a-B", "B", "a"),
    g = c("z1", "Z1", "z 1", "z-1", "z1", "Z1")
  )
  expect_snapshot(
    ard_tabulate(df_locale, variables = x, by = g, statistic = ~"n") |>
      dplyr::select(all_ard_groups(), all_ard_variables(), "stat_name", "stat") |>
      as.data.frame()
  )
})

test_that("nest_for_ard() and ard_tabulate() order character levels consistently (#589)", {
  # gtsummary's tbl_strata_nested_stack() pairs these two functions' level order
  # positionally, so a divergence attaches statistics to the wrong strata label
  # (ddsjoberg/gtsummary#2443). Both must use C-locale ordering (matching
  # dplyr::arrange()) for character columns.
  x <- c("ALT", "AST", "Albumin", "Bilirubin")
  df <- data.frame(g = rep(x, each = 3))

  tabulate_order <- unique(as.character(unlist(ard_tabulate(df, variables = "g")$variable_level)))

  # nest_for_ard() agrees via both the `strata` and `by` paths
  expect_identical(
    as.character(unlist(nest_for_ard(df, strata = "g")$group1_level)),
    tabulate_order
  )
  expect_identical(
    as.character(unlist(nest_for_ard(df, by = "g")$group1_level)),
    tabulate_order
  )

  # and both match dplyr::arrange() / the C locale
  expect_identical(tabulate_order, unique(dplyr::arrange(df, g)$g))
  expect_identical(tabulate_order, x[order(x, method = "radix")])
})

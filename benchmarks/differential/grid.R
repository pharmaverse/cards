# Differential-test case grid for the ard_tabulate() engine rewrite (#176) ----
# Each case is list(name =, call = quote(...)). Cases are evaluated twice by
# run-differential.R (legacy engine vs new engine) and compared.
#
# `locale_sensitive = TRUE` marks cases whose row/level ordering may legally
# differ between engines (base::order() vs vctrs C-locale ordering of
# character levels) — these get a secondary order-insensitive comparison.

build_case_grid <- function() {
  cases <- list()
  add <- function(name, call, locale_sensitive = FALSE, expect_fix = FALSE) {
    cases[[length(cases) + 1L]] <<-
      list(name = name, call = call, locale_sensitive = locale_sensitive, expect_fix = expect_fix)
  }

  # datasets used inside quoted calls (constructed fresh in the eval env) -----
  # defined in run-differential.R: ADSL, ADAE (package data), plus:
  #   df_types  - engineered mixed-type data frame
  #   df_zero   - zero-row data with factor
  #   df_na     - NA-heavy data (all-NA logical/factor, NA in by/strata)
  #   denom_*   - denominator data frames

  # 1. full cross: by x strata x denominator x statistic ----------------------
  by_opts <- list(
    none = NULL,
    one = "ARM",
    two = c("ARM", "SEX")
  )
  strata_opts <- list(
    none = NULL,
    one = "AGEGR1",
    two = c("AGEGR1", "RACE")
  )
  denom_opts <- list(
    column = quote("column"),
    row = quote("row"),
    cell = quote("cell"),
    null = quote(NULL),
    int = quote(1000L),
    df = quote(ADSL),
    df_nocols = quote(ADSL["BMIBL"]),
    df_counts = NULL, # resolved below to denom_counts_<cols> per by/strata combo
    misspec = quote(letters) # not a string/int/df -> mis-specification error path
  )
  stat_opts <- list(
    default = NULL,
    n_only = quote(~"n"),
    all = quote(~ c("n", "p", "N", "n_cum", "p_cum"))
  )

  for (b in names(by_opts)) {
    for (s in names(strata_opts)) {
      for (d in names(denom_opts)) {
        for (st in names(stat_opts)) {
          # keep the grid manageable: vary statistic only for column/row denominators
          if (st != "default" && !d %in% c("column", "row")) next
          # denom_counts requires by/strata columns to key on
          if (d == "df_counts" && b == "none" && s == "none") next

          # BMIBLGR1 is not in any by/strata option (variables must not overlap)
          cl <- call(
            "ard_tabulate",
            data = quote(ADSL),
            variables = "BMIBLGR1"
          )
          if (!is.null(by_opts[[b]])) cl$by <- by_opts[[b]]
          if (!is.null(strata_opts[[s]])) cl$strata <- strata_opts[[s]]
          if (d == "df_counts") {
            # a with-counts denominator keyed on exactly this case's by/strata cols
            cl$denominator <- as.name(
              paste0("denom_counts_", paste(c(by_opts[[b]], strata_opts[[s]]), collapse = "_"))
            )
          } else if (d != "column") {
            cl$denominator <- denom_opts[[d]]
          }
          if (!is.null(stat_opts[[st]])) cl$statistic <- stat_opts[[st]]

          add(paste("cross", b, s, d, st, sep = "/"), cl)
        }
      }
    }
  }

  # 2. variable types ---------------------------------------------------------
  add("type/factor_unobserved", quote(ard_tabulate(df_types, variables = fct_unob, by = grp)))
  add("type/ordered_factor", quote(ard_tabulate(df_types, variables = fct_ord)))
  add("type/character", quote(ard_tabulate(df_types, variables = chr, by = grp)))
  add("type/logical", quote(ard_tabulate(df_types, variables = lgl, by = grp)))
  add("type/integer", quote(ard_tabulate(df_types, variables = int, by = grp)))
  add("type/double", quote(ard_tabulate(df_types, variables = dbl, by = grp)))
  add("type/date", quote(ard_tabulate(df_types, variables = date, by = grp)))
  add("type/posixct", quote(ard_tabulate(df_types, variables = dttm)))
  add("type/nan_inf", quote(ard_tabulate(df_types, variables = dbl_naninf)))
  add("type/all_na_logical", quote(ard_tabulate(df_na, variables = lgl_all_na, by = grp)))
  add("type/all_na_factor", quote(ard_tabulate(df_na, variables = fct_all_na, by = grp)))
  add("type/all_na_logical_cell", quote(ard_tabulate(df_na, variables = lgl_all_na, by = grp, denominator = "cell")))
  add("type/factor_by", quote(ard_tabulate(df_types, variables = chr, by = fct_unob)))
  add("type/logical_by", quote(ard_tabulate(df_types, variables = chr, by = lgl)))
  add("type/numeric_by", quote(ard_tabulate(df_types, variables = chr, by = dbl)))

  # 3. locale/order-sensitive character levels --------------------------------
  add("locale/variable", quote(ard_tabulate(df_locale, variables = x, statistic = ~"n")), locale_sensitive = TRUE)
  add("locale/by", quote(ard_tabulate(df_locale, variables = x, by = g)), locale_sensitive = TRUE)
  add("locale/strata", quote(ard_tabulate(df_locale, variables = x, strata = g)), locale_sensitive = TRUE)

  # 4. NA handling -------------------------------------------------------------
  add("na/in_by", quote(ard_tabulate(df_na, variables = chr, by = grp_na)))
  add("na/in_strata", quote(ard_tabulate(df_na, variables = chr, by = grp, strata = strat_na)))
  add("na/in_strata_cell", quote(ard_tabulate(df_na, variables = chr, by = grp, strata = strat_na, denominator = "cell")))
  add("na/in_strata_int", quote(ard_tabulate(df_na, variables = chr, by = grp, strata = strat_na, denominator = 50L)))
  add("na/in_variable", quote(ard_tabulate(df_na, variables = chr_na, by = grp)))
  add("na/in_variable_row", quote(ard_tabulate(df_na, variables = chr_na, by = grp, denominator = "row")))

  # 5. structural edge cases ----------------------------------------------------
  add("edge/zero_row_factor", quote(ard_tabulate(df_zero, variables = f)))
  # legacy engine crashes on zero-row data with strata (tibble internal error);
  # the rewrite returns a 0-row ARD (zero observed strata combinations)
  add("edge/zero_row_strata", quote(ard_tabulate(df_zero, variables = f, by = g, strata = s)), expect_fix = TRUE)
  add("edge/single_row", quote(ard_tabulate(df_types[1, ], variables = chr, by = grp)))
  add("edge/grouped_input", quote(ard_tabulate(dplyr::group_by(ADSL, ARM), variables = "AGEGR1")))
  add("edge/nonsyntactic", quote(ard_tabulate(df_nonsyn, variables = `Age Group`, by = `Trt Arm`)))
  add(
    "edge/reserved_names",
    quote(ard_tabulate(df_reserved, variables = variable_level, by = name, denominator = "row"))
  )
  add("edge/multi_variables", quote(ard_tabulate(ADSL, variables = c("AGEGR1", "SEX", "RACE"), by = "ARM")))
  add(
    "edge/per_variable_stats",
    quote(ard_tabulate(
      ADSL,
      variables = c("AGEGR1", "SEX"),
      by = "ARM",
      statistic = list(AGEGR1 = c("n", "p"), SEX = "N"),
      stat_label = list(AGEGR1 = list(n = "num", p = "pct")),
      fmt_fun = list(AGEGR1 = list(n = 2))
    ))
  )
  add("edge/empty_variables", quote(ard_tabulate(ADSL, variables = starts_with("xyz_no_match"))))
  # on main this crashed with an internal error ('stat_name' not found); the
  # rewrite branch returns an empty ARD (the fix lives in the shared shell of
  # ard_tabulate.data.frame(), so both engines agree here)
  add("edge/empty_statistic", quote(ard_tabulate(ADSL, variables = "AGEGR1", statistic = ~ character(0))))

  # 6. error paths (identical condition messages required) ---------------------
  add("error/all_na_character", quote(ard_tabulate(df_na, variables = chr_all_na)))
  add("error/by_protected_name", quote(ard_tabulate(df_reserved, variables = name, by = variable)))
  add("error/factor_no_levels", quote(ard_tabulate(df_bad_fct, variables = f0)))
  add("error/factor_na_level", quote(ard_tabulate(df_bad_fct, variables = f_na_lvl)))
  add("error/cum_with_cell", quote(ard_tabulate(ADSL, variables = "AGEGR1", denominator = "cell", statistic = ~"n_cum")))
  add("error/denom_missing_combo", quote(ard_tabulate(ADSL, variables = "AGEGR1", by = "ARM", denominator = denom_missing_combo)))
  add("error/denom_dupe_n", quote(ard_tabulate(ADSL, variables = "AGEGR1", by = "ARM", denominator = denom_dupe_n)))
  add("error/vars_overlap_by", quote(ard_tabulate(ADSL, variables = "ARM", by = "ARM")))
  add("message/denom_class_mismatch", quote(ard_tabulate(df_types, variables = chr, by = fct_unob, denominator = denom_class_mismatch)))

  # 7. wrapper routes (end-to-end) ----------------------------------------------
  add("wrapper/tabulate_value", quote(ard_tabulate_value(mtcars, by = "vs", variables = c("cyl", "am"), value = list(cyl = 4))))
  add("wrapper/tabulate_rows", quote(ard_tabulate_rows(ADSL, by = "ARM")))
  add("wrapper/hierarchical", quote(ard_hierarchical(ADAE, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL)))
  add("wrapper/hierarchical_count", quote(ard_hierarchical_count(ADAE, variables = c(AESOC, AEDECOD), by = TRTA)))
  add(
    "wrapper/stack",
    quote(ard_stack(ADSL, ard_tabulate(variables = "AGEGR1"), .by = "ARM", .missing = TRUE, .attributes = TRUE))
  )
  add(
    "wrapper/stack_hierarchical",
    quote(ard_stack_hierarchical(ADAE, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID))
  )
  add("wrapper/deprecated_categorical", quote(ard_categorical(ADSL, by = "ARM", variables = "AGEGR1")))
  add("wrapper/deprecated_dichotomous", quote(ard_dichotomous(mtcars, by = "vs", variables = "cyl", value = list(cyl = 4))))

  cases
}

# datasets used by the cases; called by the runner in the evaluation env ------
build_case_data <- function(envir) {
  set.seed(20260724) # fixed seed: identical data on every run
  n <- 60

  envir$df_types <- data.frame(
    grp = rep(c("g1", "g2", "g3"), each = 20),
    fct_unob = factor(sample(c("a", "b"), n, replace = TRUE), levels = c("a", "b", "unobserved")),
    fct_ord = factor(sample(c("lo", "mid", "hi"), n, replace = TRUE), levels = c("lo", "mid", "hi"), ordered = TRUE),
    chr = sample(c("x", "y", "z"), n, replace = TRUE),
    lgl = sample(c(TRUE, FALSE), n, replace = TRUE),
    int = sample(1:4, n, replace = TRUE),
    dbl = sample(c(1.5, 2.5, 3.5), n, replace = TRUE),
    date = as.Date("2024-01-01") + sample(0:3, n, replace = TRUE),
    dttm = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + sample(c(0, 3600), n, replace = TRUE),
    dbl_naninf = sample(c(1, 2, NaN, Inf), n, replace = TRUE)
  )

  envir$df_na <- data.frame(
    grp = rep(c("g1", "g2"), each = 15),
    grp_na = rep(c("g1", NA, "g2"), each = 10),
    strat_na = rep(c("s1", "s2", NA), times = 10),
    chr = sample(c("u", "v"), 30, replace = TRUE),
    chr_na = sample(c("u", "v", NA), 30, replace = TRUE),
    chr_all_na = NA_character_,
    lgl_all_na = NA,
    fct_all_na = factor(rep(NA_character_, 30), levels = c("a", "b"))
  )

  envir$df_locale <- data.frame(
    x = c("b", "A", "a B", "a-B", "B", "a"),
    g = c("z1", "Z1", "z 1", "z-1", "z1", "Z1")
  )

  envir$df_zero <- data.frame(
    f = factor(character(0), levels = c("a", "b")),
    g = character(0),
    s = character(0)
  )

  envir$df_nonsyn <- data.frame(
    `Age Group` = sample(c("<65", ">=65"), 40, replace = TRUE),
    `Trt Arm` = rep(c("A", "B"), each = 20),
    check.names = FALSE
  )

  envir$df_reserved <- data.frame(
    variable = sample(c("v1", "v2"), 40, replace = TRUE),
    variable_level = sample(c("l1", "l2"), 40, replace = TRUE),
    name = rep(c("n1", "n2"), each = 20)
  )

  envir$df_bad_fct <- data.frame(x = 1:5)
  envir$df_bad_fct$f0 <- factor(rep(NA_character_, 5), levels = character(0))
  envir$df_bad_fct$f_na_lvl <- factor(rep("a", 5), levels = c("a", NA), exclude = NULL)

  # denominator data frames with pre-specified counts, one per by/strata key
  # set used in the cross grid
  key_sets <- list(
    c("ARM"),
    c("AGEGR1"),
    c("ARM", "AGEGR1"),
    c("ARM", "SEX"),
    c("AGEGR1", "RACE"),
    c("ARM", "SEX", "AGEGR1"),
    c("ARM", "AGEGR1", "RACE"),
    c("ARM", "SEX", "AGEGR1", "RACE")
  )
  for (cols in key_sets) {
    df <- dplyr::count(envir$ADSL[cols], dplyr::pick(dplyr::everything()), name = "...ard_N...")
    assign(paste0("denom_counts_", paste(cols, collapse = "_")), as.data.frame(df), envir = envir)
  }
  envir$denom_missing_combo <- envir$ADSL[envir$ADSL$ARM == "Placebo", ]
  envir$denom_dupe_n <- data.frame(
    ARM = rep(unique(envir$ADSL$ARM), 2),
    "...ard_N..." = 1:6,
    check.names = FALSE
  )
  envir$denom_class_mismatch <- data.frame(
    fct_unob = factor(c("a", "b", "unobserved")),
    "...ard_N..." = c(30L, 20L, 10L),
    check.names = FALSE
  )

  invisible(envir)
}

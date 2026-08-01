# Differential-test case grid for the sort_ard_hierarchical() /
# filter_ard_hierarchical() performance rewrite (#176) ------------------------
#
# Each case is list(name =, call = quote(...)). The call operates on a
# pre-built stacked hierarchical ARD held in the eval env (see build_sf_data()).
# run-differential-sort-filter.R evaluates every case twice — legacy funcs vs
# rewritten funcs — and gates on identical() over result + messages + warnings
# + errors.
#
# Input ARDs are built once (new engine) in build_sf_data() and shared by both
# arms of every case, so each case isolates the sort/filter transform. ARD
# construction itself (which calls sort_ard_hierarchical() internally) is
# covered separately by the wrapper/stack_hierarchical case in the ard_tabulate
# grid and by the package snapshot tests.

build_sf_case_grid <- function() {
  cases <- list()
  add <- function(name, call) {
    cases[[length(cases) + 1L]] <<- list(name = name, call = call)
  }

  # ---- sort_ard_hierarchical cases ------------------------------------------
  # ARDs available in the eval env:
  #   ard_2by      2 vars, by = TRTA, rates (n/N/p), overall = FALSE
  #   ard_2by_ov   2 vars, by = TRTA, overall = TRUE
  #   ard_2by_ovv  2 vars, by = TRTA, over_variables = TRUE
  #   ard_3by      3 vars, by = TRTA
  #   ard_2nb      2 vars, no by
  #   ard_1by      1 var,  by = TRTA
  #   ard_2by2     2 vars, by = c(TRTA, SEX)  (length-2 by -> severity path)
  #   ard_cnt      2 vars, by = TRTA, count ARD (n only)
  #   ard_inc      2 vars, by = TRTA, include = AEDECOD only
  #   ard_ponly    2 vars, by = TRTA, statistic ~ c("N","p") (no n)
  #   ard_attr     2 vars, by = TRTA, attributes = TRUE, total_n = TRUE
  #   ard_ties     small ARD engineered to produce tied descending sums

  add("sort/default_desc", quote(sort_ard_hierarchical(ard_2by)))
  add("sort/alpha_all", quote(sort_ard_hierarchical(ard_2by, sort = "alphanumeric")))
  add("sort/mixed", quote(sort_ard_hierarchical(ard_2by, sort = list(AESOC ~ "alphanumeric", AEDECOD ~ "descending"))))
  add("sort/mixed2", quote(sort_ard_hierarchical(ard_2by, sort = list(AESOC ~ "descending", AEDECOD ~ "alphanumeric"))))
  add("sort/string_alpha", quote(sort_ard_hierarchical(ard_2by, sort = "alphanumeric")))
  add("sort/overall", quote(sort_ard_hierarchical(ard_2by_ov)))
  add("sort/overall_alpha", quote(sort_ard_hierarchical(ard_2by_ov, sort = "alphanumeric")))
  add("sort/over_variables", quote(sort_ard_hierarchical(ard_2by_ovv)))
  add("sort/three_level", quote(sort_ard_hierarchical(ard_3by)))
  add("sort/three_level_mixed", quote(sort_ard_hierarchical(
    ard_3by,
    sort = list(AESOC ~ "descending", AEBODSYS ~ "alphanumeric", AEDECOD ~ "descending")
  )))
  add("sort/no_by", quote(sort_ard_hierarchical(ard_2nb)))
  add("sort/no_by_alpha", quote(sort_ard_hierarchical(ard_2nb, sort = "alphanumeric")))
  add("sort/single_var", quote(sort_ard_hierarchical(ard_1by)))
  add("sort/single_var_alpha", quote(sort_ard_hierarchical(ard_1by, sort = "alphanumeric")))
  add("sort/length2_by", quote(sort_ard_hierarchical(ard_2by2)))
  add("sort/length2_by_alpha", quote(sort_ard_hierarchical(ard_2by2, sort = "alphanumeric")))
  add("sort/count_ard", quote(sort_ard_hierarchical(ard_cnt)))
  add("sort/include_subset", quote(sort_ard_hierarchical(ard_inc)))
  add("sort/p_only_desc", quote(sort_ard_hierarchical(ard_ponly)))
  add("sort/attributes", quote(sort_ard_hierarchical(ard_attr)))
  add("sort/ties", quote(sort_ard_hierarchical(ard_ties)))
  add("sort/ties_alpha", quote(sort_ard_hierarchical(ard_ties, sort = "alphanumeric")))
  # error path: descending requested but neither n nor p present for a variable
  add("sort/error_no_np", quote(sort_ard_hierarchical(ard_Nonly)))

  # ---- filter_ard_hierarchical cases ----------------------------------------
  add("filter/n_gt", quote(filter_ard_hierarchical(ard_2by, n > 2)))
  add("filter/n_ge", quote(filter_ard_hierarchical(ard_2by, n >= 3)))
  add("filter/p_gt", quote(filter_ard_hierarchical(ard_2by, p > 0.05)))
  add("filter/compound", quote(filter_ard_hierarchical(ard_2by, n == 2 & p < 0.5)))
  add("filter/sum_n", quote(filter_ard_hierarchical(ard_2by, sum(n) > 3)))
  add("filter/mean_n", quote(filter_ard_hierarchical(ard_2by, mean(n) > 2 | n > 3)))
  add("filter/order_sensitive", quote(filter_ard_hierarchical(ard_2by, n[1] > 2)))
  add("filter/ratio", quote(filter_ard_hierarchical(ard_2by, sum(n) / sum(N) > 0.05)))
  add("filter/col_stat_n1", quote(filter_ard_hierarchical(ard_2by, n_1 > 2)))
  add("filter/col_stat_diff", quote(filter_ard_hierarchical(ard_2by, abs(p_2 - p_3) > 0.03)))
  add("filter/n_overall_derived", quote(filter_ard_hierarchical(ard_2by, n_overall > 3)))
  add("filter/N_overall_derived", quote(filter_ard_hierarchical(ard_2by, N_overall > 100)))
  add("filter/p_overall_derived", quote(filter_ard_hierarchical(ard_2by, p_overall > 0.05)))
  add("filter/n_overall_true", quote(filter_ard_hierarchical(ard_2by_ov, n_overall > 3)))
  add("filter/p_overall_true", quote(filter_ard_hierarchical(ard_2by_ov, p_overall > 0.05)))
  add("filter/quiet", quote(filter_ard_hierarchical(ard_2by, n_1 > 2, quiet = TRUE)))
  add("filter/keep_all", quote(filter_ard_hierarchical(ard_2by, n >= 0)))
  add("filter/keep_none", quote(filter_ard_hierarchical(ard_2by, n > 1e6)))
  add("filter/no_by", quote(filter_ard_hierarchical(ard_2nb, n > 2)))
  add("filter/no_by_overall", quote(filter_ard_hierarchical(ard_2nb, n_overall > 2)))
  add("filter/count_ard", quote(filter_ard_hierarchical(ard_cnt, n > 2)))
  add("filter/over_variables", quote(filter_ard_hierarchical(ard_2by_ovv, n > 2)))
  # var = outer variable (section pruning + keep_empty branches)
  add("filter/var_outer", quote(filter_ard_hierarchical(ard_2by, p > 0.05, var = AESOC)))
  add("filter/var_outer_overall", quote(filter_ard_hierarchical(ard_2by, p_overall > 0.10, var = AESOC)))
  add("filter/var_outer_keep_empty", quote(filter_ard_hierarchical(ard_2by, n > 3, var = AESOC, keep_empty = TRUE)))
  add("filter/var_mid_3lvl", quote(filter_ard_hierarchical(ard_3by, n > 2, var = AEBODSYS)))
  add("filter/var_outer_3lvl", quote(filter_ard_hierarchical(ard_3by, n > 3, var = AESOC)))
  add("filter/attributes", quote(filter_ard_hierarchical(ard_attr, n > 2)))
  add("filter/single_var", quote(filter_ard_hierarchical(ard_1by, n > 2)))
  # error paths (identical messages required)
  add("filter/error_bad_stat", quote(filter_ard_hierarchical(ard_2by, q > 2)))
  add("filter/error_not_expr", quote(filter_ard_hierarchical(ard_2by, n)))
  add("filter/error_var_not_included", quote(filter_ard_hierarchical(ard_inc, n > 2, var = AESOC)))

  cases
}

# datasets + prebuilt ARDs used by the cases; called by the runner ------------
build_sf_data <- function(envir) {
  ADSL <- cards::ADSL
  ADAE <- cards::ADAE

  # keep a compact, deterministic AE subset so the grid runs fast but still
  # exercises multiple SOCs / AEs / body systems and by-levels
  soc_keep <- c(
    "GASTROINTESTINAL DISORDERS",
    "SKIN AND SUBCUTANEOUS TISSUE DISORDERS",
    "NERVOUS SYSTEM DISORDERS",
    "CARDIAC DISORDERS"
  )
  adae <- ADAE[ADAE$AESOC %in% soc_keep, ]

  # ARD builders (silence the alphanumeric-sort's own construction messages)
  mk <- function(...) suppressMessages(cards::ard_stack_hierarchical(...))
  mkc <- function(...) suppressMessages(cards::ard_stack_hierarchical_count(...))

  envir$ard_2by <- mk(adae, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID)
  envir$ard_2by_ov <- mk(adae, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID, overall = TRUE)
  envir$ard_2by_ovv <- mk(adae, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID, over_variables = TRUE)
  envir$ard_3by <- mk(adae, variables = c(AESOC, AEBODSYS, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID)
  envir$ard_2nb <- mk(adae, variables = c(AESOC, AEDECOD), denominator = ADSL, id = USUBJID)
  envir$ard_1by <- mk(adae, variables = AEDECOD, by = TRTA, denominator = ADSL, id = USUBJID)
  envir$ard_2by2 <- mk(adae, variables = c(AESOC, AEDECOD), by = c(TRTA, SEX), denominator = ADSL, id = USUBJID)
  envir$ard_cnt <- mkc(adae, variables = c(AESOC, AEDECOD), by = TRTA)
  envir$ard_inc <- mk(adae, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID, include = AEDECOD)
  envir$ard_ponly <- mk(adae,
    variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID,
    statistic = everything() ~ c("N", "p")
  )
  envir$ard_Nonly <- mk(adae,
    variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID,
    statistic = everything() ~ "N"
  )
  envir$ard_attr <- mk(adae,
    variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID,
    attributes = TRUE, total_n = TRUE
  )

  # tie-prone ARD: a tiny hand-built dataset where descending sums collide
  set.seed(20260731)
  tie_dat <- data.frame(
    USUBJID = sprintf("T%03d", 1:60),
    TRTA = rep(c("A", "B"), 30),
    AESOC = rep(c("S1", "S2", "S3"), each = 20),
    stringsAsFactors = FALSE
  )
  tie_dat$AEDECOD <- paste0(tie_dat$AESOC, "-", rep(c("a", "b"), 30))
  tie_adsl <- data.frame(USUBJID = sprintf("T%03d", 1:60), TRTA = rep(c("A", "B"), 30), stringsAsFactors = FALSE)
  envir$ard_ties <- mk(tie_dat, variables = c(AESOC, AEDECOD), by = TRTA, denominator = tie_adsl, id = USUBJID)

  invisible(envir)
}

# Benchmarks for the ard_tabulate() engine rewrite (#176) ---------------------
#
# Usage (from the package root, on the rewrite branch):
#   Rscript benchmarks/bench_ard_tabulate_rewrite.R
#
# Measures the legacy engine (benchmarks/differential/legacy-engine.R swapped
# into the namespace) against the engine in R/ across scenarios chosen to
# cover both the rewrite's target cases (sparse strata, high cardinality) and
# the overhead-sensitive tiny-data case. Writes a markdown report to
# benchmarks/results/.

suppressPackageStartupMessages({
  library(bench)
  library(dplyr)
})

pkgload::load_all(".", quiet = TRUE)

ENGINE_FNS <- c(
  ".calculate_tabulation_statistics", ".table_as_df",
  ".process_denominator", ".add_cum_count_stats", "arrange_using_order"
)
legacy_env <- new.env(parent = asNamespace("cards"))
sys.source(file.path("benchmarks", "differential", "legacy-engine.R"), envir = legacy_env)

swap_in_legacy <- function() {
  originals <- mget(ENGINE_FNS, envir = asNamespace("cards"))
  for (fn in ENGINE_FNS) utils::assignInNamespace(fn, legacy_env[[fn]], ns = "cards")
  originals
}
swap_back <- function(originals) {
  for (fn in ENGINE_FNS) utils::assignInNamespace(fn, originals[[fn]], ns = "cards")
}

# scenario data ----------------------------------------------------------------
set.seed(20260724)

ADSL <- cards::ADSL
ADAE <- cards::ADAE
adsl_1m <- ADSL[rep(seq_len(nrow(ADSL)), 4000L), ] # ~1M rows

# many by-level combinations, ~half unobserved
n_s4 <- 100000L
df_many_by <- data.frame(
  b1 = factor(sample(sprintf("b1_%02d", 1:30), n_s4, replace = TRUE), levels = sprintf("b1_%02d", 1:30)),
  b2 = factor(
    sample(sprintf("b2_%02d", 1:15), n_s4, replace = TRUE),
    levels = sprintf("b2_%02d", 1:30) # half the levels unobserved
  ),
  var = factor(sample(c("x", "y", "z"), n_s4, replace = TRUE))
)

# 50 variables in one call
df_many_vars <- as.data.frame(
  c(
    list(grp = rep(c("g1", "g2", "g3"), length.out = 10000L)),
    stats::setNames(
      lapply(1:50, \(i) sample(c("a", "b", "c"), 10000L, replace = TRUE)),
      sprintf("v%02d", 1:50)
    )
  )
)

# high-cardinality variable: 10k distinct character levels
n_s7 <- 200000L
df_high_card <- data.frame(
  grp = sample(c("g1", "g2", "g3"), n_s7, replace = TRUE),
  id = sprintf("level_%05d", sample(1:10000, n_s7, replace = TRUE))
)

# large, high-cardinality AE dataset: the sparse-strata pattern that
# ard_hierarchical()/ard_stack_hierarchical() are built on. Each PT is nested
# in exactly one SOC (realistic MedDRA), so the ~2,000 observed SOC x PT
# combinations are sparse within the 30 x 2,000 full cross that the legacy
# engine materialized densely (and twice, for counts and denominators).
n_subj_ae <- 5000L
n_events <- 200000L
pt_soc <- data.frame(
  AEDECOD = sprintf("PT%04d", 1:2000),
  AESOC = sprintf("SOC%02d", sample(1:30, 2000, replace = TRUE))
)
big_adsl <- data.frame(
  USUBJID = sprintf("S%05d", 1:n_subj_ae),
  TRTA = sample(c("Placebo", "Drug A", "Drug B"), n_subj_ae, replace = TRUE)
)
big_adae <- pt_soc[sample(nrow(pt_soc), n_events, replace = TRUE), ]
big_adae$USUBJID <- sample(big_adsl$USUBJID, n_events, replace = TRUE)
# ard_hierarchical(id=) expects one row per subject/leaf (it does not de-event
# internally the way ard_stack_hierarchical() does), so reduce to distinct
# subject x SOC x PT records (~196k rows remain)
big_adae <- dplyr::distinct(big_adae, USUBJID, AESOC, AEDECOD)
big_adae <- dplyr::left_join(big_adae, big_adsl, by = "USUBJID")

scenarios <- list(
  S1_tiny_overhead = quote(ard_tabulate(mtcars, variables = "am")),
  S2_typical = quote(ard_tabulate(ADSL, by = "ARM", variables = c("AGEGR1", "SEX", "RACE"))),
  S3_large_n = quote(ard_tabulate(adsl_1m, by = "ARM", variables = "AGEGR1")),
  S4_many_by_levels = quote(ard_tabulate(df_many_by, by = c("b1", "b2"), variables = "var")),
  S5_sparse_strata = quote(
    ard_tabulate(
      dplyr::mutate(ADAE, dummy_one = 1L),
      variables = "dummy_one",
      by = "TRTA",
      strata = c("AESOC", "AEDECOD"),
      denominator = ADSL,
      statistic = ~"n"
    )
  ),
  S5b_hierarchical = quote(ard_hierarchical(ADAE, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL)),
  S6_many_variables = quote(ard_tabulate(df_many_vars, by = "grp", variables = sprintf("v%02d", 1:50))),
  S7_high_cardinality = quote(ard_tabulate(df_high_card, by = "grp", variables = "id")),
  S8_stack_hierarchical = quote(
    ard_stack_hierarchical(ADAE, variables = c(AESOC, AEDECOD), by = TRTA, denominator = ADSL, id = USUBJID)
  ),
  # large-AE hierarchical scenario (the headline improvement): subject-level
  # incidence over a high-cardinality SOC/PT hierarchy, 200k events / 5k
  # subjects, where the legacy engine materialized the full 30 x 2,000 SOC/PT
  # cross densely (and twice) but only ~2,000 combinations are observed
  S9_hierarchical_large = quote(
    ard_hierarchical(big_adae, variables = c(AESOC, AEDECOD), by = TRTA, denominator = big_adsl, id = USUBJID)
  )
)
# more iterations where each run is fast, fewer where runs are expensive
iterations <- c(
  S1_tiny_overhead = 200L, S2_typical = 25L, S3_large_n = 5L,
  S4_many_by_levels = 5L, S5_sparse_strata = 5L, S5b_hierarchical = 5L,
  S6_many_variables = 5L, S7_high_cardinality = 3L, S8_stack_hierarchical = 3L,
  S9_hierarchical_large = 3L
)

run_engine <- function(engine) {
  if (engine == "legacy") {
    originals <- swap_in_legacy()
    on.exit(swap_back(originals), add = TRUE)
  }
  lapply(names(scenarios), function(nm) {
    cat(sprintf("  %s / %s\n", engine, nm))
    res <- bench::mark(
      eval(scenarios[[nm]]),
      iterations = iterations[[nm]],
      check = FALSE,
      filter_gc = FALSE,
      memory = TRUE
    )
    dplyr::tibble(
      scenario = nm,
      engine = engine,
      min = res$min,
      median = res$median,
      `itr/sec` = res$`itr/sec`,
      mem_alloc = res$mem_alloc,
      n_gc = res$n_gc
    )
  }) |>
    dplyr::bind_rows()
}

cat("Benchmarking new engine...\n")
res_new <- run_engine("new")
cat("Benchmarking legacy engine...\n")
res_legacy <- run_engine("legacy")

results <-
  dplyr::bind_rows(res_legacy, res_new) |>
  dplyr::arrange(.data$scenario, .data$engine) |>
  dplyr::mutate(
    .by = "scenario",
    speedup_vs_legacy = round(as.numeric(median[engine == "legacy"]) / as.numeric(median), 2)
  ) |>
  dplyr::mutate(
    dplyr::across(c("min", "median"), ~ format(.x)),
    mem_alloc = format(.data$mem_alloc),
    `itr/sec` = round(.data$`itr/sec`, 2)
  )

print(as.data.frame(results), width = 200)

# S1 overhead guard: the rewrite must not slow down the tiny-data case > 5%
s1 <- results[results$scenario == "S1_tiny_overhead", ]
ratio <- 1 / s1$speedup_vs_legacy[s1$engine == "new"]
cat(sprintf("\nS1 overhead ratio (new/legacy): %.3f (must be <= 1.05)\n", ratio))

dir.create(file.path("benchmarks", "results"), showWarnings = FALSE)
out_file <- file.path("benchmarks", "results", format(Sys.Date(), "ard_tabulate-rewrite-%Y-%m-%d.md"))
cat(
  "### `ard_tabulate()` engine rewrite benchmarks (#176)\n\n",
  sprintf("Run on %s, R %s, cards %s.\n\n", Sys.Date(), getRversion(), utils::packageVersion("cards")),
  file = out_file
)
results |>
  knitr::kable() |>
  cat(file = out_file, append = TRUE, sep = "\n")
cat("\nReport written to ", out_file, "\n", sep = "")

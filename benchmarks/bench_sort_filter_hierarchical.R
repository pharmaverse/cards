# Benchmark suite: sort_ard_hierarchical() / filter_ard_hierarchical() (#176) --
#
# Usage (from the package root):
#   Rscript benchmarks/bench_sort_filter_hierarchical.R
#
# Builds a large stacked hierarchical ARD and times sort + representative
# filter calls with memory tracking. Run on `main` and on the rewrite branch
# and compare the tables; the rewrite must leave results unchanged (see the
# differential harness) while improving time and mem_alloc.

pkgload::load_all(".", quiet = TRUE)

make_ard <- function(n_soc, n_ae_per, n_pt, ae_rows, seed = 1L) {
  set.seed(seed)
  adsl <- data.frame(
    USUBJID = sprintf("PT%05d", seq_len(n_pt)),
    TRTA = sample(c("A", "B", "C"), n_pt, replace = TRUE),
    stringsAsFactors = FALSE
  )
  soc <- sprintf("SOC%03d", seq_len(n_soc))
  adae <- data.frame(
    USUBJID = sample(adsl$USUBJID, ae_rows, replace = TRUE),
    AESOC = sample(soc, ae_rows, replace = TRUE),
    stringsAsFactors = FALSE
  )
  adae$AEDECOD <- paste0(adae$AESOC, "_AE", sprintf("%02d", sample(n_ae_per, ae_rows, replace = TRUE)))
  adae$TRTA <- adsl$TRTA[match(adae$USUBJID, adsl$USUBJID)]
  suppressMessages(
    ard_stack_hierarchical(
      adae,
      variables = c(AESOC, AEDECOD),
      by = TRTA,
      denominator = adsl,
      id = USUBJID,
      overall = TRUE
    )
  )
}

bench_one <- function(label, ard) {
  cat("\n====", label, "(", nrow(ard), "rows ) ====\n")
  # `memory = FALSE`: bench's allocation tracking (Rprofmem) adds large,
  # allocation-proportional overhead that distorts timings for these
  # allocation-heavy calls. Time and memory are therefore measured separately.
  time <- bench::mark(
    sort = sort_ard_hierarchical(ard),
    filter_n = filter_ard_hierarchical(ard, n > 2),
    filter_col = suppressMessages(filter_ard_hierarchical(ard, n_1 > 2)),
    filter_overall = filter_ard_hierarchical(ard, n_overall > 2),
    filter_var_outer = filter_ard_hierarchical(ard, p > 0.01, var = AESOC),
    check = FALSE,
    iterations = 3,
    filter_gc = FALSE,
    memory = FALSE
  )
  mem <- bench::mark(
    sort = sort_ard_hierarchical(ard),
    filter_n = filter_ard_hierarchical(ard, n > 2),
    filter_col = suppressMessages(filter_ard_hierarchical(ard, n_1 > 2)),
    filter_overall = filter_ard_hierarchical(ard, n_overall > 2),
    filter_var_outer = filter_ard_hierarchical(ard, p > 0.01, var = AESOC),
    check = FALSE,
    iterations = 1,
    filter_gc = FALSE
  )
  out <- data.frame(
    expression = as.character(time$expression),
    median_s = round(as.numeric(time$median), 3),
    mem_alloc_MB = round(as.numeric(mem$mem_alloc) / 1024^2, 1)
  )
  print(out, row.names = FALSE)
  invisible(out)
}

# large case (matches the plan's profiled baseline: ~82k rows)
ard_lg <- make_ard(n_soc = 150, n_ae_per = 60, n_pt = 1000, ae_rows = 200000)
bench_one("large  150x60x3", ard_lg)

# small case guards against added fixed overhead on typical-size ARDs
ard_sm <- make_ard(n_soc = 20, n_ae_per = 10, n_pt = 300, ae_rows = 5000)
bench_one("small  20x10x3", ard_sm)

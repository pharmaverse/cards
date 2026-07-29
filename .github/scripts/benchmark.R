suppressPackageStartupMessages({
  library(bench)
  library(dplyr)
  library(pkgload)
})

# Load the local cards package
pkgload::load_all(".")

# We use the trial dataset from gtsummary to test
library(gtsummary)
data_big <- trial[rep(seq_len(nrow(trial)), 20), ]

cat("Running benchmarks for ard_summary and ard_tabulate...\n")

res_summary <- bench::mark(
  ard_summary(
    data_big,
    variables = c(age, marker),
    by = trt
  ),
  check = FALSE,
  iterations = 10,
  filter_gc = FALSE
)

res_tabulate <- bench::mark(
  ard_tabulate(
    data_big,
    variables = c(grade, trt),
    by = response
  ),
  check = FALSE,
  iterations = 10,
  filter_gc = FALSE
)

# sparse-strata pattern (the ard_hierarchical() shape; many observed
# SOC/PT combinations, most of the full cross unobserved)
res_tabulate_strata <- bench::mark(
  ard_hierarchical(
    ADAE,
    variables = c(AESOC, AEDECOD),
    by = TRTA,
    denominator = ADSL
  ),
  check = FALSE,
  iterations = 5,
  filter_gc = FALSE
)

# high-cardinality variable
set.seed(20260724)
data_high_card <- data.frame(
  grp = sample(c("g1", "g2", "g3"), 2e5, replace = TRUE),
  id = sprintf("level_%05d", sample(1:5000, 2e5, replace = TRUE))
)
res_tabulate_high_card <- bench::mark(
  ard_tabulate(data_high_card, by = grp, variables = id),
  check = FALSE,
  iterations = 3,
  filter_gc = FALSE
)

# Format the results into a markdown table
cat("### Performance Benchmark Results\n\n", file = "bench_report.md")
cat("These benchmarks run on 20x replicated `gtsummary::trial` dataset.\n\n", file = "bench_report.md", append = TRUE)

cat("#### `ard_summary`\n", file = "bench_report.md", append = TRUE)
knitr::kable(summary(res_summary)[, c("expression", "min", "median", "itr/sec", "mem_alloc", "gc/sec", "n_itr", "n_gc", "total_time")]) |>
  cat(file = "bench_report.md", append = TRUE, sep = "\n")

cat("\n#### `ard_tabulate`\n", file = "bench_report.md", append = TRUE)
knitr::kable(summary(res_tabulate)[, c("expression", "min", "median", "itr/sec", "mem_alloc", "gc/sec", "n_itr", "n_gc", "total_time")]) |>
  cat(file = "bench_report.md", append = TRUE, sep = "\n")

cat("\n#### `ard_hierarchical` (sparse strata)\n", file = "bench_report.md", append = TRUE)
knitr::kable(summary(res_tabulate_strata)[, c("expression", "min", "median", "itr/sec", "mem_alloc", "gc/sec", "n_itr", "n_gc", "total_time")]) |>
  cat(file = "bench_report.md", append = TRUE, sep = "\n")

cat("\n#### `ard_tabulate` (high-cardinality variable)\n", file = "bench_report.md", append = TRUE)
knitr::kable(summary(res_tabulate_high_card)[, c("expression", "min", "median", "itr/sec", "mem_alloc", "gc/sec", "n_itr", "n_gc", "total_time")]) |>
  cat(file = "bench_report.md", append = TRUE, sep = "\n")

cat("\nBenchmark report generated successfully.\n")

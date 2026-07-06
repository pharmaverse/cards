suppressPackageStartupMessages({
  library(bench)
  library(dplyr)
  library(pkgload)
})

pkgload::load_all("/home/kpagacz/jnj/gtsummary-perf/cards")

# We can use the trial dataset from gtsummary to test
library(gtsummary)
data_big <- trial[rep(seq_len(nrow(trial)), 20), ]

cat("Benchmarking ard_summary...\n")

res <- bench::mark(
  ard_summary(
    data_big,
    variables = c(age, marker),
    by = trt
  ),
  check = FALSE,
  iterations = 10,
  filter_gc = FALSE
)
print(res)

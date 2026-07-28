suppressPackageStartupMessages({
  library(bench)
  library(dplyr)
  library(pkgload)
})

pkgload::load_all("/home/kpagacz/jnj/gtsummary-perf/cards")
library(gtsummary)
data_big <- trial[rep(seq_len(nrow(trial)), 20), ]

cat("Benchmarking ard_tabulate...\n")

res <- bench::mark(
  ard_tabulate(
    data_big,
    variables = c(grade, trt),
    by = response
  ),
  check = FALSE,
  iterations = 10,
  filter_gc = FALSE
)
print(res)

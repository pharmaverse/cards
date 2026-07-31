# Performance benchmark: main vs PR.
#
# Modeled on the gtsummary benchmark workflow
# (https://github.com/ddsjoberg/gtsummary/blob/main/.github/scripts/benchmark.R).
# Each version (the PR source and the current `main`) is installed into its own
# temporary library and benchmarked in a fully isolated R session, over several
# independent rounds. The report compares the two: the mean % change in median
# run time, a 95% CI on that change (flagging real improvements/regressions),
# and the % change in memory allocated.
library(callr)

run_benchmarks <- function(version = "main", n_rounds = 5L) {
  # This function runs in a completely isolated R session
  callr::r(
    function(version, n_rounds) {
      if (version == "pr") {
        message("--- Installing and loading PR version ---")
        tmp_lib <- file.path(tempdir(), "pr_lib")
        dir.create(tmp_lib, showWarnings = FALSE)
        .libPaths(c(tmp_lib, .libPaths()))
        pak::pkg_install("local::.", lib = tmp_lib)
      } else {
        message("--- Installing and loading main version ---")
        tmp_lib <- file.path(tempdir(), "main_lib")
        dir.create(tmp_lib, showWarnings = FALSE)
        .libPaths(c(tmp_lib, .libPaths()))
        pak::pkg_install("pharmaverse/cards", lib = tmp_lib)
      }
      library(cards, lib.loc = tmp_lib)

      pkg_version <- as.character(packageVersion("cards"))
      message("Version: ", pkg_version)
      # confirm the R build supports memory profiling (needed for bench mem_alloc)
      message("profmem capable: ", capabilities("profmem"))

      # Data setup (cards bundled datasets, so the isolated session needs only
      # cards + bench) ---------------------------------------------------------
      # core `ard_summary()` / `ard_tabulate()` benchmarks: 20x replicated ADSL
      adsl_core <- ADSL[rep(seq_len(nrow(ADSL)), 20L), ]

      # hierarchical benchmarks: 10x replicated ADAE with unique subjects, plus a
      # matching denominator, so the id-based rate path is exercised realistically
      n_rep <- 10L
      adae_big <- ADAE[rep(seq_len(nrow(ADAE)), n_rep), ]
      adae_big$USUBJID <- paste0(adae_big$USUBJID, rep(seq_len(n_rep), each = nrow(ADAE)))
      adsl_big <- ADSL[rep(seq_len(nrow(ADSL)), n_rep), ]
      adsl_big$USUBJID <- paste0(adsl_big$USUBJID, rep(seq_len(n_rep), each = nrow(ADSL)))

      # high-cardinality variable stress test for the tabulation engine
      set.seed(20260724)
      data_high_card <- data.frame(
        grp = sample(c("g1", "g2", "g3"), 2e5, replace = TRUE),
        id = sprintf("level_%05d", sample(1:5000, 2e5, replace = TRUE))
      )

      res_list <- lapply(seq_len(n_rounds), function(r) {
        message("  Round ", r)

        # core ARD functions
        core_res <- bench::mark(
          ard_summary = ard_summary(adsl_core, variables = c(AGE, BMIBL), by = ARM),
          ard_tabulate = ard_tabulate(adsl_core, variables = c(AGEGR1, SEX), by = ARM),
          iterations = 20, check = FALSE, filter_gc = FALSE
        )

        # hierarchical stacking (the shape most affected by perf work here)
        hier_res <- bench::mark(
          ard_stack_hierarchical = ard_stack_hierarchical(
            adae_big,
            variables = c(AESOC, AEDECOD), by = TRTA,
            denominator = adsl_big, id = USUBJID
          ),
          ard_stack_hierarchical_count = ard_stack_hierarchical_count(
            adae_big,
            variables = c(AESOC, AEDECOD), by = TRTA,
            denominator = adsl_big
          ),
          ard_hierarchical = ard_hierarchical(
            adae_big,
            variables = c(AESOC, AEDECOD), by = TRTA, denominator = adsl_big
          ),
          iterations = 5, check = FALSE, filter_gc = FALSE
        )

        # high-cardinality tabulation
        highcard_res <- bench::mark(
          `ard_tabulate high-card` = ard_tabulate(data_high_card, by = grp, variables = id),
          iterations = 5, check = FALSE, filter_gc = FALSE
        )

        all_res <- rbind(core_res, hier_res, highcard_res)
        data.frame(
          expression = as.character(all_res$expression),
          median_s = as.numeric(all_res$median),
          mem_bytes = as.numeric(all_res$mem_alloc),
          round = r,
          version = version,
          pkg_version = pkg_version,
          stringsAsFactors = FALSE
        )
      })

      do.call(rbind, res_list)
    },
    args = list(version = version, n_rounds = n_rounds),
    show = TRUE
  )
}

n_rounds <- as.integer(Sys.getenv("N_ROUNDS", unset = "5"))
df_pr <- run_benchmarks("pr", n_rounds)
df_main <- run_benchmarks("main", n_rounds)
df_all <- rbind(df_main, df_pr)

pr_version <- unique(df_pr$pkg_version)
main_version <- unique(df_main$pkg_version)

build_comparison <- function(rounds_df) {
  groups <- unique(rounds_df$expression)
  rows <- lapply(groups, function(g) {
    main_medians <- rounds_df$median_s[rounds_df$expression == g & rounds_df$version == "main"]
    pr_medians <- rounds_df$median_s[rounds_df$expression == g & rounds_df$version == "pr"]

    ratios <- pr_medians / main_medians
    mean_ratio <- mean(ratios)
    diff_pct <- (mean_ratio - 1) * 100

    n <- length(ratios)
    if (n > 1) {
      se <- sd(ratios) / sqrt(n)
      t_crit <- qt(0.975, df = n - 1)
      ci_lo <- (mean_ratio - t_crit * se - 1) * 100
      ci_hi <- (mean_ratio + t_crit * se - 1) * 100
    } else {
      ci_lo <- diff_pct
      ci_hi <- diff_pct
    }

    if (ci_hi < 0) {
      verdict <- paste0("\U2705 ", round(diff_pct, 1), "%")
    } else if (ci_lo > 0) {
      verdict <- paste0("\U274C +", round(diff_pct, 1), "%")
    } else {
      sign_chr <- ifelse(diff_pct >= 0, "+", "")
      verdict <- paste0("\U2796 ", sign_chr, round(diff_pct, 1), "%")
    }

    # memory allocation is deterministic, so summarize with the mean across
    # rounds (no confidence interval) and flag purely by sign. mem_alloc is NA
    # when R was built without memory profiling (e.g. the RSPM ubuntu binary used
    # on CI); in that case the columns fall back to "n/a" instead of erroring.
    main_mem <- mean(rounds_df$mem_bytes[rounds_df$expression == g & rounds_df$version == "main"], na.rm = TRUE)
    pr_mem <- mean(rounds_df$mem_bytes[rounds_df$expression == g & rounds_df$version == "pr"], na.rm = TRUE)
    mem_pct <- (pr_mem / main_mem - 1) * 100

    if (is.na(mem_pct)) {
      mem_verdict <- "n/a"
    } else if (mem_pct < -0.05) {
      mem_verdict <- paste0("\U2705 ", round(mem_pct, 1), "%")
    } else if (mem_pct > 0.05) {
      mem_verdict <- paste0("\U274C +", round(mem_pct, 1), "%")
    } else {
      mem_verdict <- paste0("\U2796 ", ifelse(mem_pct >= 0, "+", ""), round(mem_pct, 1), "%")
    }

    data.frame(
      expression = g,
      main = paste0(round(mean(main_medians) * 1000, 1), "ms"),
      pr = paste0(round(mean(pr_medians) * 1000, 1), "ms"),
      change = verdict,
      ci = paste0("[", round(ci_lo, 1), "%, ", round(ci_hi, 1), "%]"),
      `main mem` = if (is.na(main_mem)) "n/a" else format(bench::as_bench_bytes(main_mem)),
      `pr mem` = if (is.na(pr_mem)) "n/a" else format(bench::as_bench_bytes(pr_mem)),
      mem_delta = mem_verdict,
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

tab <- build_comparison(df_all)
# display label for the memory-change column (\U escapes are not allowed inside
# backtick names, so set the column name here where a string literal is fine)
names(tab)[names(tab) == "mem_delta"] <- "mem \U0394"

core_names <- c("ard_summary", "ard_tabulate")
hier_names <- c("ard_stack_hierarchical", "ard_stack_hierarchical_count", "ard_hierarchical")
highcard_names <- c("ard_tabulate high-card")

core_tab <- tab[tab$expression %in% core_names, ]
hier_tab <- tab[tab$expression %in% hier_names, ]
highcard_tab <- tab[tab$expression %in% highcard_names, ]

header <- paste0(
  "## Performance Benchmark\n\n",
  "Comparing **main** (`", main_version, "`) vs **PR** (`", pr_version, "`)\n\n",
  "Each benchmark runs ", n_rounds, " independent rounds. ",
  "The **change** column shows the mean % difference in median run time (negative = faster).\n",
  "The **95% CI** column shows the confidence interval on the change. ",
  "If the CI excludes 0%, the result is flagged as a real improvement (\U2705) or regression (\U274C); ",
  "otherwise it is inconclusive (\U2796).\n\n",
  "The **main mem** / **pr mem** columns show total memory allocated ",
  "(`bench::mark()` `mem_alloc`), and **mem \U0394** its % change (negative = less memory). ",
  "Allocation is deterministic, so no confidence interval is shown. ",
  "These columns show `n/a` when R is built without memory profiling.\n\n"
)

core_section <- paste0(
  "### Core ARD functions (20x replicated `ADSL`)\n\n",
  paste(knitr::kable(core_tab, format = "markdown", row.names = FALSE), collapse = "\n"),
  "\n\n"
)
hier_section <- paste0(
  "### Hierarchical (10x replicated `ADAE`, denominator `ADSL`)\n\n",
  paste(knitr::kable(hier_tab, format = "markdown", row.names = FALSE), collapse = "\n"),
  "\n\n"
)
highcard_section <- paste0(
  "### High-cardinality tabulation (200k rows, 5k levels)\n\n",
  paste(knitr::kable(highcard_tab, format = "markdown", row.names = FALSE), collapse = "\n"),
  "\n"
)

report <- paste0(header, core_section, hier_section, highcard_section)
writeLines(report, "bench_report.md")
cat(report)

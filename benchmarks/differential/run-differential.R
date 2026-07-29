# Differential test runner: legacy vs rewritten ard_tabulate() engine (#176) --
#
# Usage (from the package root, on the rewrite branch):
#   Rscript benchmarks/differential/run-differential.R
#
# For every case in grid.R the same call is evaluated twice — once with the
# legacy engine functions swapped into the cards namespace, once with the
# engine currently in R/ — capturing the result plus all messages, warnings,
# and errors. The gate is identical() on the full captured bundle.
#
# Cases flagged locale_sensitive get a secondary comparison that ignores row
# order (the vctrs-vs-base::order() character ordering deviation accepted for
# the rewrite); everything else must match byte-for-byte.

pkgload::load_all(".", quiet = TRUE) # NEW engine active

ENGINE_FNS <- c(
  ".calculate_tabulation_statistics", ".table_as_df",
  ".process_denominator", ".add_cum_count_stats", "arrange_using_order"
)

legacy_env <- new.env(parent = asNamespace("cards"))
sys.source(file.path("benchmarks", "differential", "legacy-engine.R"), envir = legacy_env)
source(file.path("benchmarks", "differential", "grid.R"), local = TRUE)

with_legacy_engine <- function(expr) {
  originals <- mget(ENGINE_FNS, envir = asNamespace("cards"))
  for (fn in ENGINE_FNS) utils::assignInNamespace(fn, legacy_env[[fn]], ns = "cards")
  on.exit(for (fn in ENGINE_FNS) utils::assignInNamespace(fn, originals[[fn]], ns = "cards"), add = TRUE)
  force(expr)
}

capture_all <- function(expr, envir) {
  msgs <- character()
  warns <- character()
  res <- tryCatch(
    withCallingHandlers(
      eval(expr, envir = envir),
      message = function(m) {
        msgs <<- c(msgs, conditionMessage(m))
        invokeRestart("muffleMessage")
      },
      warning = function(w) {
        warns <<- c(warns, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      structure(
        list(msg = conditionMessage(e), cls = class(e)),
        class = "captured_error"
      )
    }
  )
  list(result = res, messages = msgs, warnings = warns)
}

# Functions (e.g. the default fmt_fun label_round() closures) are recreated on
# every call, and identical() treats distinct closure environments as unequal.
# Replace each function with a value representation: signature + body +
# captured environment values. Real differences (say digits = 1 vs 2 captured
# by label_round()) still surface; environment identity does not.
normalize_fn <- function(f) {
  e <- environment(f)
  vars <- NULL
  if (!is.null(e) && !identical(e, globalenv()) && environmentName(e) == "") {
    lst <- tryCatch(as.list(e, all.names = TRUE), error = function(err) NULL)
    if (!is.null(lst) && length(lst)) {
      lst <- lst[order(names(lst))]
      vars <- lapply(lst, function(v) {
        if (is.function(v)) paste(deparse(v), collapse = "\n") else v
      })
    }
  }
  list(
    "__fn__",
    paste(deparse(args(f)), collapse = "\n"),
    paste(deparse(body(f)), collapse = "\n"),
    vars
  )
}

normalize_fns <- function(x) {
  if (inherits(x, "captured_error")) {
    return(x)
  }
  if (is.function(x)) {
    return(normalize_fn(x))
  }
  if (is.data.frame(x)) {
    for (col in names(x)) {
      if (is.list(x[[col]])) x[[col]] <- lapply(x[[col]], normalize_fns)
    }
    return(x)
  }
  if (is.list(x)) {
    return(lapply(x, normalize_fns))
  }
  x
}

normalize_bundle <- function(bundle) {
  bundle$result <- normalize_fns(bundle$result)
  bundle
}

# order-insensitive view for the locale-sensitive secondary gate
canonicalize_rows <- function(x) {
  if (!is.data.frame(x)) {
    return(x)
  }
  flat <- vapply(
    seq_len(nrow(x)),
    function(i) {
      paste(
        vapply(
          x[i, , drop = FALSE],
          function(col) paste(format(col[[1]]), collapse = "\r"),
          character(1)
        ),
        collapse = "\v"
      )
    },
    character(1)
  )
  x[order(flat), , drop = FALSE] |> `rownames<-`(NULL)
}

compare_bundles <- function(old, new, locale_sensitive = FALSE, expect_fix = FALSE) {
  old <- normalize_bundle(old)
  new <- normalize_bundle(new)
  if (identical(old, new)) {
    return(list(status = "identical"))
  }
  if (expect_fix &&
    inherits(old$result, "captured_error") &&
    !inherits(new$result, "captured_error")) {
    return(list(status = "fixed-crash"))
  }
  if (locale_sensitive &&
    identical(old[c("messages", "warnings")], new[c("messages", "warnings")]) &&
    identical(canonicalize_rows(old$result), canonicalize_rows(new$result))) {
    return(list(status = "identical-after-reorder"))
  }
  list(
    status = "DIFF",
    diff = waldo::compare(old, new, x_arg = "legacy", y_arg = "new", max_diffs = 25)
  )
}

run_grid <- function() {
  eval_env <- new.env(parent = globalenv())
  eval_env$ADSL <- cards::ADSL
  eval_env$ADAE <- cards::ADAE
  build_case_data(eval_env)

  cases <- build_case_grid()
  cat(sprintf("Running %d differential cases...\n", length(cases)))

  results <- lapply(cases, function(case) {
    old <- with_legacy_engine(capture_all(case$call, eval_env))
    new <- capture_all(case$call, eval_env)
    cmp <- compare_bundles(
      old, new,
      locale_sensitive = isTRUE(case$locale_sensitive),
      expect_fix = isTRUE(case$expect_fix)
    )
    if (cmp$status == "DIFF") {
      cat("\n== DIFF:", case$name, "==\n")
      cat(deparse(case$call), sep = "\n")
      print(cmp$diff)
    }
    list(name = case$name, status = cmp$status)
  })

  status <- vapply(results, `[[`, character(1), "status")
  cat("\n---- Summary ----\n")
  print(table(status))
  if (any(status == "DIFF")) {
    cat("\nFailing cases:\n")
    cat(paste("  -", vapply(results[status == "DIFF"], `[[`, character(1), "name")), sep = "\n")
    quit(status = 1L, save = "no")
  }
  cat("\nAll cases match.\n")
  invisible(results)
}

if (sys.nframe() == 0L) {
  run_grid()
}

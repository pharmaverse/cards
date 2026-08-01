# Differential test runner: legacy vs rewritten sort_ard_hierarchical() /
# filter_ard_hierarchical() (#176) --------------------------------------------
#
# Usage (from the package root, on the rewrite branch):
#   Rscript benchmarks/differential/run-differential-sort-filter.R
#
# For every case in grid-sort-filter.R the same call is evaluated twice — once
# with the legacy sort/filter functions swapped into the cards namespace, once
# with the functions currently in R/ — capturing the result plus all messages,
# warnings, and errors. The gate is identical() on the full captured bundle.

pkgload::load_all(".", quiet = TRUE) # NEW functions active

# The two exported entry points are SHADOWED directly in the evaluation env for
# each arm (see run_arm() below) rather than swapped via assignInNamespace().
# assignInNamespace() only updates the internal namespace binding, but a
# top-level call (`filter_ard_hierarchical(...)` from a globalenv-parented env,
# as here) resolves against the attached `package:cards` copy, which it does NOT
# update - so a namespace swap would silently compare NEW vs NEW. Each function's
# internal helper calls still resolve through its own closure (legacy_env for the
# legacy copy, the cards namespace for the new one), so shadowing the entry point
# is sufficient and correct.
SF_FNS <- c("sort_ard_hierarchical", "filter_ard_hierarchical")

legacy_env <- new.env(parent = asNamespace("cards"))
sys.source(file.path("benchmarks", "differential", "legacy-sort-filter.R"), envir = legacy_env)
new_fns <- stats::setNames(lapply(SF_FNS, getFromNamespace, "cards"), SF_FNS)
legacy_fns <- stats::setNames(lapply(SF_FNS, function(fn) legacy_env[[fn]]), SF_FNS)
source(file.path("benchmarks", "differential", "grid-sort-filter.R"), local = TRUE)

# evaluate `case$call` with the given implementations shadowing the exports
run_arm <- function(fns, expr, data_env) {
  ev <- new.env(parent = data_env)
  for (fn in names(fns)) assign(fn, fns[[fn]], envir = ev)
  capture_all(expr, ev)
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

# Default fmt_fun label closures are recreated per call; identical() treats
# distinct closure environments as unequal. Replace each function with a value
# representation (signature + body + captured environment values) so real
# differences still surface while environment identity does not.
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

compare_bundles <- function(old, new) {
  old <- normalize_bundle(old)
  new <- normalize_bundle(new)
  if (identical(old, new)) {
    return(list(status = "identical"))
  }
  list(
    status = "DIFF",
    diff = waldo::compare(old, new, x_arg = "legacy", y_arg = "new", max_diffs = 25)
  )
}

run_grid <- function() {
  eval_env <- new.env(parent = globalenv())
  build_sf_data(eval_env)

  cases <- build_sf_case_grid()
  cat(sprintf("Running %d differential cases...\n", length(cases)))

  results <- lapply(cases, function(case) {
    old <- run_arm(legacy_fns, case$call, eval_env)
    new <- run_arm(new_fns, case$call, eval_env)
    cmp <- compare_bundles(old, new)
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

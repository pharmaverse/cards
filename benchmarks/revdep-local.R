# Local reverse-dependency check for the ard_tabulate() engine rewrite (#176) -
#
# Runs the test suites of the key revdeps (gtsummary, cardx, crane) twice:
# against cards from the *current branch* and against cards from *main*.
# The decisive signal is zero NEW failures/snapshot diffs on the branch
# relative to main (pre-existing failures are filtered by the diff).
#
# Usage (from the package root, on the rewrite branch; takes a while):
#   Rscript benchmarks/revdep-local.R
#
# Requires: pak, callr, gert, testthat (and each revdep's dev dependencies,
# which are installed into the throwaway libraries automatically).

revdeps <- c(
  "ddsjoberg/gtsummary",
  "insightsengineering/cardx",
  "insightsengineering/crane"
)

work_dir <- file.path(tempdir(), "cards-revdep")
dir.create(work_dir, showWarnings = FALSE, recursive = TRUE)
lib_new <- file.path(work_dir, "lib-cards-branch")
lib_old <- file.path(work_dir, "lib-cards-main")
for (lib in c(lib_new, lib_old)) dir.create(lib, showWarnings = FALSE)

cat("Installing branch cards into", lib_new, "\n")
pak::pkg_install("local::.", lib = lib_new, ask = FALSE)
cat("Installing main cards into", lib_old, "\n")
pak::pkg_install("insightsengineering/cards@main", lib = lib_old, ask = FALSE)

run_suite <- function(src, lib) {
  callr::r(
    function(src, lib) {
      .libPaths(c(lib, .libPaths()))
      pak::local_install_dev_deps(src, ask = FALSE, dependencies = TRUE)
      res <- testthat::test_local(src, stop_on_failure = FALSE, reporter = "silent")
      df <- as.data.frame(res)
      df[c("file", "test", "failed", "warning", "skipped", "passed")]
    },
    args = list(src = src, lib = lib),
    show = TRUE
  )
}

summaries <- list()
for (repo in revdeps) {
  pkg <- basename(repo)
  src <- file.path(work_dir, pkg)
  if (!dir.exists(src)) {
    cat("Cloning", repo, "\n")
    gert::git_clone(paste0("https://github.com/", repo), path = src)
  }

  cat("\n==== ", pkg, ": testing against MAIN cards ====\n")
  res_old <- run_suite(src, lib_old)
  cat("\n==== ", pkg, ": testing against BRANCH cards ====\n")
  res_new <- run_suite(src, lib_new)

  saveRDS(res_old, file.path(work_dir, paste0(pkg, "-main.rds")))
  saveRDS(res_new, file.path(work_dir, paste0(pkg, "-branch.rds")))

  merged <- merge(
    stats::aggregate(failed ~ file, data = res_old, FUN = sum),
    stats::aggregate(failed ~ file, data = res_new, FUN = sum),
    by = "file", suffixes = c("_main", "_branch"), all = TRUE
  )
  merged[is.na(merged)] <- 0L
  regressions <- merged[merged$failed_branch > merged$failed_main, ]

  summaries[[pkg]] <- list(
    total_main = sum(res_old$failed),
    total_branch = sum(res_new$failed),
    regressions = regressions
  )
}

cat("\n\n================ SUMMARY ================\n")
ok <- TRUE
for (pkg in names(summaries)) {
  s <- summaries[[pkg]]
  cat(sprintf(
    "%s: failures main=%d, branch=%d, files with NEW failures=%d\n",
    pkg, s$total_main, s$total_branch, nrow(s$regressions)
  ))
  if (nrow(s$regressions) > 0) {
    ok <- FALSE
    print(s$regressions)
  }
}
if (!ok) {
  cat("\nNEW failures detected relative to main - investigate before merging.\n")
  quit(status = 1L, save = "no")
}
cat("\nNo new failures relative to main.\n")

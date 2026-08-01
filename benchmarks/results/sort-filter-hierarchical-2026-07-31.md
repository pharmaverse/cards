# `sort_ard_hierarchical()` / `filter_ard_hierarchical()` performance rewrite (#176)

Legacy (the implementations on `main`) vs. new (this branch), measured on the
same stacked hierarchical ARD in one R 4.6.1 session. Legacy and new were run
back-to-back (functions shadowed into the eval env, not swapped via
`assignInNamespace()`, which does not affect top-level lookups) so the numbers
are directly comparable. Timing via `system.time()` (median of repeated calls);
memory via a single `bench::mark()` `mem_alloc`. Correctness is verified
separately by `benchmarks/differential/run-differential-sort-filter.R`
(55/55 cases byte-identical).

## Test data

`ard_stack_hierarchical(variables = c(AESOC, AEDECOD), by = TRTA, id, denominator)`
over 200,000 simulated AE rows: 150 SOCs × 60 AEs × 3 arms.

- 82,359-row ARD (`overall = FALSE`)
- 109,809-row ARD (`overall = TRUE`, used for the `n_overall` case so the legacy
  per-group overall join is exercised)

## Time

| call | legacy | new | speedup |
|------|-------:|----:|--------:|
| `sort_ard_hierarchical(ard)` | 1.36 s | 0.49 s | 2.8× |
| `filter_ard_hierarchical(ard, n > 2)` | 5.71 s | 1.48 s | 3.9× |
| `filter_ard_hierarchical(ard, n_1 > 2)` | 119.9 s | 1.42 s | ~84× |
| `filter_ard_hierarchical(ard, p > 0.05, var = AESOC)` | 5.06 s | 0.34 s | 14.9× |
| `filter_ard_hierarchical(ard_overall, n_overall > 2)` | 143.6 s | 1.70 s | 84.5× |

## Memory (`mem_alloc`)

| call | legacy | new |
|------|-------:|----:|
| `sort_ard_hierarchical(ard)` | 137 MB | 62 MB |
| `filter_ard_hierarchical(ard, n > 2)` | 148 MB | 93 MB |

## Where the time went

- **`sort`** — the per-level grouped `dplyr::summarize()` + `left_join()`
  (`.append_hierarchy_sums()`), the repeated n/p-availability check, and the
  whole-frame sub-assignments in `.ard_reformat_sort()` were replaced with
  `vctrs::vec_group_id()`/`vec_group_loc()` group sums, one hoisted check, and
  column-level assignments. Because `ard_stack_hierarchical()` sorts on
  construction, this also speeds up ARD construction.
- **`n_1` (column statistics)** — the legacy code ran a `tidyr::pivot_wider()`
  per variable group (~9,000 groups) to build `n_1`, `p_2`, … . The rewrite
  builds those values directly from the reshaped ARD, eliminating the pivots.
- **`n_overall` with `overall = TRUE`** — the legacy code did a per-group
  `rename_ard_groups_shift()` + `left_join()` against the overall data. The
  rewrite resolves every group's overall statistic in one `vctrs::vec_match()`.
- **`n > 2`, `var = AESOC`** — the group loop, the "overall" row detection (now
  short-circuited so the costly list columns are scanned only for
  not-yet-matched rows), and the empty-section pruning were converted to
  `vctrs`-based set operations.

Results are unchanged in every case.

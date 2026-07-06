# Detect Columns with Non-Null Contents

Function looks for non-null contents in requested columns and notifies
user before removal. Specifically used for detecting messages.

## Usage

``` r
.detect_msgs(x, ...)
```

## Arguments

- x:

  (`data.frame`)\
  a data frame

- ...:

  ([`dynamic-dots`](https://rlang.r-lib.org/reference/dyn-dots.html))\
  columns to search within

## Examples

``` r
ard <- ard_summary(
  ADSL,
  by = ARM,
  variables = AGE,
  statistic = ~ list(
    mean = \(x) mean(x),
    mean_warning = \(x) {
      warning("warn1")
      warning("warn2")
      mean(x)
    },
    err_fn = \(x) stop("'tis an error")
  )
)

cards:::.detect_msgs(ard, "warning", "error")
#> "warning" column contains messages that will be removed.
#> "error" column contains messages that will be removed.
#> [[1]]
#> NULL
#> 
#> [[2]]
#> NULL
#> 
```

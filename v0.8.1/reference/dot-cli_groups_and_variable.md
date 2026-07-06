# Locate Condition Messages in an ARD

Prints a string of all `group##`/`group##_level` column values and
`variable` column values where condition messages occur, formatted using
glue syntax.

## Usage

``` r
.cli_groups_and_variable(x)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

## Value

a string

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

cards:::.cli_groups_and_variable(ard)
#> [1] "c(\"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\", \"{.code ARM = {.val {\\\"Placebo\\\"}}}\"), c(\"{.var AGE}\", \"{.var AGE}\", \"{.var AGE}\", \"{.var AGE}\", \"{.var AGE}\", \"{.var AGE}\", \"{.var AGE}\", \"{.var AGE}\", \"{.var AGE}\")"
```

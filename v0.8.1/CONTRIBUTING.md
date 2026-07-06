# Contributing to cards

This outlines how to propose a change to {cards}.

## Fixing typos

You can fix typos, spelling mistakes, or grammatical errors in the
documentation directly using the GitHub web interface, as long as the
changes are made in the *source* file. This generally means you’ll need
to edit [roxygen2
comments](https://roxygen2.r-lib.org/articles/roxygen2.html) in an `.R`,
not a `.Rd` file. You can find the `.R` file that generates the `.Rd` by
reading the comment in the first line.

## Bigger changes

If you want to make a bigger change, it’s a good idea to first file an
issue and make sure someone from the team agrees that it’s needed. If
you’ve found a bug, please file an issue that illustrates the bug with a
minimal [reprex](https://www.tidyverse.org/help/#reprex) (this will also
help you write a unit test, if needed). See guide on [how to create a
great issue](https://code-review.tidyverse.org/issues/) for more advice.

### Pull request process

- Fork the package and clone onto your computer.

- Install all development dependencies with
  [`devtools::install_dev_deps()`](https://devtools.r-lib.org/reference/install_deps.html),
  and then make sure the package passes R CMD check by running
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html).
  If R CMD check doesn’t pass cleanly, it’s a good idea to ask for help
  before continuing.

- Create a Git branch for your pull request (PR).

- Make your changes, commit to git, and then create a PR. The title of
  your PR should briefly describe the change. The body of your PR should
  contain `Closes #issue-number`.

- For user-facing changes, add a bullet to the top of `NEWS.md`
  (i.e. just below the first header). Follow the style described in
  <https://style.tidyverse.org/news.html>.

- Note for your first contribution you will need to accept the
  [Individual Contributor License
  Agreement](https://github.com/insightsengineering/.github/blob/main/CLA.md).
  To do so please leave a comment stating “I have read the CLA Document
  and I hereby sign the CLA” on the Pull Request.

### Code Style

- New code should follow the tidyverse [style
  guide](https://style.tidyverse.org). You can use the
  [styler](https://CRAN.R-project.org/package=styler) package to apply
  these styles, but please don’t restyle code that has nothing to do
  with your PR.

  - To apply the appropriate style with styler please use
    `styler:::style_active_pkg()`

- We use [roxygen2](https://cran.r-project.org/package=roxygen2), with
  [Markdown
  syntax](https://cran.r-project.org/web/packages/roxygen2/vignettes/rd-formatting.html),
  for documentation.

- We use [testthat](https://cran.r-project.org/package=testthat) for
  unit tests. Contributions with test cases included are easier to
  accept.

- All helper/non-exported function are named with a period prefix,
  e.g. `.helper_function()`.

- All helper/non-exported functions are documented with roxygen2 as
  indicated above. Include `#' @keywords internal` to mark the function
  as internal. Any helper functions that appear in examples, will need
  to use the `cards:::` prefix,
  e.g. `#' @example cards:::.helper_function()`

### Error Handling

We use the {cli} package to signal errors, warnings, and messages to
users. For each call to
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
the `call` argument must be used to correctly message to users the
calling function. Any general function that can be re-used to check, for
example, user-passed argument values, shall be placed in
`R\import-standalone-checks.R`. The checks in this file are re-used
among multiple projects. If you do need to modify this file, please
review the section below about standalone scripts.

### Package Dependencies

Generally, no additional package dependencies may be added. If the code
you add would be more readable using, for example, using a {tidyverse}
function, consider adding a shim for the function in one of the
standalone scripts. See the section below about standalone scripts for
details.

### Standalone Scripts

The package utilizes a few standalone scripts that are used across a few
projects. Some of these scripts make available shims for common
tidyverse functions, so you can use the function without depending on
the package. The `"checks"` script is a series of functions to check the
argument values supplied by users, and provides informative error
messages when the values are not valid. Do not make changes to these
files directly: rather, update these files in their source location.

- `import-standalone-purrr.R`:
  <https://github.com/r-lib/rlang/blob/main/R/standalone-purrr.R>
- `import-standalone-forcats.R`
  <https://github.com/insightsengineering/standalone/blob/main/R/standalone-forcats.R>
- `import-standalone-stringr.R`
  <https://github.com/insightsengineering/standalone/blob/main/R/standalone-stringr.R>
- `import-standalone-checks.R`
  <https://github.com/insightsengineering/standalone/blob/main/R/standalone-checks.R>

After the update has been made, you can copy the file into the repo with

``` r

usethis::use_standalone("r-lib/rlang", file = "purrr")
usethis::use_standalone("insightsengineering/standalone", file = "forcats")
usethis::use_standalone("insightsengineering/standalone", file = "stringr")
usethis::use_standalone("insightsengineering/standalone", file = "checks")
```

## Scope

The {cards} package exports basic functions for creating ARDs (such as,
univariate continuous summaries, tabulations, etc.), and utilities for
creating/working with ARDs. All new functions to create ARDs will live
in the [{cardx}](https://github.com/insightsengineering/cardx) package.

## Deprecation Cycle

In the {cards} package we soft deprecate for 6 months, then warn for an
additional 6 months, then defunct for 6 more months for a total of 18
months.

## Code of Conduct

Please note that the cards project is released with a [Contributor Code
of
Conduct](https://insightsengineering.github.io/cards/CODE_OF_CONDUCT.md).
By contributing to this project you agree to abide by its terms.

# Selecting Syntax

Selecting Syntax

## Selectors

The cards package also utilizes selectors: selectors from the tidyselect
package and custom selectors. Review their help files for details.

- **tidy selectors**

  [`everything()`](https://tidyselect.r-lib.org/reference/everything.html),
  [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html),
  [`any_of()`](https://tidyselect.r-lib.org/reference/all_of.html),
  [`starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html),
  [`ends_with()`](https://tidyselect.r-lib.org/reference/starts_with.html),
  [`contains()`](https://tidyselect.r-lib.org/reference/starts_with.html),
  [`matches()`](https://tidyselect.r-lib.org/reference/starts_with.html),
  [`num_range()`](https://tidyselect.r-lib.org/reference/starts_with.html),
  [`last_col()`](https://tidyselect.r-lib.org/reference/everything.html)

- **cards selectors**

  [`all_ard_groups()`](https://insightsengineering.github.io/cards/reference/selectors.md),
  [`all_ard_variables()`](https://insightsengineering.github.io/cards/reference/selectors.md)

## Formula and List Selectors

Some arguments in the cards package accept list and formula notation,
e.g. `ard_summary(statistic=)`. Below enumerates a few tips and
shortcuts for using the list and formulas.

1.  **List of Formulas**

    Typical usage includes a list of formulas, where the LHS is a
    variable name or a selector.

        ard_summary(statistic = list(age ~ list(N = \(x) length(x)), starts_with("a") ~ list(mean = mean)))

2.  **Named List**

    You may also pass a named list; however, the tidyselect selectors
    are not supported with this syntax.

        ard_summary(statistic = list(age = list(N = \(x) length(x))))

3.  **Hybrid Named List/List of Formulas**

    You can pass a combination of formulas and named elements.

        ard_summary(statistic = list(age = list(N = \(x) length(x)), starts_with("a") ~ list(mean = mean)))

4.  **Shortcuts**

    You can pass a single formula, which is equivalent to passing the
    formula in a list.

        ard_summary(statistic = starts_with("a") ~ list(mean = mean)

    As a shortcut to select all variables, you can omit the LHS of the
    formula. The two calls below are equivalent.

        ard_summary(statistic = ~list(N = \(x) length(x)))
        ard_summary(statistic = everything() ~ list(N = \(x) length(x)))

5.  **Combination Selectors**

    Selectors can be combined using the
    [`c()`](https://rdrr.io/r/base/c.html) function.

        ard_summary(statistic = c(everything(), -age) ~ list(N = \(x) length(x)))

# Getting Started

Suppose you need to create the table below, and need an ARD
representation of the results to get started. Here, we will review an
examples for creating a basic demographics table.

To get started, load the **{cards}** package.

``` r

library(cards)
```

### Demographics

[TABLE]

The table above has three types of data summaries: a **continuous**
variable summary for `AGE`, a **categorical** variable summary for
`AGEGR1`, and a **dichotomous** variable summary for `SEX`.

#### Continuous Summaries

To get a continuous variable summary, we will use the
[`ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md)
function from the **{cards}** package.

``` r

df_continuous_ard <-
  ard_summary(
    ADSL,
    by = ARM,
    variables = AGE,
    statistic = ~ continuous_summary_fns(c(
      "median",
      "p25",
      "p75",
      "mean",
      "sd",
      "min",
      "max"
    ))
  )
df_continuous_ard |> head(5)
#> {cards} data frame: 5 x 10
#>   group1 group1_level variable stat_name stat_label   stat
#> 1    ARM      Placebo      AGE    median     Median     76
#> 2    ARM      Placebo      AGE       p25         Q1     69
#> 3    ARM      Placebo      AGE       p75         Q3     82
#> 4    ARM      Placebo      AGE      mean       Mean 75.209
#> 5    ARM      Placebo      AGE        sd         SD   8.59
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

#### Categorical Summaries

To get the categorical variable summary, we will use the
[`ard_tabulate()`](https://insightsengineering.github.io/cards/reference/ard_tabulate.md)
function.

``` r

df_categorical_ard <-
  ard_tabulate(
    ADSL,
    by = ARM,
    variables = AGEGR1
  )
df_categorical_ard |> head(5)
#> {cards} data frame: 5 x 11
#>   group1 group1_level variable variable_level stat_name stat_label  stat
#> 1    ARM      Placebo   AGEGR1            <65         n          n    14
#> 2    ARM      Placebo   AGEGR1            <65         N          N    86
#> 3    ARM      Placebo   AGEGR1            <65         p          % 0.163
#> 4    ARM      Placebo   AGEGR1            >80         n          n    30
#> 5    ARM      Placebo   AGEGR1            >80         N          N    86
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

#### Dichotomous Summaries

To get the dichotomous variable summary, we will use
[`ard_tabulate_value()`](https://insightsengineering.github.io/cards/reference/ard_tabulate_value.md).
In this case, we want to show the Female (`"F"`) level of the `SEX`
variable and specify this with the `values` argument.

``` r

df_dichotomous_ard <-
  ard_tabulate_value(
    ADSL,
    by = ARM,
    variables = SEX,
    value = list(SEX = "F")
  )
df_dichotomous_ard |> head(5)
#> {cards} data frame: 5 x 11
#>   group1 group1_level variable variable_level stat_name stat_label  stat
#> 1    ARM      Placebo      SEX              F         n          n    53
#> 2    ARM      Placebo      SEX              F         N          N    86
#> 3    ARM      Placebo      SEX              F         p          % 0.616
#> 4    ARM    Xanomeli…      SEX              F         n          n    40
#> 5    ARM    Xanomeli…      SEX              F         N          N    84
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

#### Combine Results

As a last step, you can combine all of these objects into a single
object using
[`bind_ard()`](https://insightsengineering.github.io/cards/reference/bind_ard.md),
which is similar to
[`dplyr::bind_rows()`](https://dplyr.tidyverse.org/reference/bind_rows.html)
and includes additional structural checks for our results.

``` r

bind_ard(
  df_continuous_ard,
  df_categorical_ard,
  df_dichotomous_ard
)
#> {cards} data frame: 57 x 11
#>    group1 group1_level variable variable_level stat_name stat_label   stat
#> 1     ARM      Placebo      AGE                   median     Median     76
#> 2     ARM      Placebo      AGE                      p25         Q1     69
#> 3     ARM      Placebo      AGE                      p75         Q3     82
#> 4     ARM      Placebo      AGE                     mean       Mean 75.209
#> 5     ARM      Placebo      AGE                       sd         SD   8.59
#> 6     ARM      Placebo      AGE                      min        Min     52
#> 7     ARM      Placebo      AGE                      max        Max     89
#> 8     ARM    Xanomeli…      AGE                   median     Median     76
#> 9     ARM    Xanomeli…      AGE                      p25         Q1   70.5
#> 10    ARM    Xanomeli…      AGE                      p75         Q3     80
#> ℹ 47 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

#### Shortcut

The
[`ard_stack()`](https://insightsengineering.github.io/cards/reference/ard_stack.md)
function provides a shortcut to perform the calculations above in a
single step.

In the example below, the `data` and `.by` arguments are passed to each
subsequent `ard_*()` function call. Moreover, this will also return the
univariate tabulation of the `.by` variable, which would be used to add
counts to the header row of the table.

``` r

ard_stack(
  data = ADSL,
  .by = ARM,
  ard_summary(
    variables = AGE,
    statistic = ~ continuous_summary_fns(c(
      "median",
      "p25",
      "p75",
      "mean",
      "sd",
      "min",
      "max"
    ))
  ),
  ard_tabulate(variables = AGEGR1),
  ard_tabulate_value(variables = SEX, value = list(SEX = "F"))
)
#> {cards} data frame: 66 x 11
#>    group1 group1_level variable variable_level stat_name stat_label   stat
#> 1     ARM      Placebo      AGE                   median     Median     76
#> 2     ARM      Placebo      AGE                      p25         Q1     69
#> 3     ARM      Placebo      AGE                      p75         Q3     82
#> 4     ARM      Placebo      AGE                     mean       Mean 75.209
#> 5     ARM      Placebo      AGE                       sd         SD   8.59
#> 6     ARM      Placebo      AGE                      min        Min     52
#> 7     ARM      Placebo      AGE                      max        Max     89
#> 8     ARM      Placebo   AGEGR1            <65         n          n     14
#> 9     ARM      Placebo   AGEGR1            <65         N          N     86
#> 10    ARM      Placebo   AGEGR1            <65         p          %  0.163
#> ℹ 56 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

### Adverse Events

Next, we will review several examples for creating basic adverse events
(AE) tables. We will skip to examples utilizing the shortcut functions
[`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
and
[`ard_stack_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md).
These functions utilize multiple calls to
[`ard_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_hierarchical.md)
and
[`ard_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_hierarchical.md)
to calculate the needed summary statistics.

For the computations below, we will not only make use of a subset of the
`ADAE` dataset. We will also rely on `ADSL` for the full study
population, which is used as the denominator in the rate calculations.

To match the treatment arm variables, we need to do a small data
manipulation on the naming of the treatment variable.

``` r

# rename trt variable
adsl <- ADSL

# subset to Treatment emergent AES
adae <- ADAE |>
  # keep the most reported AEs for a smaller table
  dplyr::filter(.by = AETERM, dplyr::n() > 25, TRTEMFL == "Y")
```

#### Participant-level summaries

A common type of AE table contains participant-level summaries. Here, we
are reporting the number and percentage of subjects with at least one AE
by system organ class and preferred term.

[TABLE]

The
[`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
function provides a shortcut to perform the calculations needed for the
summary table in a single step.

In the example below, the `data` and `by` arguments are passed to each
subsequent calculation. The function utilizes `USUBJID` (passed to the
`id` argument) as the subject identifier for participant-level
calculations, and `ADSL` is used to define the denominator. With
`variables = c(AEBODSYS, AEDECOD)`, the function returns rates of
adverse events by `AEDECOD` nested within `AESOC` as well as by `AESOC`.
With `over_variables = TRUE`, the function also returns rates of any
adverse event across all system organ classes and preferred terms.

``` r

ard_stack_hierarchical(
  data = adae,
  by = TRTA,
  variables = c(AEBODSYS, AEDECOD),
  denominator = adsl,
  id = USUBJID,
  over_variables = TRUE
)
#> {cards} data frame: 117 x 13
#>    group1 group1_level group2 group2_level                     variable
#> 1    <NA>                <NA>                                      TRTA
#> 2    <NA>                <NA>                                      TRTA
#> 3    <NA>                <NA>                                      TRTA
#> 4    <NA>                <NA>                                      TRTA
#> 5    <NA>                <NA>                                      TRTA
#> 6    <NA>                <NA>                                      TRTA
#> 7    <NA>                <NA>                                      TRTA
#> 8    <NA>                <NA>                                      TRTA
#> 9    <NA>                <NA>                                      TRTA
#> 10   TRTA      Placebo   <NA>              ..ard_hierarchical_overall..
#>    variable_level stat_name stat_label  stat
#> 1         Placebo         n          n    86
#> 2         Placebo         N          N   254
#> 3         Placebo         p          % 0.339
#> 4       Xanomeli…         n          n    84
#> 5       Xanomeli…         N          N   254
#> 6       Xanomeli…         p          % 0.331
#> 7       Xanomeli…         n          n    84
#> 8       Xanomeli…         N          N   254
#> 9       Xanomeli…         p          % 0.331
#> 10           TRUE         n          n    30
#> ℹ 107 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

#### Event-level Summaries

In addition to participant-level summaries, event-level summaries are
often needed. For these types of tables, we report total counts of AEs ,
and therefore we can use the `ADAE` data directly. We will need to count
AEs overall, by system organ class, and by preferred term (within system
organ class).

[TABLE]

The
[`ard_stack_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
function provides a shortcut to perform the calculations needed for the
summary table in a single step.

In the example below, the `data` and `by` arguments are passed to each
subsequent calculation. With `variables = c(AEBODSYS, AEDECOD)`, the
function returns counts of adverse events by `AEDECOD` nested within
`AESOC` as well as by `AESOC`. With `over_variables = TRUE`, the
function also returns counts of any adverse event across all system
organ classes and preferred terms.

``` r

ard_stack_hierarchical_count(
  data = adae,
  by = TRTA,
  variables = c(AEBODSYS, AETERM),
  over_variables = TRUE
)
#> {cards} data frame: 36 x 13
#>    group1 group1_level   group2 group2_level                     variable
#> 1    TRTA      Placebo     <NA>              ..ard_hierarchical_overall..
#> 2    TRTA    Xanomeli…     <NA>              ..ard_hierarchical_overall..
#> 3    TRTA    Xanomeli…     <NA>              ..ard_hierarchical_overall..
#> 4    TRTA      Placebo     <NA>                                  AEBODSYS
#> 5    TRTA    Xanomeli…     <NA>                                  AEBODSYS
#> 6    TRTA    Xanomeli…     <NA>                                  AEBODSYS
#> 7    TRTA      Placebo AEBODSYS    GENERAL …                       AETERM
#> 8    TRTA    Xanomeli… AEBODSYS    GENERAL …                       AETERM
#> 9    TRTA    Xanomeli… AEBODSYS    GENERAL …                       AETERM
#> 10   TRTA      Placebo AEBODSYS    GENERAL …                       AETERM
#>    variable_level stat_name stat_label stat
#> 1            TRUE         n          n   64
#> 2            TRUE         n          n  176
#> 3            TRUE         n          n  169
#> 4       GENERAL …         n          n   29
#> 5       GENERAL …         n          n   86
#> 6       GENERAL …         n          n   85
#> 7       APPLICAT…         n          n    9
#> 8       APPLICAT…         n          n   12
#> 9       APPLICAT…         n          n   15
#> 10      APPLICAT…         n          n    3
#> ℹ 26 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

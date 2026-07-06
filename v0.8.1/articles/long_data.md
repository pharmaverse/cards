# Long Data Summaries

``` r

library(cards)
library(dplyr)
```

The goal of this article is to illustrate which {cards} functions are
used to create long data summaries: think summaries from ADAE, ADLB,
ADCM, and other similarly structured data sets.

Generally, the solution to long data summaries lies with
`ard_stack_hierarchical*()`,
[`ard_strata()`](https://insightsengineering.github.io/cards/reference/ard_strata.md),
or even a call to a more basic function like
[`ard_tabulate()`](https://insightsengineering.github.io/cards/reference/ard_tabulate.md).
Herein, we will review these function and when each is needed.

## Hierarchical or Nested Summaries

The `ard_stack_hierarchical*()` family of functions are useful when
tabulating hierarchical or nested data **and** the tabulation needs to
be repeated across more than one of the hierarchies. The most common
example is the summary of adverse event (AE) data.

[TABLE]

In the table above, the AE *rates* are reported for both the system
organ class (SOC) and AE term. That is, each AE is counted once per
subject and then rate for each AE calculated; this is repeated for SOC.
A call to the
[`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
function will return an ARD with the adverse event rates, the system
organ class rates, the overall rates (row one from the example table),
and the counts that appear in the header.

To create the ARD for this table, use the
[`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
function.

``` r

ard_ae <-
  ADAE |>
  ard_stack_hierarchical(
    variables = c(AESOC, AEDECOD), # report rates for SOC and AE within SOC
    by = TRTA, # report all statistics by treatment
    id = USUBJID, # used to remove duplicate AEs within subject
    denominator = ADSL, # specified the denominator for rate calculations
    over_variables = TRUE # include summary statistics for Any AE
  )
```

The returned ARD contains *four stacked sections*: AE rates, SOC rates,
Any AE rates, and Treatment counts. Let’s inspect each of these four
sections.

**Adverse Event Rates**

To calculate the AE event counts, the `ADAE` data frame is subset to
remove duplicate AEs reported from each subject. From there, the rates
are calculated using the `ADSL` data frame passed in the `denominator`
argument.

``` r

ard_ae |>
  filter(variable == "AEDECOD")
#> {cards} data frame: 2178 x 13
#>    group1 group1_level group2 group2_level variable variable_level stat_name stat_label  stat
#> 1    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n          n     1
#> 2    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         N          N    86
#> 3    TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         p          % 0.012
#> 4    TRTA    Xanomeli…  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n          n     3
#> 5    TRTA    Xanomeli…  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         N          N    84
#> 6    TRTA    Xanomeli…  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         p          % 0.036
#> 7    TRTA    Xanomeli…  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n          n     1
#> 8    TRTA    Xanomeli…  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         N          N    84
#> 9    TRTA    Xanomeli…  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         p          % 0.012
#> 10   TRTA      Placebo  AESOC    CARDIAC …  AEDECOD      ATRIAL F…         n          n     0
#> ℹ 2168 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

**System Organ Class Rates**

The AE rate process is repeated for SOC.

``` r

ard_ae |>
  filter(variable == "AESOC") |>
  select(-all_missing_columns())
#> {cards} data frame: 207 x 9
#>    group1 group1_level variable variable_level stat_name stat_label  stat
#> 1    TRTA      Placebo    AESOC      CARDIAC …         n          n    13
#> 2    TRTA      Placebo    AESOC      CARDIAC …         N          N    86
#> 3    TRTA      Placebo    AESOC      CARDIAC …         p          % 0.151
#> 4    TRTA    Xanomeli…    AESOC      CARDIAC …         n          n    18
#> 5    TRTA    Xanomeli…    AESOC      CARDIAC …         N          N    84
#> 6    TRTA    Xanomeli…    AESOC      CARDIAC …         p          % 0.214
#> 7    TRTA    Xanomeli…    AESOC      CARDIAC …         n          n    13
#> 8    TRTA    Xanomeli…    AESOC      CARDIAC …         N          N    84
#> 9    TRTA    Xanomeli…    AESOC      CARDIAC …         p          % 0.155
#> 10   TRTA      Placebo    AESOC      CONGENIT…         n          n     0
#> ℹ 197 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 2 more variables: context, fmt_fun
```

**Any AE Rates**

The process is then repeated to calculate rates of any adverse event.

``` r

ard_ae |>
  filter(variable == "..ard_hierarchical_overall..") |>
  select(-all_missing_columns())
#> {cards} data frame: 9 x 9
#>   group1 group1_level                     variable variable_level stat_name stat_label  stat
#> 1   TRTA      Placebo ..ard_hierarchical_overall..           TRUE         n          n    69
#> 2   TRTA      Placebo ..ard_hierarchical_overall..           TRUE         N          N    86
#> 3   TRTA      Placebo ..ard_hierarchical_overall..           TRUE         p          % 0.802
#> 4   TRTA    Xanomeli… ..ard_hierarchical_overall..           TRUE         n          n    79
#> 5   TRTA    Xanomeli… ..ard_hierarchical_overall..           TRUE         N          N    84
#> 6   TRTA    Xanomeli… ..ard_hierarchical_overall..           TRUE         p          %  0.94
#> 7   TRTA    Xanomeli… ..ard_hierarchical_overall..           TRUE         n          n    77
#> 8   TRTA    Xanomeli… ..ard_hierarchical_overall..           TRUE         N          N    84
#> 9   TRTA    Xanomeli… ..ard_hierarchical_overall..           TRUE         p          % 0.917
#> ℹ 2 more variables: context, fmt_fun
```

**Treatment Counts**

Finally, a univariate tabulation of the `TRTA` column from `ADSL` is
included.

``` r

ard_ae |>
  filter(variable == "TRTA") |>
  select(-all_missing_columns())
#> {cards} data frame: 9 x 7
#>   variable variable_level  context stat_name stat_label  stat
#> 1     TRTA        Placebo tabulate         n          n    86
#> 2     TRTA        Placebo tabulate         N          N   254
#> 3     TRTA        Placebo tabulate         p          % 0.339
#> 4     TRTA      Xanomeli… tabulate         n          n    84
#> 5     TRTA      Xanomeli… tabulate         N          N   254
#> 6     TRTA      Xanomeli… tabulate         p          % 0.331
#> 7     TRTA      Xanomeli… tabulate         n          n    84
#> 8     TRTA      Xanomeli… tabulate         N          N   254
#> 9     TRTA      Xanomeli… tabulate         p          % 0.331
#> ℹ 1 more variable: fmt_fun
```

The package exports a similar function for counting adverse event,
rather than calculating rates:
[`ard_stack_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md).

## Stratified Summaries

There are many types of stratified summaries that may be needed to
report results from a trial. We will focus on a common lab summary where
summary statistics are reported by lab type, visit and treatment.

[TABLE]

To build the ARD for this table, we use the
[`ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md).

- `ard_summary(by="TRTA")`: Use the `by` argument ensures each level of
  treatment has all associated summary statistics, even if there are
  combinations that are unobserved or all `NA`.

- `ard_summary(strata=c("PARAM", "AVISIT")`: The strata argument will
  produce summary statistics for all *observed combinations* of
  `'PARAM'` and `'AVISIT'`. We opt to use `strata` because it is common
  a trial will not collect all labs at each visit, and we don’t want to
  report that bilirubin had no observations at week xx when it was never
  meant to be collected at that visit, for example.

- `ard_summary(variables=c("AVAL", "CHG"))`: These are the variables
  that will be summarized within `'TRTA'`, `'PARAM'`, and `'AVISIT'`.

``` r

ADLB |>
  # subset on two labs and two study visits
  filter(
    PARAMCD %in% c("BILI", "CREAT"),
    AVISIT %in% c("Baseline", "Week 24")
  ) |>
  ard_summary(
    # calculate statistics by observed combinations of PARAM on AVISIT
    strata = c("PARAM", "AVISIT"),
    # `by='TRTA'` will provide results for each of the treatments, even if unobserved
    by = "TRTA",
    # provide summaries for the measurement and its change from baseline
    variables = c("AVAL", "CHG")
  )
#> {cards} data frame: 192 x 14
#>    group1 group1_level group2 group2_level group3 group3_level variable stat_name stat_label  stat
#> 1    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL         N          N     7
#> 2    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL      mean       Mean  8.55
#> 3    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL        sd         SD 2.962
#> 4    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL    median     Median  8.55
#> 5    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL       p25         Q1  5.13
#> 6    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL       p75         Q3 11.97
#> 7    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL       min        Min  5.13
#> 8    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline     AVAL       max        Max 11.97
#> 9    TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline      CHG         N          N     0
#> 10   TRTA      Placebo  PARAM    Bilirubi… AVISIT     Baseline      CHG      mean       Mean   NaN
#> ℹ 182 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

There are some cases, where slightly different behavior is needed within
stratum. In these cases, use the
[`ard_strata()`](https://insightsengineering.github.io/cards/reference/ard_strata.md)
function. For example, if we were tabulating character `AVALC` values,
and the possible values are different depending on `PARAM`, the code may
look something like this:

``` r

ard_strata(
  data = ADLB,
  .strata = "PARAM",
  .f = \(data_param) {
    # set factor depending on the PARAM value
    if (data_param$PARAM[1] == "XXX") data_param$AVALC <- factor(data_param$AVALC, levels = c("No", "Yes"))
    if (data_param$PARAM[1] == "YYY") data_param$AVALC <- factor(data_param$AVALC, levels = c("Low", "High"))

    ard_tabulate(
      data_param,
      strata = "AVISIT",
      by = "TRTA",
      variable = "AVALC"
    )
  }
)
```

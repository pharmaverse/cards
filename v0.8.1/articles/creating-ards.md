# Writing ARD Functions

The basic functions offered by {cards} can create a wide variety of
ARDs. However, sometimes we may need to include the outputs from more
complicated statistical methods in our ARDs. In this article we’ll look
at a few different ways to implement the output from these statistical
methods.

### {cardx}

The {cardx} package is an extension of {cards}. The idea is that {cards}
provides the core functions to create ARDs, while {cardx} contains a
large number of extensions that implement various, commonly used
statistical methods. There are a large number of extensions for a wide
variety of methods, including (but not limited to):

- Regression models
- ANOVA
- Chi-squared Test
- t-test
- LS Mean Difference
- Survival Estimates and Differences

When looking to include the output from a statistical method your first
port of call should be to see if it has already been implemented in
{cardx}. You can find the full list of available functions
[here](https://insightsengineering.github.io/cardx/main/reference/index.html).

Consider a simple t-test comparing the mean age (`AGE`) across two
treatments arms (`ARM`). In {cardx} we have the function
[`cardx::ard_stats_t_test()`](https://insightsengineering.github.io/cardx/latest-tag/reference/ard_stats_t_test.html)

``` r

cards::ADSL |>
  dplyr::filter(ARM %in% c("Xanomeline High Dose", "Xanomeline Low Dose")) |>
  cardx::ard_stats_t_test(by = ARM, variables = AGE)
#> {cards} data frame: 14 x 9
#>    group1 variable   context   stat_name stat_label      stat
#> 1     ARM      AGE stats_t_…    estimate  Mean Dif…    -1.286
#> 2     ARM      AGE stats_t_…   estimate1  Group 1 …    74.381
#> 3     ARM      AGE stats_t_…   estimate2  Group 2 …    75.667
#> 4     ARM      AGE stats_t_…   statistic  t Statis…     -1.03
#> 5     ARM      AGE stats_t_…     p.value    p-value     0.304
#> 6     ARM      AGE stats_t_…   parameter  Degrees …   165.595
#> 7     ARM      AGE stats_t_…    conf.low  CI Lower…     -3.75
#> 8     ARM      AGE stats_t_…   conf.high  CI Upper…     1.179
#> 9     ARM      AGE stats_t_…      method     method Welch Tw…
#> 10    ARM      AGE stats_t_… alternative  alternat… two.sided
#> 11    ARM      AGE stats_t_…          mu    H0 Mean         0
#> 12    ARM      AGE stats_t_…      paired  Paired t…     FALSE
#> 13    ARM      AGE stats_t_…   var.equal  Equal Va…     FALSE
#> 14    ARM      AGE stats_t_…  conf.level  CI Confi…      0.95
#> ℹ 3 more variables: fmt_fun, warning, error
```

In the output, we see the outputs from the t-test; the mean difference,
confidence interval limits and p-value. It’s also useful to see the
functions inputs; for example, we can see that we did not use equal
variances as the `stat` is `FALSE` for `stat_name` `var.equal`. This is
useful for re-use, if we need to run the test again we can use the ARD
to see what options we need to use to recreate the result.

## Write a new `ard_*()` function

*But what do we do if the statistical method that we want to use hasn’t
been implemented already in {cardx}?*

Implementing a new function to create an ARD for a statistical method is
often simple; all we need to do is write a function that outputs the
results as a named list!

We’ll first look at how
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html) can
make this even easier for us, then provide an example on how to
implement from scratch.

### Using `broom::tidy()`

Typically, a user will pass a function which returns a scalar value in
the `cards::ard_summary(statistic)` argument. However, the argument also
allows for functions that return named lists, where the names from the
list will then be used as the statistic names. Since data frames or
tibbles are just named lists with a little more formatting, we can pass
a function to the `statistic` argument which returns a single row data
frame or tibble and the behavior will be the same. Each column of the
table gives the name of the statistic via its column name, and then the
corresponding value.

Commonly used statistical methods outputs are able to be passed through
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html), which
will convert the output into a tibble. We can then pass the output of
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html)
through to the `cards::ard_summary(statistic)` argument of the ARD
function we wish to use, this leads to an ARD output like we see in the
above example, where we have one row per relevant input or output from
the statistical method.

Please note that we can only use the
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html) output
directly, as we see in the below example, when the output is a tibble
with a single row.

Let’s extend our t-test example from above. This time we want to carry
out a one-sample t-test. We can just pass the code to carry out the
one-sample t-test and pass the output through
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html) to the
`statistic` argument like so:

``` r

cards::ADSL |>
  dplyr::filter(ARM %in% c("Xanomeline High Dose", "Xanomeline Low Dose")) |>
  cards::ard_summary(
    variables = AGE,
    statistic = everything() ~ list(t_test = \(x) t.test(x) |> broom::tidy())
  ) |>
  dplyr::mutate(context = "t_test_one_sample")
#> {cards} data frame: 8 x 8
#>   variable   context   stat_name stat_label      stat fmt_fun
#> 1      AGE t_test_o…    estimate   estimate    75.024       1
#> 2      AGE t_test_o…   statistic  statistic     120.2       1
#> 3      AGE t_test_o…     p.value    p.value         0       1
#> 4      AGE t_test_o…   parameter  parameter       167       1
#> 5      AGE t_test_o…    conf.low   conf.low    73.792       1
#> 6      AGE t_test_o…   conf.high  conf.high    76.256       1
#> 7      AGE t_test_o…      method     method One Samp…    <fn>
#> 8      AGE t_test_o… alternative  alternat… two.sided    <fn>
#> ℹ 2 more variables: warning, error
```

In the above chunk of code, if we focus on what we pass to the
`statistic` argument:

- [`everything()`](https://tidyselect.r-lib.org/reference/everything.html)
  means we want to run this test on all columns passed to the
  `variables` argument.
- `t.test(x)` is the function which carries out the statistical test, in
  this case with the default arguments.
- We pipe the output of `t.test(x)` into
  [`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html)
  which converts the output of the test into a tibble (which, remember,
  is just a named list!)
- The function we’ve defined (`\(x) t.test(x) |> broom::tidy()`) itself
  needs to be included in a named list, where here we’ve chosen to use
  the label `'t_test'`.

Over 100 different statistical methods implemented in R are able to be
‘tidied’ using
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html).
However, the method you aim to use might not be, or the current
[`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html)
implementation might not contain the information that you need to be in
your ARD. In that case we’ll have to format the output ourselves.

### Without `broom::tidy()`

As mentioned above, we need to define a function which carries out our
required statistical method and outputs a named list of the information
we wish to include in the ARD.

As an example, let’s write a function which carries out a Wilcoxon
signed rank test over one variable using the function `wilcox.test`. As
an output we just want to record the method and the p-value.

``` r

wilcox_one_var <- \(x) wilcox.test(x)[c("method", "p.value")]
```

Let’s now use this function when creating an ARD with {cards}. Remember
we just need the statistic to be a named list, so we’ll call our
function inside a named list. We also don’t need to specify any
arguments, in this case it will pick up that the one variable `x`
corresponds to the data we are testing, in this case `AGE` for the
individual treatment arms.

``` r

cards::ADSL |>
  cards::ard_summary(
    variables = AGE,
    by = ARM,
    statistic = ~ list(wilcox = wilcox_one_var)
  )
#> {cards} data frame: 6 x 10
#>   group1 group1_level variable stat_name stat_label      stat
#> 1    ARM      Placebo      AGE    method     method Wilcoxon…
#> 2    ARM      Placebo      AGE   p.value    p.value         0
#> 3    ARM    Xanomeli…      AGE    method     method Wilcoxon…
#> 4    ARM    Xanomeli…      AGE   p.value    p.value         0
#> 5    ARM    Xanomeli…      AGE    method     method Wilcoxon…
#> 6    ARM    Xanomeli…      AGE   p.value    p.value         0
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

We see here that we get an output of 8 rows, 2 rows (one for the method,
and one for the p-value) for each of the 4 treatment arms.

### Complex inputs

The examples above are great to illustrate a simple case, but it is
perhaps a rare scenario where we are implementing a statistical method
with a single vector as its input. How would we update the code above if
we need to implement a two-sample t-test?

The
[`cards::ard_mvsummary()`](https://insightsengineering.github.io/cards/reference/ard_mvsummary.md)
is similar to
[`cards::ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md),
but allows for more complex inputs in the function passed in the
`statistic` argument. In
[`cards::ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md),
the functions passed must accept a single vector, e.g. `\(x) t.test(x)`.
But in
[`cards::ard_mvsummary()`](https://insightsengineering.github.io/cards/reference/ard_mvsummary.md),
in addition to the vector being passed, the `data` subset, the
`full_data`, character `by`, and character `strata` are also passed (see
the
[`cards::ard_mvsummary()`](https://insightsengineering.github.io/cards/reference/ard_mvsummary.md)
for a full description). Your function does not need to utilize each of
these elements, but each *will be passed* to your function. As a result,
we recommend your function accept the triple dots to handle unused
arguments.

An implementation of a two-sample t-test may look like this:

``` r

ttest_two_sample <- \(x, data, ...) t.test(x ~ data[["ARM"]]) |> broom::tidy()

cards::ADSL |>
  dplyr::filter(ARM %in% c("Xanomeline High Dose", "Xanomeline Low Dose")) |>
  cards::ard_mvsummary(
    variables = AGE,
    statistic = everything() ~ list(t_test = ttest_two_sample)
  ) |>
  dplyr::mutate(context = "t_test_two_sample")
#> {cards} data frame: 10 x 8
#>    variable   context   stat_name stat_label      stat fmt_fun
#> 1       AGE t_test_t…    estimate   estimate    -1.286       1
#> 2       AGE t_test_t…   estimate1  estimate1    74.381       1
#> 3       AGE t_test_t…   estimate2  estimate2    75.667       1
#> 4       AGE t_test_t…   statistic  statistic     -1.03       1
#> 5       AGE t_test_t…     p.value    p.value     0.304       1
#> 6       AGE t_test_t…   parameter  parameter   165.595       1
#> 7       AGE t_test_t…    conf.low   conf.low     -3.75       1
#> 8       AGE t_test_t…   conf.high  conf.high     1.179       1
#> 9       AGE t_test_t…      method     method Welch Tw…    <fn>
#> 10      AGE t_test_t… alternative  alternat… two.sided    <fn>
#> ℹ 2 more variables: warning, error
```

## Handling errors

Let’s consider what happens when we encounter an error in our
statistical method.

``` r

wilcox_one_var_error <- function(x) {
  stop("AN ERROR!")
  wilcox.test(x)[c("method", "p.value")]
}

cards::ADSL |>
  cards::ard_summary(
    variables = AGE,
    by = ARM,
    statistic = ~ list(wilcox = wilcox_one_var_error)
  )
#> {cards} data frame: 3 x 10
#>   group1 group1_level variable stat_name stat_label stat     error
#> 1    ARM      Placebo      AGE    wilcox     wilcox      AN ERROR!
#> 2    ARM    Xanomeli…      AGE    wilcox     wilcox      AN ERROR!
#> 3    ARM    Xanomeli…      AGE    wilcox     wilcox      AN ERROR!
#> ℹ 3 more variables: context, fmt_fun, warning
```

In the output we see that we only get 4 rows of output, the error has
been stored in the `error` column but `stat_name` and `stat_label` now
just take the list name of “wilcox” that we define in the statistic
argument. This could have unintended effects in downstream code, we may
be relying on the `stat_name` and `stat_label` having values of “method”
and “p-value”, or just that the output has 2 rows per treatment arm.

To handle this we can specify the expected results from our function, so
that even if we encounter an error during the code run we can be assured
that the output will be of a consistent format so as not to impact
downstream code.

Here’s an example of how to specify the expected output using
[`cards::as_cards_fn()`](https://insightsengineering.github.io/cards/reference/as_cards_fn.md):

``` r

wilcox_one_var_error <- cards::as_cards_fn(
  wilcox_one_var_error,
  stat_names = c("method", "p.value")
)

cards::ADSL |>
  cards::ard_summary(
    variables = AGE,
    by = ARM,
    statistic = ~ list(wilcox = wilcox_one_var_error)
  )
#> {cards} data frame: 6 x 10
#>   group1 group1_level variable stat_name stat_label stat     error
#> 1    ARM      Placebo      AGE    method     method      AN ERROR!
#> 2    ARM      Placebo      AGE   p.value    p.value      AN ERROR!
#> 3    ARM    Xanomeli…      AGE    method     method      AN ERROR!
#> 4    ARM    Xanomeli…      AGE   p.value    p.value      AN ERROR!
#> 5    ARM    Xanomeli…      AGE    method     method      AN ERROR!
#> 6    ARM    Xanomeli…      AGE   p.value    p.value      AN ERROR!
#> ℹ 3 more variables: context, fmt_fun, warning
```

Our function becomes the first argument to
[`cards::as_cards_fn()`](https://insightsengineering.github.io/cards/reference/as_cards_fn.md),
then the second argument is `stat_names` where we specify the expected
names of the output list.

In the output shown here, the `error` column is still populated with the
error. However, now we have the expected 8 rows and we can see that the
`stat_name` and `stat_label` match the values specified in the
`stat_names` argument in the
[`as_cards_fn()`](https://insightsengineering.github.io/cards/reference/as_cards_fn.md)—helping
us to avoid problems in code that relies on this output.

## Formalizing Your Function

If you are writing function that will be used multiple times, for
example adding it to a package, you may want to include the function’s
arguments in the returned ARD. Returning the arguments improves the
traceability of the ARD, and requires combining the function’s default
arguments (the formals) and any argument passed by the user. The
[`ard_formals()`](https://insightsengineering.github.io/cards/reference/ard_formals.md)
function helps combine these results.

In the example below, we expand out one-sample t-test example with the
argument values passed to `t.test(...)`

``` r

my_ard_one_sample_t_test <- function(data, variable, ...) {
  # define function to calculate results
  t_test_fun <- function(x) t.test(x, ...) |> broom::tidy()
  t_test_fun <-
    cards::as_cards_fn(
      t_test_fun,
      c(
        "estimate", "statistic", "p.value", "parameter",
        "conf.low", "conf.high", "method", "alternative"
      )
    )

  # create the ARD of results
  ard_results <-
    cards::ard_summary(
      data = data,
      variables = {{ variable }},
      statistic = everything() ~ list(t_test = t_test_fun)
    ) |>
    dplyr::mutate(context = "t_test_one_sample")

  # ard of argument values
  ard_arguments <-
    cards::ard_formals(
      fun = asNamespace("stats")[["t.test.default"]],
      arg_names = c("mu", "paired", "var.equal", "conf.level"),
      passed_args = rlang::dots_list(...)
    )

  # combine ARDs and fill arguments with missing information
  dplyr::bind_rows(ard_results, ard_arguments) |>
    dplyr::mutate(dplyr::across(c(variable, context), dplyr::first))
}

cards::ADSL |>
  dplyr::filter(ARM %in% c("Xanomeline High Dose", "Xanomeline Low Dose")) |>
  my_ard_one_sample_t_test(
    variable = "AGE",
    var.equal = TRUE,
    conf.level = 0.90
  )
#> {cards} data frame: 12 x 8
#>    variable   context   stat_name stat_label      stat fmt_fun
#> 1       AGE t_test_o…    estimate   estimate    75.024       1
#> 2       AGE t_test_o…   statistic  statistic     120.2       1
#> 3       AGE t_test_o…     p.value    p.value         0       1
#> 4       AGE t_test_o…   parameter  parameter       167       1
#> 5       AGE t_test_o…    conf.low   conf.low    73.991       1
#> 6       AGE t_test_o…   conf.high  conf.high    76.056       1
#> 7       AGE t_test_o…      method     method One Samp…    <fn>
#> 8       AGE t_test_o… alternative  alternat… two.sided    <fn>
#> 9       AGE t_test_o…          mu         mu         0    NULL
#> 10      AGE t_test_o…      paired     paired     FALSE    NULL
#> 11      AGE t_test_o…   var.equal  var.equal      TRUE    NULL
#> 12      AGE t_test_o…  conf.level  conf.lev…       0.9    NULL
#> ℹ 2 more variables: warning, error
```

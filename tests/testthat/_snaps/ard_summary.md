# ard_summary() works

    Code
      class(ard_test)
    Output
      [1] "card"       "tbl_df"     "tbl"        "data.frame"

# ard_summary(fmt_fun) argument works

    Code
      as.data.frame(dplyr::select(apply_fmt_fun(ard_summary(ADSL, variables = "AGE",
        statistic = list(AGE = continuous_summary_fns(c("N", "mean", "median"))),
        fmt_fun = list(AGE = list(mean = function(x) as.character(round5(x, digits = 3)),
        N = function(x) format(round5(x, digits = 2), nsmall = 2), N_obs = function(x)
          format(round5(x, digits = 2), nsmall = 2))))), variable, stat_name, stat,
      stat_fmt))
    Output
        variable stat_name     stat stat_fmt
      1      AGE         N      254   254.00
      2      AGE      mean 75.08661   75.087
      3      AGE    median       77     77.0

---

    Code
      as.data.frame(dplyr::select(apply_fmt_fun(ard_summary(ADSL, variables = c("AGE",
        "BMIBL"), statistic = ~ continuous_summary_fns("mean"), fmt_fun = list(AGE = list(
        mean = function(x) as.character(round5(x, digits = 3)))))), variable,
      stat_name, stat, stat_fmt))
    Output
        variable stat_name     stat stat_fmt
      1      AGE      mean 75.08661   75.087
      2    BMIBL      mean 24.67233     24.7

---

    Code
      as.data.frame(dplyr::select(apply_fmt_fun(ard_summary(ADSL, variables = c("AGE",
        "BMIBL"), statistic = ~ continuous_summary_fns(c("mean", "sd")), fmt_fun = ~
      list(~ function(x) round(x, 4)))), variable, stat_name, stat, stat_fmt))
    Output
        variable stat_name     stat stat_fmt
      1      AGE      mean 75.08661  75.0866
      2      AGE        sd 8.246234   8.2462
      3    BMIBL      mean 24.67233  24.6723
      4    BMIBL        sd 4.092185   4.0922

# ard_summary() messaging

    Code
      ard_summary(mtcars, variables = "mpg", statistic = ~ list(mean = "this is a string"))
    Condition
      Error in `ard_summary()`:
      ! Error in the argument `statistic` for variable "mpg".
      i Value must be a named list of functions.

---

    Code
      ard_summary(letters, variables = "mpg")
    Condition
      Error in `UseMethod()`:
      ! no applicable method for 'ard_summary' applied to an object of class "character"

---

    Code
      ard_summary(mtcars)
    Condition
      Error in `ard_summary()`:
      ! The `variables` argument cannot be missing.

# ard_summary(stat_label) argument works

    Code
      unique(dplyr::filter(dplyr::select(as.data.frame(ard_summary(data = ADSL, by = "ARM",
        variables = c("AGE", "BMIBL"), stat_label = everything() ~ list(c("min",
          "max") ~ "min - max"))), stat_name, stat_label), stat_name %in% c("min",
        "max")))
    Output
        stat_name stat_label
      1       min  min - max
      2       max  min - max

---

    Code
      unique(dplyr::filter(dplyr::select(as.data.frame(ard_summary(data = ADSL, by = "ARM",
        variables = c("AGE", "BMIBL"), stat_label = everything() ~ list(p25 = "25th %ile",
          p75 = "75th %ile"))), stat_name, stat_label), stat_name %in% c("p25", "p75")))
    Output
        stat_name stat_label
      1       p25  25th %ile
      2       p75  75th %ile

---

    Code
      unique(dplyr::select(dplyr::filter(as.data.frame(ard_summary(data = ADSL, by = "ARM",
        variables = c("AGE", "BMIBL"), stat_label = AGE ~ list(p25 = "25th %ile",
          p75 = "75th %ile"))), stat_name %in% c("p25", "p75")), variable, stat_name,
      stat_label))
    Output
        variable stat_name stat_label
      1      AGE       p25  25th %ile
      2      AGE       p75  75th %ile
      3    BMIBL       p25         Q1
      4    BMIBL       p75         Q3

---

    Code
      ard1
    Output
        variable stat_name stat_label
      1      AGE  conf.low         LB
      2      AGE conf.high         UB

# ard_summary() with dates works and displays as expected

    Code
      ard_date
    Output
      # An ARD data frame: 3 x 8
        variable context stat_name stat_label stat       fmt_fun warning error 
      * <chr>    <chr>   <chr>     <chr>      <list>     <list>  <list>  <list>
      1 DISONSDT summary min       Min        1998-06-13 <fn>    <NULL>  <NULL>
      2 DISONSDT summary max       Max        2013-09-16 <fn>    <NULL>  <NULL>
      3 DISONSDT summary sd        SD         878.5575   1       <NULL>  <NULL>

# ard_summary() works with non-syntactic names

    Code
      as.data.frame(ard_summary(dplyr::mutate(ADSL, `BMI base` = BMIBL, Age = AGE,
        `Arm Var` = ARM), variables = c("BMI base", Age), statistic = ~ list(
        `mean lbl` = `mean error`), stat_label = everything() ~ list(`mean lbl` = "Test lbl")))
    Output
        variable context stat_name stat_label stat                    fmt_fun warning
      1 BMI base summary  mean lbl   Test lbl NULL .Primitive("as.character")    NULL
      2      Age summary  mean lbl   Test lbl NULL .Primitive("as.character")    NULL
                                           error
      1 There was an error calculating the mean.
      2 There was an error calculating the mean.

# ard_summary() errors with incomplete factor columns

    Code
      ard_summary(dplyr::mutate(mtcars, am = factor(am, levels = character(0))), by = am,
      variables = mpg)
    Condition
      Error in `ard_summary()`:
      ! Factors with empty "levels" attribute are not allowed, which was identified in column "am".

---

    Code
      ard_summary(dplyr::mutate(mtcars, am = factor(am, levels = c(0, 1, NA),
      exclude = NULL)), by = am, variables = mpg)
    Condition
      Error in `ard_summary()`:
      ! Factors with NA levels are not allowed, which are present in column "am".


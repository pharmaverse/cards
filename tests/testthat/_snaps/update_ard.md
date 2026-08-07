# update_ard_fmt_fun()

    Code
      update_ard_fmt_fun(ard_summary(ADSL, variables = AGE), stat_names = c("mean",
        "sd"), fmt_fun = -8L)
    Condition
      Error in `update_ard_fmt_fun()`:
      ! The value in `fmt_fun` cannot be converted into a function.
      i Value must be a function, a non-negative integer, or a formatting string, e.g. "xx.x".
      * See `?cards::alias_as_fmt_fun()` for details.

# update_ard_fmt_fun(filter)

    Code
      apply_fmt_fun(update_ard_fmt_fun(ard_summary(ADSL, by = ARM, variables = AGE,
        statistic = ~ continuous_summary_fns(c("N", "mean"))), stat_names = "mean",
      fmt_fun = 8L, filter = group1_level == "Placebo"))
    Output
      # An ARD data frame: 6 x 11
        group1 group1_level       variable context stat_name stat_label  stat stat_fmt
        <chr>  <list>             <chr>    <chr>   <chr>     <chr>      <lis> <list>  
      1 ARM    Placebo            AGE      summary N         N           86   86      
      2 ARM    Placebo            AGE      summary mean      Mean        75.2 75.2093~
      3 ARM    Xanomeline High D~ AGE      summary N         N           84   84      
      4 ARM    Xanomeline High D~ AGE      summary mean      Mean        74.4 74.4    
      5 ARM    Xanomeline Low Do~ AGE      summary N         N           84   84      
      6 ARM    Xanomeline Low Do~ AGE      summary mean      Mean        75.7 75.7    
      # i 3 more variables: fmt_fun <list>, warning <list>, error <list>

# update_ard_fmt_fun(filter) messaging

    Code
      update_ard_fmt_fun(ard_summary(ADSL, by = ARM, variables = AGE, statistic = ~
        continuous_summary_fns(c("N", "mean"))), stat_names = "mean", fmt_fun = 8L,
      filter = group99999999_level == "Placebo")
    Condition
      Error in `update_ard_fmt_fun()`:
      ! There was an error evaluating the `filter` argument. See below:
      x object 'group99999999_level' not found

---

    Code
      update_ard_fmt_fun(ard_summary(ADSL, by = ARM, variables = AGE, statistic = ~
        continuous_summary_fns(c("N", "mean"))), stat_names = "mean", fmt_fun = 8L,
      filter = c(TRUE, FALSE))
    Condition
      Error in `update_ard_fmt_fun()`:
      ! The `filter` argument must be an expression that evaluates to a <logical> vector of length 1 or 6.

# update_ard_stat_label(filter)

    Code
      update_ard_stat_label(ard_summary(ADSL, by = ARM, variables = AGE, statistic = ~
        continuous_summary_fns(c("N", "mean", "sd"))), stat_names = c("mean", "sd"),
      stat_label = "Mean (SD)", filter = group1_level == "Placebo")
    Output
      # An ARD data frame: 9 x 10
        group1 group1_level        variable context stat_name stat_label  stat fmt_fun
        <chr>  <list>              <chr>    <chr>   <chr>     <chr>      <lis>  <list>
      1 ARM    Placebo             AGE      summary N         N          86          0
      2 ARM    Placebo             AGE      summary mean      Mean (SD)  75.2        1
      3 ARM    Placebo             AGE      summary sd        Mean (SD)   8.59       1
      4 ARM    Xanomeline High Do~ AGE      summary N         N          84          0
      5 ARM    Xanomeline High Do~ AGE      summary mean      Mean       74.4        1
      6 ARM    Xanomeline High Do~ AGE      summary sd        SD          7.89       1
      7 ARM    Xanomeline Low Dose AGE      summary N         N          84          0
      8 ARM    Xanomeline Low Dose AGE      summary mean      Mean       75.7        1
      9 ARM    Xanomeline Low Dose AGE      summary sd        SD          8.29       1
      # i 2 more variables: warning <list>, error <list>

# update_ard_stat_label(filter) messaging

    Code
      update_ard_stat_label(ard_summary(ADSL, by = ARM, variables = AGE, statistic = ~
        continuous_summary_fns(c("N", "mean", "sd"))), stat_names = c("mean", "sd"),
      stat_label = "Mean (SD)", filter = group99999999_level == "Placebo")
    Condition
      Error in `value[[3L]]()`:
      ! There was an error evaluating the `filter` argument. See below:
      x object 'group99999999_level' not found

---

    Code
      update_ard_stat_label(ard_summary(ADSL, by = ARM, variables = AGE, statistic = ~
        continuous_summary_fns(c("N", "mean", "sd"))), stat_names = c("mean", "sd"),
      stat_label = "Mean (SD)", filter = c(TRUE, FALSE))
    Condition
      Error in `update_ard_stat_label()`:
      ! The `filter` argument must be an expression that evaluates to a <logical> vector of length 1 or 9.


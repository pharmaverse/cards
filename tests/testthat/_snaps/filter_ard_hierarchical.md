# filter_ard_hierarchical() works

    Code
      ard_f
    Output
      # An ARD data frame: 45 x 15
         group1 group1_level group2 group2_level group3 group3_level variable                     variable_level       context      stat_name stat_label    stat fmt_fun warning error 
         <chr>  <list>       <chr>  <list>       <chr>  <list>       <chr>                        <list>               <chr>        <chr>     <chr>       <list> <list>  <list>  <list>
       1 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Placebo              tabulate     n         n           86     0       <NULL>  <NULL>
       2 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Placebo              tabulate     N         N          254     0       <NULL>  <NULL>
       3 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Placebo              tabulate     p         %            0.339 <fn>    <NULL>  <NULL>
       4 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline High Dose tabulate     n         n           84     0       <NULL>  <NULL>
       5 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline High Dose tabulate     N         N          254     0       <NULL>  <NULL>
       6 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline High Dose tabulate     p         %            0.331 <fn>    <NULL>  <NULL>
       7 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline Low Dose  tabulate     n         n           84     0       <NULL>  <NULL>
       8 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline Low Dose  tabulate     N         N          254     0       <NULL>  <NULL>
       9 <NA>   <NULL>       <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline Low Dose  tabulate     p         %            0.331 <fn>    <NULL>  <NULL>
      10 TRTA   Placebo      <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                 hierarchical n         n           26     0       <NULL>  <NULL>
      # i 35 more rows

# filter_ard_hierarchical() error messaging works

    Code
      filter_ard_hierarchical(ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1"),
      n > 10)
    Condition
      Warning:
      The `filter_ard_hierarchical()` function was created for stacked hierarchical ARDs created using `ard_stack_hierarchical()` or `ard_stack_hierarchical_count()`.
      i Unexpected results may occur.
      Error in `filter_ard_hierarchical()`:
      ! No statistics available in the ARD for variable "AGEGR1". In order to filter on "AGEGR1" it must be specified in the `include` argument when the ARD is created.

---

    Code
      filter_ard_hierarchical(ard, 10)
    Condition
      Error in `filter_ard_hierarchical()`:
      ! The `filter` argument must be an expression.

---

    Code
      filter_ard_hierarchical(ard, A > 5)
    Condition
      Error in `filter_ard_hierarchical()`:
      ! The expression provided as `filter` includes condition for statistic "A" which is not present in the ARD and does not correspond to any of the `by` variable levels.
      i Valid filter terms for variable "AETERM" are: "n", "N", "p", "n_1", "n_2", "n_3", "N_1", "N_2", "N_3", "p_1", "p_2", "p_3", "n_overall", "N_overall", "p_overall", and "TRTA".

---

    Code
      filter_ard_hierarchical(ard, n > 1, var = "A")
    Condition
      Error in `filter_ard_hierarchical()`:
      ! Error processing `var` argument.
      ! Can't select columns that don't exist. x Column `A` doesn't exist.
      i Select among columns "SEX", "RACE", and "AETERM"

---

    Code
      filter_ard_hierarchical(ard, n > 1, var = c(SEX, RACE))
    Condition
      Error in `filter_ard_hierarchical()`:
      ! Only one variable can be selected as `var`.

---

    Code
      filter_ard_hierarchical(ard, n > 1, var = RACE)
    Condition
      Error in `filter_ard_hierarchical()`:
      ! No statistics available in the ARD for variable "RACE". In order to filter on "RACE" it must be specified in the `include` argument when the ARD is created.

---

    Code
      filter_ard_hierarchical(ard, n > 1, keep_empty = NULL)
    Condition
      Error in `filter_ard_hierarchical()`:
      ! The `keep_empty` argument must be a scalar with class <logical>, not NULL.

---

    Code
      filter_ard_hierarchical(ard_stat_miss, n_1 > 1)
    Condition
      Error in `filter_ard_hierarchical()`:
      ! The expression provided as `filter` includes condition for statistic "n_1" which is not present in the ARD and does not correspond to any of the `by` variable levels.
      i Valid filter terms for variable "AETERM" are: "p", "p_1", "p_2", "p_3", and "TRTA".

---

    Code
      filter_ard_hierarchical(ard_stat_miss, p_overall > 0.1)
    Condition
      Error in `filter_ard_hierarchical()`:
      ! The expression provided as `filter` includes condition for statistic "p_overall" which is not present in the ARD and does not correspond to any of the `by` variable levels.
      i Valid filter terms for variable "AETERM" are: "p", "p_1", "p_2", "p_3", and "TRTA".


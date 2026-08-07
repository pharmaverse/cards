# ard_stack() messaging

    Code
      head(ard_stack(data = mtcars, ard_summary(variables = "mpg"), .overall = TRUE), 1L)
    Message
      The `.by` argument should be specified when using `.overall=TRUE`.
      i Setting `ard_stack(.overall=FALSE)`.
    Output
      # An ARD data frame: 1 x 8
        variable context stat_name stat_label   stat fmt_fun warning error 
        <chr>    <chr>   <chr>     <chr>      <list>  <list> <list>  <list>
      1 mpg      summary N         N              32       0 <NULL>  <NULL>

---

    Code
      ard_stack(ADSL, by = "ARM", ard_summary(variables = AGE))
    Condition
      Error in `ard_stack()`:
      ! Cannot evaluate expression `by = ARM`.
      i Did you mean `.by = ARM`?

# ard_stack() complex call error

    Code
      complex_call <- list()
      complex_call$ard_summary <- ard_summary
      ard_stack(data = mtcars, .by = am, complex_call$ard_summary(variables = "mpg"), )
    Condition
      Error in `ard_stack()`:
      ! `cards::ard_stack()` works with simple calls (`?rlang::call_name()`) and `complex_call$ard_summary(variables = "mpg")` is not simple.

# ard_stack(.by) messaging

    Code
      dplyr::filter(ard_stack(mtcars2, ard_summary(variables = "mpg", statistic = ~ continuous_summary_fns("N")), .by = c(am, vs), .total_n = TRUE,
      .overall = TRUE), stat_name %in% "N")
    Message
      * Removing 1 row with NA or NaN values in "am" and "vs" columns.
    Output
      # An ARD data frame: 10 x 13
         group1 group1_level group2 group2_level variable        variable_level context  stat_name stat_label   stat fmt_fun warning error 
         <chr>  <list>       <chr>  <list>       <chr>           <list>         <chr>    <chr>     <chr>      <list>  <list> <list>  <list>
       1 am     0            vs     0            mpg             <NULL>         summary  N         N              12       0 <NULL>  <NULL>
       2 am     0            vs     1            mpg             <NULL>         summary  N         N               7       0 <NULL>  <NULL>
       3 am     1            vs     0            mpg             <NULL>         summary  N         N               5       0 <NULL>  <NULL>
       4 am     1            vs     1            mpg             <NULL>         summary  N         N               7       0 <NULL>  <NULL>
       5 <NA>   <NULL>       <NA>   <NULL>       mpg             <NULL>         summary  N         N              31       0 <NULL>  <NULL>
       6 <NA>   <NULL>       <NA>   <NULL>       am              0              tabulate N         N              31       0 <NULL>  <NULL>
       7 <NA>   <NULL>       <NA>   <NULL>       am              1              tabulate N         N              31       0 <NULL>  <NULL>
       8 <NA>   <NULL>       <NA>   <NULL>       vs              0              tabulate N         N              31       0 <NULL>  <NULL>
       9 <NA>   <NULL>       <NA>   <NULL>       vs              1              tabulate N         N              31       0 <NULL>  <NULL>
      10 <NA>   <NULL>       <NA>   <NULL>       ..ard_total_n.. <NULL>         total_n  N         N              31       0 <NULL>  <NULL>

---

    Code
      dplyr::filter(ard_stack(mtcars3, ard_summary(variables = "mpg", statistic = ~ continuous_summary_fns("N")), .by = c(am, vs), .total_n = TRUE,
      .overall = TRUE), stat_name %in% "N")
    Message
      * Removing 2 rows with NA or NaN values in "am" and "vs" columns.
    Output
      # An ARD data frame: 10 x 13
         group1 group1_level group2 group2_level variable        variable_level context  stat_name stat_label   stat fmt_fun warning error 
         <chr>  <list>       <chr>  <list>       <chr>           <list>         <chr>    <chr>     <chr>      <list>  <list> <list>  <list>
       1 am     0            vs     0            mpg             <NULL>         summary  N         N              12       0 <NULL>  <NULL>
       2 am     0            vs     1            mpg             <NULL>         summary  N         N               7       0 <NULL>  <NULL>
       3 am     1            vs     0            mpg             <NULL>         summary  N         N               4       0 <NULL>  <NULL>
       4 am     1            vs     1            mpg             <NULL>         summary  N         N               7       0 <NULL>  <NULL>
       5 <NA>   <NULL>       <NA>   <NULL>       mpg             <NULL>         summary  N         N              30       0 <NULL>  <NULL>
       6 <NA>   <NULL>       <NA>   <NULL>       am              0              tabulate N         N              30       0 <NULL>  <NULL>
       7 <NA>   <NULL>       <NA>   <NULL>       am              1              tabulate N         N              30       0 <NULL>  <NULL>
       8 <NA>   <NULL>       <NA>   <NULL>       vs              0              tabulate N         N              30       0 <NULL>  <NULL>
       9 <NA>   <NULL>       <NA>   <NULL>       vs              1              tabulate N         N              30       0 <NULL>  <NULL>
      10 <NA>   <NULL>       <NA>   <NULL>       ..ard_total_n.. <NULL>         total_n  N         N              30       0 <NULL>  <NULL>


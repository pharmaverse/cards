# sort_ard_hierarchical() works

    Code
      print(dplyr::select(ard_s, all_ard_groups(), all_ard_variables()), n = 50)
    Output
      # An ARD data frame: 234 x 8
         group1 group1_level         group2 group2_level group3 group3_level variable                     variable_level           
         <chr>  <list>               <chr>  <list>       <chr>  <list>       <chr>                        <list>                   
       1 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Placebo                  
       2 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Placebo                  
       3 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Placebo                  
       4 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline High Dose     
       5 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline High Dose     
       6 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline High Dose     
       7 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline Low Dose      
       8 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline Low Dose      
       9 <NA>   <NULL>               <NA>   <NULL>       <NA>   <NULL>       TRTA                         Xanomeline Low Dose      
      10 TRTA   Placebo              <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      11 TRTA   Placebo              <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      12 TRTA   Placebo              <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      13 TRTA   Xanomeline High Dose <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      14 TRTA   Xanomeline High Dose <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      15 TRTA   Xanomeline High Dose <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      16 TRTA   Xanomeline Low Dose  <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      17 TRTA   Xanomeline Low Dose  <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      18 TRTA   Xanomeline Low Dose  <NA>   <NULL>       <NA>   <NULL>       ..ard_hierarchical_overall.. TRUE                     
      19 TRTA   Placebo              <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      20 TRTA   Placebo              <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      21 TRTA   Placebo              <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      22 TRTA   Xanomeline High Dose <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      23 TRTA   Xanomeline High Dose <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      24 TRTA   Xanomeline High Dose <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      25 TRTA   Xanomeline Low Dose  <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      26 TRTA   Xanomeline Low Dose  <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      27 TRTA   Xanomeline Low Dose  <NA>   <NULL>       <NA>   <NULL>       SEX                          F                        
      28 TRTA   Placebo              SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      29 TRTA   Placebo              SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      30 TRTA   Placebo              SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      31 TRTA   Xanomeline High Dose SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      32 TRTA   Xanomeline High Dose SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      33 TRTA   Xanomeline High Dose SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      34 TRTA   Xanomeline Low Dose  SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      35 TRTA   Xanomeline Low Dose  SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      36 TRTA   Xanomeline Low Dose  SEX    F            <NA>   <NULL>       RACE                         WHITE                    
      37 TRTA   Placebo              SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      38 TRTA   Placebo              SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      39 TRTA   Placebo              SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      40 TRTA   Xanomeline High Dose SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      41 TRTA   Xanomeline High Dose SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      42 TRTA   Xanomeline High Dose SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      43 TRTA   Xanomeline Low Dose  SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      44 TRTA   Xanomeline Low Dose  SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      45 TRTA   Xanomeline Low Dose  SEX    F            RACE   WHITE        AETERM                       APPLICATION SITE PRURITUS
      46 TRTA   Placebo              SEX    F            RACE   WHITE        AETERM                       ERYTHEMA                 
      47 TRTA   Placebo              SEX    F            RACE   WHITE        AETERM                       ERYTHEMA                 
      48 TRTA   Placebo              SEX    F            RACE   WHITE        AETERM                       ERYTHEMA                 
      49 TRTA   Xanomeline High Dose SEX    F            RACE   WHITE        AETERM                       ERYTHEMA                 
      50 TRTA   Xanomeline High Dose SEX    F            RACE   WHITE        AETERM                       ERYTHEMA                 
      # i 184 more rows

# sort_ard_hierarchical() warning messaging works

    Code
      r <- sort_ard_hierarchical(ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1"))
    Condition
      Warning:
      The `sort_ard_hierarchical()` function was created for stacked hierarchical ARDs created using `ard_stack_hierarchical()` or `ard_stack_hierarchical_count()`.
      i Unexpected results may occur.

---

    Code
      sort_ard_hierarchical(ard, sort = "no_sorting")
    Condition
      Error in `sort_ard_hierarchical()`:
      ! Sorting type must be either "descending" or "alphanumeric" for all variables.

---

    Code
      sort_ard_hierarchical(ard_no_np)
    Condition
      Error in `sort_ard_hierarchical()`:
      ! If `sort='descending'` for any variables then either "n" or "p" must be present in `x` for each of these specified variables in order to calculate the count sums used for sorting.

---

    Code
      sort_ard_hierarchical(ard, by_level = list(TRTA = "not-a-level"))
    Condition
      Error in `sort_ard_hierarchical()`:
      ! The `by_level` element `TRTA` must be one of "Placebo", "Xanomeline High Dose", and "Xanomeline Low Dose", not "not-a-level".

---

    Code
      sort_ard_hierarchical(ard, by_level = list(not_a_by_var = "Placebo"))
    Condition
      Error in `sort_ard_hierarchical()`:
      ! The names of `by_level` must be `by` variables used to create `x`.
      i The `by` variable "TRTA" is available.

---

    Code
      sort_ard_hierarchical(ard, by_level = list("Placebo"))
    Condition
      Error in `sort_ard_hierarchical()`:
      ! The `by_level` argument must be a fully named list, e.g. `list(TRTA = "Placebo")`.

---

    Code
      sort_ard_hierarchical(ard, by_level = list(TRTA = c("Placebo", "Xanomeline Low Dose")))
    Condition
      Error in `sort_ard_hierarchical()`:
      ! Each element of `by_level` must be a single `by` variable level.

---

    Code
      sort_ard_hierarchical(ard_no_by, by_level = list(TRTA = "Placebo"))
    Condition
      Error in `sort_ard_hierarchical()`:
      ! The `by_level` argument cannot be used because `x` was created without a `by` argument.


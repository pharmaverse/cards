# ard_strata() works

    Code
      ard_strata(ADSL, .by = ARM, .f = ~ ard_summary(.x, variables = AGE))
    Output
      # An ARD data frame: 24 x 10
         group1 group1_level       variable context stat_name stat_label  stat fmt_fun
         <chr>  <list>             <chr>    <chr>   <chr>     <chr>      <lis>  <list>
       1 ARM    Placebo            AGE      summary N         N          86          0
       2 ARM    Placebo            AGE      summary mean      Mean       75.2        1
       3 ARM    Placebo            AGE      summary sd        SD          8.59       1
       4 ARM    Placebo            AGE      summary median    Median     76          1
       5 ARM    Placebo            AGE      summary p25       Q1         69          1
       6 ARM    Placebo            AGE      summary p75       Q3         82          1
       7 ARM    Placebo            AGE      summary min       Min        52          1
       8 ARM    Placebo            AGE      summary max       Max        89          1
       9 ARM    Xanomeline High D~ AGE      summary N         N          84          0
      10 ARM    Xanomeline High D~ AGE      summary mean      Mean       74.4        1
      # i 14 more rows
      # i 2 more variables: warning <list>, error <list>

---

    Code
      ard_strata(ADSL, .strata = ARM, .f = ~ ard_summary(.x, variables = AGE, by = AGEGR1))
    Output
      # An ARD data frame: 72 x 12
         group2 group2_level group1 group1_level variable context stat_name   stat
         <chr>  <list>       <chr>  <list>       <chr>    <chr>   <chr>     <list>
       1 ARM    Placebo      AGEGR1 65-80        AGE      summary N          42   
       2 ARM    Placebo      AGEGR1 65-80        AGE      summary mean       73.6 
       3 ARM    Placebo      AGEGR1 65-80        AGE      summary sd          4.17
       4 ARM    Placebo      AGEGR1 65-80        AGE      summary median     74   
       5 ARM    Placebo      AGEGR1 65-80        AGE      summary p25        70   
       6 ARM    Placebo      AGEGR1 65-80        AGE      summary p75        77   
       7 ARM    Placebo      AGEGR1 65-80        AGE      summary min        65   
       8 ARM    Placebo      AGEGR1 65-80        AGE      summary max        80   
       9 ARM    Placebo      AGEGR1 <65          AGE      summary N          14   
      10 ARM    Placebo      AGEGR1 <65          AGE      summary mean       61.1 
      # i 62 more rows
      # i 4 more variables: stat_label <chr>, fmt_fun <list>, warning <list>,
      #   error <list>


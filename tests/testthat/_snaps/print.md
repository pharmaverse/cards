# print.card() works

    Code
      ard_summary(ADSL, by = "ARM", variables = "AGE")
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
      ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
    Output
      # An ARD data frame: 27 x 11
         group1 group1_level         variable variable_level context  stat_name   stat
         <chr>  <list>               <chr>    <list>         <chr>    <chr>     <list>
       1 ARM    Placebo              AGEGR1   65-80          tabulate n         42    
       2 ARM    Placebo              AGEGR1   65-80          tabulate N         86    
       3 ARM    Placebo              AGEGR1   65-80          tabulate p          0.488
       4 ARM    Placebo              AGEGR1   <65            tabulate n         14    
       5 ARM    Placebo              AGEGR1   <65            tabulate N         86    
       6 ARM    Placebo              AGEGR1   <65            tabulate p          0.163
       7 ARM    Placebo              AGEGR1   >80            tabulate n         30    
       8 ARM    Placebo              AGEGR1   >80            tabulate N         86    
       9 ARM    Placebo              AGEGR1   >80            tabulate p          0.349
      10 ARM    Xanomeline High Dose AGEGR1   65-80          tabulate n         55    
      # i 17 more rows
      # i 4 more variables: stat_label <chr>, fmt_fun <list>, warning <list>,
      #   error <list>

---

    Code
      ard_summary(ADSL, variables = "AGE", fmt_fun = AGE ~ list(~ function(x) round(x,
        3)))
    Output
      # An ARD data frame: 8 x 8
        variable context stat_name stat_label   stat fmt_fun warning error 
      * <chr>    <chr>   <chr>     <chr>      <list> <list>  <list>  <list>
      1 AGE      summary N         N          254    <fn>    <NULL>  <NULL>
      2 AGE      summary mean      Mean        75.1  <fn>    <NULL>  <NULL>
      3 AGE      summary sd        SD           8.25 <fn>    <NULL>  <NULL>
      4 AGE      summary median    Median      77    <fn>    <NULL>  <NULL>
      5 AGE      summary p25       Q1          70    <fn>    <NULL>  <NULL>
      6 AGE      summary p75       Q3          81    <fn>    <NULL>  <NULL>
      7 AGE      summary min       Min         51    <fn>    <NULL>  <NULL>
      8 AGE      summary max       Max         89    <fn>    <NULL>  <NULL>

---

    Code
      dplyr::select(ard_summary(data = data.frame(x = seq(as.Date("2000-01-01"),
      length.out = 10L, by = "day")), variables = x, statistic = ~
      continuous_summary_fns(c("min", "max", "sd"))), -fmt_fun)
    Output
      # An ARD data frame: 3 x 7
        variable context stat_name stat_label stat       warning error 
        <chr>    <chr>   <chr>     <chr>      <list>     <list>  <list>
      1 x        summary min       Min        2000-01-01 <NULL>  <NULL>
      2 x        summary max       Max        2000-01-10 <NULL>  <NULL>
      3 x        summary sd        SD         3.02765    <NULL>  <NULL>

---

    Code
      bind_ard(ard_attributes(mtcars, variables = mpg), ard_summary(mtcars,
        variables = mpg, statistic = ~ continuous_summary_fns("mean", other_stats = list(
          vcov = function(x) vcov(lm(mpg ~ am, mtcars))))))
    Output
      # An ARD data frame: 4 x 8
        variable context    stat_name stat_label  stat          fmt_fun warning error 
        <chr>    <chr>      <chr>     <chr>       <list>        <list>  <list>  <list>
      1 mpg      attributes label     Variable L~ mpg           <fn>    <NULL>  <NULL>
      2 mpg      attributes class     Variable C~ numeric       <NULL>  <NULL>  <NULL>
      3 mpg      summary    mean      Mean        20.09062      1       <NULL>  <NULL>
      4 mpg      summary    vcov      vcov        <dbl [2 x 2]> 1       <NULL>  <NULL>

# print.card() drops columns in order when too wide

    Code
      print(ard, width = 60)
    Output
      # An ARD data frame: 27 x 11
         group1 group1_level     variable variable_level stat_name
         <chr>  <list>           <chr>    <list>         <chr>    
       1 ARM    Placebo          AGEGR1   65-80          n        
       2 ARM    Placebo          AGEGR1   65-80          N        
       3 ARM    Placebo          AGEGR1   65-80          p        
       4 ARM    Placebo          AGEGR1   <65            n        
       5 ARM    Placebo          AGEGR1   <65            N        
       6 ARM    Placebo          AGEGR1   <65            p        
       7 ARM    Placebo          AGEGR1   >80            n        
       8 ARM    Placebo          AGEGR1   >80            N        
       9 ARM    Placebo          AGEGR1   >80            p        
      10 ARM    Xanomeline High~ AGEGR1   65-80          n        
      # i 17 more rows
      # i 6 more variables: context <chr>, stat_label <chr>,
      #   stat <list>, fmt_fun <list>, warning <list>,
      #   error <list>

---

    Code
      print(ard, width = Inf)
    Output
      # An ARD data frame: 27 x 11
         group1 group1_level         variable variable_level context  stat_name
       * <chr>  <list>               <chr>    <list>         <chr>    <chr>    
       1 ARM    Placebo              AGEGR1   65-80          tabulate n        
       2 ARM    Placebo              AGEGR1   65-80          tabulate N        
       3 ARM    Placebo              AGEGR1   65-80          tabulate p        
       4 ARM    Placebo              AGEGR1   <65            tabulate n        
       5 ARM    Placebo              AGEGR1   <65            tabulate N        
       6 ARM    Placebo              AGEGR1   <65            tabulate p        
       7 ARM    Placebo              AGEGR1   >80            tabulate n        
       8 ARM    Placebo              AGEGR1   >80            tabulate N        
       9 ARM    Placebo              AGEGR1   >80            tabulate p        
      10 ARM    Xanomeline High Dose AGEGR1   65-80          tabulate n        
         stat_label   stat fmt_fun warning error 
       * <chr>      <list> <list>  <list>  <list>
       1 n          42     0       <NULL>  <NULL>
       2 N          86     0       <NULL>  <NULL>
       3 %           0.488 <fn>    <NULL>  <NULL>
       4 n          14     0       <NULL>  <NULL>
       5 N          86     0       <NULL>  <NULL>
       6 %           0.163 <fn>    <NULL>  <NULL>
       7 n          30     0       <NULL>  <NULL>
       8 N          86     0       <NULL>  <NULL>
       9 %           0.349 <fn>    <NULL>  <NULL>
      10 n          55     0       <NULL>  <NULL>
      # i 17 more rows

# print.card() keeps non-NULL warning/error columns when narrow

    Code
      print(ard, width = 60)
    Output
      # An ARD data frame: 24 x 10
         group1 group1_level    variable stat_name  stat warning  
         <chr>  <list>          <chr>    <chr>     <lis> <list>   
       1 ARM    Placebo         AGE      N         86    a warning
       2 ARM    Placebo         AGE      mean      75.2  <NULL>   
       3 ARM    Placebo         AGE      sd         8.59 <NULL>   
       4 ARM    Placebo         AGE      median    76    <NULL>   
       5 ARM    Placebo         AGE      p25       69    <NULL>   
       6 ARM    Placebo         AGE      p75       82    <NULL>   
       7 ARM    Placebo         AGE      min       52    <NULL>   
       8 ARM    Placebo         AGE      max       89    <NULL>   
       9 ARM    Xanomeline Hig~ AGE      N         84    <NULL>   
      10 ARM    Xanomeline Hig~ AGE      mean      74.4  <NULL>   
      # i 14 more rows
      # i 4 more variables: context <chr>, stat_label <chr>,
      #   fmt_fun <list>, error <list>

# print.compare_ard() works

    Code
      compare_ard(ard, ard)
    Message
      The comparison `keys` are "group1", "group1_level", "variable", "variable_level", and "stat_name".
      The comparison columns are "stat_label" and "stat".
      
      -- Mis-matched Rows ------------------------------------------------------------
      v No rows in `x` that do not appear in `y`.
      v No rows in `y` that do not appear in `x`.
      
      -- Comparison Results ----------------------------------------------------------
      v No differences found in column "stat_label".
      v No differences found in column "stat".

---

    Code
      compare_ard(ard, ard_subset)
    Message
      The comparison `keys` are "group1", "group1_level", "variable", "variable_level", and "stat_name".
      The comparison columns are "stat_label" and "stat".
      
      -- Mis-matched Rows ------------------------------------------------------------
      -- Rows in `x` that do not appear in `y`. 
    Output
      # An ARD data frame: 9 x 5
        group1 group1_level         variable variable_level stat_name
        <chr>  <list>               <chr>    <list>         <chr>    
      1 ARM    Placebo              AGEGR1   >80            n        
      2 ARM    Placebo              AGEGR1   >80            N        
      3 ARM    Placebo              AGEGR1   >80            p        
      4 ARM    Xanomeline High Dose AGEGR1   >80            n        
      5 ARM    Xanomeline High Dose AGEGR1   >80            N        
      6 ARM    Xanomeline High Dose AGEGR1   >80            p        
      7 ARM    Xanomeline Low Dose  AGEGR1   >80            n        
      8 ARM    Xanomeline Low Dose  AGEGR1   >80            N        
      9 ARM    Xanomeline Low Dose  AGEGR1   >80            p        
    Message
      v No rows in `y` that do not appear in `x`.
      
      -- Comparison Results ----------------------------------------------------------
      v No differences found in column "stat_label".
      ! Differences found in column "stat" for 12 rows.
    Output
      # An ARD data frame: 12 x 8
         group1 group1_level         variable variable_level stat_name  stat.x stat.y difference                         
         <chr>  <list>               <chr>    <list>         <chr>      <list> <list> <list>                             
       1 ARM    Placebo              AGEGR1   65-80          N         86      56     Mean relative difference: 0.3488372
       2 ARM    Placebo              AGEGR1   65-80          p          0.488   0.75  Mean relative difference: 0.5357143
       3 ARM    Placebo              AGEGR1   <65            N         86      56     Mean relative difference: 0.3488372
       4 ARM    Placebo              AGEGR1   <65            p          0.163   0.25  Mean relative difference: 0.5357143
       5 ARM    Xanomeline High Dose AGEGR1   65-80          N         84      66     Mean relative difference: 0.2142857
       6 ARM    Xanomeline High Dose AGEGR1   65-80          p          0.655   0.833 Mean relative difference: 0.2727273
       7 ARM    Xanomeline High Dose AGEGR1   <65            N         84      66     Mean relative difference: 0.2142857
       8 ARM    Xanomeline High Dose AGEGR1   <65            p          0.131   0.167 Mean relative difference: 0.2727273
       9 ARM    Xanomeline Low Dose  AGEGR1   65-80          N         84      55     Mean relative difference: 0.3452381
      10 ARM    Xanomeline Low Dose  AGEGR1   65-80          p          0.560   0.855 Mean relative difference: 0.5272727
      11 ARM    Xanomeline Low Dose  AGEGR1   <65            N         84      55     Mean relative difference: 0.3452381
      12 ARM    Xanomeline Low Dose  AGEGR1   <65            p          0.0952  0.145 Mean relative difference: 0.5272727

---

    Code
      compare_ard(ard_subset, ard)
    Message
      The comparison `keys` are "group1", "group1_level", "variable", "variable_level", and "stat_name".
      The comparison columns are "stat_label" and "stat".
      
      -- Mis-matched Rows ------------------------------------------------------------
      v No rows in `x` that do not appear in `y`.
      -- Rows in `y` that do not appear in `x`. 
    Output
      # An ARD data frame: 9 x 5
        group1 group1_level         variable variable_level stat_name
        <chr>  <list>               <chr>    <list>         <chr>    
      1 ARM    Placebo              AGEGR1   >80            n        
      2 ARM    Placebo              AGEGR1   >80            N        
      3 ARM    Placebo              AGEGR1   >80            p        
      4 ARM    Xanomeline High Dose AGEGR1   >80            n        
      5 ARM    Xanomeline High Dose AGEGR1   >80            N        
      6 ARM    Xanomeline High Dose AGEGR1   >80            p        
      7 ARM    Xanomeline Low Dose  AGEGR1   >80            n        
      8 ARM    Xanomeline Low Dose  AGEGR1   >80            N        
      9 ARM    Xanomeline Low Dose  AGEGR1   >80            p        
    Message
      
      -- Comparison Results ----------------------------------------------------------
      v No differences found in column "stat_label".
      ! Differences found in column "stat" for 12 rows.
    Output
      # An ARD data frame: 12 x 8
         group1 group1_level         variable variable_level stat_name stat.x  stat.y difference                         
         <chr>  <list>               <chr>    <list>         <chr>     <list>  <list> <list>                             
       1 ARM    Placebo              AGEGR1   65-80          N         56     86      Mean relative difference: 0.5357143
       2 ARM    Placebo              AGEGR1   65-80          p          0.75   0.488  Mean relative difference: 0.3488372
       3 ARM    Placebo              AGEGR1   <65            N         56     86      Mean relative difference: 0.5357143
       4 ARM    Placebo              AGEGR1   <65            p          0.25   0.163  Mean relative difference: 0.3488372
       5 ARM    Xanomeline High Dose AGEGR1   65-80          N         66     84      Mean relative difference: 0.2727273
       6 ARM    Xanomeline High Dose AGEGR1   65-80          p          0.833  0.655  Mean relative difference: 0.2142857
       7 ARM    Xanomeline High Dose AGEGR1   <65            N         66     84      Mean relative difference: 0.2727273
       8 ARM    Xanomeline High Dose AGEGR1   <65            p          0.167  0.131  Mean relative difference: 0.2142857
       9 ARM    Xanomeline Low Dose  AGEGR1   65-80          N         55     84      Mean relative difference: 0.5272727
      10 ARM    Xanomeline Low Dose  AGEGR1   65-80          p          0.855  0.560  Mean relative difference: 0.3452381
      11 ARM    Xanomeline Low Dose  AGEGR1   <65            N         55     84      Mean relative difference: 0.5272727
      12 ARM    Xanomeline Low Dose  AGEGR1   <65            p          0.145  0.0952 Mean relative difference: 0.3452381

# print.compare_ard() prints both mis-matched row blocks

    Code
      compare_ard(ard_no_high, ard_no_low)
    Message
      The comparison `keys` are "group1", "group1_level", "variable", "variable_level", and "stat_name".
      The comparison columns are "stat_label" and "stat".
      
      -- Mis-matched Rows ------------------------------------------------------------
      -- Rows in `x` that do not appear in `y`. 
    Output
      # An ARD data frame: 9 x 5
        group1 group1_level         variable variable_level stat_name
        <chr>  <list>               <chr>    <list>         <chr>    
      1 ARM    Placebo              AGEGR1   <65            n        
      2 ARM    Placebo              AGEGR1   <65            N        
      3 ARM    Placebo              AGEGR1   <65            p        
      4 ARM    Xanomeline High Dose AGEGR1   <65            n        
      5 ARM    Xanomeline High Dose AGEGR1   <65            N        
      6 ARM    Xanomeline High Dose AGEGR1   <65            p        
      7 ARM    Xanomeline Low Dose  AGEGR1   <65            n        
      8 ARM    Xanomeline Low Dose  AGEGR1   <65            N        
      9 ARM    Xanomeline Low Dose  AGEGR1   <65            p        
    Message
      -- Rows in `y` that do not appear in `x`. 
    Output
      # An ARD data frame: 9 x 5
        group1 group1_level         variable variable_level stat_name
        <chr>  <list>               <chr>    <list>         <chr>    
      1 ARM    Placebo              AGEGR1   >80            n        
      2 ARM    Placebo              AGEGR1   >80            N        
      3 ARM    Placebo              AGEGR1   >80            p        
      4 ARM    Xanomeline High Dose AGEGR1   >80            n        
      5 ARM    Xanomeline High Dose AGEGR1   >80            N        
      6 ARM    Xanomeline High Dose AGEGR1   >80            p        
      7 ARM    Xanomeline Low Dose  AGEGR1   >80            n        
      8 ARM    Xanomeline Low Dose  AGEGR1   >80            N        
      9 ARM    Xanomeline Low Dose  AGEGR1   >80            p        
    Message
      
      -- Comparison Results ----------------------------------------------------------
      v No differences found in column "stat_label".
      ! Differences found in column "stat" for 6 rows.
    Output
      # An ARD data frame: 6 x 8
        group1 group1_level         variable variable_level stat_name stat.x stat.y difference                          
        <chr>  <list>               <chr>    <list>         <chr>     <list> <list> <list>                              
      1 ARM    Placebo              AGEGR1   65-80          N         56     72     Mean relative difference: 0.2857143 
      2 ARM    Placebo              AGEGR1   65-80          p          0.75   0.583 Mean relative difference: 0.2222222 
      3 ARM    Xanomeline High Dose AGEGR1   65-80          N         66     73     Mean relative difference: 0.1060606 
      4 ARM    Xanomeline High Dose AGEGR1   65-80          p          0.833  0.753 Mean relative difference: 0.09589041
      5 ARM    Xanomeline Low Dose  AGEGR1   65-80          N         55     76     Mean relative difference: 0.3818182 
      6 ARM    Xanomeline Low Dose  AGEGR1   65-80          p          0.855  0.618 Mean relative difference: 0.2763158 

# print.compare_ard() truncates long mis-matched row blocks

    Code
      compare_ard(ard, ard_two_sites)
    Message
      The comparison `keys` are "variable", "variable_level", and "stat_name".
      The comparison columns are "stat_label" and "stat".
      
      -- Mis-matched Rows ------------------------------------------------------------
      -- Rows in `x` that do not appear in `y`. 
    Output
      # An ARD data frame: 45 x 3
         variable variable_level stat_name
         <chr>    <list>         <chr>    
       1 SITEID   702            n        
       2 SITEID   702            N        
       3 SITEID   702            p        
       4 SITEID   704            n        
       5 SITEID   704            N        
       6 SITEID   704            p        
       7 SITEID   705            n        
       8 SITEID   705            N        
       9 SITEID   705            p        
      10 SITEID   706            n        
      # i 35 more rows
    Message
      v No rows in `y` that do not appear in `x`.
      
      -- Comparison Results ----------------------------------------------------------
      v No differences found in column "stat_label".
      ! Differences found in column "stat" for 4 rows.
    Output
      # An ARD data frame: 4 x 6
        variable variable_level stat_name   stat.x stat.y difference                         
        <chr>    <list>         <chr>       <list> <list> <list>                             
      1 SITEID   701            N         254      59     Mean relative difference: 0.7677165
      2 SITEID   701            p           0.161   0.695 Mean relative difference: 3.305085 
      3 SITEID   703            N         254      59     Mean relative difference: 0.7677165
      4 SITEID   703            p           0.0709  0.305 Mean relative difference: 3.305085 


# mock_categorical()

    Code
      apply_fmt_fun(mock_categorical(variables = list(AGEGR1 = factor(c("<65", "65-80", ">80"), levels = c("<65", "65-80", ">80"))),
      by = list(TRTA = c("Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"))))
    Output
      # An ARD data frame: 27 x 12
         group1 group1_level         variable variable_level context     stat_name stat_label stat   stat_fmt fmt_fun warning error 
         <chr>  <list>               <chr>    <list>         <chr>       <chr>     <chr>      <list> <list>   <list>  <list>  <list>
       1 TRTA   Placebo              AGEGR1   <65            categorical n         n          <NULL> xx       <fn>    <NULL>  <NULL>
       2 TRTA   Placebo              AGEGR1   <65            categorical p         %          <NULL> xx.x     <fn>    <NULL>  <NULL>
       3 TRTA   Placebo              AGEGR1   <65            categorical N         N          <NULL> xx       <fn>    <NULL>  <NULL>
       4 TRTA   Placebo              AGEGR1   65-80          categorical n         n          <NULL> xx       <fn>    <NULL>  <NULL>
       5 TRTA   Placebo              AGEGR1   65-80          categorical p         %          <NULL> xx.x     <fn>    <NULL>  <NULL>
       6 TRTA   Placebo              AGEGR1   65-80          categorical N         N          <NULL> xx       <fn>    <NULL>  <NULL>
       7 TRTA   Placebo              AGEGR1   >80            categorical n         n          <NULL> xx       <fn>    <NULL>  <NULL>
       8 TRTA   Placebo              AGEGR1   >80            categorical p         %          <NULL> xx.x     <fn>    <NULL>  <NULL>
       9 TRTA   Placebo              AGEGR1   >80            categorical N         N          <NULL> xx       <fn>    <NULL>  <NULL>
      10 TRTA   Xanomeline High Dose AGEGR1   <65            categorical n         n          <NULL> xx       <fn>    <NULL>  <NULL>
      # i 17 more rows

# mock_categorical() messaging

    Code
      mock_categorical(variables = list(AGEGR1 = factor(c("<65", "65-80", ">80"),
      levels = c("<65", "65-80", ">80"))), statistic = ~ c("NOTASTATISTIC"))
    Condition
      Error in `mock_categorical()`:
      ! The elements of the `statistic` argument must be vector with one or more of "n", "p", and "N".

# mock_continuous()

    Code
      apply_fmt_fun(mock_continuous(variables = c("AGE", "BMIBL")))
    Output
      # An ARD data frame: 16 x 9
         variable context    stat_name stat_label stat   stat_fmt fmt_fun warning error 
         <chr>    <chr>      <chr>     <chr>      <list> <list>   <list>  <list>  <list>
       1 AGE      continuous N         N          <NULL> xx       <fn>    <NULL>  <NULL>
       2 AGE      continuous mean      Mean       <NULL> xx.x     <fn>    <NULL>  <NULL>
       3 AGE      continuous sd        SD         <NULL> xx.x     <fn>    <NULL>  <NULL>
       4 AGE      continuous median    Median     <NULL> xx.x     <fn>    <NULL>  <NULL>
       5 AGE      continuous p25       Q1         <NULL> xx.x     <fn>    <NULL>  <NULL>
       6 AGE      continuous p75       Q3         <NULL> xx.x     <fn>    <NULL>  <NULL>
       7 AGE      continuous min       Min        <NULL> xx.x     <fn>    <NULL>  <NULL>
       8 AGE      continuous max       Max        <NULL> xx.x     <fn>    <NULL>  <NULL>
       9 BMIBL    continuous N         N          <NULL> xx       <fn>    <NULL>  <NULL>
      10 BMIBL    continuous mean      Mean       <NULL> xx.x     <fn>    <NULL>  <NULL>
      11 BMIBL    continuous sd        SD         <NULL> xx.x     <fn>    <NULL>  <NULL>
      12 BMIBL    continuous median    Median     <NULL> xx.x     <fn>    <NULL>  <NULL>
      13 BMIBL    continuous p25       Q1         <NULL> xx.x     <fn>    <NULL>  <NULL>
      14 BMIBL    continuous p75       Q3         <NULL> xx.x     <fn>    <NULL>  <NULL>
      15 BMIBL    continuous min       Min        <NULL> xx.x     <fn>    <NULL>  <NULL>
      16 BMIBL    continuous max       Max        <NULL> xx.x     <fn>    <NULL>  <NULL>

# mock_continuous() messaging

    Code
      mock_continuous(variables = c("AGE", "BMIBL"), statistic = ~t.test)
    Condition
      Error in `mock_continuous()`:
      ! The elements of the `statistic` argument must be <character> vector of statistic names.

# mock_dichotomous()

    Code
      apply_fmt_fun(mock_dichotomous(variables = list(AGEGR1 = factor("65-80", levels = c("<65", "65-80", ">80"))), by = list(TRTA = c(
        "Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"))))
    Output
      # An ARD data frame: 9 x 12
        group1 group1_level         variable variable_level context     stat_name stat_label stat   stat_fmt fmt_fun warning error 
        <chr>  <list>               <chr>    <list>         <chr>       <chr>     <chr>      <list> <list>   <list>  <list>  <list>
      1 TRTA   Placebo              AGEGR1   65-80          dichotomous n         n          <NULL> xx       <fn>    <NULL>  <NULL>
      2 TRTA   Placebo              AGEGR1   65-80          dichotomous p         %          <NULL> xx.x     <fn>    <NULL>  <NULL>
      3 TRTA   Placebo              AGEGR1   65-80          dichotomous N         N          <NULL> xx       <fn>    <NULL>  <NULL>
      4 TRTA   Xanomeline High Dose AGEGR1   65-80          dichotomous n         n          <NULL> xx       <fn>    <NULL>  <NULL>
      5 TRTA   Xanomeline High Dose AGEGR1   65-80          dichotomous p         %          <NULL> xx.x     <fn>    <NULL>  <NULL>
      6 TRTA   Xanomeline High Dose AGEGR1   65-80          dichotomous N         N          <NULL> xx       <fn>    <NULL>  <NULL>
      7 TRTA   Xanomeline Low Dose  AGEGR1   65-80          dichotomous n         n          <NULL> xx       <fn>    <NULL>  <NULL>
      8 TRTA   Xanomeline Low Dose  AGEGR1   65-80          dichotomous p         %          <NULL> xx.x     <fn>    <NULL>  <NULL>
      9 TRTA   Xanomeline Low Dose  AGEGR1   65-80          dichotomous N         N          <NULL> xx       <fn>    <NULL>  <NULL>

# mock_dichotomous() messaging

    Code
      mock_dichotomous(variables = list(AGEGR1 = factor(c("<65", "65-80", ">80"),
      levels = c("<65", "65-80", ">80"))), by = list(TRTA = c("Placebo",
        "Xanomeline High Dose", "Xanomeline Low Dose")))
    Condition
      Error in `mock_dichotomous()`:
      ! The list values of `variables` argument must be length 1.

# mock_missing()

    Code
      apply_fmt_fun(mock_missing(variables = c("AGE", "BMIBL")))
    Output
      # An ARD data frame: 10 x 9
         variable context stat_name stat_label    stat   stat_fmt fmt_fun warning error 
         <chr>    <chr>   <chr>     <chr>         <list> <list>   <list>  <list>  <list>
       1 AGE      missing N_obs     Vector Length <NULL> xx       <fn>    <NULL>  <NULL>
       2 AGE      missing N_miss    N Missing     <NULL> xx       <fn>    <NULL>  <NULL>
       3 AGE      missing N_nonmiss N Non-missing <NULL> xx       <fn>    <NULL>  <NULL>
       4 AGE      missing p_miss    % Missing     <NULL> xx.x     <fn>    <NULL>  <NULL>
       5 AGE      missing p_nonmiss % Non-missing <NULL> xx.x     <fn>    <NULL>  <NULL>
       6 BMIBL    missing N_obs     Vector Length <NULL> xx       <fn>    <NULL>  <NULL>
       7 BMIBL    missing N_miss    N Missing     <NULL> xx       <fn>    <NULL>  <NULL>
       8 BMIBL    missing N_nonmiss N Non-missing <NULL> xx       <fn>    <NULL>  <NULL>
       9 BMIBL    missing p_miss    % Missing     <NULL> xx.x     <fn>    <NULL>  <NULL>
      10 BMIBL    missing p_nonmiss % Non-missing <NULL> xx.x     <fn>    <NULL>  <NULL>

# mock_missing() messaging

    Code
      mock_missing(variables = c("AGE", "BMIBL"), statistic = ~letters)
    Condition
      Error in `mock_missing()`:
      ! The elements of the `statistic` argument must be vector with one or more of "N_obs", "N_miss", "N_nonmiss", "p_miss", and "p_nonmiss".

# mock_attributes()

    Code
      mock_attributes(label = list(AGE = "Age", BMIBL = "Baseline BMI"))
    Output
      # An ARD data frame: 4 x 8
        variable context    stat_name stat_label     stat         fmt_fun warning error 
      * <chr>    <chr>      <chr>     <chr>          <list>       <list>  <list>  <list>
      1 AGE      attributes label     Variable Label Age          <fn>    <NULL>  <NULL>
      2 AGE      attributes class     Variable Class logical      <NULL>  <NULL>  <NULL>
      3 BMIBL    attributes label     Variable Label Baseline BMI <fn>    <NULL>  <NULL>
      4 BMIBL    attributes class     Variable Class logical      <NULL>  <NULL>  <NULL>

# mock_attributes() messaging

    Code
      mock_attributes(label = c("AGE", "BMIBL"))
    Condition
      Error in `mock_attributes()`:
      ! The `label` argument must be a named list.

# mock_total_n()

    Code
      apply_fmt_fun(mock_total_n())
    Output
      # An ARD data frame: 1 x 9
        variable        context stat_name stat_label stat   stat_fmt fmt_fun warning error 
        <chr>           <chr>   <chr>     <chr>      <list> <list>   <list>  <list>  <list>
      1 ..ard_total_n.. total_n N         N          <NULL> xx       <fn>    <NULL>  <NULL>


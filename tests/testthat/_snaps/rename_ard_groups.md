# rename_ard_groups_shift()

    Code
      dplyr::select(rename_ard_groups_shift(ard_summary(ADSL, variables = AGE, by = c(
        SEX, ARM)), shift = 1L), all_ard_groups()) %>% 1L[]
    Output
      # An ARD data frame: 1 x 4
        group2 group2_level group3 group3_level
        <chr>  <list>       <chr>  <list>      
      1 SEX    F            ARM    Placebo     

# rename_ard_groups_shift() messaging

    Code
      dplyr::select(rename_ard_groups_shift(ard_summary(ADSL, variables = AGE, by = c(
        SEX, ARM)), shift = -1L), all_ard_groups()) %>% 1L[]
    Message
      There are now non-standard group column names: "group0" and "group0_level".
      i Is this the shift you had planned?
    Output
      # An ARD data frame: 1 x 4
        group0 group0_level group1 group1_level
        <chr>  <list>       <chr>  <list>      
      1 SEX    F            ARM    Placebo     

# rename_ard_groups_reverse()

    Code
      dplyr::select(rename_ard_groups_reverse(ard_summary(ADSL, variables = AGE, by = c(
        SEX, ARM))), all_ard_groups()) %>% 1L[]
    Output
      # An ARD data frame: 1 x 4
        group1 group1_level group2 group2_level
        <chr>  <list>       <chr>  <list>      
      1 ARM    Placebo      SEX    F           


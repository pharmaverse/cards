# ard_tabulate_rows() works

    Code
      ard_tabulate_rows(ADSL, by = TRTA)
    Output
      # An ARD data frame: 3 x 11
        group1 group1_level variable variable_level context stat_name stat_label  stat
        <chr>  <list>       <chr>    <list>         <chr>   <chr>     <chr>      <lis>
      1 TRTA   Placebo      ..row_c~ TRUE           tabula~ n         n             86
      2 TRTA   Xanomeline ~ ..row_c~ TRUE           tabula~ n         n             84
      3 TRTA   Xanomeline ~ ..row_c~ TRUE           tabula~ n         n             84
      # i 3 more variables: fmt_fun <list>, warning <list>, error <list>


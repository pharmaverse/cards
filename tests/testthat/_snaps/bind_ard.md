# ARD helpers messaging

    Code
      bind_ard(ard, ard, .update = letters)
    Condition
      Error in `bind_ard()`:
      ! The `.update` argument must be a scalar with class <logical>, not a character vector.

---

    Code
      bind_ard(ard, ard, .distinct = FALSE, .update = FALSE)
    Condition
      Error in `bind_ard()`:
      ! 27 rows with duplicated statistic names have been found.
      i See cards::bind_ard(.update) (`?cards::bind_ard()`) for details.

# bind_ard() .order argument works

    Code
      dplyr::select(as.data.frame(bind_ard(ard_tabulate(ADSL, by = "ARM", variables = "SEX") %>% {
        dplyr::slice(., sample.int(nrow(.)))
      }, .order = TRUE)), -c(context, fmt_fun, warning, error))
    Output
         group1         group1_level variable variable_level stat_name stat_label      stat
      1     ARM  Xanomeline Low Dose      SEX              M         n          n        34
      2     ARM  Xanomeline Low Dose      SEX              M         p          % 0.4047619
      3     ARM  Xanomeline Low Dose      SEX              F         p          % 0.5952381
      4     ARM  Xanomeline Low Dose      SEX              M         N          N        84
      5     ARM  Xanomeline Low Dose      SEX              F         n          n        50
      6     ARM  Xanomeline Low Dose      SEX              F         N          N        84
      7     ARM              Placebo      SEX              M         p          % 0.3837209
      8     ARM              Placebo      SEX              M         n          n        33
      9     ARM              Placebo      SEX              F         n          n        53
      10    ARM              Placebo      SEX              F         N          N        86
      11    ARM              Placebo      SEX              F         p          % 0.6162791
      12    ARM              Placebo      SEX              M         N          N        86
      13    ARM Xanomeline High Dose      SEX              M         N          N        84
      14    ARM Xanomeline High Dose      SEX              M         p          % 0.5238095
      15    ARM Xanomeline High Dose      SEX              F         p          % 0.4761905
      16    ARM Xanomeline High Dose      SEX              F         N          N        84
      17    ARM Xanomeline High Dose      SEX              F         n          n        40
      18    ARM Xanomeline High Dose      SEX              M         n          n        44

---

    Code
      dplyr::select(as.data.frame(bind_ard(ard_tabulate(ADSL, by = "ARM", variables = "SEX") %>% {
        dplyr::slice(., sample.int(nrow(.)))
      }, .order = FALSE)), -c(context, fmt_fun, warning, error))
    Output
         group1         group1_level variable variable_level stat_name stat_label      stat
      1     ARM              Placebo      SEX              F         p          % 0.6162791
      2     ARM  Xanomeline Low Dose      SEX              F         N          N        84
      3     ARM              Placebo      SEX              M         n          n        33
      4     ARM Xanomeline High Dose      SEX              F         n          n        40
      5     ARM Xanomeline High Dose      SEX              F         p          % 0.4761905
      6     ARM              Placebo      SEX              F         n          n        53
      7     ARM Xanomeline High Dose      SEX              M         n          n        44
      8     ARM Xanomeline High Dose      SEX              M         N          N        84
      9     ARM              Placebo      SEX              M         p          % 0.3837209
      10    ARM              Placebo      SEX              M         N          N        86
      11    ARM  Xanomeline Low Dose      SEX              F         p          % 0.5952381
      12    ARM              Placebo      SEX              F         N          N        86
      13    ARM  Xanomeline Low Dose      SEX              M         p          % 0.4047619
      14    ARM Xanomeline High Dose      SEX              M         p          % 0.5238095
      15    ARM Xanomeline High Dose      SEX              F         N          N        84
      16    ARM  Xanomeline Low Dose      SEX              F         n          n        50
      17    ARM  Xanomeline Low Dose      SEX              M         N          N        84
      18    ARM  Xanomeline Low Dose      SEX              M         n          n        34

# bind_ard(.distinct)

    Code
      ard_summary(ADSL, variables = AGE) %>% {
        bind_ard(., ., .update = FALSE)
      }
    Message
      i 8 rows with duplicated statistic values have been removed.
      * See cards::bind_ard(.distinct) (`?cards::bind_ard()`) for details.
    Output
      # An ARD data frame: 8 x 8
        variable context stat_name stat_label   stat fmt_fun warning error 
        <chr>    <chr>   <chr>     <chr>      <list>  <list> <list>  <list>
      1 AGE      summary N         N          254          0 <NULL>  <NULL>
      2 AGE      summary mean      Mean        75.1        1 <NULL>  <NULL>
      3 AGE      summary sd        SD           8.25       1 <NULL>  <NULL>
      4 AGE      summary median    Median      77          1 <NULL>  <NULL>
      5 AGE      summary p25       Q1          70          1 <NULL>  <NULL>
      6 AGE      summary p75       Q3          81          1 <NULL>  <NULL>
      7 AGE      summary min       Min         51          1 <NULL>  <NULL>
      8 AGE      summary max       Max         89          1 <NULL>  <NULL>


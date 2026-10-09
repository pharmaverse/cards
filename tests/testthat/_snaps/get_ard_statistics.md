# get_ard_statistics() works

    Code
      get_ard_statistics(ard, group1_level %in% "Placebo", variable_level %in%
      "65-80")
    Output
      $n
      [1] 42
      
      $N
      [1] 86
      
      $p
      [1] 0.4883721
      

---

    Code
      get_ard_statistics(ard, group1_level %in% "Placebo", variable_level %in%
      "65-80", .attributes = "stat_label")
    Output
      $n
      [1] 42
      attr(,"stat_label")
      [1] "n"
      
      $N
      [1] 86
      attr(,"stat_label")
      [1] "N"
      
      $p
      [1] 0.4883721
      attr(,"stat_label")
      [1] "%"
      


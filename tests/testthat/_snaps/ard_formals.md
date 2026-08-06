# ard_formals() works

    Code
      ard_formals(fun = mcnemar.test, arg_names = "correct")
    Output
      # An ARD data frame: 1 x 3
        stat_name stat_label stat  
      * <chr>     <chr>      <list>
      1 correct   correct    TRUE  

---

    Code
      ard_formals(fun = asNamespace("stats")[["t.test.default"]], arg_names = c("mu",
        "paired", "var.equal", "conf.level"), passed_args = list(conf.level = 0.9))
    Output
      # An ARD data frame: 4 x 3
        stat_name  stat_label   stat
      * <chr>      <chr>      <list>
      1 mu         mu            0  
      2 paired     paired        0  
      3 var.equal  var.equal     0  
      4 conf.level conf.level    0.9


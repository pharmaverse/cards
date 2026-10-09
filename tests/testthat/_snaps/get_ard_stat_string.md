# get_ard_stat_string() errors with bad inputs

    Code
      get_ard_stat_string(mtcars, pattern = "{n}")
    Condition
      Error in `get_ard_stat_string()`:
      ! The `x` argument must be class <card>, not a data frame.

---

    Code
      get_ard_stat_string(ard, pattern = 1L)
    Condition
      Error in `get_ard_stat_string()`:
      ! The `pattern` argument must be a string, not an integer.

---

    Code
      get_ard_stat_string(ard, pattern = "no stats")
    Condition
      Error in `get_ard_stat_string()`:
      ! The `pattern` argument must reference at least one statistic in curly brackets, e.g. "{n} ({p}%)".

---

    Code
      get_ard_stat_string(ard, group1_level %in% "Placebo", variable_level %in%
        "65-80", pattern = "{n} ({not_a_stat})")
    Condition
      Error in `get_ard_stat_string()`:
      ! Each statistic in `pattern` must appear in exactly one row of the subset ARD.
      x Statistic "not_a_stat" not found.

---

    Code
      get_ard_stat_string(ard, variable_level %in% "65-80", pattern = "{n} / {N}")
    Condition
      Error in `get_ard_stat_string()`:
      ! Each statistic in `pattern` must appear in exactly one row of the subset ARD.
      x Statistics "n" and "N" found in more than one row.


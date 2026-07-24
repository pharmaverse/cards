# ard_tabulate() univariate

    Code
      class(ard_cat_uni)
    Output
      [1] "card"       "tbl_df"     "tbl"        "data.frame"

# ard_tabulate() univariate & specified denomiator

    Code
      class(ard_cat_new_denom)
    Output
      [1] "card"       "tbl_df"     "tbl"        "data.frame"

# ard_tabulate(fmt_fun) argument works

    Code
      as.data.frame(dplyr::select(apply_fmt_fun(ard_tabulate(mtcars, variables = "am",
        fmt_fun = list(am = list(p = function(x) as.character(round5(x * 100, digits = 3)),
        N = function(x) format(round5(x, digits = 2), nsmall = 2), N_obs = function(x)
          format(round5(x, digits = 2), nsmall = 2))))), variable, variable_level,
      stat_name, stat, stat_fmt))
    Output
        variable variable_level stat_name    stat stat_fmt
      1       am              0         n      19       19
      2       am              0         N      32    32.00
      3       am              0         p 0.59375   59.375
      4       am              1         n      13       13
      5       am              1         N      32    32.00
      6       am              1         p 0.40625   40.625

---

    Code
      as.data.frame(dplyr::select(apply_fmt_fun(ard_tabulate(mtcars, variables = c(
        "am", "vs"), fmt_fun = list(am = list(p = function(x) round5(x * 100, digits = 3)),
      vs = list(p = function(x) round5(x * 100, digits = 1))))), variable,
      variable_level, stat_name, stat, stat_fmt))
    Output
         variable variable_level stat_name    stat stat_fmt
      1        am              0         n      19       19
      2        am              0         N      32       32
      3        am              0         p 0.59375   59.375
      4        am              1         n      13       13
      5        am              1         N      32       32
      6        am              1         p 0.40625   40.625
      7        vs              0         n      18       18
      8        vs              0         N      32       32
      9        vs              0         p  0.5625     56.3
      10       vs              1         n      14       14
      11       vs              1         N      32       32
      12       vs              1         p  0.4375     43.8

# ard_tabulate() with strata and by arguments

    Code
      ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1", denominator = dplyr::filter(
        ADSL, ARM %in% "Placebo"))
    Condition
      Error in `ard_tabulate()`:
      ! The following `by/strata` combinations are missing from the `denominator` data frame: ARM (Xanomeline High Dose) and ARM (Xanomeline Low Dose).

# ard_tabulate(stat_label) argument works

    Code
      unique(dplyr::select(dplyr::filter(as.data.frame(ard_tabulate(data = ADSL, by = "ARM",
        variables = c("AGEGR1", "SEX"), stat_label = everything() ~ list(c("n", "p") ~
          "n (pct)"))), stat_name %in% c("n", "p")), stat_name, stat_label))
    Output
        stat_name stat_label
      1         n    n (pct)
      2         p    n (pct)

---

    Code
      unique(dplyr::select(dplyr::filter(as.data.frame(ard_tabulate(data = ADSL, by = "ARM",
        variables = c("AGEGR1", "SEX"), stat_label = everything() ~ list(n = "num",
          p = "pct"))), stat_name %in% c("n", "p")), stat_name, stat_label))
    Output
        stat_name stat_label
      1         n        num
      2         p        pct

---

    Code
      unique(dplyr::select(dplyr::filter(as.data.frame(ard_tabulate(data = ADSL, by = "ARM",
        variables = c("AGEGR1", "SEX"), stat_label = AGEGR1 ~ list(c("n", "p") ~
          "n (pct)"))), stat_name %in% c("n", "p")), variable, stat_name, stat_label))
    Output
        variable stat_name stat_label
      1   AGEGR1         n    n (pct)
      2   AGEGR1         p    n (pct)
      7      SEX         n          n
      8      SEX         p          %

# ard_tabulate(denominator='row') works

    Code
      as.data.frame(dplyr::select(apply_fmt_fun(ard_with_args), -fmt_fun, -warning, -error))
    Output
         group1         group1_level variable variable_level  context stat_name stat_label stat stat_fmt
      1     ARM              Placebo   AGEGR1          65-80 tabulate         n          n   42    42.00
      2     ARM              Placebo   AGEGR1          65-80 tabulate         N          N  144      144
      3     ARM              Placebo   AGEGR1            <65 tabulate         n          n   14    14.00
      4     ARM              Placebo   AGEGR1            <65 tabulate         N          N   33       33
      5     ARM              Placebo   AGEGR1            >80 tabulate         n          n   30    30.00
      6     ARM              Placebo   AGEGR1            >80 tabulate         N          N   77       77
      7     ARM Xanomeline High Dose   AGEGR1          65-80 tabulate         n          n   55    55.00
      8     ARM Xanomeline High Dose   AGEGR1          65-80 tabulate         N          N  144      144
      9     ARM Xanomeline High Dose   AGEGR1            <65 tabulate         n          n   11    11.00
      10    ARM Xanomeline High Dose   AGEGR1            <65 tabulate         N          N   33       33
      11    ARM Xanomeline High Dose   AGEGR1            >80 tabulate         n          n   18    18.00
      12    ARM Xanomeline High Dose   AGEGR1            >80 tabulate         N          N   77       77
      13    ARM  Xanomeline Low Dose   AGEGR1          65-80 tabulate         n          n   47    47.00
      14    ARM  Xanomeline Low Dose   AGEGR1          65-80 tabulate         N          N  144      144
      15    ARM  Xanomeline Low Dose   AGEGR1            <65 tabulate         n          n    8     8.00
      16    ARM  Xanomeline Low Dose   AGEGR1            <65 tabulate         N          N   33       33
      17    ARM  Xanomeline Low Dose   AGEGR1            >80 tabulate         n          n   29    29.00
      18    ARM  Xanomeline Low Dose   AGEGR1            >80 tabulate         N          N   77       77

# ard_tabulate(denominator=<data frame with counts>) works

    Code
      ard_tabulate(ADSL, by = ARM, variables = AGEGR1, denominator = data.frame(ARM = c(
        "Placebo", "Placebo", "Xanomeline High Dose", "Xanomeline Low Dose"),
      ...ard_N... = c(86, 86, 84, 84)))
    Condition
      Error in `ard_tabulate()`:
      ! Specified counts in column "'...ard_N...'" are not unique in the `denominator` argument across the `by` and `strata` columns.

---

    Code
      ard_tabulate(ADSL, by = ARM, variables = AGEGR1, denominator = data.frame(ARM = "Placebo",
        ...ard_N... = 86))
    Condition
      Error in `ard_tabulate()`:
      ! The following `by/strata` combinations are missing from the `denominator` data frame: ARM (Xanomeline High Dose) and ARM (Xanomeline Low Dose).

# ard_tabulate() and all NA columns

    Code
      ard_tabulate(dplyr::mutate(ADSL, AGEGR1 = NA_character_), variables = AGEGR1)
    Condition
      Error in `ard_tabulate()`:
      ! Column "AGEGR1" is all missing and cannot by tabulated.
      i Only columns of class <logical> and <factor> can be tabulated when all values are missing.

# ard_tabulate(by) messages about protected names

    Code
      ard_tabulate(mtcars2, by = variable, variables = gear)
    Condition
      Error in `ard_tabulate()`:
      ! The `by` argument cannot include variables named "variable" and "variable_level".

---

    Code
      ard_tabulate(mtcars2, by = variable, variables = by)
    Condition
      Error in `ard_tabulate()`:
      ! The `by` argument cannot include variables named "variable" and "variable_level".

# ard_tabulate() errors with incomplete factor columns

    Code
      ard_tabulate(dplyr::mutate(mtcars, am = factor(am, levels = character(0))),
      variables = am)
    Condition
      Error in `ard_tabulate()`:
      ! Factors with empty "levels" attribute are not allowed, which was identified in column "am".

---

    Code
      ard_tabulate(dplyr::mutate(mtcars, am = factor(am, levels = c(0, 1, NA),
      exclude = NULL)), variables = am)
    Condition
      Error in `ard_tabulate()`:
      ! Factors with NA levels are not allowed, which are present in column "am".

# ard_tabulate() with cumulative counts messaging

    Code
      ard_tabulate(ADSL, variables = "AGEGR1", by = SEX, statistic = everything() ~ c(
        "n", "p", "n_cum", "p_cum"), denominator = NULL)
    Condition
      Error in `ard_tabulate()`:
      ! The `denominator` argument must be one of "column" and "row" when cumulative statistics "n_cum" or "p_cum" are specified, which were requested for variable `AGEGR1`.

# ard_tabulate(data, denominator) class mis-match

    Code
      ard <- ard_tabulate(data = ADSL, variables = AGEGR1, by = TRTA, denominator = dplyr::mutate(
        ADSL, TRTA = as.factor(TRTA)))
    Message
      The classes for column "TRTA" in `data` (<character>) and `denominator` (<factor>) do not match, which may cause downstream issues.

# ard_tabulate() row order is stable with by + multiple strata

    Code
      as.data.frame(dplyr::select(ard_tabulate(mtcars, by = am, strata = c(cyl, vs), variables = gear, statistic = ~ c("n", "N", "p", "n_cum", "p_cum")), all_ard_groups(), all_ard_variables(), "stat_name",
      "stat"))
    Output
          group1 group1_level group2 group2_level group3 group3_level variable variable_level stat_name      stat
      1       am            0    cyl            4     vs            0     gear              3         n         0
      2       am            0    cyl            4     vs            0     gear              3         N         0
      3       am            0    cyl            4     vs            0     gear              3         p       NaN
      4       am            0    cyl            4     vs            0     gear              3     n_cum         0
      5       am            0    cyl            4     vs            0     gear              3     p_cum       NaN
      6       am            0    cyl            4     vs            0     gear              4         n         0
      7       am            0    cyl            4     vs            0     gear              4         N         0
      8       am            0    cyl            4     vs            0     gear              4         p       NaN
      9       am            0    cyl            4     vs            0     gear              4     n_cum         0
      10      am            0    cyl            4     vs            0     gear              4     p_cum       NaN
      11      am            0    cyl            4     vs            0     gear              5         n         0
      12      am            0    cyl            4     vs            0     gear              5         N         0
      13      am            0    cyl            4     vs            0     gear              5         p       NaN
      14      am            0    cyl            4     vs            0     gear              5     n_cum         0
      15      am            0    cyl            4     vs            0     gear              5     p_cum       NaN
      16      am            0    cyl            4     vs            1     gear              3         n         1
      17      am            0    cyl            4     vs            1     gear              3         N         3
      18      am            0    cyl            4     vs            1     gear              3         p 0.3333333
      19      am            0    cyl            4     vs            1     gear              3     n_cum         1
      20      am            0    cyl            4     vs            1     gear              3     p_cum 0.3333333
      21      am            0    cyl            4     vs            1     gear              4         n         2
      22      am            0    cyl            4     vs            1     gear              4         N         3
      23      am            0    cyl            4     vs            1     gear              4         p 0.6666667
      24      am            0    cyl            4     vs            1     gear              4     n_cum         3
      25      am            0    cyl            4     vs            1     gear              4     p_cum         1
      26      am            0    cyl            4     vs            1     gear              5         n         0
      27      am            0    cyl            4     vs            1     gear              5         N         3
      28      am            0    cyl            4     vs            1     gear              5         p         0
      29      am            0    cyl            4     vs            1     gear              5     n_cum         3
      30      am            0    cyl            4     vs            1     gear              5     p_cum         1
      31      am            0    cyl            6     vs            0     gear              3         n         0
      32      am            0    cyl            6     vs            0     gear              3         N         0
      33      am            0    cyl            6     vs            0     gear              3         p       NaN
      34      am            0    cyl            6     vs            0     gear              3     n_cum         0
      35      am            0    cyl            6     vs            0     gear              3     p_cum       NaN
      36      am            0    cyl            6     vs            0     gear              4         n         0
      37      am            0    cyl            6     vs            0     gear              4         N         0
      38      am            0    cyl            6     vs            0     gear              4         p       NaN
      39      am            0    cyl            6     vs            0     gear              4     n_cum         0
      40      am            0    cyl            6     vs            0     gear              4     p_cum       NaN
      41      am            0    cyl            6     vs            0     gear              5         n         0
      42      am            0    cyl            6     vs            0     gear              5         N         0
      43      am            0    cyl            6     vs            0     gear              5         p       NaN
      44      am            0    cyl            6     vs            0     gear              5     n_cum         0
      45      am            0    cyl            6     vs            0     gear              5     p_cum       NaN
      46      am            0    cyl            6     vs            1     gear              3         n         2
      47      am            0    cyl            6     vs            1     gear              3         N         4
      48      am            0    cyl            6     vs            1     gear              3         p       0.5
      49      am            0    cyl            6     vs            1     gear              3     n_cum         2
      50      am            0    cyl            6     vs            1     gear              3     p_cum       0.5
      51      am            0    cyl            6     vs            1     gear              4         n         2
      52      am            0    cyl            6     vs            1     gear              4         N         4
      53      am            0    cyl            6     vs            1     gear              4         p       0.5
      54      am            0    cyl            6     vs            1     gear              4     n_cum         4
      55      am            0    cyl            6     vs            1     gear              4     p_cum         1
      56      am            0    cyl            6     vs            1     gear              5         n         0
      57      am            0    cyl            6     vs            1     gear              5         N         4
      58      am            0    cyl            6     vs            1     gear              5         p         0
      59      am            0    cyl            6     vs            1     gear              5     n_cum         4
      60      am            0    cyl            6     vs            1     gear              5     p_cum         1
      61      am            0    cyl            8     vs            0     gear              3         n        12
      62      am            0    cyl            8     vs            0     gear              3         N        12
      63      am            0    cyl            8     vs            0     gear              3         p         1
      64      am            0    cyl            8     vs            0     gear              3     n_cum        12
      65      am            0    cyl            8     vs            0     gear              3     p_cum         1
      66      am            0    cyl            8     vs            0     gear              4         n         0
      67      am            0    cyl            8     vs            0     gear              4         N        12
      68      am            0    cyl            8     vs            0     gear              4         p         0
      69      am            0    cyl            8     vs            0     gear              4     n_cum        12
      70      am            0    cyl            8     vs            0     gear              4     p_cum         1
      71      am            0    cyl            8     vs            0     gear              5         n         0
      72      am            0    cyl            8     vs            0     gear              5         N        12
      73      am            0    cyl            8     vs            0     gear              5         p         0
      74      am            0    cyl            8     vs            0     gear              5     n_cum        12
      75      am            0    cyl            8     vs            0     gear              5     p_cum         1
      76      am            1    cyl            4     vs            0     gear              3         n         0
      77      am            1    cyl            4     vs            0     gear              3         N         1
      78      am            1    cyl            4     vs            0     gear              3         p         0
      79      am            1    cyl            4     vs            0     gear              3     n_cum         0
      80      am            1    cyl            4     vs            0     gear              3     p_cum         0
      81      am            1    cyl            4     vs            0     gear              4         n         0
      82      am            1    cyl            4     vs            0     gear              4         N         1
      83      am            1    cyl            4     vs            0     gear              4         p         0
      84      am            1    cyl            4     vs            0     gear              4     n_cum         0
      85      am            1    cyl            4     vs            0     gear              4     p_cum         0
      86      am            1    cyl            4     vs            0     gear              5         n         1
      87      am            1    cyl            4     vs            0     gear              5         N         1
      88      am            1    cyl            4     vs            0     gear              5         p         1
      89      am            1    cyl            4     vs            0     gear              5     n_cum         1
      90      am            1    cyl            4     vs            0     gear              5     p_cum         1
      91      am            1    cyl            4     vs            1     gear              3         n         0
      92      am            1    cyl            4     vs            1     gear              3         N         7
      93      am            1    cyl            4     vs            1     gear              3         p         0
      94      am            1    cyl            4     vs            1     gear              3     n_cum         0
      95      am            1    cyl            4     vs            1     gear              3     p_cum         0
      96      am            1    cyl            4     vs            1     gear              4         n         6
      97      am            1    cyl            4     vs            1     gear              4         N         7
      98      am            1    cyl            4     vs            1     gear              4         p 0.8571429
      99      am            1    cyl            4     vs            1     gear              4     n_cum         6
      100     am            1    cyl            4     vs            1     gear              4     p_cum 0.8571429
      101     am            1    cyl            4     vs            1     gear              5         n         1
      102     am            1    cyl            4     vs            1     gear              5         N         7
      103     am            1    cyl            4     vs            1     gear              5         p 0.1428571
      104     am            1    cyl            4     vs            1     gear              5     n_cum         7
      105     am            1    cyl            4     vs            1     gear              5     p_cum         1
      106     am            1    cyl            6     vs            0     gear              3         n         0
      107     am            1    cyl            6     vs            0     gear              3         N         3
      108     am            1    cyl            6     vs            0     gear              3         p         0
      109     am            1    cyl            6     vs            0     gear              3     n_cum         0
      110     am            1    cyl            6     vs            0     gear              3     p_cum         0
      111     am            1    cyl            6     vs            0     gear              4         n         2
      112     am            1    cyl            6     vs            0     gear              4         N         3
      113     am            1    cyl            6     vs            0     gear              4         p 0.6666667
      114     am            1    cyl            6     vs            0     gear              4     n_cum         2
      115     am            1    cyl            6     vs            0     gear              4     p_cum 0.6666667
      116     am            1    cyl            6     vs            0     gear              5         n         1
      117     am            1    cyl            6     vs            0     gear              5         N         3
      118     am            1    cyl            6     vs            0     gear              5         p 0.3333333
      119     am            1    cyl            6     vs            0     gear              5     n_cum         3
      120     am            1    cyl            6     vs            0     gear              5     p_cum         1
      121     am            1    cyl            6     vs            1     gear              3         n         0
      122     am            1    cyl            6     vs            1     gear              3         N         0
      123     am            1    cyl            6     vs            1     gear              3         p       NaN
      124     am            1    cyl            6     vs            1     gear              3     n_cum         0
      125     am            1    cyl            6     vs            1     gear              3     p_cum       NaN
      126     am            1    cyl            6     vs            1     gear              4         n         0
      127     am            1    cyl            6     vs            1     gear              4         N         0
      128     am            1    cyl            6     vs            1     gear              4         p       NaN
      129     am            1    cyl            6     vs            1     gear              4     n_cum         0
      130     am            1    cyl            6     vs            1     gear              4     p_cum       NaN
      131     am            1    cyl            6     vs            1     gear              5         n         0
      132     am            1    cyl            6     vs            1     gear              5         N         0
      133     am            1    cyl            6     vs            1     gear              5         p       NaN
      134     am            1    cyl            6     vs            1     gear              5     n_cum         0
      135     am            1    cyl            6     vs            1     gear              5     p_cum       NaN
      136     am            1    cyl            8     vs            0     gear              3         n         0
      137     am            1    cyl            8     vs            0     gear              3         N         2
      138     am            1    cyl            8     vs            0     gear              3         p         0
      139     am            1    cyl            8     vs            0     gear              3     n_cum         0
      140     am            1    cyl            8     vs            0     gear              3     p_cum         0
      141     am            1    cyl            8     vs            0     gear              4         n         0
      142     am            1    cyl            8     vs            0     gear              4         N         2
      143     am            1    cyl            8     vs            0     gear              4         p         0
      144     am            1    cyl            8     vs            0     gear              4     n_cum         0
      145     am            1    cyl            8     vs            0     gear              4     p_cum         0
      146     am            1    cyl            8     vs            0     gear              5         n         2
      147     am            1    cyl            8     vs            0     gear              5         N         2
      148     am            1    cyl            8     vs            0     gear              5         p         1
      149     am            1    cyl            8     vs            0     gear              5     n_cum         2
      150     am            1    cyl            8     vs            0     gear              5     p_cum         1

# ard_tabulate() strata combinations containing NA yield a single NA row

    Code
      as.data.frame(dplyr::select(ard_tabulate(df_na_strata, variables = var, by = trt, strata = str), all_ard_groups(), all_ard_variables(), "stat_name", "stat"))
    Output
         group1 group1_level group2 group2_level variable variable_level stat_name stat
      1     trt            A    str           s1      var              x         n    1
      2     trt            A    str           s1      var              x         N    2
      3     trt            A    str           s1      var              x         p  0.5
      4     trt            A    str           s1      var              y         n    1
      5     trt            A    str           s1      var              y         N    2
      6     trt            A    str           s1      var              y         p  0.5
      7     trt            A    str           s2      var              x         n    0
      8     trt            A    str           s2      var              x         N    0
      9     trt            A    str           s2      var              x         p  NaN
      10    trt            A    str           s2      var              y         n    0
      11    trt            A    str           s2      var              y         N    0
      12    trt            A    str           s2      var              y         p  NaN
      13    trt            B    str           s1      var              x         n    0
      14    trt            B    str           s1      var              x         N    0
      15    trt            B    str           s1      var              x         p  NaN
      16    trt            B    str           s1      var              y         n    0
      17    trt            B    str           s1      var              y         N    0
      18    trt            B    str           s1      var              y         p  NaN
      19    trt            B    str           s2      var              x         n    1
      20    trt            B    str           s2      var              x         N    1
      21    trt            B    str           s2      var              x         p    1
      22    trt            B    str           s2      var              y         n    0
      23    trt            B    str           s2      var              y         N    1
      24    trt            B    str           s2      var              y         p    0
      25    trt           NA    str           NA      var             NA         n   NA
      26    trt           NA    str           NA      var             NA         N   NA
      27    trt           NA    str           NA      var             NA         p   NA

---

    Code
      as.data.frame(dplyr::select(ard_tabulate(df_na_strata, variables = var, by = trt, strata = str, denominator = "cell"), all_ard_groups(), all_ard_variables(), "stat_name", "stat"))
    Output
         group1 group1_level group2 group2_level variable variable_level stat_name      stat
      1     trt            A    str           s1      var              x         n         1
      2     trt            A    str           s1      var              x         N         3
      3     trt            A    str           s1      var              x         p 0.3333333
      4     trt            A    str           s1      var              y         n         1
      5     trt            A    str           s1      var              y         N         3
      6     trt            A    str           s1      var              y         p 0.3333333
      7     trt            A    str           s2      var              x         n         0
      8     trt            A    str           s2      var              x         N         3
      9     trt            A    str           s2      var              x         p         0
      10    trt            A    str           s2      var              y         n         0
      11    trt            A    str           s2      var              y         N         3
      12    trt            A    str           s2      var              y         p         0
      13    trt            B    str           s1      var              x         n         0
      14    trt            B    str           s1      var              x         N         3
      15    trt            B    str           s1      var              x         p         0
      16    trt            B    str           s1      var              y         n         0
      17    trt            B    str           s1      var              y         N         3
      18    trt            B    str           s1      var              y         p         0
      19    trt            B    str           s2      var              x         n         1
      20    trt            B    str           s2      var              x         N         3
      21    trt            B    str           s2      var              x         p 0.3333333
      22    trt            B    str           s2      var              y         n         0
      23    trt            B    str           s2      var              y         N         3
      24    trt            B    str           s2      var              y         p         0
      25    trt           NA    str           NA      var             NA         n        NA
      26    trt           NA    str           NA      var             NA         N         3
      27    trt           NA    str           NA      var             NA         p        NA

---

    Code
      as.data.frame(dplyr::select(ard_tabulate(df_na_strata, variables = var, by = trt, strata = str, denominator = 100L), all_ard_groups(), all_ard_variables(), "stat_name", "stat"))
    Output
         group1 group1_level group2 group2_level variable variable_level stat_name stat
      1     trt            A    str           s1      var              x         n    1
      2     trt            A    str           s1      var              x         N  100
      3     trt            A    str           s1      var              x         p 0.01
      4     trt            A    str           s1      var              y         n    1
      5     trt            A    str           s1      var              y         N  100
      6     trt            A    str           s1      var              y         p 0.01
      7     trt            A    str           s2      var              x         n    0
      8     trt            A    str           s2      var              x         N  100
      9     trt            A    str           s2      var              x         p    0
      10    trt            A    str           s2      var              y         n    0
      11    trt            A    str           s2      var              y         N  100
      12    trt            A    str           s2      var              y         p    0
      13    trt            B    str           s1      var              x         n    0
      14    trt            B    str           s1      var              x         N  100
      15    trt            B    str           s1      var              x         p    0
      16    trt            B    str           s1      var              y         n    0
      17    trt            B    str           s1      var              y         N  100
      18    trt            B    str           s1      var              y         p    0
      19    trt            B    str           s2      var              x         n    1
      20    trt            B    str           s2      var              x         N  100
      21    trt            B    str           s2      var              x         p 0.01
      22    trt            B    str           s2      var              y         n    0
      23    trt            B    str           s2      var              y         N  100
      24    trt            B    str           s2      var              y         p    0
      25    trt           NA    str           NA      var             NA         n   NA
      26    trt           NA    str           NA      var             NA         N  100
      27    trt           NA    str           NA      var             NA         p   NA

# ard_tabulate() handles NaN and Inf in numeric variables

    Code
      as.data.frame(dplyr::select(ard_tabulate(data.frame(x = c(1, 2, NaN, Inf, 2, 1, Inf)), variables = x), all_ard_groups(), all_ard_variables(), "stat_name", "stat"))
    Output
        variable variable_level stat_name      stat
      1        x              1         n         2
      2        x              1         N         6
      3        x              1         p 0.3333333
      4        x              2         n         2
      5        x              2         N         6
      6        x              2         p 0.3333333
      7        x            Inf         n         2
      8        x            Inf         N         6
      9        x            Inf         p 0.3333333

# ard_tabulate() errors when a column is in both variables and by/strata

    Code
      ard_tabulate(ADSL, by = "ARM", variables = "ARM")
    Condition
      Error in `dplyr::mutate()`:
      ! Can't transform a data frame with duplicate names.

---

    Code
      ard_tabulate(ADSL, strata = "AGEGR1", variables = "AGEGR1")
    Condition
      Error in `dplyr::mutate()`:
      ! Can't transform a data frame with duplicate names.

# ard_tabulate() with NA values in a by column drops the NA group

    Code
      as.data.frame(dplyr::select(ard_tabulate(data.frame(b = c("g1", "g1", NA, "g2"), x = c("u", "v", "u", "u")), variables = x, by = b), all_ard_groups(), all_ard_variables(), "stat_name", "stat"))
    Output
         group1 group1_level variable variable_level stat_name stat
      1       b           g1        x              u         n    1
      2       b           g1        x              u         N    2
      3       b           g1        x              u         p  0.5
      4       b           g1        x              v         n    1
      5       b           g1        x              v         N    2
      6       b           g1        x              v         p  0.5
      7       b           g2        x              u         n    1
      8       b           g2        x              u         N    1
      9       b           g2        x              u         p    1
      10      b           g2        x              v         n    0
      11      b           g2        x              v         N    1
      12      b           g2        x              v         p    0

# ard_tabulate(denominator='row') is stable with two by columns

    Code
      as.data.frame(dplyr::select(ard_tabulate(mtcars, by = c(am, vs), variables = gear, denominator = "row"), all_ard_groups(), all_ard_variables(), "stat_name", "stat"))
    Output
         group1 group1_level group2 group2_level variable variable_level stat_name      stat
      1      am            0     vs            0     gear              3         n        12
      2      am            0     vs            0     gear              3         N        15
      3      am            0     vs            0     gear              3         p       0.8
      4      am            0     vs            0     gear              4         n         0
      5      am            0     vs            0     gear              4         N        12
      6      am            0     vs            0     gear              4         p         0
      7      am            0     vs            0     gear              5         n         0
      8      am            0     vs            0     gear              5         N         5
      9      am            0     vs            0     gear              5         p         0
      10     am            0     vs            1     gear              3         n         3
      11     am            0     vs            1     gear              3         N        15
      12     am            0     vs            1     gear              3         p       0.2
      13     am            0     vs            1     gear              4         n         4
      14     am            0     vs            1     gear              4         N        12
      15     am            0     vs            1     gear              4         p 0.3333333
      16     am            0     vs            1     gear              5         n         0
      17     am            0     vs            1     gear              5         N         5
      18     am            0     vs            1     gear              5         p         0
      19     am            1     vs            0     gear              3         n         0
      20     am            1     vs            0     gear              3         N        15
      21     am            1     vs            0     gear              3         p         0
      22     am            1     vs            0     gear              4         n         2
      23     am            1     vs            0     gear              4         N        12
      24     am            1     vs            0     gear              4         p 0.1666667
      25     am            1     vs            0     gear              5         n         4
      26     am            1     vs            0     gear              5         N         5
      27     am            1     vs            0     gear              5         p       0.8
      28     am            1     vs            1     gear              3         n         0
      29     am            1     vs            1     gear              3         N        15
      30     am            1     vs            1     gear              3         p         0
      31     am            1     vs            1     gear              4         n         6
      32     am            1     vs            1     gear              4         N        12
      33     am            1     vs            1     gear              4         p       0.5
      34     am            1     vs            1     gear              5         n         1
      35     am            1     vs            1     gear              5         N         5
      36     am            1     vs            1     gear              5         p       0.2

# ard_tabulate() cumulative statistics work with strata present

    Code
      as.data.frame(dplyr::select(ard_tabulate(ADSL, by = "ARM", strata = "SEX", variables = "AGEGR1", statistic = ~ c("n", "n_cum", "p", "p_cum")), all_ard_groups(), all_ard_variables(), "stat_name",
      "stat"))
    Output
         group1         group1_level group2 group2_level variable variable_level stat_name       stat
      1     ARM              Placebo    SEX            F   AGEGR1          65-80         n         22
      2     ARM              Placebo    SEX            F   AGEGR1          65-80         p  0.4150943
      3     ARM              Placebo    SEX            F   AGEGR1          65-80     n_cum         22
      4     ARM              Placebo    SEX            F   AGEGR1          65-80     p_cum  0.4150943
      5     ARM              Placebo    SEX            F   AGEGR1            <65         n          9
      6     ARM              Placebo    SEX            F   AGEGR1            <65         p  0.1698113
      7     ARM              Placebo    SEX            F   AGEGR1            <65     n_cum         31
      8     ARM              Placebo    SEX            F   AGEGR1            <65     p_cum  0.5849057
      9     ARM              Placebo    SEX            F   AGEGR1            >80         n         22
      10    ARM              Placebo    SEX            F   AGEGR1            >80         p  0.4150943
      11    ARM              Placebo    SEX            F   AGEGR1            >80     n_cum         53
      12    ARM              Placebo    SEX            F   AGEGR1            >80     p_cum          1
      13    ARM              Placebo    SEX            M   AGEGR1          65-80         n         20
      14    ARM              Placebo    SEX            M   AGEGR1          65-80         p  0.6060606
      15    ARM              Placebo    SEX            M   AGEGR1          65-80     n_cum         20
      16    ARM              Placebo    SEX            M   AGEGR1          65-80     p_cum  0.6060606
      17    ARM              Placebo    SEX            M   AGEGR1            <65         n          5
      18    ARM              Placebo    SEX            M   AGEGR1            <65         p  0.1515152
      19    ARM              Placebo    SEX            M   AGEGR1            <65     n_cum         25
      20    ARM              Placebo    SEX            M   AGEGR1            <65     p_cum  0.7575758
      21    ARM              Placebo    SEX            M   AGEGR1            >80         n          8
      22    ARM              Placebo    SEX            M   AGEGR1            >80         p  0.2424242
      23    ARM              Placebo    SEX            M   AGEGR1            >80     n_cum         33
      24    ARM              Placebo    SEX            M   AGEGR1            >80     p_cum          1
      25    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80         n         28
      26    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80         p        0.7
      27    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80     n_cum         28
      28    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80     p_cum        0.7
      29    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65         n          5
      30    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65         p      0.125
      31    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65     n_cum         33
      32    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65     p_cum      0.825
      33    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80         n          7
      34    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80         p      0.175
      35    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80     n_cum         40
      36    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80     p_cum          1
      37    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80         n         27
      38    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80         p  0.6136364
      39    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80     n_cum         27
      40    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80     p_cum  0.6136364
      41    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65         n          6
      42    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65         p  0.1363636
      43    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65     n_cum         33
      44    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65     p_cum       0.75
      45    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80         n         11
      46    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80         p       0.25
      47    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80     n_cum         44
      48    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80     p_cum          1
      49    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80         n         28
      50    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80         p       0.56
      51    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80     n_cum         28
      52    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80     p_cum       0.56
      53    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65         n          5
      54    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65         p        0.1
      55    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65     n_cum         33
      56    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65     p_cum       0.66
      57    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80         n         17
      58    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80         p       0.34
      59    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80     n_cum         50
      60    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80     p_cum          1
      61    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80         n         19
      62    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80         p  0.5588235
      63    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80     n_cum         19
      64    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80     p_cum  0.5588235
      65    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65         n          3
      66    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65         p 0.08823529
      67    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65     n_cum         22
      68    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65     p_cum  0.6470588
      69    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80         n         12
      70    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80         p  0.3529412
      71    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80     n_cum         34
      72    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80     p_cum          1

---

    Code
      as.data.frame(dplyr::select(ard_tabulate(ADSL, by = "ARM", strata = "SEX", variables = "AGEGR1", denominator = "row", statistic = ~ c("n", "n_cum", "p", "p_cum")), all_ard_groups(), all_ard_variables(),
      "stat_name", "stat"))
    Output
         group1         group1_level group2 group2_level variable variable_level stat_name       stat
      1     ARM              Placebo    SEX            F   AGEGR1          65-80         n         22
      2     ARM              Placebo    SEX            F   AGEGR1          65-80         p  0.1527778
      3     ARM              Placebo    SEX            F   AGEGR1          65-80     n_cum         22
      4     ARM              Placebo    SEX            F   AGEGR1          65-80     p_cum  0.1527778
      5     ARM              Placebo    SEX            F   AGEGR1            <65         n          9
      6     ARM              Placebo    SEX            F   AGEGR1            <65         p  0.2727273
      7     ARM              Placebo    SEX            F   AGEGR1            <65     n_cum          9
      8     ARM              Placebo    SEX            F   AGEGR1            <65     p_cum  0.2727273
      9     ARM              Placebo    SEX            F   AGEGR1            >80         n         22
      10    ARM              Placebo    SEX            F   AGEGR1            >80         p  0.2857143
      11    ARM              Placebo    SEX            F   AGEGR1            >80     n_cum         22
      12    ARM              Placebo    SEX            F   AGEGR1            >80     p_cum  0.2857143
      13    ARM              Placebo    SEX            M   AGEGR1          65-80         n         20
      14    ARM              Placebo    SEX            M   AGEGR1          65-80         p  0.1388889
      15    ARM              Placebo    SEX            M   AGEGR1          65-80     n_cum         98
      16    ARM              Placebo    SEX            M   AGEGR1          65-80     p_cum  0.6805556
      17    ARM              Placebo    SEX            M   AGEGR1            <65         n          5
      18    ARM              Placebo    SEX            M   AGEGR1            <65         p  0.1515152
      19    ARM              Placebo    SEX            M   AGEGR1            <65     n_cum         24
      20    ARM              Placebo    SEX            M   AGEGR1            <65     p_cum  0.7272727
      21    ARM              Placebo    SEX            M   AGEGR1            >80         n          8
      22    ARM              Placebo    SEX            M   AGEGR1            >80         p  0.1038961
      23    ARM              Placebo    SEX            M   AGEGR1            >80     n_cum         54
      24    ARM              Placebo    SEX            M   AGEGR1            >80     p_cum  0.7012987
      25    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80         n         28
      26    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80         p  0.1944444
      27    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80     n_cum         50
      28    ARM Xanomeline High Dose    SEX            F   AGEGR1          65-80     p_cum  0.3472222
      29    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65         n          5
      30    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65         p  0.1515152
      31    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65     n_cum         14
      32    ARM Xanomeline High Dose    SEX            F   AGEGR1            <65     p_cum  0.4242424
      33    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80         n          7
      34    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80         p 0.09090909
      35    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80     n_cum         29
      36    ARM Xanomeline High Dose    SEX            F   AGEGR1            >80     p_cum  0.3766234
      37    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80         n         27
      38    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80         p     0.1875
      39    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80     n_cum        125
      40    ARM Xanomeline High Dose    SEX            M   AGEGR1          65-80     p_cum  0.8680556
      41    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65         n          6
      42    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65         p  0.1818182
      43    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65     n_cum         30
      44    ARM Xanomeline High Dose    SEX            M   AGEGR1            <65     p_cum  0.9090909
      45    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80         n         11
      46    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80         p  0.1428571
      47    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80     n_cum         65
      48    ARM Xanomeline High Dose    SEX            M   AGEGR1            >80     p_cum  0.8441558
      49    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80         n         28
      50    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80         p  0.1944444
      51    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80     n_cum         78
      52    ARM  Xanomeline Low Dose    SEX            F   AGEGR1          65-80     p_cum  0.5416667
      53    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65         n          5
      54    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65         p  0.1515152
      55    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65     n_cum         19
      56    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            <65     p_cum  0.5757576
      57    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80         n         17
      58    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80         p  0.2207792
      59    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80     n_cum         46
      60    ARM  Xanomeline Low Dose    SEX            F   AGEGR1            >80     p_cum  0.5974026
      61    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80         n         19
      62    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80         p  0.1319444
      63    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80     n_cum        144
      64    ARM  Xanomeline Low Dose    SEX            M   AGEGR1          65-80     p_cum          1
      65    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65         n          3
      66    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65         p 0.09090909
      67    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65     n_cum         33
      68    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            <65     p_cum          1
      69    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80         n         12
      70    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80         p  0.1558442
      71    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80     n_cum         77
      72    ARM  Xanomeline Low Dose    SEX            M   AGEGR1            >80     p_cum          1

# ard_tabulate() level ordering of character columns is stable

    Code
      as.data.frame(dplyr::select(ard_tabulate(df_locale, variables = x, by = g, statistic = ~"n"), all_ard_groups(), all_ard_variables(), "stat_name", "stat"))
    Output
         group1 group1_level variable variable_level stat_name stat
      1       g           Z1        x              A         n    1
      2       g           Z1        x              B         n    0
      3       g           Z1        x              a         n    1
      4       g           Z1        x            a B         n    0
      5       g           Z1        x            a-B         n    0
      6       g           Z1        x              b         n    0
      7       g          z 1        x              A         n    0
      8       g          z 1        x              B         n    0
      9       g          z 1        x              a         n    0
      10      g          z 1        x            a B         n    1
      11      g          z 1        x            a-B         n    0
      12      g          z 1        x              b         n    0
      13      g          z-1        x              A         n    0
      14      g          z-1        x              B         n    0
      15      g          z-1        x              a         n    0
      16      g          z-1        x            a B         n    0
      17      g          z-1        x            a-B         n    1
      18      g          z-1        x              b         n    0
      19      g           z1        x              A         n    0
      20      g           z1        x              B         n    1
      21      g           z1        x              a         n    0
      22      g           z1        x            a B         n    0
      23      g           z1        x            a-B         n    0
      24      g           z1        x              b         n    1


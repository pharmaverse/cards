# diff_ard_hierarchical() works

    Code
      print(dplyr::select(d, all_ard_groups(), all_ard_variables(), stat_name, stat), n = 100)
    Output
      # An ARD data frame: 52 x 6
         group1 group1_level                                         variable variable_level                                       stat_name      stat
         <chr>  <list>                                               <chr>    <list>                                               <chr>        <list>
       1 <NA>   <NULL>                                               AESOC    GASTROINTESTINAL DISORDERS                           p_diff     0.0523  
       2 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  ABDOMINAL DISCOMFORT                                 p_diff     0.0119  
       3 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  ABDOMINAL PAIN                                       p_diff     0.000277
       4 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  CONSTIPATION                                         p_diff    -0.0116  
       5 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  DIARRHOEA                                            p_diff    -0.0570  
       6 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  DYSPEPSIA                                            p_diff     0.000277
       7 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  DYSPHAGIA                                            p_diff     0       
       8 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  FLATULENCE                                           p_diff    -0.0116  
       9 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  GASTROINTESTINAL HAEMORRHAGE                         p_diff     0.0119  
      10 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  GASTROOESOPHAGEAL REFLUX DISEASE                     p_diff    -0.0116  
      11 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  GLOSSITIS                                            p_diff    -0.0116  
      12 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  HIATUS HERNIA                                        p_diff    -0.0116  
      13 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  NAUSEA                                               p_diff     0.0365  
      14 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  RECTAL HAEMORRHAGE                                   p_diff     0       
      15 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  SALIVARY HYPERSECRETION                              p_diff     0.0476  
      16 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  STOMACH DISCOMFORT                                   p_diff     0.0119  
      17 AESOC  GASTROINTESTINAL DISORDERS                           AEDECOD  VOMITING                                             p_diff     0.0484  
      18 <NA>   <NULL>                                               AESOC    GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS p_diff     0.232   
      19 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE BLEEDING                            p_diff     0       
      20 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE DERMATITIS                          p_diff     0.0252  
      21 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE DESQUAMATION                        p_diff     0       
      22 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE DISCHARGE                           p_diff     0.0119  
      23 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE DISCOLOURATION                      p_diff     0       
      24 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE ERYTHEMA                            p_diff     0.144   
      25 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE INDURATION                          p_diff    -0.0116  
      26 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE IRRITATION                          p_diff     0.0723  
      27 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE PAIN                                p_diff     0.0238  
      28 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE PERSPIRATION                        p_diff     0.0238  
      29 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE PRURITUS                            p_diff     0.192   
      30 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE REACTION                            p_diff     0.000277
      31 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE SWELLING                            p_diff     0.0238  
      32 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE URTICARIA                           p_diff     0.0119  
      33 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE VESICLES                            p_diff     0.0598  
      34 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  APPLICATION SITE WARMTH                              p_diff     0       
      35 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  ASTHENIA                                             p_diff     0.000277
      36 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  CHEST DISCOMFORT                                     p_diff     0.0238  
      37 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  CHEST PAIN                                           p_diff     0.0238  
      38 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  CHILLS                                               p_diff     0.000277
      39 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  CYST                                                 p_diff     0       
      40 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  FATIGUE                                              p_diff     0.0479  
      41 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  FEELING ABNORMAL                                     p_diff     0.0119  
      42 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  FEELING COLD                                         p_diff     0.0119  
      43 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  INFLAMMATION                                         p_diff     0       
      44 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  MALAISE                                              p_diff     0.0238  
      45 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  OEDEMA                                               p_diff     0       
      46 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  OEDEMA PERIPHERAL                                    p_diff     0.000554
      47 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  PAIN                                                 p_diff     0.0119  
      48 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  PYREXIA                                              p_diff    -0.0114  
      49 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  SECRETION DISCHARGE                                  p_diff     0       
      50 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  SUDDEN DEATH                                         p_diff     0       
      51 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  SWELLING                                             p_diff     0       
      52 AESOC  GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS AEDECOD  ULCER                                                p_diff     0       

# diff_ard_hierarchical() input checks

    Code
      diff_ard_hierarchical(ard_noby)
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The ARD `x` must contain at least one `by` variable to calculate rate differences.

---

    Code
      diff_ard_hierarchical(ard_cnt)
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The "p" statistic must be present in `x` to calculate rate differences.
      i Include "p" in the `statistic` argument of `ard_stack_hierarchical()`.

---

    Code
      diff_ard_hierarchical(ard)
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The `by` variable "TRTA" must have exactly two levels to calculate a rate difference without specifying `levels`.
      i "TRTA" has 3 levels: "Placebo", "Xanomeline High Dose", and "Xanomeline Low Dose". Specify `levels` to choose two.

---

    Code
      diff_ard_hierarchical(ard, levels = list(FOO = "a", FOO = "b"))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The names of `levels` must be `by` variables used to create `x`.
      i The `by` variable "TRTA" is available.

---

    Code
      diff_ard_hierarchical(ard, levels = list(TRTA = "Placebo", TRTA = "Nope"))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The `levels` value "Nope" for "TRTA" is not a valid level.
      i Valid levels: "Placebo", "Xanomeline High Dose", and "Xanomeline Low Dose".

---

    Code
      diff_ard_hierarchical(ard, levels = list(TRTA = "Placebo"))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Exactly one `by` variable must be repeated in `levels` to define the two groups being differenced.
      i Repeat the `by` variable name, e.g. `list(TRTA = "level1", TRTA = "level2")`.

---

    Code
      diff_ard_hierarchical(ard, levels = list(list(TRTA = "Placebo"), list(TRTA = "Placebo")))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The two groups specified in `levels` must differ.

# diff_ard_hierarchical() input checks with multiple `by` variables

    Code
      diff_ard_hierarchical(ard2)
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The `levels` argument must be specified when `x` has more than one `by` variable.
      i Specify the two groups as two named lists, e.g. `levels = list(list(...), list(...))`.

---

    Code
      diff_ard_hierarchical(ard2, levels = list(TRTA = "Placebo", SEX = "F"))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Exactly one `by` variable must be repeated in `levels` to define the two groups being differenced.
      i With more than one `by` variable, specify the two groups as two named lists, e.g. `list(list(...), list(...))`.

---

    Code
      diff_ard_hierarchical(ard2, levels = list(TRTA = "Placebo", TRTA = "Xanomeline High Dose"))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Every `by` variable other than the difference variable must be specified exactly once in `levels`.
      i The `by` variables "TRTA" and "SEX" must each appear (the difference variable twice).

---

    Code
      diff_ard_hierarchical(ard2, levels = list(list(TRTA = "Placebo"), list(TRTA = "Xanomeline High Dose")))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Each group in `levels` must specify a level for every `by` variable.
      i The `by` variables "TRTA" and "SEX" must each appear once.

# diff_ard_hierarchical() input checks on `levels` structure

    Code
      diff_ard_hierarchical(ard, levels = list("Placebo", "Xanomeline High Dose"))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The `levels` argument must be a fully named list, e.g. `list(TRTA = "Placebo", TRTA = "Low Dose")`.

---

    Code
      diff_ard_hierarchical(ard, levels = list(TRTA = c("Placebo",
        "Xanomeline High Dose")))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Each element of `levels` must be a single `by` variable level.

---

    Code
      diff_ard_hierarchical(ard, levels = list(TRTA = "Placebo", TRTA = "Placebo"))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The two levels of the difference variable "TRTA" in `levels` must differ.

---

    Code
      diff_ard_hierarchical(ard, levels = list(list("Placebo"), list(TRTA = "Placebo")))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Each group in `levels` must be a fully named list of `by` variable levels.

---

    Code
      diff_ard_hierarchical(ard, levels = list(list(TRTA = "Placebo", TRTA = "Xanomeline High Dose"),
      list(TRTA = "Placebo")))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Each `by` variable may be specified only once within a group of `levels`.

---

    Code
      diff_ard_hierarchical(ard, levels = list(list(TRTA = c("Placebo",
        "Xanomeline High Dose")), list(TRTA = "Placebo")))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! Each element of a `levels` group must be a single level.

---

    Code
      diff_ard_hierarchical(ard, levels = list(list(TRTA = "Nope"), list(TRTA = "Placebo")))
    Condition
      Error in `diff_ard_hierarchical()`:
      ! The `levels` value for "TRTA" must be one of "Placebo", "Xanomeline High Dose", and "Xanomeline Low Dose", not "Nope".


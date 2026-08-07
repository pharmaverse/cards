# ard_hierarchical() works without by variables

    Code
      class(ard_heir_no_by)
    Output
      [1] "card"       "tbl_df"     "tbl"        "data.frame"

# ard_hierarchical() works without any variables

    Code
      ard_hierarchical(data = ADAE, variables = starts_with("xxxx"), by = c(TRTA,
        AESEV))
    Output
      # An ARD data frame: 0 x 0

# ard_hierarchical(id) argument works

    Code
      head(ard_hierarchical(data = ADAE, variables = c(AESOC, AEDECOD), by = c(TRTA,
        AESEV), denominator = ADSL, id = USUBJID), 1L)
    Condition
      Warning:
      Duplicate rows found in data for the "USUBJID" column.
      i Percentages/Denominators are not correct.
    Output
      # An ARD data frame: 1 x 15
        group1 group1_level group2 group2_level group3 group3_level      variable
        <chr>  <list>       <chr>  <list>       <chr>  <list>            <chr>   
      1 TRTA   Placebo      AESEV  MILD         AESOC  CARDIAC DISORDERS AEDECOD 
      # i 8 more variables: variable_level <list>, context <chr>, stat_name <chr>,
      #   stat_label <chr>, stat <list>, fmt_fun <list>, warning <list>, error <list>

---

    Code
      head(ard_hierarchical(data = ADAE, variables = c(AESOC, AEDECOD), by = c(TRTA,
        AESEV), denominator = ADSL, id = c(USUBJID, SITEID)), 1L)
    Condition
      Warning:
      Duplicate rows found in data for the "USUBJID" and "SITEID" columns.
      i Percentages/Denominators are not correct.
    Output
      # An ARD data frame: 1 x 15
        group1 group1_level group2 group2_level group3 group3_level      variable
        <chr>  <list>       <chr>  <list>       <chr>  <list>            <chr>   
      1 TRTA   Placebo      AESEV  MILD         AESOC  CARDIAC DISORDERS AEDECOD 
      # i 8 more variables: variable_level <list>, context <chr>, stat_name <chr>,
      #   stat_label <chr>, stat <list>, fmt_fun <list>, warning <list>, error <list>

# ard_hierarchical_count() works without by variables

    Code
      class(ard_heir_no_by)
    Output
      [1] "card"       "tbl_df"     "tbl"        "data.frame"

# ard_hierarchical_count() works without any variables

    Code
      ard_hierarchical_count(data = ADAE, variables = starts_with("xxxx"), by = c(
        TRTA, AESEV))
    Output
      # An ARD data frame: 0 x 0

# ard_hierarchical() errors with incomplete factor columns

    Code
      ard_hierarchical(dplyr::mutate(mtcars, am = factor(am, levels = character(0))),
      variables = c(vs, am))
    Condition
      Error in `ard_hierarchical()`:
      ! Factors with empty "levels" attribute are not allowed, which was identified in column "am".

---

    Code
      ard_hierarchical(dplyr::mutate(mtcars, am = factor(am, levels = c(0, 1, NA),
      exclude = NULL)), variables = c(vs, am))
    Condition
      Error in `ard_hierarchical()`:
      ! Factors with NA levels are not allowed, which are present in column "am".

# ard_hierarchical_count() errors with incomplete factor columns

    Code
      ard_hierarchical_count(dplyr::mutate(mtcars, am = factor(am, levels = character(
        0))), variables = c(vs, am))
    Condition
      Error in `ard_hierarchical_count()`:
      ! Factors with empty "levels" attribute are not allowed, which was identified in column "am".

---

    Code
      ard_hierarchical_count(dplyr::mutate(mtcars, am = factor(am, levels = c(0, 1,
        NA), exclude = NULL)), variables = c(vs, am))
    Condition
      Error in `ard_hierarchical_count()`:
      ! Factors with NA levels are not allowed, which are present in column "am".


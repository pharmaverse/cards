# complete_ard_hierarchical() errors with incorrect inputs

    Code
      complete_ard_hierarchical(ard_tabulate(cards::ADSL, variables = AGEGR1),
      combinations = all_combinations)
    Condition
      Error in `complete_ard_hierarchical()`:
      ! The `x` argument must be class <ard_stack_hierarchical/ard_stack_hierarchical_count>, not a <card> object.

---

    Code
      complete_ard_hierarchical(ard, combinations = "EYE DISORDERS")
    Condition
      Error in `complete_ard_hierarchical()`:
      ! The `combinations` argument must be class <data.frame>, not a string.

---

    Code
      complete_ard_hierarchical(ard, combinations = data.frame(TRTA = "Placebo"))
    Condition
      Error in `complete_ard_hierarchical()`:
      ! The columns of `combinations` must be hierarchy variables of `x`, starting from the top.
      i The hierarchy variables of `x`, from the top, are "AESOC" and "AEDECOD".

---

    Code
      complete_ard_hierarchical(ard, combinations = dplyr::distinct(all_combinations,
        AEDECOD))
    Condition
      Error in `complete_ard_hierarchical()`:
      ! The columns of `combinations` must be hierarchy variables of `x`, starting from the top.
      i The hierarchy variables of `x`, from the top, are "AESOC" and "AEDECOD".

---

    Code
      complete_ard_hierarchical(ard, combinations = data.frame(AESOC = NA_character_))
    Condition
      Error in `complete_ard_hierarchical()`:
      ! The `combinations` argument cannot contain missing values.

---

    Code
      complete_ard_hierarchical(ard, combinations = data.frame(AESOC = 1))
    Condition
      Error in `complete_ard_hierarchical()`:
      ! Can't convert `combinations$AESOC` <double> to <character>.

---

    Code
      complete_ard_hierarchical(ard_cum, combinations = all_combinations)
    Condition
      Error in `complete_ard_hierarchical()`:
      ! Cannot add unobserved levels to an ARD with the "n_cum" statistic.
      i Only the "n", "N", and "p" statistics can be set for an unobserved level.

---

    Code
      complete_ard_hierarchical(dplyr::filter(ard, variable != "AEDECOD"),
      combinations = all_combinations)
    Condition
      Error in `complete_ard_hierarchical()`:
      ! Cannot add levels for "AEDECOD": `x` has no rows for this variable to copy.


# compare_ard() error messages name the user-facing argument

    Code
      compare_ard(ard, ard, keys = any_of("not_a_column"))
    Condition
      Error in `compare_ard()`:
      ! The `keys` argument cannot be empty.

---

    Code
      compare_ard(ard, ard, columns = any_of("not_a_column"))
    Condition
      Error in `compare_ard()`:
      ! The `columns` argument cannot be empty.

---

    Code
      compare_ard(ard, ard, keys = not_a_column)
    Condition
      Error in `compare_ard()`:
      ! Error processing `keys` argument.
      ! Can't select columns that don't exist. x Column `not_a_column` doesn't exist.
      i Select among columns "variable", "variable_level", "context", "stat_name", "stat_label", "stat", "fmt_fun", "warning", and "error"

---

    Code
      compare_ard(ard, ard, keys = c(foo = variable))
    Condition
      Error in `compare_ard()`:
      ! Error processing `keys` argument.
      ! Can't rename variables in this context.
      i Select among columns "variable", "variable_level", "context", "stat_name", "stat_label", "stat", "fmt_fun", "warning", and "error"

# compare_ard() errors when the comparison columns have nothing in common

    Code
      compare_ard(dplyr::select(ard, -"stat"), dplyr::select(ard, -"stat_label"),
      columns = any_of(c("stat_label", "stat")))
    Condition
      Error in `compare_ard()`:
      ! The comparison `columns` from `x` and `y` have no columns in common.
      i Comparison `columns` in `x`: "stat_label"
      i Comparison `columns` in `y`: "stat"


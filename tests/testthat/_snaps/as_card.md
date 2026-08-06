# as_card() allows non card objects with check = FALSE

    Code
      as_card(data.frame(stat_name = c("N", "mean"), stat_label = c("N", "Mean"),
      stat = c(10, 0.5)), check = FALSE)
    Output
      # An ARD data frame: 2 x 3
        stat_name stat_label  stat
      * <chr>     <chr>      <dbl>
      1 N         N           10  
      2 mean      Mean         0.5

# as_card() error catching works correctly

    Code
      as_card("notadataframe")
    Condition
      Error in `as_card()`:
      ! The `x` argument must be class <data.frame>, not a string.

---

    Code
      as_card(nonliststat)
    Condition
      Error in `as_card()`:
      ! The following columns are expected to be list columns: "stat".


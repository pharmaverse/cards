# add_calculated_row(x)

    Code
      apply_fmt_fun(add_calculated_row(ard_summary(mtcars, variables = mpg), expr = max -
        min, stat_name = "range"))
    Output
      # An ARD data frame: 9 x 9
        variable context stat_name stat_label   stat stat_fmt fmt_fun warning error 
        <chr>    <chr>   <chr>     <chr>      <list> <list>    <list> <list>  <list>
      1 mpg      summary N         N           32    32             0 <NULL>  <NULL>
      2 mpg      summary mean      Mean        20.1  20.1           1 <NULL>  <NULL>
      3 mpg      summary sd        SD           6.03 6.0            1 <NULL>  <NULL>
      4 mpg      summary median    Median      19.2  19.2           1 <NULL>  <NULL>
      5 mpg      summary p25       Q1          15.4  15.4           1 <NULL>  <NULL>
      6 mpg      summary p75       Q3          22.8  22.8           1 <NULL>  <NULL>
      7 mpg      summary min       Min         10.4  10.4           1 <NULL>  <NULL>
      8 mpg      summary max       Max         33.9  33.9           1 <NULL>  <NULL>
      9 mpg      summary range     range       23.5  23.5           1 <NULL>  <NULL>

---

    Code
      apply_fmt_fun(add_calculated_row(ard_summary(mtcars, variables = mpg), expr = dplyr::case_when(
        mean > median ~ "Right Skew", mean < median ~ "Left Skew", .default = "Symmetric"),
      stat_name = "skew"))
    Output
      # An ARD data frame: 9 x 9
        variable context stat_name stat_label stat       stat_fmt   fmt_fun
        <chr>    <chr>   <chr>     <chr>      <list>     <list>     <list> 
      1 mpg      summary N         N          32         32         0      
      2 mpg      summary mean      Mean       20.09062   20.1       1      
      3 mpg      summary sd        SD         6.026948   6.0        1      
      4 mpg      summary median    Median     19.2       19.2       1      
      5 mpg      summary p25       Q1         15.35      15.4       1      
      6 mpg      summary p75       Q3         22.8       22.8       1      
      7 mpg      summary min       Min        10.4       10.4       1      
      8 mpg      summary max       Max        33.9       33.9       1      
      9 mpg      summary skew      skew       Right Skew Right Skew <fn>   
      # i 2 more variables: warning <list>, error <list>

# add_calculated_row(expr) messaging

    Code
      add_calculated_row(ard_summary(mtcars, variables = mpg), expr = not_a_stat * 2,
      stat_name = "this_doesnt_work")
    Condition
      Error in `add_calculated_row()`:
      ! There was an error calculating the new statistic. See below:
      x object 'not_a_stat' not found

# add_calculated_row(by) messaging

    Code
      add_calculated_row(ard_summary(mtcars, variables = mpg, by = cyl), expr = max -
        min, stat_name = "range", by = "context")
    Condition
      Error in `add_calculated_row()`:
      ! Duplicate statistics present within `by` groups: "N", "mean", "sd", "median", "p25", "p75", "min", "max", "N", "mean", "sd", "median", "p25", "p75", "min", and "max"


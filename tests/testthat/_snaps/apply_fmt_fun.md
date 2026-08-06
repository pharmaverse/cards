# apply_fmt_fun() error messaging

    Code
      apply_fmt_fun(letters)
    Condition
      Error in `apply_fmt_fun()`:
      ! The `x` argument must be class <card>, not a character vector.

---

    Code
      apply_fmt_fun(dplyr::mutate(ard_fmt_checks, fmt_fun = list("xoxo", "xoxo")))
    Condition
      Error in `dplyr::mutate()`:
      i In argument: `stat_fmt = pmap(...)`.
      Caused by error in `apply_fmt_fun()`:
      ! There was an error applying the formatting function to statistic "mean" for variable "mpg".
      i Perhaps try formmatting function `as.character()`? See error message below:
      x The format "xoxo" for `fmt_fun` is not valid for the variable "mpg" for the statistic "mean". String must begin with 'x' and only consist of x's, a single period or none, and may end with a percent symbol.

---

    Code
      apply_fmt_fun(dplyr::mutate(ard_fmt_checks, fmt_fun = list(1L, -1L)))
    Condition
      Error in `dplyr::mutate()`:
      i In argument: `stat_fmt = pmap(...)`.
      Caused by error in `apply_fmt_fun()`:
      ! There was an error applying the formatting function to statistic "sd" for variable "mpg".
      i Perhaps try formmatting function `as.character()`? See error message below:
      x The value in `fmt_fun` cannot be converted into a function for statistic "sd" and variable "mpg". i Value must be a function, a non-negative integer, or a formatting string, e.g. "xx.x". * See `?cards::alias_as_fmt_fun()` for details.

---

    Code
      as.data.frame(apply_fmt_fun(dplyr::mutate(ard_fmt_checks, stat = lapply(stat,
        function(x) x * 1000), fmt_fun = list("xx", "xx"))))
    Output
        variable context stat_name stat_label     stat stat_fmt fmt_fun warning error
      1      mpg summary      mean       Mean 20090.62    20091      xx    NULL  NULL
      2      mpg summary        sd         SD 6026.948     6027      xx    NULL  NULL

# apply_fmt_fun(replace)

    Code
      apply_fmt_fun(ard, replace = FALSE)
    Output
      # An ARD data frame: 3 x 10
        variable variable_level context  stat_name stat_label   stat fmt_fun stat_fmt 
        <chr>    <list>         <chr>    <chr>     <chr>      <list>  <list> <list>   
      1 AGEGR1   65-80          tabulate n         n             144       0 144.0000~
      2 AGEGR1   <65            tabulate n         n              33       0 33       
      3 AGEGR1   >80            tabulate n         n              77       0 77       
      # i 2 more variables: warning <list>, error <list>

---

    Code
      apply_fmt_fun(ard, replace = TRUE)
    Output
      # An ARD data frame: 3 x 10
        variable variable_level context  stat_name stat_label   stat fmt_fun stat_fmt
        <chr>    <list>         <chr>    <chr>     <chr>      <list>  <list> <list>  
      1 AGEGR1   65-80          tabulate n         n             144       0 144     
      2 AGEGR1   <65            tabulate n         n              33       0 33      
      3 AGEGR1   >80            tabulate n         n              77       0 77      
      # i 2 more variables: warning <list>, error <list>


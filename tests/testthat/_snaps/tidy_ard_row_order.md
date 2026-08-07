# tidy_ard_row_order() works

    Code
      dplyr::select(ard_tabulate(data.frame(x1 = sample(LETTERS[1:5], 30, replace = TRUE), x2 = sample(LETTERS[6:10], 30,
      replace = TRUE), x3 = sample(LETTERS[11:15], 30, replace = TRUE), zz = 1L, aa = 1L), by = x1:x3, variables = c(zz, aa),
      statistic = everything() ~ "n"), all_ard_groups(), all_ard_variables())
    Output
      # An ARD data frame: 250 x 8
         group1 group1_level group2 group2_level group3 group3_level variable variable_level
         <chr>  <list>       <chr>  <list>       <chr>  <list>       <chr>            <list>
       1 x1     A            x2     F            x3     K            zz                    1
       2 x1     A            x2     F            x3     K            aa                    1
       3 x1     A            x2     F            x3     L            zz                    1
       4 x1     A            x2     F            x3     L            aa                    1
       5 x1     A            x2     F            x3     M            zz                    1
       6 x1     A            x2     F            x3     M            aa                    1
       7 x1     A            x2     F            x3     N            zz                    1
       8 x1     A            x2     F            x3     N            aa                    1
       9 x1     A            x2     F            x3     O            zz                    1
      10 x1     A            x2     F            x3     O            aa                    1
      # i 240 more rows


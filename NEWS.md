# cards 0.8.0.9006

* The output of `bind_ard()` now has a `"bind_ard"` class. (#572; @alanahjonas95).

* `unlist_ard_columns()` and `rename_ard_columns()` now return objects subclassed `"card_unlisted"` and `"card_renamed"` respectively, rather than retaining the `"card"` class. The result no longer satisfies the ARD contract, so functions requiring a proper ARD now reject these objects with a clear error. `rename_ard_columns()` accepts both `"card"` and `"card_unlisted"` inputs. (#513, @Melkiades)

* Fixed `get_ard_statistics()` to return `NULL` statistics unchanged instead of attempting to attach attributes to `NULL`, which errors as of R 4.5.0.


# cards 0.8.0

## New Features and Functions

* Added new functions `compare_ard()`, `is_ard_equal()`, and `check_ard_equal()`. (#437; @malanbos)

* Adding `ard_tabulate_rows()` function to tabulate the number of rows in a data frame. (#531)

## Other Updates

* `as_card` now has the argument `check = TRUE` which when `TRUE` will confirm if the data frame being converted matches the cards spec using `check_ard_structure`. To support this, `check_ard_structure` has a new argument `error_on_fail` which is FALSE by default. When TRUE any failures will generate an error. (#514)

* Users are now messaged if the `by` or `strata` arguments pass columns with different classes in the `ard_tabulate(data,denominator)` arguments as this _may_ cause issues downstream. (#515)

* Similar to `ard_stack_hierarchical()` and `ard_stack()`, other `ard_*()` functions and `nest_for_ard()` now contain an `args` attribute to retain information about input arguments. (#483)

* The `ard_stack_hierarchical*()` functions now return a subclass with the calling function name.

* The following functions now return an object with an `'args'` attribute that contains more contextual information about the objects' creation. `ard_strata()`, `ard_pairwise()`, `ard_summary()`,  `ard_tabulate()`,  `ard_tabulate_value()`,  `ard_hierarchical()`,  `ard_hierarchical_count()`, `ard_missing()`, `ard_mvsummary()` and  `nest_for_ard()` contain an args attribute to retain information about input arguments. (#483, @alanahjonas95)

* Update in `ard_tabulate()` to account for change in `as.data.frame()` being released in R-Devel. (#554)

## Bug Fixes

* Fixed bug in `rename_ard_columns()` whereby factor variables were getting converted to integers and added parameter `fct_as_chr` as is used in `unlist_ard_columns()` (#542)

# cards 0.7.1

* Updated `ard_stack_hierarchical()` so that the `denominator` dataset only contains the `id` and `by` variables. (#482)

* Fixed bug in `sort_ard_hierarchical()` causing an error when sorting hierarchical ARDs with more than 2 `by` variables. (#516)

* `shuffle_ard()` has been deprecated and will be maintained in {tfrmt} going forward. (#509)

# cards 0.7.0

## New Features and Functions

* Updated `sort_ard_hierarchical()` to allow for different sorting methods at each hierarchy variable level. (#487)

* Updated `sort_ard_hierarchical()` and `filter_ard_hierarchical()` to always keep attribute and total N rows at the bottom of the ARD.

* Added argument `var` to `filter_ard_hierarchical()` to allow filtering by any hierarchy variable. (#467)

* Added flexibility to filter by `by` variable level-specific values when using `filter_ard_hierarchical()` to allow for filtering of hierarchical ARDs by difference in two rates. (#438)

* The `ard_strata()` function has been updated to include the strata columns in the nested data frames. (#461)

* Similar to `ard_stack_hierarchical()`, `ard_stack()` contains an `args` attribute to retain information about input arguments.

* Added an article illustrating how to summarize long data structures. (#356)

* Added `ard_stack(.by_stat)` and `ard_stack_hierarchical(by_stat)` arguments that, when `TRUE` (the default), includes a univariate ARD tabulation of the `by` variable in the returned ARD. (#335)

* `shuffle_ard()` passes down the `args` attribute of the input `card` object when present. (#484, @dragosmg)

* `shuffle_ard()` fills overall or group statistics with `"Overall <column_name>"` or `"Any <column_name>"`. (#337, @dragosmg)

* `shuffle_ard()` messages if `"Overall <column_names>"` is accidentally present in the data and creates a unique label. (#465, @dragosmg)

* Add `ADLB` data set. (#450)

## Lifecycle Changes

* The following functions have been renamed. The old functions still work in the package, and will be soft deprecated in the next release. (#470)
  - `ard_continuous()` to `ard_summary()`
  - `ard_complex()` to `ard_mvsummary()`
  - `ard_categorical()` to `ard_tabulate()`
  - `ard_dichotomous()` to `ard_tabulate_value()`
  
* `shuffle` and `.shuffle` arguments (for `ard_stack_hierarchical()` and `ard_stack()`) are deprecated and users encouraged to call `shuffle_ard()` directly. (#475, @dragosmg)

# cards 0.6.1

## New Features and Functions

* Added new function `ard_identity()` for saving pre-calculated statistics in an ARD format. (#379)

## Lifecycle Changes

* Updating any `fmt_fn` references to `fmt_fun` for consistency. 

    * Any function with an argument `cards::foo(fmt_fn)` has been updated to `cards::foo(fmt_fun)`. The old syntax will continue to function, but with a deprecation warning to users.

    * The following function names have been updated: `alias_as_fmt_fun()`, `apply_fmt_fun()`, and `update_ard_fmt_fun()`.  The former function names are still exported from the package, and users will see a deprecation note when they are used.

    * Importantly, the ARD column named `"fmt_fn"` has been updated to `"fmt_fun"`. This change cannot be formally deprecated. For users who were accessing the ARD object directly to modify this column instead of using functions like `update_ard_fmt_fun()`, this will be a breaking change.
    
## Bug Fixes

* Fix bug in `sort_ard_hierarchical()` when hierarchical ARD has `overall=TRUE`. (#431)

* Fix bug in `ard_stack_hierarchical()` when `id` values are present in multiple levels of the `by` variables. (#442)

* Fix bug in `shuffle_ard()` where error is thrown if input contains hierarchical results. (#447)

# cards 0.6.0

## New Features and Functions

* Added functions `sort_ard_hierarchical()` and `filter_ard_hierarchical()` to sort & filter ARDs created using `ard_stack_hierarchical()` and `ard_stack_hierarchical_count()`. (#301)

* Updated `ard_stack_hierarchical()` and `ard_stack_hierarchical_count()` to automatically sort results alphanumerically. (#423)

* Added new function `unlist_ard_columns()`. (#391)

* Updated function `rename_ard_columns()`. (#380)

    * The function no longer coerces values to character.

    * The `fill` argument has been added to specify a value to fill in the new column when there are no levels associated with the variables (e.g. continuous summaries).

    * The `unlist` argument has been deprecated in favor of using the new `unlist_ard_columns()` function.

    * The function no longer accepts generic data frames: inputs must be a data frame of class `card`.
    
* Added function `ard_formals()` to assist in adding a function's formals, that is, the arguments with their default values, along with user-passed arguments into an ARD structure.

## Bug Fixes

* Fixed sorting order of logical variables in `nest_for_ard()`. (#411)

## Lifecycle Changes

* The `shuffle_ard()` function no longer outputs a `'label'` column, and instead retains the original `'variable'` level from the cards object. It also no longer trims rows with non-numeric stats values. (#416)

# cards 0.5.1

* Small update to account for a change in R-devel.

# cards 0.5.0

## New Features and Functions

* Added functions `rename_ard_groups_shift()` and `rename_ard_groups_reverse()` for renaming the grouping variables in the ARD. (#344)

* Added an option to specify the default rounding in the package: `cards.round_type`. See `?cards.options` for details. (#384)

* Added the `print_ard_conditions(condition_type)` argument, which allows users to select to return conditions as messages (the default), or have warnings returned as warnings and errors as errors. (#386)

* Added the `all_ard_group_n(types)` argument to allow separate selection of `groupX` and `groupX_level` columns.

* Added the `tidy_ard_column_order(group_order)` argument that allows users to specify whether the grouping variables are listed in ascending order (the default) or descending order. The output of `ard_strata()` now calls `tidy_ard_column_order(group_order="descending")`.

## Other Updates

* A new article has been added detailing how to create new ARD functions.

* Results are now sorted in a consistent manner, by descending groups and strata. (#342, #326)

## Lifecycle Updates

* Function `label_cards()` has been renamed to `label_round()`, which more clearly communicates that is returns a rounding function.

# cards 0.4.0

## New Features and Functions

* Added functions `as_cards_fn()`, `is_cards_fn()`, and `get_cards_fn_stat_names()`. These functions assist is creating functions with attributes enumerating the expected results.

* Updated `ard_continuous()` and `ard_complex()` to return full ARDs when functions passed are created with `as_cards_fn()`: instead of a single row output, we get a long ARD with rows for each of the expected statistic names. (#316)

* Added function `ard_pairwise()` to ease the calculations of pairwise analyses. (#359)

## Other Updates

* Improved messaging in `print_ard_conditions()` when the calling function is namespaced. (#348)

* Updated print method for `'card'` objects so extraneous columns are never printed by default.

## Lifecycle Changes

* No longer exporting functions `check_pkg_installed()`, `is_pkg_installed()`, `get_min_version_required()`, `get_pkg_dependencies()`. These functions are now internal-only. (#330)

## Bug Fixes

* The `tidy_ard_column_order()` now correctly orders grouping columns when there are 10+ groups. This also corrects an issue in the hierarchical functions where the ordering of the variables matters. (#352)

# cards 0.3.0

## New Features & Updates

* Added functions `ard_stack_hierarchical()` and  `ard_stack_hierarchical_count()` that ease the creation of ARDs for multiple nested or hierarchical structures. (#314)

* Added functions `update_ard_fmt_fn()` and `update_ard_stat_label()` to update an ARD's formatting function and statistic label, respectively. (#253)

* Added `rename_ard_columns(unlist)` argument, which unlists specified columns in the ARD data frame. (#313)

* Added `ard_strata()` function to ease the task of calculating ARDs stratified by one or more other categorical variables. (#273)

* Added functions `mock_continuous()`, `mock_categorical()`, `mock_dichotomous()`, `mock_missing()`, `mock_attributes()` to build ARDs in the absence of a data frame. Where applicable, the formatting functions are set to return `'xx'` or `'xx.x'` to aid in the construction of mock tables or table shells. (#256)

* Added functions for printing results from `eval_capture_conditions()`. Captured conditions can be printed as either errors or messages with `captured_condition_as_error()` and `captured_condition_as_message()`, respectively. (#282)

## Other Updates

* The `ard_hierarchical_count()` function has been updated to match the behavior of `ard_hierarchical()` and results are now only returned for the last column listed in the `variables` arguments, rather than recursively counting all variables.

* Add columns `'fmt_fn'`, `'warning'`, and `'errors'` to `ard_attributes()` output. (#327)

* Add checks for factors with no levels, or any levels that are `NA` into `ard_*` functions (#255) 

* Any rows with `NA` or `NaN` values in the `.by` columns specified in `ard_stack()` are now removed from all calculations. (#320)

# cards 0.2.2

## New Features & Updates

* Converted `ard_total_n()` to an S3 generic and added method `ard_total_n.data.frame()`.

* Added the `bind_ard(.quiet)` argument to suppress messaging. (#299)

* Improved ability of `shuffle_ard()` to populate missing group values where possible. (#306)

* Added `apply_fmt_fn(replace)` argument. Use `replace=FALSE` to retain any previously formatted statistics in the `stat_fmt` column. (#285)

* Added `bind_ard(.distinct)` argument, which can remove non-distinct rows from the ARD across grouping variables, primary variables, context, statistic name and value. (#286)

## Bug Fixes

* Fix in `print_ard_conditions()` when the variables were factors, which did not render properly in `cli::cli_format()`.

* Bug fix in `print_ard_conditions()` and we can now print condition messages that contain curly brace pairs. (#309)

# cards 0.2.1

* Update in `ard_categorical()` to use `base::order()` instead of `dplyr::arrange()`, so the ordering of variables match the results from `base::table()` in some edge cases where sorted order was inconsistent.

* Update in `ard_categorical()` to run `base::table()` output checks against coerced character columns. Previously, we relied on R to perform checks on the type it decided to check against (e.g. when it coerces to a common type). While the initial strategy worked in cases of Base R classes, there were some bespoke classes, such as times from {hms}, where Base R does not coerce as we expected.

* Adding selectors `all_group_n()` and `all_missing_columns()`. (#272, #274)

* Added new function `add_calculated_row()` for adding a new row of calculated statistic(s) that are a function of the other statistics in the ARD. (#275)

# cards 0.2.0

## New Features & Updates

* Converting `ard_*()` functions and other helpers to S3 generics to make them extendable. (#227) 

* Added helper `rename_ard_columns()` for renaming/coalescing group/variable columns. (#213).

* Added new function `ard_total_n()` for calculating the total N in a data frame. (#236)

* Added the `nest_for_ard(include_data)` argument to either include or exclude the subsetted data frames in a list-column in the returned tibble.

* Added `check_ard_structure(column_order, method)` arguments to the function to check for column ordering and whether result contains a `stat_name='method'` row.

* Added the optional `ard_hierarchical(id)` argument. When provided we check for duplicates across the column(s) supplied here. If duplicates are found, the user is warned that the percentages and denominators are not correct. (#214)

* Improved messaging in `check_pkg_installed()` that incorporates the calling function name in the case of an error. (#205)

* Updated `is_pkg_installed()` and `check_pkg_installed()` to allow checks for more than package at a time. The `get_min_version_required()` function has also been updated to return a tibble instead of a list with attributes. (#201)

* Styling from the {cli} package are now removed from errors and warnings when they are captured with `eval_capture_conditions()`. Styling is removed with `cli::ansi_strip()`. (#129)

## Bug Fixes

* Bug fix in `ard_stack()` when calls to functions were namespaced. (#242)

* The `print_ard_conditions()` function has been updated to no longer error out if the ARD object does not have `"error"` or `"warning"` columns. (#240)

* Bug fix in `shuffle_ard()` where factors were coerced to integers instead of their labels. (#232)

## Lifecycle Changes

* Corrected order that `ard_categorical` (strata) columns would appear in the ARD results. Previously, they appeared in the order they appeared in the original data, and now they are sorted properly. (#221)

* The API for `ard_continuous(statistic)` and `ard_missing(statistic)` arguments has been updated. Previously, the RHS of these argument's passed lists would be either `continuous_summary_fns()` and `missing_summary_fns()`. Now these arguments accept simple character vectors of the statistic names. For example, `ard_categorical(statistic = everything() ~ c("n", "p", "N"))` and `ard_missing(statistic = everything() ~ c("N_obs", "N_miss", "N_nonmiss", "p_miss", "p_nonmiss"))`. (#223) 

* Updated `ard_stack()` to return `n`, `p`, and `N` for the `by` variable when specified. Previously, it only returned `N` which is the same for all levels of the by variable. (#219)

* Bug fix where `ard_stack(by)` argument was not passed to `ard_missing()` when `ard_stack(.missing=TRUE)`. (#244)

* The `ard_stack(by)` argument has been renamed to `".by"` and its location moved to after the dots inputs, e.g. `ard_stack(..., .by)`. (#243)

* A messaging overhaul to utilize the scripts in `https://github.com/ddsjoberg/standalone/blob/main/R/standalone-cli_call_env.R`. This allows clear error messaging across functions and packages. (#42)
  - The `print_ard_conditions(call)`, `check_list_elements(env)`, `cards_select(.call)` arguments have been removed.

# cards 0.1.0

* Initial release.

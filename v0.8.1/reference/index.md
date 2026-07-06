# Package index

## ARD Creation

### Data Summaries

- [`ard_summary()`](https://insightsengineering.github.io/cards/reference/ard_summary.md)
  : Univariate ARD Statistics
- [`ard_tabulate()`](https://insightsengineering.github.io/cards/reference/ard_tabulate.md)
  : Tabulate ARD
- [`ard_tabulate_value()`](https://insightsengineering.github.io/cards/reference/ard_tabulate_value.md)
  : Tabulate Value ARD
- [`ard_tabulate_rows()`](https://insightsengineering.github.io/cards/reference/ard_tabulate_rows.md)
  : Row Tabulate ARD
- [`ard_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_hierarchical.md)
  [`ard_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_hierarchical.md)
  : Hierarchical ARD Statistics
- [`ard_missing()`](https://insightsengineering.github.io/cards/reference/ard_missing.md)
  : Missing ARD Statistics
- [`ard_total_n()`](https://insightsengineering.github.io/cards/reference/ard_total_n.md)
  : ARD Total N
- [`ard_mvsummary()`](https://insightsengineering.github.io/cards/reference/ard_mvsummary.md)
  : Multivariate ARD Summaries
- [`ard_stack()`](https://insightsengineering.github.io/cards/reference/ard_stack.md)
  : Stack ARDs
- [`ard_stack_hierarchical()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
  [`ard_stack_hierarchical_count()`](https://insightsengineering.github.io/cards/reference/ard_stack_hierarchical.md)
  : Stacked Hierarchical ARD Statistics

### Misc.

- [`ard_strata()`](https://insightsengineering.github.io/cards/reference/ard_strata.md)
  : Stratified ARD
- [`ard_pairwise()`](https://insightsengineering.github.io/cards/reference/ard_pairwise.md)
  : Pairwise ARD
- [`ard_attributes()`](https://insightsengineering.github.io/cards/reference/ard_attributes.md)
  : ARD Attributes
- [`ard_identity()`](https://insightsengineering.github.io/cards/reference/ard_identity.md)
  : ARD Identity

## ARD Utilities

### Construct ARDs

- [`as_card()`](https://insightsengineering.github.io/cards/reference/as_card.md)
  : Data Frame as ARD
- [`bind_ard()`](https://insightsengineering.github.io/cards/reference/bind_ard.md)
  : Bind ARDs
- [`tidy_ard_column_order()`](https://insightsengineering.github.io/cards/reference/tidy_ard_order.md)
  [`tidy_ard_row_order()`](https://insightsengineering.github.io/cards/reference/tidy_ard_order.md)
  : Standard Order of ARD
- [`apply_fmt_fun()`](https://insightsengineering.github.io/cards/reference/apply_fmt_fun.md)
  : Apply Formatting Functions
- [`update_ard_fmt_fun()`](https://insightsengineering.github.io/cards/reference/update_ard.md)
  [`update_ard_stat_label()`](https://insightsengineering.github.io/cards/reference/update_ard.md)
  : Update ARDs
- [`process_selectors()`](https://insightsengineering.github.io/cards/reference/process_selectors.md)
  [`process_formula_selectors()`](https://insightsengineering.github.io/cards/reference/process_selectors.md)
  [`fill_formula_selectors()`](https://insightsengineering.github.io/cards/reference/process_selectors.md)
  [`compute_formula_selector()`](https://insightsengineering.github.io/cards/reference/process_selectors.md)
  [`check_list_elements()`](https://insightsengineering.github.io/cards/reference/process_selectors.md)
  [`cards_select()`](https://insightsengineering.github.io/cards/reference/process_selectors.md)
  : Process tidyselectors
- [`ard_formals()`](https://insightsengineering.github.io/cards/reference/ard_formals.md)
  : Argument Values ARD
- [`nest_for_ard()`](https://insightsengineering.github.io/cards/reference/nest_for_ard.md)
  : ARD Nesting
- [`default_stat_labels()`](https://insightsengineering.github.io/cards/reference/default_stat_labels.md)
  : Defaults for Statistical Arguments
- [`check_ard_structure()`](https://insightsengineering.github.io/cards/reference/check_ard_structure.md)
  : Check ARD Structure
- [`alias_as_fmt_fun()`](https://insightsengineering.github.io/cards/reference/alias_as_fmt_fun.md)
  : Convert Alias to Function
- [`label_round()`](https://insightsengineering.github.io/cards/reference/label_round.md)
  : Generate Formatting Function
- [`rename_ard_columns()`](https://insightsengineering.github.io/cards/reference/rename_ard_columns.md)
  : Rename ARD Variables
- [`unlist_ard_columns()`](https://insightsengineering.github.io/cards/reference/unlist_ard_columns.md)
  : Unlist ARD Columns
- [`add_calculated_row()`](https://insightsengineering.github.io/cards/reference/add_calculated_row.md)
  : Add Calculated Row
- [`as_cards_fn()`](https://insightsengineering.github.io/cards/reference/as_cards_fn.md)
  [`is_cards_fn()`](https://insightsengineering.github.io/cards/reference/as_cards_fn.md)
  [`get_cards_fn_stat_names()`](https://insightsengineering.github.io/cards/reference/as_cards_fn.md)
  : As card function

### Wrangle ARD

- [`filter_ard_hierarchical()`](https://insightsengineering.github.io/cards/reference/filter_ard_hierarchical.md)
  **\[experimental\]** : Filter Stacked Hierarchical ARDs
- [`sort_ard_hierarchical()`](https://insightsengineering.github.io/cards/reference/sort_ard_hierarchical.md)
  **\[experimental\]** : Sort Stacked Hierarchical ARDs
- [`ard_continuous()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`ard_categorical()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`ard_complex()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`ard_dichotomous()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`apply_fmt_fn()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`alias_as_fmt_fn()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`update_ard_fmt_fn()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`shuffle_ard()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  **\[deprecated\]** : Deprecated functions
- [`as_nested_list()`](https://insightsengineering.github.io/cards/reference/as_nested_list.md)
  **\[experimental\]** : ARD as Nested List
- [`get_ard_statistics()`](https://insightsengineering.github.io/cards/reference/get_ard_statistics.md)
  : ARD Statistics as List
- [`replace_null_statistic()`](https://insightsengineering.github.io/cards/reference/replace_null_statistic.md)
  : Replace NULL Statistics with Specified Value
- [`rename_ard_groups_shift()`](https://insightsengineering.github.io/cards/reference/rename_ard_groups.md)
  [`rename_ard_groups_reverse()`](https://insightsengineering.github.io/cards/reference/rename_ard_groups.md)
  : Rename ARD Group Columns
- [`compare_ard()`](https://insightsengineering.github.io/cards/reference/compare_ard.md)
  [`is_ard_equal()`](https://insightsengineering.github.io/cards/reference/compare_ard.md)
  [`check_ard_equal()`](https://insightsengineering.github.io/cards/reference/compare_ard.md)
  **\[experimental\]** : Compare ARDs

### Table Shells

- [`mock_categorical()`](https://insightsengineering.github.io/cards/reference/mock.md)
  [`mock_continuous()`](https://insightsengineering.github.io/cards/reference/mock.md)
  [`mock_dichotomous()`](https://insightsengineering.github.io/cards/reference/mock.md)
  [`mock_missing()`](https://insightsengineering.github.io/cards/reference/mock.md)
  [`mock_attributes()`](https://insightsengineering.github.io/cards/reference/mock.md)
  [`mock_total_n()`](https://insightsengineering.github.io/cards/reference/mock.md)
  **\[experimental\]** : Mock ARDs

### Data Summary Functions

- [`continuous_summary_fns()`](https://insightsengineering.github.io/cards/reference/summary_functions.md)
  : Summary Functions
- [`maximum_variable_value()`](https://insightsengineering.github.io/cards/reference/maximum_variable_value.md)
  : Maximum Value

### Misc.

- [`all_ard_groups()`](https://insightsengineering.github.io/cards/reference/selectors.md)
  [`all_ard_variables()`](https://insightsengineering.github.io/cards/reference/selectors.md)
  [`all_ard_group_n()`](https://insightsengineering.github.io/cards/reference/selectors.md)
  [`all_missing_columns()`](https://insightsengineering.github.io/cards/reference/selectors.md)
  : ARD Selectors
- [`eval_capture_conditions()`](https://insightsengineering.github.io/cards/reference/eval_capture_conditions.md)
  [`captured_condition_as_message()`](https://insightsengineering.github.io/cards/reference/eval_capture_conditions.md)
  [`captured_condition_as_error()`](https://insightsengineering.github.io/cards/reference/eval_capture_conditions.md)
  : Evaluate and Capture Conditions
- [`print_ard_conditions()`](https://insightsengineering.github.io/cards/reference/print_ard_conditions.md)
  : Print ARD Condition Messages
- [`round5()`](https://insightsengineering.github.io/cards/reference/round5.md)
  : Rounding of Numbers
- [`cards.options`](https://insightsengineering.github.io/cards/reference/cards.options.md)
  : Options in {cards}

## Data

- [`ADSL`](https://insightsengineering.github.io/cards/reference/adam.md)
  [`ADAE`](https://insightsengineering.github.io/cards/reference/adam.md)
  [`ADTTE`](https://insightsengineering.github.io/cards/reference/adam.md)
  [`ADLB`](https://insightsengineering.github.io/cards/reference/adam.md)
  : Example ADaM Data

## Deprecated Functions

- [`ard_continuous()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`ard_categorical()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`ard_complex()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`ard_dichotomous()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`apply_fmt_fn()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`alias_as_fmt_fn()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`update_ard_fmt_fn()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  [`shuffle_ard()`](https://insightsengineering.github.io/cards/reference/deprecated.md)
  **\[deprecated\]** : Deprecated functions

# ARD Attributes

Add variable attributes to an ARD data frame.

- The `label` attribute will be added for all columns, and when no label
  is specified and no label has been set for a column using the `label=`
  argument, the column name will be placed in the label statistic.

- The `class` attribute will also be returned for all columns.

- Any other attribute returned by
  [`attributes()`](https://rdrr.io/r/base/attributes.html) will also be
  added, e.g. factor levels.

## Usage

``` r
ard_attributes(data, ...)

# S3 method for class 'data.frame'
ard_attributes(data, variables = everything(), label = NULL, ...)

# Default S3 method
ard_attributes(data, ...)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- ...:

  These dots are for future extensions and must be empty.

- variables:

  ([`tidy-select`](https://dplyr.tidyverse.org/reference/dplyr_tidy_select.html))\
  variables to include

- label:

  (named `list`)\
  named list of variable labels, e.g. `list(cyl = "No. Cylinders")`.
  Default is `NULL`

## Value

an ARD data frame of class 'card'

## Examples

``` r
df <- dplyr::tibble(var1 = letters, var2 = LETTERS)
attr(df$var1, "label") <- "Lowercase Letters"

ard_attributes(df, variables = everything())
#> {cards} data frame: 4 x 8
#>   variable   context stat_name stat_label      stat fmt_fun
#> 1     var1 attribut…     label  Variable… Lowercas…    <fn>
#> 2     var1 attribut…     class  Variable… character    NULL
#> 3     var2 attribut…     label  Variable…      var2    <fn>
#> 4     var2 attribut…     class  Variable… character    NULL
#> ℹ 2 more variables: warning, error
```

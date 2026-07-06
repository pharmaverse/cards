# Create List for Attributes

Create List for Attributes

## Usage

``` r
.create_list_for_attributes(ard_subset, attributes, i)
```

## Arguments

- ard_subset:

  (`data.frame`)\
  an ARD data frame of class 'card'

- attributes:

  (`character`)\
  a character vector of attribute names

- i:

  (`integer`)\
  a row index number

## Value

a named list

## Examples

``` r
ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")

cards:::.create_list_for_attributes(ard, c("group1", "group1_level"), 1)
#> $group1
#> [1] "ARM"
#> 
#> $group1_level
#> [1] "Placebo"
#> 
```

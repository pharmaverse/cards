# Derive overall labels

Transform the `"..cards_overall.."` and `"..hierarchical_overall.."`
labels into `"Overall <variable_name>"` and `"Any <variable_name>"`
respectively. Also it ensures the labels are unique (in case they
already exist) with
[`make.unique()`](https://rdrr.io/r/base/make.unique.html) which appends
a sequence number.

## Usage

``` r
.derive_overall_labels(x, cur_col = dplyr::cur_column())
```

## Arguments

- x:

  (character) content of target (current) column

- cur_col:

  (character) name of current column

## Value

a character vector

## Examples

``` r
data <- dplyr::tibble(
  ARM = c("..cards_overall..", "Overall ARM", NA, "BB", NA),
  TRTA = c(NA, NA, "..hierarchical_overall..", "C", "C")
)

data |>
  dplyr::mutate(
    dplyr::across(
      ARM:TRTA,
      cards:::.derive_overall_labels
    )
  )
#> ℹ "Overall ARM" already exists in the `ARM` column. Using "Overall ARM.1".
#> # A tibble: 5 × 2
#>   ARM           TRTA    
#>   <chr>         <chr>   
#> 1 Overall ARM.1 NA      
#> 2 Overall ARM   NA      
#> 3 NA            Any TRTA
#> 4 BB            C       
#> 5 NA            C       
```

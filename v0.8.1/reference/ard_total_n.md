# ARD Total N

Returns the total N for the data frame. The placeholder variable name
returned in the object is `"..ard_total_n.."`

## Usage

``` r
ard_total_n(data, ...)

# S3 method for class 'data.frame'
ard_total_n(data, ...)
```

## Arguments

- data:

  (`data.frame`)\
  a data frame

- ...:

  Arguments passed to methods.

## Value

an ARD data frame of class 'card'

## Examples

``` r
ard_total_n(ADSL)
#> {cards} data frame: 1 x 8
#>          variable context stat_name stat_label stat fmt_fun
#> 1 ..ard_total_n.. total_n         N          N  254       0
#> ℹ 2 more variables: warning, error
```

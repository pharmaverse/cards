# Convert Alias to Function

Accepted aliases are non-negative integers and strings.

The integers are converted to functions that round the statistics to the
number of decimal places to match the integer.

The formatting strings come in the form `"xx"`, `"xx.x"`, `"xx.x%"`,
etc. The number of `x`s that appear after the decimal place indicate the
number of decimal places the statistics will be rounded to. The number
of `x`s that appear before the decimal place indicate the leading spaces
that are added to the result. If the string ends in `"%"`, results are
scaled by 100 before rounding.

## Usage

``` r
alias_as_fmt_fun(x, variable, stat_name)
```

## Arguments

- x:

  (`integer`, `string`, or `function`)\
  a non-negative integer, string alias, or function

- variable:

  (`character`)\
  the variable whose statistic is to be formatted

- stat_name:

  (`character`)\
  the name of the statistic that is to be formatted

## Value

a function

## Examples

``` r
alias_as_fmt_fun(1)
#> function(x) {
#>     # round and scale vector
#>     res <-
#>       ifelse(
#>         is.na(x),
#>         NA_character_,
#>         format(round_fun(x * scale, digits = digits), nsmall = digits) |> str_trim()
#>       )
#> 
#> 
#>     # if width provided, pad formatted result
#>     if (!is.null(width)) {
#>       res <-
#>         ifelse(
#>           nchar(res) >= width | is.na(res),
#>           res,
#>           paste0(strrep(" ", width - nchar(res)), res)
#>         )
#>     }
#> 
#>     # return final formatted vector
#>     res
#>   }
#> <environment: 0x563a6f581670>
alias_as_fmt_fun("xx.x")
#> function(x) {
#>     # round and scale vector
#>     res <-
#>       ifelse(
#>         is.na(x),
#>         NA_character_,
#>         format(round_fun(x * scale, digits = digits), nsmall = digits) |> str_trim()
#>       )
#> 
#> 
#>     # if width provided, pad formatted result
#>     if (!is.null(width)) {
#>       res <-
#>         ifelse(
#>           nchar(res) >= width | is.na(res),
#>           res,
#>           paste0(strrep(" ", width - nchar(res)), res)
#>         )
#>     }
#> 
#>     # return final formatted vector
#>     res
#>   }
#> <environment: 0x563a6c7537e0>
```

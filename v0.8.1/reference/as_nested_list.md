# ARD as Nested List

**\[experimental\]**\
Convert ARDs to nested lists.

## Usage

``` r
as_nested_list(x)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

## Value

a nested list

## Examples

``` r
ard_summary(mtcars, by = "cyl", variables = c("mpg", "hp")) |>
  as_nested_list()
#> $variable
#> $variable$mpg
#> $variable$mpg$group1
#> $variable$mpg$group1$cyl
#> $variable$mpg$group1$cyl$group1_level
#> $variable$mpg$group1$cyl$group1_level$`4`
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$N
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$N$stat
#> [1] 11
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$N$stat_fmt
#> [1] "11"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$N$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$N$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$N$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$mean
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$mean$stat
#> [1] 26.66364
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$mean$stat_fmt
#> [1] "26.7"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$mean$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$mean$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$mean$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$sd
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$sd$stat
#> [1] 4.509828
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$sd$stat_fmt
#> [1] "4.5"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$sd$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$sd$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$sd$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$median
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$median$stat
#> [1] 26
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$median$stat_fmt
#> [1] "26.0"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$median$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$median$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$median$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p25
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p25$stat
#> [1] 22.8
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p25$stat_fmt
#> [1] "22.8"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p25$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p25$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p25$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p75
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p75$stat
#> [1] 30.4
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p75$stat_fmt
#> [1] "30.4"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p75$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p75$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$p75$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$min
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$min$stat
#> [1] 21.4
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$min$stat_fmt
#> [1] "21.4"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$min$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$min$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$min$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$max
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$max$stat
#> [1] 33.9
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$max$stat_fmt
#> [1] "33.9"
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$max$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$max$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`4`$stat_name$max$context
#> [1] "summary"
#> 
#> 
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$N
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$N$stat
#> [1] 7
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$N$stat_fmt
#> [1] "7"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$N$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$N$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$N$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$mean
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$mean$stat
#> [1] 19.74286
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$mean$stat_fmt
#> [1] "19.7"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$mean$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$mean$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$mean$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$sd
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$sd$stat
#> [1] 1.453567
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$sd$stat_fmt
#> [1] "1.5"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$sd$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$sd$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$sd$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$median
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$median$stat
#> [1] 19.7
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$median$stat_fmt
#> [1] "19.7"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$median$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$median$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$median$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p25
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p25$stat
#> [1] 18.1
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p25$stat_fmt
#> [1] "18.1"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p25$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p25$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p25$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p75
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p75$stat
#> [1] 21
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p75$stat_fmt
#> [1] "21.0"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p75$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p75$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$p75$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$min
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$min$stat
#> [1] 17.8
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$min$stat_fmt
#> [1] "17.8"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$min$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$min$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$min$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$max
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$max$stat
#> [1] 21.4
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$max$stat_fmt
#> [1] "21.4"
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$max$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$max$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`6`$stat_name$max$context
#> [1] "summary"
#> 
#> 
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$N
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$N$stat
#> [1] 14
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$N$stat_fmt
#> [1] "14"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$N$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$N$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$N$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$mean
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$mean$stat
#> [1] 15.1
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$mean$stat_fmt
#> [1] "15.1"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$mean$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$mean$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$mean$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$sd
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$sd$stat
#> [1] 2.560048
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$sd$stat_fmt
#> [1] "2.6"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$sd$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$sd$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$sd$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$median
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$median$stat
#> [1] 15.2
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$median$stat_fmt
#> [1] "15.2"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$median$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$median$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$median$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p25
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p25$stat
#> [1] 14.3
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p25$stat_fmt
#> [1] "14.3"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p25$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p25$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p25$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p75
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p75$stat
#> [1] 16.4
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p75$stat_fmt
#> [1] "16.4"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p75$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p75$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$p75$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$min
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$min$stat
#> [1] 10.4
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$min$stat_fmt
#> [1] "10.4"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$min$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$min$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$min$context
#> [1] "summary"
#> 
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$max
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$max$stat
#> [1] 19.2
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$max$stat_fmt
#> [1] "19.2"
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$max$warning
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$max$error
#> NULL
#> 
#> $variable$mpg$group1$cyl$group1_level$`8`$stat_name$max$context
#> [1] "summary"
#> 
#> 
#> 
#> 
#> 
#> 
#> 
#> 
#> $variable$hp
#> $variable$hp$group1
#> $variable$hp$group1$cyl
#> $variable$hp$group1$cyl$group1_level
#> $variable$hp$group1$cyl$group1_level$`4`
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$N
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$N$stat
#> [1] 11
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$N$stat_fmt
#> [1] "11"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$N$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$N$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$N$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$mean
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$mean$stat
#> [1] 82.63636
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$mean$stat_fmt
#> [1] "82.6"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$mean$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$mean$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$mean$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$sd
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$sd$stat
#> [1] 20.93453
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$sd$stat_fmt
#> [1] "20.9"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$sd$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$sd$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$sd$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$median
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$median$stat
#> [1] 91
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$median$stat_fmt
#> [1] "91.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$median$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$median$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$median$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p25
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p25$stat
#> [1] 65
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p25$stat_fmt
#> [1] "65.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p25$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p25$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p25$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p75
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p75$stat
#> [1] 97
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p75$stat_fmt
#> [1] "97.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p75$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p75$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$p75$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$min
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$min$stat
#> [1] 52
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$min$stat_fmt
#> [1] "52.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$min$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$min$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$min$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$max
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$max$stat
#> [1] 113
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$max$stat_fmt
#> [1] "113.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$max$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$max$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`4`$stat_name$max$context
#> [1] "summary"
#> 
#> 
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$N
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$N$stat
#> [1] 7
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$N$stat_fmt
#> [1] "7"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$N$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$N$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$N$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$mean
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$mean$stat
#> [1] 122.2857
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$mean$stat_fmt
#> [1] "122.3"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$mean$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$mean$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$mean$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$sd
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$sd$stat
#> [1] 24.26049
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$sd$stat_fmt
#> [1] "24.3"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$sd$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$sd$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$sd$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$median
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$median$stat
#> [1] 110
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$median$stat_fmt
#> [1] "110.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$median$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$median$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$median$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p25
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p25$stat
#> [1] 110
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p25$stat_fmt
#> [1] "110.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p25$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p25$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p25$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p75
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p75$stat
#> [1] 123
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p75$stat_fmt
#> [1] "123.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p75$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p75$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$p75$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$min
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$min$stat
#> [1] 105
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$min$stat_fmt
#> [1] "105.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$min$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$min$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$min$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$max
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$max$stat
#> [1] 175
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$max$stat_fmt
#> [1] "175.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$max$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$max$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`6`$stat_name$max$context
#> [1] "summary"
#> 
#> 
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$N
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$N$stat
#> [1] 14
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$N$stat_fmt
#> [1] "14"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$N$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$N$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$N$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$mean
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$mean$stat
#> [1] 209.2143
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$mean$stat_fmt
#> [1] "209.2"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$mean$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$mean$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$mean$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$sd
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$sd$stat
#> [1] 50.97689
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$sd$stat_fmt
#> [1] "51.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$sd$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$sd$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$sd$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$median
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$median$stat
#> [1] 192.5
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$median$stat_fmt
#> [1] "192.5"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$median$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$median$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$median$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p25
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p25$stat
#> [1] 175
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p25$stat_fmt
#> [1] "175.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p25$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p25$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p25$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p75
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p75$stat
#> [1] 245
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p75$stat_fmt
#> [1] "245.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p75$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p75$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$p75$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$min
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$min$stat
#> [1] 150
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$min$stat_fmt
#> [1] "150.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$min$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$min$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$min$context
#> [1] "summary"
#> 
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$max
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$max$stat
#> [1] 335
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$max$stat_fmt
#> [1] "335.0"
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$max$warning
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$max$error
#> NULL
#> 
#> $variable$hp$group1$cyl$group1_level$`8`$stat_name$max$context
#> [1] "summary"
#> 
#> 
#> 
#> 
#> 
#> 
#> 
#> 
#> 
```

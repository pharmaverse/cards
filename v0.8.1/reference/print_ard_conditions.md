# Print ARD Condition Messages

Function parses the errors and warnings observed while calculating the
statistics requested in the ARD and prints them to the console as
messages.

## Usage

``` r
print_ard_conditions(x, condition_type = c("inform", "identity"))
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- condition_type:

  (`string`)\
  indicates how warnings and errors are returned. Default is `"inform"`
  where all are returned as messages. When `"identity"`, errors are
  returned as errors and warnings as warnings.

## Value

returns invisible if check is successful, throws all condition messages
if not.

## Examples

``` r
# passing a character variable for numeric summary
ard_summary(ADSL, variables = AGEGR1) |>
  print_ard_conditions()
#> The following warnings were returned during `print_ard_conditions()`:
#> ! For variable `AGEGR1` and "mean" and "median" statistics: argument is not
#>   numeric or logical: returning NA
#> ! For variable `AGEGR1` and "sd" statistic: NAs introduced by coercion
```

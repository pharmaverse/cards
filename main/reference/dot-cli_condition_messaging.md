# Print Condition Messages Saved in an ARD

Print Condition Messages Saved in an ARD

## Usage

``` r
.cli_condition_messaging(x, msg_type, condition_type)
```

## Arguments

- x:

  (`data.frame`)\
  an ARD data frame of class 'card'

- msg_type:

  (`string`)\
  message type. Options are `"warning"` and `"error"`.

## Value

returns invisible if check is successful, throws warning/error messages
if not.

## Examples

``` r
ard <- ard_summary(
  ADSL,
  by = ARM,
  variables = AGE
)

cards:::.cli_condition_messaging(ard, msg_type = "error")
```

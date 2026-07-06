# Other ARD Representations

The default structure of a {cards} object is data frame. But it is often
needed to represent the results in other formats.

The {cards} objects can easily be expressed in YAML and JSON formats.

Let’s begin by creating an Analysis Results Data (ARD) object.

``` r

library(cards)

ard <-
  bind_ard(
    ard_summary(ADSL, by = "ARM", variables = "AGE"),
    ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
  )

ard
#> {cards} data frame: 51 x 11
#>    group1 group1_level variable variable_level stat_name stat_label   stat
#> 1     ARM      Placebo      AGE                        N          N     86
#> 2     ARM      Placebo      AGE                     mean       Mean 75.209
#> 3     ARM      Placebo      AGE                       sd         SD   8.59
#> 4     ARM      Placebo      AGE                   median     Median     76
#> 5     ARM      Placebo      AGE                      p25         Q1     69
#> 6     ARM      Placebo      AGE                      p75         Q3     82
#> 7     ARM      Placebo      AGE                      min        Min     52
#> 8     ARM      Placebo      AGE                      max        Max     89
#> 9     ARM    Xanomeli…      AGE                        N          N     84
#> 10    ARM    Xanomeli…      AGE                     mean       Mean 74.381
#> ℹ 41 more rows
#> ℹ Use `print(n = ...)` to see more rows
#> ℹ 4 more variables: context, fmt_fun, warning, error
```

## YAML

The
[`as_nested_list()`](https://insightsengineering.github.io/cards/reference/as_nested_list.md)
function prepares the ARD data frame to be converted to a YAML object.

``` r

ard |>
  as_nested_list() |>
  yaml::as.yaml() |>
  cat()
#> variable:
#>   AGE:
#>     group1:
#>       ARM:
#>         group1_level:
#>           Placebo:
#>             stat_name:
#>               'N':
#>                 stat: 86
#>                 stat_fmt: '86'
#>                 warning: ~
#>                 error: ~
#>                 context: summary
#>               mean:
#>                 stat: 75.2093023
...
```

## JSON

The
[`as_nested_list()`](https://insightsengineering.github.io/cards/reference/as_nested_list.md)
function prepares the ARD data frame to be converted to a JSON object.

``` r

ard |>
  as_nested_list() |>
  jsonlite::toJSON(pretty = TRUE)
#> {
#>   "variable": {
#>     "AGE": {
#>       "group1": {
#>         "ARM": {
#>           "group1_level": {
#>             "Placebo": {
#>               "stat_name": {
#>                 "N": {
#>                   "stat": [86],
#>                   "stat_fmt": ["86"],
#>                   "warning": {},
#>                   "error": {},
#>                   "context": ["summary"]
#>                 },
...
```

Use the
[`jsonlite::write_json()`](https://jeroen.r-universe.dev/jsonlite/reference/read_json.html)
function to convert to JSON and write to disk simultaneously.

## REST API

With the JSON format, ARDs can be made accessible via REST APIs. Using
the {plumber} package, an API can be created in a `plumber.R` file.

``` r

library(cards)
library(plumber)
library(jsonlite)

#* @get /nested_json
#* @serializer unboxedJSON
function() {
  ard <- bind_ard(
    ard_summary(ADSL, by = "ARM", variables = "AGE"),
    ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
  )

  ard |>
    as_nested_list() |>
    toJSON()
}
```

The following code serves the API, making it available for testing.
Note: “plumber.R” represents the path to the `plumber.R` file created
above.

``` r

library(plumber)

pr("plumber.R") |>
  pr_run(
    host = "127.0.0.1",
    port = 8000
  )
```

Data is requested from a hosted API via the {httr} package and converted
back to a nested list using {jsonlite}.

``` r

library(httr)
library(jsonlite)

GET("http://127.0.0.1:8000/nested_json") |>
  content() |>
  fromJSON()
```

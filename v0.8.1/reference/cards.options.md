# Options in {cards}

See below for options available in the {cards} package

## cards.round_type

There are two types of rounding types in the {cards} package that are
implemented in
[`label_round()`](https://insightsengineering.github.io/cards/reference/label_round.md),
[`alias_as_fmt_fun()`](https://insightsengineering.github.io/cards/reference/alias_as_fmt_fun.md),
and
[`apply_fmt_fun()`](https://insightsengineering.github.io/cards/reference/apply_fmt_fun.md)
functions.

- `'round-half-up'` (*default*): rounding method where values exactly
  halfway between two numbers are rounded to the larger in magnitude
  number. Rounding is implemented via
  [`round5()`](https://insightsengineering.github.io/cards/reference/round5.md).

- `'round-to-even'`: base R's default IEC 60559 rounding standard. See
  [`round()`](https://rdrr.io/r/base/Round.html) for details.

To change the default rounding to use IEC 60559, this option must be set
**both** when the ARDs are created and when
[`apply_fmt_fun()`](https://insightsengineering.github.io/cards/reference/apply_fmt_fun.md)
is run. This ensures that any *default* formatting functions created
with
[`label_round()`](https://insightsengineering.github.io/cards/reference/label_round.md)
utilize the specified rounding method and the method is used what
aliases are converted into functions (which occurs in
[`apply_fmt_fun()`](https://insightsengineering.github.io/cards/reference/apply_fmt_fun.md)
when it calls
[`alias_as_fmt_fun()`](https://insightsengineering.github.io/cards/reference/alias_as_fmt_fun.md)).

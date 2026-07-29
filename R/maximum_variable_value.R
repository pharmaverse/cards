#' Maximum Value
#'
#' For each column in the passed data frame, the function returns a named list
#' with the value being the largest/last element after a sort. Character values
#' are ordered in the C locale (via `order(method = "radix")`), so the result is
#' independent of the session locale and consistent with the ordering used
#' elsewhere in the package.
#' For factors, the last level is returned, and for logical vectors `TRUE` is returned.
#'
#' @param data (`data.frame`)\cr
#'   a data frame
#'
#' @return a named list
#' @export
#'
#' @examples
#' ADSL[c("AGEGR1", "BMIBLGR1")] |> maximum_variable_value()
maximum_variable_value <- function(data) {
  data |>
    lapply(
      function(x) {
        if (inherits(x, "factor")) {
          return(levels(x) |> dplyr::last())
        }
        if (inherits(x, "logical")) {
          return(TRUE)
        }
        ux <- stats::na.omit(x) |> unique()
        ux[order(ux, method = "radix")] |> dplyr::last()
      }
    )
}

#' ARD Statistics as List
#'
#' Returns the statistics from an ARD as a named list.
#'
#' @param x (`data.frame`)\cr
#'   an ARD data frame of class 'card'
#' @param ... ([`dynamic-dots`][rlang::dyn-dots])\cr
#'   optional arguments indicating rows to subset of the ARD.
#'   For example, to return only rows where the column `"AGEGR1"` is `"65-80"`,
#'   pass `AGEGR1 %in% "65-80"`.
#' @param .column (`string`)\cr
#'   string indicating the column that will be returned in the list.
#'   Default is `"statistic"`
#' @param .attributes (`character`)\cr
#'   character vector of column names that will be returned
#'   in the list as attributes.
#'   Default is `NULL`
#'
#' @return named list
#' @export
#'
#' @examples
#' ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
#'
#' get_ard_statistics(
#'   ard,
#'   group1_level %in% "Placebo",
#'   variable_level %in% "65-80",
#'   .attributes = "stat_label"
#' )
get_ard_statistics <- function(x,
                               ...,
                               .column = "stat",
                               .attributes = NULL) {
  set_cli_abort_call()

  # subset the ARD
  ard_subset <- dplyr::filter(x, ...)

  # return a named list of the selected stats
  # add attributes for the label, formatting function, warnings, and errors
  seq_len(nrow(ard_subset)) |>
    lapply(
      FUN = function(i) {
        stat <- ard_subset[[.column]][[i]]
        # attributes cannot be attached to NULL (an error as of R 4.5.0),
        # so return the NULL statistic unchanged
        if (is.null(stat)) {
          return(NULL)
        }
        # styler: off
        stat %>%
          {inject(structure(
            ., !!!.create_list_for_attributes(ard_subset, .attributes, i)
          ))}
        # styler: on
      }
    ) |>
    stats::setNames(ard_subset[["stat_name"]])
}

#' Create List for Attributes
#'
#' @param ard_subset (`data.frame`)\cr
#'   an ARD data frame of class 'card'
#' @param attributes (`character`)\cr
#'   a character vector of attribute names
#' @param i (`integer`)\cr
#'   a row index number
#'
#' @return a named list
#' @keywords internal
#'
#' @examples
#' ard <- ard_tabulate(ADSL, by = "ARM", variables = "AGEGR1")
#'
#' cards:::.create_list_for_attributes(ard, c("group1", "group1_level"), 1)
.create_list_for_attributes <- function(ard_subset, attributes, i) {
  ret <- list()
  for (attr in attributes) {
    ret <- c(ret, list(ard_subset[[attr]][[i]]))
  }
  stats::setNames(ret, nm = attributes)
}

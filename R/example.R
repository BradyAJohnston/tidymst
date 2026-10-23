#' Get paths to example exports
#'
#' tidymst comes bundled with example MO.Affinity Analysis exports in its
#' `inst/extdata` directory. This function makes them easy to access.
#'
#' Most of the files are from one experiment: the binding of a Cy5-labelled
#' PPR protein, dPPR10-Cy5, to two RNA targets (atpH-fl and NEAT1-fl), exported
#' in several formats.
#'
#' @param file Name of a file. If `NULL`, the example files will be listed.
#' @returns A path, or a character vector of file names.
#' @export
#' @examples
#' tidymst_example()
#' tidymst_example("dppr10-cy5_traces.xlsx")
tidymst_example <- function(file = NULL) {
  check_string(file, allow_null = TRUE)
  files <- sort(
    dir(system.file("extdata", package = "tidymst")),
    method = "radix"
  )
  if (is.null(file)) {
    return(files)
  }
  if (!file %in% files) {
    cli::cli_abort(c(
      "{.val {file}} isn't an example file.",
      i = "Available files: {.val {files}}."
    ))
  }
  system.file("extdata", file, package = "tidymst")
}

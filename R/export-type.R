#' Detect the type of a MO.Affinity Analysis export
#'
#' MO.Affinity Analysis records which view an Excel export was made from in
#' its `Exported from:` field. `mst_export_type()` reads that field and returns
#' a short identifier, which [read_mst()] uses to pick a reader. It also
#' recognises the project files written by MO.Control (`.moc`) and
#' MO.Affinity Analysis (`.nta`), which are SQLite databases.
#'
#' @param path Path to an `.xlsx` file exported from MO.Affinity Analysis, or
#'   a `.moc` or `.nta` project file.
#'
#' @returns A string, one of:
#'   * `"traces"`: MST Traces, including the Raw Data Inspection variant.
#'   * `"capillary_scan"`: Capillary Scan.
#'   * `"compare_chart"`: Compare Results (Chart).
#'   * `"compare_grid"`: Compare Results (Grid).
#'   * `"dose_response_grouped"`: Dose-Response (Grouped).
#'   * `"dose_response_flat"`: Dose-Response (Flat).
#'   * `"affinity_project"`: an MO.Affinity Analysis project (`.nta`), with
#'     both the measurements and their analysis.
#'   * `"control_project"`: an MO.Control project (`.moc`), with the
#'     measurements only.
#' @export
#' @examples
#' mst_export_type(tidymst_example("dppr10-cy5_traces.xlsx"))
#' mst_export_type(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))
#' mst_export_type(tidymst_example("dppr10-cy5.nta"))
mst_export_type <- function(path) {
  check_path(path)
  if (is_sqlite(path)) {
    return(project_type(path))
  }
  exported_from <- exported_from(path)

  type <- if (!is.na(exported_from)) {
    export_types[startsWith(exported_from, names(export_types))]
  }
  if (length(type) == 0) {
    cli::cli_abort(c(
      "Can't read {.file {path}}.",
      i = "It was exported from {.val {exported_from}}.",
      i = "Supported exports are from {.or {.val {names(export_types)}}}."
    ))
  }
  unname(type[[1]])
}

export_types <- c(
  "MST Traces" = "traces",
  "Capillary Scan" = "capillary_scan",
  "Compare Results (Chart)" = "compare_chart",
  "Compare Results (Grid)" = "compare_grid",
  "Dose-Response (Grouped)" = "dose_response_grouped",
  "Dose-Response (Flat)" = "dose_response_flat"
)

is_sqlite <- function(path) {
  header <- readBin(path, "raw", n = 16)
  identical(header, c(charToRaw("SQLite format 3"), as.raw(0)))
}

exported_from <- function(path) {
  sheets <- readxl::excel_sheets(path)
  # Flat exports keep their header on a separate sheet.
  sheet <- if ("MetaData" %in% sheets) "MetaData" else 1
  m <- read_sheet(path, sheet)
  if (ncol(m) < 2) {
    return(NA_character_)
  }
  m[match("Exported from:", m[, 1]), 2]
}

check_path <- function(path, arg = caller_arg(path), call = caller_env()) {
  check_string(path, arg = arg, call = call)
  if (!file.exists(path)) {
    cli::cli_abort("{.file {path}} doesn't exist.", call = call)
  }
}

check_export_type <- function(
  path,
  types,
  arg = caller_arg(path),
  call = caller_env()
) {
  check_path(path, arg = arg, call = call)
  type <- mst_export_type(path)
  if (!type %in% types) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be a {.or {.val {types}}} export, not {.val {type}}.",
        i = "Use {.fn read_mst} to pick a reader automatically."
      ),
      call = call
    )
  }
  type
}

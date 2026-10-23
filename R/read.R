#' Read a MO.Affinity Analysis export
#'
#' `read_mst()` detects the type of export with [mst_export_type()] and reads
#' its main table:
#'
#' * MST Traces: [read_mst_traces()].
#' * Capillary Scan: [read_mst_capillary_scan()].
#' * Compare Results (Chart) and Dose-Response (Grouped and Flat):
#'   [read_mst_dose_response()].
#' * Compare Results (Grid): [read_mst_fit()].
#'
#' @inheritParams mst_export_type
#' @returns A tibble.
#' @seealso [read_mst_metadata()] for the file-level header, and
#'   [read_mst_fit()] and [read_mst_fit_curve()] for the fits included in
#'   Compare Results and Dose-Response (Grouped) exports.
#' @export
#' @examples
#' read_mst(tidymst_example("dppr10-cy5_dose-response-flat.xlsx"))
read_mst <- function(path) {
  type <- mst_export_type(path)
  switch(
    type,
    traces = read_mst_traces(path),
    capillary_scan = read_mst_capillary_scan(path),
    compare_grid = read_mst_fit(path),
    read_mst_dose_response(path)
  )
}

#' Read MST traces
#'
#' Reads an MST Traces export: the fluorescence of each capillary over time,
#' before and while the IR laser heats it. Normalised fluorescence (Fnorm) can
#' be recalculated from the traces with [mst_fnorm()].
#'
#' @inheritParams mst_export_type
#' @returns A tibble with one row per time point per capillary. Alongside
#'   the sample and measurement settings of each capillary, it has columns:
#'   * `included`: `FALSE` if the capillary was marked as an outlier.
#'   * `time`: time in seconds relative to the laser switching on.
#'   * `fluorescence`: fluorescence, normalised by MO.Affinity Analysis.
#'
#'   Concentrations are molar.
#' @export
#' @examples
#' read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
read_mst_traces <- function(path) {
  check_export_type(path, "traces")
  read_capillaries(path, c("time", "fluorescence"))
}

#' Read capillary scans
#'
#' Reads a Capillary Scan export: the raw fluorescence across the tray before
#' each measurement, which is used to check for sticking, aggregation and
#' pipetting errors.
#'
#' @inheritParams mst_export_type
#' @returns A tibble with one row per scan position per capillary. Alongside
#'   the sample and measurement settings of each capillary, it has columns:
#'   * `included`: `FALSE` if the capillary was marked as an outlier.
#'   * `position`: position along the tray, in capillary index units.
#'   * `fluorescence`: raw fluorescence counts.
#' @export
#' @examples
#' read_mst_capillary_scan(tidymst_example("dppr10c2_capillary-scan.xlsx"))
read_mst_capillary_scan <- function(path) {
  check_export_type(path, "capillary_scan")
  read_capillaries(path, c("position", "fluorescence"))
}

read_capillaries <- function(path, value_names) {
  m <- read_sheet(path)
  series <- find_series(m)
  blocks <- lapply(series$cols, \(col) parse_series(m, series$row, col))

  meta <- vctrs::vec_rbind(
    !!!lapply(blocks, \(b) {
      row <- meta_row(b$sections$sample, b$sections$measurement)
      row$included <- b$included
      row
    })
  )
  data <- lapply(blocks, \(b) {
    tibble::tibble(
      !!value_names[[1]] := b$data[, 1],
      !!value_names[[2]] := b$data[, 2]
    )
  })
  out <- coerce_columns(expand_meta(meta, data))
  dplyr::relocate(out, dplyr::any_of(c("merge_set", "run", "capillary")))
}

#' Read dose-response data
#'
#' Reads the response of each ligand concentration from a dose-response
#' export.
#'
#' * Compare Results (Chart) and Dose-Response (Grouped) exports give the
#'   mean response of each concentration in each merge set, with its error.
#'   Capillaries marked as outliers are excluded.
#' * Dose-Response (Flat) exports give the Fnorm of every capillary. They do
#'   not record which capillaries were marked as outliers, so all are
#'   included; join to [read_mst_traces()] by `run` and `capillary` to find
#'   them.
#'
#' Note that dates of measurement in Dose-Response (Flat) exports appear to be
#' in UTC, while other exports use the local time of the instrument computer.
#' Both are returned as recorded, labelled as UTC.
#'
#' @inheritParams mst_export_type
#' @returns A tibble with one row per concentration per series. It always
#'   has columns `merge_set`, `target`, `target_concentration`, `ligand`,
#'   `ligand_concentration`, `response_type` and `response`, followed by the
#'   other settings in the export.
#'
#'   * `response_type` is one of `"fnorm"`, `"delta_fnorm"` or
#'     `"fraction_bound"`, depending on how the data was exported. Fnorm and
#'     delta Fnorm are in per mille.
#'   * `series` numbers the merge sets in the order they appear in the export,
#'     to tell apart series that share a name. It matches `series` in
#'     [read_mst_fit()] and [read_mst_fit_curve()].
#'   * `error` is the error of the mean response.
#'
#'   Concentrations are molar.
#' @export
#' @examples
#' read_mst_dose_response(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))
#'
#' read_mst_dose_response(
#'   tidymst_example("dppr10-cy5_dose-response-flat.xlsx")
#' )
read_mst_dose_response <- function(path) {
  type <- check_export_type(
    path,
    c("compare_chart", "dose_response_grouped", "dose_response_flat")
  )
  out <- if (type == "dose_response_flat") {
    read_flat(path)
  } else {
    read_merge_sets(path)
  }
  dplyr::relocate(
    out,
    dplyr::any_of(c(
      "series",
      "merge_set",
      "run",
      "capillary",
      "target",
      "target_concentration",
      "ligand",
      "ligand_concentration",
      "response_type",
      "response",
      "error"
    ))
  )
}

read_merge_sets <- function(path) {
  m <- read_sheet(path)
  series <- find_series(m)
  blocks <- lapply(series$cols, \(col) parse_series(m, series$row, col))
  types <- merge_set_response_types(path, blocks)

  meta <- vctrs::vec_rbind(
    !!!lapply(seq_along(blocks), \(i) {
      sections <- blocks[[i]]$sections
      row <- meta_row(sections$sample, sections$measurement, sections$analysis)
      row$series <- as.character(i)
      row$response_type <- types[[i]]
      row
    })
  )
  data <- lapply(blocks, \(b) {
    tibble::tibble(
      ligand_concentration = b$data[, 1],
      response = b$data[, 2],
      error = b$data[, 3]
    )
  })
  coerce_columns(expand_meta(meta, data))
}

# Compare Results exports only say what the response is in the header of the
# fitted curves.
merge_set_response_types <- function(path, blocks) {
  header <- vapply(blocks, \(b) colnames(b$data)[[2]], character(1))
  types <- response_type(header)
  if (anyNA(types) && "Fit-Values" %in% readxl::excel_sheets(path)) {
    fit <- read_sheet(path, "Fit-Values")
    cols <- which(fit[1, ] %in% "Dose")
    types <- response_type(fit[1, cols + 2L])
  }
  vctrs::vec_recycle(types, length(blocks))
}

flat_names <- c(
  "Project-Name" = "project",
  "AnalysisSet" = "analysis_set",
  "AnalysisSetType" = "analysis_type",
  "EvaluationStrategy" = "evaluation_strategy",
  "MergeSet" = "merge_set",
  "Run" = "run",
  "OriginOfData" = "origin",
  "CapillaryIndex" = "capillary",
  "DateOfMeasurement" = "measured_at",
  "ColdRegionStart" = "cold_start",
  "ColdRegionEnd" = "cold_end",
  "HotRegionStart" = "hot_start",
  "HotRegionEnd" = "hot_end",
  "MSTPower" = "mst_power",
  "ExcitationPower" = "excitation_power",
  "MeasuredTemperature" = "temperature",
  "Target" = "target",
  "TargetConcentration" = "target_concentration",
  "Ligand" = "ligand",
  "LigandConcentration" = "ligand_concentration",
  "Fnorm" = "response",
  "ExportedOn" = "exported_on",
  "BleachingRate" = "bleaching_rate",
  "InitialFluorescence(MST)" = "initial_fluorescence"
)

read_flat <- function(path) {
  m <- read_sheet(path, "RawData")
  header <- m[1, ]
  names <- unname(flat_names[header])
  names[is.na(names)] <- snake_case(header[is.na(names)])

  out <- tibble::as_tibble(
    as.data.frame(m[-1, , drop = FALSE]),
    .name_repair = \(x) names
  )
  out$response_type <- "fnorm"
  coerce_columns(out)
}

#' Read binding fits
#'
#' Reads the fits that MO.Affinity Analysis made to each merge set. These are
#' included in Compare Results (Chart and Grid) and Dose-Response (Grouped)
#' exports.
#'
#' @inheritParams mst_export_type
#' @returns A tibble with one row per merge set, with columns:
#'   * `series`, `merge_set`, `target`, `target_concentration` and `ligand`
#'     identify the merge set. `series` is missing for Grid exports.
#'   * `model`: the fit model, `"kd"` or `"hill"`.
#'   * `unbound` and `bound`: the response of the unbound and bound states.
#'   * `kd` and `kd_confidence` (Kd model): the dissociation constant and its
#'     confidence, in molar.
#'   * `target_concentration_fit` (Kd model): the target concentration used
#'     in the fit, which may differ from the nominal `target_concentration`
#'     if it was a free parameter.
#'   * `ec50`, `ec50_confidence` and `hill` (Hill model): the half-maximal
#'     concentration, its confidence, and the Hill coefficient.
#'   * `std_dev`: the standard deviation of the residuals.
#'
#'   Grid exports also include fit statistics such as `std_error`,
#'   `reduced_chi_sq` and `signal_to_noise`.
#' @export
#' @examples
#' read_mst_fit(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))
#' read_mst_fit(tidymst_example("dsnppr10_compare-delta-fnorm.xlsx"))
read_mst_fit <- function(path) {
  type <- check_export_type(
    path,
    c("compare_chart", "compare_grid", "dose_response_grouped")
  )
  if (type == "compare_grid") {
    return(read_grid(path))
  }

  m <- read_sheet(path)
  series <- find_series(m)
  rows <- lapply(seq_along(series$cols), \(i) {
    sections <- parse_series(m, series$row, series$cols[[i]])$sections
    sample <- sections$sample
    sample <- sample[intersect(
      names(sample),
      c("Merge-Set Name", "Target", "TargetConcentration", "Ligand")
    )]
    row <- meta_row(sample, sections$fit)
    row$series <- as.character(i)
    row
  })
  out <- coerce_columns(vctrs::vec_rbind(!!!rows))
  dplyr::relocate(out, dplyr::any_of(c("series", "merge_set")))
}

grid_names <- c(
  "Name" = "merge_set",
  "Target Name" = "target",
  "Ligand Name" = "ligand",
  "Kd" = "kd",
  "Kd Confidence" = "kd_confidence",
  "EC50" = "ec50",
  "EC50 Confidence" = "ec50_confidence",
  "Hill Coeff." = "hill",
  "Response Amplitude" = "amplitude",
  "TargetConc" = "target_concentration_fit",
  "Unbound" = "unbound",
  "Bound" = "bound",
  "n" = "n",
  "Std. Error of Regression" = "std_error",
  "Signal to Noise" = "signal_to_noise",
  "Comments" = "comment",
  "Target concentration" = "target_concentration",
  "Ligand concentration" = "ligand_concentration",
  "Excitation Power" = "excitation_power",
  "MST Power" = "mst_power",
  "Temperature" = "temperature"
)

read_grid <- function(path) {
  m <- read_sheet(path)
  header_row <- match("Name", m[, 1])
  header <- m[header_row, ]
  rows <- seq(header_row + 1L, nrow(m))
  rows <- rows[!is.na(m[rows, 1])]

  names <- unname(grid_names[header])
  names[startsWith(header, "Reduced")] <- "reduced_chi_sq"
  keep <- !is.na(names)

  out <- tibble::as_tibble(
    as.data.frame(m[rows, keep, drop = FALSE]),
    .name_repair = \(x) names[keep]
  )
  out$model <- if ("ec50" %in% names(out)) "hill" else "kd"
  out <- coerce_columns(out)
  dplyr::relocate(
    out,
    dplyr::any_of(c(
      "merge_set",
      "target",
      "target_concentration",
      "ligand",
      "model"
    ))
  )
}

#' Read fitted binding curves
#'
#' Reads the curves MO.Affinity Analysis fitted to each merge set, from the
#' `Fit-Values` sheet of Compare Results (Chart) and Dose-Response (Grouped)
#' exports.
#'
#' @inheritParams mst_export_type
#' @returns A tibble with one row per point on each curve, with columns
#'   `series`, `merge_set`, `target`, `ligand_concentration`, `fnorm`,
#'   `response_type` and `response`. `response` is the curve in the units the
#'   data was exported in (see `response_type`); `fnorm` is the same curve as
#'   Fnorm. Some exports leave the curves empty, giving a tibble with no rows.
#' @export
#' @examples
#' read_mst_fit_curve(tidymst_example("dsnppr10_compare-delta-fnorm.xlsx"))
read_mst_fit_curve <- function(path) {
  check_export_type(path, c("compare_chart", "dose_response_grouped"))
  if (!"Fit-Values" %in% readxl::excel_sheets(path)) {
    cli::cli_abort("{.file {path}} doesn't have a {.val Fit-Values} sheet.")
  }

  m <- read_sheet(path, "Fit-Values")
  cols <- which(m[1, ] %in% "Dose")
  rows <- seq(2L, nrow(m))
  curves <- lapply(seq_along(cols), \(i) {
    col <- cols[[i]]
    tibble::tibble(
      series = as.character(i),
      ligand_concentration = m[rows, col],
      fnorm = m[rows, col + 1L],
      response_type = response_type(m[1, col + 2L]),
      response = m[rows, col + 2L]
    )
  })
  out <- coerce_columns(vctrs::vec_rbind(!!!curves))
  # Some exports write the concentrations but leave the curve empty.
  out <- out[!is.na(out$fnorm) | !is.na(out$response), ]

  ids <- read_mst_fit(path)[c("series", "merge_set", "target")]
  out <- dplyr::left_join(out, ids, by = "series")
  dplyr::relocate(out, "series", "merge_set", "target")
}

#' Read export metadata
#'
#' Reads the header that MO.Affinity Analysis writes at the top of every
#' export: where the data came from, when it was exported, and (for most
#' exports) the analysis settings.
#'
#' @inheritParams mst_export_type
#' @returns A tibble with one row. Columns include `software`, `project`,
#'   `analysis_set`, `exported_from` and `exported_on`, and, when the export
#'   has a single set of analysis settings, `analysis_type`,
#'   `evaluation_strategy` and the cold and hot regions in seconds
#'   (`cold_start`, `cold_end`, `hot_start`, `hot_end`).
#' @export
#' @examples
#' read_mst_metadata(tidymst_example("dppr10-cy5_traces.xlsx"))
read_mst_metadata <- function(path) {
  check_path(path)
  type <- mst_export_type(path)
  sheet <- if (type == "dose_response_flat") "MetaData" else 1
  m <- read_sheet(path, sheet)

  end <- which(apply(m, 1, \(x) any(x %in% c("Sample Information", "Name"))))
  end <- if (length(end)) end[[1]] - 1L else nrow(m)
  sections <- parse_sections(m, seq_len(end))$sections

  out <- meta_row(sections$origin, sections$analysis)
  software <- grep("^MO\\.", m[, 1], value = TRUE)
  out$software <- if (length(software)) software[[1]] else NA_character_
  out <- coerce_columns(out)
  dplyr::relocate(out, "software")
}

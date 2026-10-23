# Readers for the project files written by MO.Control (.moc) and MO.Affinity
# Analysis (.nta). Both are SQLite databases sharing the instrument's tables:
# capillaries (tCapillary) and their sample annotations, series of
# measurements (aSeries), MST traces (mMst) and capillary scans (mCapScan).
# MO.Affinity Analysis projects add the analysis: analysis sets, merge sets,
# runs, which traces are outliers, and the fitted parameters.

project_type <- function(path) {
  con <- db_connect(path)
  on.exit(DBI::dbDisconnect(con))
  if (DBI::dbExistsTable(con, "AffinityAnalysis")) {
    "affinity_project"
  } else {
    "control_project"
  }
}

db_connect <- function(path) {
  DBI::dbConnect(RSQLite::SQLite(), path, flags = RSQLite::SQLITE_RO)
}

db_query <- function(con, sql) {
  tibble::as_tibble(DBI::dbGetQuery(con, sql))
}

check_db_measurements <- function(con, path, table, call = caller_env()) {
  if (!DBI::dbExistsTable(con, table)) {
    cli::cli_abort(
      "{.file {path}} doesn't contain any measurements.",
      call = call
    )
  }
}

# Traces and scans ------------------------------------------------------------

read_db_traces <- function(path, call = caller_env()) {
  con <- db_connect(path)
  on.exit(DBI::dbDisconnect(con))
  check_db_measurements(con, path, "mMst", call = call)

  mst <- db_query(
    con,
    "SELECT ID AS measurement_id, Container AS capillary_id,
      ParentAction AS series_id, UtcStarted AS measured_at,
      MstPower AS mst_power, ExcitationPower AS excitation_power,
      Tsp AS thermostat_setpoint, Tm AS temperature, MstTrace AS blob
    FROM mMst"
  )
  mst$mst_power <- paste0(signif(mst$mst_power, 3), "%")

  data <- lapply(mst$blob, \(blob) {
    values <- decode_floats(blob, 2)
    raw <- values[, 2]
    tibble::tibble(
      time = values[, 1],
      fluorescence = raw / mean(raw[values[, 1] < 0]),
      fluorescence_raw = raw
    )
  })
  mst$blob <- NULL

  out <- db_annotate(con, mst, by = "measurement_id")
  db_finish(expand_meta(out, data[out$.row]))
}

read_db_capillary_scans <- function(path, call = caller_env()) {
  con <- db_connect(path)
  on.exit(DBI::dbDisconnect(con))
  check_db_measurements(con, path, "mCapScan", call = call)

  scans <- db_query(
    con,
    "SELECT ID AS measurement_id, Container AS capillary_id,
      ParentAction AS series_id, UtcStarted AS measured_at,
      ExcitationPower AS excitation_power, Tsp AS thermostat_setpoint,
      Tm AS temperature, CenterPosition AS centre, CapScanTrace AS blob
    FROM mCapScan"
  )
  blobs <- scans$blob
  scans$blob <- NULL
  out <- db_annotate(con, scans, by = c("series_id", "capillary_id"))

  data <- lapply(seq_len(nrow(out)), \(i) {
    values <- decode_floats(blobs[[out$.row[[i]]]], 4)
    tibble::tibble(
      # Positions are stored in mm along the tray, with capillaries 4.5 mm
      # apart. The Excel export gives them in units of capillary index.
      position = out$capillary[[i]] + (values[, 1] - out$centre[[i]]) / 4.5,
      fluorescence = values[, 4]
    )
  })
  out$centre <- NULL
  db_finish(expand_meta(out, data))
}

# Each record is `width` little-endian 32-bit floats.
decode_floats <- function(blob, width) {
  values <- readBin(
    blob,
    "numeric",
    size = 4,
    n = length(blob) %/% 4,
    endian = "little"
  )
  matrix(values, ncol = width, byrow = TRUE)
}

# Adds the sample, run and analysis information to a table of measurements.
# MST traces are assigned to analysis sets individually, by `measurement_id`;
# capillary scans by their series and capillary. Measurements in more than one
# analysis set appear once for each. `.row` indexes the original measurements.
db_annotate <- function(con, measurements, by) {
  measurements$.row <- seq_len(nrow(measurements))
  measurements$measured_at <- parse_utc(measurements$measured_at)

  out <- dplyr::left_join(
    measurements,
    db_capillaries(con),
    by = "capillary_id"
  )
  out <- dplyr::left_join(out, db_series(con), by = "series_id")
  out$run <- sprintf(
    "Run %s of Experiment #%02d",
    out$dilution_series,
    out$series_number
  )

  assignments <- db_assignments(con)
  if (!is.null(assignments)) {
    assignments <- assignments[c(
      by,
      "analysis_set",
      "merge_set",
      "run",
      "included"
    )]
    assignments <- assignments[
      !duplicated(assignments[c(by, "analysis_set")]),
    ]
    out <- dplyr::left_join(
      out,
      assignments,
      by = by,
      suffix = c("", ".analysis"),
      relationship = "many-to-many"
    )
    has_run <- !is.na(out$run.analysis)
    out$run[has_run] <- out$run.analysis[has_run]
    out$run.analysis <- NULL
  }
  out[order(out$series_number, out$capillary), ]
}

db_capillaries <- function(con) {
  capillaries <- db_query(
    con,
    "SELECT ID AS capillary_id, IndexOnParentContainer AS idx,
      ContainerType AS capillary_type, Annotations AS annotations
    FROM tCapillary"
  )
  annotations <- db_query(
    con,
    "SELECT ID AS annotation_id, AnnotationRole AS role, Caption AS caption,
      NumericValue AS value
    FROM Annotation"
  )

  ids <- strsplit(dplyr::coalesce(capillaries$annotations, ""), ";")
  links <- tibble::tibble(
    capillary_id = rep(capillaries$capillary_id, lengths(ids)),
    annotation_id = unlist(ids)
  )
  links <- dplyr::inner_join(links, annotations, by = "annotation_id")
  annotation <- function(role, col) {
    x <- links[links$role == role, ]
    x <- x[!duplicated(x$capillary_id), ]
    x[[col]][match(capillaries$capillary_id, x$capillary_id)]
  }

  tibble::tibble(
    capillary_id = capillaries$capillary_id,
    capillary = as.integer(capillaries$idx) + 1L,
    capillary_type = capillaries$capillary_type,
    # Concentrations are stored in mM.
    ligand = annotation("ligand", "caption"),
    ligand_concentration = annotation("ligand", "value") / 1000,
    target = annotation("target", "caption"),
    target_concentration = annotation("target", "value") / 1000,
    dilution_series = annotation("dilutionseries", "caption")
  )
}

# Series of measurements, numbered in the order they were measured.
db_series <- function(con) {
  series <- db_query(
    con,
    "SELECT ID AS series_id, UtcStarted AS started FROM aSeries"
  )
  started <- parse_utc(series$started)
  tibble::tibble(
    series_id = series$series_id,
    series_number = as.integer(rank(started, ties.method = "first"))
  )
}

# The analysis set, merge set, run and inclusion of each MST trace. NULL for
# MO.Control projects, which have no analysis.
db_assignments <- function(con) {
  if (!DBI::dbExistsTable(con, "AffinityAnalysis")) {
    return(NULL)
  }
  out <- db_query(
    con,
    "SELECT mst.ID AS measurement_id, mst.Container AS capillary_id,
      mst.ParentAction AS series_id, a.ID AS analysis_id,
      a.Caption AS analysis_set, ms.Caption AS merge_set, r.Caption AS run,
      t.MSTIncludance AS includance
    FROM AffinityAnalysisMstTrace t
    JOIN mMst mst ON t.RawMst = mst.ID
    JOIN AffinityAnalysisRun r ON t.ParentRun = r.ID
    JOIN AffinityAnalysisMergeSet ms ON r.ParentMergeSet = ms.ID
    JOIN AffinityAnalysis a ON ms.ParentAnalysis = a.ID"
  )
  out$included <- out$includance == "Included"
  out$includance <- NULL
  out
}

db_finish <- function(df) {
  for (col in c("analysis_set", "merge_set", "included")) {
    if (!col %in% names(df)) {
      df[[col]] <- if (col == "included") NA else NA_character_
    }
  }
  df$thermostat_setpoint <- as.character(df$thermostat_setpoint)
  df <- df[setdiff(
    names(df),
    c(
      ".row",
      "measurement_id",
      "capillary_id",
      "series_id",
      "series_number",
      "dilution_series"
    )
  )]
  df <- dplyr::relocate(
    df,
    "analysis_set",
    "merge_set",
    "run",
    "capillary",
    "measured_at"
  )
  values <- intersect(c("time", "position"), names(df))[[1]]
  dplyr::relocate(df, "included", .before = dplyr::all_of(values))
}

parse_utc <- function(x) {
  x[startsWith(x, "0001-01-01")] <- NA
  as.POSIXct(sub("Z$", "", x), format = "%Y-%m-%d %H:%M:%OS", tz = "UTC")
}

# Analysis --------------------------------------------------------------------

db_analysis_sets <- function(con) {
  out <- db_query(
    con,
    "SELECT ID AS analysis_id, Caption AS analysis_set,
      IndexOnParentProject AS idx, AffinityAnalysisType AS analysis_type,
      MstTraceEvaluationStrategy AS evaluation_strategy,
      ColdRegionStart AS cold_start, ColdRegionEnd AS cold_end,
      HotRegionStart AS hot_start, HotRegionEnd AS hot_end
    FROM AffinityAnalysis"
  )
  out$evaluation_strategy[out$evaluation_strategy == "m"] <- "Manual"
  out$analysis_type <- toupper(out$analysis_type)
  out <- out[order(out$idx), ]
  out$idx <- NULL
  out
}

# Fnorm of each trace, using the cold and hot regions of its analysis set.
read_db_dose_response <- function(path) {
  traces <- read_db_traces(path)
  con <- db_connect(path)
  on.exit(DBI::dbDisconnect(con))
  sets <- db_analysis_sets(con)

  traces <- traces[!is.na(traces$analysis_set), ]
  out <- lapply(seq_len(nrow(sets)), \(i) {
    set <- traces[traces$analysis_set == sets$analysis_set[[i]], ]
    if (nrow(set) == 0) {
      return(NULL)
    }
    fnorm <- mst_fnorm(
      set,
      hot = c(sets$hot_start[[i]], sets$hot_end[[i]]),
      cold = c(sets$cold_start[[i]], sets$cold_end[[i]])
    )
    dplyr::bind_cols(
      fnorm,
      sets[i, c("cold_start", "cold_end", "hot_start", "hot_end")]
    )
  })
  vctrs::vec_rbind(!!!out)
}

fit_parameter_names <- c(
  u = "unbound",
  b = "bound",
  kd = "kd",
  ct = "target_concentration_fit",
  e = "ec50",
  s = "hill"
)

read_db_fit <- function(path) {
  con <- db_connect(path)
  on.exit(DBI::dbDisconnect(con))

  params <- db_query(
    con,
    "SELECT a.Caption AS analysis_set, a.IndexOnParentProject AS set_idx,
      ms.ID AS merge_set_id, ms.Caption AS merge_set,
      ms.IndexOnParentAnalysis AS series, f.FitParameterType AS type,
      f.OutputValue AS value, f.Variance AS variance, f.IsFixed AS fixed
    FROM FitParameter f
    JOIN AffinityAnalysisMergeSet ms ON f.FittedEntity = ms.ID
    JOIN AffinityAnalysis a ON ms.ParentAnalysis = a.ID"
  )
  params$model <- sub("_.*", "", params$type)
  params$term <- unname(fit_parameter_names[sub("^[^_]*_", "", params$type)])
  params$std_error <- sqrt(params$variance)
  params$std_error[params$fixed == 1] <- NA
  # Models that weren't fitted are stored with missing values.
  params <- params[!is.na(params$value), ]

  samples <- db_query(
    con,
    "SELECT DISTINCT r.ParentMergeSet AS merge_set_id, mst.Container AS capillary_id
    FROM AffinityAnalysisMstTrace t
    JOIN AffinityAnalysisRun r ON t.ParentRun = r.ID
    JOIN mMst mst ON t.RawMst = mst.ID"
  )
  samples <- dplyr::left_join(samples, db_capillaries(con), by = "capillary_id")
  samples <- samples[!duplicated(samples$merge_set_id), ]

  keys <- c(
    "analysis_set",
    "set_idx",
    "merge_set_id",
    "merge_set",
    "series",
    "model"
  )
  fits <- dplyr::summarise(
    params,
    fixed = paste(.data$term[.data$fixed == 1], collapse = ", "),
    .by = dplyr::all_of(keys)
  )
  for (term in unique(fit_parameter_names)) {
    rows <- params[params$term == term, c(keys, "value", "std_error")]
    names(rows)[names(rows) == "value"] <- term
    names(rows)[names(rows) == "std_error"] <- paste0(term, "_std_error")
    fits <- dplyr::left_join(fits, rows, by = keys)
  }
  fits <- fits[vapply(fits, \(x) !all(is.na(x)), logical(1))]
  fits$fixed[fits$fixed == ""] <- NA

  fits <- dplyr::left_join(
    fits,
    samples[c("merge_set_id", "target", "target_concentration", "ligand")],
    by = "merge_set_id"
  )
  fits$series <- as.integer(fits$series) + 1L
  fits <- fits[order(fits$set_idx, fits$series, fits$model), ]
  fits$set_idx <- NULL
  fits$merge_set_id <- NULL
  dplyr::relocate(
    fits,
    "analysis_set",
    "series",
    "merge_set",
    "target",
    "target_concentration",
    "ligand",
    "model"
  )
}

read_db_metadata <- function(path, type) {
  con <- db_connect(path)
  on.exit(DBI::dbDisconnect(con))

  project <- db_query(
    con,
    "SELECT Caption AS project, CreatedOn AS created_at, UpdatedOn AS updated_at
    FROM Project"
  )[1, ]
  project$created_at <- parse_utc(project$created_at)
  project$updated_at <- parse_utc(project$updated_at)

  out <- tibble::tibble(
    software = if (type == "affinity_project") {
      "MO.Affinity Analysis"
    } else {
      "MO.Control"
    },
    project
  )
  for (table in c("tDevice", "tOptics")) {
    if (DBI::dbExistsTable(con, table)) {
      col <- if (table == "tDevice") "DeviceType" else "OpticsType"
      value <- db_query(con, paste0("SELECT ", col, " FROM ", table))[[1]]
      out[[if (table == "tDevice") "device_type" else "optics_type"]] <-
        if (length(value)) value[[1]] else NA_character_
    }
  }

  if (type == "affinity_project") {
    sets <- db_analysis_sets(con)
    sets$analysis_id <- NULL
    out <- dplyr::cross_join(out, sets)
  }
  out
}

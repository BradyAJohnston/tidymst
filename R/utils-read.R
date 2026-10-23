# Parsing helpers shared by the readers. MO.Affinity Analysis exports lay out
# one block per capillary (or per merge set) side by side. Each block is a
# series of titled key/value sections followed by a numeric table.

read_sheet <- function(path, sheet = 1) {
  x <- readxl::read_excel(
    path,
    sheet = sheet,
    col_names = FALSE,
    col_types = "text",
    .name_repair = "minimal"
  )
  m <- as.matrix(x)
  dimnames(m) <- NULL
  m
}

# Walks down `rows` of column `col`, collecting key/value pairs into named
# sections. Stops at the start of a data table and returns the row of its
# header.
parse_sections <- function(m, rows, col = 1) {
  sections <- list()
  section <- "header"
  included <- NA
  header_row <- NA_integer_
  ncol <- ncol(m)

  for (i in rows) {
    a <- m[i, col]
    b <- if (col < ncol) m[i, col + 1] else NA_character_
    if (is.na(a)) {
      next
    }
    if (identical(a, b)) {
      if (a %in% c("Included", "Outlier")) {
        included <- a == "Included"
        header_row <- i + 1L
        break
      }
      if (a == "Dose Response Curve") {
        header_row <- i + 1L
        break
      }
      section <- section_name(a)
      next
    }
    key <- sub(":\\s*$", "", a)
    sections[[section]][[key]] <- b
  }

  list(sections = sections, included = included, header_row = header_row)
}

section_name <- function(x) {
  switch(
    x,
    "Origin of exported data" = "origin",
    "Sample Information" = "sample",
    "Measurement Settings" = "measurement",
    "Analysis Settings" = "analysis",
    if (startsWith(x, "Fit Results")) "fit" else snake_case(x)
  )
}

# Locates the per-series blocks: the row holding "Sample Information" titles
# and the first column of each block.
find_series <- function(m, call = caller_env()) {
  rows <- which(apply(m, 1, \(x) any(x %in% "Sample Information")))
  if (length(rows) == 0) {
    cli::cli_abort(
      "Can't find any {.val Sample Information} blocks.",
      call = call
    )
  }
  row <- rows[[1]]
  title <- m[row, ] %in% "Sample Information"
  cols <- which(title & c(title[-1], FALSE))
  cols <- cols[!(cols - 1L) %in% cols]
  list(row = row, cols = cols)
}

# Parses one block starting at `col`, returning its metadata and data table.
parse_series <- function(m, row, col) {
  parsed <- parse_sections(m, row:nrow(m), col)
  data <- NULL
  if (!is.na(parsed$header_row)) {
    data <- block_table(m, parsed$header_row, col)
  }
  c(parsed, list(data = data))
}

block_table <- function(m, header_row, col) {
  cols <- col:min(col + 2L, ncol(m))
  header <- m[header_row, cols]
  width <- match(TRUE, is.na(header), nomatch = length(header) + 1L) - 1L
  cols <- cols[seq_len(width)]

  rows <- seq(header_row + 1L, length.out = max(nrow(m) - header_row, 0))
  end <- match(TRUE, is.na(m[rows, col]), nomatch = length(rows) + 1L) - 1L
  rows <- rows[seq_len(end)]

  values <- m[rows, cols, drop = FALSE]
  colnames(values) <- header[seq_len(width)]
  values
}

# Metadata ------------------------------------------------------------------

key_names <- c(
  "Project Title" = "project",
  "Comment" = "comment",
  "Project File Path" = "project_path",
  "Analysis-Set Name" = "analysis_set",
  "Exported from" = "exported_from",
  "Exported on" = "exported_on",
  "Type of Analysis" = "analysis_type",
  "Evaluation strategy" = "evaluation_strategy",
  "Cold Region Start" = "cold_start",
  "Cold Region End" = "cold_end",
  "Hot Region Start" = "hot_start",
  "Hot Region End" = "hot_end",
  "Merge-Set Name" = "merge_set",
  "Run Name" = "run",
  "Date of Measurement" = "measured_at",
  "Capillary Type" = "capillary_type",
  "Capillary Position" = "capillary",
  "Ligand" = "ligand",
  "Ligand Concentration" = "ligand_concentration",
  "Target" = "target",
  "TargetConcentration" = "target_concentration",
  "MST-Power" = "mst_power",
  "Excitation-Power" = "excitation_power",
  "Excitation type" = "excitation_type",
  "Thermostat Setpoint" = "thermostat_setpoint",
  "Fit Model" = "model",
  "Unbound" = "unbound",
  "Bound" = "bound",
  "Kd" = "kd",
  "Kd Confidence" = "kd_confidence",
  "TargetConc" = "target_concentration_fit",
  "Hill Coeff." = "hill",
  "EC50" = "ec50",
  "EC50 Confidence" = "ec50_confidence",
  "Standard Deviation" = "std_dev"
)

clean_names <- function(x) {
  out <- unname(key_names[x])
  missing <- is.na(out)
  out[missing] <- snake_case(x[missing])
  out
}

snake_case <- function(x) {
  x <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", x)
  x <- gsub("[^A-Za-z0-9]+", "_", x)
  tolower(gsub("^_|_$", "", x))
}

# Turns a list of named character vectors into a one-row tibble.
meta_row <- function(...) {
  x <- unlist(unname(list(...)))
  if (length(x) == 0) {
    return(tibble::tibble(.rows = 1))
  }
  names(x) <- clean_names(names(x))
  x <- x[!duplicated(names(x))]
  tibble::as_tibble(as.list(x))
}

# Repeats each row of `meta` to sit alongside its block of `data`.
expand_meta <- function(meta, data) {
  sizes <- vapply(data, vctrs::vec_size, integer(1))
  vctrs::vec_cbind(
    vctrs::vec_slice(meta, rep(seq_len(nrow(meta)), sizes)),
    vctrs::vec_rbind(!!!data)
  )
}

# Types ---------------------------------------------------------------------

integer_cols <- c("series", "capillary", "n")
concentration_cols <- c("ligand_concentration", "target_concentration")
datetime_cols <- c("measured_at", "measured_end", "exported_on")
character_cols <- c(
  "project",
  "comment",
  "project_path",
  "analysis_set",
  "exported_from",
  "analysis_type",
  "evaluation_strategy",
  "merge_set",
  "run",
  "origin",
  "capillary_type",
  "ligand",
  "target",
  "mst_power",
  "excitation_type",
  "thermostat_setpoint",
  "model",
  "response_type",
  "software"
)

# Converts the all-text columns read from the sheet into their proper types.
# Columns not listed above are assumed to be numeric.
coerce_columns <- function(df) {
  if ("measured_at" %in% names(df) && !"measured_end" %in% names(df)) {
    range <- split_date_range(df$measured_at)
    if (any(!is.na(range$end))) {
      df$measured_at <- range$start
      df$measured_end <- range$end
    }
  }
  for (col in names(df)) {
    x <- df[[col]]
    if (!is.character(x) || col %in% character_cols) {
      next
    }
    df[[col]] <- if (col %in% integer_cols) {
      as.integer(parse_number(x))
    } else if (col %in% concentration_cols) {
      parse_concentration(x)
    } else if (col %in% datetime_cols) {
      parse_datetime(x)
    } else {
      parse_number(x)
    }
  }
  if (all(c("measured_at", "measured_end") %in% names(df))) {
    df <- dplyr::relocate(df, "measured_end", .after = "measured_at")
  }
  if ("model" %in% names(df)) {
    df$model <- tolower(df$model)
  }
  df
}

parse_number <- function(x) {
  x[x %in% c("n/a", "NaN", "")] <- NA
  suppressWarnings(as.numeric(x))
}

# Concentrations are molar numbers, except in some exports where they are
# written with units, e.g. "50 nM".
parse_concentration <- function(x) {
  out <- parse_number(x)
  pattern <- "^\\s*([-+0-9.eE]+)\\s*([fpnum\u00b5\u03bc]?)M\\s*$"
  with_unit <- is.na(out) & grepl(pattern, x)
  if (any(with_unit)) {
    value <- as.numeric(sub(pattern, "\\1", x[with_unit]))
    prefix <- sub(pattern, "\\2", x[with_unit])
    scale <- c(
      f = 1e-15,
      p = 1e-12,
      n = 1e-9,
      u = 1e-6,
      "\u00b5" = 1e-6,
      "\u03bc" = 1e-6,
      m = 1e-3
    )
    out[with_unit] <- value * ifelse(prefix == "", 1, scale[prefix])
  }
  out
}

# Dates are either Excel serial numbers or text timestamps.
parse_datetime <- function(x) {
  out <- rep(as.POSIXct(NA, tz = "UTC"), length(x))
  serial <- grepl("^[0-9]+(\\.[0-9]+)?$", x)
  out[serial] <- as.POSIXct(
    (as.numeric(x[serial]) - 25569) * 86400,
    origin = "1970-01-01",
    tz = "UTC"
  )
  text <- !serial & !is.na(x)
  out[text] <- as.POSIXct(x[text], format = "%Y-%m-%d %H:%M:%OS", tz = "UTC")
  out
}

# Merge-set level exports give the measurement date as a range, "start -> end".
split_date_range <- function(x) {
  parts <- strsplit(x, "\\s*\u2192\\s*")
  list(
    start = vapply(parts, \(p) p[1], character(1)),
    end = vapply(
      parts,
      \(p) if (length(p) > 1) p[2] else NA_character_,
      character(1)
    )
  )
}

response_type <- function(x) {
  x <- tolower(gsub("\\s*\\[.*\\]$|[^A-Za-z]", "", x))
  types <- c(
    fnorm = "fnorm",
    deltafnorm = "delta_fnorm",
    fractionbound = "fraction_bound"
  )
  unname(types[x])
}

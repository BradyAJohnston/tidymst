#' Calculate normalised fluorescence from MST traces
#'
#' Fnorm is the ratio of the mean fluorescence in a "hot" window, while the IR
#' laser is on, to the mean fluorescence in a "cold" window just before it,
#' expressed in per mille. Recalculating Fnorm from [read_mst_traces()]
#' lets you choose the windows without going back to MO.Affinity Analysis.
#'
#' Windows include their start and exclude their end, as MO.Affinity Analysis
#' does, so the results match its Fnorm for the same windows.
#'
#' @param data A data frame of traces, as returned by [read_mst_traces()],
#'   with columns `time` and `fluorescence`.
#' @param hot,cold Start and end times of the hot and cold windows, in seconds,
#'   as numeric vectors of length 2. The hot window depends on how long the
#'   laser was on; look up the one used in MO.Affinity Analysis with
#'   [read_mst_metadata()].
#' @returns A tibble with one row per capillary, with the columns of `data`
#'   other than `time` and `fluorescence`, plus `response_type` (always
#'   `"fnorm"`) and `response`, the Fnorm in per mille. This is the same form as
#'   [read_mst_dose_response()], ready for [mst_fit()].
#' @export
#' @examples
#' traces <- read_mst_traces(nanotempr_example("dppr10-cy5_traces.xlsx"))
#' mst_fnorm(traces, hot = c(19, 20))
#'
#' # Use a shorter hot window, excluding outliers
#' traces |>
#'   dplyr::filter(included) |>
#'   mst_fnorm(hot = c(1.5, 2.5))
mst_fnorm <- function(data, hot, cold = c(-1, 0)) {
  check_data_frame(data)
  check_columns(data, c("time", "fluorescence"))
  check_window(hot)
  check_window(cold)
  check_window_has_data(hot, data$time)
  check_window_has_data(cold, data$time)

  data <- dplyr::ungroup(data)
  by <- setdiff(names(data), c("time", "fluorescence"))
  out <- dplyr::summarise(
    data,
    response_type = "fnorm",
    response = 1000 *
      window_mean(.data$fluorescence, .data$time, hot) /
      window_mean(.data$fluorescence, .data$time, cold),
    .by = dplyr::all_of(by)
  )
  out
}

window_mean <- function(x, time, window) {
  mean(x[time >= window[[1]] & time < window[[2]]])
}

check_window <- function(x, arg = caller_arg(x), call = caller_env()) {
  check_required(x, arg = arg, call = call)
  ok <- is.numeric(x) && length(x) == 2 && !anyNA(x) && x[[1]] < x[[2]]
  if (!ok) {
    cli::cli_abort(
      "{.arg {arg}} must be a numeric vector {.code c(start, end)} with
      {.code start} before {.code end}.",
      call = call
    )
  }
}

check_window_has_data <- function(
  window,
  time,
  arg = caller_arg(window),
  call = caller_env()
) {
  if (!any(time >= window[[1]] & time < window[[2]], na.rm = TRUE)) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must contain at least one time point.",
        i = "Times range from {signif(min(time), 3)} to {signif(max(time), 3)} s."
      ),
      call = call
    )
  }
}

check_columns <- function(
  data,
  cols,
  arg = caller_arg(data),
  call = caller_env()
) {
  missing <- setdiff(cols, names(data))
  if (length(missing) > 0) {
    cli::cli_abort(
      "{.arg {arg}} must have {cli::qty(missing)}column{?s} {.field {missing}}.",
      call = call
    )
  }
}

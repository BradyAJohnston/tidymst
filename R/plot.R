#' Plot MST traces
#'
#' Draws one line per capillary. Requires ggplot2.
#'
#' @param data A data frame of traces, as returned by [read_mst_traces()].
#' @param colour <[`data-masking`][rlang::args_data_masking]> The column to
#'   colour lines by. Numeric columns are coloured on a log scale.
#' @returns A ggplot.
#' @export
#' @examplesIf rlang::is_installed("ggplot2")
#' traces <- read_mst_traces(nanotempr_example("dppr10-cy5_traces.xlsx"))
#' mst_plot_traces(traces)
mst_plot_traces <- function(data, colour = ligand_concentration) {
  check_installed("ggplot2")
  check_data_frame(data)
  check_columns(data, c("time", "fluorescence"))

  id <- intersect(c("run", "capillary"), names(data))
  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      .data$time,
      .data$fluorescence,
      colour = {{ colour }},
      group = interaction(!!!syms(id))
    )
  ) +
    ggplot2::geom_line() +
    ggplot2::labs(x = "Time (s)", y = "Normalised fluorescence")

  if (is.numeric(eval_tidy(enquo(colour), data))) {
    plot <- plot + ggplot2::scale_colour_viridis_c(transform = "log10")
  }
  plot
}

#' Plot dose-response curves
#'
#' Draws the response at each concentration, with error bars if `data` has an
#' `error` column, and optionally the fitted curves. Requires ggplot2.
#'
#' @param data A data frame of dose-response data, such as from
#'   [read_mst_dose_response()] or [mst_fnorm()].
#' @param fits Optionally, a tibble of fits from [mst_fit()] to draw.
#' @param concentration,response,colour
#'   <[`data-masking`][rlang::args_data_masking]> The columns of ligand
#'   concentration, response, and colour of the points.
#' @returns A ggplot.
#' @export
#' @examplesIf rlang::is_installed("ggplot2")
#' doses <- read_mst_dose_response(
#'   nanotempr_example("dppr10-cy5_dose-response-flat.xlsx")
#' )
#' fits <- mst_fit(doses, .by = target)
#' mst_plot_dose_response(doses, fits, colour = target)
mst_plot_dose_response <- function(
  data,
  fits = NULL,
  concentration = ligand_concentration,
  response = response,
  colour = NULL
) {
  check_installed("ggplot2")
  check_data_frame(data)

  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes({{ concentration }}, {{ response }}, colour = {{ colour }})
  ) +
    ggplot2::geom_point() +
    ggplot2::scale_x_log10() +
    ggplot2::labs(x = "Ligand concentration (M)", y = "Response")

  if ("error" %in% names(data)) {
    plot <- plot +
      ggplot2::geom_errorbar(
        ggplot2::aes(
          ymin = {{ response }} - .data$error,
          ymax = {{ response }} + .data$error
        ),
        width = 0.05
      )
  }

  if (!is.null(fits)) {
    check_fits(fits)
    curves <- mst_curve(fits)
    by <- fit_by(fits)
    x <- setdiff(
      names(curves),
      c(by, "response", "delta_fnorm", "fraction_bound")
    )
    group <- if (length(by)) expr(interaction(!!!syms(by))) else 1
    mapping <- ggplot2::aes(.data[[x]], .data$response, group = !!group)
    # Colour the curves too, if they have the columns to.
    colour <- enquo(colour)
    if (!quo_is_null(colour) && all(all.vars(quo_get_expr(colour)) %in% by)) {
      mapping$colour <- colour
    }
    plot <- plot +
      ggplot2::geom_line(mapping, data = curves, inherit.aes = FALSE)
  }
  plot
}

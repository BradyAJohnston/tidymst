#' Fit binding models to dose-response data
#'
#' Fits the binding models used by MO.Affinity Analysis by non-linear least
#' squares, with [stats::nls()].
#'
#' @section Models:
#' The **Kd** model describes 1:1 binding of a ligand to a target, accounting
#' for depletion of free ligand:
#'
#' \deqn{f = \frac{c + c_T + K_d - \sqrt{(c + c_T + K_d)^2 - 4 c c_T}}{2 c_T}}
#'
#' \deqn{y = U + (B - U) f}
#'
#' where \eqn{c} is the ligand concentration, \eqn{c_T} the target
#' concentration, \eqn{f} the fraction of target bound, and \eqn{U} and
#' \eqn{B} the responses of the unbound and bound states.
#'
#' The **Hill** model describes cooperative binding:
#'
#' \deqn{y = U + \frac{B - U}{1 + (EC_{50} / c)^n}}
#'
#' @param data A data frame with a row for each concentration, such as from
#'   [read_mst_dose_response()] or [mst_fnorm()]. If `data` is grouped with
#'   [dplyr::group_by()], each group is fitted separately.
#' @param model The model to fit, `"kd"` or `"hill"`. See the Models section.
#' @param concentration,response <[`data-masking`][rlang::args_data_masking]>
#'   The columns of ligand concentration (molar) and response.
#' @param target_concentration For the Kd model, the target concentration in
#'   molar. If `NULL`, the default, it is estimated along with the other
#'   parameters, as MO.Affinity Analysis can do. If it is known, fixing it
#'   gives a more stable fit.
#' @param .by <[`tidy-select`][dplyr::dplyr_tidy_select]> Columns to group by,
#'   fitting each group separately. An alternative to grouping `data`.
#' @returns A tibble with one row per group, with the grouping columns and:
#'   * `model`: the model fitted.
#'   * `n`: the number of points fitted.
#'   * `sigma`: the residual standard deviation.
#'   * `fit`: the fitted model, used by [mst_coefs()], [mst_curve()] and
#'     [mst_normalise()]. `NULL` if the fit failed.
#' @export
#' @examples
#' doses <- read_mst_dose_response(
#'   nanotempr_example("dppr10-cy5_dose-response-flat.xlsx")
#' )
#' fits <- mst_fit(doses, .by = target)
#' fits
#'
#' mst_coefs(fits)
#'
#' # Fix the target concentration at its nominal value
#' mst_fit(doses, target_concentration = 50e-9, .by = target)
mst_fit <- function(
  data,
  model = c("kd", "hill"),
  concentration = ligand_concentration,
  response = response,
  target_concentration = NULL,
  .by = NULL
) {
  check_data_frame(data)
  model <- arg_match(model)
  check_number_decimal(target_concentration, min = 0, allow_null = TRUE)
  if (!is.null(target_concentration) && model != "kd") {
    cli::cli_abort(
      "{.arg target_concentration} can only be used with {.code model = \"kd\"}."
    )
  }

  if (dplyr::is_grouped_df(data)) {
    if (!quo_is_null(enquo(.by))) {
      cli::cli_abort("Can't supply {.arg .by} when {.arg data} is grouped.")
    }
    by <- dplyr::group_vars(data)
    data <- dplyr::ungroup(data)
  } else {
    by <- names(tidyselect::eval_select(enquo(.by), data))
  }
  concentration_name <- as_label(enquo(concentration))

  out <- dplyr::summarise(
    data,
    fit = list(try_fit_binding(
      {{ concentration }},
      {{ response }},
      model = .env$model,
      target_concentration = .env$target_concentration,
      concentration_name = .env$concentration_name
    )),
    .by = dplyr::all_of(by)
  )

  failed <- vapply(out$fit, is.null, logical(1))
  if (any(failed)) {
    cli::cli_warn("Failed to fit {sum(failed)} of {length(failed)} group{?s}.")
  }

  out$model <- model
  out$n <- vapply(
    out$fit,
    \(f) if (is.null(f)) NA_integer_ else f$n,
    integer(1)
  )
  out$sigma <- vapply(
    out$fit,
    \(f) if (is.null(f)) NA_real_ else stats::sigma(f$nls),
    double(1)
  )
  dplyr::relocate(out, "fit", .after = dplyr::last_col())
}

try_fit_binding <- function(...) {
  tryCatch(fit_binding(...), error = function(e) NULL)
}

fit_binding <- function(
  concentration,
  response,
  model,
  target_concentration,
  concentration_name
) {
  ok <- !is.na(concentration) & !is.na(response) & concentration > 0
  concentration <- concentration[ok]
  response <- response[ok]

  # Rescale so all parameters are of order 1, which nls() needs to converge.
  scale <- exp(mean(log(concentration)))
  df <- data.frame(x = concentration / scale, y = response)

  unbound <- mean(df$y[df$x == min(df$x)])
  bound <- mean(df$y[df$x == max(df$x)])
  midpoint <- df$x[which.min(abs(df$y - (unbound + bound) / 2))]

  if (model == "kd") {
    if (is.null(target_concentration)) {
      formula <- y ~ kd_model(x, unbound, bound, kd, target_concentration)
      start <- list(
        unbound = unbound,
        bound = bound,
        kd = midpoint,
        target_concentration = midpoint
      )
    } else {
      df$target <- target_concentration / scale
      formula <- y ~ kd_model(x, unbound, bound, kd, target)
      start <- list(unbound = unbound, bound = bound, kd = midpoint)
    }
  } else {
    formula <- y ~ hill_model(x, unbound, bound, ec50, hill)
    start <- list(unbound = unbound, bound = bound, ec50 = midpoint, hill = 1)
  }
  # nls() can loop indefinitely when there are too few points.
  if (nrow(df) <= length(start)) {
    cli::cli_abort("Need more points than parameters to fit.")
  }
  lower <- c(-Inf, -Inf, rep(1e-8, length(start) - 2))

  fit <- stats::nls(
    formula,
    data = df,
    start = start,
    lower = lower,
    algorithm = "port",
    control = stats::nls.control(maxiter = 500)
  )

  structure(
    list(
      nls = fit,
      model = model,
      scale = scale,
      target_concentration = target_concentration,
      range = range(concentration),
      n = nrow(df),
      concentration_name = concentration_name
    ),
    class = "mst_binding_fit"
  )
}

kd_model <- function(x, unbound, bound, kd, target) {
  s <- x + target + kd
  unbound + (bound - unbound) * (s - sqrt(s^2 - 4 * x * target)) / (2 * target)
}

hill_model <- function(x, unbound, bound, ec50, hill) {
  unbound + (bound - unbound) / (1 + (ec50 / x)^hill)
}

concentration_terms <- c("kd", "target_concentration", "ec50")

# Estimates in the original units.
fit_estimates <- function(fit) {
  coefs <- summary(fit$nls)$coefficients
  scale <- ifelse(rownames(coefs) %in% concentration_terms, fit$scale, 1)
  list(
    term = rownames(coefs),
    estimate = coefs[, "Estimate"] * scale,
    std_error = coefs[, "Std. Error"] * scale,
    df = stats::df.residual(fit$nls)
  )
}

fit_params <- function(fit) {
  est <- fit_estimates(fit)
  params <- as.list(stats::setNames(est$estimate, est$term))
  if (fit$model == "kd" && !is.null(fit$target_concentration)) {
    params$target_concentration <- fit$target_concentration
  }
  params
}

predict_fit <- function(fit, x) {
  p <- fit_params(fit)
  if (fit$model == "kd") {
    kd_model(x, p$unbound, p$bound, p$kd, p$target_concentration)
  } else {
    hill_model(x, p$unbound, p$bound, p$ec50, p$hill)
  }
}

#' Get fitted model coefficients
#'
#' @param fits A tibble of fits from [mst_fit()].
#' @param conf_level Confidence level of the intervals.
#' @returns A tibble with one row per parameter per fit, with the grouping
#'   columns of `fits` and:
#'   * `model`: the model fitted.
#'   * `term`: the parameter: `unbound`, `bound`, and `kd` and
#'     `target_concentration` for the Kd model or `ec50` and `hill` for the
#'     Hill model. A fixed `target_concentration` is not included.
#'   * `estimate` and `std_error`: the estimate and its standard error.
#'     Concentrations are molar.
#'   * `conf_low` and `conf_high`: the confidence interval, from the
#'     t-distribution.
#' @export
#' @examples
#' doses <- read_mst_dose_response(
#'   nanotempr_example("dppr10-cy5_dose-response-flat.xlsx")
#' )
#' fits <- mst_fit(doses, .by = target)
#' mst_coefs(fits)
mst_coefs <- function(fits, conf_level = 0.95) {
  check_fits(fits)
  check_number_decimal(conf_level, min = 0, max = 1)

  ok <- !vapply(fits$fit, is.null, logical(1))
  rows <- lapply(fits$fit[ok], \(fit) {
    est <- fit_estimates(fit)
    q <- stats::qt((1 + conf_level) / 2, est$df)
    tibble::tibble(
      term = est$term,
      estimate = est$estimate,
      std_error = est$std_error,
      conf_low = est$estimate - q * est$std_error,
      conf_high = est$estimate + q * est$std_error
    )
  })
  expand_meta(fits[ok, c(fit_by(fits), "model")], rows)
}

#' Predict fitted binding curves
#'
#' @inheritParams mst_coefs
#' @param n Number of points on each curve, spaced evenly on a log scale over
#'   the range of concentrations fitted.
#' @returns A tibble with `n` rows per fit, with the grouping columns of
#'   `fits` and:
#'   * The concentration, named as in [mst_fit()] (`ligand_concentration` by
#'     default).
#'   * `response`: the fitted response.
#'   * `delta_fnorm`: the response relative to the unbound state.
#'   * `fraction_bound`: the fraction of target bound.
#' @export
#' @examples
#' doses <- read_mst_dose_response(
#'   nanotempr_example("dppr10-cy5_dose-response-flat.xlsx")
#' )
#' fits <- mst_fit(doses, .by = target)
#' mst_curve(fits)
mst_curve <- function(fits, n = 100) {
  check_fits(fits)
  check_number_whole(n, min = 2)

  ok <- !vapply(fits$fit, is.null, logical(1))
  rows <- lapply(fits$fit[ok], \(fit) {
    x <- 10^seq(log10(fit$range[[1]]), log10(fit$range[[2]]), length.out = n)
    p <- fit_params(fit)
    y <- predict_fit(fit, x)
    tibble::tibble(
      !!fit$concentration_name := x,
      response = y,
      delta_fnorm = y - p$unbound,
      fraction_bound = (y - p$unbound) / (p$bound - p$unbound)
    )
  })
  expand_meta(fits[ok, fit_by(fits)], rows)
}

#' Normalise responses to delta Fnorm and fraction bound
#'
#' Uses the unbound and bound states of fitted models to express responses
#' relative to the unbound state (delta Fnorm), and as the fraction of target
#' bound. This puts merge sets with different baselines on the same scale.
#'
#' @param data A data frame of dose-response data, as passed to [mst_fit()].
#' @param fits A tibble of fits from [mst_fit()]. Its grouping columns must
#'   also be in `data`.
#' @param response <[`data-masking`][rlang::args_data_masking]> The column of
#'   response, in the same units as the fits.
#' @returns `data` with two new columns:
#'   * `delta_fnorm`: the response minus the unbound response.
#'   * `fraction_bound`: `delta_fnorm` divided by the difference between the
#'     bound and unbound responses.
#' @export
#' @examples
#' doses <- read_mst_dose_response(
#'   nanotempr_example("dppr10-cy5_dose-response-flat.xlsx")
#' )
#' fits <- mst_fit(doses, .by = target)
#' mst_normalise(doses, fits)
mst_normalise <- function(data, fits, response = response) {
  check_data_frame(data)
  check_fits(fits)
  by <- fit_by(fits)
  check_columns(data, by)

  ok <- !vapply(fits$fit, is.null, logical(1))
  params <- fits[by]
  params$.unbound <- NA_real_
  params$.bound <- NA_real_
  params$.unbound[ok] <- vapply(
    fits$fit[ok],
    \(f) fit_params(f)$unbound,
    double(1)
  )
  params$.bound[ok] <- vapply(fits$fit[ok], \(f) fit_params(f)$bound, double(1))

  joined <- if (length(by) > 0) {
    dplyr::left_join(
      dplyr::ungroup(data),
      params,
      by = by,
      relationship = "many-to-one"
    )
  } else {
    dplyr::cross_join(dplyr::ungroup(data), params)
  }
  y <- eval_tidy(enquo(response), joined)
  data$delta_fnorm <- y - joined$.unbound
  data$fraction_bound <- data$delta_fnorm / (joined$.bound - joined$.unbound)
  data
}

fit_by <- function(fits) {
  setdiff(names(fits), c("model", "n", "sigma", "fit"))
}

check_fits <- function(x, arg = caller_arg(x), call = caller_env()) {
  ok <- is.data.frame(x) &&
    "fit" %in% names(x) &&
    is.list(x$fit) &&
    all(vapply(
      x$fit,
      \(f) is.null(f) || inherits(f, "mst_binding_fit"),
      logical(1)
    ))
  if (!ok) {
    cli::cli_abort(
      "{.arg {arg}} must be a tibble of fits from {.fn mst_fit}.",
      call = call
    )
  }
}

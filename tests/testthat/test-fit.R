test_that("Kd fit matches MO.Affinity Analysis", {
  traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
  outliers <- dplyr::distinct(dplyr::filter(traces, !included), run, capillary)
  doses <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))
  doses <- dplyr::anti_join(doses, outliers, by = c("run", "capillary"))
  expected <- read_mst_fit(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))[
    1,
  ]

  fits <- mst_fit(dplyr::filter(doses, target == "atpH-fl"))
  coefs <- mst_coefs(fits)
  estimate <- stats::setNames(coefs$estimate, coefs$term)

  expect_equal(fits$n, 47L)
  expect_equal(estimate[["kd"]], expected$kd, tolerance = 0.01)
  expect_equal(
    estimate[["target_concentration"]],
    expected$target_concentration_fit,
    tolerance = 0.01
  )
  expect_equal(estimate[["unbound"]], expected$unbound, tolerance = 1e-4)
  expect_equal(estimate[["bound"]], expected$bound, tolerance = 1e-4)
})

test_that("Hill fit matches MO.Affinity Analysis", {
  path <- tidymst_example("dsnppr10_compare-delta-fnorm.xlsx")
  doses <- dplyr::filter(read_mst_dose_response(path), series == 1)
  expected <- read_mst_fit(path)[1, ]

  coefs <- mst_coefs(mst_fit(doses, model = "hill"))
  estimate <- stats::setNames(coefs$estimate, coefs$term)

  expect_equal(estimate[["ec50"]], expected$ec50, tolerance = 1e-3)
  expect_equal(estimate[["hill"]], expected$hill, tolerance = 1e-3)
})

test_that("fits are robust to rounding differences between platforms", {
  # This delta Fnorm data has an unbound baseline at zero, which made fits
  # fail on some platforms but not others.
  path <- tidymst_example("dsnppr10_compare-delta-fnorm.xlsx")
  doses <- dplyr::filter(read_mst_dose_response(path), series == 1)
  expected <- read_mst_fit(path)$ec50[[1]]

  ec50 <- vapply(
    1:10,
    \(i) {
      jittered <- doses
      jittered$response <- doses$response *
        (1 + 1e-10 * sin(i * seq_along(doses$response)))
      coefs <- suppressWarnings(mst_coefs(mst_fit(jittered, model = "hill")))
      if (nrow(coefs) == 0) NA_real_ else coefs$estimate[coefs$term == "ec50"]
    },
    double(1)
  )
  expect_equal(ec50, rep(expected, 10), tolerance = 1e-3)
})

test_that("concentration confidence intervals are positive and asymmetric", {
  path <- tidymst_example("dsnppr10_compare-delta-fnorm.xlsx")
  doses <- dplyr::filter(read_mst_dose_response(path), series == 1)
  coefs <- mst_coefs(mst_fit(doses, model = "hill"))
  ec50 <- coefs[coefs$term == "ec50", ]

  expect_gt(ec50$conf_low, 0)
  expect_lt(ec50$conf_low, ec50$estimate)
  expect_gt(
    ec50$conf_high - ec50$estimate,
    ec50$estimate - ec50$conf_low
  )
})

test_that("mst_fit() fits groups and fixed target concentrations", {
  doses <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))

  by <- mst_fit(doses, target_concentration = 50e-9, .by = target)
  grouped <- mst_fit(
    dplyr::group_by(doses, target),
    target_concentration = 50e-9
  )
  expect_equal(by, grouped, ignore_attr = TRUE)
  expect_named(by, c("target", "model", "n", "sigma", "fit"))
  expect_equal(nrow(by), 1)
  expect_false("target_concentration" %in% mst_coefs(by)$term)
})

test_that("mst_fit() warns when fits fail", {
  doses <- tibble::tibble(ligand_concentration = c(1, 2), response = c(1, 1))
  expect_snapshot(fits <- mst_fit(doses))
  expect_null(fits$fit[[1]])

  coefs <- mst_coefs(fits)
  expect_equal(nrow(coefs), 0)
  expect_named(
    coefs,
    c("model", "term", "estimate", "std_error", "conf_low", "conf_high")
  )
  curve <- mst_curve(fits)
  expect_equal(nrow(curve), 0)
  expect_named(
    curve,
    c("ligand_concentration", "response", "delta_fnorm", "fraction_bound")
  )
})

test_that("mst_fit() validates arguments", {
  doses <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))
  expect_snapshot(error = TRUE, {
    mst_fit(doses, model = "linear")
    mst_fit(doses, model = "hill", target_concentration = 1e-9)
    mst_fit(dplyr::group_by(doses, target), .by = target)
    mst_coefs(doses)
  })
})

test_that("mst_curve() spans the fitted range", {
  doses <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))
  fits <- mst_fit(doses, .by = target)
  curve <- mst_curve(fits, n = 10)
  estimate <- stats::setNames(mst_coefs(fits)$estimate, mst_coefs(fits)$term)

  expect_equal(nrow(curve), 10)
  expect_equal(
    range(curve$ligand_concentration),
    range(doses$ligand_concentration)
  )
  expect_equal(curve$delta_fnorm, curve$response - estimate[["unbound"]])
  expect_equal(
    curve$fraction_bound,
    curve$delta_fnorm / (estimate[["bound"]] - estimate[["unbound"]])
  )
})

test_that("mst_normalise() matches fraction bound exported by MO.Affinity Analysis", {
  traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
  outliers <- dplyr::distinct(dplyr::filter(traces, !included), run, capillary)
  flat <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))
  flat <- dplyr::anti_join(flat, outliers, by = c("run", "capillary"))
  fits <- mst_fit(dplyr::filter(flat, target == "atpH-fl"), .by = target)

  fnorm <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_compare-fnorm.xlsx"
  ))
  fnorm <- dplyr::filter(fnorm, target == "atpH-fl")
  bound <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_compare-fraction-bound.xlsx"
  ))
  bound <- dplyr::filter(bound, target == "atpH-fl")

  normalised <- mst_normalise(fnorm, fits)
  expect_equal(normalised$fraction_bound, bound$response, tolerance = 1e-3)
  expect_equal(
    normalised$delta_fnorm,
    normalised$response - mst_coefs(fits)$estimate[[1]]
  )
})

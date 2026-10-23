test_that("read_mst() dispatches on export type", {
  expect_equal(
    read_mst(tidymst_example("dsnppr10_compare-grid.xlsx")),
    read_mst_fit(tidymst_example("dsnppr10_compare-grid.xlsx"))
  )
  expect_named(
    read_mst(tidymst_example("dppr10c2_capillary-scan.xlsx")),
    names(read_mst_capillary_scan(tidymst_example(
      "dppr10c2_capillary-scan.xlsx"
    )))
  )
})

test_that("read_mst_traces() returns one trace per capillary", {
  traces <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))

  expect_s3_class(traces, "tbl_df")
  expect_equal(nrow(dplyr::distinct(traces, run, capillary)), 80)
  expect_type(traces$capillary, "integer")
  expect_type(traces$ligand_concentration, "double")
  expect_s3_class(traces$measured_at, "POSIXct")
  expect_equal(
    dplyr::distinct(dplyr::filter(traces, !included), run, capillary),
    tibble::tibble(
      run = "Run atpH-fl_50_dPPR10-Cy5 of Experiment #03",
      capillary = 9L
    )
  )
  expect_equal(range(traces$time), c(-3.57674884796143, 23.7704772949219))
})

test_that("read_mst_capillary_scan() reads positions", {
  scan <- read_mst_capillary_scan(tidymst_example(
    "dppr10c2_capillary-scan.xlsx"
  ))

  expect_equal(nrow(dplyr::distinct(scan, run, capillary)), 96)
  expect_type(scan$position, "double")
  expect_type(scan$fluorescence, "double")
})

test_that("read_mst_dose_response() reads merge-set exports", {
  doses <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_compare-fnorm.xlsx"
  ))

  expect_equal(nrow(doses), 32)
  expect_equal(unique(doses$response_type), "fnorm")
  expect_equal(unique(doses$target), c("atpH-fl", "NEAT1-fl"))
  expect_equal(unique(doses$target_concentration), 5e-8)
  expect_equal(doses$response[[1]], 1095.74731756402)
  expect_s3_class(doses$measured_end, "POSIXct")
})

test_that("read_mst_dose_response() finds the response type", {
  type <- \(f) {
    unique(read_mst_dose_response(tidymst_example(f))$response_type)
  }

  expect_equal(type("dppr10-cy5_compare-fraction-bound.xlsx"), "fraction_bound")
  expect_equal(type("dsnppr10_compare-delta-fnorm.xlsx"), "delta_fnorm")
  expect_equal(type("dppr10-cy5_dose-response-grouped.xlsx"), "fnorm")
  expect_equal(type("dppr10-cy5_dose-response-flat.xlsx"), "fnorm")
})

test_that("read_mst_dose_response() reads flat exports", {
  doses <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))

  expect_equal(nrow(doses), 48)
  expect_equal(
    names(doses)[1:9],
    c(
      "merge_set",
      "run",
      "capillary",
      "target",
      "target_concentration",
      "ligand",
      "ligand_concentration",
      "response_type",
      "response"
    )
  )
  # Written as "50 nM" in flat exports
  expect_equal(unique(doses$target_concentration), 5e-8)
})

test_that("read_mst_fit() reads Kd, Hill and grid fits", {
  kd <- read_mst_fit(tidymst_example("dppr10-cy5_compare-fnorm.xlsx"))
  expect_equal(kd$model, c("kd", "kd"))
  expect_equal(kd$kd[[1]], 1.25774389704214e-08)
  expect_equal(kd$kd_confidence, c(2.49237821641024e-09, NA))

  hill <- read_mst_fit(tidymst_example("dsnppr10_compare-delta-fnorm.xlsx"))
  expect_equal(hill$model, c("hill", "hill"))
  expect_equal(hill$hill, c(1.35197458620559, 1.8))

  grid <- read_mst_fit(tidymst_example("dsnppr10_compare-grid.xlsx"))
  expect_equal(nrow(grid), 4)
  expect_equal(grid$n, rep(3L, 4))
  expect_equal(grid$kd[[3]], 2.24657246656874e-08)
})

test_that("read_mst_fit_curve() reads curves, dropping empty ones", {
  path <- tidymst_example("dsnppr10_compare-delta-fnorm.xlsx")
  curve <- read_mst_fit_curve(path)
  expect_equal(nrow(curve), 300)
  expect_equal(unique(curve$response_type), "delta_fnorm")

  # Delta Fnorm is Fnorm relative to the unbound state
  first <- dplyr::filter(curve, series == 1)
  unbound <- read_mst_fit(path)$unbound[[1]]
  expect_equal(first$response, first$fnorm - unbound, tolerance = 1e-6)

  empty <- read_mst_fit_curve(tidymst_example(
    "dppr10-cy5_compare-fnorm.xlsx"
  ))
  expect_equal(nrow(empty), 0)
})

test_that("read_mst_metadata() reads the header", {
  meta <- read_mst_metadata(tidymst_example("dppr10-cy5_traces.xlsx"))

  expect_equal(nrow(meta), 1)
  expect_equal(meta$software, "MO.Affinity Analysis v2.2.7")
  expect_equal(meta$exported_from, "MST Traces")
  expect_equal(c(meta$hot_start, meta$hot_end), c(19, 20))

  flat <- read_mst_metadata(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))
  expect_equal(flat$exported_from, "Dose-Response (Flat)")
})

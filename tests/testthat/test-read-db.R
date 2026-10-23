test_that("detects project files", {
  expect_equal(
    mst_export_type(tidymst_example("dppr10-cy5.nta")),
    "affinity_project"
  )
  expect_equal(mst_export_type(local_control_project()), "control_project")
})

test_that("traces match the MST Traces export of the same project", {
  db <- read_mst_traces(tidymst_example("dppr10-cy5.nta"))
  xl <- read_mst_traces(tidymst_example("dppr10-cy5_traces.xlsx"))
  db$i <- stats::ave(db$time, db$run, db$capillary, FUN = seq_along)
  xl$i <- stats::ave(xl$time, xl$run, xl$capillary, FUN = seq_along)
  joined <- dplyr::inner_join(db, xl, by = c("run", "capillary", "i"))

  expect_equal(nrow(joined), nrow(xl))
  expect_equal(joined$time.x, joined$time.y)
  expect_equal(joined$ligand_concentration.x, joined$ligand_concentration.y)
  expect_equal(joined$target_concentration.x, joined$target_concentration.y)
  expect_equal(joined$included.x, joined$included.y)
  expect_equal(joined$fluorescence.x, joined$fluorescence.y, tolerance = 2e-3)
  expect_equal(unique(db$analysis_set), "Analysis-Set #1")
})

test_that("Fnorm matches the Dose-Response (Flat) export", {
  db <- read_mst_dose_response(tidymst_example("dppr10-cy5.nta"))
  flat <- read_mst_dose_response(tidymst_example(
    "dppr10-cy5_dose-response-flat.xlsx"
  ))
  joined <- dplyr::inner_join(db, flat, by = c("run", "capillary"))

  expect_equal(nrow(db), 80)
  expect_equal(nrow(joined), 48)
  expect_equal(joined$response.x, joined$response.y, tolerance = 1e-6)
  expect_equal(joined$temperature.x, joined$temperature.y)
  expect_equal(sum(!db$included), 1)
  expect_equal(unique(db$hot_start), 19)
})

test_that("reads the fits saved in the project", {
  fits <- read_mst_fit(tidymst_example("dppr10-cy5.nta"))
  atph <- fits[fits$target == "atpH-fl" & fits$model == "kd", ]

  expect_equal(nrow(fits), 3)
  expect_equal(atph$fixed, "bound")
  expect_equal(atph$bound, 850)
  expect_equal(atph$kd, 1.4424234491942446e-08)
  expect_equal(atph$kd_std_error, sqrt(4.180092799168243e-18))
  expect_equal(atph$bound_std_error, NA_real_)
})

test_that("capillary scans are centred on their capillaries", {
  scans <- read_mst_capillary_scan(tidymst_example("dppr10-cy5.nta"))
  centre <- dplyr::summarise(
    scans,
    peak = position[which.max(fluorescence)],
    .by = c(run, capillary)
  )

  expect_equal(nrow(centre), 80)
  expect_lt(max(abs(centre$peak - centre$capillary)), 0.5)
})

test_that("reads metadata from projects", {
  meta <- read_mst_metadata(tidymst_example("dppr10-cy5.nta"))
  expect_equal(nrow(meta), 1)
  expect_equal(meta$software, "MO.Affinity Analysis")
  expect_equal(meta$project, "dPPR10-C5_binding_test")
  expect_equal(meta$evaluation_strategy, "Manual")

  meta <- read_mst_metadata(local_control_project())
  expect_equal(meta$software, "MO.Control")
  expect_false("analysis_set" %in% names(meta))
})

test_that("MO.Control projects name runs as MO.Affinity Analysis does", {
  analysed <- read_mst_traces(tidymst_example("dppr10-cy5.nta"))
  measured <- read_mst_traces(local_control_project())

  expect_equal(sort(unique(measured$run)), sort(unique(analysed$run)))
  expect_equal(unique(measured$analysis_set), NA_character_)
  expect_equal(unique(measured$included), NA)
})

test_that("errors informatively on unsupported project reads", {
  empty <- local_empty_project()
  control <- local_control_project()
  expect_snapshot(
    error = TRUE,
    transform = \(x) gsub("'[^']*\\.moc'", "'<project>.moc'", x),
    {
      read_mst_traces(empty)
      read_mst_fit(control)
      read_mst_fit_curve(tidymst_example("dppr10-cy5.nta"))
    }
  )
})

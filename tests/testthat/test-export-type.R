test_that("detects every example export type", {
  types <- vapply(
    tidymst_example(),
    \(f) mst_export_type(tidymst_example(f)),
    character(1)
  )
  expect_equal(
    types,
    c(
      "dppr10-cy5.nta" = "affinity_project",
      "dppr10-cy5_compare-fnorm.xlsx" = "compare_chart",
      "dppr10-cy5_compare-fraction-bound.xlsx" = "compare_chart",
      "dppr10-cy5_dose-response-flat.xlsx" = "dose_response_flat",
      "dppr10-cy5_dose-response-grouped.xlsx" = "dose_response_grouped",
      "dppr10-cy5_traces.xlsx" = "traces",
      "dppr10c2_capillary-scan.xlsx" = "capillary_scan",
      "dsnppr10_compare-delta-fnorm.xlsx" = "compare_chart",
      "dsnppr10_compare-grid.xlsx" = "compare_grid"
    )
  )
})

test_that("errors informatively on bad input", {
  expect_snapshot(error = TRUE, {
    mst_export_type(1)
    mst_export_type("missing.xlsx")
    read_mst_traces(tidymst_example("dsnppr10_compare-grid.xlsx"))
  })
})
